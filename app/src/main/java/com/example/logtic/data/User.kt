package com.example.logtic.data

data class User(
    val username: String,
    val password: String = "",  // No almacenar en producción
    val fullName: String,
    val role: String = "driver",  // admin, driver, monitor
    val driverCode: String = "",  // ID del conductor en Odoo
    val driverId: Int = 0,  // ID del partner vinculado
    val driverName: String = ""
)
