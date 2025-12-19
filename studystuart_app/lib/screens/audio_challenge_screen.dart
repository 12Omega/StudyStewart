import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class AudioChallengeScreen extends StatefulWidget {
  const AudioChallengeScreen({super.key});

  @override
  State<AudioChallengeScreen> createState() => _AudioChallengeScreenState();
}

class _AudioChallengeScreenState extends State<AudioChallengeScreen> {
  final TTSService _ttsService = TTSService();
  String _selectedDifficulty = '';
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() {
    _ttsService.speak('Audio Challenge. Listen and Repeat. Play close attention and listen to audio pattern and repeat it back.');
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _ttsService.speak('Selected $difficulty difficulty');
  }

  void _playAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _ttsService.speak('Playing audio pattern. Listen carefully and repeat.');
    } else {
      _ttsService.speak('Audio stopped');
    }
  }

  void _recordResponse() {
    _ttsService.speak('Recording your response. Speak now.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording feature coming soon!')),
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
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 22,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
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
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Audio Challenge',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Listen And Repeat',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Play close attention and listen to audio pattern and repeat it back',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Progress
                        Row(
                          children: [
                            Text(
                              'Level 1',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '76% completed',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Progress Bar
                        Container(
                          width: double.infinity,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.76,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Difficulty Selection
                        Text(
                          'Select Difficulty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDifficultyButton('Easy'),
                            _buildDifficultyButton('Medium'),
                            _buildDifficultyButton('Hard'),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Audio Player
                        Center(
                          child: GestureDetector(
                            onTap: _playAudio,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: _isPlaying ? Colors.red : Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.stop : Icons.play_arrow,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Voice Record Button
                            GestureDetector(
                              onTap: _recordResponse,
                              child: Container(
                                width: 87,
                                height: 87,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.mic,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            
                            // Replay Button
                            GestureDetector(
                              onTap: () {
                                _ttsService.speak('Replaying audio');
                                _playAudio();
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.replay,
                                  size: 40,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildDifficultyButton(String difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    
    return GestureDetector(
      onTap: () => _selectDifficulty(difficulty),
      child: Container(
        width: 87,
        height: 21,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            difficulty,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}