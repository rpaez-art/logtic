class AppConfig {
  static const String appName = 'LogTic';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Corporación Crea 21, CA';
  
  // Odoo Configuration
  static const String odooBaseUrl = 'https://etc-corpocrea.odoo.com/';
  static const String odooDatabase = 'etc-corpocrea';
  
  // API Endpoints
  static const String apiAuthLogin = 'api/auth/login';
  static const String apiRoutesSync = 'api/routes/sync';
  static const String apiRoutesDriver = 'api/routes/driver';
  static const String apiRouteDetails = 'api/routes';
  static const String apiRouteLineStart = 'api/routes/line/start';
  static const String apiRouteLinePickup = 'api/routes/line/pickup';
  static const String apiRouteLineComplete = 'api/routes/line/complete';
  static const String apiRouteLineIncomplete = 'api/routes/line/incomplete';
  static const String apiRouteLineUploadImage = 'api/routes/line/upload-image';
  static const String apiRouteLineImage = 'api/routes/line/image';
  static const String apiRouteState = 'api/routes/state';
  static const String apiDriverStats = 'api/driver/stats';
  static const String apiRoutesHistory = 'api/routes/history';
  static const String apiRoutesCheckNew = 'api/routes/check-new';
  static const String apiFcmRegister = 'api/fcm/register';
  static const String apiLineAttachments = 'api/routes/line/attachments';
  static const String apiAttachment = 'api/attachment';

  // Shared Preferences Keys
  static const String prefsIsLoggedIn = 'is_logged_in';
  static const String prefsUsername = 'username';
  static const String prefsPassword = 'password';
  static const String prefsFullName = 'full_name';
  static const String prefsRole = 'role';
  static const String prefsDriverCode = 'driver_code';
  static const String prefsDriverId = 'driver_id';
  static const String prefsDriverName = 'driver_name';
  static const String prefsOdooUrl = 'odoo_url';
  static const String prefsOdooDatabase = 'odoo_database';
  static const String prefsOdooUsername = 'odoo_username';
  static const String prefsCookieHosts = 'cookie_hosts';
  static const String prefsCookiesPrefix = 'cookies_';
  static const String prefsFcmToken = 'fcm_token';
  static const String prefsFcmTokenSent = 'fcm_token_sent';
}