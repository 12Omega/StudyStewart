import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

class KinestheticScreen extends StatefulWidget {
  const KinestheticScreen({super.key});

  @override
  State<KinestheticScreen> createState() => _KinestheticScreenState();
}

class _KinestheticScreenState extends State<KinestheticScreen> {
  final TTSService _ttsService = TTSService();
  int _currentQuestion = 7;
  final int _totalQuestions = 10;
  String _selectedAnswer = '';
  
  final String _question = 'Mars is called the "Red Planet" because of its red appearance. It is the fourth planet from the Sun. The "Red Planet" is:';
  final List<String> _answers = ['Venus', 'Mars', 'Earth', 'Jupiter'];
  final String _correctAnswer = 'Mars';

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() {
    _ttsService.speak('Reading Exercise. Question 7 of 10. Fill in the blank.');
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
    _ttsService.speak('Selected $answer');
  }

  void _submitAnswer() {
    if (_selectedAnswer.isEmpty) {
      _ttsService.speak('Please select an answer');
      return;
    }
    
    if (_selectedAnswer == _correctAnswer) {
      _ttsService.speak('Correct! Well done.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! Well done.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _ttsService.speak('Incorrect. The correct answer is $_correctAnswer');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect. The correct answer is $_correctAnswer'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // Move to next question after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = '';
        });
        
        if (_currentQuestion > _totalQuestions) {
          _ttsService.speak('Exercise completed! Great job.');
          Navigator.pop(context);
        } else {
          _ttsService.speak('Question $_currentQuestion of $_totalQuestions');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentQuestion / _totalQuestions;
    
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
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Reading Exercise',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Progress
                        Row(
                          children: [
                            Text(
                              '$_currentQuestion/$_totalQuestions',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Progress Bar
                        Container(
                          width: double.infinity,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              // Progress indicator circle
                              Positioned(
                                left: (MediaQuery.of(context).size.width - 40) * progress - 8,
                                top: -5,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Question Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fill in the blank:',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                _question,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Answer Options
                        Text(
                          'Choose the correct word:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Column(
                          children: _answers.map((answer) => 
                            _buildAnswerOption(answer)
                          ).toList(),
                        ),
                        
                        const Spacer(),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _selectedAnswer.isNotEmpty ? _submitAnswer : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Submit Answer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildAnswerOption(String answer) {
    final isSelected = _selectedAnswer == answer;
    
    return GestureDetector(
      onTap: () => _selectAnswer(answer),
      child: Container(
        width: double.infinity,
        height: 42,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}