package com.example.logtic.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.*
import com.example.logtic.MainActivity
import com.example.logtic.R
import com.example.logtic.data.api.OdooApiService
import com.example.logtic.data.api.RetrofitClient
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

/**
 * Worker para verificar nuevas rutas asignadas al conductor.
 * Usa el endpoint ligero /api/routes/check-new para minimizar tráfico.
 * Se ejecuta cada 15 minutos (mínimo de WorkManager).
 */
class RouteNotificationWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val TAG = "RouteNotifWorker"
        const val CHANNEL_ID = "route_notifications"
        const val CHANNEL_URGENT_ID = "route_new_assignment"
        const val NOTIFICATION_ID = 1001
        const val PENDING_NOTIFICATION_ID = 1002
        const val NEW_ROUTE_NOTIFICATION_ID = 1003
        private const val PREF_NAME = "route_check"
        private const val PREF_LAST_CHECK_TIME = "last_check_time"
        private const val PREF_LAST_ROUTE_COUNT = "last_route_count"
        private const val ODOO_URL = "https://etc-corpocrea.odoo.com/"
        
        fun schedulePeriodicCheck(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            // Verificación cada 15 minutos para nuevas rutas (mínimo permitido por WorkManager)
            val newRoutesWork = PeriodicWorkRequestBuilder<RouteNotificationWorker>(
                15, TimeUnit.MINUTES
            )
                .setConstraints(constraints)
                .setInitialDelay(1, TimeUnit.MINUTES) // Primera verificación rápida
                .build()

            // Recordatorio cada 1 hora para rutas pendientes
            val pendingRoutesWork = PeriodicWorkRequestBuilder<PendingRoutesReminderWorker>(
                1, TimeUnit.HOURS
            )
                .setConstraints(constraints)
                .build()

            WorkManager.getInstance(context).apply {
                enqueueUniquePeriodicWork(
                    "route_check_worker",
                    ExistingPeriodicWorkPolicy.UPDATE,
                    newRoutesWork
                )
                enqueueUniquePeriodicWork(
                    "pending_routes_reminder",
                    ExistingPeriodicWorkPolicy.KEEP,
                    pendingRoutesWork
                )
            }
            
            Log.d(TAG, "Workers de notificaciones programados")
        }

        fun cancelPeriodicCheck(context: Context) {
            WorkManager.getInstance(context).apply {
                cancelUniqueWork("route_check_worker")
                cancelUniqueWork("pending_routes_reminder")
            }
            Log.d(TAG, "Workers de notificaciones cancelados")
        }
        
        /**
         * Ejecutar verificación inmediata (para usar después de login o al abrir la app)
         */
        fun checkNow(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
                
            val oneTimeWork = OneTimeWorkRequestBuilder<RouteNotificationWorker>()
                .setConstraints(constraints)
                .build()
                
            WorkManager.getInstance(context).enqueue(oneTimeWork)
            Log.d(TAG, "Verificación inmediata solicitada")
        }
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "=== Ejecutando verificación de rutas nuevas ===")
            
            val sharedPrefs = applicationContext.getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
            val driverId = sharedPrefs.getInt("driver_id", 0)
            
            if (driverId == 0) {
                Log.d(TAG, "Sin driver_id, saltando verificación")
                return@withContext Result.success()
            }

            // Restaurar cookies desde disco (el worker puede ejecutarse sin la app abierta)
            RetrofitClient.restoreCookies(applicationContext)
            
            // Si no hay sesión activa, intentar re-login automático
            if (!RetrofitClient.hasActiveSession()) {
                Log.w(TAG, "Sin sesión activa, intentando re-login")
                if (!tryAutoLogin(sharedPrefs)) {
                    Log.e(TAG, "Re-login falló, abortando verificación")
                    return@withContext Result.retry()
                }
            }

            // Usar RetrofitClient que mantiene las cookies de sesión
            val apiService = RetrofitClient.getApiService(ODOO_URL)
            
            // Obtener timestamp de última verificación
            val prefs = applicationContext.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            val lastCheckTime = prefs.getString(PREF_LAST_CHECK_TIME, null)
            
            Log.d(TAG, "Driver ID: $driverId, Última verificación: $lastCheckTime")
            
            // Intentar usar el endpoint check-new primero
            try {
                val checkResponse = apiService.checkNewRoutes(
                    driver = driverId.toString(),
                    since = lastCheckTime
                )
                
                if (checkResponse.isSuccessful && checkResponse.body()?.success == true) {
                    val data = checkResponse.body()?.data
                    Log.d(TAG, "Check-new: hasNew=${data?.hasNew}, count=${data?.newCount}, pending=${data?.totalPending}")
                    
                    if (data != null && data.hasNew && data.newCount > 0) {
                        showNewRouteNotification(data.newCount, data.routeNames)
                    }
                    
                    // Guardar timestamp de esta verificación
                    data?.checkedAt?.let { checkedAt ->
                        prefs.edit().putString(PREF_LAST_CHECK_TIME, checkedAt).apply()
                    }
                    
                    return@withContext Result.success()
                }
            } catch (e: Exception) {
                Log.w(TAG, "Endpoint check-new no disponible, usando fallback: ${e.message}")
            }
            
            // Fallback: usar sync endpoint y comparar conteos
            try {
                val response = apiService.syncTodayRoutes(driverId.toString())
                
                if (response.isSuccessful) {
                    val routeData = response.body()
                    val currentRouteCount = routeData?.data?.size ?: 0
                    val lastRouteCount = prefs.getInt(PREF_LAST_ROUTE_COUNT, -1)
                    
                    Log.d(TAG, "Fallback: current=$currentRouteCount, last=$lastRouteCount")
                    
                    if (lastRouteCount != -1 && currentRouteCount > lastRouteCount) {
                        val newRoutes = currentRouteCount - lastRouteCount
                        val routeNames = routeData?.data
                            ?.takeLast(newRoutes)
                            ?.map { it.name } ?: emptyList()
                        showNewRouteNotification(newRoutes, routeNames)
                    }
                    
                    prefs.edit()
                        .putInt(PREF_LAST_ROUTE_COUNT, currentRouteCount)
                        .putString(PREF_LAST_CHECK_TIME, 
                            java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault())
                                .format(java.util.Date()))
                        .apply()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error en fallback sync: ${e.message}")
            }
            
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Error en verificación de rutas", e)
            Result.retry()
        }
    }

    /**
     * Intentar re-login automático usando credenciales guardadas.
     * Retorna true si el login fue exitoso.
     */
    private suspend fun tryAutoLogin(prefs: android.content.SharedPreferences): Boolean {
        return try {
            val username = prefs.getString("username", null) ?: return false
            val password = prefs.getString("password", null) ?: return false
            
            val apiService = RetrofitClient.getApiService(ODOO_URL)
            val loginRequest = com.example.logtic.data.api.LoginRequest(
                username = username,
                password = password
            )
            val response = apiService.login(loginRequest)
            
            if (response.isSuccessful && response.body()?.success == true) {
                // Persistir las nuevas cookies
                RetrofitClient.saveCookies(applicationContext)
                Log.d(TAG, "Re-login automático exitoso para $username")
                true
            } else {
                Log.w(TAG, "Re-login falló: ${response.code()}")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error en re-login automático: ${e.message}")
            false
        }
    }

    /**
     * Notificación prominente de nuevas rutas asignadas.
     * Usa canal de alta prioridad, vibración, sonido y estilo expandido.
     */
    private fun showNewRouteNotification(newRoutes: Int, routeNames: List<String>) {
        createNotificationChannels()

        val intent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("navigate_to", "routes") // Para navegar directamente a rutas
        }
        
        val pendingIntent = PendingIntent.getActivity(
            applicationContext,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val title = if (newRoutes == 1) "🚛 Nueva Ruta Asignada" else "🚛 $newRoutes Nuevas Rutas Asignadas"
        val shortText = if (newRoutes == 1) {
            "Tienes una nueva ruta para hoy"
        } else {
            "Tienes $newRoutes nuevas rutas para hoy"
        }
        
        // Texto expandido con nombres de rutas
        val bigText = buildString {
            append(shortText)
            if (routeNames.isNotEmpty()) {
                append("\n\n")
                routeNames.forEachIndexed { index, name ->
                    append("📍 $name")
                    if (index < routeNames.size - 1) append("\n")
                }
                append("\n\nToca para ver detalles")
            }
        }

        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_URGENT_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(shortText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setSound(soundUri)
            .setVibrate(longArrayOf(0, 500, 200, 500)) // Vibración: pausa-vibra-pausa-vibra
            .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // Visible en pantalla de bloqueo
            .build()

        try {
            NotificationManagerCompat.from(applicationContext).notify(NEW_ROUTE_NOTIFICATION_ID, notification)
            Log.d(TAG, "Notificación de nueva ruta mostrada: $newRoutes rutas")
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso para mostrar notificaciones: ${e.message}")
        }
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Canal para rutas nuevas (alta prioridad)
            val urgentChannel = NotificationChannel(
                CHANNEL_URGENT_ID,
                "Nuevas Rutas Asignadas",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificaciones cuando se asignan nuevas rutas"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(urgentChannel)
            
            // Canal general de rutas
            val generalChannel = NotificationChannel(
                CHANNEL_ID,
                "Rutas",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Recordatorios de rutas pendientes"
            }
            notificationManager.createNotificationChannel(generalChannel)
        }
    }
}

/**
 * Worker para recordatorios de rutas pendientes cada hora.
 * Notifica al conductor si tiene rutas sin completar.
 */
class PendingRoutesReminderWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    companion object {
        private const val TAG = "PendingRoutesWorker"
        private const val ODOO_URL = "https://etc-corpocrea.odoo.com/"
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            val sharedPrefs = applicationContext.getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
            val driverId = sharedPrefs.getInt("driver_id", 0)
            
            if (driverId == 0) {
                return@withContext Result.success()
            }

            // Restaurar cookies desde disco
            RetrofitClient.restoreCookies(applicationContext)
            
            // Si no hay sesión activa, intentar re-login
            if (!RetrofitClient.hasActiveSession()) {
                Log.w(TAG, "Sin sesión activa, intentando re-login")
                val username = sharedPrefs.getString("username", null)
                val password = sharedPrefs.getString("password", null)
                if (username != null && password != null) {
                    try {
                        val loginService = RetrofitClient.getApiService(ODOO_URL)
                        val loginResponse = loginService.login(
                            com.example.logtic.data.api.LoginRequest(username = username, password = password)
                        )
                        if (loginResponse.isSuccessful && loginResponse.body()?.success == true) {
                            RetrofitClient.saveCookies(applicationContext)
                            Log.d(TAG, "Re-login exitoso")
                        } else {
                            return@withContext Result.retry()
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error en re-login: ${e.message}")
                        return@withContext Result.retry()
                    }
                } else {
                    return@withContext Result.success()
                }
            }

            // Usar RetrofitClient con sesión activa
            val apiService = RetrofitClient.getApiService(ODOO_URL)
            
            // Intentar check-new primero (más ligero)
            try {
                val checkResponse = apiService.checkNewRoutes(driver = driverId.toString())
                if (checkResponse.isSuccessful && checkResponse.body()?.success == true) {
                    val totalPending = checkResponse.body()?.data?.totalPending ?: 0
                    if (totalPending > 0) {
                        showPendingRoutesNotification(totalPending)
                    }
                    return@withContext Result.success()
                }
            } catch (e: Exception) {
                Log.w(TAG, "check-new no disponible, usando fallback")
            }
            
            // Fallback
            val response = apiService.syncTodayRoutes(driverId.toString())
            
            if (response.isSuccessful) {
                val routes = response.body()?.data ?: emptyList()
                val pendingCount = routes.count { route ->
                    route.state != "finished" && route.state != "cancelled" && route.state != "done"
                }
                
                if (pendingCount > 0) {
                    showPendingRoutesNotification(pendingCount)
                }
            }
            
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Error en recordatorio de rutas pendientes", e)
            Result.retry()
        }
    }

    private fun showPendingRoutesNotification(pendingCount: Int) {
        createNotificationChannel()

        val intent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("navigate_to", "routes")
        }
        
        val pendingIntent = PendingIntent.getActivity(
            applicationContext,
            1,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(applicationContext, RouteNotificationWorker.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("⏰ Recordatorio de Rutas")
            .setContentText("Tienes $pendingCount ruta${if (pendingCount > 1) "s" else ""} pendiente${if (pendingCount > 1) "s" else ""} por completar")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        try {
            NotificationManagerCompat.from(applicationContext).notify(
                RouteNotificationWorker.PENDING_NOTIFICATION_ID,
                notification
            )
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso para mostrar notificaciones")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                RouteNotificationWorker.CHANNEL_ID,
                "Rutas",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Recordatorios de rutas pendientes"
            }
            
            val notificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
