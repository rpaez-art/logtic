package com.example.logtic.viewmodel

import android.content.Context
import android.util.Log
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.logtic.data.User
import com.example.logtic.data.api.LoginRequest
import com.example.logtic.data.api.FcmTokenRequest
import com.example.logtic.data.api.RetrofitClient
import com.example.logtic.service.RouteNotificationWorker
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.launch

class AuthViewModel(private val context: Context) : ViewModel() {
    
    companion object {
        private const val TAG = "AuthViewModel"
        private const val PREFS_NAME = "user_prefs"
        private const val KEY_IS_LOGGED_IN = "is_logged_in"
        private const val KEY_USERNAME = "username"
        private const val KEY_FULL_NAME = "full_name"
        private const val KEY_ROLE = "role"
        private const val KEY_DRIVER_CODE = "driver_code"
        private const val KEY_DRIVER_ID = "driver_id"
        private const val KEY_DRIVER_NAME = "driver_name"
        private const val KEY_PASSWORD = "password"
    }
    
    // URL de Odoo pre-configurada
    private val ODOO_URL = "https://etc-corpocrea.odoo.com/"
    
    var username = mutableStateOf("")
        private set
    
    var password = mutableStateOf("")
        private set
    
    var currentUser = mutableStateOf<User?>(null)
        private set
    
    var errorMessage = mutableStateOf("")
        private set
    
    var isLoading = mutableStateOf(false)
        private set
    
    private val apiService = RetrofitClient.getApiService(ODOO_URL)
    
    init {
        // Restaurar sesión guardada al crear el ViewModel
        restoreSession()
    }
    
    /**
     * Verifica si hay una sesión guardada en SharedPreferences
     */
    fun isLoggedIn(): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_IS_LOGGED_IN, false) && currentUser.value != null
    }
    
    /**
     * Restaurar la sesión del usuario desde SharedPreferences
     */
    private fun restoreSession() {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val isLoggedIn = prefs.getBoolean(KEY_IS_LOGGED_IN, false)
        
        if (isLoggedIn) {
            val savedUsername = prefs.getString(KEY_USERNAME, "") ?: ""
            val savedFullName = prefs.getString(KEY_FULL_NAME, "") ?: ""
            val savedRole = prefs.getString(KEY_ROLE, "driver") ?: "driver"
            val savedDriverCode = prefs.getString(KEY_DRIVER_CODE, "") ?: ""
            val savedDriverId = prefs.getInt(KEY_DRIVER_ID, 0)
            val savedDriverName = prefs.getString(KEY_DRIVER_NAME, "") ?: ""
            
            if (savedUsername.isNotEmpty() && savedDriverId > 0) {
                currentUser.value = User(
                    username = savedUsername,
                    fullName = savedFullName,
                    role = savedRole,
                    driverCode = savedDriverCode,
                    driverId = savedDriverId,
                    driverName = savedDriverName
                )
                
                // Restaurar cookies desde disco
                RetrofitClient.restoreCookies(context)

                // Reintentar registro de token FCM al abrir la app con sesión activa.
                registerFcmToken(savedDriverId, savedUsername)
                
                Log.d(TAG, "Sesión restaurada para: $savedUsername (driverId=$savedDriverId)")
            } else {
                // Datos incompletos, limpiar
                prefs.edit().clear().apply()
                Log.d(TAG, "Datos de sesión incompletos, limpiados")
            }
        }
    }
    
    /**
     * Guardar todos los datos del usuario en SharedPreferences
     */
    private fun saveSession(user: User) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean(KEY_IS_LOGGED_IN, true)
            .putString(KEY_USERNAME, user.username)
            .putString(KEY_FULL_NAME, user.fullName)
            .putString(KEY_ROLE, user.role)
            .putString(KEY_DRIVER_CODE, user.driverCode)
            .putInt(KEY_DRIVER_ID, user.driverId)
            .putString(KEY_DRIVER_NAME, user.driverName)
            .putString(KEY_PASSWORD, password.value)
            .apply()
        
        // Persistir cookies a disco
        RetrofitClient.saveCookies(context)
        
        Log.d(TAG, "Sesión guardada para: ${user.username}")
    }
    
    fun updateUsername(newUsername: String) {
        username.value = newUsername
        errorMessage.value = ""
    }
    
    fun updatePassword(newPassword: String) {
        password.value = newPassword
        errorMessage.value = ""
    }
    
    fun login(onSuccess: () -> Unit) {
        if (username.value.isBlank() || password.value.isBlank()) {
            errorMessage.value = "Por favor ingresa usuario y contraseña"
            return
        }
        
        isLoading.value = true
        errorMessage.value = ""
        
        viewModelScope.launch {
            try {
                Log.d(TAG, "=== INICIANDO LOGIN ===")
                Log.d(TAG, "URL: $ODOO_URL")
                Log.d(TAG, "Username: ${username.value}")
                
                val request = LoginRequest(
                    username = username.value,
                    password = password.value
                )
                
                val response = apiService.login(request)
                
                Log.d(TAG, "Respuesta HTTP: ${response.code()}")
                Log.d(TAG, "Respuesta exitosa: ${response.isSuccessful}")
                Log.d(TAG, "Body: ${response.body()}")
                
                isLoading.value = false
                
                if (response.isSuccessful && response.body()?.success == true) {
                    val authData = response.body()?.data
                    
                    Log.d(TAG, "=== DATOS DE AUTENTICACIÓN ===")
                    Log.d(TAG, "AuthData: $authData")
                    Log.d(TAG, "Username: ${authData?.username}")
                    Log.d(TAG, "FullName: ${authData?.fullName}")
                    Log.d(TAG, "Role: ${authData?.role}")
                    Log.d(TAG, "DriverId: ${authData?.driverId}")
                    Log.d(TAG, "DriverCode: ${authData?.driverCode}")
                    Log.d(TAG, "DriverName: ${authData?.driverName}")
                    
                    if (authData != null) {
                        // Si el username está vacío, usar el que se ingresó
                        val finalUsername = authData.username.ifEmpty { username.value }
                        // Si el fullName está vacío, usar el username
                        val finalFullName = authData.fullName.ifEmpty { finalUsername }
                        // Si el driverName está vacío, usar el fullName
                        val finalDriverName = authData.driverName.ifEmpty { finalFullName }
                        
                        currentUser.value = User(
                            username = finalUsername,
                            fullName = finalFullName,
                            role = authData.role.ifEmpty { "driver" },
                            driverCode = authData.driverCode,
                            driverId = authData.driverId,
                            driverName = finalDriverName
                        )
                        
                        Log.d(TAG, "Usuario creado: ${currentUser.value}")
                        
                        // Guardar sesión completa en SharedPreferences
                        saveSession(currentUser.value!!)
                        
                        // Iniciar servicio de notificaciones periódicas
                        if (authData.role.equals("driver", ignoreCase = true)) {
                            RouteNotificationWorker.schedulePeriodicCheck(context)
                            // Verificación inmediata al hacer login
                            RouteNotificationWorker.checkNow(context)
                        }

                        // Registrar token FCM si el usuario tiene conductor vinculado.
                        if (authData.driverId > 0) {
                            registerFcmToken(authData.driverId, finalUsername)
                        } else {
                            Log.w(TAG, "No se registra FCM: driverId inválido (${authData.driverId}) para usuario $finalUsername")
                        }
                        
                        errorMessage.value = ""
                        onSuccess()
                    } else {
                        errorMessage.value = "Error al procesar los datos del usuario"
                    }
                } else {
                    // Añadir información de debug del error
                    val httpCode = response.code()
                    val errorBody = response.errorBody()?.string() ?: ""
                    val errorMsg = response.body()?.message 
                        ?: when (httpCode) {
                            401 -> "Usuario o contraseña incorrectos"
                            404 -> "Endpoint no encontrado. Verifica que el controller de Odoo esté instalado."
                            500 -> "Error interno del servidor Odoo"
                            else -> "Error HTTP $httpCode: $errorBody"
                        }
                    errorMessage.value = errorMsg
                }
            } catch (e: java.net.UnknownHostException) {
                isLoading.value = false
                errorMessage.value = "No se puede conectar al servidor. Verifica tu conexión a internet y la URL: $ODOO_URL"
            } catch (e: java.net.SocketTimeoutException) {
                isLoading.value = false
                errorMessage.value = "Tiempo de espera agotado. El servidor no responde."
            } catch (e: javax.net.ssl.SSLException) {
                isLoading.value = false
                errorMessage.value = "Error de seguridad SSL. Verifica el certificado del servidor."
            } catch (e: Exception) {
                isLoading.value = false
                errorMessage.value = "Error de conexión: ${e.javaClass.simpleName} - ${e.message}"
            }
        }
    }
    
    fun logout() {
        // Cancelar servicio de notificaciones
        RouteNotificationWorker.cancelPeriodicCheck(context)
        
        // Limpiar SharedPreferences
        val sharedPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        sharedPrefs.edit().clear().apply()
        
        // Limpiar cookies del cliente HTTP
        RetrofitClient.clearSession()
        RetrofitClient.clearSavedCookies(context)
        
        currentUser.value = null
        username.value = ""
        password.value = ""
        errorMessage.value = ""
        
        Log.d(TAG, "Sesión cerrada completamente")
    }

    /**
     * Obtener token FCM y registrarlo en el servidor Odoo
     */
    private fun registerFcmToken(driverId: Int, username: String? = null) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                Log.w(TAG, "Error obteniendo token FCM: ${task.exception}")
                return@addOnCompleteListener
            }

            val token = task.result
            Log.d(TAG, "Token FCM obtenido, registrando en servidor...")

            // Guardar localmente
            val fcmPrefs = context.getSharedPreferences("fcm_prefs", Context.MODE_PRIVATE)
            fcmPrefs.edit()
                .putString("fcm_token", token)
                .putBoolean("fcm_token_sent", false)
                .apply()

            // Enviar al servidor en background
            viewModelScope.launch {
                try {
                    val response = withContext(Dispatchers.IO) {
                        apiService.registerFcmToken(
                            FcmTokenRequest(
                                driverId = driverId,
                                token = token,
                                platform = "android",
                                username = username
                            )
                        ).execute()
                    }

                    if (response.isSuccessful) {
                        fcmPrefs.edit().putBoolean("fcm_token_sent", true).apply()
                        Log.d(TAG, "Token FCM registrado exitosamente en Odoo")
                    } else {
                        Log.w(TAG, "Error registrando token FCM: ${response.code()} - ${response.errorBody()?.string()}")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error enviando token FCM: ${e.message}")
                }
            }
        }
    }
}
