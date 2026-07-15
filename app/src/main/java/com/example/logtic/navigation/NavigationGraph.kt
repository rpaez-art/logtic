package com.example.logtic.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.example.logtic.ui.screens.DashboardScreen
import com.example.logtic.ui.screens.DriverMonitorScreen
import com.example.logtic.ui.screens.LoginScreen
import com.example.logtic.ui.screens.OdooConfigScreen
import com.example.logtic.ui.screens.RouteHistoryScreen
import com.example.logtic.ui.screens.RoutesScreen
import com.example.logtic.ui.screens.UserManagementScreen
import com.example.logtic.viewmodel.AuthViewModel
import com.example.logtic.viewmodel.DriverMonitorViewModel
import com.example.logtic.viewmodel.OdooViewModel
import com.example.logtic.viewmodel.RouteViewModel
import com.example.logtic.viewmodel.UserManagementViewModel

@Composable
fun NavigationGraph(
    navController: NavHostController,
    routeViewModel: RouteViewModel = viewModel(),
    userManagementViewModel: UserManagementViewModel = viewModel(),
    driverMonitorViewModel: DriverMonitorViewModel = viewModel(),
    odooViewModel: OdooViewModel = viewModel()
) {
    val context = LocalContext.current
    val authViewModel: AuthViewModel = viewModel { AuthViewModel(context) }
    
    // Determinar destino inicial según si hay sesión guardada
    val startDestination = if (authViewModel.isLoggedIn()) {
        Screen.Dashboard.route
    } else {
        Screen.Login.route
    }
    
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.Login.route) {
            LoginScreen(
                authViewModel = authViewModel,
                onLoginSuccess = {
                    navController.navigate(Screen.Dashboard.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Screen.Dashboard.route) {
            DashboardScreen(
                authViewModel = authViewModel,
                odooViewModel = odooViewModel,
                onNavigateToRoutes = {
                    navController.navigate(Screen.Routes.route)
                },
                onLogout = {
                    authViewModel.logout()
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.Dashboard.route) { inclusive = true }
                    }
                },
                onManageUsers = {
                    navController.navigate(Screen.UserManagement.route)
                },
                onMonitorDrivers = {
                    navController.navigate(Screen.DriverMonitor.route)
                },
                onViewHistory = {
                    navController.navigate(Screen.RouteHistory.route)
                }
            )
        }
        
        composable(Screen.Routes.route) {
            RoutesScreen(
                authViewModel = authViewModel,
                routeViewModel = routeViewModel,
                odooViewModel = odooViewModel,
                onLogout = {
                    authViewModel.logout()
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.Routes.route) { inclusive = true }
                    }
                },
                onManageUsers = {
                    navController.navigate(Screen.UserManagement.route)
                },
                onMonitorDrivers = {
                    navController.navigate(Screen.DriverMonitor.route)
                },
                onBackToDashboard = {
                    navController.popBackStack()
                }
            )
        }
        
        composable(Screen.UserManagement.route) {
            UserManagementScreen(
                userManagementViewModel = userManagementViewModel,
                onBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable(Screen.DriverMonitor.route) {
            DriverMonitorScreen(
                driverMonitorViewModel = driverMonitorViewModel,
                onBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable(Screen.RouteHistory.route) {
            RouteHistoryScreen(
                authViewModel = authViewModel,
                odooViewModel = odooViewModel,
                onBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
