import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/game_transition_service.dart';
import '../services/emotional_feedback_service.dart';
import '../services/notification_service.dart';
import '../widgets/tts_button.dart';
import '../widgets/study_mascot.dart';
import '../widgets/premium_game_card.dart';
import '../constants/assets.dart';
import 'word_games_screen.dart';
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
import 'educational_wordle_screen.dart';
import 'notifications_screen.dart';

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
  final List<bool> _cardPressed = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _welcomeUserHome();
  }

  /// Set up all 3D and floating animations
  void _setupAnimations() {
    // Card press animations
    _cardAnimationControllers = List.generate(7, (index) => 
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
        Navigator.pushReplacement(
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
                // Enhanced header with mascot
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Welcome text with emotional design
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Ready for your next challenge?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Animated mascot companion
                      MascotReactions.welcome(size: MascotSize.medium),
                      
                      const SizedBox(width: 12),
                      
                      // Notification icon
                      NotificationIcon(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Profile with micro-interaction
                      GestureDetector(
                        onTap: () {
                          EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.purple.shade400],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator with momentum
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EmotionalFeedbackService.createProgressAnimation(
                    progress: 0.67, // 67% through current level
                    label: 'Daily Goal Progress',
                    color: Colors.green,
                    showSparkles: true,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Games section with floating animation
                Expanded(
                  child: AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Games header with emotional design
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Choose Your Adventure',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    
                                    // Streak indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.orange.shade400, Colors.red.shade400],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '🔥',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            '12 day streak',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Premium game cards with emotional feedback
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  children: [
                                    GameCardFactory.mathChallenge(
                                      onTap: () => _navigateToGame(const MathGameScreen()),
                                      completedLevels: 7,
                                    ),
                                    
                                    GameCardFactory.educationalWordle(
                                      onTap: () => _navigateToGame(const EducationalWordleScreen()),
                                      completedLevels: 12,
                                    ),
                                    
                                    GameCardFactory.diagramExplorer(
                                      onTap: () => _navigateToGame(const FillDiagramScreen()),
                                      completedLevels: 5,
                                    ),
                                    
                                    GameCardFactory.memoryChallenge(
                                      onTap: () => _navigateToGame(const RepeatGameScreen()),
                                      completedLevels: 3,
                                      isLocked: false, // Unlock after completing 2 other games
                                    ),
                                    
                                    GameCardFactory.audioRepetition(
                                      onTap: () => _navigateToGame(const AudioRepetitionScreen()),
                                      completedLevels: 8,
                                    ),
                                    
                                    GameCardFactory.wordGames(
                                      onTap: () => _navigateToGame(const WordGamesScreen()),
                                      completedLevels: 15,
                                    ),
                                    
                                    const SizedBox(height: 100), // Bottom padding for nav
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Enhanced bottom navigation with micro-interactions
      bottomNavigationBar: _buildEnhancedBottomNav(),
    );
  }

  /// Navigate to game with emotional feedback and premium transitions
  void _navigateToGame(Widget gameScreen) {
    // Provide encouraging feedback
    EmotionalFeedbackService.celebrateSuccess(
      context,
      type: 'correct',
      intensity: 1,
    );
    
    // Speak encouragement
    _voiceAssistant.speak("Let's do this! Time to learn and have fun! 🚀");
    
    // Navigate with premium transition
    Navigator.push(
      context,
      GameTransitionService.createZoomTransition(gameScreen),
    );
  }

  Widget _buildEnhancedBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentlySelectedTab,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Learning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high_rounded),
            label: 'Converter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
        ],
      ),
      
      // Positioned TTS Button in bottom right
      floatingActionButton: const PositionedTTSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
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
                              _voiceAssistant.speak('Profile');
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
                
                // Games Section Header with 3D effect
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
                          'Choose Your Adventure!',
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
                
                // Enhanced 3D Game Cards Grid with Floating Effect
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
                            physics: const BouncingScrollPhysics(),
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
                                    const WordGamesScreen(),
                                    transitionType: 'zoom',
                                  );
                                },
                                0,
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
                                    transitionType: 'slide',
                                  );
                                },
                                1,
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
                                2,
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
                                    transitionType: 'slide',
                                  );
                                },
                                3,
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
                                4,
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
                                5,
                              ),
                              

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // TTS Button - moved to bottom right to avoid blocking header elements
          const Positioned(
            bottom: 100, // Above bottom navigation
            right: 16,
            child: TTSButton(),
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
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: _cardPressed[cardIndex] ? _cardElevationAnimations[cardIndex].value : 12,
                    spreadRadius: _cardPressed[cardIndex] ? 1 : 3,
                    offset: Offset(0, _cardPressed[cardIndex] ? 4 : 8),
                  ),
                  BoxShadow(
                    color: gradientColors[1].withOpacity(0.2),
                    blurRadius: _cardPressed[cardIndex] ? 8 : 16,
                    spreadRadius: 0,
                    offset: Offset(0, _cardPressed[cardIndex] ? 2 : 4),
                  ),
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
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
    final isSelected = _currentlySelectedTab == index;
    
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