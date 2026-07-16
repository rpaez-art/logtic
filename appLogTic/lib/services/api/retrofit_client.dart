import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../models/odoo_models.dart';

class CookieManager {
  static final CookieManager _instance = CookieManager._internal();
  factory CookieManager() => _instance;
  CookieManager._internal();

  final Map<String, List<Cookie>> _cookieStore = {};

  void saveFromResponse(Uri uri, List<Cookie> cookies) {
    final host = uri.host;
    _cookieStore[host] = cookies;
    _persistCookies(host, cookies);
  }

  List<Cookie> loadForRequest(Uri uri) {
    return _cookieStore[uri.host] ?? [];
  }

  String? getSessionId() {
    for (final cookies in _cookieStore.values) {
      for (final cookie in cookies) {
        if (cookie.name == 'session_id') {
          return cookie.value;
        }
      }
    }
    return null;
  }

  bool hasActiveSession() {
    return _cookieStore.values.any((cookies) =>
        cookies.any((c) => c.name == 'session_id'));
  }

  Future<void> _persistCookies(String host, List<Cookie> cookies) async {
    final prefs = await SharedPreferences.getInstance();
    final cookieStrings = cookies.map((c) =>
        '${c.name}|${c.value}|${c.domain}|${c.path}|${c.expires ?? 0}|${c.secure}|${c.httpOnly}').toList();
    await prefs.setStringList('${AppConfig.prefsCookiesPrefix}$host', cookieStrings);
    
    final hosts = prefs.getStringList(AppConfig.prefsCookieHosts) ?? [];
    if (!hosts.contains(host)) {
      hosts.add(host);
      await prefs.setStringList(AppConfig.prefsCookieHosts, hosts);
    }
  }

  Future<void> restoreCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final hosts = prefs.getStringList(AppConfig.prefsCookieHosts) ?? [];
    
    for (final host in hosts) {
      final cookieStrings = prefs.getStringList('${AppConfig.prefsCookiesPrefix}$host') ?? [];
      final cookies = <Cookie>[];
      
      for (final cookieStr in cookieStrings) {
        final parts = cookieStr.split('|');
        if (parts.length >= 7) {
          try {
            final expiresAt = int.tryParse(parts[4]) ?? 0;
            if (expiresAt > 0 && expiresAt < DateTime.now().millisecondsSinceEpoch) continue;
            
            cookies.add(Cookie(
              parts[0], parts[1],
              domain: parts[2],
              path: parts[3],
              expires: expiresAt > 0 ? DateTime.fromMillisecondsSinceEpoch(expiresAt) : null,
              secure: parts[5] == 'true',
              httpOnly: parts[6] == 'true',
            ));
          } catch (_) {}
        }
      }
      
      if (cookies.isNotEmpty) {
        _cookieStore[host] = cookies;
      }
    }
  }

  Future<void> clearCookies() async {
    _cookieStore.clear();
    final prefs = await SharedPreferences.getInstance();
    final hosts = prefs.getStringList(AppConfig.prefsCookieHosts) ?? [];
    for (final host in hosts) {
      await prefs.remove('${AppConfig.prefsCookiesPrefix}$host');
    }
    await prefs.remove(AppConfig.prefsCookieHosts);
  }
}

class RetrofitClient {
  static final RetrofitClient _instance = RetrofitClient._internal();
  factory RetrofitClient() => _instance;
  RetrofitClient._internal();

  final CookieManager _cookieManager = CookieManager();
  String _baseUrl = AppConfig.odooBaseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    
    final request = http.Request(method, uri);
    request.headers.addAll(_headers);

    // Add cookies
    final cookies = _cookieManager.loadForRequest(uri);
    if (cookies.isNotEmpty) {
      request.headers['Cookie'] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Save cookies
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final parsedCookies = _parseCookies(setCookie, uri);
      _cookieManager.saveFromResponse(uri, parsedCookies);
    }

    return response;
  }

  List<Cookie> _parseCookies(String setCookie, Uri uri) {
    final cookies = <Cookie>[];
    final parts = setCookie.split(';');
    if (parts.isNotEmpty) {
      final nameValue = parts[0].split('=');
      if (nameValue.length == 2) {
        cookies.add(Cookie(nameValue[0].trim(), nameValue[1].trim()));
      }
    }
    return cookies;
  }

  // Auth
  Future<LoginResponse> login(String username, String password) async {
    final response = await _request('POST', AppConfig.apiAuthLogin, body: {
      'username': username,
      'password': password,
    });
    
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    }
    throw HttpException('HTTP ${response.statusCode}: ${response.body}');
  }

  // Routes
  Future<List<RouteData>> syncTodayRoutes({String? driver}) async {
    final params = <String, String>{};
    if (driver != null) params['driver'] = driver;
    
    final response = await _request('GET', AppConfig.apiRoutesSync, queryParams: params);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return (json['data'] as List).map((e) => RouteData.fromJson(e)).toList();
      }
      return [];
    }
    throw HttpException('HTTP ${response.statusCode}');
  }

  // Route Lines
  Future<UpdateStateResponse> startRouteLine(UpdateStateRequest request) async {
    final response = await _request('POST', AppConfig.apiRouteLineStart, body: request.toJson());
    return UpdateStateResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateStateResponse> pickupRouteLine(UpdateStateRequest request) async {
    final response = await _request('POST', AppConfig.apiRouteLinePickup, body: request.toJson());
    return UpdateStateResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateStateResponse> completeRouteLine(UpdateStateRequest request) async {
    final response = await _request('POST', AppConfig.apiRouteLineComplete, body: request.toJson());
    return UpdateStateResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateStateResponse> markLineIncomplete(IncompleteLineRequest request) async {
    final response = await _request('POST', AppConfig.apiRouteLineIncomplete, body: request.toJson());
    return UpdateStateResponse.fromJson(jsonDecode(response.body));
  }

  // Images
  Future<UploadImageResponse> uploadLineImage(UploadImageRequest request) async {
    final response = await _request('POST', AppConfig.apiRouteLineUploadImage, body: request.toJson());
    return UploadImageResponse.fromJson(jsonDecode(response.body));
  }

  // Driver Stats
  Future<DriverStatsResponse> getDriverStats(String driver, {String period = 'today'}) async {
    final response = await _request('GET', AppConfig.apiDriverStats, queryParams: {
      'driver': driver,
      'period': period,
    });
    return DriverStatsResponse.fromJson(jsonDecode(response.body));
  }

  // Routes History
  Future<RoutesHistoryResponse> getRoutesHistory(String driver, {int limit = 20, int offset = 0}) async {
    final response = await _request('GET', AppConfig.apiRoutesHistory, queryParams: {
      'driver': driver,
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    return RoutesHistoryResponse.fromJson(jsonDecode(response.body));
  }

  // Check new routes
  Future<CheckNewRoutesResponse> checkNewRoutes(String driver, {String? since}) async {
    final params = <String, String>{'driver': driver};
    if (since != null) params['since'] = since;
    
    final response = await _request('GET', AppConfig.apiRoutesCheckNew, queryParams: params);
    return CheckNewRoutesResponse.fromJson(jsonDecode(response.body));
  }

  // FCM Register
  Future<void> registerFcmToken(FcmTokenRequest request) async {
    await _request('POST', AppConfig.apiFcmRegister, body: request.toJson());
  }

  // History lines (lazy-load)
  Future<RouteHistoryLinesResponse> getRouteHistoryLines(int routeId) async {
    final response = await _request('GET', '${AppConfig.apiRoutesHistoryLines}/$routeId/lines');
    return RouteHistoryLinesResponse.fromJson(jsonDecode(response.body));
  }

  // Attachments
  Future<LineAttachmentsResponse> getLineAttachments(int lineId) async {
    final response = await _request('GET', '${AppConfig.apiLineAttachments}/$lineId');
    return LineAttachmentsResponse.fromJson(jsonDecode(response.body));
  }

  // Clear session
  Future<void> clearSession() async {
    _baseUrl = AppConfig.odooBaseUrl;
    await _cookieManager.clearCookies();
  }

  // Restore session
  Future<void> restoreSession() async {
    await _cookieManager.restoreCookies();
  }
}

class Cookie {
  final String name;
  final String value;
  final String? domain;
  final String? path;
  final DateTime? expires;
  final bool secure;
  final bool httpOnly;

  Cookie(this.name, this.value, {
    this.domain,
    this.path,
    this.expires,
    this.secure = false,
    this.httpOnly = false,
  });
}