import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import '../services/tts_service.dart';
import '../services/emotional_feedback_service.dart';
import '../widgets/tts_button.dart';
import '../widgets/study_mascot.dart';
import '../widgets/document_concept_selector.dart';
import '../constants/assets.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> 
    with TickerProviderStateMixin {
  final TTSService _voiceAssistant = TTSService();
  final Random _numberGenerator = Random();
  
  // Animation controllers for emotional design
  late AnimationController _celebrationController;
  late AnimationController _encouragementController;
  late AnimationController _progressController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  // Original variables
  int _currentQuestionNumber = 0;
  int _playerScore = 0;
  int _timeRemainingInSeconds = 30;
  bool _gameIsActive = true;
  
  late int _firstNumber;
  late int _secondNumber;
  late String _mathOperation;
  late int _correctAnswer;
  late List<int> _answerChoices;
  
  final List<String> _availableOperations = ['+', '-', '×', '÷'];
  final int _totalQuestionsInGame = 10;
  
  // Missing variables referenced in UI code
  bool _gameActive = true;
  int _currentQuestion = 0;
  int _totalQuestions = 10;
  int _timeLeft = 30;
  int _num1 = 0;
  int _num2 = 0;
  String _operation = '+';
  List<int> _options = [];
  int _score = 0;
  int _streak = 0;
  
  // Mascot state
  MascotEmotion _mascotEmotion = MascotEmotion.excited;
  String? _mascotMessage;
  
  // Document/Concept selection
  StudyDocument? _selectedDocument;
  String? _selectedConcept;
  List<StudyDocument> _availableDocuments = [];
  List<String> _availableConcepts = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeSampleData();
    // Initialize all game state variables
    _gameActive = true;
    _currentQuestion = 0;
    _totalQuestions = 10;
    _timeLeft = 30;
    _score = 0;
    _streak = 0;
    
    _createNewMathProblem();
    _welcomePlayerToMathGame();
    _startQuestionTimer();
  }

  void _initializeSampleData() {
    // Initialize sample documents and concepts for math
    _availableDocuments = SampleDocuments.getNepalSamples()
        .where((doc) => doc.subject == 'Mathematics')
        .toList();
    
    _availableConcepts = SampleDocuments.getNepalConcepts()
        .where((concept) => concept.contains('Operations') || 
                           concept.contains('Fractions') || 
                           concept.contains('Geometry') || 
                           concept.contains('Algebra'))
        .toList();
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _encouragementController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _encouragementController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _encouragementController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Give the player an enthusiastic welcome to the math adventure
  void _welcomePlayerToMathGame() {
    _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('math'));
  }

  /// Create a fun new math problem for the player to solve
  void _generateQuestion() {
    _mathOperation = _availableOperations[_numberGenerator.nextInt(_availableOperations.length)];
    
    switch (_mathOperation) {
      case '+':
        _firstNumber = _numberGenerator.nextInt(50) + 1;
        _secondNumber = _numberGenerator.nextInt(50) + 1;
        _correctAnswer = _firstNumber + _secondNumber;
        break;
      case '-':
        _firstNumber = _numberGenerator.nextInt(50) + 25;
        _secondNumber = _numberGenerator.nextInt(25) + 1;
        _correctAnswer = _firstNumber - _secondNumber;
        break;
      case '×':
        _firstNumber = _numberGenerator.nextInt(12) + 1;
        _secondNumber = _numberGenerator.nextInt(12) + 1;
        _correctAnswer = _firstNumber * _secondNumber;
        break;
      case '÷':
        _correctAnswer = _numberGenerator.nextInt(12) + 1;
        _secondNumber = _numberGenerator.nextInt(12) + 1;
        _firstNumber = _correctAnswer * _secondNumber;
        break;
    }
    
    _createAnswerChoices();
    _announceNewProblem();
  }

  /// Check if the player's answer is correct and provide emotional feedback
  void _checkAnswer(int selectedAnswer) {
    if (!_gameActive) return;
    
    setState(() {
      _gameActive = false;
    });
    
    if (selectedAnswer == _correctAnswer) {
      // Correct answer - celebrate!
      _streak++;
      _score += 10 + (_streak * 2); // Bonus points for streaks
      
      // Update mascot to celebrate
      setState(() {
        _mascotEmotion = MascotEmotion.celebrating;
        _mascotMessage = EmotionalFeedbackService().getRandomEncouragement();
      });
      
      // Trigger celebration animation
      _celebrationController.forward().then((_) {
        _celebrationController.reverse();
      });
      
      // Emotional feedback
      EmotionalFeedbackService.celebrateSuccess(
        context,
        type: 'correct',
        intensity: _streak > 3 ? 3 : (_streak > 1 ? 2 : 1),
      );
      
      // Encouraging voice feedback
      final encouragements = [
        "Fantastic! You're on fire! 🔥",
        "Perfect! Keep up the amazing work! ⭐",
        "Brilliant! You're a math superstar! 🌟",
        "Outstanding! Your brain is working perfectly! 🧠",
        "Incredible! You're unstoppable! 🚀"
      ];
      _voiceAssistant.speak(encouragements[_numberGenerator.nextInt(encouragements.length)]);
      
    } else {
      // Wrong answer - encourage and support
      _streak = 0;
      
      // Update mascot to be encouraging
      setState(() {
        _mascotEmotion = MascotEmotion.encouraging;
        _mascotMessage = "Don't worry, you've got this! 💪";
      });
      
      // Gentle encouragement animation
      _encouragementController.forward().then((_) {
        _encouragementController.reverse();
      });
      
      // Supportive feedback
      EmotionalFeedbackService.provideMicroFeedback(context, 'wrong_answer');
      
      // Supportive voice feedback
      final supportiveMessages = [
        "No worries! Let's try the next one together! 🤗",
        "That's okay! Learning is all about practice! 📚",
        "Close one! You're getting better with each try! 💪",
        "Don't give up! Every mistake helps you learn! 🌱",
        "Keep going! You're doing great! ⭐"
      ];
      _voiceAssistant.speak(supportiveMessages[_numberGenerator.nextInt(supportiveMessages.length)]);
    }
    
    // Move to next question after a brief pause
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  /// Move to the next question with smooth transitions
  void _moveToNextQuestion() {
    setState(() {
      _currentQuestion++;
      _gameActive = true;
      _mascotEmotion = MascotEmotion.thinking;
      _mascotMessage = "Let's solve this one! 🤔";
    });
    
    if (_currentQuestion < _totalQuestions) {
      _createNewMathProblem();
      _resetTimer();
    } else {
      _endGame();
    }
  }

  /// End the game with celebration based on performance
  void _endGame() {
    setState(() {
      _gameActive = false;
    });
    
    final percentage = (_score / (_totalQuestions * 10)) * 100;
    
    if (percentage >= 80) {
      // Excellent performance
      setState(() {
        _mascotEmotion = MascotEmotion.celebrating;
        _mascotMessage = "Amazing! You're a math champion! 🏆";
      });
      
      EmotionalFeedbackService.celebrateSuccess(
        context,
        type: 'level_up',
        intensity: 3,
      );
      
      _voiceAssistant.speak("Incredible! You scored ${percentage.toInt()}%! You're a true math champion! 🏆");
      
    } else if (percentage >= 60) {
      // Good performance
      setState(() {
        _mascotEmotion = MascotEmotion.happy;
        _mascotMessage = "Great job! Keep practicing! 🌟";
      });
      
      EmotionalFeedbackService.celebrateSuccess(
        context,
        type: 'correct',
        intensity: 2,
      );
      
      _voiceAssistant.speak("Well done! You scored ${percentage.toInt()}%! Keep up the great work! 🌟");
      
    } else {
      // Encouraging for lower scores
      setState(() {
        _mascotEmotion = MascotEmotion.encouraging;
        _mascotMessage = "Every practice makes you stronger! 💪";
      });
      
      _voiceAssistant.speak("Great effort! You scored ${percentage.toInt()}%. Remember, every practice session makes you stronger! Keep going! 💪");
    }
  }
      int wrongAnswer;
      if (_mathOperation == '÷') {
        wrongAnswer = _correctAnswer + _numberGenerator.nextInt(10) - 5;
      } else {
        wrongAnswer = _correctAnswer + _numberGenerator.nextInt(20) - 10;
      }
      
      if (wrongAnswer > 0 && !_answerChoices.contains(wrongAnswer)) {
        _answerChoices.add(wrongAnswer);
      }
    }
    
    _answerChoices.shuffle();
  }

  /// Tell the player about their new math challenge in a friendly way
  void _announceNewProblem() {
    String operationWord = _mathOperation == '×' ? 'times' : 
                          _mathOperation == '÷' ? 'divided by' :
                          _mathOperation == '+' ? 'plus' : 'minus';
    final questionNumber = _currentQuestionNumber + 1;
    _voiceAssistant.speak('Here\'s challenge number $questionNumber: $_firstNumber $operationWord $_secondNumber equals what?');
  }

  /// Start the countdown timer for each question
  void _startQuestionTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_gameIsActive && _timeRemainingInSeconds > 0 && mounted) {
        setState(() {
          _timeRemainingInSeconds--;
          _timeLeft = _timeRemainingInSeconds; // Keep UI variable in sync
        });
        
        // Give a friendly warning when time is running low
        if (_timeRemainingInSeconds == 10) {
          _voiceAssistant.speak('10 seconds left! You can do this!');
        } else if (_timeRemainingInSeconds == 5) {
          _voiceAssistant.speak('5 seconds! Almost there!');
        }
        
        _startQuestionTimer();
      } else if (_timeRemainingInSeconds == 0 && _gameIsActive) {
        _handleTimeUp();
      }
    });
  }

  /// Handle when time runs out - be encouraging, not discouraging
  void _handleTimeUp() {
    _voiceAssistant.speak('Time\'s up! No worries, let\'s see the next one!');
    _moveToNextQuestion();
  }

  /// Process the player's answer with encouraging feedback
  void _checkPlayerAnswer(int selectedAnswer) {
    if (!_gameIsActive) return;
    
    final isCorrect = selectedAnswer == _correctAnswer;
    
    if (isCorrect) {
      _playerScore++;
      setState(() {
        _score = _playerScore; // Keep UI variable in sync
      });
      _voiceAssistant.speak(_voiceAssistant.getCorrectAnswerMessage());
    } else {
      _voiceAssistant.speak('${_voiceAssistant.getIncorrectAnswerMessage()} The answer was $_correctAnswer.');
    }
    
    _moveToNextQuestion();
  }

  /// Move to the next question or end the game
  void _moveToNextQuestion() {
    setState(() {
      _currentQuestionNumber++;
      _timeRemainingInSeconds = 30;
      // Keep UI variables in sync
      _currentQuestion = _currentQuestionNumber;
      _timeLeft = _timeRemainingInSeconds;
    });
    
    if (_currentQuestionNumber < _totalQuestionsInGame) {
      _generateQuestion();
      // Update UI variables after generating new question
      setState(() {
        _num1 = _firstNumber;
        _num2 = _secondNumber;
        _operation = _mathOperation;
        _options = List.from(_answerChoices);
      });
    } else {
      _celebrateGameCompletion();
    }
  }

  /// Celebrate the player's effort and show results
  void _celebrateGameCompletion() {
    setState(() {
      _gameIsActive = false;
      _gameActive = false; // Keep UI variable in sync
    });
    
    _voiceAssistant.speak(_voiceAssistant.getGameCompleteMessage(_playerScore, _totalQuestionsInGame));
  }

  /// Let the player start a fresh new game
  void _startNewGame() {
    setState(() {
      _currentQuestionNumber = 0;
      _playerScore = 0;
      _timeRemainingInSeconds = 30;
      _gameIsActive = true;
      // Reset UI variables
      _gameActive = true;
      _currentQuestion = 0;
      _timeLeft = 30;
      _score = 0;
    });
    _createNewMathProblem();
    _startQuestionTimer();
  }

  /// Create a new math problem and sync all variables
  void _createNewMathProblem() {
    _generateQuestion();
    // Sync the UI variables with the internal variables
    setState(() {
      _gameActive = _gameIsActive;
      _currentQuestion = _currentQuestionNumber;
      _totalQuestions = _totalQuestionsInGame;
      _timeLeft = _timeRemainingInSeconds;
      _num1 = _firstNumber;
      _num2 = _secondNumber;
      _operation = _mathOperation;
      _options = List.from(_answerChoices);
      _score = _playerScore;
    });
  }

  /// Handle player's answer selection
  void _answerQuestion(int option) {
    _checkPlayerAnswer(option);
  }

  /// Start a new game (alias for _startNewGame for UI consistency)
  void _playAgain() {
    setState(() {
      _currentQuestionNumber = 0;
      _playerScore = 0;
      _timeRemainingInSeconds = 30;
      _gameIsActive = true;
      // Reset UI variables
      _gameActive = true;
      _currentQuestion = 0;
      _timeLeft = 30;
      _score = 0;
    });
    _createNewMathProblem();
    _startQuestionTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Force left-to-right text direction
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Math Magic Challenge! 🔢'),
          backgroundColor: Colors.orange.shade100,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Your Score: $_playerScore',
                  style: const TextStyle(
                    fontSize: 18,
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
                    Colors.orange.shade100,
                    Colors.red.shade100,
                  ],
                ),
              ),
              child: SafeArea(
                child: _gameActive && _currentQuestion < _totalQuestions
                    ? _buildQuestionCard()
                    : _buildResultCard(),
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
      ),
    );
  }

  Widget _buildQuestionCard() {
    final progress = (_currentQuestion + 1) / _totalQuestions;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress and Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1}/$_totalQuestions',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10 ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${_timeLeft}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                
                const SizedBox(height: 32),
                
                // Math equation with visual aid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '$_num1 $_operation $_num2 = ?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Visual aid for the operation
                      Container(
                        height: 120,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity(), // Ensure no unwanted transformations
                          child: SvgPicture.asset(
                            AppAssets.getMathVisual(_operation),
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Answer options
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2,
                  children: _options.map((option) {
                    return ElevatedButton(
                      onPressed: () => _answerQuestion(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        option.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final percentage = (_score / _totalQuestions) * 100;
    
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
                  percentage >= 70 ? Icons.emoji_events : Icons.thumb_up,
                  size: 80,
                  color: percentage >= 70 ? Colors.amber : Colors.orange,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  percentage >= 70 ? 'Excellent!' : 'Good Job!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'You scored $_score out of $_totalQuestions',
                  style: const TextStyle(fontSize: 18),
                ),
                
                Text(
                  '${percentage.round()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _playAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
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
}
  /// Create multiple choice options including the correct answer
  void _createAnswerChoices() {
    _answerChoices = [_correctAnswer];
    
    while (_answerChoices.length < 4) {
      int wrongAnswer;
      switch (_mathOperation) {
        case '+':
          wrongAnswer = _correctAnswer + _numberGenerator.nextInt(20) - 10;
          break;
        case '-':
          wrongAnswer = _correctAnswer + _numberGenerator.nextInt(20) - 10;
          break;
        case '×':
          wrongAnswer = _correctAnswer + _numberGenerator.nextInt(30) - 15;
          break;
        case '÷':
          wrongAnswer = _correctAnswer + _numberGenerator.nextInt(10) - 5;
          break;
        default:
          wrongAnswer = _correctAnswer + _numberGenerator.nextInt(10) - 5;
      }
      
      if (wrongAnswer > 0 && !_answerChoices.contains(wrongAnswer)) {
        _answerChoices.add(wrongAnswer);
      }
    }
    
    _answerChoices.shuffle();
    _options = _answerChoices; // Update the options list
  }

  /// Create a new math problem with emotional setup
  void _createNewMathProblem() {
    _generateQuestion();
    _createAnswerChoices();
    
    // Update display variables
    _num1 = _firstNumber;
    _num2 = _secondNumber;
    _operation = _mathOperation;
    
    // Update progress animation
    _progressController.reset();
    _progressController.forward();
  }

  /// Reset the timer for the next question
  void _resetTimer() {
    _timeLeft = 30;
    _startQuestionTimer();
  }

  /// Start the question timer with visual feedback
  void _startQuestionTimer() {
    // Timer implementation would go here
    // For now, we'll just set the time
    setState(() {
      _timeLeft = 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade300,
                  Colors.purple.shade300,
                  Colors.pink.shade200,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Document/Concept Selector at the top
                DocumentConceptSelector(
                  availableDocuments: _availableDocuments,
                  availableConcepts: _availableConcepts,
                  selectedDocument: _selectedDocument,
                  selectedConcept: _selectedConcept,
                  onDocumentSelected: (document) {
                    setState(() {
                      _selectedDocument = document;
                      _selectedConcept = null; // Clear concept when document is selected
                    });
                  },
                  onConceptSelected: (concept) {
                    setState(() {
                      _selectedConcept = concept;
                      _selectedDocument = null; // Clear document when concept is selected
                    });
                  },
                ),
                
                // Header with mascot and progress
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button with micro-interaction
                      GestureDetector(
                        onTap: () {
                          EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      // Animated mascot
                      StudyMascot(
                        emotion: _mascotEmotion,
                        size: MascotSize.medium,
                        message: _mascotMessage,
                      ),
                      
                      // Score with celebration animation
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _bounceAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_score',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
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
                
                // Progress indicator with momentum
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EmotionalFeedbackService.createProgressAnimation(
                    progress: (_currentQuestion + 1) / _totalQuestions,
                    label: 'Question ${_currentQuestion + 1} of $_totalQuestions',
                    color: Colors.white,
                    showSparkles: true,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Game content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Math problem display
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (_progressAnimation.value * 0.2),
                                    child: Container(
                                      padding: const EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.blue.shade50, Colors.purple.shade50],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '$_num1 $_operation $_num2 = ?',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Answer options with premium styling
                          Expanded(
                            flex: 3,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _options.length,
                              itemBuilder: (context, index) {
                                return _buildAnswerButton(_options[index]);
                              },
                            ),
                          ),
                          
                          // Streak indicator
                          if (_streak > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade400, Colors.red.shade400],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_streak streak!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
        ],
      ),
      
      // Positioned TTS Button in bottom right
      floatingActionButton: const PositionedTTSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAnswerButton(int answer) {
    return GestureDetector(
      onTap: () => _checkAnswer(answer),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$answer',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}