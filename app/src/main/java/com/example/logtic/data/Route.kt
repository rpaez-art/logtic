package com.example.logtic.data

data class Route(
    val id: Int,
    val clientName: String,
    val address: String,
    val city: String,
    val scheduledTime: String,
    val status: RouteStatus,
    val latitude: Double,
    val longitude: Double,
    val description: String = "",
    val startTime: String? = null,
    val endTime: String? = null,
    val endLatitude: Double? = null,
    val endLongitude: Double? = null,
    val assignedDriver: String = "",
    val odooRouteId: Int? = null,
    val odooLineId: Int? = null,
    val sequence: Int = 0
)

enum class RouteStatus {
    PENDING,
    IN_PROGRESS,
    COMPLETED
}
