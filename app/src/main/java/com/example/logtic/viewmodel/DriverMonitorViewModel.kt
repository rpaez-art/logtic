package com.example.logtic.viewmodel

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import com.example.logtic.data.AuthRepository
import com.example.logtic.data.DriverWithRoutes
import com.example.logtic.data.RouteRepository

class DriverMonitorViewModel : ViewModel() {
    var driversWithRoutes = mutableStateOf<List<DriverWithRoutes>>(emptyList())
        private set
    
    init {
        loadDriversWithRoutes()
    }
    
    fun loadDriversWithRoutes() {
        // En producción, esto vendría de una API o base de datos
        val allUsers = listOf(
            AuthRepository.authenticate("driver1", "pass123"),
            AuthRepository.authenticate("driver2", "pass123")
        ).filterNotNull()
        
        driversWithRoutes.value = allUsers.map { user ->
            val routes = RouteRepository.getRoutesByDriver(user.username)
            DriverWithRoutes(user, routes)
        }
    }
    
    fun refreshData() {
        loadDriversWithRoutes()
    }
}
