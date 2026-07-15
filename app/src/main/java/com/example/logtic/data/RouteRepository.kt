package com.example.logtic.data

object RouteRepository {
    // Las rutas ahora se cargan desde Odoo
    // Este repositorio solo se mantiene para compatibilidad
    
    fun getRoutesForToday(): List<Route> = emptyList()
    
    fun getRouteById(id: Int): Route? = null
    
    fun getRoutesByDriver(driverUsername: String): List<Route> = emptyList()
}
