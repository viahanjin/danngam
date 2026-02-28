/// Application Configuration
/// Centralized app settings and constants
class AppConfig {
  AppConfig._();

  // App Information
  static const String appName = 'Danngam';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000'; // Development
  // static const String apiBaseUrl = 'https://api.danngam.com'; // Production
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Feature Configuration
  static const int minPhoneNumberLength = 10;
  static const int maxPhoneNumberLength = 15;
  static const int otpLength = 6;
  static const Duration otpExpiration = Duration(minutes: 5);

  // UI Configuration
  static const double defaultBorderRadius = 24.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration transitionDuration = Duration(milliseconds: 500);

  // Pagination
  static const int pageSize = 20;
  static const int maxItems = 1000;

  // Location Configuration
  static const double nearbySearchRadius = 30.0; // km
  static const int nearbySearchResultLimit = 50;

  // Cache Configuration
  static const Duration imageCacheDuration = Duration(days: 7);
  static const Duration dataCacheDuration = Duration(minutes: 5);

  // Logging Configuration
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;
}
