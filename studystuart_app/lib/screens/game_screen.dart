import 'package:flutter/material.dart';
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

class _GameScreenState extends State<GameScreen> {
  final TTSService _ttsService = TTSService();
  int _currentQuestion = 0;
  int _score = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 2 plus 2?',
      'options': ['3', '4', '5', '6'],
      'correct': 1,
    },
    {
      'question': 'What color is the sky?',
      'options': ['Red', 'Blue', 'Green', 'Yellow'],
      'correct': 1,
    },
    {
      'question': 'How many days in a week?',
      'options': ['5', '6', '7', '8'],
      'correct': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakQuestion();
  }

  void _speakQuestion() {
    if (_currentQuestion < _questions.length) {
      final question = _questions[_currentQuestion];
      _ttsService.speak('Question ${_currentQuestion + 1}. ${question['question']}');
    }
  }

  void _answerQuestion(int selectedIndex) {
    final question = _questions[_currentQuestion];
    final isCorrect = selectedIndex == question['correct'];

    if (isCorrect) {
      _score++;
      _ttsService.speak('Correct! Well done.');
    } else {
      _ttsService.speak('Incorrect. Try the next one.');
    }

    setState(() {
      _currentQuestion++;
    });

    if (_currentQuestion < _questions.length) {
      Future.delayed(const Duration(seconds: 2), () {
        _speakQuestion();
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        _ttsService.speak('Game over! Your score is $_score out of ${_questions.length}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Game'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $_score',
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
                  Colors.purple.shade100,
                  Colors.blue.shade100,
                ],
              ),
            ),
            child: SafeArea(
              child: _currentQuestion < _questions.length
                  ? _buildQuestionCard()
                  : _buildResultCard(),
            ),
          ),
          // TTS Button in top right corner
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
    final question = _questions[_currentQuestion];

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
                // Question number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Question ${_currentQuestion + 1} of ${_questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Question text with speaker icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question['question'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () {
                        _ttsService.speak(question['question']);
                      },
                      tooltip: 'Read question',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Answer options
                ...List.generate(
                  question['options'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(index),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                question['options'][index],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 20),
                              onPressed: () {
                                _ttsService.speak(question['options'][index]);
                              },
                            ),
                          ],
                        ),
                      ),
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
