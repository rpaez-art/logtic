# Integración Odoo - App Logística

## Configuración en Odoo

### 1. Agregar el Controller

Copia el archivo `ODOO_CONTROLLER_EXAMPLE.py` a tu módulo de Odoo:
```
addons/mss_route_optimization/controllers/api.py
```

### 2. Actualizar __init__.py

En `addons/mss_route_optimization/controllers/__init__.py`:
```python
from . import api
```

### 3. Campos necesarios en el modelo mss.route.line

Asegúrate de que el modelo `mss.route.line` tenga estos campos:

```python
class MssRouteLine(models.Model):
    _name = 'mss.route.line'
    
    # Campos existentes
    partner_id = fields.Many2one('res.partner', 'Cliente')
    street = fields.Char('Dirección')
    city = fields.Char('Ciudad')
    latitude = fields.Float('Latitud', digits=(10, 7))
    longitude = fields.Float('Longitud', digits=(10, 7))
    sequence = fields.Integer('Secuencia')
    notes = fields.Text('Notas')
    state = fields.Selection([
        ('draft', 'Borrador'),
        ('in_progress', 'En Progreso'),
        ('done', 'Completado')
    ], default='draft')
    
    # Campos nuevos (agregar si no existen)
    scheduled_time = fields.Char('Hora Programada')
    start_time = fields.Datetime('Hora de Inicio')
    end_time = fields.Datetime('Hora de Finalización')
    start_latitude = fields.Float('Latitud Inicio', digits=(10, 7))
    start_longitude = fields.Float('Longitud Inicio', digits=(10, 7))
    end_latitude = fields.Float('Latitud Fin', digits=(10, 7))
    end_longitude = fields.Float('Longitud Fin', digits=(10, 7))
    route_id = fields.Many2one('mss.route', 'Ruta')
```

### 4. Endpoints Disponibles

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/auth/login` | POST | Autenticación de usuario |
| `/api/routes/driver/{username}` | GET | Rutas por conductor |
| `/api/routes/{route_id}` | GET | Detalle de ruta |
| `/api/routes/line/start` | POST | Iniciar línea de ruta |
| `/api/routes/line/pickup` | POST | Marcar línea como recogida |
| `/api/routes/line/complete` | POST | Completar línea de ruta |
| `/api/routes/line/upload-image` | POST | Subir imagen de entrega |
| `/api/routes/{route_id}/state` | PUT | Actualizar estado de ruta |
| `/api/routes/sync` | GET | Sincronizar rutas del día |
| `/api/routes/check-new` | GET | **NUEVO** - Verificar rutas nuevas (notificaciones) |
| `/api/routes/history` | GET | **NUEVO** - Historial de rutas completadas |
| `/api/driver/stats` | GET | **NUEVO** - Estadísticas del conductor |
| `/api/routes/line/{line_id}/attachments` | GET | Adjuntos de una línea |
| `/api/attachment/{attachment_id}` | GET | Descargar adjunto |

### 5. Endpoint de Notificaciones: `/api/routes/check-new`

Este endpoint es **ligero** y está diseñado para ser llamado frecuentemente desde el Worker de Android (cada 15 min).

**Parámetros:**
- `driver` (int): ID del conductor (res.partner)
- `since` (string, opcional): Timestamp ISO `YYYY-MM-DD HH:MM:SS` de última verificación

**Respuesta:**
```json
{
    "success": true,
    "data": {
        "has_new": true,
        "new_count": 2,
        "total_pending": 3,
        "route_names": ["RUTA-001", "RUTA-002"],
        "checked_at": "2026-03-20 14:30:00"
    }
}
```

### 6. Endpoint de Historial: `/api/routes/history`

**Parámetros:**
- `driver` (int/string): ID del conductor o username
- `limit` (int): Cantidad de resultados (default 20)
- `offset` (int): Paginación (default 0)

**Respuesta:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "RUTA-001",
            "date": "2026-03-18",
            "start_date": "2026-03-18 08:00:00",
            "end_date": "2026-03-18 16:30:00",
            "duration_minutes": 510.0,
            "duration_formatted": "8h 30m",
            "total_deliveries": 12,
            "completed_deliveries": 12
        }
    ],
    "pagination": {
        "total": 45,
        "limit": 20,
        "offset": 0,
        "has_more": true
    }
}
```

## Configuración en la App

1. **Login como Admin**
2. **Ir a Configuración Odoo** (ícono ⚙️)
3. **Configurar**:
   - URL Base: `https://tu-servidor.com/`
   - Base de Datos: `nombre_bd`
   - Usuario: `admin`
   - Contraseña: `***`
4. **Guardar** (se prueba la conexión automáticamente)

## Uso

### Para Conductores:
1. Login con sus credenciales
2. Las rutas se cargan automáticamente desde Odoo
3. Presionar "Iniciar Ruta" → Se actualiza en Odoo
4. Presionar "Completar" → Se registra ubicación final en Odoo

### Para Administrador:
1. Ver monitor de choferes
2. Ver todas las rutas en tiempo real
3. Ver ubicaciones finales de entregas

## Sincronización Bidireccional

✅ **App → Odoo:**
- Inicio de ruta (estado, hora, GPS)
- Finalización de ruta (estado, hora, GPS)

✅ **Odoo → App:**
- Rutas asignadas del día
- Clientes y direcciones
- Coordenadas GPS
- Secuencia de entregas
- Estado actual

## Seguridad

- Autenticación requerida
- CSRF deshabilitado para endpoints JSON
- Usuarios sudo para operaciones
- Logs de errores en Odoo

## Testing

Puedes probar los endpoints con curl o Postman:

```bash
# Login
curl -X POST https://tu-servidor.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"db":"nombre_bd","login":"admin","password":"***"}'

# Obtener rutas
curl https://tu-servidor.com/api/routes/driver/driver1 \
  -H "Cookie: session_id=XXXXXXX"
```
