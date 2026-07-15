package com.example.logtic.navigation

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Dashboard : Screen("dashboard")
    object Routes : Screen("routes")
    object RouteHistory : Screen("route_history")
    object UserManagement : Screen("user_management")
    object DriverMonitor : Screen("driver_monitor")
    object OdooConfig : Screen("odoo_config")
}
