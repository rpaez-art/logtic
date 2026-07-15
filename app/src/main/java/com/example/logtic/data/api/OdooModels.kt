package com.example.logtic.data.api

import com.google.gson.annotations.SerializedName

data class OdooConfig(
    val baseUrl: String = "https://etc-corpocrea.odoo.com",
    val apiKey: String = "",
    val database: String = "etc-corpocrea"
)

// Request/Response para autenticación
// El controller en producción espera 'username' y 'password'
data class LoginRequest(
    val username: String,
    val password: String
)

// FCM Push Notification
data class FcmTokenRequest(
    @SerializedName("driver_id") val driverId: Int,
    val token: String,
    val platform: String = "android",
    val username: String? = null
)

data class LoginResponse(
    val success: Boolean,
    val message: String? = null,
    val data: AuthData? = null
)

data class AuthData(
    val username: String = "",
    val uid: Int? = null,  // ID del usuario en Odoo
    @SerializedName("session_id")
    val sessionId: String? = null,
    @SerializedName("full_name")
    val fullName: String = "",
    val role: String = "driver",  // Valor por defecto
    @SerializedName("driver_code")
    val driverCode: String = "",
    @SerializedName("driver_id")
    val driverId: Int = 0,
    @SerializedName("driver_name")
    val driverName: String = ""
)

// Modelos de Ruta
data class RouteResponse(
    val success: Boolean,
    val message: String? = null,
    val data: List<RouteData>? = null
)

data class RouteData(
    val id: Int,
    val name: String,
    @SerializedName("driver_id")
    val driverId: DriverInfo? = null,
    val state: String,
    @SerializedName("max_priority")
    val maxPriority: String? = "low",
    val date: String,
    @SerializedName("start_date")
    val startDate: String? = null,
    @SerializedName("end_date")
    val endDate: String? = null,
    @SerializedName("route_lines")
    val routeLines: List<RouteLineData>
)

data class DriverInfo(
    val id: Int,
    val name: String
)

data class RouteLineData(
    val id: Int,
    @SerializedName("partner_id")
    val partnerId: PartnerInfo,
    val street: String?,
    val city: String?,
    val latitude: Double?,
    val longitude: Double?,
    val sequence: Int,
    val notes: String?,
    val obra: String?,
    val priority: String? = "low",
    val state: String,
    @SerializedName("scheduled_time")
    val scheduledTime: String?,
    @SerializedName("start_time")
    val startTime: String? = null,  // Fecha/hora real de inicio de esta tarea
    @SerializedName("pickup_time")
    val pickupTime: String? = null,  // Fecha/hora de recogida
    @SerializedName("end_time")
    val endTime: String? = null,  // Fecha/hora real de fin de esta tarea
    @SerializedName("order_type")
    val orderType: String? = null,  // 'sale', 'purchase' o null
    @SerializedName("order_name")
    val orderName: String? = null,  // Nombre del pedido
    @SerializedName("order_lines")
    val orderLines: List<OrderLineData>? = null,  // Lista de productos
    @SerializedName("attachments")
    val attachments: List<AttachmentData>? = null,  // Lista de archivos adjuntos
    @SerializedName("incomplete_reason")
    val incompleteReason: String? = null,
    @SerializedName("incomplete_notes")
    val incompleteNotes: String? = null
)

data class OrderLineData(
    @SerializedName("product_name")
    val productName: String,
    val quantity: Double,
    val uom: String,
    @SerializedName("price_unit")
    val priceUnit: Double
)

// ===== ARCHIVOS ADJUNTOS =====

data class AttachmentData(
    val id: Int,
    val name: String,
    val filename: String?,
    val mimetype: String?,
    @SerializedName("file_size")
    val fileSize: Long?,
    @SerializedName("create_date")
    val createDate: String?,
    @SerializedName("download_url")
    val downloadUrl: String? = null
) {
    // Helper para determinar el tipo de archivo
    fun isImage(): Boolean {
        return mimetype?.startsWith("image/") == true
    }
    
    fun isPdf(): Boolean {
        return mimetype == "application/pdf"
    }
    
    fun isDocument(): Boolean {
        val docMimes = listOf(
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "text/plain"
        )
        return mimetype in docMimes
    }
    
    // Helper para formatear el tamaño del archivo
    fun formattedFileSize(): String {
        val size = fileSize ?: return ""
        return when {
            size < 1024 -> "$size B"
            size < 1024 * 1024 -> "${size / 1024} KB"
            else -> String.format("%.1f MB", size / (1024.0 * 1024.0))
        }
    }
    
    // Helper para obtener la extensión del archivo
    fun getExtension(): String {
        return name.substringAfterLast('.', "").uppercase()
    }
}

// Response para obtener archivos adjuntos de una línea
data class LineAttachmentsResponse(
    val success: Boolean,
    val message: String? = null,
    val data: LineAttachmentsData? = null
)

data class LineAttachmentsData(
    @SerializedName("line_id")
    val lineId: Int,
    val attachments: List<AttachmentData>,
    val count: Int
)

// Response para descargar un archivo adjunto
data class AttachmentDownloadResponse(
    val success: Boolean,
    val message: String? = null,
    val data: AttachmentDownloadData? = null
)

data class AttachmentDownloadData(
    val id: Int,
    val name: String,
    val filename: String?,
    val mimetype: String?,
    @SerializedName("file_size")
    val fileSize: Long?,
    val datas: String?,  // Base64 encoded content
    @SerializedName("create_date")
    val createDate: String?
)

data class PartnerInfo(
    val id: Int,
    val name: String
)

// Request para actualizar estado
data class UpdateStateRequest(
    @SerializedName("line_id")
    val lineId: Int,
    val state: String,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val timestamp: String? = null
)

// Request para marcar línea como incompleta/parcial
data class IncompleteLineRequest(
    @SerializedName("line_id")
    val lineId: Int,
    val state: String,  // "incomplete" o "partial"
    val reason: String? = null,
    val notes: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val timestamp: String? = null
)

data class UpdateStateResponse(
    val success: Boolean,
    val message: String? = null
)

// Response genérica
data class ApiResponse<T>(
    val success: Boolean,
    val message: String? = null,
    val data: T? = null
)

// Request para subir imagen de entrega
data class UploadImageRequest(
    @SerializedName("line_id")
    val lineId: Int,
    val image: String,  // Base64 encoded image
    val filename: String,
    val notes: String? = null,
    val timestamp: String? = null
)

// Response para subir imagen
data class UploadImageResponse(
    val success: Boolean,
    val message: String? = null,
    val data: UploadImageData? = null
)

data class UploadImageData(
    @SerializedName("line_id")
    val lineId: Int,
    val filename: String,
    val timestamp: String?
)

// Response para obtener imagen
data class GetImageResponse(
    val success: Boolean,
    val message: String? = null,
    val data: ImageData? = null
)

data class ImageData(
    @SerializedName("line_id")
    val lineId: Int,
    val image: String,  // Base64 encoded image
    val filename: String?,
    val timestamp: String?,
    val notes: String?
)

// ===== ESTADÍSTICAS DEL CONDUCTOR =====

data class DriverStatsResponse(
    val success: Boolean,
    val message: String? = null,
    val data: DriverStatsData? = null
)

data class DriverStatsData(
    val driver: DriverProfile,
    val period: String,
    val summary: StatsSummary,
    val performance: PerformanceStats,
    val today: TodayStats
)

data class DriverProfile(
    val id: Int,
    val name: String,
    val image: String?  // Base64 encoded image
)

data class StatsSummary(
    @SerializedName("total_routes")
    val totalRoutes: Int,
    @SerializedName("completed_routes")
    val completedRoutes: Int,
    @SerializedName("in_progress_routes")
    val inProgressRoutes: Int,
    @SerializedName("pending_routes")
    val pendingRoutes: Int,
    @SerializedName("total_deliveries")
    val totalDeliveries: Int,
    @SerializedName("completed_deliveries")
    val completedDeliveries: Int,
    @SerializedName("pending_deliveries")
    val pendingDeliveries: Int,
    @SerializedName("in_progress_deliveries")
    val inProgressDeliveries: Int,
    @SerializedName("completion_rate")
    val completionRate: Double
)

data class PerformanceStats(
    @SerializedName("avg_delivery_time_minutes")
    val avgDeliveryTimeMinutes: Double,
    @SerializedName("avg_route_time_minutes")
    val avgRouteTimeMinutes: Double,
    @SerializedName("avg_delivery_time_formatted")
    val avgDeliveryTimeFormatted: String,
    @SerializedName("avg_route_time_formatted")
    val avgRouteTimeFormatted: String
)

data class TodayStats(
    val total: Int,
    val completed: Int,
    val pending: Int,
    @SerializedName("in_progress")
    val inProgress: Int
)

// ===== HISTORIAL DE RUTAS =====

data class RoutesHistoryResponse(
    val success: Boolean,
    val message: String? = null,
    val data: List<RouteHistoryItem>? = null,
    val pagination: PaginationInfo? = null
)

data class RouteHistoryItem(
    val id: Int,
    val name: String,
    val date: String,
    @SerializedName("start_date")
    val startDate: String?,
    @SerializedName("end_date")
    val endDate: String?,
    @SerializedName("duration_minutes")
    val durationMinutes: Double,
    @SerializedName("duration_formatted")
    val durationFormatted: String,
    @SerializedName("total_deliveries")
    val totalDeliveries: Int,
    @SerializedName("completed_deliveries")
    val completedDeliveries: Int
)

data class PaginationInfo(
    val total: Int,
    val limit: Int,
    val offset: Int,
    @SerializedName("has_more")
    val hasMore: Boolean
)

// ===== VERIFICACIÓN DE RUTAS NUEVAS (para notificaciones) =====

data class CheckNewRoutesResponse(
    val success: Boolean,
    val message: String? = null,
    val data: CheckNewRoutesData? = null
)

data class CheckNewRoutesData(
    @SerializedName("has_new")
    val hasNew: Boolean,
    @SerializedName("new_count")
    val newCount: Int,
    @SerializedName("total_pending")
    val totalPending: Int,
    @SerializedName("route_names")
    val routeNames: List<String>,
    @SerializedName("checked_at")
    val checkedAt: String
)

