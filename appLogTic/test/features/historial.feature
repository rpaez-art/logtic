Feature: Historial de Rutas
  Como conductor de LogTic
  Quiero ver mi historial de rutas completadas
  Para revisar mis entregas anteriores

  Scenario: Ver el resumen general del historial
    Given tengo estadísticas de historial
    When veo la pantalla de historial
    Then veo el texto "Historial de Rutas"
    And veo el texto "Resumen General (Todo el tiempo)"

  Scenario: Ver estado vacío del historial
    Given no tengo rutas completadas
    When veo la pantalla de historial
    Then veo el texto "Sin historial de rutas"

  Scenario: Ver lista de rutas completadas
    Given tengo rutas completadas
    When veo la pantalla de historial
    Then veo el texto "Rutas Completadas"