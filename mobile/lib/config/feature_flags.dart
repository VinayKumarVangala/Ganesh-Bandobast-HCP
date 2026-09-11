class FeatureFlags {
  static const bool enableResourceSharing = true;
  static const bool enableRealtimeSync = false;
  static const bool enablePushNotifications = false;
  static const bool enableOfflineQueue = false;
  static const bool enableAuditLog = false;
  static const bool useStaticData = true;
  static const bool enableMapmyIndia = true;
  static const bool enableRealAuth = false;
}

class AppConfig {
  static const String appName = 'Ganesh Bandobust';
  static const String version = '1.0.0+1';
  static const int defaultSearchRadiusKm = 15;
  static const int slaNormalMinutes = 60;
  static const int slaUrgentMinutes = 20;
  static const int slaEmergencyMinutes = 0;
  static const String defaultTimezone = 'Asia/Kolkata';
}