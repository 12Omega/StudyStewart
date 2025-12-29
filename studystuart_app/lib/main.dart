import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/character_creation_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
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
      
      // Force left-to-right text direction globally
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
      
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
      
      // Determine initial screen based on user status
      home: const InitialScreenLoader(),
      
      // Special routes for testing and development
      routes: {
        '/asset-test': (context) => const FigmaAssetExamples(),
      },
    );
  }
}

/// 🚀 Initial Screen Loader - Smart Navigation for User Experience
/// 
/// This widget determines which screen to show based on the user's status:
/// - New users: Character Creation → Auth → Home
/// - Returning users without login: Auth → Home  
/// - Returning logged-in users: Home directly
class InitialScreenLoader extends StatefulWidget {
  const InitialScreenLoader({super.key});

  @override
  State<InitialScreenLoader> createState() => _InitialScreenLoaderState();
}

class _InitialScreenLoaderState extends State<InitialScreenLoader> {
  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  /// Smart navigation logic based on user preferences and login status
  Future<void> _determineInitialScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check user status flags
      final hasCreatedCharacter = prefs.getBool('character_created') ?? false;
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
      
      // Add a small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      Widget targetScreen;
      
      if (!hasCreatedCharacter) {
        // First-time user - start with character creation
        targetScreen = const CharacterCreationScreen();
      } else if (!isLoggedIn) {
        // Returning user who needs to log in
        targetScreen = const AuthScreen();
      } else {
        // Logged-in returning user - go straight to home
        targetScreen = const HomeScreen();
      }
      
      // Navigate to the determined screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
      
    } catch (e) {
      // If there's any error, default to character creation for safety
      debugPrint('Error determining initial screen: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CharacterCreationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade300,
              Colors.purple.shade300,
              Colors.pink.shade200,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Icon(
                Icons.school,
                size: 80,
                color: Colors.white,
              ),
              
              SizedBox(height: 20),
              
              Text(
                'StudyStewart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Your Personal Learning Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              SizedBox(height: 40),
              
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              
              SizedBox(height: 16),
              
              Text(
                'Loading your learning journey...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}