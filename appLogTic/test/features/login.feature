# language: es
Funcionalidad: Login de Usuario
  Como usuario de LogTic
  Quiero iniciar sesión en la aplicación
  Para acceder a mis rutas y entregas

  Escenario: Ver la pantalla de login
    Dado que no estoy autenticado
    Cuando veo la pantalla de login
    Entonces veo el texto "Iniciar sesión"
    Y veo el campo de usuario
    Y veo el campo de contraseña

  Escenario: Ver error de credenciales inválidas
    Dado que ingreso credenciales incorrectas
    Cuando intento iniciar sesión
    Entonces veo un mensaje de error