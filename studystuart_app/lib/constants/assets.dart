/// Asset paths for StudyStewart app
/// All assets are organized by type and include exact Figma design assets
class AppAssets {
  // Screen References (for development comparison)
  static const String homeScreenRef = 'assets/screens/Home Screen.png';
  static const String dashboardScreenRef = 'assets/screens/Dashboard.png';
  static const String learningScreenRef = 'assets/screens/Learning.png';
  static const String converterScreenRef = 'assets/screens/Converter.png';
  static const String settingsScreenRef = 'assets/screens/Settings Light Mode.jpg';
  static const String loginScreenRef = 'assets/screens/login.png';
  static const String signupScreenRef = 'assets/screens/Sign up.png';
  static const String forgotScreenRef = 'assets/screens/forgot.png';
  static const String audioScreenRef = 'assets/screens/audio.png';
  static const String kinesticScreenRef = 'assets/screens/kinestic.png';
  static const String wordleScreenRef = 'assets/screens/wordle.png';
  
  // Navigation Icons
  static const String arrowLeft = 'assets/icons/arrow-left.svg';
  
  // UI Icons (with density variants)
  static const String star = 'assets/icons/star.png';
  static const String star2x = 'assets/icons/star@2x.png';
  static const String star3x = 'assets/icons/star@3x.png';
  
  static const String notification = 'assets/icons/notification.png';
  static const String notification2x = 'assets/icons/notification@2x.png';
  static const String notification3x = 'assets/icons/notification@3x.png';
  
  static const String profile = 'assets/icons/profile.png';
  static const String profile2x = 'assets/icons/profile@2x.png';
  
  static const String toggle = 'assets/icons/toggle.png';
  static const String toggle2x = 'assets/icons/toggle@2x.png';
  static const String toggle3x = 'assets/icons/toggle@3x.png';
  
  static const String darkMode = 'assets/icons/dark-mode.png';
  static const String darkMode2x = 'assets/icons/dark-mode@2x.png';
  static const String darkMode3x = 'assets/icons/dark-mode@3x.png';
  
  static const String logout = 'assets/icons/logout.png';
  static const String logout2x = 'assets/icons/logout@2x.png';
  static const String logout3x = 'assets/icons/logout@3x.png';
  
  static const String feedback = 'assets/icons/feedback.png';
  static const String feedback2x = 'assets/icons/feedback@2x.png';
  static const String feedback3x = 'assets/icons/feedback@3x.png';
  
  static const String privacy = 'assets/icons/privacy.png';
  static const String privacy2x = 'assets/icons/privacy@2x.png';
  static const String privacy3x = 'assets/icons/privacy@3x.png';
  
  static const String share = 'assets/icons/share.png';
  static const String share2x = 'assets/icons/share@2x.png';
  static const String share3x = 'assets/icons/share@3x.png';
  
  static const String setting = 'assets/icons/setting.png';
  static const String edit = 'assets/icons/edit.png';
  
  // Visual Elements & Backgrounds
  static const String progress76 = 'assets/images/76%.png';
  static const String progress76Alt = 'assets/images/76%-1.png';
  static const String rectangle39 = 'assets/images/Rectangle 39.png';
  static const String rectangle40 = 'assets/images/Rectangle 40.png';
  static const String displayPicture = 'assets/images/dp.png';
  static const String ellipse7 = 'assets/images/Ellipse 7.png';
  static const String background = 'assets/images/back.png';
  static const String background1 = 'assets/images/back-1.png';
  static const String background2 = 'assets/images/back-2.png';
  static const String background3 = 'assets/images/back-3.png';
  
  /// Helper method to get density-appropriate asset
  static String getDensityAsset(String basePath, {String? extension}) {
    // Flutter automatically handles @2x and @3x selection
    // Just return the base path and Flutter will choose the right density
    return basePath;
  }
  
  /// Get star icon with appropriate density
  static String getStarIcon() => star;
  
  /// Get notification icon with appropriate density  
  static String getNotificationIcon() => notification;
  
  /// Get profile icon with appropriate density
  static String getProfileIcon() => profile;
  
  /// Get toggle icon with appropriate density
  static String getToggleIcon() => toggle;
  
  /// Get dark mode icon with appropriate density
  static String getDarkModeIcon() => darkMode;
  
  /// Get logout icon with appropriate density
  static String getLogoutIcon() => logout;
  
  /// Get feedback icon with appropriate density
  static String getFeedbackIcon() => feedback;
  
  /// Get privacy icon with appropriate density
  static String getPrivacyIcon() => privacy;
  
  /// Get share icon with appropriate density
  static String getShareIcon() => share;
}

/// Asset dimensions extracted from Figma designs
class AssetDimensions {
  // Icon sizes (standard)
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  
  // Specific asset dimensions (measured from Figma)
  static const double arrowLeftWidth = 30.0;
  static const double arrowLeftHeight = 29.0;
  
  static const double starSize = 24.0;
  static const double notificationSize = 24.0;
  static const double profileSize = 40.0; // For avatar
  static const double toggleWidth = 51.0;
  static const double toggleHeight = 31.0;
  
  // Progress indicator dimensions
  static const double progressIndicatorSize = 60.0;
  
  // Background element dimensions
  static const double ellipse7Size = 120.0;
}