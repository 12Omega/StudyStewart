import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'converter_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TTSService _ttsService = TTSService();
  int _selectedIndex = 4; // Dashboard tab is selected

  @override
  void initState() {
    super.initState();
    _speakWelcome();
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
        Navigator.push(
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
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade400,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header with logo and profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back arrow
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
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
                      Container(
                        width: 58,
                        height: 59,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
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