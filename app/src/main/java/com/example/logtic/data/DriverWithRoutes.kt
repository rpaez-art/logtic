package com.example.logtic.data

data class DriverWithRoutes(
    val driver: User,
    val routes: List<Route>
) {
    val totalRoutes: Int get() = routes.size
    val completedRoutes: Int get() = routes.count { it.status == RouteStatus.COMPLETED }
    val inProgressRoutes: Int get() = routes.count { it.status == RouteStatus.IN_PROGRESS }
    val pendingRoutes: Int get() = routes.count { it.status == RouteStatus.PENDING }
    val completionPercentage: Int get() = if (totalRoutes > 0) (completedRoutes * 100 / totalRoutes) else 0
}
