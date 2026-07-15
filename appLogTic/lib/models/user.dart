class User {
  final String username;
  final String password;
  final String fullName;
  final String role;
  final String driverCode;
  final int driverId;
  final String driverName;

  User({
    this.username = '',
    this.password = '',
    this.fullName = '',
    this.role = 'driver',
    this.driverCode = '',
    this.driverId = 0,
    this.driverName = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'] ?? 'driver',
      driverCode: json['driver_code'] ?? json['driverCode'] ?? '',
      driverId: json['driver_id'] ?? json['driverId'] ?? 0,
      driverName: json['driver_name'] ?? json['driverName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'role': role,
      'driver_code': driverCode,
      'driver_id': driverId,
      'driver_name': driverName,
    };
  }

  User copyWith({
    String? username,
    String? password,
    String? fullName,
    String? role,
    String? driverCode,
    int? driverId,
    String? driverName,
  }) {
    return User(
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      driverCode: driverCode ?? this.driverCode,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
    );
  }
}