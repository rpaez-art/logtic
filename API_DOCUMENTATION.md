# API Documentation - LogTic

> Documentación de los endpoints de la API REST de Odoo utilizados por LogTic.
> Base URL: `https://etc-corpocrea.odoo.com/`

---

## Autenticación

### `POST /api/auth/login`
Iniciar sesión y obtener sesión de Odoo.

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response (`LoginResponse`):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "username": "string",
    "uid": 123,
    "session_id": "string",
    "full_name": "Nombre Completo",
    "role": "driver | admin",
    "driver_code": "COD001",
    "driver_id": 1,
    "driver_name": "Nombre Conductor"
  }
}
```

---

## Rutas / Entregas

### `GET /api/routes/sync?driver={driver_id}`
Obtener las rutas activas/hoy del conductor (incluye líneas, productos, adjuntos).

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| driver | string | ID del conductor |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "name": "RUTA-001",
      "driver_id": {
        "id": 1,
        "name": "Conductor"
      },
      "state": "started | finished | draft",
      "max_priority": "normal | urgent",
      "date": "2026-07-16",
      "start_date": "2026-07-16 08:00:00",
      "end_date": "2026-07-16 17:00:00",
      "route_lines": [
        {
          "id": 456,
          "partner_id": { "id": 789, "name": "Cliente XYZ" },
          "street": "Av. Principal 123",
          "city": "Caracas",
          "latitude": 10.4806,
          "longitude": -66.9036,
          "sequence": 1,
          "notes": "Notas <b>HTML</b>",
          "obra": "Edificio Central",
          "priority": "normal | urgent",
          "state": "pending | in_progress | picked_up | done | incomplete | partial | cancelled",
          "scheduled_time": "2026-07-16 09:00:00",
          "start_time": "2026-07-16 08:30:00",
          "pickup_time": "2026-07-16 09:15:00",
          "end_time": "2026-07-16 09:45:00",
          "order_type": "sale | transfer",
          "order_name": "PED-001",
          "order_lines": [
            {
              "product_name": "Producto A",
              "quantity": 5,
              "uom": "unidades",
              "price_unit": 100.00
            }
          ],
          "attachments": [
            {
              "id": 999,
              "name": "Documento.pdf",
              "filename": "doc.pdf",
              "mimetype": "application/pdf",
              "file_size": 102400,
              "create_date": "2026-07-16 10:00:00",
              "download_url": "https://etc-corpocrea.odoo.com/..."
            }
          ],
          "incomplete_reason": "Falta firma",
          "incomplete_notes": "Cliente no estaba presente"
        }
      ]
    }
  ]
}
```

### `GET /api/routes/driver?driver={driver_id}`
Obtener rutas activas de un conductor (similar a sync, formato alternativo).

### `POST /api/routes/line/start`
Iniciar una línea de ruta (marcar como `in_progress`).

**Request Body:**
```json
{
  "line_id": 456,
  "state": "in_progress",
  "latitude": 10.4806,
  "longitude": -66.9036,
  "timestamp": "2026-07-16 08:30:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Línea iniciada"
}
```

### `POST /api/routes/line/pickup`
Marcar línea como recogida (`picked_up`).

**Request Body:**
```json
{
  "line_id": 456,
  "state": "picked_up",
  "latitude": 10.4806,
  "longitude": -66.9036,
  "timestamp": "2026-07-16 09:15:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Recogida registrada"
}
```

### `POST /api/routes/line/complete`
Completar línea de ruta (`done`).

**Request Body:**
```json
{
  "line_id": 456,
  "state": "done",
  "latitude": 10.4806,
  "longitude": -66.9036,
  "timestamp": "2026-07-16 09:45:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Línea completada"
}
```

### `POST /api/routes/line/incomplete`
Marcar línea como incompleta o parcial.

**Request Body:**
```json
{
  "line_id": 456,
  "state": "incomplete | partial",
  "reason": "Firma pendiente",
  "notes": "Cliente no disponible",
  "latitude": 10.4806,
  "longitude": -66.9036,
  "timestamp": "2026-07-16 09:45:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Línea marcada como incompleta"
}
```

### `POST /api/routes/line/upload-image`
Subir imagen como evidencia de entrega.

**Request Body:**
```json
{
  "line_id": 456,
  "image": "base64_encoded_image_data",
  "filename": "delivery_456_1234567890.jpg",
  "notes": "Foto de entrega",
  "timestamp": "2026-07-16 09:45:00"
}
```

**Response (`UploadImageResponse`):**
```json
{
  "success": true,
  "message": "Imagen subida",
  "data": {
    "line_id": 456,
    "filename": "delivery_456_1234567890.jpg",
    "timestamp": "2026-07-16 09:45:00"
  }
}
```

### `POST /api/routes/state`
Actualizar estado general de la ruta (no línea individual).

**Request Body:**
```json
{
  "route_id": 123,
  "state": "started | finished"
}
```

### `GET /api/routes/line/attachments/{lineId}`
Obtener adjuntos de una línea específica.

**Response (`LineAttachmentsResponse`):**
```json
{
  "success": true,
  "message": null,
  "data": {
    "line_id": 456,
    "count": 2,
    "attachments": [
      {
        "id": 999,
        "name": "Documento.pdf",
        "filename": "doc.pdf",
        "mimetype": "application/pdf",
        "file_size": 102400,
        "create_date": "2026-07-16 10:00:00",
        "download_url": "https://etc-corpocrea.odoo.com/..."
      }
    ]
  }
}
```

### `GET /api/attachment/{id}`
Descargar un attachment específico por su ID (binary file stream).

---

## Historial

### `GET /api/routes/history?driver={driver_id}&limit={n}&offset={n}`
Obtener historial de rutas del conductor.

**Query Params:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| driver | string | — | ID del conductor |
| limit | int | 20 | Cantidad máxima de resultados |
| offset | int | 0 | Paginación |

**Response (`RoutesHistoryResponse`):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "name": "RUTA-001",
      "date": "2026-07-16",
      "start_date": "2026-07-16 08:00:00",
      "end_date": "2026-07-16 17:00:00",
      "duration_minutes": 540.0,
      "duration_formatted": "9h 0m",
      "total_deliveries": 10,
      "completed_deliveries": 10,
      "lines": null
    }
  ],
  "pagination": {
    "total": 50,
    "limit": 20,
    "offset": 0,
    "has_more": true
  }
}
```

> **Nota:** `lines` viene `null` en la lista resumen. Se cargan bajo demanda con el endpoint de detalle.

### `GET /api/routes/{routeId}`
Obtener detalle completo de una ruta histórica (incluye líneas con productos y adjuntos).

**Response (`RouteHistoryLinesResponse`):**
```json
{
  "success": true,
  "message": null,
  "data": {
    "route_lines": [
      {
        "id": 456,
        "partner_id": { "id": 789, "name": "Cliente XYZ" },
        "street": "Av. Principal 123",
        "city": "Caracas",
        "latitude": 10.4806,
        "longitude": -66.9036,
        "sequence": 1,
        "notes": "Notas",
        "obra": "Edificio Central",
        "priority": "normal",
        "state": "done",
        "start_time": "2026-07-16 08:30:00",
        "pickup_time": null,
        "end_time": "2026-07-16 09:45:00",
        "order_type": "sale",
        "order_name": "PED-001",
        "order_lines": [],
        "attachments": [],
        "incomplete_reason": null,
        "incomplete_notes": null
      }
    ]
  }
}
```

---

## Estadísticas

### `GET /api/driver/stats?driver={driver_id}&period={period}`
Obtener estadísticas del conductor.

**Query Params:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| driver | string | — | ID del conductor |
| period | string | today | `today`, `week`, `month`, `all` |

**Response (`DriverStatsResponse`):**
```json
{
  "success": true,
  "data": {
    "driver": {
      "id": 1,
      "name": "Conductor",
      "image": "base64_encoded_image"
    },
    "period": "today",
    "summary": {
      "total_routes": 5,
      "completed_routes": 3,
      "in_progress_routes": 1,
      "pending_routes": 1,
      "total_deliveries": 20,
      "completed_deliveries": 12,
      "pending_deliveries": 6,
      "in_progress_deliveries": 2,
      "completion_rate": 60.0
    },
    "performance": {
      "avg_delivery_time_minutes": 15.5,
      "avg_route_time_minutes": 120.0,
      "avg_delivery_time_formatted": "15m 30s",
      "avg_route_time_formatted": "2h 0m"
    },
    "today": {
      "total": 10,
      "completed": 6,
      "pending": 3,
      "in_progress": 1
    }
  }
}
```

---

## Notificaciones

### `GET /api/routes/check-new?driver={driver_id}&since={datetime}`
Verificar si hay nuevas rutas asignadas desde la última comprobación.

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| driver | string | ID del conductor |
| since | string | (opcional) Fecha/hora desde cuándo revisar |

**Response (`CheckNewRoutesResponse`):**
```json
{
  "success": true,
  "data": {
    "has_new": true,
    "new_count": 2,
    "total_pending": 5,
    "route_names": ["RUTA-002", "RUTA-003"],
    "checked_at": "2026-07-16 10:00:00"
  }
}
```

### `POST /api/fcm/register`
Registrar token FCM para notificaciones push.

**Request Body:**
```json
{
  "driver_id": 1,
  "token": "fcm_token_device",
  "platform": "android | ios",
  "username": "conductor_username"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Token registrado"
}
```

---

## Resumen de endpoints

| Método | Endpoint | Propósito |
|--------|----------|-----------|
| POST | `/api/auth/login` | Iniciar sesión |
| GET | `/api/routes/sync` | Sincronizar rutas activas (con líneas, productos y adjuntos) |
| GET | `/api/routes/driver` | Obtener rutas activas (alternativo) |
| POST | `/api/routes/line/start` | Iniciar una entrega |
| POST | `/api/routes/line/pickup` | Marcar recogida |
| POST | `/api/routes/line/complete` | Completar entrega |
| POST | `/api/routes/line/incomplete` | Marcar como incompleta/parcial |
| POST | `/api/routes/line/upload-image` | Subir foto de evidencia |
| POST | `/api/routes/state` | Actualizar estado de la ruta |
| GET | `/api/routes/line/attachments/{lineId}` | Obtener adjuntos de una línea |
| GET | `/api/attachment/{id}` | Descargar archivo adjunto |
| GET | `/api/routes/history` | Historial de rutas (resumen) |
| GET | `/api/routes/{routeId}` | Detalle de ruta histórica (líneas completas) |
| GET | `/api/driver/stats` | Estadísticas del conductor |
| GET | `/api/routes/check-new` | Verificar nuevas rutas |
| POST | `/api/fcm/register` | Registrar token FCM |