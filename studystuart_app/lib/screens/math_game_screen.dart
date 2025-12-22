import 'package:flutter/material.dart';
import 'dart:math';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  final TTSService _voiceAssistant = TTSService();
  final Random _numberGenerator = Random();
  
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

  @override
  void initState() {
    super.initState();
    _createNewMathProblem();
    _welcomePlayerToMathGame();
    _startQuestionTimer();
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

  /// Create multiple choice options including the correct answer
  void _createAnswerChoices() {
    _answerChoices = [_correctAnswer];
    
    while (_answerChoices.length < 4) {
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
    });
    
    if (_currentQuestionNumber < _totalQuestionsInGame) {
      _generateQuestion();
    } else {
      _celebrateGameCompletion();
    }
  }

  /// Celebrate the player's effort and show results
  void _celebrateGameCompletion() {
    setState(() {
      _gameIsActive = false;
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
    });
    _generateQuestion();
    _startQuestionTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                
                // Math equation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '$_num1 $_operation $_num2 = ?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
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