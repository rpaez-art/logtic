package com.example.logtic.viewmodel

import android.util.Log
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.logtic.data.Route
import com.example.logtic.data.RouteStatus
import com.example.logtic.data.api.*
import kotlinx.coroutines.launch
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class OdooViewModel : ViewModel() {
    // URL de Odoo pre-configurada
    private val ODOO_URL = "https://etc-corpocrea.odoo.com/"
    
    var isConnected = mutableStateOf(false)
        private set
    
    var isLoading = mutableStateOf(false)
        private set
    
    var errorMessage = mutableStateOf("")
        private set
    
    var lastSyncTime = mutableStateOf("")
        private set
    
    // Debug info visible en la UI
    var debugInfo = mutableStateOf("")
        private set
    
    var lastRequest = mutableStateOf("")
        private set
    
    var lastResponse = mutableStateOf("")
        private set
    
    // Rutas de Odoo (RouteData completo con sus líneas)
    var odooRoutes = mutableStateOf<List<RouteData>>(emptyList())
        private set
    
    // Estado para upload de imagen
    var isUploadingImage = mutableStateOf(false)
        private set
    
    var uploadImageError = mutableStateOf("")
        private set
    
    var uploadImageSuccess = mutableStateOf(false)
        private set
    
    // Estado para estadísticas del conductor
    var driverStats = mutableStateOf<DriverStatsData?>(null)
        private set
    
    var isLoadingStats = mutableStateOf(false)
        private set
    
    var statsError = mutableStateOf("")
        private set
    
    // Historial de rutas
    var routesHistory = mutableStateOf<List<RouteHistoryItem>>(emptyList())
        private set
    
    var isLoadingHistory = mutableStateOf(false)
        private set
    
    // Estado para descarga de archivos adjuntos
    var isDownloadingAttachment = mutableStateOf(false)
        private set
    
    var downloadError = mutableStateOf("")
        private set
    
    private val apiService: OdooApiService
    
    init {
        // Inicializar el servicio con la URL pre-configurada
        apiService = RetrofitClient.getApiService(ODOO_URL)
        Log.d("OdooViewModel", "Inicializado con URL: $ODOO_URL")
        debugInfo.value = "Inicializado\nURL: $ODOO_URL"
    }
    
    
    /**
     * Sincronizar rutas desde Odoo
     * @param driverId ID del conductor (res.partner) vinculado al usuario
     */
    fun syncRoutesFromOdoo(driverId: Int? = null, onResult: (List<Route>) -> Unit) {
        Log.d("OdooViewModel", "=== INICIANDO SINCRONIZACIÓN ===")
        Log.d("OdooViewModel", "URL: $ODOO_URL")
        Log.d("OdooViewModel", "Driver ID recibido: $driverId")
        
        // Validar que el driver_id sea válido (mayor que 0)
        if (driverId == null || driverId <= 0) {
            Log.w("OdooViewModel", "Driver ID no válido: $driverId - No se puede sincronizar")
            errorMessage.value = "Usuario sin conductor asignado (driver_id: $driverId)"
            isConnected.value = false
            isLoading.value = false
            onResult(emptyList())
            return
        }
        
        val url = "${ODOO_URL}api/routes/sync?driver=$driverId"
        
        lastRequest.value = "GET $url\nMétodo: GET\nTimestamp: ${LocalDateTime.now()}"
        debugInfo.value = "Enviando request...\n${lastRequest.value}"
        
        isLoading.value = true
        errorMessage.value = ""
        
        viewModelScope.launch {
            try {
                Log.d("OdooViewModel", "Llamando a /api/routes/sync con driver=$driverId")
                
                // Pasar el driver_id como string
                val response = apiService.syncTodayRoutes(driver = driverId.toString())
                
                Log.d("OdooViewModel", "Respuesta recibida - Código: ${response.code()}")
                Log.d("OdooViewModel", "Respuesta exitosa: ${response.isSuccessful}")
                
                val responseBody = response.body()
                val rawResponse = """
                    |HTTP ${response.code()} ${response.message()}
                    |Headers: ${response.headers()}
                    |Body: ${responseBody}
                    |Success: ${responseBody?.success}
                    |Message: ${responseBody?.message ?: "N/A"}
                    |Data count: ${responseBody?.data?.size ?: 0}
                """.trimMargin()
                
                lastResponse.value = rawResponse
                Log.d("OdooViewModel", "Body completo: $responseBody")
                
                debugInfo.value = """
                    |REQUEST:
                    |${lastRequest.value}
                    |
                    |RESPONSE:
                    |$rawResponse
                """.trimMargin()
                
                if (response.isSuccessful && response.body()?.success == true) {
                    val routeDataList = response.body()?.data ?: emptyList()
                    Log.d("OdooViewModel", "Rutas recibidas: ${routeDataList.size}")
                    
                    // Limpiar mensaje de error previo - la sincronización fue exitosa
                    errorMessage.value = ""
                    
                    // Guardar las rutas completas de Odoo
                    odooRoutes.value = routeDataList
                    
                    val routes = mutableListOf<Route>()
                    
                    for (routeData in routeDataList) {
                        Log.d("OdooViewModel", "Procesando ruta: ${routeData.name}, Líneas: ${routeData.routeLines.size}")
                        
                        for (line in routeData.routeLines) {
                            val status = when (line.state) {
                                "done" -> RouteStatus.COMPLETED
                                "in_progress" -> RouteStatus.IN_PROGRESS
                                else -> RouteStatus.PENDING
                            }
                            
                            routes.add(
                                Route(
                                    id = line.id,
                                    clientName = line.partnerId.name,
                                    address = line.street ?: "",
                                    city = line.city ?: "",
                                    scheduledTime = line.scheduledTime ?: "${line.sequence}° Parada",
                                    status = status,
                                    latitude = line.latitude ?: 0.0,
                                    longitude = line.longitude ?: 0.0,
                                    description = line.notes ?: "",
                                    startTime = line.startTime,  // Fecha de inicio de esta tarea
                                    endTime = line.endTime,  // Fecha de fin de esta tarea
                                    assignedDriver = routeData.driverId?.name ?: "",
                                    odooRouteId = routeData.id,
                                    odooLineId = line.id,
                                    sequence = line.sequence
                                )
                            )
                        }
                    }
                    
                    Log.d("OdooViewModel", "Total de paradas procesadas: ${routes.size}")
                    lastSyncTime.value = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"))
                    isLoading.value = false
                    isConnected.value = true
                    
                    debugInfo.value += "\n\n✅ ${routes.size} rutas cargadas"
                    
                    onResult(routes.sortedBy { it.sequence })
                } else if (response.isSuccessful) {
                    // El servidor respondió pero con success=false
                    // Aún así marcamos como conectado porque hay comunicación con el servidor
                    val error = response.body()?.message ?: "Sin rutas disponibles"
                    Log.w("OdooViewModel", "Respuesta del servidor: $error")
                    
                    // Si el error es de serialización, es un bug del servidor pero hay conexión
                    isConnected.value = true
                    lastSyncTime.value = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"))
                    errorMessage.value = if (error.contains("serializable")) {
                        "Error en servidor Odoo. Contacte al administrador."
                    } else {
                        error
                    }
                    isLoading.value = false
                    
                    debugInfo.value += "\n\n⚠️ Conectado pero: $error"
                    
                    onResult(emptyList())
                } else {
                    val error = response.body()?.message ?: "Error HTTP ${response.code()}: ${response.message()}"
                    Log.e("OdooViewModel", "Error en respuesta: $error")
                    errorMessage.value = error
                    isLoading.value = false
                    isConnected.value = false
                    
                    debugInfo.value += "\n\n❌ ERROR: $error"
                    
                    onResult(emptyList())
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "EXCEPCIÓN en sincronización", e)
                Log.e("OdooViewModel", "Mensaje: ${e.message}")
                Log.e("OdooViewModel", "Stack trace: ${e.stackTraceToString()}")
                
                val errorDetail = """
                    |❌ EXCEPCIÓN:
                    |Tipo: ${e.javaClass.simpleName}
                    |Mensaje: ${e.message}
                    |Causa: ${e.cause?.message ?: "N/A"}
                """.trimMargin()
                
                errorMessage.value = "Error: ${e.message}"
                debugInfo.value += "\n\n$errorDetail"
                lastResponse.value = errorDetail
                
                isLoading.value = false
                onResult(emptyList())
            }
        }
    }
    
    fun notifyRouteStarted(odooLineId: Int?, latitude: Double? = null, longitude: Double? = null) {
        if (odooLineId == null) return
        
        viewModelScope.launch {
            try {
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val request = UpdateStateRequest(
                    lineId = odooLineId,
                    state = "in_progress",
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                val response = apiService.startRouteLine(request)
                
                if (!response.isSuccessful) {
                    Log.e("OdooViewModel", "Error iniciando ruta: ${response.message()}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Error notificando inicio: ${e.message}", e)
            }
        }
    }
    
    fun notifyRouteCompleted(odooLineId: Int?, latitude: Double? = null, longitude: Double? = null) {
        if (odooLineId == null) return
        
        viewModelScope.launch {
            try {
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val request = UpdateStateRequest(
                    lineId = odooLineId,
                    state = "done",
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                val response = apiService.completeRouteLine(request)
                
                if (!response.isSuccessful) {
                    Log.e("OdooViewModel", "Error completando ruta: ${response.message()}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Error notificando fin: ${e.message}", e)
            }
        }
    }
    
    fun notifyLineStarted(lineId: Int, latitude: Double? = null, longitude: Double? = null) {
        viewModelScope.launch {
            try {
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val request = UpdateStateRequest(
                    lineId = lineId,
                    state = "in_progress",
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                Log.d("OdooViewModel", "Iniciando línea $lineId")
                val response = apiService.startRouteLine(request)
                
                if (response.isSuccessful) {
                    Log.d("OdooViewModel", "Línea iniciada exitosamente")
                    // Actualizar estado local
                    updateLineStateLocally(lineId, "in_progress", timestamp)
                } else {
                    Log.e("OdooViewModel", "Error iniciando línea: ${response.message()}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Error notificando inicio de línea: ${e.message}", e)
            }
        }
    }
    
    fun notifyLinePickedUp(lineId: Int, latitude: Double? = null, longitude: Double? = null) {
        viewModelScope.launch {
            try {
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val request = UpdateStateRequest(
                    lineId = lineId,
                    state = "picked_up",
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                Log.d("OdooViewModel", "Marcando línea $lineId como recogida")
                val response = apiService.pickupRouteLine(request)
                
                if (response.isSuccessful) {
                    Log.d("OdooViewModel", "Línea marcada como recogida exitosamente")
                    // Actualizar estado local
                    updateLineStateLocally(lineId, "picked_up", timestamp, isPickup = true)
                } else {
                    Log.e("OdooViewModel", "Error marcando recogida: ${response.message()}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Error notificando recogida de línea: ${e.message}", e)
            }
        }
    }
    
    fun notifyLineCompleted(lineId: Int, latitude: Double? = null, longitude: Double? = null) {
        viewModelScope.launch {
            try {
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val request = UpdateStateRequest(
                    lineId = lineId,
                    state = "done",
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                Log.d("OdooViewModel", "Completando línea $lineId")
                val response = apiService.completeRouteLine(request)
                
                if (response.isSuccessful) {
                    Log.d("OdooViewModel", "Línea completada exitosamente")
                    // Actualizar estado local
                    updateLineStateLocally(lineId, "done", timestamp)
                } else {
                    Log.e("OdooViewModel", "Error completando línea: ${response.message()}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Error notificando fin de línea: ${e.message}", e)
            }
        }
    }
    
    fun notifyLineIncomplete(
        lineId: Int,
        incompleteState: String,  // "incomplete" or "partial"
        reason: String,
        notes: String,
        latitude: Double? = null,
        longitude: Double? = null
    ) {
        viewModelScope.launch {
            try {
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val request = IncompleteLineRequest(
                    lineId = lineId,
                    state = incompleteState,
                    reason = reason,
                    notes = notes,
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                Log.d("OdooViewModel", "Marcando línea $lineId como $incompleteState")
                val response = apiService.markLineIncomplete(request)
                
                if (response.isSuccessful) {
                    Log.d("OdooViewModel", "Línea marcada como $incompleteState")
                    updateLineStateLocally(lineId, incompleteState, timestamp,
                        incompleteReason = reason, incompleteNotes = notes)
                } else {
                    Log.e("OdooViewModel", "Error marcando línea incompleta: ${response.message()}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Error notificando línea incompleta: ${e.message}", e)
            }
        }
    }
    
    private fun updateLineStateLocally(
        lineId: Int,
        newState: String,
        timestamp: String,
        isPickup: Boolean = false,
        incompleteReason: String? = null,
        incompleteNotes: String? = null
    ) {
        val updatedRoutes = odooRoutes.value.map { route ->
            var routeUpdated = false
            val updatedLines = route.routeLines.map { line ->
                if (line.id == lineId) {
                    routeUpdated = true
                    when {
                        newState == "in_progress" -> line.copy(state = newState, startTime = timestamp)
                        isPickup && newState == "picked_up" -> line.copy(state = newState, pickupTime = timestamp)
                        newState == "done" -> line.copy(state = newState, endTime = timestamp)
                        newState in listOf("incomplete", "partial") -> line.copy(
                            state = newState,
                            endTime = timestamp,
                            incompleteReason = incompleteReason,
                            incompleteNotes = incompleteNotes
                        )
                        else -> line.copy(state = newState)
                    }
                } else {
                    line
                }
            }
            
            // Si actualizamos una línea, también actualizar la ruta
            if (routeUpdated) {
                when (newState) {
                    "in_progress" -> {
                        // Si es la primera línea que se inicia, actualizar start_date de la ruta
                        val hasOtherStarted = updatedLines.any { it.id != lineId && it.state == "in_progress" }
                        if (!hasOtherStarted && route.startDate.isNullOrEmpty()) {
                            route.copy(routeLines = updatedLines, startDate = timestamp, state = "started")
                        } else {
                            route.copy(routeLines = updatedLines, state = "started")
                        }
                    }
                    "done", "incomplete", "partial" -> {
                        // Si todas están terminadas (done/cancelled/incomplete/partial), finalizar ruta
                        val allDone = updatedLines.all { it.state in listOf("done", "cancelled", "incomplete", "partial") }
                        if (allDone) {
                            route.copy(routeLines = updatedLines, endDate = timestamp, state = "finished")
                        } else {
                            route.copy(routeLines = updatedLines)
                        }
                    }
                    else -> route.copy(routeLines = updatedLines)
                }
            } else {
                route.copy(routeLines = updatedLines)
            }
        }
        odooRoutes.value = updatedRoutes
    }
    
    /**
     * Subir imagen de entrega para una línea de ruta
     */
    fun uploadLineImage(
        lineId: Int, 
        imageBase64: String, 
        notes: String? = null,
        onSuccess: () -> Unit = {},
        onError: (String) -> Unit = {}
    ) {
        viewModelScope.launch {
            try {
                isUploadingImage.value = true
                uploadImageError.value = ""
                uploadImageSuccess.value = false
                
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val filename = "delivery_${lineId}_${System.currentTimeMillis()}.jpg"
                
                val request = UploadImageRequest(
                    lineId = lineId,
                    image = imageBase64,
                    filename = filename,
                    notes = notes,
                    timestamp = timestamp
                )
                
                Log.d("OdooViewModel", "Subiendo imagen para línea $lineId")
                val response = apiService.uploadLineImage(request)
                
                if (response.isSuccessful && response.body()?.success == true) {
                    Log.d("OdooViewModel", "Imagen subida exitosamente")
                    uploadImageSuccess.value = true
                    isUploadingImage.value = false
                    onSuccess()
                } else {
                    val error = response.body()?.message ?: "Error al subir imagen"
                    Log.e("OdooViewModel", "Error subiendo imagen: $error")
                    uploadImageError.value = error
                    isUploadingImage.value = false
                    onError(error)
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Excepción subiendo imagen: ${e.message}", e)
                uploadImageError.value = e.message ?: "Error desconocido"
                isUploadingImage.value = false
                onError(e.message ?: "Error desconocido")
            }
        }
    }
    
    /**
     * Completar línea con imagen adjunta
     */
    fun completeLineWithImage(
        lineId: Int,
        imageBase64: String,
        latitude: Double? = null,
        longitude: Double? = null,
        notes: String? = null,
        onComplete: (Boolean) -> Unit = {}
    ) {
        viewModelScope.launch {
            try {
                isUploadingImage.value = true
                
                // Primero subir la imagen
                val timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                
                val filename = "delivery_${lineId}_${System.currentTimeMillis()}.jpg"
                
                val uploadRequest = UploadImageRequest(
                    lineId = lineId,
                    image = imageBase64,
                    filename = filename,
                    notes = notes,
                    timestamp = timestamp
                )
                
                Log.d("OdooViewModel", "Subiendo imagen antes de completar línea $lineId")
                val uploadResponse = apiService.uploadLineImage(uploadRequest)
                
                if (!uploadResponse.isSuccessful || uploadResponse.body()?.success != true) {
                    val error = uploadResponse.body()?.message ?: "Error al subir imagen"
                    Log.e("OdooViewModel", "Error subiendo imagen: $error")
                    uploadImageError.value = error
                    isUploadingImage.value = false
                    onComplete(false)
                    return@launch
                }
                
                Log.d("OdooViewModel", "Imagen subida, ahora completando línea")
                
                // Luego completar la línea
                val completeRequest = UpdateStateRequest(
                    lineId = lineId,
                    state = "done",
                    latitude = latitude,
                    longitude = longitude,
                    timestamp = timestamp
                )
                
                val completeResponse = apiService.completeRouteLine(completeRequest)
                
                if (completeResponse.isSuccessful) {
                    Log.d("OdooViewModel", "Línea completada exitosamente con imagen")
                    updateLineStateLocally(lineId, "done", timestamp)
                    uploadImageSuccess.value = true
                    isUploadingImage.value = false
                    onComplete(true)
                } else {
                    Log.e("OdooViewModel", "Error completando línea: ${completeResponse.message()}")
                    uploadImageError.value = "Imagen subida pero error al completar línea"
                    isUploadingImage.value = false
                    onComplete(false)
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Excepción: ${e.message}", e)
                uploadImageError.value = e.message ?: "Error desconocido"
                isUploadingImage.value = false
                onComplete(false)
            }
        }
    }
    
    /**
     * Limpiar estado de upload de imagen
     */
    fun clearUploadState() {
        uploadImageError.value = ""
        uploadImageSuccess.value = false
        isUploadingImage.value = false
    }
    
    /**
     * Obtener estadísticas del conductor
     */
    fun fetchDriverStats(driverId: Int, period: String = "today") {
        viewModelScope.launch {
            try {
                isLoadingStats.value = true
                statsError.value = ""
                
                Log.d("OdooViewModel", "Obteniendo estadísticas para driver $driverId, período: $period")
                val response = apiService.getDriverStats(driverId.toString(), period)
                
                if (response.isSuccessful && response.body()?.success == true) {
                    driverStats.value = response.body()?.data
                    Log.d("OdooViewModel", "Estadísticas obtenidas: ${driverStats.value}")
                } else {
                    val error = response.body()?.message ?: "Error obteniendo estadísticas"
                    statsError.value = error
                    Log.e("OdooViewModel", "Error en estadísticas: $error")
                }
            } catch (e: Exception) {
                statsError.value = e.message ?: "Error de conexión"
                Log.e("OdooViewModel", "Excepción obteniendo estadísticas: ${e.message}", e)
            } finally {
                isLoadingStats.value = false
            }
        }
    }
    
    /**
     * Obtener historial de rutas completadas
     */
    fun fetchRoutesHistory(driverId: Int, limit: Int = 20, offset: Int = 0) {
        viewModelScope.launch {
            try {
                isLoadingHistory.value = true
                
                Log.d("OdooViewModel", "Obteniendo historial para driver $driverId")
                val response = apiService.getRoutesHistory(driverId.toString(), limit, offset)
                
                if (response.isSuccessful && response.body()?.success == true) {
                    routesHistory.value = response.body()?.data ?: emptyList()
                    Log.d("OdooViewModel", "Historial obtenido: ${routesHistory.value.size} rutas")
                } else {
                    Log.e("OdooViewModel", "Error en historial: ${response.body()?.message}")
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Excepción obteniendo historial: ${e.message}", e)
            } finally {
                isLoadingHistory.value = false
            }
        }
    }
    
    /**
     * Calcular estadísticas locales de las rutas actuales Y del historial
     */
    fun getLocalStats(): LocalStats {
        val routes = odooRoutes.value
        val history = routesHistory.value
        
        var totalDeliveries = 0
        var completedDeliveries = 0
        var pendingDeliveries = 0
        var inProgressDeliveries = 0
        
        // Para calcular promedios de tiempo
        var totalDeliveryTimeMinutes = 0L
        var deliveriesWithTime = 0
        var totalRouteTimeMinutes = 0L
        var routesWithTime = 0
        
        Log.d("OdooViewModel", "Calculando stats locales. Rutas activas: ${routes.size}, Historial: ${history.size}")
        
        // Procesar rutas activas
        routes.forEach { route ->
            Log.d("OdooViewModel", "Ruta: ${route.name}, state: ${route.state}, start: ${route.startDate}, end: ${route.endDate}")
            
            route.routeLines.forEach { line ->
                totalDeliveries++
                when (line.state) {
                    "done" -> {
                        completedDeliveries++
                        // Calcular tiempo de entrega si hay start_time y end_time
                        if (!line.startTime.isNullOrEmpty() && !line.endTime.isNullOrEmpty()) {
                            val deliveryMinutes = calculateMinutesDifference(line.startTime, line.endTime)
                            Log.d("OdooViewModel", "Línea ${line.id}: start=${line.startTime}, end=${line.endTime}, minutos=$deliveryMinutes")
                            if (deliveryMinutes > 0) {
                                totalDeliveryTimeMinutes += deliveryMinutes
                                deliveriesWithTime++
                            }
                        } else if (!line.pickupTime.isNullOrEmpty() && !line.endTime.isNullOrEmpty()) {
                            // Alternativa: usar pickup_time si no hay start_time
                            val deliveryMinutes = calculateMinutesDifference(line.pickupTime, line.endTime)
                            if (deliveryMinutes > 0) {
                                totalDeliveryTimeMinutes += deliveryMinutes
                                deliveriesWithTime++
                            }
                        }
                    }
                    "pending" -> pendingDeliveries++
                    "in_progress", "picked_up" -> inProgressDeliveries++
                }
            }
            
            // Calcular tiempo de ruta si tiene start_date y end_date
            if (!route.startDate.isNullOrEmpty() && !route.endDate.isNullOrEmpty()) {
                val routeMinutes = calculateMinutesDifference(route.startDate, route.endDate)
                Log.d("OdooViewModel", "Ruta ${route.name}: minutos=$routeMinutes")
                if (routeMinutes > 0) {
                    totalRouteTimeMinutes += routeMinutes
                    routesWithTime++
                }
            }
        }
        
        // Usar datos del historial para calcular promedios más precisos
        history.forEach { historyItem ->
            if (historyItem.durationMinutes > 0) {
                totalRouteTimeMinutes += historyItem.durationMinutes.toLong()
                routesWithTime++
            }
            // Sumar entregas del historial para cálculo de eficiencia global
            totalDeliveries += historyItem.totalDeliveries
            completedDeliveries += historyItem.completedDeliveries
        }
        
        // Calcular promedios
        val avgRouteMinutes = if (routesWithTime > 0) totalRouteTimeMinutes / routesWithTime else 0L
        
        // Calcular promedio de entrega
        var avgDeliveryMinutes = if (deliveriesWithTime > 0) totalDeliveryTimeMinutes / deliveriesWithTime else 0L
        
        // Si no hay datos de líneas, estimar desde rutas
        if (avgDeliveryMinutes == 0L && routesWithTime > 0 && completedDeliveries > 0) {
            // Estimar: tiempo promedio de rutas / promedio de entregas por ruta
            val avgDeliveriesPerRoute = completedDeliveries.toDouble() / routesWithTime
            if (avgDeliveriesPerRoute > 0) {
                avgDeliveryMinutes = (avgRouteMinutes / avgDeliveriesPerRoute).toLong()
            }
        }
        
        // Calcular eficiencia (completadas / total * 100)
        val efficiency = if (totalDeliveries > 0) {
            (completedDeliveries * 100.0 / totalDeliveries)
        } else 0.0
        
        Log.d("OdooViewModel", "Stats finales: total=$totalDeliveries, completed=$completedDeliveries, " +
                "avgDelivery=$avgDeliveryMinutes, avgRoute=$avgRouteMinutes, efficiency=$efficiency%")
        
        return LocalStats(
            totalRoutes = routes.size + history.size,
            completedRoutes = routes.count { it.state == "finished" } + history.size,
            inProgressRoutes = routes.count { it.state == "started" },
            pendingRoutes = routes.count { it.state in listOf("new", "draft") },
            totalDeliveries = totalDeliveries,
            completedDeliveries = completedDeliveries,
            pendingDeliveries = pendingDeliveries,
            inProgressDeliveries = inProgressDeliveries,
            completionRate = efficiency,
            avgDeliveryTimeMinutes = avgDeliveryMinutes,
            avgRouteTimeMinutes = avgRouteMinutes,
            avgDeliveryTimeFormatted = formatMinutesToTime(avgDeliveryMinutes),
            avgRouteTimeFormatted = formatMinutesToTime(avgRouteMinutes)
        )
    }
    
    /**
     * Calcular diferencia en minutos entre dos fechas en formato "YYYY-MM-DD HH:MM:SS"
     */
    private fun calculateMinutesDifference(start: String, end: String): Long {
        return try {
            // Intentar varios formatos de fecha
            val formats = listOf(
                java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault()),
                java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.getDefault()),
                java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
            )
            
            var startDate: java.util.Date? = null
            var endDate: java.util.Date? = null
            
            for (format in formats) {
                try {
                    if (startDate == null) startDate = format.parse(start)
                    if (endDate == null) endDate = format.parse(end)
                    if (startDate != null && endDate != null) break
                } catch (e: Exception) {
                    continue
                }
            }
            
            if (startDate != null && endDate != null) {
                val diff = (endDate.time - startDate.time) / (1000 * 60)  // Convertir ms a minutos
                if (diff > 0) diff else 0L
            } else 0L
        } catch (e: Exception) {
            Log.e("OdooViewModel", "Error calculando diferencia de tiempo: ${e.message}")
            0L
        }
    }
    
    /**
     * Formatear minutos a formato legible (ej: "45m", "1h 30m")
     */
    private fun formatMinutesToTime(minutes: Long): String {
        return when {
            minutes <= 0 -> "--"
            minutes < 60 -> "${minutes}m"
            else -> {
                val hours = minutes / 60
                val mins = minutes % 60
                if (mins > 0) "${hours}h ${mins}m" else "${hours}h"
            }
        }
    }
    
    /**
     * Descargar un archivo adjunto y retornar el contenido en base64
     */
    fun downloadAttachment(
        attachmentId: Int,
        onSuccess: (String, String, String) -> Unit, // (base64Data, filename, mimetype)
        onError: (String) -> Unit
    ) {
        viewModelScope.launch {
            try {
                isDownloadingAttachment.value = true
                downloadError.value = ""
                
                Log.d("OdooViewModel", "Descargando adjunto ID: $attachmentId")
                val response = apiService.getAttachment(attachmentId, "base64")
                
                if (response.isSuccessful && response.body()?.success == true) {
                    val data = response.body()?.data
                    if (data != null && !data.datas.isNullOrEmpty()) {
                        Log.d("OdooViewModel", "Adjunto descargado: ${data.filename}")
                        onSuccess(data.datas, data.filename ?: "archivo", data.mimetype ?: "application/octet-stream")
                    } else {
                        onError("Archivo vacío o no disponible")
                    }
                } else {
                    val error = response.body()?.message ?: "Error al descargar archivo"
                    Log.e("OdooViewModel", "Error descargando adjunto: $error")
                    downloadError.value = error
                    onError(error)
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Excepción descargando adjunto: ${e.message}", e)
                downloadError.value = e.message ?: "Error de conexión"
                onError(e.message ?: "Error de conexión")
            } finally {
                isDownloadingAttachment.value = false
            }
        }
    }
    
    /**
     * Obtener archivos adjuntos de una línea específica
     */
    fun fetchLineAttachments(
        lineId: Int,
        onSuccess: (List<AttachmentData>) -> Unit,
        onError: (String) -> Unit
    ) {
        viewModelScope.launch {
            try {
                Log.d("OdooViewModel", "Obteniendo adjuntos para línea ID: $lineId")
                val response = apiService.getLineAttachments(lineId)
                
                if (response.isSuccessful && response.body()?.success == true) {
                    val attachments = response.body()?.data?.attachments ?: emptyList()
                    Log.d("OdooViewModel", "Adjuntos obtenidos: ${attachments.size}")
                    onSuccess(attachments)
                } else {
                    val error = response.body()?.message ?: "Error al obtener adjuntos"
                    Log.e("OdooViewModel", "Error obteniendo adjuntos: $error")
                    onError(error)
                }
            } catch (e: Exception) {
                Log.e("OdooViewModel", "Excepción obteniendo adjuntos: ${e.message}", e)
                onError(e.message ?: "Error de conexión")
            }
        }
    }
    
    /**
     * Limpiar estado de descarga
     */
    fun clearDownloadState() {
        downloadError.value = ""
        isDownloadingAttachment.value = false
    }
}

/**
 * Estadísticas locales calculadas desde las rutas actuales
 */
data class LocalStats(
    val totalRoutes: Int,
    val completedRoutes: Int,
    val inProgressRoutes: Int,
    val pendingRoutes: Int,
    val totalDeliveries: Int,
    val completedDeliveries: Int,
    val pendingDeliveries: Int,
    val inProgressDeliveries: Int,
    val completionRate: Double,
    val avgDeliveryTimeMinutes: Long = 0,
    val avgRouteTimeMinutes: Long = 0,
    val avgDeliveryTimeFormatted: String = "--",
    val avgRouteTimeFormatted: String = "--"
)
