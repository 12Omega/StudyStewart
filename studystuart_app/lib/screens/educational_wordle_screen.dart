import 'package:flutter/material.dart';
import 'dart:math';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class EducationalWordleScreen extends StatefulWidget {
  const EducationalWordleScreen({super.key});

  @override
  State<EducationalWordleScreen> createState() => _EducationalWordleScreenState();
}

class _EducationalWordleScreenState extends State<EducationalWordleScreen> {
  final TTSService _ttsService = TTSService();
  final Random _random = Random();
  
  String _currentCategory = 'Science';
  String _targetWord = '';
  String _wordDefinition = '';
  final List<List<String>> _guesses = List.generate(6, (index) => List.filled(5, ''));
  final List<List<Color>> _colors = List.generate(6, (index) => List.filled(5, Colors.grey.shade200));
  int _currentRow = 0;
  int _currentCol = 0;
  bool _gameOver = false;
  bool _won = false;
  int _score = 0;
  int _streak = 0;

  final Map<String, List<Map<String, String>>> _wordCategories = {
    'Science': [
      {'word': 'ATOMS', 'definition': 'Basic units of matter'},
      {'word': 'CELLS', 'definition': 'Basic units of life'},
      {'word': 'GENES', 'definition': 'Units of heredity'},
      {'word': 'LIGHT', 'definition': 'Electromagnetic radiation'},
      {'word': 'SOUND', 'definition': 'Vibrations through air'},
      {'word': 'WATER', 'definition': 'H2O compound'},
      {'word': 'PLANT', 'definition': 'Living organism that photosynthesizes'},
      {'word': 'EARTH', 'definition': 'Our home planet'},
      {'word': 'SPACE', 'definition': 'The universe beyond Earth'},
      {'word': 'FORCE', 'definition': 'Push or pull on an object'},
    ],
    'Math': [
      {'word': 'ANGLE', 'definition': 'Space between two intersecting lines'},
      {'word': 'GRAPH', 'definition': 'Visual representation of data'},
      {'word': 'PRIME', 'definition': 'Number divisible only by 1 and itself'},
      {'word': 'RATIO', 'definition': 'Comparison of two quantities'},
      {'word': 'SLOPE', 'definition': 'Steepness of a line'},
      {'word': 'CHORD', 'definition': 'Line segment connecting two points on a circle'},
      {'word': 'DIGIT', 'definition': 'Single number from 0 to 9'},
      {'word': 'EQUAL', 'definition': 'Same in value or amount'},
      {'word': 'MINUS', 'definition': 'Subtraction operation'},
      {'word': 'ROUND', 'definition': 'Approximate to nearest value'},
    ],
    'History': [
      {'word': 'KINGS', 'definition': 'Male rulers of kingdoms'},
      {'word': 'WARS', 'definition': 'Armed conflicts between nations'}, // 4 letters, need 5
      {'word': 'PEACE', 'definition': 'State of harmony and no conflict'},
      {'word': 'TRADE', 'definition': 'Exchange of goods and services'},
      {'word': 'CROWN', 'definition': 'Royal headpiece symbolizing authority'},
      {'word': 'SWORD', 'definition': 'Weapon used by ancient warriors'},
      {'word': 'CASTLE', 'definition': 'Fortified residence of nobility'}, // 6 letters, need 5
      {'word': 'QUEEN', 'definition': 'Female ruler or king\'s wife'},
      {'word': 'TRIBE', 'definition': 'Social group with common ancestry'},
      {'word': 'STONE', 'definition': 'Material used in ancient construction'},
    ],
    'Geography': [
      {'word': 'OCEAN', 'definition': 'Large body of salt water'},
      {'word': 'RIVER', 'definition': 'Natural flowing watercourse'},
      {'word': 'MOUNT', 'definition': 'Large natural elevation'},
      {'word': 'PLAIN', 'definition': 'Large area of flat land'},
      {'word': 'COAST', 'definition': 'Land along the sea'},
      {'word': 'BEACH', 'definition': 'Sandy or rocky shore'},
      {'word': 'FIELD', 'definition': 'Open area of land'},
      {'word': 'WOODS', 'definition': 'Area covered with trees'},
      {'word': 'CLIFF', 'definition': 'Steep rock face'},
      {'word': 'LAKES', 'definition': 'Bodies of fresh water'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectRandomWord();
    _speakWelcome();
  }

  void _selectRandomWord() {
    final categoryWords = _wordCategories[_currentCategory]!;
    final selectedWord = categoryWords[_random.nextInt(categoryWords.length)];
    _targetWord = selectedWord['word']!;
    _wordDefinition = selectedWord['definition']!;
  }

  void _speakWelcome() {
    _ttsService.speak('Educational Wordle! Category: $_currentCategory. Guess the 5-letter word. Hint: $_wordDefinition');
  }

  void _changeCategory(String newCategory) {
    setState(() {
      _currentCategory = newCategory;
      _resetGame();
    });
    _selectRandomWord();
    _ttsService.speak('Category changed to $_currentCategory. New word hint: $_wordDefinition');
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
          _score += (6 - _currentRow) * 10; // More points for fewer guesses
          _streak++;
          _ttsService.speak('Excellent! You guessed $_targetWord correctly! Definition: $_wordDefinition. Score: $_score');
        } else if (_currentRow == 5) {
          _gameOver = true;
          _streak = 0;
          _ttsService.speak('The word was $_targetWord. Definition: $_wordDefinition');
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

  void _nextWord() {
    _resetGame();
    _selectRandomWord();
    _ttsService.speak('New word! Hint: $_wordDefinition');
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
  }

  void _showHint() {
    _ttsService.speak('Hint: $_wordDefinition. The word starts with ${_targetWord[0]}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hint: $_wordDefinition\nStarts with: ${_targetWord[0]}'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal.shade100,
                  Colors.cyan.shade100,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            const Text(
                              'Educational Wordle',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Score: $_score | Streak: $_streak',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _showHint,
                          icon: const Icon(Icons.lightbulb_outline),
                        ),
                      ],
                    ),
                  ),
                  
                  // Category selector
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _wordCategories.keys.map((category) {
                        final isSelected = category == _currentCategory;
                        return GestureDetector(
                          onTap: () => _changeCategory(category),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.teal : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Definition hint
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Definition: $_wordDefinition',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Game Board
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Game status
                          if (_gameOver)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _won ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _won ? 'Correct! +${(6 - _currentRow) * 10} points' : 'Try Again!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          
                          if (_gameOver) const SizedBox(height: 12),
                          
                          // Word Grid
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (row) => 
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (col) => 
                                      Container(
                                        width: 45,
                                        height: 45,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: _colors[row][col],
                                          border: Border.all(
                                            color: _guesses[row][col].isEmpty 
                                              ? Colors.grey.shade400 
                                              : Colors.grey.shade600,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _guesses[row][col],
                                            style: TextStyle(
                                              fontSize: 18,
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
                          
                          // Action buttons
                          if (_gameOver) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _nextWord,
                                  icon: const Icon(Icons.skip_next),
                                  label: const Text('Next Word'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.home),
                                  label: const Text('Home'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          // Keyboard
                          if (!_gameOver) ...[
                            const SizedBox(height: 16),
                            _buildKeyboard(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                  width: key == 'ENTER' || key == '⌫' ? 55 : 28,
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.teal.shade300),
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: key == 'ENTER' || key == '⌫' ? 9 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
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