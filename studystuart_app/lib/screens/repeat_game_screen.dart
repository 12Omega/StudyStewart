import 'package:flutter/material.dart';
import 'dart:math';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class RepeatGameScreen extends StatefulWidget {
  const RepeatGameScreen({super.key});

  @override
  State<RepeatGameScreen> createState() => _RepeatGameScreenState();
}

class _RepeatGameScreenState extends State<RepeatGameScreen>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  final Random _random = Random();
  
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  
  int _level = 1;
  int _score = 0;
  int _lives = 3;
  bool _gameActive = true;
  bool _showingSequence = false;
  bool _playerTurn = false;
  
  List<int> _sequence = [];
  List<int> _playerSequence = [];
  int _currentStep = 0;
  
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _speakWelcome();
    _startNewLevel();
  }

  void _initializeAnimations() {
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _flashAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.yellow,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));
  }

  void _speakWelcome() {
    _ttsService.speak('Repeat Game! Watch the sequence of colors and repeat them in the same order. You have 3 lives.');
  }

  void _startNewLevel() {
    setState(() {
      _sequence.add(_random.nextInt(_colors.length));
      _playerSequence.clear();
      _currentStep = 0;
      _showingSequence = true;
      _playerTurn = false;
    });
    
    _ttsService.speak('Level $_level. Watch the sequence of ${_sequence.length} colors.');
    
    Future.delayed(const Duration(seconds: 1), () {
      _showSequence();
    });
  }

  void _showSequence() async {
    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        
        _flashController.forward().then((_) {
          _flashController.reverse();
        });
        
        // Speak color name
        String colorName = _getColorName(_sequence[i]);
        _ttsService.speak(colorName);
        
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    
    setState(() {
      _showingSequence = false;
      _playerTurn = true;
      _currentStep = -1;
    });
    
    _ttsService.speak('Now repeat the sequence by tapping the colors in the same order.');
  }

  String _getColorName(int colorIndex) {
    const colorNames = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];
    return colorNames[colorIndex];
  }

  void _playerTapColor(int colorIndex) {
    if (!_playerTurn || !_gameActive) return;
    
    setState(() {
      _playerSequence.add(colorIndex);
    });
    
    String colorName = _getColorName(colorIndex);
    _ttsService.speak(colorName);
    
    // Check if the tap is correct
    int currentIndex = _playerSequence.length - 1;
    if (_sequence[currentIndex] != colorIndex) {
      _wrongAnswer();
      return;
    }
    
    // Check if sequence is complete
    if (_playerSequence.length == _sequence.length) {
      _correctSequence();
    }
  }

  void _correctSequence() {
    setState(() {
      _score += _level * 10;
      _level++;
      _playerTurn = false;
    });
    
    _ttsService.speak('Excellent! Correct sequence. Level $_level coming up.');
    
    Future.delayed(const Duration(seconds: 2), () {
      if (_level <= 15) {
        _startNewLevel();
      } else {
        _winGame();
      }
    });
  }

  void _wrongAnswer() {
    setState(() {
      _lives--;
      _playerTurn = false;
    });
    
    if (_lives > 0) {
      _ttsService.speak('Incorrect! You have $_lives lives left. Let\'s try this level again.');
      
      Future.delayed(const Duration(seconds: 2), () {
        // Remove the last added color and restart the level
        _sequence.removeLast();
        _startNewLevel();
      });
    } else {
      _gameOver();
    }
  }

  void _gameOver() {
    setState(() {
      _gameActive = false;
    });
    
    _ttsService.speak('Game Over! You reached level $_level with a score of $_score points.');
  }

  void _winGame() {
    setState(() {
      _gameActive = false;
    });
    
    _ttsService.speak('Congratulations! You completed all 15 levels! Final score: $_score points.');
  }

  void _playAgain() {
    setState(() {
      _level = 1;
      _score = 0;
      _lives = 3;
      _gameActive = true;
      _sequence.clear();
      _playerSequence.clear();
    });
    
    _startNewLevel();
  }

  void _replaySequence() {
    if (!_showingSequence && _playerTurn) {
      setState(() {
        _playerSequence.clear();
      });
      _showSequence();
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repeat Game'),
        backgroundColor: Colors.pink.shade100,
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
                  Colors.pink.shade100,
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
              _buildStatCard('Level', _level.toString(), Colors.pink),
              _buildStatCard('Lives', _lives.toString(), Colors.red),
              _buildStatCard('Sequence', '${_sequence.length}', Colors.blue),
            ],
          ),
        ),
        
        // Status display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.pink, width: 2),
          ),
          child: Column(
            children: [
              if (_showingSequence)
                const Text(
                  'Watch the sequence!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                )
              else if (_playerTurn)
                Column(
                  children: [
                    const Text(
                      'Your turn! Repeat the sequence:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: ${_playerSequence.length}/${_sequence.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _replaySequence,
                      icon: const Icon(Icons.replay),
                      label: const Text('Replay Sequence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              
              // Sequence progress indicator
              if (_sequence.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _sequence.asMap().entries.map((entry) {
                      int index = entry.key;
                      int colorIndex = entry.value;
                      
                      bool isActive = _showingSequence && index == _currentStep;
                      bool isCompleted = _playerSequence.length > index;
                      
                      return AnimatedBuilder(
                        animation: _flashAnimation,
                        builder: (context, child) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? _flashAnimation.value 
                                  : isCompleted 
                                      ? _colors[colorIndex] 
                                      : Colors.grey.shade300,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Color buttons
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _colors.asMap().entries.map((entry) {
                int index = entry.key;
                Color color = entry.value;
                
                return GestureDetector(
                  onTap: () => _playerTapColor(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getColorName(index),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
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
    bool won = _level > 15;
    
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
                  won ? Icons.emoji_events : Icons.refresh,
                  size: 80,
                  color: won ? Colors.amber : Colors.pink,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  won ? 'You Won!' : 'Game Over',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Level Reached: $_level',
                  style: const TextStyle(fontSize: 18),
                ),
                
                Text(
                  'Final Score: $_score points',
                  style: const TextStyle(fontSize: 18),
                ),
                
                if (won)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Perfect! You completed all levels!',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _playAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
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