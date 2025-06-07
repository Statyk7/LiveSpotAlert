class AppConstants {
  static const String appName = 'LiveSpotAlert';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String geofencesKey = 'geofences';
  static const String mediaItemsKey = 'media_items';
  static const String settingsKey = 'app_settings';
  
  // Geofencing
  static const double defaultGeofenceRadius = 100.0; // meters
  static const int maxGeofences = 20;
  
  // Live Activities
  static const int liveActivityDurationMinutes = 30;
  static const String liveActivityType = 'LocationAlert';
  
  // Media
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const int maxImageSizeMB = 5;
}