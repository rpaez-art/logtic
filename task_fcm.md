# 📱 Task FCM — Sistema de Notificaciones Firebase (LogTic)

> **Fecha**: 2026-08-06
> **Estado**: ✅ 8/8 Mejoras aplicadas (solo en app Flutter)
> **Proyecto Firebase**: `logtic` (nuevo)
> **Package Name**: `com.corpocrea.logistica`
> **⚠️ Restricción**: No se modifica nada en Odoo

---

## ✅ Checklist de Mejoras Aplicadas

- [x] **Mejora 1**: Implementar `onTokenRefresh` → `AuthProvider.listenTokenRefresh()`
- [x] **Mejora 2**: Manejar `route_ids` del backend en `_handleDeepLink()` (sin modificar Odoo)
- [x] **Mejora 3**: Usar `checkNewRoutes` en polling → `OdooProvider.checkNewRoutes()` + `main.dart`
- [x] **Mejora 4**: ~~Desregistrar token en logout~~ → ⚠️ **No aplicable** (Odoo no se modifica)
- [x] **Mejora 5**: Persistir badge → `NotificationBadgeProvider` con `SharedPreferences`
- [x] **Mejora 6**: Crear `firebase_options.dart` → credenciales del nuevo proyecto Firebase
- [x] **Mejora 7**: Unificar `route_count` en foreground → `_showForegroundNotification()`
- [x] **Mejora 8**: ID de notificación estable → hash FNV-1a en `LocalNotificationService.generateId()`

### ✅ Credenciales Firebase Actualizadas

| Campo | Valor |
|---|---|
| **project_number** | `694502319973` |
| **project_id** | `logtic` |
| **mobilesdk_app_id** | `1:694502319973:android:e369fcb0bc9972231d238c` |
| **package_name** | `com.corpocrea.logistica` |
| **api_key** | `AIzaSyA9ZsEzw1ViKnZs_-2irlcfw44dyG29EpQ` |
| **storage_bucket** | `logtic.firebasestorage.app` |

### ✅ Archivos Modificados (solo app Flutter)

| Archivo | Cambio |
|---|---|
| `appLogTic/android/app/google-services.json` | Nuevas credenciales Firebase |
| `appLogTic/android/app/build.gradle.kts` | `namespace` y `applicationId` → `com.corpocrea.logistica` |
| `appLogTic/android/app/src/main/kotlin/com/corpocrea/logistica/MainActivity.kt` | Nuevo package |
| `appLogTic/lib/firebase_options.dart` | **NUEVO** — Opciones Firebase por plataforma |
| `appLogTic/lib/main.dart` | `firebase_options`, `listenTokenRefresh()`, `checkNewRoutes` en polling, `route_count` en foreground, manejo de `route_ids` |
| `appLogTic/lib/providers/auth_provider.dart` | `listenTokenRefresh()`, plataforma dinámica |
| `appLogTic/lib/providers/odoo_provider.dart` | `checkNewRoutes()` |
| `appLogTic/lib/providers/notification_badge_provider.dart` | Persistencia del badge |
| `appLogTic/lib/services/local_notification_service.dart` | Hash FNV-1a para IDs |

### ⚠️ Archivos NO modificados (restricción Odoo)

| Archivo | Motivo |
|---|---|
| `ODOO_CONTROLLER_EXAMPLE.py` | No se puede modificar nada en Odoo |

---

## 📋 Pendientes / Acciones Requeridas

- [ ] **Backend Odoo**: Verificar que `firebase-service-account.json` corresponda al **nuevo** proyecto Firebase `logtic`
- [ ] **iOS**: Configurar `GoogleService-Info.plist` y completar el directorio `ios/` (actualmente incompleto)
- [ ] **Probar** el flujo completo: login → registro token → asignar ruta en Odoo → push → deep link
- [ ] **Nota**: El deep link se construye desde `route_ids` (el backend no envía `route`)

---

## 🗺️ Mapa del Sistema de Notificaciones

```
┌─────────────────────────────────────────────────────────────────────┐
│                        BACKEND (Odoo) — SIN CAMBIOS                 │
│  ODOO_CONTROLLER_EXAMPLE.py                                         │
│  ├─ Modelo: fcm.device.token (driver_id, token, platform, active)   │
│  ├─ POST /api/fcm/register → Registra token FCM                     │
│  ├─ send_fcm_notification() → Envía push al asignar rutas           │
│  └─ MssRouteWithFcm.write() → Detecta cambio de driver y notifica   │
│  └─ Payload: route_ids (NO route)                                   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ FCM Push (data message)
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        FIREBASE CLOUD MESSAGING                     │
│  Proyecto: logtic (694502319973)                                    │
│  Android: com.corpocrea.logistica                                   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                      ▼
┌───────────────┐   ┌──────────────────┐   ┌──────────────────┐
│  FOREGROUND   │   │   BACKGROUND     │   │   TERMINATED     │
│  onMessage    │   │ onBackgroundMsg  │   │ getInitialMessage│
└───────┬───────┘   └────────┬─────────┘   └────────┬─────────┘
        │                    │                      │
        ▼                    ▼                      ▼
┌───────────────────────────────────────────────────────────────┐
│                    APP FLUTTER (main.dart)                     │
│                                                                │
│  _showForegroundNotification()  _firebaseMessagingBackground   │
│  ├─ Notificación local (sistema)  Handler()                    │
│  ├─ Banner in-app (SnackBar)      ├─ Notificación local        │
│  └─ Badge increment (persistido)  └─ Guarda pending_route       │
│                                                                │
│  _handleDeepLink(data) → construye /routes/{id} desde route_ids│
│  AuthProvider.listenTokenRefresh() → re-registra token         │
│  BackgroundSyncService → checkNewRoutes → sync → badge++       │
└───────────────────────────────────────────────────────────────┘
```

---

## 🔍 Incongruencias Detectadas (Originales)

### Críticas
1. ~~`onTokenRefresh` no implementado~~ → ✅ Mejora 1
2. ~~`_handleDeepLink` espera `route`, backend envía `route_ids`~~ → ✅ Mejora 2 (app construye deep link desde `route_ids`)
3. ~~`pending_route` solo se guarda si `data.containsKey('route')`~~ → ✅ Mejora 2 (ahora también con `route_ids`)
4. ~~`prefsFcmTokenSent` se escribe pero nunca se lee~~ → ✅ Mejora 1 (reintento en token refresh)
5. ~~`checkNewRoutes` nunca se usa~~ → ✅ Mejora 3

### Importantes
6. ~~`platform: 'android'` hardcodeado~~ → ✅ Corregido con `Platform.isIOS`
7. ~~`firebase_options.dart` no existe~~ → ✅ Mejora 6
8. ~~Directorio iOS incompleto~~ → ⏳ Pendiente (requiere acción manual)
9. ~~Doble notificación en foreground~~ → ⚠️ Por diseño (sistema + banner)
10. ~~`generateId` usa `hashCode`~~ → ✅ Mejora 8
11. ~~`logout()` no desregistra token~~ → ⚠️ **No aplicable** (requeriría modificar Odoo)
12. ~~`_showForegroundNotification` no maneja `route_count`~~ → ✅ Mejora 7

### Menores
13. ~~`markOneAsRead` vs `markAllAsRead` inconsistente~~ → ⚠️ Por diseño
14. ~~`NotificationBadgeProvider` no persiste~~ → ✅ Mejora 5
15. ~~`LocalNotificationService.init()` se llama 2 veces~~ → ⚠️ Guard `_initialized` lo protege
16. ~~`BackgroundSyncService` no usa `checkNewRoutes`~~ → ✅ Mejora 3
17. ~~`_registerFcmToken` no verifica `prefsFcmTokenSent`~~ → ⚠️ Re-registro intencional en cada sesión

---

## 🚀 Cómo Probar

1. **Build Android**:
   ```bash
   cd appLogTic
   flutter build apk --debug
   ```

2. **Probar registro de token**:
   - Iniciar sesión → verificar en logs: `FCM Token registered successfully`
   - Verificar en Odoo: `fcm.device.token` tiene el registro activo

3. **Probar push al asignar ruta**:
   - En Odoo, asignar una ruta a un conductor
   - Verificar que llega la notificación push con "Te han asignado X nueva(s) ruta(s)"
   - Tocar la notificación → debe navegar a `/routes/{id}` (construido desde `route_ids`)

4. **Probar rotación de token**:
   - Desinstalar/reinstalar la app o forzar rotación
   - Verificar que `onTokenRefresh` re-registra el nuevo token