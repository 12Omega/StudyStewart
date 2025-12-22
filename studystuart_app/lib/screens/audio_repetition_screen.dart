import 'package:flutter/material.dart';
import 'dart:math';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class AudioRepetitionScreen extends StatefulWidget {
  const AudioRepetitionScreen({super.key});

  @override
  State<AudioRepetitionScreen> createState() => _AudioRepetitionScreenState();
}

class _AudioRepetitionScreenState extends State<AudioRepetitionScreen>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  final Random _random = Random();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _currentRound = 1;
  int _score = 0;
  int _streak = 0;
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _gameActive = true;
  
  List<String> _currentSequence = [];
  List<String> _userSequence = [];
  int _sequenceIndex = 0;
  
  final List<Map<String, dynamic>> _sounds = [
    {'name': 'Bell', 'sound': 'ding', 'color': Colors.blue, 'icon': Icons.notifications},
    {'name': 'Drum', 'sound': 'boom', 'color': Colors.red, 'icon': Icons.music_note},
    {'name': 'Whistle', 'sound': 'tweet', 'color': Colors.green, 'icon': Icons.sports_soccer},
    {'name': 'Chime', 'sound': 'ring', 'color': Colors.orange, 'icon': Icons.access_alarm},
    {'name': 'Pop', 'sound': 'pop', 'color': Colors.purple, 'icon': Icons.bubble_chart},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _speakWelcome();
    _startNewRound();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _speakWelcome() {
    _ttsService.speak('Audio Repetition Challenge! Listen to the sound sequence and repeat it back in the same order.');
  }

  void _startNewRound() {
    setState(() {
      _currentSequence.clear();
      _userSequence.clear();
      _sequenceIndex = 0;
    });
    
    // Generate sequence (starts with 2 sounds, adds 1 each round)
    int sequenceLength = 2 + (_currentRound - 1);
    for (int i = 0; i < sequenceLength; i++) {
      _currentSequence.add(_sounds[_random.nextInt(_sounds.length)]['sound']);
    }
    
    _ttsService.speak('Round $_currentRound. Listen to the sequence of $sequenceLength sounds.');
    
    Future.delayed(const Duration(seconds: 2), () {
      _playSequence();
    });
  }

  void _playSequence() async {
    setState(() {
      _isPlaying = true;
    });
    
    _ttsService.speak('Playing sequence now. Listen carefully.');
    
    for (int i = 0; i < _currentSequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        setState(() {
          _sequenceIndex = i;
        });
        
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
        
        _ttsService.speak(_currentSequence[i]);
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }
    
    setState(() {
      _isPlaying = false;
      _sequenceIndex = -1;
    });
    
    _ttsService.speak('Now repeat the sequence by tapping the sound buttons in the same order.');
  }

  void _addUserSound(String sound) {
    if (_isPlaying || !_gameActive) return;
    
    setState(() {
      _userSequence.add(sound);
    });
    
    _ttsService.speak(sound);
    
    // Check if sequence is complete
    if (_userSequence.length == _currentSequence.length) {
      _checkSequence();
    }
  }

  void _checkSequence() {
    bool isCorrect = true;
    
    for (int i = 0; i < _currentSequence.length; i++) {
      if (_currentSequence[i] != _userSequence[i]) {
        isCorrect = false;
        break;
      }
    }
    
    if (isCorrect) {
      setState(() {
        _score += _currentRound * 10;
        _streak++;
        _currentRound++;
      });
      
      _ttsService.speak('Excellent! Correct sequence. Your streak is $_streak.');
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_currentRound <= 10) {
          _startNewRound();
        } else {
          _endGame();
        }
      });
    } else {
      setState(() {
        _streak = 0;
      });
      
      _ttsService.speak('Incorrect sequence. Let\'s try this round again.');
      
      Future.delayed(const Duration(seconds: 2), () {
        _startNewRound();
      });
    }
  }

  void _endGame() {
    setState(() {
      _gameActive = false;
    });
    
    _ttsService.speak('Congratulations! You completed all 10 rounds with a final score of $_score points!');
  }

  void _playAgain() {
    setState(() {
      _currentRound = 1;
      _score = 0;
      _streak = 0;
      _gameActive = true;
    });
    
    _startNewRound();
  }

  void _replaySequence() {
    if (!_isPlaying) {
      _playSequence();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Repetition'),
        backgroundColor: Colors.indigo.shade100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.indigo.shade100,
                  Colors.purple.shade100,
                ],
              ),
            ),
            child: SafeArea(
              child: _gameActive ? _buildGameScreen() : _buildResultScreen(),
            ),
          ),
          Positioned(
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

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Game stats
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Round', _currentRound.toString(), Colors.indigo),
              _buildStatCard('Streak', _streak.toString(), Colors.green),
              _buildStatCard('Sequence', '${_currentSequence.length}', Colors.orange),
            ],
          ),
        ),
        
        // Sequence display area
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isPlaying)
                  Column(
                    children: [
                      const Text(
                        'Listen to the sequence:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _currentSequence.asMap().entries.map((entry) {
                          int index = entry.key;
                          String sound = entry.value;
                          var soundData = _sounds.firstWhere((s) => s['sound'] == sound);
                          
                          return AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: Transform.scale(
                                  scale: index == _sequenceIndex ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: index == _sequenceIndex 
                                          ? soundData['color'] 
                                          : Colors.grey.shade300,
                                      shape: BoxShape.circle,
                                      boxShadow: index == _sequenceIndex ? [
                                        BoxShadow(
                                          color: soundData['color'].withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 3,
                                        ),
                                      ] : null,
                                    ),
                                    child: Icon(
                                      soundData['icon'],
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Repeat the sequence:',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Progress: ${_userSequence.length}/${_currentSequence.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _replaySequence,
                        icon: const Icon(Icons.replay),
                        label: const Text('Replay Sequence'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        
        // Sound buttons
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _sounds.map((sound) {
                return GestureDetector(
                  onTap: () => _addUserSound(sound['sound']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sound['color'],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: sound['color'].withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sound['icon'],
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sound['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Game Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Final Score: $_score points',
                  style: const TextStyle(fontSize: 20),
                ),
                
                Text(
                  'Rounds Completed: ${_currentRound - 1}/10',
                  style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _playAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Play Again'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}