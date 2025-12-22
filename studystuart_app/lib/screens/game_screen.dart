import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import 'audio_challenge_screen.dart';
import 'kinesthetic_screen.dart';
import 'wordle_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  int _currentQuestion = 0;
  int _score = 0;
  int _streak = 0;
  int _totalCorrect = 0;
  bool _isAnswering = false;
  bool _showFeedback = false;
  bool _lastAnswerCorrect = false;
  
  // Animation controllers for addictive feedback
  late AnimationController _cardController;
  late AnimationController _feedbackController;
  late AnimationController _streakController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _feedbackScaleAnimation;
  late Animation<double> _feedbackOpacityAnimation;
  late Animation<double> _streakBounceAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pulseAnimation;
  
  // Streak multipliers for addictive progression
  final List<int> _streakMultipliers = [1, 2, 3, 5, 8, 10, 15, 20];
  
  // Achievement system
  List<String> _achievements = [];
  bool _showAchievement = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 2 plus 2?',
      'options': ['3', '4', '5', '6'],
      'correct': 1,
      'explanation': 'Two plus two equals four! Basic addition is the foundation of math.',
    },
    {
      'question': 'What color is the sky on a clear day?',
      'options': ['Red', 'Blue', 'Green', 'Yellow'],
      'correct': 1,
      'explanation': 'The sky appears blue due to light scattering in our atmosphere!',
    },
    {
      'question': 'How many days are in a week?',
      'options': ['5', '6', '7', '8'],
      'correct': 2,
      'explanation': 'Seven days make a week: Monday through Sunday!',
    },
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'correct': 2,
      'explanation': 'Paris is the beautiful capital city of France!',
    },
    {
      'question': 'How many sides does a triangle have?',
      'options': ['2', '3', '4', '5'],
      'correct': 1,
      'explanation': 'A triangle always has exactly three sides and three angles!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _speakQuestion();
  }

  void _setupAnimations() {
    // Card transition animations
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOutCubic,
    ));
    
    _cardFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    // Feedback animations
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _feedbackScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));
    
    _feedbackOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    // Streak animations
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _streakBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _streakController,
      curve: Curves.bounceOut,
    ));
    
    // Confetti animation for achievements
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    // Pulse animation for buttons
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _speakQuestion() {
    if (_currentQuestion < _questions.length) {
      final question = _questions[_currentQuestion];
      _ttsService.speak('Question ${_currentQuestion + 1}. ${question['question']}');
    }
  }

  void _answerQuestion(int selectedIndex) async {
    if (_isAnswering) return;
    
    setState(() {
      _isAnswering = true;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    final question = _questions[_currentQuestion];
    final isCorrect = selectedIndex == question['correct'];
    
    setState(() {
      _lastAnswerCorrect = isCorrect;
      _showFeedback = true;
    });
    
    // Start feedback animation
    _feedbackController.forward();
    
    if (isCorrect) {
      _score += _getScoreMultiplier();
      _streak++;
      _totalCorrect++;
      
      // Celebration effects
      HapticFeedback.mediumImpact();
      _streakController.forward();
      
      // Check for achievements
      _checkAchievements();
      
      // Positive TTS with enthusiasm
      final encouragements = [
        'Fantastic! You\'re on fire!',
        'Brilliant! Keep it up!',
        'Amazing! You\'re a star!',
        'Perfect! You\'re unstoppable!',
        'Excellent! You\'re crushing it!',
      ];
      
      String message = encouragements[_totalCorrect % encouragements.length];
      
      if (_streak > 1) {
        message += ' ${_streak} in a row! ';
        if (_streak >= 3) {
          message += 'You\'re on a hot streak! ';
          _confettiController.forward();
        }
      }
      
      message += ' ${question['explanation']}';
      _ttsService.speak(message);
      
    } else {
      _streak = 0;
      
      // Gentle feedback for wrong answers
      HapticFeedback.lightImpact();
      
      final encouragements = [
        'Not quite, but you\'re learning! ',
        'Close! Try to remember this one. ',
        'Good try! Every mistake helps you grow. ',
        'Almost there! You\'ll get the next one. ',
      ];
      
      String message = encouragements[_currentQuestion % encouragements.length];
      message += question['explanation'];
      _ttsService.speak(message);
    }
    
    // Wait for feedback, then transition
    await Future.delayed(const Duration(milliseconds: 2500));
    
    setState(() {
      _showFeedback = false;
      _isAnswering = false;
    });
    
    _feedbackController.reset();
    _streakController.reset();
    
    // Smooth card transition
    await _cardController.forward();
    
    setState(() {
      _currentQuestion++;
    });
    
    _cardController.reset();
    
    if (_currentQuestion < _questions.length) {
      await Future.delayed(const Duration(milliseconds: 300));
      _speakQuestion();
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      _showGameComplete();
    }
  }

  int _getScoreMultiplier() {
    if (_streak < _streakMultipliers.length) {
      return _streakMultipliers[_streak];
    }
    return _streakMultipliers.last;
  }

  void _checkAchievements() {
    List<String> newAchievements = [];
    
    if (_streak == 3 && !_achievements.contains('Triple Threat')) {
      newAchievements.add('Triple Threat');
    }
    if (_streak == 5 && !_achievements.contains('Unstoppable')) {
      newAchievements.add('Unstoppable');
    }
    if (_totalCorrect == 1 && !_achievements.contains('First Success')) {
      newAchievements.add('First Success');
    }
    if (_score >= 50 && !_achievements.contains('High Scorer')) {
      newAchievements.add('High Scorer');
    }
    
    if (newAchievements.isNotEmpty) {
      _achievements.addAll(newAchievements);
      setState(() {
        _showAchievement = true;
      });
      
      _ttsService.speak('Achievement unlocked: ${newAchievements.join(', ')}!');
      
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _showAchievement = false;
        });
      });
    }
  }

  void _showGameComplete() {
    final percentage = (_totalCorrect / _questions.length * 100).round();
    
    String message = 'Game complete! ';
    
    if (percentage == 100) {
      message += 'Perfect score! You\'re absolutely incredible! ';
      _confettiController.forward();
    } else if (percentage >= 80) {
      message += 'Outstanding performance! You\'re a learning superstar! ';
    } else if (percentage >= 60) {
      message += 'Great job! You\'re making excellent progress! ';
    } else {
      message += 'Good effort! Every question makes you smarter! ';
    }
    
    message += 'Your final score is $_score points with $_totalCorrect correct answers!';
    _ttsService.speak(message);
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
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),
            
            SafeArea(
              child: Column(
                children: [
                  // Enhanced header with streak and score
                  _buildGameHeader(),
                  
                  // Main game content
                  Expanded(
                    child: _currentQuestion < _questions.length
                        ? _buildQuestionCard()
                        : _buildResultCard(),
                  ),
                ],
              ),
            ),
            
            // Feedback overlay
            if (_showFeedback) _buildFeedbackOverlay(),
            
            // Achievement popup
            if (_showAchievement) _buildAchievementPopup(),
            
            // Confetti effect
            if (_confettiController.isAnimating) _buildConfettiEffect(),
            
            // TTS Button
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: TTSButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          left: (index * 37.0) % MediaQuery.of(context).size.width,
          top: (index * 43.0) % MediaQuery.of(context).size.height,
          child: Transform.scale(
            scale: 0.5 + (_pulseAnimation.value * 0.3),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button with style
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
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
            ),
          ),
          
          // Score and streak display
          Column(
            children: [
              AnimatedBuilder(
                animation: _streakBounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_streakBounceAnimation.value * 0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              if (_streak > 0) ...[
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _streakBounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_streakBounceAnimation.value * 0.3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.pink.shade400],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '$_streak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Column(
              children: [
                Text(
                  '${_currentQuestion + 1}/${_questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentQuestion + 1) / _questions.length,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.purple.shade400],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestion];

    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_cardSlideAnimation.value * MediaQuery.of(context).size.width, 0),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.blue.shade50,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Question number with pulsing effect
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.quiz, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Question ${_currentQuestion + 1} of ${_questions.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 30),

                            // Question text with enhanced styling
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.shade100, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      question['question'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.volume_up, color: Colors.blue.shade600),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _ttsService.speak(question['question']);
                                      },
                                      tooltip: 'Read question aloud',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 30),

                            // Enhanced answer options with animations
                            ...List.generate(
                              question['options'].length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildAnswerOption(question['options'][index], index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerOption(String option, int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAnswering ? 0.95 : 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.blue.shade100,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _isAnswering ? null : () => _answerQuestion(index),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Option letter
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade300, Colors.purple.shade300],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Option text
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      
                      // Audio button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.volume_up, 
                            color: Colors.blue.shade600, 
                            size: 20
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _ttsService.speak(option);
                          },
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

  Widget _buildResultCard() {
    final percentage = (_score / _questions.length * 100).round();

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
                  percentage >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied,
                  size: 80,
                  color: percentage >= 70 ? Colors.amber : Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score / ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentQuestion = 0;
                          _score = 0;
                        });
                        _speakQuestion();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Additional game options
                Text(
                  'Try Other Games',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AudioChallengeScreen()),
                        );
                      },
                      icon: const Icon(Icons.hearing),
                      label: const Text('Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const KinestheticScreen()),
                        );
                      },
                      icon: const Icon(Icons.touch_app),
                      label: const Text('Reading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WordleScreen()),
                    );
                  },
                  icon: const Icon(Icons.grid_3x3),
                  label: const Text('Wordle Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  Widget _buildFeedbackOverlay() {
    return AnimatedBuilder(
      animation: _feedbackController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3 * _feedbackOpacityAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _feedbackScaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _lastAnswerCorrect 
                        ? [Colors.green.shade400, Colors.teal.shade400]
                        : [Colors.orange.shade400, Colors.red.shade400],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (_lastAnswerCorrect ? Colors.green : Colors.orange).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _lastAnswerCorrect ? Icons.check_circle : Icons.lightbulb,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _lastAnswerCorrect ? 'CORRECT!' : 'LEARNING!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_lastAnswerCorrect && _streak > 1) ...[
                        const SizedBox(height: 10),
                        Text(
                          '🔥 $_streak STREAK! 🔥',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildAchievementPopup() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACHIEVEMENT UNLOCKED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _achievements.isNotEmpty ? _achievements.last : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiEffect() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ConfettiPainter(_confettiAnimation.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    final percentage = (_totalCorrect / _questions.length * 100).round();
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isExcellent 
                    ? [Colors.amber.shade100, Colors.orange.shade100]
                    : isGood 
                      ? [Colors.blue.shade100, Colors.purple.shade100]
                      : [Colors.green.shade100, Colors.teal.shade100],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated trophy/medal
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseAnimation.value * 0.1),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isExcellent 
                                  ? [Colors.amber.shade400, Colors.orange.shade400]
                                  : isGood 
                                    ? [Colors.blue.shade400, Colors.purple.shade400]
                                    : [Colors.green.shade400, Colors.teal.shade400],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isExcellent ? Colors.amber : isGood ? Colors.blue : Colors.green).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              isExcellent ? Icons.emoji_events : isGood ? Icons.star : Icons.thumb_up,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      isExcellent ? 'AMAZING!' : isGood ? 'GREAT JOB!' : 'WELL DONE!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isExcellent ? Colors.amber.shade700 : isGood ? Colors.blue.shade700 : Colors.green.shade700,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Score display with animation
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Final Score',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.star, color: Colors.amber, size: 30),
                            ],
                          ),
                          Text(
                            '$_totalCorrect / ${_questions.length} correct ($percentage%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Achievements display
                    if (_achievements.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade50, Colors.orange.shade50],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.emoji_events, color: Colors.amber.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Achievements Earned',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _achievements.map((achievement) => 
                                Chip(
                                  label: Text(achievement),
                                  backgroundColor: Colors.amber.shade100,
                                  labelStyle: TextStyle(color: Colors.amber.shade700, fontSize: 12),
                                )
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Action buttons with enhanced styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          'Play Again',
                          Icons.refresh,
                          [Colors.green.shade400, Colors.teal.shade400],
                          () {
                            setState(() {
                              _currentQuestion = 0;
                              _score = 0;
                              _streak = 0;
                              _totalCorrect = 0;
                              _achievements.clear();
                            });
                            _confettiController.reset();
                            _speakQuestion();
                          },
                        ),
                        _buildActionButton(
                          'Home',
                          Icons.home,
                          [Colors.blue.shade400, Colors.purple.shade400],
                          () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // "Try other games" section with pulsing effect
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseAnimation.value * 0.05),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade50, Colors.blue.shade50],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.purple.shade100),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🎮 Keep the Fun Going!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildMiniGameButton('Audio Challenge', Icons.hearing, Colors.orange, () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioChallengeScreen()));
                                    }),
                                    _buildMiniGameButton('Reading Game', Icons.book, Colors.green, () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const KinestheticScreen()));
                                    }),
                                    _buildMiniGameButton('Wordle', Icons.grid_3x3, Colors.purple, () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WordleScreen()));
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildMiniGameButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade300, color.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _feedbackController.dispose();
    _streakController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

// Custom painter for confetti effect
class ConfettiPainter extends CustomPainter {
  final double progress;
  
  ConfettiPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    
    for (int i = 0; i < 50; i++) {
      paint.color = colors[i % colors.length];
      
      final x = (i * 37.0) % size.width;
      final y = (progress * size.height * 1.5) - (i * 20.0) % (size.height * 0.5);
      
      if (y > -10 && y < size.height + 10) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}