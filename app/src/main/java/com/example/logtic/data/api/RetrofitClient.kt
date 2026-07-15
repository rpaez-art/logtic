package com.example.logtic.data.api

import android.content.Context
import android.util.Log
import okhttp3.Cookie
import okhttp3.CookieJar
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

/**
 * Cliente Retrofit para conectar con la API REST de Odoo
 * Cookies persistidas en SharedPreferences para mantener sesión entre reinicios
 */
object RetrofitClient {
    
    private const val TAG = "RetrofitClient"
    private const val COOKIE_PREFS = "cookie_prefs"
    private const val COOKIE_KEY_PREFIX = "cookies_"
    
    private var retrofit: Retrofit? = null
    private var currentBaseUrl: String = ""
    
    // Cookie storage para mantener la sesión de Odoo
    private val cookieStore = mutableMapOf<String, MutableList<Cookie>>()
    
    /**
     * CookieJar para manejar las cookies de sesión de Odoo
     */
    private val cookieJar = object : CookieJar {
        override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
            val host = url.host
            cookieStore.getOrPut(host) { mutableListOf() }.apply {
                clear()
                addAll(cookies)
            }
            Log.d(TAG, "Cookies guardadas para $host: ${cookies.map { "${it.name}=${it.value.take(10)}..." }}")
        }
        
        override fun loadForRequest(url: HttpUrl): List<Cookie> {
            val cookies = cookieStore[url.host] ?: emptyList()
            if (cookies.isNotEmpty()) {
                Log.d(TAG, "Cookies enviadas para ${url.host}: ${cookies.map { it.name }}")
            }
            return cookies
        }
    }
    
    fun getClient(baseUrl: String): Retrofit {
        if (retrofit == null || currentBaseUrl != baseUrl) {
            currentBaseUrl = baseUrl
            
            val loggingInterceptor = HttpLoggingInterceptor { message ->
                Log.d("OkHttp", message)
            }.apply {
                level = HttpLoggingInterceptor.Level.BODY
            }
            
            val client = OkHttpClient.Builder()
                .cookieJar(cookieJar)
                .addInterceptor(loggingInterceptor)
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .build()
            
            retrofit = Retrofit.Builder()
                .baseUrl(baseUrl)
                .client(client)
                .addConverterFactory(GsonConverterFactory.create())
                .build()
                
            Log.d(TAG, "Cliente Retrofit creado para: $baseUrl")
        }
        
        return retrofit!!
    }
    
    fun getApiService(baseUrl: String): OdooApiService {
        return getClient(baseUrl).create(OdooApiService::class.java)
    }
    
    /**
     * Limpiar la sesión en memoria (logout)
     */
    fun clearSession() {
        cookieStore.clear()
        retrofit = null
        currentBaseUrl = ""
        Log.d(TAG, "Sesión limpiada")
    }
    
    /**
     * Verificar si hay una sesión activa
     */
    fun hasActiveSession(): Boolean {
        return cookieStore.values.any { cookies ->
            cookies.any { it.name == "session_id" }
        }
    }
    
    /**
     * Persistir cookies a SharedPreferences para sobrevivir reinicios de app
     */
    fun saveCookies(context: Context) {
        val prefs = context.getSharedPreferences(COOKIE_PREFS, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        // Limpiar cookies anteriores
        editor.clear()
        
        // Guardar hosts con cookies
        val hosts = cookieStore.keys.toList()
        editor.putStringSet("cookie_hosts", hosts.toSet())
        
        for (host in hosts) {
            val cookies = cookieStore[host] ?: continue
            val cookieStrings = cookies.map { cookie ->
                // Serializar cookie como string: name|value|domain|path|expiresAt|secure|httpOnly
                "${cookie.name}|${cookie.value}|${cookie.domain}|${cookie.path}|${cookie.expiresAt}|${cookie.secure}|${cookie.httpOnly}"
            }
            editor.putStringSet("$COOKIE_KEY_PREFIX$host", cookieStrings.toSet())
        }
        
        editor.apply()
        Log.d(TAG, "Cookies guardadas en disco para ${hosts.size} hosts")
    }
    
    /**
     * Restaurar cookies desde SharedPreferences
     */
    fun restoreCookies(context: Context) {
        val prefs = context.getSharedPreferences(COOKIE_PREFS, Context.MODE_PRIVATE)
        val hosts = prefs.getStringSet("cookie_hosts", emptySet()) ?: emptySet()
        
        if (hosts.isEmpty()) {
            Log.d(TAG, "No hay cookies guardadas para restaurar")
            return
        }
        
        for (host in hosts) {
            val cookieStrings = prefs.getStringSet("$COOKIE_KEY_PREFIX$host", emptySet()) ?: continue
            val cookies = mutableListOf<Cookie>()
            
            for (cookieStr in cookieStrings) {
                try {
                    val parts = cookieStr.split("|")
                    if (parts.size >= 7) {
                        val name = parts[0]
                        val value = parts[1]
                        val domain = parts[2]
                        val path = parts[3]
                        val expiresAt = parts[4].toLongOrNull() ?: 0L
                        val secure = parts[5].toBoolean()
                        val httpOnly = parts[6].toBoolean()
                        
                        // No restaurar cookies expiradas
                        if (expiresAt > 0 && expiresAt < System.currentTimeMillis()) {
                            continue
                        }
                        
                        val cookie = Cookie.Builder()
                            .name(name)
                            .value(value)
                            .domain(domain)
                            .path(path)
                            .apply {
                                if (expiresAt > 0) expiresAt(expiresAt)
                                if (secure) secure()
                                if (httpOnly) httpOnly()
                            }
                            .build()
                        
                        cookies.add(cookie)
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "Error restaurando cookie: ${e.message}")
                }
            }
            
            if (cookies.isNotEmpty()) {
                cookieStore[host] = cookies
                Log.d(TAG, "Restauradas ${cookies.size} cookies para $host")
            }
        }
    }
    
    /**
     * Limpiar cookies guardadas en disco (logout)
     */
    fun clearSavedCookies(context: Context) {
        val prefs = context.getSharedPreferences(COOKIE_PREFS, Context.MODE_PRIVATE)
        prefs.edit().clear().apply()
        Log.d(TAG, "Cookies eliminadas del disco")
    }
}
