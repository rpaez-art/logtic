# 🗺️ Mapa del Sistema de Notificaciones — LogTic

> **Generado**: 2026-08-18
> **Alcance**: App Flutter (`appLogTic/`) + Backend Odoo (solo lectura, no se modifica)
> **Proyecto Firebase**: `logtic` (# `694502319973`) · **Package**: `com.corpocrea.logistica`

---

## 1. Vista General (Arquitectura)

```
┌────────────────────────────────────────────────────────────────────────┐
│                     BACKEND — Odoo (SIN MODIFICAR)                     │
│                     ODOO_CONTROLLER_EXAMPLE.py                         │
│                                                                        │
│  Modelo fcm.device.token                                               │
│   ├─ driver_id (Many2one → res.partner)                                │
│   ├─ token (Char, UNIQUE)                                              │
│   ├─ platform ('android' | 'ios')                                      │
│   └─ active (Bool)                                                     │
│                                                                        │
│  MssRouteWithFcm.write()  ── detecta asignación/cambio de driver       │
│   └─ send_fcm_notification(driver_id, data_payload)                    │
│        ├─ Busca tokens activos del driver                              │
│        ├─ Envía DATA message (no notification message)                 │
│        └─ UnregisteredError → desactiva token (active=False)           │
│                                                                        │
│  POST /api/fcm/register  ── registra/actualiza token del dispositivo   │
│  GET  /api/routes/check-new ── polling ligero (fallback del push)      │
└────────────────────────────────┬───────────────────────────────────────┘
                                 │  firebase-admin SDK
                                 ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   FIREBASE CLOUD MESSAGING (proyecto logtic)           │
└───────┬──────────────────────────┬──────────────────────────┬──────────┘
        │ FOREGROUND               │ BACKGROUND               │ TERMINATED
        ▼                          ▼                          ▼
┌────────────────┐   ┌──────────────────────────┐   ┌──────────────────────┐
│ onMessage       │  │ onBackgroundMessage      │   │ getInitialMessage()  │
│ (app abierta)   │  │ _firebaseMessagingBack-  │   │ (app abre desde      │
│                 │  │  groundHandler (top-lvl, │   │  notif. del sistema) │
│                 │  │  @pragma vm:entry-point) │   │                      │
└───────┬────────┘  └────────────┬─────────────┘   └──────────┬───────────┘
        │                        │                            │
        ▼                        ▼                            ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        APP FLUTTER — lib/main.dart                     │
│                                                                        │
│  FOREGROUND: _showForegroundNotification()                             │
│   1. Notificación local del sistema (LocalNotificationService)         │
│   2. Badge++ (NotificationBadgeProvider, persistido)                   │
│   3. Banner in-app (NotificationBanner / SnackBar flotante)            │
│                                                                        │
│  BACKGROUND: handler aislado                                           │
│   1. Firebase.initializeApp + LocalNotificationService.init            │
│   2. Notificación local del sistema                                    │
│   3. Guarda 'pending_route' en SharedPreferences (si route/route_ids)  │
│                                                                        │
│  TERMINATED / TAP: _initDeepLinks() → _handleDeepLink(data)            │
│   ├─ getInitialMessage() → deep link directo                           │
│   ├─ onMessageOpenedApp → deep link                                    │
│   ├─ _checkPendingRoute() → recupera pending_route de prefs            │
│   └─ LocalNotificationService.onNotificationTap → deep link            │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Inventario de Componentes

### 📱 App Flutter

| Componente | Archivo | Responsabilidad |
|---|---|---|
| **Orquestador FCM** | `lib/main.dart` | Inicializa Firebase, registra handlers (fore/back/terminated), deep links, banner, badge |
| **Notificaciones locales** | `lib/services/local_notification_service.dart` | Singleton. Muestra pushes como notificaciones del sistema; canal Android; tap → callback |
| **Badge provider** | `lib/providers/notification_badge_provider.dart` | Contador de no leídas, persistido en SharedPreferences (`unread_badge_count`) |
| **Banner in-app** | `lib/widgets/notification_banner.dart` | SnackBar flotante con gradiente, ícono de campana, tap → deep link |
| **Sync periódico** | `lib/services/background_sync_service.dart` | Timer cada 5 min → `checkNewRoutes` → sync + badge++ (fallback del push) |
| **Registro de token** | `lib/providers/auth_provider.dart` | `_registerFcmToken()` tras login/restore; `listenTokenRefresh()` ante rotación |
| **Check de rutas nuevas** | `lib/providers/odoo_provider.dart` | `checkNewRoutes(driverId)` → endpoint ligero |
| **Cliente API** | `lib/services/api/retrofit_client.dart` | `registerFcmToken()` → `POST api/fcm/register`; `checkNewRoutes()` → `api/routes/check-new` |
| **Config Firebase** | `lib/firebase_options.dart` | `DefaultFirebaseOptions.currentPlatform` (credenciales por plataforma) |
| **UI del badge** | `lib/screens/shell_screen.dart` | `BadgeWrapper` en BottomNav / NavigationRail / Drawer sobre el ícono de Rutas |
| **Constantes** | `lib/config/app_config.dart` | Endpoints `apiFcmRegister`, `apiRoutesCheckNew`; prefs `prefsFcmToken`, `prefsFcmTokenSent` |

### ⚙️ Backend Odoo (referencia, NO modificar)

| Elemento | Detalle |
|---|---|
| `fcm.device.token` | Modelo: driver_id, token (UNIQUE), platform, active |
| `MssRouteWithFcm.write()` | Hook que detecta asignación de driver y dispara el push |
| `send_fcm_notification()` | firebase-admin; envía **data message**; desactiva tokens inválidos |
| `POST /api/fcm/register` | `auth='user'`; registra/actualiza token por driver |
| `FCM_CREDENTIALS_PATH` | `/etc/odoo/firebase-service-account.json` (⚠️ debe ser del proyecto `logtic`) |

---

## 3. Contrato del Payload (data message)

El backend envía **data messages** (no `notification`), por lo que la app renderiza todo manualmente:

| Clave | Tipo | Descripción |
|---|---|---|
| `type` | string | Ej. `route_assigned` |
| `route_count` | string | Nº de rutas asignadas → genera body: *"Te han asignado X nueva(s) ruta(s)."* |
| `route_ids` | string | IDs separados por coma, ej. `"12,15"` → la app construye `/routes/{firstId}` |
| `route_name` | string | Nombre de la ruta (solo si es 1) |
| `route_date` | string | Fecha de la ruta |
| `title` / `body` | string | Opcionales; la app usa defaults si faltan |

> ⚠️ **Nota**: el backend **no** envía `route`. El deep link se construye en `_handleDeepLink()` navegando
> siempre a `/routes` (tab de Rutas del día) cuando llegan `route_ids` o `type`. El payload completo se
> preserva en la notificación local para que el tap también funcione correctamente.

---

## 4. Flujos por Estado de la App

### 🟢 Foreground (`onMessage` → `_showForegroundNotification`)
1. Extrae `title`/`body` (de `notification` o `data`; aplica `route_count`).
2. Muestra **notificación local del sistema** (`showFcmNotification`, ID = FNV-1a del `messageId`; payload = `data` completo incluido `route_ids`).
3. **Badge++** vía `rootNavigatorKey.currentContext`.
4. Muestra **banner in-app** (SnackBar, 5 s). Tap → `markOneAsRead()` + `_handleDeepLink()`. El tap se activa si el mensaje contiene `route` **o** `route_ids`.

### 🟡 Background (`_firebaseMessagingBackgroundHandler`, isolate)
1. Inicializa Firebase + `LocalNotificationService` (aislado del isolate principal).
2. Muestra notificación local del sistema.
3. Si hay `route` o `route_ids` → guarda `pending_route` (JSON) en SharedPreferences.

### 🔴 Terminated
- **Tap en notificación FCM**: `getInitialMessage()` → `_handleDeepLink()`.
- **Tap en notificación local**: `onNotificationTap` → payload JSON → `_handleDeepLink()`.
- **Fallback**: `_checkPendingRoute()` lee y borra `pending_route`.

### 🧭 Resolución de Deep Link (`_handleDeepLink`)
```
data['route']  ──null──▶  ¿'route_ids' o 'type' presentes?  ──sí──▶  '/routes'
        │                                                     ──no──▶  return (ignorar)
        ▼
 ¿isLoggedIn? ──no──▶ authProvider.setPendingDeepLink(route)  (post-login, consumido en _onAuthChange)
        │ sí
        ▼
   _router.go(route)
```

---

## 5. Ciclo de Vida del Token FCM

```
Login / RestoreSession
        │
        ▼
_registerFcmToken(driverId, username)
  ├─ messaging.getToken()
  ├─ prefs[fcm_token] = token
  ├─ prefs[fcm_token_sent] = false
  ├─ POST /api/fcm/register  {driver_id, token, platform: Platform.isIOS?'ios':'android'}
  └─ éxito → prefs[fcm_token_sent] = true
        │
Rotación ▼
listenTokenRefresh()  (en _LogticAppState.initState)
  └─ onTokenRefresh → guarda nuevo token + marca sent=false + re-registra si hay sesión
```

> ⚠️ **Logout no desregistra el token** (requeriría endpoint en Odoo — fuera de alcance).

---

## 6. Sistema de Badge (no leídas)

| Acción | Dónde | Efecto |
|---|---|---|
| `increment()` | Foreground push (`main.dart`) y sync con rutas nuevas | +1, persiste |
| `markOneAsRead()` | Tap en banner in-app | −1, persiste |
| `markAllAsRead()` | Navegar a tab Rutas / `onNavigateToRoutes` en `shell_screen.dart` | 0, persiste |
| `load()` | Al iniciar app (en `addPostFrameCallback` de `_LogticAppState.initState`) | Restaura `unread_badge_count` |
| Render | `BadgeWrapper` en BottomNav / Rail / Drawer (ícono Rutas) | Muestra contador |

---

## 7. Polling de Respaldo (sin push)

```
BackgroundSyncService (cada 5 min, sin solapar ticks)
  └─ getDriverId() == null → stop()
  └─ onSync(driverId, since):
       1. odooProvider.checkNewRoutes(driverId, since: since)  → GET api/routes/check-new?since=…
       2. si hay nuevas → syncRoutesFromOdoo(silent: true)
       3. routeProvider.setRoutesFromOdoo(routes)
       4. badgeProvider.increment()
       5. _lastSyncedAt = DateTime.now()  (para el próximo tick)
```

> ⚠️ **reset()**: Al detectar login en `_onAuthChange`, se llama `_bgSync.reset()` para reiniciar el
> servicio. Sin esto, el servicio permanecía muerto si el primer tick ocurría en la pantalla de login.

---

## 8. Configuración de Plataforma

| Archivo | Contenido clave |
|---|---|
| `android/app/google-services.json` | Credenciales proyecto `logtic` |
| `lib/firebase_options.dart` | Opciones multiplataforma |
| `android/app/build.gradle.kts` | `applicationId = com.corpocrea.logistica` |
| `AndroidManifest.xml` | Permiso `POST_NOTIFICATIONS`; `launchMode="singleTop"` |
| Canal Android | `logtic_push_channel` — "Notificaciones LogTic", importance **high**, sonido + vibración |
| Ícono notif. | `@drawable/ic_launcher` |
| Permisos runtime | `messaging.requestPermission()` en `main()` |

**Dependencias**: `firebase_core ^4.12.1`, `firebase_messaging ^16.4.3`, `flutter_local_notifications ^22.1.0`, `shared_preferences ^2.3.3`.

**SharedPreferences usadas**: `fcm_token`, `fcm_token_sent`, `pending_route`, `unread_badge_count`.

---

## 9. IDs de Notificación

`LocalNotificationService.generateId()` usa **hash FNV-1a (32-bit)** sobre el `messageId` de FCM → ID **estable** entre reinicios (evita el `hashCode` de Dart, que varía por ejecución). Fallback: timestamp si no hay `messageId`.

---

## 10. Pendientes y Limitaciones Conocidas

- [x] **Backend**: verificar que `firebase-service-account.json` corresponda al proyecto `logtic` (nuevo).
- [ ] **iOS**: falta `GoogleService-Info.plist` y completar el directorio `ios/`.
- [ ] **Prueba E2E**: login → registro token → asignar ruta en Odoo → push → deep link.
- ✅ ~~Doble aviso en foreground~~: Comportamiento por diseño, documentado.
- ⚠️ **Logout** no desregistra el token FCM (bloqueado por restricción de no modificar Odoo).
- ✅ ~~Deep link usa solo el primer ID~~ — corregido: ahora navega a `/routes` (lista completa del día).
- ⚠️ `fcm_token_sent` se escribe pero el re-registro es intencional en cada sesión.
- ✅ ~~Banner in-app no clickeable con route_ids~~ — corregido.
- ✅ ~~Badge no carga al reiniciar~~ — corregido: `load()` se llama en `initState`.
- ✅ ~~Polling infinito del badge~~ — corregido: se pasa `since` al endpoint.
- ✅ ~~BackgroundSyncService muere tras login manual~~ — corregido: `reset()` en `_onAuthChange`.
- ✅ ~~pendingDeepLink nunca consumido~~ — corregido: se consume en `_onAuthChange`.
- ✅ ~~Ícono `@drawable/app_icon` inexistente~~ — corregido: `@drawable/ic_launcher`.
- ✅ ~~Backend: `request.env` falla fuera de HTTP~~ — corregido: `env` como parámetro explícito.
- ✅ ~~TTL de 5 min demasiado corto~~ — corregido: 24 horas.
