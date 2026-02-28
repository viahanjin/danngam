/// Feature Flags for Danngam App
/// Controls which features are enabled/disabled
class FeatureFlags {
  FeatureFlags._();

  // Auth Module
  static const bool enableAuth = true;
  static const bool enableOnboarding = true;

  // Equipment Module
  static const bool enableEquipment = true;
  static const bool enableNearbySearch = true;
  static const bool enableCategoryFilter = true;

  // Booking Module
  static const bool enableBooking = true;
  static const bool enableBookingHistory = true;

  // Payment Module
  static const bool enablePayment = true;

  // Chat Module
  static const bool enableChat = false; // Phase 2+
  static const bool enableNotifications = false; // Phase 2+

  // Review Module
  static const bool enableReview = false; // Phase 2+

  // Map Module
  static const bool enableMap = false; // Phase 2+

  // Admin Features
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceMonitoring = false;
}
