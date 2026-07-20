# 📡 Documentación Oficial de la API REST — LogTic 🚚

> **Servidor:** `https://etc-corpocrea.odoo.com/`
> **Módulo Odoo:** `mss_route_optimization/controllers/api.py`
> **Autenticación:** Basada en cookies de sesión (`session_id`)
> **Formato:** JSON (excepto descargas de archivos)
> **Última actualización:** 20 Julio 2026 — Pruebas completas con usuario `rafaelpaez`

---

## 📋 Índice de Endpoints

| # | Método | Endpoint | Estado |
|---|--------|----------|--------|
| 1 | `POST` | `/api/auth/login` | ✅ 200 |
| 2 | `GET` | `/api/routes/sync` | ✅ 200 |
| 3 | `GET` | `/api/routes/driver/{username}` | ⚠️ Funciona solo con usuarios `res.users` |
| 4 | `GET` | `/api/routes/{route_id}` | ✅ 200 |
| 5 | `GET` | `/api/routes/history/{route_id}/lines` | ✅ 200 (alias) |
| 6 | `POST` | `/api/routes/line/start` | ✅ 200 |
| 7 | `POST` | `/api/routes/line/pickup` | ✅ 200 |
| 8 | `POST` | `/api/routes/line/complete` | ✅ 200 |
| 9 | `POST` | `/api/routes/line/incomplete` | ⚠️ Bug de codificación |
| 10 | `PUT/POST` | `/api/routes/{route_id}/state` | ⚠️ 200 (HTTP) |
| 11 | `PUT/POST` | `/api/routes/{route_id}/set-state` | ✅ 200 |
| 12 | `POST` | `/api/routes/line/upload-image` | ✅ 200 |
| 13 | `GET` | `/api/routes/line/{line_id}/image` | ✅ 200 |
| 14 | `GET` | `/api/driver/stats` | ✅ 200 |
| 15 | `GET` | `/api/routes/history` | ✅ 200 |
| 16 | `GET` | `/api/routes/line/{line_id}/map-info` | ✅ 200 |
| 17 | `GET` | `/api/attachment/{attachment_id}` | ✅ 200 |
| 18 | `GET` | `/api/routes/check-new` | ✅ 200 |
| 19 | `GET` | `/api/routes/line/{line_id}/attachments` | ✅ 200 |
| 20 | `POST` | `/api/fcm/register` | ✅ 200 |

---

## 🔐 Autenticación

### `POST /api/auth/login`

Inicia sesión en la app móvil. A diferencia del endpoint estándar de Odoo, usa **`username`/`password`** en vez de `login`/`password`/`db`.

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"rafaelpaez","password":"rafaelpaez"}'
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "username": "rafaelpaez",
    "full_name": "Rafael Paez",
    "role": "driver",
    "driver_code": "DRV009",
    "driver_id": 20173,
    "driver_name": "MILANO AGUILAR GUSTAVO RAFAEL"
  }
}
```

**Headers de respuesta:**
```
Set-Cookie: session_id=YOUR_SESSION_ID; Expires=...; HttpOnly; Path=/; Secure; SameSite=Lax
```

> **⚠️ Nota:** El `driver_name` devuelto es el nombre del partner/chofer vinculado, NO el nombre de usuario.

---

## 📍 Rutas del Día (Sync)

### `GET /api/routes/sync`

Obtiene las rutas **pendientes** (no finalizadas) del conductor. Es el endpoint principal que usa la app móvil al iniciar.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `driver` | string | No* | Username, driver_code o driver_id del conductor |
| `debug` | string | No | Si es `1`, incluye info de debugging del modelo |
| `all` | string | No | Si es `1`, trae TODAS las rutas sin filtrar por estado |

> *Si no se pasa `driver`, devuelve rutas sin filtrar por conductor.

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/sync?driver=rafaelpaez" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 903,
      "name": "RUTA000899",
      "driver_id": {
        "id": 20173,
        "name": "MILANO AGUILAR GUSTAVO RAFAEL"
      },
      "state": "new",
      "max_priority": "low",
      "date": "2026-07-20",
      "start_date": "",
      "end_date": "",
      "route_lines": [
        {
          "id": 943,
          "partner_id": {
            "id": 0,
            "name": ""
          },
          "origin_address": "https://www.google.com/maps/place/Estacionamiento+Centro+Comercial+Arta/...",
          "destination_address": "Cento empresarial Galipan, piso 4",
          "street": "Cento empresarial Galipan, piso 4",
          "city": "",
          "origin_latitude": 0.0,
          "origin_longitude": 0.0,
          "destination_latitude": 0.0,
          "destination_longitude": 0.0,
          "latitude": 0.0,
          "longitude": 0.0,
          "map_address": "https://www.google.com/maps/place/Estacionamiento+Centro+Comercial+Arta/...",
          "map_latitude": 0.0,
          "map_longitude": 0.0,
          "sequence": 943,
          "notes": "<p style=\"margin-bottom: 0px;\">Entregar en el departamento de comprar Michael o Rosa</p>",
          "obra": "ETC PROYECTO GALIPAN",
          "priority": "low",
          "state": "pending",
          "incomplete_reason": "",
          "incomplete_notes": "",
          "scheduled_time": "",
          "start_time": "",
          "pickup_time": "",
          "end_time": "",
          "order_type": null,
          "order_name": null,
          "order_lines": [],
          "attachments": []
        }
      ]
    }
  ],
  "meta": null
}
```

**Estructura de `route_line`:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int | ID de la línea de ruta |
| `partner_id` | object | `{id, name}` — cliente/destinatario |
| `origin_address` | string | Dirección de origen (punto de partida) |
| `destination_address` | string | Dirección de destino (entrega) |
| `street` | string | Legacy — alias de delivery_address |
| `origin_latitude` | float | Latitud de origen |
| `origin_longitude` | float | Longitud de origen |
| `destination_latitude` | float | Latitud de destino |
| `destination_longitude` | float | Longitud de destino |
| `latitude` | float | Legacy — latitud actual |
| `longitude` | float | Legacy — longitud actual |
| `map_address` | string | Dirección activa según estado (origen si pending, destino si in_progress/done) |
| `map_latitude` | float | Latitud del mapa según estado |
| `map_longitude` | float | Longitud del mapa según estado |
| `sequence` | int | Orden (usa ID como temporal) |
| `notes` | string | Notas/instrucciones (puede contener HTML) |
| `obra` | string | Nombre de la obra/proyecto |
| `priority` | string | Prioridad: `low`, `medium`, `high` |
| `state` | string | Estado: `pending`, `in_progress`, `picked_up`, `done`, `incomplete`, `partial` |
| `incomplete_reason` | string | Razón de incompletitud |
| `incomplete_notes` | string | Notas de incompletitud |
| `scheduled_time` | string | Fecha/hora programada |
| `start_time` | string | Fecha/hora de inicio |
| `pickup_time` | string | Fecha/hora de recogida |
| `end_time` | string | Fecha/hora de finalización |
| `order_type` | string|null | Tipo de pedido: `sale`, `purchase`, o `null` |
| `order_name` | string|null | Nombre del pedido (ej: ODC43436) |
| `order_lines` | array | Lista de productos del pedido |
| `attachments` | array | Lista de archivos adjuntos (IDs, metadata) |

---

## 👤 Obtener Rutas por Conductor (Alternativo)

### `GET /api/routes/driver/{username}`

Obtiene rutas **de HOY** para un conductor específico. **Busca en `res.users`**, no en `mss.app.user`.

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/driver/rafaelpaez" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (usuario no encontrado):**
```json
{
  "success": false,
  "message": "Usuario no encontrado"
}
```

> ⚠️ **Nota:** `rafaelpaez` es un usuario de `mss.app.user`, no de `res.users`. Por eso devuelve "Usuario no encontrado". Usar con un login de Odoo estándar.

---

## 📄 Detalle de Ruta

### `GET /api/routes/{route_id}`
### `GET /api/routes/history/{route_id}/lines`

Obtiene el detalle completo de una ruta específica, incluyendo todas sus líneas.

**Request:**
```bash
# Formato 1
curl "https://etc-corpocrea.odoo.com/api/routes/903" \
  -H "Cookie: session_id=YOUR_SESSION_ID"

# Formato 2 (alias)
curl "https://etc-corpocrea.odoo.com/api/routes/history/903/lines" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 903,
    "name": "RUTA000899",
    "driver_id": {
      "id": 20173,
      "name": "MILANO AGUILAR GUSTAVO RAFAEL"
    },
    "state": "new",
    "date": "2026-07-20",
    "route_lines": [
      {
        "id": 943,
        "partner_id": {
          "id": 0,
          "name": ""
        },
        "street": "Cento empresarial Galipan, piso 4",
        "city": "",
        "latitude": 0.0,
        "longitude": 0.0,
        "sequence": 943,
        "notes": "<p style=\"margin-bottom: 0px;\">Entregar en el departamento de comprar Michael o Rosa</p>",
        "state": "draft",
        "scheduled_time": ""
      }
    ]
  }
}
```

> ⚠️ **Nota:** Este endpoint devuelve un **formato más básico** que el sync (sin `order_lines`, `attachments`, coordenadas separadas origen/destino, `obra`, `priority`).

---

## ▶️ Acciones sobre Líneas de Ruta

### `POST /api/routes/line/start`

Inicia una línea de ruta. Si la ruta no está iniciada, la inicia automáticamente.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `line_id` | int | ✅ Sí | ID de la línea de ruta |
| `latitude` | float | No | Latitud actual |
| `longitude` | float | No | Longitud actual |
| `timestamp` | string | No | Fecha/hora en formato `YYYY-MM-DD HH:MM:SS` |

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/routes/line/start" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{"line_id":943,"latitude":10.4900108,"longitude":-66.870626,"timestamp":"2026-07-20 19:50:00"}'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Tarea iniciada correctamente"
}
```

**Lógica:**
- Si la ruta está en estado `new`/`draft` → la cambia a `started` y registra `start_date`
- La línea pasa a estado `in_progress` con su `start_date`
- Guarda latitud/longitud si se proporcionan

---

### `POST /api/routes/line/pickup`

Marca una línea como **recogida** (aplica para rutas con recogida de materiales).

**Parámetros:** (mismos que `start`)

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/routes/line/pickup" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{"line_id":943,"latitude":10.4900108,"longitude":-66.870626,"timestamp":"2026-07-20 19:51:00"}'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Línea marcada como recogida exitosamente"
}
```

**Lógica:**
- Cambia estado de línea a `picked_up`
- Registra `pickup_date`
- Guarda ubicación si se proporciona

---

### `POST /api/routes/line/complete`

Completa una línea de ruta. Si **todas** las líneas están completadas, finaliza la ruta automáticamente.

**Parámetros:** (mismos que `start`)

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/routes/line/complete" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{"line_id":943,"latitude":10.4900108,"longitude":-66.870626,"timestamp":"2026-07-20 19:55:00"}'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Tarea completada correctamente",
  "route_finished": true
}
```

**Lógica:**
- Cambia estado de línea a `done`, registra `end_date`
- Si todas las líneas están en estado final (`done`, `cancelled`, `incomplete`, `partial`):
  - Cambia ruta a `finished`
  - Registra `end_date` de la ruta
  - Calcula `travel_duration` (diferencia entre start_date y end_date)
- `route_finished: true` indica que la ruta se completó totalmente

---

### `POST /api/routes/line/incomplete`

Marca una línea como **incompleta o parcial** con un motivo.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `line_id` | int | ✅ Sí | ID de la línea de ruta |
| `state` | string | No | `incomplete` o `partial` (default: `incomplete`) |
| `reason` | string | No | Razón de la incompletitud |
| `notes` | string | No | Notas adicionales |
| `latitude` | float | No | Latitud |
| `longitude` | float | No | Longitud |
| `timestamp` | string | No | Fecha/hora |

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/routes/line/incomplete" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{"line_id":1,"state":"incomplete","reason":"Cliente ausente","notes":"Se intentó contactar pero no responde","timestamp":"2026-07-20 20:00:00"}'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Línea marcada como incompleta",
  "route_finished": false
}
```

> ⚠️ **Bug conocido:** Si el `reason` o `notes` contienen caracteres no-UTF-8, puede fallar con error `'utf-8' codec can't decode byte ...`

---

### `PUT/POST /api/routes/{route_id}/state` | `PUT/POST /api/routes/{route_id}/set-state`

Actualiza el estado de una ruta completa.

| Endpoint | Funciona |
|----------|----------|
| `PUT /api/routes/{id}/state` (JSON-RPC) | ❌ Error: `'Request' object has no attribute 'jsonrequest'` |
| `PUT /api/routes/{id}/set-state` (HTTP) | ✅ Funciona |
| `POST /api/routes/{id}/state` (HTTP) | ✅ Funciona |

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `state` | string | ✅ Sí | Nuevo estado: `new`, `started`, `finished`, `draft` |

**Request (funciona):**
```bash
curl -X PUT "https://etc-corpocrea.odoo.com/api/routes/903/set-state" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{"state":"finished"}'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Estado actualizado correctamente"
}
```

---

## 📸 Imágenes de Entrega

### `POST /api/routes/line/upload-image`

Sube una imagen de entrega/firma para una línea de ruta.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `line_id` | int | ✅ Sí | ID de la línea de ruta |
| `image` | string | ✅ Sí | Imagen en base64 (con o sin prefijo `data:image/...`) |
| `filename` | string | No | Nombre del archivo (default: `delivery_{line_id}.jpg`) |
| `notes` | string | No | Notas de la entrega |
| `timestamp` | string | No | Fecha/hora |

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/routes/line/upload-image" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{
    "line_id": 943,
    "image": "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7",
    "filename": "firma_entrega.jpg",
    "notes": "Entrega completada",
    "timestamp": "2026-07-20 19:55:00"
  }'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Imagen guardada correctamente",
  "data": {
    "line_id": 943,
    "filename": "firma_entrega.jpg",
    "timestamp": "2026-07-20 19:55:00"
  }
}
```

**Lógica:**
- Si el base64 viene con prefijo `data:image/png;base64,...`, lo limpia automáticamente
- Valida que el base64 sea decodificable
- Guarda en la línea: `completion_image`, `completion_image_filename`, `completion_image_date`, `completion_notes`

---

### `GET /api/routes/line/{line_id}/image`

Obtiene la imagen de entrega de una línea de ruta.

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/line/943/image" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK) — con imagen:**
```json
{
  "success": true,
  "data": {
    "line_id": 943,
    "image": "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7",
    "filename": "test_firma.jpg",
    "timestamp": "2026-07-20 19:55:00",
    "notes": "Entrega completada"
  }
}
```

**Response (200 OK) — sin imagen:**
```json
{
  "success": false,
  "message": "No hay imagen de entrega para esta línea"
}
```

---

## 📊 Estadísticas del Conductor

### `GET /api/driver/stats`

Obtiene estadísticas completas del conductor, incluyendo tiempos promedio, tasas de completitud y resumen del día.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `driver` | string | ✅ Sí | Username, driver_code o driver_id |
| `period` | string | No | Período: `today` (default), `week`, `month`, `all` |

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/driver/stats?driver=rafaelpaez&period=all" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "driver": {
      "id": 20173,
      "name": "MILANO AGUILAR GUSTAVO RAFAEL",
      "image": "iVBORw0KGgo... [base64 de la foto del conductor]"
    },
    "period": "all",
    "summary": {
      "total_routes": 159,
      "completed_routes": 158,
      "in_progress_routes": 0,
      "pending_routes": 1,
      "total_deliveries": 163,
      "completed_deliveries": 160,
      "pending_deliveries": 1,
      "in_progress_deliveries": 0,
      "completion_rate": 98.2
    },
    "performance": {
      "avg_delivery_time_minutes": 26.3,
      "avg_route_time_minutes": 35.0,
      "avg_delivery_time_formatted": "26m",
      "avg_route_time_formatted": "35m"
    },
    "today": {
      "total": 3,
      "completed": 2,
      "pending": 1,
      "in_progress": 0
    }
  }
}
```

> 📸 **Nota:** `driver.image` contiene la foto de perfil del conductor en base64. Puede ser una imagen grande.

---

## 📜 Historial de Rutas

### `GET /api/routes/history`

Obtiene el historial de rutas completadas del conductor, con paginación.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `driver` | string | ✅ Sí | Username, driver_code o driver_id |
| `limit` | int | No | Cantidad de resultados (default: 20) |
| `offset` | int | No | Desplazamiento para paginación (default: 0) |

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/history?driver=rafaelpaez&limit=2" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 906,
      "name": "RUTA000902",
      "date": "2026-07-20",
      "start_date": "2026-07-20 14:52:12",
      "end_date": "2026-07-20 15:20:09",
      "duration_minutes": 27.9,
      "duration_formatted": "27m",
      "total_deliveries": 1,
      "completed_deliveries": 1
    },
    {
      "id": 901,
      "name": "RUTA000897",
      "date": "2026-07-20",
      "start_date": "2026-07-20 11:10:11",
      "end_date": "2026-07-20 11:57:10",
      "duration_minutes": 47.0,
      "duration_formatted": "47m",
      "total_deliveries": 1,
      "completed_deliveries": 1
    }
  ],
  "pagination": {
    "total": 158,
    "limit": 2,
    "offset": 0,
    "has_more": true
  }
}
```

> **Nota:** El conductor `rafaelpaez` tiene **158 rutas completadas** de **159 totales** (1 pendiente) en el período `all`.

---

## 🗺️ Información de Mapa por Línea

### `GET /api/routes/line/{line_id}/map-info`

Obtiene la dirección y coordenadas a mostrar en el mapa según el estado de la línea.

**Lógica de estado:**
- `pending` → Muestra dirección de **ORIGEN**
- `in_progress`, `picked_up`, `done` → Muestra dirección de **DESTINO**

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/line/943/map-info" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK) — línea en estado `pending`:**
```json
{
  "success": true,
  "data": {
    "line_id": 943,
    "state": "pending",
    "address_type": "origin",
    "address": "https://www.google.com/maps/place/Estacionamiento+Centro+Comercial+Arta/...",
    "latitude": 0.0,
    "longitude": 0.0,
    "all_addresses": {
      "origin_address": "https://www.google.com/maps/place/Estacionamiento+Centro+Comercial+Arta/...",
      "origin_latitude": 0.0,
      "origin_longitude": 0.0,
      "destination_address": "Cento empresarial Galipan, piso 4",
      "destination_latitude": 0.0,
      "destination_longitude": 0.0
    }
  }
}
```

---

## 📎 Archivos Adjuntos

### `GET /api/attachment/{attachment_id}`

Obtiene un archivo adjunto por su ID. Puede devolver el archivo como JSON con base64 o como descarga binaria.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `format` | string | No | `json` (default) para base64, `download` para archivo binario |

**Request (como JSON con base64):**
```bash
curl "https://etc-corpocrea.odoo.com/api/attachment/1?format=json" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "flag_image",
    "filename": "flag_image",
    "mimetype": "image/png",
    "file_size": 9152,
    "datas": "iVBORw0KGgo... [base64 del archivo]",
    "create_date": "2024-02-14 17:53:08.862176"
  }
}
```

**Request (como descarga):**
```bash
curl "https://etc-corpocrea.odoo.com/api/attachment/1?format=download" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -o flag_image.png
```

**Response (200 OK) — descarga binaria:**
```
Content-Type: image/png
Content-Disposition: attachment; filename="flag_image"
Content-Length: 9152
```

---

### `GET /api/routes/line/{line_id}/attachments`
### `GET /api/routes/line/attachments/{line_id}`

Obtiene todos los archivos adjuntos de una línea de ruta específica.

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/line/943/attachments" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK) — sin adjuntos:**
```json
{
  "success": true,
  "data": {
    "line_id": 943,
    "attachments": [],
    "count": 0
  }
}
```

**Response (200 OK) — con adjuntos (ejemplo teórico):**
```json
{
  "success": true,
  "data": {
    "line_id": 123,
    "attachments": [
      {
        "id": 45,
        "name": "factura_001.pdf",
        "filename": "factura_001.pdf",
        "mimetype": "application/pdf",
        "file_size": 204800,
        "create_date": "2026-07-17 12:00:00",
        "download_url": "/api/attachment/45?format=download"
      }
    ],
    "count": 1
  }
}
```

> 💡 **Flujo para attachments:** Los attachments también vienen incluidos en el array `attachments[]` dentro de cada `route_line` del endpoint `GET /api/routes/sync`. Para descargar un archivo individual, usa `/api/attachment/{id}`.

---

## 🔔 Verificar Nuevas Rutas

### `GET /api/routes/check-new`

Verifica si hay rutas nuevas o actualizadas para el conductor desde una fecha específica.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `driver` | string | ✅ Sí | Username, driver_code o driver_id |
| `since` | string | No | Fecha desde (`YYYY-MM-DD HH:MM:SS`) para filtrar por `write_date` |

**Request:**
```bash
curl "https://etc-corpocrea.odoo.com/api/routes/check-new?driver=rafaelpaez" \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

**Response (200 OK):**
```json
{
  "success": true,
  "has_new": true,
  "new_count": 1
}
```

---

## 📱 Registrar Token FCM

### `POST /api/fcm/register`

Registra el token FCM (Firebase Cloud Messaging) del dispositivo para notificaciones push.

**Parámetros:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `token` | string | ✅ Sí | Token FCM del dispositivo |
| `driver_id` | int | No* | ID del conductor |
| `username` | string | No* | Username del conductor (alternativa a driver_id) |
| `platform` | string | No | `android` (default) o `ios` |

> *Si no se pasa `driver_id`, intenta resolverlo usando `username`.

**Request:**
```bash
curl -X POST "https://etc-corpocrea.odoo.com/api/fcm/register" \
  -H "Content-Type: application/json" \
  -H "Cookie: session_id=YOUR_SESSION_ID" \
  -d '{
    "driver_id": 20173,
    "token": "fcm_token_abc123",
    "platform": "android",
    "username": "rafaelpaez"
  }'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Token FCM registrado"
}
```

**Lógica:**
- Busca si el token ya existe en `fcm.device.token`
- Si existe: actualiza `driver_id`, `platform`, `last_used`
- Si no existe: crea un nuevo registro

---

## 📊 Modelos de Datos

### Estado de Ruta (`traktop.route`)

| Estado | Descripción |
|--------|-------------|
| `new` | Ruta creada, no iniciada |
| `draft` | Ruta en borrador |
| `started` | Ruta en progreso (al menos una línea iniciada) |
| `finished` | Ruta completada (todas las líneas en estado final) |

### Estado de Línea (`traktop.line`)

| Estado | Descripción |
|--------|-------------|
| `pending` | Pendiente por iniciar |
| `in_progress` | En progreso (iniciada) |
| `picked_up` | Recogida (materiales) |
| `done` | Completada exitosamente |
| `incomplete` | Incompleta (con motivo) |
| `partial` | Parcialmente completada |
| `cancelled` | Cancelada |

### Prioridad

| Valor | Descripción |
|-------|-------------|
| `low` | Prioridad baja |
| `medium` | Prioridad media |
| `high` | Prioridad alta |

### Tipo de Pedido

| Valor | Descripción |
|-------|-------------|
| `sale` | Pedido de venta (facturación) |
| `purchase` | Orden de compra (ODC) |
| `null` | Sin pedido asociado |

---

## 🔄 Flujos Típicos

### Flujo de Trabajo Diario del Conductor

```
1. LOGIN
   POST /api/auth/login
   → Obtiene: session_id, role, driver_code, driver_id

2. SINCRONIZAR RUTAS DEL DÍA
   GET /api/routes/sync?driver=rafaelpaez
   → Obtiene: rutas pendientes con líneas y adjuntos

3. INICIAR TAREA
   POST /api/routes/line/start
   → Marca línea como in_progress, inicia ruta si es necesario

4. RECOGER (opcional)
   POST /api/routes/line/pickup
   → Marca línea como picked_up

5. COMPLETAR TAREA
   POST /api/routes/line/complete
     O
   POST /api/routes/line/incomplete
   → Marca línea como done/incomplete
   → Si todas las líneas están hechas, la ruta se cierra automáticamente

6. SUBIR EVIDENCIA (opcional)
   POST /api/routes/line/upload-image
   → Guarda foto de entrega/firma

7. VERIFICAR NUEVAS RUTAS (periódico)
   GET /api/routes/check-new?driver=rafaelpaez
   → Consulta si hay nuevas asignaciones
```

### Flujo para Histórico con Archivos

```
1. OBTENER HISTORIAL
   GET /api/routes/history?driver=rafaelpaez&limit=20
   → Lista de rutas completadas con IDs

2. VER DETALLE DE RUTA
   GET /api/routes/{route_id}
   → Líneas de la ruta histórica

3. VER ADJUNTOS DE UNA LÍNEA
   GET /api/routes/line/{line_id}/attachments
   → Lista de archivos adjuntos con download_url

4. DESCARGAR ARCHIVO
   GET /api/attachment/{attachment_id}?format=download
   → Archivo binario
     O
   GET /api/attachment/{attachment_id}?format=json
   → Metadata + base64
```

---

## ⚠️ Notas Técnicas y Errores Conocidos

### Autenticación
- El login usa `username`/`password`, **NO** `login`/`password`/`db` como el estándar de Odoo
- Si envías `db` en el body, el servidor responde `"Usuario y contraseña son requeridos"`
- La sesión expira en **7 días** (Max-Age=604800)

### Endpoint `/api/routes/driver/{username}`
- Busca en `res.users` (usuarios Odoo), **NO** en `mss.app.user` (usuarios de la app)
- Los usuarios de app como `rafaelpaez` NO existen en `res.users`, por eso devuelve "Usuario no encontrado"

### Endpoint `/api/routes/{id}` (Detalle de ruta)
- Devuelve un formato **básico** sin `order_lines`, `attachments`, `origin_address`, `destination_address`, `obra`, `priority`
- Para datos completos, usar `GET /api/routes/sync`

### Endpoint `PUT /api/routes/{id}/state` (JSON-RPC)
- **No funciona** — error: `'Request' object has no attribute 'jsonrequest'`
- Usar `PUT /api/routes/{id}/set-state` o `POST /api/routes/{id}/state` en su lugar

### Endpoint `POST /api/routes/line/incomplete`
- Puede fallar con caracteres no UTF-8: `'utf-8' codec can't decode byte ...`
- Esto ocurre si los parámetros contienen caracteres especiales no codificados correctamente

### Adjuntos (Attachments)
- Los `attachments[]` viajan **dentro de cada `route_line`** en el endpoint de sync
- El endpoint dedicado `/api/routes/line/{id}/attachments` **funciona** correctamente
- Para descargar, usa `/api/attachment/{id}?format=download`

---

## 🧪 Comandos de Prueba Rápidos

```bash
# Variables
SESSION="session_id=YOUR_SESSION_ID"
BASE="https://etc-corpocrea.odoo.com"

# Login
curl -X POST "$BASE/api/auth/login" -H "Content-Type: application/json" \
  -d '{"username":"rafaelpaez","password":"rafaelpaez"}'

# Sync
curl "$BASE/api/routes/sync?driver=rafaelpaez" -H "Cookie: $SESSION"

# Historial (últimas 3)
curl "$BASE/api/routes/history?driver=rafaelpaez&limit=3" -H "Cookie: $SESSION"

# Stats (todo)
curl "$BASE/api/driver/stats?driver=rafaelpaez&period=all" -H "Cookie: $SESSION"

# Detalle de ruta
curl "$BASE/api/routes/903" -H "Cookie: $SESSION"

# Map-info de línea
curl "$BASE/api/routes/line/943/map-info" -H "Cookie: $SESSION"

# Adjuntos de línea
curl "$BASE/api/routes/line/943/attachments" -H "Cookie: $SESSION"

# Descargar attachment
curl "$BASE/api/attachment/1?format=json" -H "Cookie: $SESSION"

# Imagen de entrega
curl "$BASE/api/routes/line/943/image" -H "Cookie: $SESSION"

# Iniciar línea
curl -X POST "$BASE/api/routes/line/start" -H "Content-Type: application/json" \
  -H "Cookie: $SESSION" \
  -d '{"line_id":943,"latitude":10.4900108,"longitude":-66.870626,"timestamp":"2026-07-20 19:50:00"}'

# Recoger línea
curl -X POST "$BASE/api/routes/line/pickup" -H "Content-Type: application/json" \
  -H "Cookie: $SESSION" \
  -d '{"line_id":943,"latitude":10.4900108,"longitude":-66.870626,"timestamp":"2026-07-20 19:51:00"}'

# Completar línea
curl -X POST "$BASE/api/routes/line/complete" -H "Content-Type: application/json" \
  -H "Cookie: $SESSION" \
  -d '{"line_id":943,"latitude":10.4900108,"longitude":-66.870626,"timestamp":"2026-07-20 19:55:00"}'

# Subir imagen
curl -X POST "$BASE/api/routes/line/upload-image" -H "Content-Type: application/json" \
  -H "Cookie: $SESSION" \
  -d '{"line_id":943,"image":"R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7","filename":"firma.jpg","notes":"OK","timestamp":"2026-07-20 19:55:00"}'

# Registrar FCM token
curl -X POST "$BASE/api/fcm/register" -H "Content-Type: application/json" \
  -H "Cookie: $SESSION" \
  -d '{"driver_id":20173,"token":"abc123","platform":"android","username":"rafaelpaez"}'

# Check nuevas rutas
curl "$BASE/api/routes/check-new?driver=rafaelpaez" -H "Cookie: $SESSION"

# Actualizar estado de ruta (HTTP - funciona)
curl -X PUT "$BASE/api/routes/903/set-state" -H "Content-Type: application/json" \
  -H "Cookie: $SESSION" \
  -d '{"state":"finished"}'
```
