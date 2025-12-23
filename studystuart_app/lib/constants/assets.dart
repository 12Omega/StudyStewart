/// 🎨 StudyStuart Asset Library - Where All Our Beautiful Resources Live!
/// 
/// This is our treasure chest of images, icons, and educational materials.
/// Everything is organized and easy to find, with helpful methods to get
/// exactly what you need for the perfect learning experience.
class AppAssets {
  // 📱 Screen References - These help our designers compare the real app to the designs
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
  
  // 🧭 Navigation Icons - Help users find their way around
  static const String arrowLeft = 'assets/icons/arrow-left.svg';
  
  // ⭐ UI Icons - The little symbols that make the interface friendly
  // (We have multiple sizes for different screen densities - crisp on every device!)
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
  
  // 🎨 Visual Elements & Backgrounds - Make everything look amazing
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
  
  /// 🔧 Smart helper - Flutter automatically picks the right image density
  /// Just give it the base path and it handles the @2x and @3x magic!
  static String getDensityAsset(String basePath, {String? extension}) {
    return basePath; // Flutter's got our back on this one
  }
  
  /// ⭐ Get the perfect star icon for any screen
  static String getStarIcon() => star;
  
  // 🔬 Educational Diagrams - Where learning comes to life!
  static const String heartDiagram = 'assets/diagrams/heart_diagram.svg';
  static const String plantCellDiagram = 'assets/diagrams/plant_cell_diagram.svg';
  static const String solarSystemDiagram = 'assets/diagrams/solar_system_diagram.svg';
  
  // 🧮 Math Visual Aids - Making numbers fun and understandable!
  static const String additionVisual = 'assets/math-aids/addition_visual.svg';
  static const String subtractionVisual = 'assets/math-aids/subtraction_visual.svg';
  static const String multiplicationVisual = 'assets/math-aids/multiplication_visual.svg';
  static const String divisionVisual = 'assets/math-aids/division_visual.svg';
  
  /// 🎯 Smart Math Helper - Get the perfect visual for any math operation!
  /// 
  /// Just tell us what operation you're working with, and we'll give you
  /// the most helpful visual aid to make that concept crystal clear.
  static String getMathVisual(String operation) {
    switch (operation) {
      case '+':
        return additionVisual; // Show dots coming together
      case '-':
        return subtractionVisual; // Show items being taken away
      case '×':
        return multiplicationVisual; // Show groups and patterns
      case '÷':
        return divisionVisual; // Show fair sharing
      default:
        return additionVisual; // When in doubt, start with addition
    }
  }
  
  /// 🔬 Smart Diagram Helper - Find the perfect educational diagram!
  /// 
  /// Whether you're exploring anatomy, biology, or astronomy, we've got
  /// the right diagram to make learning visual and engaging.
  static String getDiagram(String type) {
    switch (type.toLowerCase()) {
      case 'heart':
        return heartDiagram; // Explore the amazing human heart
      case 'plant':
      case 'cell':
        return plantCellDiagram; // Dive into the microscopic world
      case 'solar':
      case 'system':
        return solarSystemDiagram; // Journey through space
      default:
        return heartDiagram; // Default to the heart - it's pretty amazing!
    }
  }
  
  // 🎯 Quick Icon Getters - One-stop shop for all your icon needs!
  
  /// 🔔 Get notification bell - never miss an important update
  static String getNotificationIcon() => notification;
  
  /// 👤 Get profile avatar - show off your learning personality
  static String getProfileIcon() => profile;
  
  /// 🔄 Get toggle switch - for all your on/off needs
  static String getToggleIcon() => toggle;
  
  /// 🌙 Get dark mode icon - easy on the eyes for night owls
  static String getDarkModeIcon() => darkMode;
  
  /// 👋 Get logout icon - see you later, alligator!
  static String getLogoutIcon() => logout;
  
  /// 💬 Get feedback icon - we love hearing from you
  static String getFeedbackIcon() => feedback;
  
  /// 🔒 Get privacy icon - your data is safe with us
  static String getPrivacyIcon() => privacy;
  
  /// 📤 Get share icon - spread the learning love
  static String getShareIcon() => share;
}

/// 📏 Asset Dimensions - Perfect sizing for every screen!
/// 
/// These measurements come straight from our Figma designs, ensuring
/// everything looks exactly as intended on every device.
class AssetDimensions {
  // 🎯 Standard Icon Sizes - From tiny to mighty
  static const double iconSmall = 16.0;    // For subtle accents
  static const double iconMedium = 24.0;   // The sweet spot for most uses
  static const double iconLarge = 32.0;    // When you need more presence
  static const double iconXLarge = 48.0;   // For hero elements
  
  // 🎨 Specific Asset Dimensions - Measured with love from Figma
  static const double arrowLeftWidth = 30.0;
  static const double arrowLeftHeight = 29.0;
  
  static const double starSize = 24.0;           // Perfect for ratings
  static const double notificationSize = 24.0;   // Friendly reminder size
  static const double profileSize = 40.0;        // Great for avatars
  static const double toggleWidth = 51.0;        // Comfortable switching
  static const double toggleHeight = 31.0;
  
  // 📊 Progress & Visual Elements
  static const double progressIndicatorSize = 60.0;  // Clear progress tracking
  static const double ellipse7Size = 120.0;          // Decorative elements
}