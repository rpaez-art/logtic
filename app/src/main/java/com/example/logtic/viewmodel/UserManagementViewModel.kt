package com.example.logtic.viewmodel

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import com.example.logtic.data.User

class UserManagementViewModel : ViewModel() {
    var users = mutableStateOf<List<User>>(emptyList())
        private set
    
    var username = mutableStateOf("")
        private set
    
    var password = mutableStateOf("")
        private set
    
    var fullName = mutableStateOf("")
        private set
    
    var driverLicense = mutableStateOf("")
        private set
    
    var errorMessage = mutableStateOf("")
        private set
    
    var successMessage = mutableStateOf("")
        private set
    
    var showCreateDialog = mutableStateOf(false)
        private set
    
    init {
        loadUsers()
    }
    
    fun loadUsers() {
        // En producción, esto cargaría usuarios de una base de datos
        users.value = listOf(
            User("admin", "admin123", "Administrador Sistema", "A12345678"),
            User("driver1", "pass123", "Juan Pérez", "B87654321"),
            User("driver2", "pass123", "María González", "C11223344")
        )
    }
    
    fun updateUsername(value: String) {
        username.value = value
        errorMessage.value = ""
    }
    
    fun updatePassword(value: String) {
        password.value = value
        errorMessage.value = ""
    }
    
    fun updateFullName(value: String) {
        fullName.value = value
        errorMessage.value = ""
    }
    
    fun updateDriverLicense(value: String) {
        driverLicense.value = value
        errorMessage.value = ""
    }
    
    fun showCreateUserDialog() {
        showCreateDialog.value = true
        clearForm()
    }
    
    fun hideCreateUserDialog() {
        showCreateDialog.value = false
        clearForm()
    }
    
    fun createUser() {
        // Validación
        if (username.value.isBlank()) {
            errorMessage.value = "El usuario es requerido"
            return
        }
        if (password.value.isBlank()) {
            errorMessage.value = "La contraseña es requerida"
            return
        }
        if (fullName.value.isBlank()) {
            errorMessage.value = "El nombre completo es requerido"
            return
        }
        if (password.value.length < 6) {
            errorMessage.value = "La contraseña debe tener al menos 6 caracteres"
            return
        }
        
        // Verificar si el usuario ya existe
        if (users.value.any { it.username.equals(username.value, ignoreCase = true) }) {
            errorMessage.value = "El usuario ya existe"
            return
        }
        
        // Crear nuevo usuario
        val newUser = User(
            username = username.value,
            password = password.value,
            fullName = fullName.value,
            role = "driver",
            driverCode = driverLicense.value
        )
        
        users.value = users.value + newUser
        successMessage.value = "Usuario ${newUser.fullName} creado exitosamente"
        hideCreateUserDialog()
        
        // Limpiar mensaje después de 3 segundos (en producción usar coroutines)
    }
    
    fun deleteUser(user: User) {
        if (user.username == "admin") {
            errorMessage.value = "No se puede eliminar el usuario administrador"
            return
        }
        users.value = users.value.filter { it.username != user.username }
        successMessage.value = "Usuario ${user.fullName} eliminado"
    }
    
    fun clearMessages() {
        errorMessage.value = ""
        successMessage.value = ""
    }
    
    private fun clearForm() {
        username.value = ""
        password.value = ""
        fullName.value = ""
        driverLicense.value = ""
        errorMessage.value = ""
    }
}
