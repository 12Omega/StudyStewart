import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class SubwaySurferScreen extends StatefulWidget {
  const SubwaySurferScreen({super.key});

  @override
  State<SubwaySurferScreen> createState() => _SubwaySurferScreenState();
}

class _SubwaySurferScreenState extends State<SubwaySurferScreen>
    with TickerProviderStateMixin {
  final TTSService _voiceAssistant = TTSService();
  final Random _random = Random();
  
  late AnimationController _runAnimationController;
  late AnimationController _jumpAnimationController;
  late Animation<double> _jumpAnimation;
  
  Timer? _gameTimer;
  Timer? _obstacleTimer;
  Timer? _coinTimer;
  Timer? _questionTimer;
  
  // Game state
  bool _gameActive = false;
  bool _gameStarted = false;
  int _score = 0;
  int _coins = 0;
  int _distance = 0;
  double _speed = 2.0;
  
  // Player state
  int _playerLane = 1; // 0=left, 1=center, 2=right
  bool _isJumping = false;
  bool _isSliding = false;
  
  // Game objects
  List<Obstacle> _obstacles = [];
  List<Coin> _gameCoins = [];
  List<Question> _questions = [];
  
  // Educational questions
  final List<QuestionData> _questionBank = [
    QuestionData('What is 5 + 3?', ['6', '7', '8', '9'], 2),
    QuestionData('Which planet is closest to the Sun?', ['Venus', 'Mercury', 'Earth', 'Mars'], 1),
    QuestionData('What is the capital of France?', ['London', 'Berlin', 'Paris', 'Rome'], 2),
    QuestionData('How many sides does a triangle have?', ['2', '3', '4', '5'], 1),
    QuestionData('What color do you get mixing red and blue?', ['Green', 'Purple', 'Orange', 'Yellow'], 1),
    QuestionData('Which is the largest ocean?', ['Atlantic', 'Pacific', 'Indian', 'Arctic'], 1),
    QuestionData('What is 10 - 4?', ['5', '6', '7', '8'], 1),
    QuestionData('How many days are in a week?', ['5', '6', '7', '8'], 2),
  ];
  
  Question? _currentQuestion;
  bool _showingQuestion = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _speakWelcome();
  }

  void _initializeAnimations() {
    _runAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
    
    _jumpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _jumpAnimation = Tween<double>(
      begin: 0.0,
      end: -100.0,
    ).animate(CurvedAnimation(
      parent: _jumpAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  /// Give players an exciting welcome to their subway adventure
  void _speakWelcome() {
    _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('subway'));
  }

  /// Start the game with enthusiasm
  void _startGame() {
    setState(() {
      _gameActive = true;
      _gameStarted = true;
      _score = 0;
      _coins = 0;
      _distance = 0;
      _speed = 2.0;
      _playerLane = 1;
      _obstacles.clear();
      _gameCoins.clear();
      _questions.clear();
      _currentQuestion = null;
      _showingQuestion = false;
    });
    
    _voiceAssistant.speak('🚇 All aboard! Your learning adventure starts now! Run, jump, and collect coins while answering questions!');
    
    // Start game timers
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateGame();
    });
    
    _obstacleTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      _spawnObstacle();
    });
    
    _coinTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _spawnCoin();
    });
    
    _questionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _spawnQuestion();
    });
  }

  void _updateGame() {
    if (!_gameActive || _showingQuestion) return;
    
    setState(() {
      _distance += _speed.toInt();
      _score = _distance ~/ 10;
      
      // Increase speed gradually
      if (_distance % 500 == 0) {
        _speed += 0.1;
      }
      
      // Move obstacles
      _obstacles.removeWhere((obstacle) {
        obstacle.y += _speed * 10;
        return obstacle.y > MediaQuery.of(context).size.height;
      });
      
      // Move coins
      _gameCoins.removeWhere((coin) {
        coin.y += _speed * 10;
        return coin.y > MediaQuery.of(context).size.height;
      });
      
      // Move questions
      _questions.removeWhere((question) {
        question.y += _speed * 10;
        return question.y > MediaQuery.of(context).size.height;
      });
      
      // Check collisions
      _checkCollisions();
    });
  }

  void _spawnObstacle() {
    if (!_gameActive) return;
    
    final lane = _random.nextInt(3);
    _obstacles.add(Obstacle(
      lane: lane,
      y: -50,
      type: ObstacleType.values[_random.nextInt(ObstacleType.values.length)],
    ));
  }

  void _spawnCoin() {
    if (!_gameActive) return;
    
    final lane = _random.nextInt(3);
    _gameCoins.add(Coin(
      lane: lane,
      y: -30,
    ));
  }

  void _spawnQuestion() {
    if (!_gameActive || _showingQuestion) return;
    
    final questionData = _questionBank[_random.nextInt(_questionBank.length)];
    final lane = _random.nextInt(3);
    
    _questions.add(Question(
      lane: lane,
      y: -40,
      data: questionData,
    ));
  }

  void _checkCollisions() {
    final playerRect = Rect.fromLTWH(
      _playerLane * 100.0 + 25,
      MediaQuery.of(context).size.height - 200 + (_isJumping ? _jumpAnimation.value : 0),
      50,
      80,
    );
    
    // Check obstacle collisions
    for (var obstacle in _obstacles.toList()) {
      final obstacleRect = Rect.fromLTWH(
        obstacle.lane * 100.0 + 25,
        obstacle.y,
        50,
        60,
      );
      
      if (playerRect.overlaps(obstacleRect) && !_isJumping && !_isSliding) {
        _gameOver();
        return;
      }
    }
    
    // Check coin collisions
    for (var coin in _gameCoins.toList()) {
      final coinRect = Rect.fromLTWH(
        coin.lane * 100.0 + 35,
        coin.y,
        30,
        30,
      );
      
      if (playerRect.overlaps(coinRect)) {
        setState(() {
          _coins += 10;
          _score += 50;
          _gameCoins.remove(coin);
        });
        _voiceAssistant.speak('💰 Nice catch! Coin collected!');
      }
    }
    
    // Check question collisions
    for (var question in _questions.toList()) {
      final questionRect = Rect.fromLTWH(
        question.lane * 100.0 + 25,
        question.y,
        50,
        40,
      );
      
      if (playerRect.overlaps(questionRect)) {
        _showQuestion(question);
        _questions.remove(question);
        return;
      }
    }
  }

  /// Show an exciting quiz question during the game
  void _showQuestion(Question question) {
    setState(() {
      _showingQuestion = true;
      _currentQuestion = question;
    });
    
    _voiceAssistant.speak('🧠 Brain break time! Here\'s a fun question: ${question.data.question}');
  }

  /// Process the player's answer with encouraging feedback
  void _answerQuestion(int answerIndex) {
    if (_currentQuestion == null) return;
    
    final isCorrect = answerIndex == _currentQuestion!.data.correctAnswerIndex;
    
    if (isCorrect) {
      setState(() {
        _score += 200;
        _coins += 50;
      });
      _voiceAssistant.speak('🎉 Brilliant! You earned bonus points and coins! Keep running!');
    } else {
      final correctAnswer = _currentQuestion!.data.options[_currentQuestion!.data.correctAnswerIndex];
      _voiceAssistant.speak('Good try! The answer was $correctAnswer. You\'re still doing great - keep going!');
    }
    
    setState(() {
      _showingQuestion = false;
      _currentQuestion = null;
    });
  }

  void _moveLeft() {
    if (_playerLane > 0 && !_showingQuestion) {
      setState(() {
        _playerLane--;
      });
    }
  }

  void _moveRight() {
    if (_playerLane < 2 && !_showingQuestion) {
      setState(() {
        _playerLane++;
      });
    }
  }

  void _jump() {
    if (!_isJumping && !_showingQuestion) {
      setState(() {
        _isJumping = true;
      });
      
      _jumpAnimationController.forward().then((_) {
        _jumpAnimationController.reverse().then((_) {
          setState(() {
            _isJumping = false;
          });
        });
      });
    }
  }

  void _slide() {
    if (!_isSliding && !_showingQuestion) {
      setState(() {
        _isSliding = true;
      });
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isSliding = false;
          });
        }
      });
    }
  }

  /// Handle game over with encouragement
  void _gameOver() {
    setState(() {
      _gameActive = false;
    });
    
    _gameTimer?.cancel();
    _obstacleTimer?.cancel();
    _coinTimer?.cancel();
    _questionTimer?.cancel();
    
    _voiceAssistant.speak('🏁 What an amazing run! You traveled ${_distance}m and scored $_score points! Plus you collected $_coins coins! Want to beat that score?');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏁 Awesome Run! 🏁'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏃‍♂️ Distance: ${_distance}m'),
            Text('🎯 Score: $_score points'),
            Text('💰 Coins: $_coins'),
            Text('⚡ Top Speed: ${_speed.toStringAsFixed(1)}x'),
            const SizedBox(height: 10),
            const Text('You did fantastic! 🌟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Run Again! 🚀'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _runAnimationController.dispose();
    _jumpAnimationController.dispose();
    _gameTimer?.cancel();
    _obstacleTimer?.cancel();
    _coinTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue.shade300,
                  Colors.green.shade300,
                ],
              ),
            ),
          ),
          
          // Game area
          if (_gameStarted) ...[
            // Track lanes
            Positioned.fill(
              child: CustomPaint(
                painter: TrackPainter(),
              ),
            ),
            
            // Obstacles
            ..._obstacles.map((obstacle) => _buildObstacle(obstacle)).toList(),
            
            // Coins
            ..._gameCoins.map((coin) => _buildCoin(coin)).toList(),
            
            // Questions
            ..._questions.map((question) => _buildQuestionIcon(question)).toList(),
            
            // Player
            _buildPlayer(),
            
            // Game UI
            _buildGameUI(),
            
            // Controls
            _buildControls(),
          ],
          
          // Start screen
          if (!_gameStarted) _buildStartScreen(),
          
          // Question overlay
          if (_showingQuestion && _currentQuestion != null) _buildQuestionOverlay(),
          
          // TTS Button
          const Positioned(
            top: 50,
            right: 16,
            child: SafeArea(
              child: TTSButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🚇 Educational Subway Surfer 🚇',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ready for an amazing adventure? 🌟\nSwipe to move, tap to jump, and collect coins!\nAnswer fun questions to earn bonus points!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'START ADVENTURE! 🚀',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return AnimatedBuilder(
      animation: _jumpAnimation,
      builder: (context, child) {
        return Positioned(
          left: _playerLane * 100.0 + 25,
          bottom: 120 - _jumpAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: _isSliding ? 40 : 80,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isSliding ? Icons.keyboard_arrow_down : Icons.person,
              color: Colors.white,
              size: _isSliding ? 30 : 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildObstacle(Obstacle obstacle) {
    return Positioned(
      left: obstacle.lane * 100.0 + 25,
      top: obstacle.y,
      child: Container(
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: obstacle.type == ObstacleType.barrier ? Colors.red : Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          obstacle.type == ObstacleType.barrier ? Icons.warning : Icons.construction,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildCoin(Coin coin) {
    return Positioned(
      left: coin.lane * 100.0 + 35,
      top: coin.y,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.yellow,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.monetization_on,
          color: Colors.orange,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildQuestionIcon(Question question) {
    return Positioned(
      left: question.lane * 100.0 + 25,
      top: question.y,
      child: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.quiz,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  Widget _buildGameUI() {
    return Positioned(
      top: 50,
      left: 16,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Coins: $_coins',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_distance}m',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: _moveLeft,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: _jump,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: _slide,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: _moveRight,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🧠 Brain Break Time! 🧠',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _currentQuestion!.data.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...List.generate(
                _currentQuestion!.data.options.length,
                (index) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      foregroundColor: Colors.purple.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentQuestion!.data.options[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2;
    
    // Draw lane dividers
    canvas.drawLine(
      Offset(100, 0),
      Offset(100, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(200, 0),
      Offset(200, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum ObstacleType { barrier, cone }

class Obstacle {
  final int lane;
  double y;
  final ObstacleType type;

  Obstacle({
    required this.lane,
    required this.y,
    required this.type,
  });
}

class Coin {
  final int lane;
  double y;

  Coin({
    required this.lane,
    required this.y,
  });
}

class Question {
  final int lane;
  double y;
  final QuestionData data;

  Question({
    required this.lane,
    required this.y,
    required this.data,
  });
}

class QuestionData {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuestionData(this.question, this.options, this.correctAnswerIndex);
}