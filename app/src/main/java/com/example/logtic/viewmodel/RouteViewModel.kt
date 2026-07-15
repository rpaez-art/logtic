package com.example.logtic.viewmodel

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import com.example.logtic.data.Route
import com.example.logtic.data.RouteRepository
import com.example.logtic.data.RouteStatus
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

enum class RouteFilter {
    PENDING,
    ALL
}

class RouteViewModel : ViewModel() {
    private var allRoutes = mutableStateOf<List<Route>>(emptyList())
    
    var routes = mutableStateOf<List<Route>>(emptyList())
        private set
    
    var selectedRoute = mutableStateOf<Route?>(null)
        private set
    
    var currentFilter = mutableStateOf(RouteFilter.PENDING)
        private set
    
    init {
        loadRoutes()
    }
    
    fun loadRoutes() {
        allRoutes.value = RouteRepository.getRoutesForToday()
        applyFilter()
    }
    
    fun setRoutesFromOdoo(odooRoutes: List<Route>) {
        allRoutes.value = odooRoutes
        applyFilter()
    }
    
    fun setFilter(filter: RouteFilter) {
        currentFilter.value = filter
        applyFilter()
    }
    
    private fun applyFilter() {
        routes.value = when (currentFilter.value) {
            RouteFilter.PENDING -> allRoutes.value.filter { it.status != RouteStatus.COMPLETED }
            RouteFilter.ALL -> allRoutes.value
        }
    }
    
    fun selectRoute(route: Route) {
        selectedRoute.value = route
    }
    
    fun clearSelectedRoute() {
        selectedRoute.value = null
    }
    
    fun startRoute(routeId: Int) {
        val currentTime = SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.getDefault()).format(Date())
        allRoutes.value = allRoutes.value.map { route ->
            if (route.id == routeId) {
                route.copy(
                    status = RouteStatus.IN_PROGRESS,
                    startTime = currentTime
                )
            } else {
                route
            }
        }
        applyFilter()
    }
    
    fun completeRoute(routeId: Int, latitude: Double? = null, longitude: Double? = null) {
        val currentTime = SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.getDefault()).format(Date())
        allRoutes.value = allRoutes.value.map { route ->
            if (route.id == routeId) {
                route.copy(
                    status = RouteStatus.COMPLETED,
                    endTime = currentTime,
                    endLatitude = latitude,
                    endLongitude = longitude
                )
            } else {
                route
            }
        }
        applyFilter()
    }
}
