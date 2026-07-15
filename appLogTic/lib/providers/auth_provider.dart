import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/odoo_models.dart';
import '../services/api/retrofit_client.dart';

class AuthProvider extends ChangeNotifier {
  final RetrofitClient _client = RetrofitClient();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _errorMessage = '';
  String _username = '';
  String _password = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;
  String get username => _username;
  String get password => _password;

  void updateUsername(String value) {
    _username = value;
    _errorMessage = '';
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIsLoggedIn = prefs.getBool(AppConfig.prefsIsLoggedIn) ?? false;

      if (savedIsLoggedIn) {
        final savedUsername = prefs.getString(AppConfig.prefsUsername) ?? '';
        final savedFullName = prefs.getString(AppConfig.prefsFullName) ?? '';
        final savedRole = prefs.getString(AppConfig.prefsRole) ?? 'driver';
        final savedDriverCode = prefs.getString(AppConfig.prefsDriverCode) ?? '';
        final savedDriverId = prefs.getInt(AppConfig.prefsDriverId) ?? 0;
        final savedDriverName = prefs.getString(AppConfig.prefsDriverName) ?? '';

        if (savedUsername.isNotEmpty && savedDriverId > 0) {
          _currentUser = User(
            username: savedUsername,
            fullName: savedFullName,
            role: savedRole,
            driverCode: savedDriverCode,
            driverId: savedDriverId,
            driverName: savedDriverName,
          );
          _isLoggedIn = true;

          await _client._cookieManager.restoreCookies();
          _registerFcmToken(savedDriverId, savedUsername);
        } else {
          await prefs.clear();
        }
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_username.isEmpty || _password.isEmpty) {
      _errorMessage = 'Por favor ingresa usuario y contraseña';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      debugPrint('=== INICIANDO LOGIN ===');
      debugPrint('Username: $_username');

      final response = await _client.login(_username, _password);
      debugPrint('Login response: success=${response.success}');

      if (response.success && response.data != null) {
        final authData = response.data!;
        final finalUsername = authData.username.isNotEmpty ? authData.username : _username;
        final finalFullName = authData.fullName.isNotEmpty ? authData.fullName : finalUsername;
        final finalDriverName = authData.driverName.isNotEmpty ? authData.driverName : finalFullName;

        _currentUser = User(
          username: finalUsername,
          fullName: finalFullName,
          role: authData.role.isNotEmpty ? authData.role : 'driver',
          driverCode: authData.driverCode,
          driverId: authData.driverId,
          driverName: finalDriverName,
        );

        _isLoggedIn = true;
        _saveSession(_currentUser!);
        
        if (authData.driverId > 0) {
          _registerFcmToken(authData.driverId, finalUsername);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('SocketException') || errorStr.contains('Connection refused')) {
        _errorMessage = 'No se puede conectar al servidor. Verifica tu conexión a internet.';
      } else if (errorStr.contains('TimeoutException')) {
        _errorMessage = 'Tiempo de espera agotado. El servidor no responde.';
      } else if (errorStr.contains('401')) {
        _errorMessage = 'Usuario o contraseña incorrectos';
      } else if (errorStr.contains('404')) {
        _errorMessage = 'Endpoint no encontrado. Verifica que el controller de Odoo esté instalado.';
      } else if (errorStr.contains('500')) {
        _errorMessage = 'Error interno del servidor Odoo';
      } else {
        _errorMessage = 'Error de conexión: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _client.clearSession();
    
    _currentUser = null;
    _isLoggedIn = false;
    _username = '';
    _password = '';
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.prefsIsLoggedIn, true);
    await prefs.setString(AppConfig.prefsUsername, user.username);
    await prefs.setString(AppConfig.prefsFullName, user.fullName);
    await prefs.setString(AppConfig.prefsRole, user.role);
    await prefs.setString(AppConfig.prefsDriverCode, user.driverCode);
    await prefs.setInt(AppConfig.prefsDriverId, user.driverId);
    await prefs.setString(AppConfig.prefsDriverName, user.driverName);
    await prefs.setString(AppConfig.prefsPassword, _password);
  }

  Future<void> _registerFcmToken(int driverId, String? username) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) return;

      debugPrint('FCM Token obtained, registering...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.prefsFcmToken, token);
      await prefs.setBool(AppConfig.prefsFcmTokenSent, false);

      try {
        final request = FcmTokenRequest(
          driverId: driverId,
          token: token,
          platform: 'android',
          username: username,
        );
        await _client.registerFcmToken(request);
        await prefs.setBool(AppConfig.prefsFcmTokenSent, true);
        debugPrint('FCM Token registered successfully');
      } catch (e) {
        debugPrint('Error registering FCM token: $e');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }
}