import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/config/theme.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'package:logtic/screens/dashboard/widgets/dashboard_header.dart';
import 'package:logtic/screens/dashboard/widgets/period_selector.dart';
import 'package:logtic/screens/dashboard/widgets/summary_cards.dart';
import 'package:logtic/screens/dashboard/widgets/performance_card.dart';
import 'package:logtic/screens/dashboard/widgets/admin_action_card.dart';
import 'package:logtic/screens/dashboard/widgets/today_progress_card.dart';
import 'package:logtic/screens/dashboard/widgets/empty_history_card.dart';
import 'step/bdd_steps.dart';

void main() {
  group('Dashboard del Conductor', () {
    testWidgets('Ver el encabezado del dashboard con nombre de usuario', (tester) async {
      // Given soy un conductor autenticado llamado "Juan Pérez"
      // When veo el encabezado del dashboard
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: DashboardHeader(
                userName: 'Juan Pérez',
                onLogout: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "¡Bienvenido!"
      await BddSteps.veoElTexto(tester, '¡Bienvenido!');
      // And veo el texto "Juan Pérez"
      await BddSteps.veoElTexto(tester, 'Juan Pérez');
      // And veo el texto "Conductor Activo"
      await BddSteps.veoElTexto(tester, 'Conductor Activo');
    });

    testWidgets('Ver las tarjetas de resumen de entregas', (tester) async {
      // Given tengo estadísticas de entregas disponibles
      // When veo la sección de resumen
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SummaryCards(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Total Entregas"
      await BddSteps.veoElTexto(tester, 'Total Entregas');
      // And veo el texto "Completadas"
      await BddSteps.veoElTexto(tester, 'Completadas');
      // And veo el texto "En Curso"
      await BddSteps.veoElTexto(tester, 'En Curso');
      // And veo el texto "Pendientes"
      await BddSteps.veoElTexto(tester, 'Pendientes');
    });

    testWidgets('Ver el panel de administración como admin', (tester) async {
      // Given soy un usuario administrador
      // When veo las tarjetas de administración
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: AdminActionCard(
                    icon: Icons.visibility,
                    label: 'Monitor',
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: AdminActionCard(
                    icon: Icons.supervisor_account,
                    label: 'Usuarios',
                    color: AppColors.secondary,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: AdminActionCard(
                    icon: Icons.settings,
                    label: 'Config',
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Monitor"
      await BddSteps.veoElTexto(tester, 'Monitor');
      // And veo el texto "Usuarios"
      await BddSteps.veoElTexto(tester, 'Usuarios');
      // And veo el texto "Config"
      await BddSteps.veoElTexto(tester, 'Config');
    });

    testWidgets('Ver el selector de período', (tester) async {
      // Given tengo opciones de período
      // When veo el selector de período
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PeriodSelector(
              selectedPeriod: 'today',
              onPeriodSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Hoy"
      await BddSteps.veoElTexto(tester, 'Hoy');
      // And veo el texto "Semana"
      await BddSteps.veoElTexto(tester, 'Semana');
      // And veo el texto "Mes"
      await BddSteps.veoElTexto(tester, 'Mes');
      // And veo el texto "Todo"
      await BddSteps.veoElTexto(tester, 'Todo');
    });

    testWidgets('Ver estado vacío del historial', (tester) async {
      // Given no tengo rutas en mi historial
      // When veo la sección de historial
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: EmptyHistoryCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Sin historial aún"
      await BddSteps.veoElTexto(tester, 'Sin historial aún');
    });

    testWidgets('Ver la tarjeta de rendimiento', (tester) async {
      // Given tengo datos de rendimiento
      // When veo la tarjeta de rendimiento
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PerformanceCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Rendimiento"
      await BddSteps.veoElTexto(tester, 'Rendimiento');
      // And veo el texto "Prom. Entrega"
      await BddSteps.veoElTexto(tester, 'Prom. Entrega');
      // And veo el texto "Prom. Ruta"
      await BddSteps.veoElTexto(tester, 'Prom. Ruta');
      // And veo el texto "Eficiencia"
      await BddSteps.veoElTexto(tester, 'Eficiencia');
    });

    testWidgets('Ver la tarjeta de progreso de hoy', (tester) async {
      // Given tengo progreso del día
      // When veo la tarjeta de progreso
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TodayProgressCard(
              onViewRoutes: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Progreso de Hoy"
      await BddSteps.veoElTexto(tester, 'Progreso de Hoy');
      // And veo el texto "Ver rutas"
      await BddSteps.veoElTexto(tester, 'Ver rutas');
    });
  });
}