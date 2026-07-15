import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserManagementProvider extends ChangeNotifier {
  List<User> _users = [];
  String _successMessage = '';
  String _errorMessage = '';
  bool _showCreateDialog = false;

  // Form fields
  String _fullName = '';
  String _username = '';
  String _password = '';
  String _driverLicense = '';

  List<User> get users => _users;
  String get successMessage => _successMessage;
  String get errorMessage => _errorMessage;
  bool get showCreateDialog => _showCreateDialog;
  String get fullName => _fullName;
  String get username => _username;
  String get password => _password;
  String get driverLicense => _driverLicense;

  void loadUsers() {
    _users = [
      User(username: 'admin', fullName: 'Administrador Sistema', role: 'admin'),
      User(username: 'driver1', fullName: 'Juan Pérez', driverCode: 'DRV001', driverId: 1),
      User(username: 'driver2', fullName: 'María González', driverCode: 'DRV002', driverId: 2),
    ];
    notifyListeners();
  }

  void showCreateUserDialog() {
    _showCreateDialog = true;
    _fullName = '';
    _username = '';
    _password = '';
    _driverLicense = '';
    notifyListeners();
  }

  void hideCreateUserDialog() {
    _showCreateDialog = false;
    notifyListeners();
  }

  void updateFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void updateUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    notifyListeners();
  }

  void updateDriverLicense(String value) {
    _driverLicense = value;
    notifyListeners();
  }

  void createUser() {
    if (_username.isEmpty || _password.isEmpty || _fullName.isEmpty) {
      _errorMessage = 'Todos los campos son requeridos';
      notifyListeners();
      return;
    }

    _users.add(User(
      username: _username,
      fullName: _fullName,
      driverCode: _driverLicense,
      driverId: _users.length + 1,
    ));

    _successMessage = 'Usuario creado exitosamente';
    _showCreateDialog = false;
    notifyListeners();
  }

  void deleteUser(User user) {
    _users.removeWhere((u) => u.username == user.username);
    _successMessage = 'Usuario eliminado exitosamente';
    notifyListeners();
  }

  void clearMessages() {
    _successMessage = '';
    _errorMessage = '';
    notifyListeners();
  }
}