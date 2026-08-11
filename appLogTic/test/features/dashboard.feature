Feature: Dashboard del Conductor
  Como conductor de LogTic
  Quiero ver mi resumen de actividad y estadísticas
  Para monitorear mi rendimiento diario

  Scenario: Ver el encabezado del dashboard con nombre de usuario
    Given soy un conductor autenticado llamado "Juan Pérez"
    When veo la pantalla del dashboard
    Then veo el texto "¡Bienvenido!"
    And veo el texto "Juan Pérez"
    And veo el texto "Conductor Activo"

  Scenario: Ver las tarjetas de resumen de entregas
    Given tengo estadísticas de entregas disponibles
    When veo la sección de resumen
    Then veo el texto "Total Entregas"
    And veo el texto "Completadas"
    And veo el texto "En Curso"
    And veo el texto "Pendientes"

  Scenario: Ver el panel de administración como admin
    Given soy un usuario administrador
    When veo la pantalla del dashboard
    Then veo el texto "Panel de Administración"
    And veo el texto "Monitor"
    And veo el texto "Usuarios"
    And veo el texto "Config"

  Scenario: Ver el historial reciente
    Given tengo rutas completadas en mi historial
    When veo la sección de historial
    Then veo el texto "Historial Reciente"
    And veo el texto "Ver todo"

  Scenario: Ver estado vacío del historial
    Given no tengo rutas en mi historial
    When veo la sección de historial
    Then veo el texto "Sin historial aún"