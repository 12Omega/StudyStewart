import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'services/tts_service.dart';
import 'services/settings_service.dart';
import 'widgets/figma_asset_examples.dart';

/// 🎓 StudyStuart - Your Personal Learning Companion
/// 
/// This is where the magic begins! We're setting up all the essential services
/// that make StudyStuart work smoothly - from text-to-speech for accessibility
/// to user preferences that remember how you like things.
void main() async {
  // Make sure Flutter is ready before we start our services
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🗣️ Get our voice assistant ready to help with learning
  await TTSService().initialize();
  
  // ⚙️ Load up user preferences and settings
  await SettingsService().initialize();
  
  // 🚀 Launch the StudyStuart experience!
  runApp(const StudyStuartApp());
}

/// The heart of our StudyStuart app - where learning becomes an adventure!
/// 
/// This widget manages the overall app experience, including themes,
/// user preferences, and the smooth transitions between light and dark modes.
class StudyStuartApp extends StatefulWidget {
  const StudyStuartApp({super.key});

  @override
  State<StudyStuartApp> createState() => _StudyStuartAppState();
}

class _StudyStuartAppState extends State<StudyStuartApp> {
  // Our settings manager - keeps track of user preferences
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    // Listen for when users change their preferences (like switching themes)
    _settingsService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    // Clean up our listeners when the app closes
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// When settings change, refresh the app to show the updates
  void _onSettingsChanged() {
    setState(() {
      // This triggers a rebuild with the new settings
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyStuart',
      
      // Respect user's theme preference (light/dark/system)
      themeMode: _settingsService.themeMode,
      
      // 🌞 Light theme - bright and cheerful for daytime learning
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Latest Material Design for modern look
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade50, // Soft, easy on the eyes
        cardTheme: CardThemeData(
          elevation: 2, // Subtle shadows for depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Friendly rounded corners
          ),
        ),
      ),
      
      // 🌙 Dark theme - easy on the eyes for evening study sessions
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade900, // Deep, comfortable dark
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Start the journey at our welcoming authentication screen
      home: const AuthScreen(),
      
      // Special routes for testing and development
      routes: {
        '/asset-test': (context) => const FigmaAssetExamples(),
      },
    );
  }
}
