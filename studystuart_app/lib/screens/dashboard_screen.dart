import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/emotional_feedback_service.dart';
import '../services/notification_service.dart';
import '../widgets/tts_button.dart';
import '../widgets/study_mascot.dart';
import '../widgets/character_avatar.dart';
import '../models/user_character.dart';
import '../constants/assets.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'converter_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  int _selectedIndex = 4; // Dashboard tab is selected
  
  // Animation controllers for emotional design
  late AnimationController _statsAnimationController;
  late AnimationController _achievementController;
  late AnimationController _leaderboardController;
  late List<Animation<double>> _statAnimations;
  late Animation<Offset> _slideAnimation;
  
  // User progress data (would come from a service in real app)
  final int _userXP = 2847;
  final int _nextLevelXP = 3000;
  final int _challengesCompleted = 23;
  final int _milestonesReached = 7;
  final int _currentStreak = 12;
  final int _userRank = 3;
  
  // Sample user character (in real app, this would come from user service)
  late final UserCharacter _currentUser;
  late final List<UserCharacter> _leaderboardUsers;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _setupAnimations();
    _speakWelcome();
    _startAnimations();
  }

  void _initializeUserData() {
    // Initialize current user (in real app, this would come from user service)
    _currentUser = UserCharacter(
      id: 'current_user',
      name: 'You',
      ethnicity: NepalEthnicity.gurung,
      gender: Gender.other,
      skinTone: SkinTone.medium,
      hairStyle: HairStyle.modern,
      clothing: ClothingStyle.student,
      accessories: AccessoryStyle.glasses,
      customMessage: 'Learning is my superpower!',
      createdAt: DateTime.now(),
    );
    
    // Initialize leaderboard users with diverse representation
    _leaderboardUsers = [
      UserCharacter(
        id: 'user_1',
        name: 'Pemba Sherpa',
        ethnicity: NepalEthnicity.sherpa,
        gender: Gender.male,
        skinTone: SkinTone.medium,
        hairStyle: HairStyle.short,
        clothing: ClothingStyle.traditional,
        accessories: AccessoryStyle.hat,
        createdAt: DateTime.now(),
      ),
      UserCharacter(
        id: 'user_2',
        name: 'Sujata Newar',
        ethnicity: NepalEthnicity.newar,
        gender: Gender.female,
        skinTone: SkinTone.mediumLight,
        hairStyle: HairStyle.braided,
        clothing: ClothingStyle.cultural,
        accessories: AccessoryStyle.jewelry,
        createdAt: DateTime.now(),
      ),
      _currentUser, // Current user at rank 3
      UserCharacter(
        id: 'user_4',
        name: 'Rajesh Tharu',
        ethnicity: NepalEthnicity.tharu,
        gender: Gender.male,
        skinTone: SkinTone.mediumDark,
        hairStyle: HairStyle.straight,
        clothing: ClothingStyle.traditional,
        accessories: AccessoryStyle.hat,
        createdAt: DateTime.now(),
      ),
      UserCharacter(
        id: 'user_5',
        name: 'Maya Tamang',
        ethnicity: NepalEthnicity.tamang,
        gender: Gender.female,
        skinTone: SkinTone.medium,
        hairStyle: HairStyle.long,
        clothing: ClothingStyle.modern,
        accessories: AccessoryStyle.flowers,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void _setupAnimations() {
    // Stats cards animation
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Create staggered animations for each stat card
    _statAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _statsAnimationController,
        curve: Interval(
          index * 0.2,
          0.6 + (index * 0.2),
          curve: Curves.elasticOut,
        ),
      ));
    });
    
    // Achievement badges animation
    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Leaderboard animation
    _leaderboardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _leaderboardController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _statsAnimationController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _achievementController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _leaderboardController.forward();
      }
    });
  }

  @override
  void dispose() {
    _statsAnimationController.dispose();
    _achievementController.dispose();
    _leaderboardController.dispose();
    super.dispose();
  }

  void _speakWelcome() {
    _ttsService.speak('Dashboard. View your progress and leaderboards.');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LearningScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConverterScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        // Stay on Dashboard
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Enhanced background with emotional gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade400,
                  Colors.pink.shade300,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Enhanced header with mascot (removed back arrow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo (replacing back arrow)
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.dashboard,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      
                      // Animated mascot
                      StudyMascot(
                        emotion: MascotEmotion.happy,
                        size: MascotSize.medium,
                        message: "Great progress! 📊",
                      ),
                      
                      // Notification and Profile
                      Row(
                        children: [
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
                          
                          SizedBox(width: 8),
                          
                          // User's character avatar
                          CharacterAvatar(
                            character: _currentUser,
                            size: AvatarSize.small,
                            showName: false,
                            isAnimated: true,
                            showBorder: true,
                            borderColor: Colors.white,
                            onTap: () {
                              // Navigate to profile or show character details
                              EmotionalFeedbackService.celebrateSuccess(
                                context,
                                type: 'correct',
                                intensity: 1,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome section with progress
                          _buildWelcomeSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Animated stats cards
                          _buildStatsSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Achievement badges
                          _buildAchievementsSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Leaderboard
                          _buildLeaderboardSection(),
                          
                          const SizedBox(height: 100), // Bottom padding for nav
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Enhanced bottom navigation
      bottomNavigationBar: _buildBottomNavigation(),
      
      // Positioned TTS Button in bottom right
      floatingActionButton: const PositionedTTSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWelcomeSection() {
    final progressPercentage = _userXP / _nextLevelXP;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Learning Journey',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // XP Progress with momentum animation
        EmotionalFeedbackService.createProgressAnimation(
          progress: progressPercentage,
          label: 'Level Progress',
          color: Colors.blue,
          showSparkles: true,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '$_userXP / $_nextLevelXP XP',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {'title': 'Challenges\nCompleted', 'value': '$_challengesCompleted', 'icon': Icons.check_circle, 'color': Colors.green},
      {'title': 'Current\nStreak', 'value': '$_currentStreak', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'title': 'Milestones\nReached', 'value': '$_milestonesReached', 'icon': Icons.flag, 'color': Colors.purple},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            
            return Expanded(
              child: AnimatedBuilder(
                animation: _statAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _statAnimations[index].value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (stat['color'] as Color).withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (stat['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              stat['icon'] as IconData,
                              color: stat['color'] as Color,
                              size: 24,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            stat['value'] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            stat['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      {'title': 'Active Learner', 'emoji': '🔥', 'description': '7 day streak'},
      {'title': 'Math Master', 'emoji': '🧮', 'description': '50 problems solved'},
      {'title': 'Word Wizard', 'emoji': '📚', 'description': '100 words learned'},
      {'title': 'Speed Demon', 'emoji': '⚡', 'description': 'Under 30 seconds'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        AnimatedBuilder(
          animation: _achievementController,
          builder: (context, child) {
            return Transform.scale(
              scale: _achievementController.value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.yellow.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: achievements.map((achievement) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              achievement['emoji'] as String,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  achievement['description'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection() {
    final leaderboardData = [
      {'character': _leaderboardUsers[0], 'score': 3247, 'rank': 1},
      {'character': _leaderboardUsers[1], 'score': 3156, 'rank': 2},
      {'character': _leaderboardUsers[2], 'score': _userXP, 'rank': _userRank},
      {'character': _leaderboardUsers[3], 'score': 2734, 'rank': 4},
      {'character': _leaderboardUsers[4], 'score': 2689, 'rank': 5},
    ];
    
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: leaderboardData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final character = data['character'] as UserCharacter;
                final score = data['score'] as int;
                final rank = data['rank'] as int;
                final isCurrentUser = character.id == _currentUser.id;
                
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: index == 0 
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          )
                        : index == leaderboardData.length - 1
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              )
                            : null,
                  ),
                  child: LeaderboardCharacterAvatar(
                    character: character,
                    rank: rank,
                    score: score,
                    isCurrentUser: isCurrentUser,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange.shade300;
      default:
        return Colors.blue;
    }
  }

  String _getTrophyEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🏆';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.transform), label: 'Converter'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      // Logo
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      
                      // Notification and Profile
                      Row(
                        children: [
                          Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.notifications_outlined, 
                                    size: 20, color: Colors.white),
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
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // User Profile Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 29,
                        backgroundImage: AssetImage(AppAssets.displayPicture),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Sebastian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress Section
                      Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.75,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '2000/2500 xp',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '75%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('20', 'Challenges done'),
                          _buildStatCard('10', 'Milestone met'),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Achievement Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBadge(Icons.school, 'Active Learner'),
                          _buildBadge(Icons.emoji_events, 'Number 1'),
                          _buildBadge(Icons.star, 'Critical Thinker'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Leaderboard Section
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF151729),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leaderboards',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Expanded(
                            child: ListView(
                              children: [
                                _buildLeaderboardItem(1, 'Sebastian', '@username', '1124', true),
                                _buildDivider(),
                                _buildLeaderboardItem(2, 'Jason', '@username', '875', false),
                                _buildDivider(),
                                _buildLeaderboardItem(3, 'Sam', '@username', '774', false),
                                _buildDivider(),
                                _buildLeaderboardItem(4, 'Monica', '@username', '723', false),
                              ],
                            ),
                          ),
                        ],
                      ),
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
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.psychology, 'Learning'),
            _buildNavItem(2, Icons.auto_awesome, 'Converter'),
            _buildNavItem(3, Icons.settings, 'Setting'),
            _buildNavItem(4, Icons.dashboard, 'Dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      width: 72,
      height: 39,
      decoration: BoxDecoration(
        color: Color(0xFF151729),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String username, String score, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        _ttsService.speak('Rank $rank. $name. Score $score points.');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Rank
            Container(
              width: 20,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 24,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Name and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Score
            Text(
              score,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Trend arrow
            Icon(
              rank <= 2 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: rank <= 2 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
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
              child: Icon(
                icon,
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