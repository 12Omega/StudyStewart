import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TTSService _ttsService = TTSService();
  final TextEditingController _textController = TextEditingController();
  int _selectedIndex = 2; // Converter tab is selected
  String _selectedLearningMethod = '';

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() {
    _ttsService.speak('Game Converter. Upload material or paste text to convert to learning games.');
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
        // Stay on Converter
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
    }
  }

  void _selectLearningMethod(String method) {
    setState(() {
      _selectedLearningMethod = method;
    });
    _ttsService.speak('Selected $method learning method');
  }

  void _uploadFile() {
    _ttsService.speak('File upload feature coming soon');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File upload feature coming soon!')),
    );
  }

  void _convertContent() {
    if (_textController.text.isEmpty && _selectedLearningMethod.isEmpty) {
      _ttsService.speak('Please enter text and select a learning method');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text and select a learning method')),
      );
      return;
    }
    
    _ttsService.speak('Converting content to $_selectedLearningMethod game');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Converting to $_selectedLearningMethod game...')),
    );
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
                        width: 75,
                        height: 75,
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
                          Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.notifications_outlined, size: 20),
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
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Game Converter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Upload Material',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Upload Section
                        GestureDetector(
                          onTap: _uploadFile,
                          child: Container(
                            width: double.infinity,
                            height: 155,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Drag & drop files or Browse',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Supported formats: JPEG, PNG, MP4, PDF, Word, PPT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Or divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Text Input
                        Container(
                          width: double.infinity,
                          height: 97,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              hintText: 'Paste your text here',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Learning Method Selection
                        Text(
                          'Choose Learning Method',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Learning Method Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.7,
                          children: [
                            _buildMethodCard('Visual', Icons.visibility, 'visual'),
                            _buildMethodCard('Auditory', Icons.hearing, 'auditory'),
                            _buildMethodCard('Kinesthetic', Icons.touch_app, 'kinesthetic'),
                            _buildMethodCard('Reading/Writing', Icons.edit, 'reading'),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Convert Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _convertContent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Convert to Game',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
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

  Widget _buildMethodCard(String title, IconData icon, String method) {
    final isSelected = _selectedLearningMethod == method;
    
    return GestureDetector(
      onTap: () => _selectLearningMethod(method),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}