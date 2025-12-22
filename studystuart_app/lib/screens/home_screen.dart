import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/game_transition_service.dart';
import '../widgets/tts_button.dart';
import '../constants/assets.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'learning_screen.dart';
import 'dashboard_screen.dart';
import 'converter_screen.dart';
import 'profile_screen.dart';
import 'math_game_screen.dart';
import 'fill_diagram_screen.dart';
import 'subway_surfer_screen.dart';
import 'audio_repetition_screen.dart';
import 'repeat_game_screen.dart';
import 'wordle_screen.dart';
import 'educational_wordle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TTSService _voiceAssistant = TTSService();
  int _currentlySelectedTab = 0;
  
  // Animation controllers for 3D effects
  late List<AnimationController> _cardAnimationControllers;
  late List<Animation<double>> _cardScaleAnimations;
  late List<Animation<double>> _cardElevationAnimations;
  
  // Floating animation for the games container
  late AnimationController _floatingAnimationController;
  late Animation<double> _floatingAnimation;
  
  // Track which cards are being pressed for 3D effects
  final List<bool> _cardPressed = List.filled(8, false);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _welcomeUserHome();
  }

  /// Set up all 3D and floating animations
  void _setupAnimations() {
    // Card press animations
    _cardAnimationControllers = List.generate(8, (index) => 
      AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      )
    );
    
    _cardScaleAnimations = _cardAnimationControllers.map((controller) =>
      Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
      )
    ).toList();
    
    _cardElevationAnimations = _cardAnimationControllers.map((controller) =>
      Tween<double>(begin: 8.0, end: 16.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
      )
    ).toList();
    
    // Subtle floating animation for the games container
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start the floating animation with a slight delay for a more natural feel
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _floatingAnimationController.repeat(reverse: true);
      }
    });
  }

  /// Give our user a warm, friendly welcome to their learning journey
  void _welcomeUserHome() {
    _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('home'));
  }

  /// Handle navigation between different sections of our app
  void _onBottomNavTap(int selectedTabIndex) {
    setState(() {
      _currentlySelectedTab = selectedTabIndex;
    });
    
    switch (selectedTabIndex) {
      case 0:
        // User wants to stay on the home screen - they're already here!
        break;
      case 1:
        // Time to explore the learning section!
        _voiceAssistant.speak("Let's explore different ways you love to learn!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearningScreen()),
        );
        break;
      case 2:
        // Time to convert some content into games
        _voiceAssistant.speak("Ready to turn your study materials into fun games?");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConverterScreen()),
        );
        break;
      case 3:
        // Visit the settings to customize the experience
        _voiceAssistant.speak("Let's make Study Stuart work perfectly for you!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        // Check out the dashboard to see progress
        _voiceAssistant.speak("Let's see how amazing your learning journey has been!");
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
                
                const SizedBox(height: 30),
                
                // 🎮 Games Section Header with 3D effect
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.purple.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.games,
                          color: Colors.blue.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '🎮 Choose Your Adventure!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // 🎯 Enhanced 3D Game Cards Grid with Floating Effect
                Expanded(
                  child: AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 5,
                                offset: Offset(0, 10 + _floatingAnimation.value),
                              ),
                              // Additional shadow for more depth
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.05),
                                blurRadius: 40,
                                spreadRadius: 10,
                                offset: Offset(0, 15 + _floatingAnimation.value),
                              ),
                            ],
                          ),
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.85,
                            physics: const BouncingScrollPhysics(), // Smooth bouncy scrolling
                            children: [
                        // Word Games
                        _buildGameCard(
                          'Word Games',
                          Icons.text_fields,
                          [Colors.purple.shade400, Colors.blue.shade400],
                          () {
                            _voiceAssistant.speak('Time for some word fun! Let\'s play and learn together!');
                            GameTransitionService.navigateToGame(
                              context, 
                              const GameScreen(),
                              transitionType: 'zoom',
                            );
                          },
                          0, // Card index for animation
                        ),
                        
                        // Math Challenge
                        _buildGameCard(
                          'Math Challenge',
                          Icons.calculate,
                          [Colors.orange.shade400, Colors.red.shade400],
                          () {
                            _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('math'));
                            GameTransitionService.navigateToGame(
                              context, 
                              const MathGameScreen(),
                              transitionType: 'flip',
                            );
                          },
                          1, // Card index for animation
                        ),
                        
                        // Educational Wordle
                        _buildGameCard(
                          'Educational Wordle',
                          Icons.school,
                          [Colors.teal.shade400, Colors.cyan.shade400],
                          () {
                            _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('wordle'));
                            GameTransitionService.navigateToGame(
                              context, 
                              const EducationalWordleScreen(),
                              transitionType: 'slide',
                            );
                          },
                          2, // Card index for animation
                        ),
                        
                        // Subway Surfer
                        _buildGameCard(
                          'Subway Surfer',
                          Icons.train,
                          [Colors.lightBlue.shade400, Colors.green.shade400],
                          () {
                            _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('subway'));
                            GameTransitionService.navigateToGame(
                              context, 
                              const SubwaySurferScreen(),
                              transitionType: 'zoom',
                            );
                          },
                          3, // Card index for animation
                        ),
                        
                        // Fill in the Diagram
                        _buildGameCard(
                          'Fill in the Diagram',
                          Icons.quiz,
                          [Colors.purple.shade400, Colors.indigo.shade400],
                          () {
                            _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('diagram'));
                            GameTransitionService.navigateToGame(
                              context, 
                              const FillDiagramScreen(),
                              transitionType: 'flip',
                            );
                          },
                          4, // Card index for animation
                        ),
                        
                        // Audio Repetition
                        _buildGameCard(
                          'Audio Repetition',
                          Icons.hearing,
                          [Colors.indigo.shade400, Colors.purple.shade400],
                          () {
                            _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('audio'));
                            GameTransitionService.navigateToGame(
                              context, 
                              const AudioRepetitionScreen(),
                              transitionType: 'slide',
                            );
                          },
                          5, // Card index for animation
                        ),
                        
                        // Repeat Game
                        _buildGameCard(
                          'Repeat Game',
                          Icons.replay,
                          [Colors.pink.shade400, Colors.purple.shade400],
                          () {
                            _voiceAssistant.speak('Memory challenge time! Let\'s see how well you can remember patterns!');
                            GameTransitionService.navigateToGame(
                              context, 
                              const RepeatGameScreen(),
                              transitionType: 'zoom',
                            );
                          },
                          6, // Card index for animation
                        ),
                        
                        // Wordle (existing)
                        _buildGameCard(
                          'Wordle',
                          Icons.grid_3x3,
                          [Colors.cyan.shade400, Colors.blue.shade400],
                          () {
                            _voiceAssistant.speak('Classic word puzzle time! Can you guess the mystery word?');
                            GameTransitionService.navigateToGame(
                              context, 
                              const WordleScreen(),
                              transitionType: 'flip',
                            );
                          },
                          7, // Card index for animation
                        ),
                      ],
                    ),
                  ),
                        ),
                      ),
                ),
                
                const SizedBox(height: 20),
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

  /// Create a stunning 3D game card that screams "CLICK ME!"
  Widget _buildGameCard(String title, IconData icon, List<Color> gradientColors, VoidCallback onTap, int cardIndex) {
    return AnimatedBuilder(
      animation: Listenable.merge([_cardScaleAnimations[cardIndex], _cardElevationAnimations[cardIndex]]),
      builder: (context, child) {
        return Transform.scale(
          scale: _cardPressed[cardIndex] ? _cardScaleAnimations[cardIndex].value : 1.0,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _cardPressed[cardIndex] = true);
              _cardAnimationControllers[cardIndex].forward();
              // Add haptic feedback for better UX
              // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
            },
            onTapUp: (_) {
              setState(() => _cardPressed[cardIndex] = false);
              _cardAnimationControllers[cardIndex].reverse();
              onTap();
            },
            onTapCancel: () {
              setState(() => _cardPressed[cardIndex] = false);
              _cardAnimationControllers[cardIndex].reverse();
            },
            child: Container(
              height: 140, // Fixed height for consistency
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Main shadow for depth
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: _cardPressed[cardIndex] ? _cardElevationAnimations[cardIndex].value : 12,
                    spreadRadius: _cardPressed[cardIndex] ? 1 : 3,
                    offset: Offset(0, _cardPressed[cardIndex] ? 4 : 8),
                  ),
                  // Secondary shadow for more depth
                  BoxShadow(
                    color: gradientColors[1].withOpacity(0.2),
                    blurRadius: _cardPressed[cardIndex] ? 8 : 16,
                    spreadRadius: 0,
                    offset: Offset(0, _cardPressed[cardIndex] ? 2 : 4),
                  ),
                  // Inner highlight for 3D effect
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: -2,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Add subtle inner shadow for more depth
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: -2,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Animated background gradient overlay
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _cardPressed[cardIndex] 
                              ? [
                                  gradientColors[0].withOpacity(0.9),
                                  gradientColors[1].withOpacity(0.9),
                                ]
                              : [
                                  gradientColors[0],
                                  gradientColors[1],
                                ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      
                      // Shimmer effect overlay
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _cardPressed[cardIndex] ? 0.3 : 0.1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 3D Icon with shadow
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                size: 32,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // 3D Text with shadow
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            // Subtle "tap me" indicator
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _cardPressed[cardIndex] ? 20 : 30,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Floating "play" indicator in corner
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _cardPressed[cardIndex] ? 1.0 : 0.7,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 16,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

  @override
  void dispose() {
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    _floatingAnimationController.dispose();
    super.dispose();
  }
}
