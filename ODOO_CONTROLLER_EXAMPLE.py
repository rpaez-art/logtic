# -*- coding: utf-8 -*-
"""
Controller REST API para mss_route_optimization
Coloca este archivo en: addons/mss_route_optimization/controllers/api.py

IMPORTANTE: Para notificaciones push instantáneas con FCM, también necesitas:
  1. pip install firebase-admin (en el servidor Odoo)
  2. Crear proyecto en Firebase Console → descargar service account JSON
  3. Colocarlo en: /etc/odoo/firebase-service-account.json (o la ruta que prefieras)
  4. Ajustar FCM_CREDENTIALS_PATH abajo con esa ruta
"""

from odoo import http, models, fields, api
from odoo.http import request
import json
import logging
from datetime import datetime, date

_logger = logging.getLogger(__name__)

# ============================================================================
# Firebase Cloud Messaging (FCM) - Push Notifications Instantáneas
# ============================================================================
FCM_CREDENTIALS_PATH = '/etc/odoo/firebase-service-account.json'
_fcm_initialized = False

def _init_firebase():
    """Inicializar Firebase Admin SDK (solo una vez)."""
    global _fcm_initialized
    if _fcm_initialized:
        return True
    try:
        import firebase_admin
        from firebase_admin import credentials
        cred = credentials.Certificate(FCM_CREDENTIALS_PATH)
        firebase_admin.initialize_app(cred)
        _fcm_initialized = True
        _logger.info("Firebase Admin SDK inicializado correctamente")
        return True
    except Exception as e:
        _logger.error("Error inicializando Firebase: %s", str(e))
        return False

def send_fcm_notification(driver_id, data_payload):
    """
    Enviar notificación push FCM a un conductor específico.
    
    :param driver_id: ID del res.partner (conductor)
    :param data_payload: dict con los datos a enviar (se usa 'data' message, no 'notification')
    """
    try:
        from firebase_admin import messaging
    except ImportError:
        _logger.warning("firebase-admin no instalado, no se puede enviar push")
        return False
    
    if not _init_firebase():
        return False
    
    try:
        # Buscar tokens FCM del conductor
        env = request.env if hasattr(request, 'env') else None
        if env is None:
            return False
        
        tokens = env['fcm.device.token'].sudo().search([
            ('driver_id', '=', driver_id),
            ('active', '=', True)
        ])
        
        if not tokens:
            _logger.info("No hay tokens FCM para driver_id=%s", driver_id)
            return False
        
        success_count = 0
        for token_record in tokens:
            try:
                message = messaging.Message(
                    data={str(k): str(v) for k, v in data_payload.items()},
                    token=token_record.token,
                    android=messaging.AndroidConfig(
                        priority='high',
                        ttl=300  # 5 minutos de vida
                    )
                )
                messaging.send(message)
                success_count += 1
                _logger.info("Push FCM enviado a token=%s...", token_record.token[:20])
            except messaging.UnregisteredError:
                # Token inválido, desactivar
                token_record.sudo().write({'active': False})
                _logger.info("Token FCM inválido desactivado: %s...", token_record.token[:20])
            except Exception as e:
                _logger.error("Error enviando FCM: %s", str(e))
        
        return success_count > 0
    except Exception as e:
        _logger.error("Error en send_fcm_notification: %s", str(e))
        return False


# ============================================================================
# Modelo para almacenar tokens FCM de dispositivos
# Crear archivo: addons/mss_route_optimization/models/fcm_device_token.py
# Y agregarlo al __init__.py del módulo
# ============================================================================
class FcmDeviceToken(models.Model):
    _name = 'fcm.device.token'
    _description = 'Token FCM de dispositivo móvil'
    
    driver_id = fields.Many2one('res.partner', string='Conductor', required=True, index=True)
    token = fields.Char(string='Token FCM', required=True, index=True)
    platform = fields.Selection([
        ('android', 'Android'),
        ('ios', 'iOS')
    ], string='Plataforma', default='android')
    active = fields.Boolean(default=True)
    last_used = fields.Datetime(string='Último uso', default=fields.Datetime.now)
    
    _sql_constraints = [
        ('unique_token', 'UNIQUE(token)', 'Este token FCM ya está registrado')
    ]


# ============================================================================
# Modelo heredado de mss.route para enviar push al asignar conductor
# Agregar al archivo de modelos existente del módulo
# ============================================================================
class MssRouteWithFcm(models.Model):
    _inherit = 'mss.route'
    
    def write(self, vals):
        """Override write para detectar cuando se asigna un conductor y enviar push."""
        # Detectar si se está cambiando el driver_id
        old_drivers = {}
        if 'driver_id' in vals:
            for route in self:
                old_drivers[route.id] = route.driver_id.id if route.driver_id else False
        
        result = super().write(vals)
        
        # Si se asignó/cambió conductor, enviar notificación push
        if 'driver_id' in vals and vals['driver_id']:
            new_driver_id = vals['driver_id']
            routes_to_notify = []
            
            for route in self:
                old_driver = old_drivers.get(route.id, False)
                # Solo notificar si es una nueva asignación o cambió
                if old_driver != new_driver_id:
                    routes_to_notify.append(route)
            
            if routes_to_notify:
                route_names = ', '.join([r.name for r in routes_to_notify])
                data_payload = {
                    'type': 'route_assigned',
                    'route_count': str(len(routes_to_notify)),
                    'route_name': routes_to_notify[0].name if len(routes_to_notify) == 1 else '',
                    'route_names': route_names,
                    'route_date': str(routes_to_notify[0].date) if routes_to_notify else '',
                    'route_ids': ','.join([str(r.id) for r in routes_to_notify]),
                }
                
                # Enviar push FCM (no bloquea si falla)
                try:
                    send_fcm_notification(new_driver_id, data_payload)
                    _logger.info(
                        "Push enviado a driver_id=%s para rutas: %s",
                        new_driver_id, route_names
                    )
                except Exception as e:
                    _logger.error("Error enviando push al asignar ruta: %s", str(e))
        
        return result

class RouteOptimizationAPI(http.Controller):
    
    @http.route('/api/auth/login', type='json', auth='none', methods=['POST'], csrf=False)
    def login(self, **kwargs):
        """Autenticar usuario"""
        try:
            params = request.jsonrequest
            db = params.get('db')
            login = params.get('login')
            password = params.get('password')
            
            uid = request.session.authenticate(db, login, password)
            
            if uid:
                # Obtener información del usuario y conductor
                user = request.env['res.users'].sudo().browse(uid)
                partner = user.partner_id
                
                # Determinar el rol (puedes personalizar esta lógica)
                role = 'user'
                if user.has_group('base.group_system'):
                    role = 'admin'
                elif partner and hasattr(partner, 'is_driver') and partner.is_driver:
                    role = 'driver'
                
                # Obtener código de conductor si existe
                driver_code = ''
                if hasattr(partner, 'driver_code'):
                    driver_code = partner.driver_code or ''
                elif hasattr(partner, 'ref'):
                    driver_code = partner.ref or ''
                
                return {
                    'success': True,
                    'data': {
                        'uid': uid,
                        'session_id': request.session.sid,
                        'username': login,
                        'full_name': user.name or partner.name or login,
                        'role': role,
                        'driver_code': driver_code,
                        'driver_id': partner.id if partner else 0,
                        'driver_name': partner.name if partner else ''
                    }
                }
            else:
                return {
                    'success': False,
                    'message': 'Credenciales inválidas'
                }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/fcm/register', type='json', auth='user', methods=['POST'], csrf=False)
    def register_fcm_token(self, **kwargs):
        """
        Registrar token FCM del dispositivo.
        La app Android llama a esto después del login para recibir push notifications.
        """
        try:
            params = request.jsonrequest
            driver_id = params.get('driver_id')
            token = params.get('token')
            platform = params.get('platform', 'android')
            
            if not driver_id or not token:
                return {'success': False, 'message': 'driver_id y token son requeridos'}
            
            TokenModel = request.env['fcm.device.token'].sudo()
            
            # Buscar si ya existe este token
            existing = TokenModel.search([('token', '=', token)], limit=1)
            if existing:
                # Actualizar driver y reactivar si estaba inactivo
                existing.write({
                    'driver_id': driver_id,
                    'platform': platform,
                    'active': True,
                    'last_used': datetime.now()
                })
            else:
                # Crear nuevo registro
                TokenModel.create({
                    'driver_id': driver_id,
                    'token': token,
                    'platform': platform,
                    'active': True,
                    'last_used': datetime.now()
                })
            
            _logger.info("Token FCM registrado para driver_id=%s", driver_id)
            return {'success': True, 'message': 'Token FCM registrado'}
        except Exception as e:
            _logger.error("Error registrando token FCM: %s", str(e))
            return {'success': False, 'message': str(e)}
    
    @http.route('/api/routes/driver/<string:username>', type='json', auth='user', methods=['GET'])
    def get_routes_by_driver(self, username, **kwargs):
        """Obtener rutas asignadas a un conductor"""
        try:
            # Buscar usuario por username
            user = request.env['res.users'].sudo().search([('login', '=', username)], limit=1)
            if not user:
                return {
                    'success': False,
                    'message': 'Usuario no encontrado'
                }
            
            # Obtener fecha de hoy
            today = date.today()
            
            # Buscar rutas del conductor para hoy
            routes = request.env['mss.route'].sudo().search([
                ('driver_id', '=', user.partner_id.id),
                ('date', '=', today)
            ])
            
            route_list = []
            for route in routes:
                # Obtener líneas de ruta
                lines = []
                for line in route.route_lines:
                    lines.append({
                        'id': line.id,
                        'partner_id': {
                            'id': line.partner_id.id,
                            'name': line.partner_id.name
                        },
                        'street': line.street or '',
                        'city': line.city or '',
                        'latitude': line.latitude or 0.0,
                        'longitude': line.longitude or 0.0,
                        'sequence': line.sequence or 0,
                        'notes': line.notes or '',
                        'state': line.state or 'draft',
                        'scheduled_time': line.scheduled_time or ''
                    })
                
                route_list.append({
                    'id': route.id,
                    'name': route.name,
                    'driver_id': {
                        'id': route.driver_id.id,
                        'name': route.driver_id.name
                    } if route.driver_id else None,
                    'state': route.state,
                    'date': str(route.date),
                    'route_lines': sorted(lines, key=lambda x: x['sequence'])
                })
            
            return {
                'success': True,
                'data': route_list
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/<int:route_id>', type='json', auth='user', methods=['GET'])
    def get_route_details(self, route_id, **kwargs):
        """Obtener detalles de una ruta específica"""
        try:
            route = request.env['mss.route'].sudo().browse(route_id)
            
            if not route.exists():
                return {
                    'success': False,
                    'message': 'Ruta no encontrada'
                }
            
            base_url = request.httprequest.host_url.rstrip('/')
            lines = []
            for line in route.route_lines:
                attachments = []
                if hasattr(line, 'attachment_ids') and line.attachment_ids:
                    for attachment in line.attachment_ids:
                        attachments.append({
                            'id': attachment.id,
                            'name': attachment.name or '',
                            'filename': attachment.name or '',
                            'mimetype': attachment.mimetype or 'application/octet-stream',
                            'file_size': attachment.file_size or 0,
                            'create_date': str(attachment.create_date) if attachment.create_date else '',
                            'download_url': f'{base_url}/api/attachment/{attachment.id}?format=download',
                        })
                
                lines.append({
                    'id': line.id,
                    'partner_id': {
                        'id': line.partner_id.id,
                        'name': line.partner_id.name
                    },
                    'street': line.street or '',
                    'city': line.city or '',
                    'latitude': line.latitude or 0.0,
                    'longitude': line.longitude or 0.0,
                    'sequence': line.sequence or 0,
                    'notes': line.notes or '',
                    'state': line.state or 'draft',
                    'scheduled_time': line.scheduled_time or '',
                    'attachments': attachments,
                })
            
            route_data = {
                'id': route.id,
                'name': route.name,
                'driver_id': {
                    'id': route.driver_id.id,
                    'name': route.driver_id.name
                } if route.driver_id else None,
                'state': route.state,
                'date': str(route.date),
                'route_lines': sorted(lines, key=lambda x: x['sequence'])
            }
            
            return {
                'success': True,
                'data': route_data
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/line/start', type='json', auth='user', methods=['POST'], csrf=False)
    def start_route_line(self, **kwargs):
        """Iniciar una línea de ruta"""
        try:
            params = request.jsonrequest
            line_id = params.get('line_id')
            latitude = params.get('latitude')
            longitude = params.get('longitude')
            timestamp = params.get('timestamp')
            
            line = request.env['mss.route.line'].sudo().browse(line_id)
            
            if not line.exists():
                return {
                    'success': False,
                    'message': 'Línea de ruta no encontrada'
                }
            
            values = {
                'state': 'in_progress',
                'start_time': timestamp or datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            
            if latitude and longitude:
                values.update({
                    'start_latitude': latitude,
                    'start_longitude': longitude
                })
            
            line.write(values)
            
            return {
                'success': True,
                'message': 'Ruta iniciada correctamente'
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/line/complete', type='json', auth='user', methods=['POST'], csrf=False)
    def complete_route_line(self, **kwargs):
        """Completar una línea de ruta"""
        try:
            params = request.jsonrequest
            line_id = params.get('line_id')
            latitude = params.get('latitude')
            longitude = params.get('longitude')
            timestamp = params.get('timestamp')
            
            line = request.env['mss.route.line'].sudo().browse(line_id)
            
            if not line.exists():
                return {
                    'success': False,
                    'message': 'Línea de ruta no encontrada'
                }
            
            values = {
                'state': 'done',
                'end_time': timestamp or datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            
            if latitude and longitude:
                values.update({
                    'end_latitude': latitude,
                    'end_longitude': longitude
                })
            
            line.write(values)
            
            # Verificar si todas las líneas están completadas para actualizar la ruta
            route = line.route_id
            all_done = all(l.state == 'done' for l in route.route_lines)
            if all_done:
                route.write({'state': 'done'})
            
            return {
                'success': True,
                'message': 'Ruta completada correctamente'
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/<int:route_id>/state', type='json', auth='user', methods=['PUT'], csrf=False)
    def update_route_state(self, route_id, **kwargs):
        """Actualizar estado de una ruta completa"""
        try:
            params = request.jsonrequest
            state = params.get('state')
            
            route = request.env['mss.route'].sudo().browse(route_id)
            
            if not route.exists():
                return {
                    'success': False,
                    'message': 'Ruta no encontrada'
                }
            
            route.write({'state': state})
            
            return {
                'success': True,
                'message': 'Estado actualizado correctamente'
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/check-new', type='json', auth='user', methods=['GET'])
    def check_new_routes(self, **kwargs):
        """
        Endpoint ligero para verificar si hay rutas nuevas asignadas desde un timestamp.
        La app usa este endpoint desde el Worker de notificaciones (polling cada 15 min).
        
        Query params:
            - driver: ID del conductor (res.partner)
            - since: timestamp ISO 'YYYY-MM-DD HH:MM:SS' (última verificación)
        
        Retorna:
            - has_new: bool
            - new_count: int (rutas nuevas desde 'since')
            - total_pending: int (rutas pendientes totales hoy)
            - route_names: list[str] (nombres de las rutas nuevas)
        """
        try:
            driver = request.params.get('driver')
            since = request.params.get('since')
            today = date.today()
            
            domain = [('date', '=', today)]
            if driver:
                try:
                    driver_id = int(driver)
                    domain.append(('driver_id', '=', driver_id))
                except ValueError:
                    user = request.env['res.users'].sudo().search([('login', '=', driver)], limit=1)
                    if user:
                        domain.append(('driver_id', '=', user.partner_id.id))
            
            routes = request.env['mss.route'].sudo().search(domain)
            
            total_pending = 0
            new_routes = []
            
            for route in routes:
                if route.state not in ('finished', 'cancelled', 'done'):
                    total_pending += 1
                
                # Si hay timestamp 'since', filtrar rutas creadas/asignadas después
                if since:
                    try:
                        since_dt = datetime.strptime(since, '%Y-%m-%d %H:%M:%S')
                        # Verificar write_date (momento de asignación) o create_date
                        route_dt = route.write_date or route.create_date
                        if route_dt and route_dt > since_dt:
                            new_routes.append(route.name)
                    except (ValueError, TypeError):
                        pass
                else:
                    # Sin 'since', todas las pendientes se consideran nuevas
                    if route.state not in ('finished', 'cancelled', 'done'):
                        new_routes.append(route.name)
            
            return {
                'success': True,
                'data': {
                    'has_new': len(new_routes) > 0,
                    'new_count': len(new_routes),
                    'total_pending': total_pending,
                    'route_names': new_routes[:10],  # Máximo 10 nombres
                    'checked_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                }
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/history', type='json', auth='user', methods=['GET'])
    def get_routes_history(self, **kwargs):
        """
        Obtener historial de rutas completadas de un conductor.
        
        Query params:
            - driver: ID del conductor (res.partner) o username
            - limit: cantidad de resultados (default 20)
            - offset: paginación (default 0)
        """
        try:
            driver = request.params.get('driver')
            limit = int(request.params.get('limit', 20))
            offset = int(request.params.get('offset', 0))
            
            domain = [('state', 'in', ['done', 'finished'])]
            if driver:
                try:
                    driver_id = int(driver)
                    domain.append(('driver_id', '=', driver_id))
                except ValueError:
                    user = request.env['res.users'].sudo().search([('login', '=', driver)], limit=1)
                    if user:
                        domain.append(('driver_id', '=', user.partner_id.id))
            
            total = request.env['mss.route'].sudo().search_count(domain)
            routes = request.env['mss.route'].sudo().search(
                domain, limit=limit, offset=offset, order='date desc'
            )
            
            history_list = []
            for route in routes:
                total_deliveries = len(route.route_lines)
                completed_deliveries = len([l for l in route.route_lines if l.state == 'done'])
                
                # Calcular duración
                duration_minutes = 0.0
                duration_formatted = '--'
                if route.start_date and route.end_date:
                    try:
                        start_dt = route.start_date if isinstance(route.start_date, datetime) else datetime.strptime(str(route.start_date), '%Y-%m-%d %H:%M:%S')
                        end_dt = route.end_date if isinstance(route.end_date, datetime) else datetime.strptime(str(route.end_date), '%Y-%m-%d %H:%M:%S')
                        diff = (end_dt - start_dt).total_seconds() / 60
                        if diff > 0:
                            duration_minutes = round(diff, 1)
                            hours = int(diff // 60)
                            mins = int(diff % 60)
                            duration_formatted = f"{hours}h {mins}m" if hours > 0 else f"{mins}m"
                    except Exception:
                        pass
                
                history_list.append({
                    'id': route.id,
                    'name': route.name,
                    'date': str(route.date),
                    'start_date': str(route.start_date) if route.start_date else None,
                    'end_date': str(route.end_date) if route.end_date else None,
                    'duration_minutes': duration_minutes,
                    'duration_formatted': duration_formatted,
                    'total_deliveries': total_deliveries,
                    'completed_deliveries': completed_deliveries,
                })
            
            return {
                'success': True,
                'data': history_list,
                'pagination': {
                    'total': total,
                    'limit': limit,
                    'offset': offset,
                    'has_more': (offset + limit) < total
                }
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
            
    @http.route('/api/driver/stats', type='json', auth='user', methods=['GET'])
    def get_driver_stats(self, **kwargs):
        """
        Obtener estadísticas del conductor.
        
        Query params:
            - driver: ID del conductor (res.partner) o username
            - period: 'today', 'week', 'month', 'all' (default 'today')
        """
        try:
            driver = request.params.get('driver')
            period = request.params.get('period', 'today')
            
            partner = None
            if driver:
                try:
                    partner_id = int(driver)
                    partner = request.env['res.partner'].sudo().browse(partner_id)
                except ValueError:
                    user = request.env['res.users'].sudo().search([('login', '=', driver)], limit=1)
                    if user:
                        partner = user.partner_id
            
            if not partner or not partner.exists():
                return {'success': False, 'message': 'Conductor no encontrado'}
            
            # Determinar rango de fechas
            today = date.today()
            if period == 'today':
                date_from = today
                date_to = today
            elif period == 'week':
                date_from = today - datetime.timedelta(days=today.weekday())
                date_to = today
            elif period == 'month':
                date_from = today.replace(day=1)
                date_to = today
            else:
                date_from = None
                date_to = None
            
            domain = [('driver_id', '=', partner.id)]
            if date_from and date_to:
                domain += [('date', '>=', date_from), ('date', '<=', date_to)]
            
            routes = request.env['mss.route'].sudo().search(domain)
            
            total_routes = len(routes)
            completed_routes = len([r for r in routes if r.state in ('done', 'finished')])
            in_progress_routes = len([r for r in routes if r.state == 'started'])
            pending_routes = total_routes - completed_routes - in_progress_routes
            
            total_deliveries = 0
            completed_deliveries = 0
            in_progress_deliveries = 0
            pending_deliveries = 0
            total_delivery_time = 0
            deliveries_with_time = 0
            total_route_time = 0
            routes_with_time = 0
            
            today_total = 0
            today_completed = 0
            today_in_progress = 0
            today_pending = 0
            
            for route in routes:
                for line in route.route_lines:
                    total_deliveries += 1
                    if line.state == 'done':
                        completed_deliveries += 1
                    elif line.state == 'in_progress':
                        in_progress_deliveries += 1
                    else:
                        pending_deliveries += 1
                    
                    if str(route.date) == str(today):
                        today_total += 1
                        if line.state == 'done':
                            today_completed += 1
                        elif line.state == 'in_progress':
                            today_in_progress += 1
                        else:
                            today_pending += 1
            
            completion_rate = (completed_deliveries / total_deliveries * 100) if total_deliveries > 0 else 0
            avg_delivery = total_delivery_time / deliveries_with_time if deliveries_with_time > 0 else 0
            avg_route = total_route_time / routes_with_time if routes_with_time > 0 else 0
            
            # Imagen del conductor
            driver_image = None
            if partner.image_128:
                driver_image = partner.image_128.decode('utf-8') if isinstance(partner.image_128, bytes) else partner.image_128
            
            return {
                'success': True,
                'data': {
                    'driver': {
                        'id': partner.id,
                        'name': partner.name,
                        'image': driver_image
                    },
                    'period': period,
                    'summary': {
                        'total_routes': total_routes,
                        'completed_routes': completed_routes,
                        'in_progress_routes': in_progress_routes,
                        'pending_routes': pending_routes,
                        'total_deliveries': total_deliveries,
                        'completed_deliveries': completed_deliveries,
                        'pending_deliveries': pending_deliveries,
                        'in_progress_deliveries': in_progress_deliveries,
                        'completion_rate': round(completion_rate, 1)
                    },
                    'performance': {
                        'avg_delivery_time_minutes': round(avg_delivery, 1),
                        'avg_route_time_minutes': round(avg_route, 1),
                        'avg_delivery_time_formatted': f"{int(avg_delivery)}m" if avg_delivery > 0 else "--",
                        'avg_route_time_formatted': f"{int(avg_route)}m" if avg_route > 0 else "--"
                    },
                    'today': {
                        'total': today_total,
                        'completed': today_completed,
                        'pending': today_pending,
                        'in_progress': today_in_progress
                    }
                }
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }
    
    @http.route('/api/routes/sync', type='json', auth='user', methods=['GET'])
    def sync_today_routes(self, **kwargs):
        """Sincronizar todas las rutas del día"""
        try:
            driver = request.params.get('driver')
            today = date.today()
            
            domain = [('date', '=', today)]
            if driver:
                user = request.env['res.users'].sudo().search([('login', '=', driver)], limit=1)
                if user:
                    domain.append(('driver_id', '=', user.partner_id.id))
            
            routes = request.env['mss.route'].sudo().search(domain)
            
            route_list = []
            for route in routes:
                lines = []
                for line in route.route_lines:
                    # Obtener archivos adjuntos si existen en tu modelo
                    base_url = request.httprequest.host_url.rstrip('/')
                    attachments = []
                    if hasattr(line, 'attachment_ids') and line.attachment_ids:
                        for attachment in line.attachment_ids:
                            attachments.append({
                                'id': attachment.id,
                                'name': attachment.name or '',
                                'filename': attachment.name or '',
                                'mimetype': attachment.mimetype or 'application/octet-stream',
                                'file_size': attachment.file_size or 0,
                                'create_date': str(attachment.create_date) if attachment.create_date else '',
                                'download_url': f'{base_url}/api/attachment/{attachment.id}?format=download',
                            })
                    
                    lines.append({
                        'id': line.id,
                        'partner_id': {
                            'id': line.partner_id.id,
                            'name': line.partner_id.name
                        },
                        'street': line.street or '',
                        'city': line.city or '',
                        'latitude': line.latitude or 0.0,
                        'longitude': line.longitude or 0.0,
                        'sequence': line.sequence or 0,
                        'notes': line.notes or '',
                        'state': line.state or 'draft',
                        'scheduled_time': line.scheduled_time or '',
                        'attachments': attachments,
                    })
                
                route_list.append({
                    'id': route.id,
                    'name': route.name,
                    'driver_id': {
                        'id': route.driver_id.id,
                        'name': route.driver_id.name
                    } if route.driver_id else None,
                    'state': route.state,
                    'date': str(route.date),
                    'route_lines': sorted(lines, key=lambda x: x['sequence'])
                })
            
            return {
                'success': True,
                'data': route_list
            }
        except Exception as e:
            return {
                'success': False,
                'message': str(e)
            }

    @http.route('/api/attachment/<int:attachment_id>', type='http', auth='public', methods=['GET'], csrf=False)
    def get_attachment(self, attachment_id, **kwargs):
        """
        Obtener un archivo adjunto por su ID.
        Retorna el archivo como descarga o como base64 según el parámetro 'format'.
        """
        try:
            output_format = kwargs.get('format', 'base64')
            attachment = request.env['ir.attachment'].sudo().browse(attachment_id)
            
            if not attachment.exists():
                response_data = {'success': False, 'message': 'Archivo adjunto no encontrado'}
                return request.make_response(json.dumps(response_data), headers=[('Content-Type', 'application/json')])
            
            if output_format == 'download':
                file_content = base64.b64decode(attachment.datas) if attachment.datas else b''
                headers = [
                    ('Content-Type', attachment.mimetype or 'application/octet-stream'),
                    ('Content-Disposition', f'attachment; filename="{attachment.name}"'),
                    ('Content-Length', len(file_content))
                ]
                return request.make_response(file_content, headers=headers)
            else:
                response_data = {
                    'success': True,
                    'data': {
                        'id': attachment.id,
                        'name': attachment.name or '',
                        'filename': attachment.name or '',
                        'mimetype': attachment.mimetype or 'application/octet-stream',
                        'file_size': attachment.file_size or 0,
                        'datas': attachment.datas.decode('utf-8') if attachment.datas else '',
                        'create_date': str(attachment.create_date) if attachment.create_date else '',
                    }
                }
                return request.make_response(json.dumps(response_data), headers=[('Content-Type', 'application/json')])
        except Exception as e:
            return request.make_response(json.dumps({'success': False, 'message': str(e)}), headers=[('Content-Type', 'application/json')])

    @http.route([
        '/api/routes/line/<int:line_id>/attachments',
        '/api/routes/line/attachments/<int:line_id>'
    ], type='http', auth='public', methods=['GET'], csrf=False)
    def get_line_attachments(self, line_id, **kwargs):
        """
        Obtener todos los archivos adjuntos de una línea de ruta.
        """
        try:
            line = request.env['mss.route.line'].sudo().browse(line_id)
            if not line.exists():
                response_data = {'success': False, 'message': 'Línea de ruta no encontrada'}
                return request.make_response(json.dumps(response_data), headers=[('Content-Type', 'application/json')])
            
            base_url = request.httprequest.host_url.rstrip('/')
            attachments = []
            if hasattr(line, 'attachment_ids') and line.attachment_ids:
                for attachment in line.attachment_ids:
                    attachments.append({
                        'id': attachment.id,
                        'name': attachment.name or '',
                        'filename': attachment.name or '',
                        'mimetype': attachment.mimetype or 'application/octet-stream',
                        'file_size': attachment.file_size or 0,
                        'create_date': str(attachment.create_date) if attachment.create_date else '',
                        'download_url': f'{base_url}/api/attachment/{attachment.id}?format=download',
                    })
            
            response_data = {
                'success': True,
                'data': {
                    'line_id': line_id,
                    'attachments': attachments,
                    'count': len(attachments)
                }
            }
            return request.make_response(json.dumps(response_data), headers=[('Content-Type', 'application/json')])
        except Exception as e:
            return request.make_response(json.dumps({'success': False, 'message': str(e)}), headers=[('Content-Type', 'application/json')])
