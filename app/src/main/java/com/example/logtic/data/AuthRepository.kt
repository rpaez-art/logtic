package com.example.logtic.data

object AuthRepository {
    // Usuarios de ejemplo (en producción esto vendría de una base de datos o API)
    private val users = listOf(
        User("admin", "admin123", "Administrador Sistema", "A12345678", ""),
        User("driver1", "pass123", "Juan Pérez", "B87654321", "DRV001"),
        User("driver2", "pass123", "María González", "C11223344", "DRV002")
    )
    
    fun authenticate(username: String, password: String): User? {
        return users.find { it.username == username && it.password == password }
    }
}
