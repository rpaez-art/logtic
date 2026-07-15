package com.example.logtic.data.api

import retrofit2.Response
import retrofit2.http.*

/**
 * API Service para conectar con Odoo a través de endpoints REST
 * Requiere un módulo de controller en Odoo que exponga estos endpoints
 */
interface OdooApiService {
    
    /**
     * POST /api/auth/login
     * Autenticar usuario en Odoo
     */
    @POST("api/auth/login")
    suspend fun login(@Body request: LoginRequest): Response<LoginResponse>
    
    /**
     * GET /api/routes/driver/{username}
     * Obtener rutas asignadas a un conductor específico
     */
    @GET("api/routes/driver/{username}")
    suspend fun getRoutesByDriver(
        @Path("username") username: String,
        @Query("date") date: String? = null
    ): Response<RouteResponse>
    
    /**
     * GET /api/routes/{route_id}
     * Obtener detalles de una ruta específica con sus líneas
     */
    @GET("api/routes/{route_id}")
    suspend fun getRouteDetails(
        @Path("route_id") routeId: Int
    ): Response<ApiResponse<RouteData>>
    
    /**
     * POST /api/routes/line/start
     * Iniciar una línea de ruta
     */
    @POST("api/routes/line/start")
    suspend fun startRouteLine(
        @Body request: UpdateStateRequest
    ): Response<UpdateStateResponse>
    
    /**
     * POST /api/routes/line/pickup
     * Marcar una línea como recogida
     */
    @POST("api/routes/line/pickup")
    suspend fun pickupRouteLine(
        @Body request: UpdateStateRequest
    ): Response<UpdateStateResponse>
    
    /**
     * POST /api/routes/line/complete
     * Completar una línea de ruta
     */
    @POST("api/routes/line/complete")
    suspend fun completeRouteLine(
        @Body request: UpdateStateRequest
    ): Response<UpdateStateResponse>

    /**
     * POST /api/routes/line/incomplete
     * Marcar línea como incompleta o parcial con motivo
     */
    @POST("api/routes/line/incomplete")
    suspend fun markLineIncomplete(
        @Body request: IncompleteLineRequest
    ): Response<UpdateStateResponse>
    
    /**
     * PUT /api/routes/{route_id}/state
     * Actualizar estado de toda la ruta
     */
    @PUT("api/routes/{route_id}/state")
    suspend fun updateRouteState(
        @Path("route_id") routeId: Int,
        @Body state: Map<String, String>
    ): Response<UpdateStateResponse>
    
    /**
     * GET /api/routes/sync
     * Sincronizar todas las rutas del día actual
     */
    @GET("api/routes/sync")
    suspend fun syncTodayRoutes(
        @Query("driver") driver: String? = null
    ): Response<RouteResponse>
    
    /**
     * POST /api/routes/line/upload-image
     * Subir imagen de entrega/finalización
     */
    @POST("api/routes/line/upload-image")
    suspend fun uploadLineImage(
        @Body request: UploadImageRequest
    ): Response<UploadImageResponse>
    
    /**
     * GET /api/routes/line/{line_id}/image
     * Obtener imagen de entrega de una línea
     */
    @GET("api/routes/line/{line_id}/image")
    suspend fun getLineImage(
        @Path("line_id") lineId: Int
    ): Response<GetImageResponse>
    
    /**
     * GET /api/driver/stats
     * Obtener estadísticas del conductor
     */
    @GET("api/driver/stats")
    suspend fun getDriverStats(
        @Query("driver") driver: String,
        @Query("period") period: String = "today"  // today, week, month, all
    ): Response<DriverStatsResponse>
    
    /**
     * GET /api/routes/history
     * Obtener historial de rutas completadas
     */
    @GET("api/routes/history")
    suspend fun getRoutesHistory(
        @Query("driver") driver: String,
        @Query("limit") limit: Int = 20,
        @Query("offset") offset: Int = 0
    ): Response<RoutesHistoryResponse>
    
    /**
     * GET /api/routes/check-new
     * Verificar si hay rutas nuevas asignadas (endpoint ligero para notificaciones)
     */
    @GET("api/routes/check-new")
    suspend fun checkNewRoutes(
        @Query("driver") driver: String,
        @Query("since") since: String? = null
    ): Response<CheckNewRoutesResponse>
    
    /**
     * GET /api/routes/line/{line_id}/attachments
     * Obtener archivos adjuntos de una línea de ruta
     */
    @GET("api/routes/line/{line_id}/attachments")
    suspend fun getLineAttachments(
        @Path("line_id") lineId: Int
    ): Response<LineAttachmentsResponse>
    
    /**
     * GET /api/attachment/{attachment_id}
     * Obtener/descargar un archivo adjunto específico
     * @param format: "base64" (default) o "download"
     */
    @GET("api/attachment/{attachment_id}")
    suspend fun getAttachment(
        @Path("attachment_id") attachmentId: Int,
        @Query("format") format: String = "base64"
    ): Response<AttachmentDownloadResponse>
    
    /**
     * POST /api/fcm/register
     * Registrar token FCM del dispositivo para recibir push notifications
     */
    @POST("api/fcm/register")
    fun registerFcmToken(@Body request: FcmTokenRequest): retrofit2.Call<Map<String, Any>>
}

