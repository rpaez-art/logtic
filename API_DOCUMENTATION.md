# 📡 Documentación Oficial de la API REST — LogTic 🚚

> **Servidor:** `https://etc-corpocrea.odoo.com/`
> **Base de datos:** `etc-corpocrea`
> **Autenticación:** Basada en cookies de sesión (`session_id`)
> **Formato:** JSON (`Content-Type: application/json`)

---

## 🔐 Autenticación

### `POST /api/auth/login`

Inicia sesión y devuelve una cookie `session_id` para autenticar requests subsiguientes.

#### Request

```json
{
  "username": "rafaelpaez",
  "password": "rafaelpaez"
}
```

> **⚠️ Nota importante:** El endpoint acepta `username`/`password`. NO usa `login`/`db` como el login estándar de Odoo. Si envías `db`, devuelve error:`"Usuario y contraseña son requeridos"`.

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "uid": "62b819f5ebc39808c691f32fcd70ef92818a7444",
    "session_id": "62b819f5ebc39808c691f32fcd70ef92818a7444",
    "username": "rafaelpaez",
    "full_name": "Rafael Paez",
    "role": "driver",
    "driver_code": "DRV009",
    "driver_id": 20173,
    "driver_name": "MILANO AGUILAR GUSTAVO RAFAEL"
  }
}
```

#### Headers relevantes

```
Set-Cookie: session_id=62b819f5ebc39808c691f32fcd70ef92818a7444; Expires=Mon, 27 Jul 2026 14:00:51 GMT; Max-Age=604800; HttpOnly; Path=/; Secure; SameSite=Lax
Server: Odoo.sh
Strict-Transport-security: max-age=31536000; includeSubDomains
```

#### cURL

```bash
curl -X POST https://etc-corpocrea.odoo.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"rafaelpaez","password":"rafaelpaez"}'
```

---

## 📋 Rutas

### `GET /api/routes/sync`

Sincroniza las rutas del día para un conductor específico.

#### Query Params

| Parámetro | Tipo    | Obligatorio | Descripción                          |
|-----------|---------|-------------|--------------------------------------|
| `driver`  | string  | No*         | Username o ID del conductor          |

> Si no se envía `driver`, trae todas las rutas del día.

#### Request

```bash
curl "https://etc-corpocrea.odoo.com/api/routes/sync?driver=rafaelpaez" \
  -H "Cookie: session_id=..."
```

#### Response (cuando hay rutas ese día)

```json
{
  "success": true,
  "data": [
    {
      "id": 886,
      "name": "RUTA000882",
      "driver_id": {
        "id": 20173,
        "name": "MILANO AGUILAR GUSTAVO RAFAEL"
      },
      "state": "finished",
      "date": "2026-07-17",
      "route_lines": [
        {
          "id": 926,
          "partner_id": {
            "id": 16878,
            "name": "DIPLOELCA, C.A."
          },
          "street": "BARF CATIA LA MAR",
          "city": "",
          "latitude": 0.0,
          "longitude": 0.0,
          "sequence": 926,
          "notes": "",
          "state": "done",
          "scheduled_time": "11:32:59"
        }
      ]
    }
  ],
  "meta": null
}
```

#### Response (sin rutas ese día)

```json
{
  "success": true,
  "data": [],
  "meta": null
}
```

---

### `GET /api/routes/{route_id}`

Obtiene el detalle completo de una ruta específica.

#### Request

```bash
curl "https://etc-corpocrea.odoo.com/api/routes/886" \
  -H "Cookie: session_id=..."
```

#### Response

```json
{
  "success": true,
  "data": {
    "id": 886,
    "name": "RUTA000882",
    "driver_id": {
      "id": 20173,
      "name": "MILANO AGUILAR GUSTAVO RAFAEL"
    },
    "state": "finished",
    "date": "2026-07-17",
    "route_lines": [
      {
        "id": 926,
        "partner_id": {
          "id": 16878,
          "name": "DIPLOELCA, C.A."
        },
        "street": "BARF CATIA LA MAR",
        "city": "",
        "latitude": 0.0,
        "longitude": 0.0,
        "sequence": 926,
        "notes": "",
        "state": "done",
        "scheduled_time": "11:32:59"
      }
    ]
  }
}
```

---

## 📊 Estadísticas del Conductor

### `GET /api/driver/stats`

Obtiene estadísticas detalladas de rendimiento.

#### Query Params

| Parámetro | Tipo    | Obligatorio | Descripción                                      |
|-----------|---------|-------------|--------------------------------------------------|
| `driver`  | string  | Sí          | Username o ID del conductor                      |
| `period`  | string  | No          | `today`, `week`, `month` o `all`. Default: `today` |

#### Request

```bash
curl "https://etc-corpocrea.odoo.com/api/driver/stats?driver=rafaelpaez&period=month" \
  -H "Cookie: session_id=..."
```

#### Response (period=month — con datos reales)

```json
{
  "success": true,
  "data": {
    "driver": {
      "id": 20173,
      "name": "MILANO AGUILAR GUSTAVO RAFAEL",
      "image": "iVBORw0KGgoA... [base64 image]"
    },
    "period": "month",
    "summary": {
      "total_routes": 28,
      "completed_routes": 28,
      "in_progress_routes": 0,
      "pending_routes": 0,
      "total_deliveries": 29,
      "completed_deliveries": 29,
      "pending_deliveries": 0,
      "in_progress_deliveries": 0,
      "completion_rate": 100.0
    },
    "performance": {
      "avg_delivery_time_minutes": 33.2,
      "avg_route_time_minutes": 42.1,
      "avg_delivery_time_formatted": "33m",
      "avg_route_time_formatted": "42m"
    },
    "today": {
      "total": 0,
      "completed": 0,
      "pending": 0,
      "in_progress": 0
    }
  }
}
```

#### Response (period=today — sin actividad)

```json
{
  "success": true,
  "data": {
    "driver": {
      "id": 20173,
      "name": "MILANO AGUILAR GUSTAVO RAFAEL",
      "image": "iVBORw0KGgoA... [base64 image]"
    },
    "period": "today",
    "summary": {
      "total_routes": 0,
      "completed_routes": 0,
      "in_progress_routes": 0,
      "pending_routes": 0,
      "total_deliveries": 0,
      "completed_deliveries": 0,
      "pending_deliveries": 0,
      "in_progress_deliveries": 0,
      "completion_rate": 0
    },
    "performance": {
      "avg_delivery_time_minutes": 0,
      "avg_route_time_minutes": 0,
      "avg_delivery_time_formatted": "0m",
      "avg_route_time_formatted": "0m"
    },
    "today": {
      "total": 0,
      "completed": 0,
      "pending": 0,
      "in_progress": 0
    }
  }
}
```

> **Nota:** La imagen del conductor viene codificada en base64 dentro del campo `driver.image`.

---

## 📜 Historial de Rutas

### `GET /api/routes/history`

Obtiene el historial paginado de rutas completadas.

#### Query Params

| Parámetro | Tipo   | Obligatorio | Descripción                         |
|-----------|--------|-------------|-------------------------------------|
| `driver`  | string | Sí          | Username o ID del conductor         |
| `limit`   | int    | No          | Resultados por página. Default: `20`|
| `offset`  | int    | No          | Paginación. Default: `0`            |

#### Request

```bash
curl "https://etc-corpocrea.odoo.com/api/routes/history?driver=rafaelpaez&limit=3&offset=0" \
  -H "Cookie: session_id=..."
```

#### Response

```json
{
  "success": true,
  "data": [
    {
      "id": 886,
      "name": "RUTA000882",
      "date": "2026-07-17",
      "start_date": "2026-07-17 11:32:59",
      "end_date": "2026-07-17 12:18:46",
      "duration_minutes": 45.8,
      "duration_formatted": "45m",
      "total_deliveries": 1,
      "completed_deliveries": 1
    },
    {
      "id": 893,
      "name": "RUTA000889",
      "date": "2026-07-17",
      "start_date": "2026-07-17 10:33:08",
      "end_date": "2026-07-17 12:18:36",
      "duration_minutes": 105.5,
      "duration_formatted": "1h 45m",
      "total_deliveries": 1,
      "completed_deliveries": 1
    },
    {
      "id": 875,
      "name": "RUTA000871",
      "date": "2026-07-16",
      "start_date": "2026-07-16 10:22:35",
      "end_date": "2026-07-16 14:54:33",
      "duration_minutes": 272.0,
      "duration_formatted": "4h 32m",
      "total_deliveries": 2,
      "completed_deliveries": 2
    }
  ],
  "pagination": {
    "total": 156,
    "limit": 3,
    "offset": 0,
    "has_more": true
  }
}
```

> Datos reales del conductor **rafaelpaez** (driver_id=20173): **156 rutas completadas** en total.

---

## 📦 Actualización de Estado de Líneas

### `POST /api/routes/line/start`

Inicia una línea de ruta (cambia estado a `in_progress`).

#### Request

```json
{
  "line_id": 926,
  "state": "in_progress",
  "latitude": 10.4858,
  "longitude": -66.8531,
  "timestamp": "2026-07-20 10:00:00"
}
```

#### Response

```json
{
  "success": true,
  "message": "Ruta iniciada correctamente"
}
```

---

### `POST /api/routes/line/pickup*

Marca una línea como "recogida" (estado `picked_up`).

#### Request

```json
{
  "line_id": 926,
  "state": "picked_up",
  "timestamp": "2026-07-20 10:30:00"
}
```

---

### `POST /api/routes/line/complete`

Completa una línea de ruta (cambia estado a `done`).  
Si todas las líneas están completadas, la ruta pasa automáticamente a estado `done`.

#### Request

```json
{
  "line_id": 926,
  "state": "done",
  "latitude": 10.4900,
  "longitude": -66.8600,
  "timestamp": "2026-07-20 11:00:00"
}
```

#### Response

```json
{
  "success": true,
  "message": "Ruta completada correctamente"
}
```

---

### `POST /api/routes/line/incomplete`

Marca una línea como incompleta con razón y notas.

#### Request

```json
{
  "line_id": 926,
  "state": "incomplete",
  "reason": "Cliente ausente",
  "notes": "Se intentó contactar vía telefónica sin éxito",
  "latitude": 10.4900,
  "longitude": -66.8600,
  "timestamp": "2026-07-20 11:30:00"
}
```

---

### `POST /api/routes/line/upload-image`

Sube una imagen asociada a una línea de ruta (foto de entrega).

#### Request

```json
{
  "line_id": 926,
  "image": "base64_encoded_image_data...",
  "filename": "delivery_926_20260720110000.jpg",
  "notes": "Foto de la entrega",
  "timestamp": "2026-07-20 11:00:00"
}
```

#### Response

```json
{
  "success": true,
  "message": "Imagen subida correctamente",
  "data": {
    "line_id": 926,
    "filename": "delivery_926_20260720110000.jpg",
    "timestamp": "2026-07-20 11:00:00"
  }
}
```

---

### `PUT /api/routes/{route_id}/state`

Actualiza el estado global de una ruta.

#### Request

```json
{
  "state": "started"
}
```

#### Response

```json
{
  "success": true,
  "message": "Estado actualizado correctamente"
}
```

---

## 🔔 Notificaciones Push y FCM

### `POST /api/fcm/register`

Registra un token FCM del dispositivo Android para recibir notificaciones push en tiempo real.

#### Request

```json
{
  "driver_id": 20173,
  "token": "fM8x2Kc9...FCM_Token",
  "platform": "android",
  "username": "rafaelpaez"
}
```

#### Response

```json
{
  "success": true,
  "message": "Token FCM registrado"
}
```

---

## ❌ Endpoints NO Implementados en el Servidor

Los siguientes endpoints están definidos en el código del controlador pero **no están disponibles** en este servidor actualmente (devuelven 404):

| Endpoint | Método | Estado |
|----------|--------|--------|
| `GET /api/routes/check-new` | GET | ❌ 404 |
| `GET /api/routes/driver/{username}` | GET | ❌ Redirect a login |
| `GET /api/routes/line/attachments/{line_id}` | GET | ❌ 404 |
| `GET /api/routes/history/{route_id}/lines` | GET | ❌ Sin implementar |
| `GET /api/attachment/{attachment_id}` | GET | ❌ Sin implementar |

---

## 🧪 Resumen de Pruebas Realizadas

| Endpoint | Método | Código | Resultado |
|----------|--------|--------|-----------|
| `/api/auth/login` | POST | `200` | ✅ Login exitoso — sesión iniciada para rafaelpaez |
| `/api/routes/sync` | GET | `200` | ✅ 0 rutas hoy, datos históricos con rutas completadas |
| `/api/routes/886` | GET | `200` | ✅ Detalle de ruta RUTA000882 |
| `/api/driver/stats` | GET | `200` | ✅ 28 rutas, 29 entregas, 100% completadas en el mes |
| `/api/routes/history` | GET | `200` | ✅ 156 rutas totales, paginación funcional |
| `/api/fcm/register` | POST | — | ⬜ Pendiente de probar (requiere token FCM real) |
| `/api/routes/line/start` | POST | — | ⬜ No probado (requiere línea activa) |
| `/api/routes/line/complete` | POST | — | ⬜ No probado (requiere línea activa) |
| `/api/routes/line/upload-image` | POST | — | ⬜ No probado |

---

## 📌 Modelos de Datos (Respuestas)

### `LoginResponse`

| Campo          | Tipo    | Descripción                          | Ejemplo                    |
|----------------|---------|--------------------------------------|----------------------------|
| `success`      | bool    | Estado de la operación               | `true`                     |
| `data.username`| string  | Nombre de usuario                    | `"rafaelpaez"`             |
| `data.full_name`| string | Nombre completo                      | `"Rafael Paez"`            |
| `data.role`    | string  | Rol del usuario                      | `"driver"`                 |
| `data.driver_code`| string | Código interno del conductor       | `"DRV009"`                 |
| `data.driver_id`| int    | ID del partner en Odoo               | `20173`                    |
| `data.driver_name`| string | Nombre registrado del conductor    | `"MILANO AGUILAR GUSTAVO RAFAEL"` |

### `RouteData`

| Campo               | Tipo    | Descripción                          |
|----------------------|---------|--------------------------------------|
| `id`                | int     | ID de la ruta                        |
| `name`              | string  | Nombre de la ruta                    |
| `state`             | string  | Estado de la ruta                    |
| `date`              | string  | Fecha de la ruta                     |
| `driver_id.id`      | int     | ID del conductor                     |
| `driver_id.name`    | string  | Nombre del conductor                 |
| `route_lines[]`     | array   | Lista de líneas de la ruta           |

### `RouteLineData`

| Campo                 | Tipo    | Descripción                          |
|------------------------|---------|--------------------------------------|
| `id`                  | int     | ID de la línea                       |
| `partner_id.id`       | int     | ID del cliente                       |
| `partner_id.name`     | string  | Nombre del cliente                   |
| `street`              | string  | Dirección                            |
| `city`                | string  | Ciudad                               |
| `latitude`            | float   | Latitud                              |
| `longitude`           | float   | Longitud                             |
| `sequence`            | int     | Orden de la parada                   |
| `notes`               | string  | Notas adicionales                    |
| `state`               | string  | `draft`, `in_progress`, `done`       |
| `scheduled_time`      | string  | Hora programada                      |

### `DriverStatsResponse`

| Campo                                  | Tipo   | Descripción                              |
|----------------------------------------|--------|------------------------------------------|
| `data.driver.id`                       | int    | ID del conductor                         |
| `data.driver.name`                     | string | Nombre del conductor                     |
| `data.driver.image`                    | string | Foto del conductor (base64)              |
| `data.period`                          | string | Período consultado                       |
| `data.summary.total_routes`            | int    | Total de rutas                           |
| `data.summary.completed_routes`        | int    | Rutas completadas                        |
| `data.summary.completion_rate`         | float  | Porcentaje de completitud                |
| `data.summary.total_deliveries`        | int    | Total de entregas                        |
| `data.summary.completed_deliveries`    | int    | Entregas completadas                     |
| `data.performance.avg_delivery_time_minutes` | float | Tiempo promedio por entrega        |
| `data.performance.avg_route_time_minutes`    | float | Tiempo promedio por ruta            |
| `data.today.total`                     | int    | Entregas de hoy                          |
| `data.today.completed`                 | int    | Completadas hoy                          |

### `RoutesHistoryResponse`

| Campo                           | Tipo    | Descripción                          |
|----------------------------------|---------|--------------------------------------|
| `data[].id`                     | int     | ID de la ruta                        |
| `data[].name`                   | string  | Nombre de la ruta                    |
| `data[].date`                   | string  | Fecha de la ruta                     |
| `data[].start_date`             | string  | Fecha/hora de inicio                 |
| `data[].end_date`               | string  | Fecha/hora de finalización           |
| `data[].duration_minutes`       | float   | Duración en minutos                  |
| `data[].duration_formatted`     | string  | Duración formateada                  |
| `data[].total_deliveries`       | int     | Total de entregas                    |
| `data[].completed_deliveries`   | int     | Entregas completadas                 |
| `pagination.total`              | int     | Total de registros                   |
| `pagination.limit`              | int     | Límite por página                    |
| `pagination.offset`             | int     | Offset actual                        |
| `pagination.has_more`           | bool    | Si hay más páginas                   |

---

## 🔧 Notas Técnicas

### Autenticación
- El endpoint usa `username`/`password` (no `login`/`password`/`db`).
- La sesión se mantiene mediante cookies HTTP (`session_id` con 7 días de expiración).
- Se debe incluir la cookie `session_id` en todos los requests subsiguientes.

### Estados de Línea de Ruta
| Estado          | Descripción                    |
|-----------------|--------------------------------|
| `draft`         | Pendiente / sin iniciar        |
| `in_progress`   | En progreso                    |
| `picked_up`     | Recogido                       |
| `done`          | Completado                     |
| `incomplete`    | Incompleto                     |
| `partial`       | Parcialmente completado        |

### Estados de Ruta
| Estado          | Descripción                    |
|-----------------|--------------------------------|
| `draft`         | Borrador                       |
| `started`       | Iniciada (al menos 1 línea)   |
| `finished`      | Finalizada (todas completadas) |
| `done`          | Completada                     |
| `cancelled`     | Cancelada                      |

### Seguridad
- Autenticación requerida para todos los endpoints excepto `/api/auth/login`.
- CSRF deshabilitado para endpoints JSON.
- Las operaciones se ejecutan con `sudo()` para evitar restricciones de permisos.

---

## 📝 Ejemplos de Uso (cURL)

```bash
# 1. Login
curl -X POST https://etc-corpocrea.odoo.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"rafaelpaez","password":"rafaelpaez"}' \
  -c cookies.txt

# 2. Sincronizar rutas del día
curl -b cookies.txt "https://etc-corpocrea.odoo.com/api/routes/sync?driver=rafaelpaez"

# 3. Obtener estadísticas del mes
curl -b cookies.txt "https://etc-corpocrea.odoo.com/api/driver/stats?driver=rafaelpaez&period=month"

# 4. Historial de rutas (primeras 3)
curl -b cookies.txt "https://etc-corpocrea.odoo.com/api/routes/history?driver=rafaelpaez&limit=3&offset=0"

# 5. Detalle de ruta específica
curl -b cookies.txt "https://etc-corpocrea.odoo.com/api/routes/886"
```
