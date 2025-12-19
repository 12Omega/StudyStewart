import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import '../constants/assets.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'learning_screen.dart';
import 'dashboard_screen.dart';
import 'converter_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _ttsService = TTSService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() {
    _ttsService.speak('Welcome to Study Stuart home screen. Choose your game.');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Stay on Home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearningScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConverterScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with logo and profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue.shade100,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      
                      // Notification and Profile
                      Row(
                        children: [
                          // Asset Test Button (temporary)
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/asset-test'),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Text('Test Assets', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Image.asset(
                                    AppAssets.notification,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _ttsService.speak('Profile');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: AssetImage(AppAssets.displayPicture),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose Your Game',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Game Cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        // First game card
                        GestureDetector(
                          onTap: () {
                            _ttsService.speak('Starting word games');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GameScreen()),
                            );
                          },
                          child: Container(
                            width: 322,
                            height: 153,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade400, Colors.blue.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Word Games',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Second game card
                        GestureDetector(
                          onTap: () {
                            _ttsService.speak('Math challenge coming soon');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Math Challenge coming soon!')),
                            );
                          },
                          child: Container(
                            width: 310,
                            height: 169,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.teal.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Math Challenge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Third game card
                        GestureDetector(
                          onTap: () {
                            _ttsService.speak('Science quest coming soon');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Science Quest coming soon!')),
                            );
                          },
                          child: Container(
                            width: 292,
                            height: 194,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.orange.shade400, Colors.red.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Science Quest',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // TTS Button
          const Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TTSButton(),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 69,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 21,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, null, 'Home', 'home'),
            _buildNavItem(1, null, 'Learning', 'psychology'),
            _buildNavItem(2, null, 'Converter', 'converter'),
            _buildNavItem(3, AppAssets.setting, 'Setting', 'setting'),
            _buildNavItem(4, null, 'Dashboard', 'dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String? assetPath, String label, String iconName) {
    final isSelected = _selectedIndex == index;
    
    // Map icon names to Material Icons as fallback
    final iconMap = {
      'home': Icons.home,
      'psychology': Icons.psychology,
      'converter': Icons.auto_awesome,
      'setting': Icons.settings,
      'dashboard': Icons.dashboard,
    };
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      width: 22,
                      height: 22,
                      color: isSelected ? Colors.blue : Colors.black54,
                    )
                  : Icon(
                      iconMap[iconName] ?? Icons.help,
                      size: 22,
                      color: isSelected ? Colors.blue : Colors.black54,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
