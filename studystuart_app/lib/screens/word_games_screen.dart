import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class WordGamesScreen extends StatefulWidget {
  const WordGamesScreen({super.key});

  @override
  State<WordGamesScreen> createState() => _WordGamesScreenState();
}

class _WordGamesScreenState extends State<WordGamesScreen> with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  int _currentGameIndex = 0;
  int _score = 0;
  int _currentWordIndex = 0;
  String _userInput = '';
  bool _showFeedback = false;
  bool _isCorrect = false;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Word games data
  final List<Map<String, dynamic>> _wordGames = [
    {
      'title': 'Spell the Word',
      'description': 'Listen and spell the word correctly',
      'words': [
        {'word': 'APPLE', 'hint': 'A red or green fruit'},
        {'word': 'HOUSE', 'hint': 'A place where people live'},
        {'word': 'WATER', 'hint': 'Clear liquid we drink'},
        {'word': 'HAPPY', 'hint': 'Feeling of joy'},
        {'word': 'SCHOOL', 'hint': 'Place where children learn'},
      ],
    },
    {
      'title': 'Complete the Word',
      'description': 'Fill in the missing letters',
      'words': [
        {'word': 'C_T', 'answer': 'CAT', 'hint': 'A furry pet that meows'},
        {'word': 'D_G', 'answer': 'DOG', 'hint': 'A loyal pet that barks'},
        {'word': 'S_N', 'answer': 'SUN', 'hint': 'Bright star in the sky'},
        {'word': 'B_RD', 'answer': 'BIRD', 'hint': 'Animal that flies'},
        {'word': 'TR_E', 'answer': 'TREE', 'hint': 'Tall plant with leaves'},
      ],
    },
    {
      'title': 'Word Matching',
      'description': 'Match words with their meanings',
      'words': [
        {'word': 'BIG', 'options': ['Small', 'Large', 'Fast', 'Cold'], 'correct': 1},
        {'word': 'HOT', 'options': ['Cold', 'Warm', 'Big', 'Small'], 'correct': 1},
        {'word': 'FAST', 'options': ['Slow', 'Quick', 'Big', 'Red'], 'correct': 1},
        {'word': 'NIGHT', 'options': ['Day', 'Dark', 'Light', 'Morning'], 'correct': 1},
        {'word': 'UP', 'options': ['Down', 'High', 'Low', 'Side'], 'correct': 1},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _speakInstructions();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_scaleController);
    
    _fadeController.forward();
    _scaleController.forward();
  }

  void _speakInstructions() {
    final game = _wordGames[_currentGameIndex];
    _ttsService.speak('Welcome to ${game['title']}! ${game['description']}');
    
    Future.delayed(const Duration(seconds: 3), () {
      _speakCurrentWord();
    });
  }

  void _speakCurrentWord() {
    final game = _wordGames[_currentGameIndex];
    final wordData = game['words'][_currentWordIndex];
    
    if (_currentGameIndex == 0) {
      // Spelling game
      _ttsService.speak('Spell this word: ${wordData['word']}. Hint: ${wordData['hint']}');
    } else if (_currentGameIndex == 1) {
      // Complete the word
      _ttsService.speak('Complete this word: ${wordData['word']}. Hint: ${wordData['hint']}');
    } else {
      // Word matching
      _ttsService.speak('What does ${wordData['word']} mean?');
    }
  }

  void _checkAnswer() {
    final game = _wordGames[_currentGameIndex];
    final wordData = game['words'][_currentWordIndex];
    bool correct = false;
    
    if (_currentGameIndex == 0) {
      // Spelling game
      correct = _userInput.toUpperCase() == wordData['word'];
    } else if (_currentGameIndex == 1) {
      // Complete the word
      correct = _userInput.toUpperCase() == wordData['answer'];
    }
    
    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
    });
    
    if (correct) {
      _score += 10;
      HapticFeedback.mediumImpact();
      _ttsService.speak('Excellent! That\'s correct!');
    } else {
      HapticFeedback.lightImpact();
      if (_currentGameIndex == 0) {
        _ttsService.speak('Not quite. The correct spelling is ${wordData['word']}');
      } else if (_currentGameIndex == 1) {
        _ttsService.speak('Not quite. The complete word is ${wordData['answer']}');
      }
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      _nextWord();
    });
  }

  void _checkMultipleChoice(int selectedIndex) {
    final game = _wordGames[_currentGameIndex];
    final wordData = game['words'][_currentWordIndex];
    final correct = selectedIndex == wordData['correct'];
    
    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
    });
    
    if (correct) {
      _score += 10;
      HapticFeedback.mediumImpact();
      _ttsService.speak('Perfect! That\'s the right answer!');
    } else {
      HapticFeedback.lightImpact();
      final correctAnswer = wordData['options'][wordData['correct']];
      _ttsService.speak('Not quite. ${wordData['word']} means $correctAnswer');
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      _nextWord();
    });
  }

  void _nextWord() {
    setState(() {
      _showFeedback = false;
      _userInput = '';
      _currentWordIndex++;
    });
    
    if (_currentWordIndex >= _wordGames[_currentGameIndex]['words'].length) {
      _nextGame();
    } else {
      _speakCurrentWord();
    }
  }

  void _nextGame() {
    if (_currentGameIndex < _wordGames.length - 1) {
      setState(() {
        _currentGameIndex++;
        _currentWordIndex = 0;
      });
      _speakInstructions();
    } else {
      _showGameComplete();
    }
  }

  void _showGameComplete() {
    _ttsService.speak('Congratulations! You completed all word games! Your final score is $_score points!');
  }

  void _resetGame() {
    setState(() {
      _currentGameIndex = 0;
      _currentWordIndex = 0;
      _score = 0;
      _userInput = '';
      _showFeedback = false;
    });
    _speakInstructions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.blue.shade100,
              Colors.cyan.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _currentWordIndex < _wordGames[_currentGameIndex]['words'].length
                    ? _buildGameContent()
                    : _buildGameComplete(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.purple),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _wordGames[_currentGameIndex]['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const TTSButton(),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final game = _wordGames[_currentGameIndex];
    final wordData = game['words'][_currentWordIndex];
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress indicator
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Game ${_currentGameIndex + 1} of ${_wordGames.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Word ${_currentWordIndex + 1} of ${game['words'].length}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Game card
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Word display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade50, Colors.blue.shade50],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _currentGameIndex == 2 ? wordData['word'] : 
                                _currentGameIndex == 1 ? wordData['word'] : 'Listen and Spell',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              onPressed: _speakCurrentWord,
                              icon: Icon(Icons.volume_up, color: Colors.purple.shade600),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Hint
                      if (_currentGameIndex != 2)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.blue.shade600),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Hint: ${wordData['hint']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // Input area
                      if (_currentGameIndex != 2) ...[
                        TextField(
                          onChanged: (value) => setState(() => _userInput = value),
                          onSubmitted: (_) => _checkAnswer(),
                          decoration: InputDecoration(
                            hintText: 'Type your answer here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _userInput.isNotEmpty ? _checkAnswer : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Submit Answer',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ] else ...[
                        // Multiple choice options
                        ...List.generate(
                          wordData['options'].length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _checkMultipleChoice(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.purple,
                                  padding: const EdgeInsets.all(15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.purple.shade200),
                                  ),
                                ),
                                child: Text(
                                  wordData['options'][index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Feedback overlay
                if (_showFeedback)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isCorrect ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.lightbulb,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isCorrect ? 'Correct!' : 'Keep Learning!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameComplete() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber.shade600,
              ),
              const SizedBox(height: 20),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You completed all word games!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Final Score: $_score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}