import 'package:flutter_test/flutter_test.dart';

/// Inicialización de Firebase no-operativa para tests.
/// AuthProvider ya maneja la no disponibilidad de Firebase en tests.
Future<void> initFirebaseForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // No-op: AuthProvider maneja la ausencia de Firebase en tests.
}