import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  final TTSService _ttsService = TTSService();
  final String _targetWord = 'STUDY';
  final List<List<String>> _guesses = List.generate(6, (index) => List.filled(5, ''));
  final List<List<Color>> _colors = List.generate(6, (index) => List.filled(5, Colors.grey.shade200));
  int _currentRow = 0;
  int _currentCol = 0;
  bool _gameOver = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() {
    _ttsService.speak('Wordle Game. Guess the 5-letter word. You have 6 attempts.');
  }

  void _addLetter(String letter) {
    if (_currentCol < 5 && _currentRow < 6 && !_gameOver) {
      setState(() {
        _guesses[_currentRow][_currentCol] = letter;
        _currentCol++;
      });
    }
  }

  void _removeLetter() {
    if (_currentCol > 0 && !_gameOver) {
      setState(() {
        _currentCol--;
        _guesses[_currentRow][_currentCol] = '';
      });
    }
  }

  void _submitGuess() {
    if (_currentCol == 5 && !_gameOver) {
      String guess = _guesses[_currentRow].join('');
      _ttsService.speak('You guessed $guess');
      
      // Check the guess
      for (int i = 0; i < 5; i++) {
        String letter = _guesses[_currentRow][i];
        if (letter == _targetWord[i]) {
          // Correct position
          _colors[_currentRow][i] = Colors.green;
        } else if (_targetWord.contains(letter)) {
          // Wrong position
          _colors[_currentRow][i] = Colors.yellow;
        } else {
          // Not in word
          _colors[_currentRow][i] = Colors.grey;
        }
      }
      
      setState(() {
        if (guess == _targetWord) {
          _gameOver = true;
          _won = true;
          _ttsService.speak('Congratulations! You won!');
        } else if (_currentRow == 5) {
          _gameOver = true;
          _ttsService.speak('Game over! The word was $_targetWord');
        } else {
          _currentRow++;
          _currentCol = 0;
          _ttsService.speak('Try again. Attempt ${_currentRow + 1} of 6');
        }
      });
    } else if (_currentCol < 5) {
      _ttsService.speak('Please complete the word');
    }
  }

  void _resetGame() {
    setState(() {
      _guesses.clear();
      _colors.clear();
      _guesses.addAll(List.generate(6, (index) => List.filled(5, '')));
      _colors.addAll(List.generate(6, (index) => List.filled(5, Colors.grey.shade200)));
      _currentRow = 0;
      _currentCol = 0;
      _gameOver = false;
      _won = false;
    });
    _speakWelcome();
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
                      
                      const Spacer(),
                      
                      // Title
                      Text(
                        'Wordle',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      const Spacer(),
                    ],
                  ),
                ),
                
                // Game Board
                Expanded(
                  child: Container(
                    width: 294,
                    height: 596,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Game status
                          if (_gameOver)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _won ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _won ? 'You Won!' : 'Game Over!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          
                          if (_gameOver) const SizedBox(height: 16),
                          
                          // Word Grid
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (row) => 
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (col) => 
                                      Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: _colors[row][col],
                                          border: Border.all(
                                            color: _guesses[row][col].isEmpty 
                                              ? Colors.grey.shade400 
                                              : Colors.grey.shade600,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _guesses[row][col],
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: _colors[row][col] == Colors.grey.shade200 
                                                ? Colors.black 
                                                : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Keyboard
                          if (!_gameOver) ...[
                            const SizedBox(height: 20),
                            _buildKeyboard(),
                          ],
                          
                          // Reset button
                          if (_gameOver) ...[
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Play Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildKeyboard() {
    final rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
    ];

    return Column(
      children: rows.map((row) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) => 
              GestureDetector(
                onTap: () {
                  if (key == 'ENTER') {
                    _submitGuess();
                  } else if (key == '⌫') {
                    _removeLetter();
                  } else {
                    _addLetter(key);
                  }
                },
                child: Container(
                  width: key == 'ENTER' || key == '⌫' ? 60 : 30,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: key == 'ENTER' || key == '⌫' ? 10 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ).toList(),
          ),
        ),
      ).toList(),
    );
  }
}