package com.example.logtic.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.logtic.MainActivity
import com.example.logtic.R
import com.example.logtic.data.api.RetrofitClient
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * Servicio FCM para recibir notificaciones push instantáneas desde Odoo.
 * Cuando se asigna una ruta en Odoo, el servidor envía un push via FCM
 * y este servicio lo muestra como notificación inmediata al conductor.
 */
class LogticFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "LogticFCM"
        const val CHANNEL_ID = "route_new_assignment"
        const val URGENT_CHANNEL_ID = "route_urgent_assignment"
        const val FCM_TOKEN_PREF = "fcm_prefs"
        const val FCM_TOKEN_KEY = "fcm_token"
        const val FCM_TOKEN_SENT_KEY = "fcm_token_sent"
    }

    /**
     * Se llama cuando se recibe un mensaje push desde FCM.
     * El payload viene en data (no en notification) para que se procese
     * incluso con la app en background.
     */
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Log.d(TAG, "Mensaje FCM recibido de: ${message.from}")

        val data = message.data
        if (data.isEmpty()) {
            Log.w(TAG, "Mensaje sin datos, ignorando")
            return
        }

        val type = data["type"] ?: "route_assigned"
        Log.d(TAG, "Tipo de mensaje: $type, datos: $data")

        when (type) {
            "route_assigned" -> showRouteAssignedNotification(data)
            "urgent_route_assigned" -> showUrgentRouteNotification(data)
            "route_updated" -> showRouteUpdatedNotification(data)
            else -> showGenericNotification(data)
        }
    }

    /**
     * Se llama cuando FCM genera un nuevo token (primera vez o cuando cambia).
     * Guardamos el token localmente y lo enviamos al servidor Odoo.
     */
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "Nuevo token FCM generado")
        
        // Guardar token localmente
        val prefs = getSharedPreferences(FCM_TOKEN_PREF, Context.MODE_PRIVATE)
        prefs.edit()
            .putString(FCM_TOKEN_KEY, token)
            .putBoolean(FCM_TOKEN_SENT_KEY, false)
            .apply()

        // Intentar enviar al servidor si hay sesión activa
        sendTokenToServer(token)
    }

    private fun sendTokenToServer(token: String) {
        val userPrefs = getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
        val driverId = userPrefs.getInt("driver_id", 0)
        val username = userPrefs.getString("username", null)
        
        if (driverId == 0) {
            Log.d(TAG, "Sin driver_id, token se enviará al hacer login")
            return
        }

        // Enviar en background thread
        Thread {
            try {
                RetrofitClient.restoreCookies(applicationContext)
                val apiService = RetrofitClient.getApiService("https://etc-corpocrea.odoo.com/")
                val response = apiService.registerFcmToken(
                    com.example.logtic.data.api.FcmTokenRequest(
                        driverId = driverId,
                        token = token,
                        platform = "android",
                        username = username
                    )
                ).execute()
                
                if (response.isSuccessful && response.body()?.get("success") == true) {
                    getSharedPreferences(FCM_TOKEN_PREF, Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean(FCM_TOKEN_SENT_KEY, true)
                        .apply()
                    Log.d(TAG, "Token FCM registrado en servidor")
                } else {
                    Log.w(TAG, "Error registrando token: ${response.code()}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error enviando token al servidor: ${e.message}")
            }
        }.start()
    }

    // --- Notificaciones ---

    private fun showRouteAssignedNotification(data: Map<String, String>) {
        createNotificationChannel()

        val routeName = data["route_name"] ?: "Nueva ruta"
        val routeCount = data["route_count"]?.toIntOrNull() ?: 1
        val routeNames = data["route_names"] ?: routeName
        val routeDate = data["route_date"] ?: "hoy"

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("navigate_to", "routes")
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val title = if (routeCount == 1) {
            "🚛 Nueva Ruta Asignada"
        } else {
            "🚛 $routeCount Nuevas Rutas Asignadas"
        }
        
        val shortText = if (routeCount == 1) {
            "Se te asignó: $routeName"
        } else {
            "Tienes $routeCount nuevas rutas para $routeDate"
        }
        
        val bigText = buildString {
            append(shortText)
            append("\n\n")
            routeNames.split(",").forEachIndexed { i, name ->
                append("📍 ${name.trim()}")
                if (i < routeNames.split(",").size - 1) append("\n")
            }
            append("\n\nToca para ver detalles")
        }

        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(shortText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setSound(soundUri)
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        try {
            NotificationManagerCompat.from(this).notify(
                System.currentTimeMillis().toInt(),
                notification
            )
            Log.d(TAG, "Notificación de ruta asignada mostrada")
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso para mostrar notificaciones: ${e.message}")
        }
    }

    private fun showUrgentRouteNotification(data: Map<String, String>) {
        createNotificationChannel()

        val routeName = data["route_name"] ?: "Nueva ruta"
        val routeCount = data["route_count"]?.toIntOrNull() ?: 1
        val routeNames = data["route_names"] ?: routeName
        val routeDate = data["route_date"] ?: "hoy"

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("navigate_to", "routes")
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 3, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val title = "🚨 ¡RUTA URGENTE ASIGNADA!"
        
        val shortText = if (routeCount == 1) {
            "⚠ URGENTE: $routeName requiere atención inmediata"
        } else {
            "⚠ URGENTE: $routeCount rutas con prioridad urgente"
        }

        val bigText = buildString {
            append("🔴 ATENCIÓN: Se te asignó una ruta con solicitudes URGENTES\n\n")
            routeNames.split(",").forEachIndexed { i, name ->
                append("🚨 ${name.trim()}")
                if (i < routeNames.split(",").size - 1) append("\n")
            }
            append("\n\n⚠ Esta ruta requiere atención INMEDIATA")
            append("\nToca para ver detalles y comenzar")
        }

        val alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val notification = NotificationCompat.Builder(this, URGENT_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(shortText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setSound(alarmSound)
            .setVibrate(longArrayOf(0, 800, 200, 800, 200, 800, 200, 800))
            .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)  // No se puede deslizar para descartar — persistente
            .setColorized(true)
            .setColor(0xFFB91C1C.toInt())  // Rojo
            .build()

        try {
            NotificationManagerCompat.from(this).notify(
                99999,  // ID fijo para urgentes — se reemplaza si hay otra urgente
                notification
            )
            Log.d(TAG, "Notificación de ruta URGENTE mostrada")
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso para mostrar notificaciones: ${e.message}")
        }
    }

    private fun showRouteUpdatedNotification(data: Map<String, String>) {
        createNotificationChannel()

        val routeName = data["route_name"] ?: "Ruta"
        val message = data["message"] ?: "Tu ruta ha sido actualizada"

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("navigate_to", "routes")
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 1, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("📋 Ruta Actualizada: $routeName")
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setVibrate(longArrayOf(0, 300, 100, 300))
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        try {
            NotificationManagerCompat.from(this).notify(
                System.currentTimeMillis().toInt(),
                notification
            )
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso para notificaciones")
        }
    }

    private fun showGenericNotification(data: Map<String, String>) {
        createNotificationChannel()

        val title = data["title"] ?: "Logtic"
        val body = data["body"] ?: data["message"] ?: "Tienes una nueva notificación"

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 2, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        try {
            NotificationManagerCompat.from(this).notify(
                System.currentTimeMillis().toInt(),
                notification
            )
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso para notificaciones")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Asignación de Rutas",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificaciones instantáneas cuando se asignan nuevas rutas"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }

            val urgentChannel = NotificationChannel(
                URGENT_CHANNEL_ID,
                "Rutas Urgentes",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Alertas de rutas con solicitudes de prioridad URGENTE"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 800, 200, 800, 200, 800)
                setShowBadge(true)
                enableLights(true)
                lightColor = android.graphics.Color.RED
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
            manager.createNotificationChannel(urgentChannel)
        }
    }
}
