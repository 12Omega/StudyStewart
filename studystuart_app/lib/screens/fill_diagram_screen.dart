import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import '../constants/assets.dart';

class FillDiagramScreen extends StatefulWidget {
  const FillDiagramScreen({super.key});

  @override
  State<FillDiagramScreen> createState() => _FillDiagramScreenState();
}

class _FillDiagramScreenState extends State<FillDiagramScreen>
    with TickerProviderStateMixin {
  final TTSService _voiceAssistant = TTSService();
  final Random _random = Random();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _score = 0;
  int _level = 1;
  int _currentDiagram = 0;
  bool _gameActive = true;
  
  // Diagram data with proper SVG assets
  final List<DiagramData> _diagrams = [
    DiagramData(
      title: 'Human Heart',
      imagePath: AppAssets.heartDiagram,
      labels: [
        DiagramLabel('Left Atrium', Offset(0.25, 0.35), 'Left Atrium'),
        DiagramLabel('Right Atrium', Offset(0.75, 0.35), 'Right Atrium'),
        DiagramLabel('Left Ventricle', Offset(0.35, 0.65), 'Left Ventricle'),
        DiagramLabel('Right Ventricle', Offset(0.65, 0.65), 'Right Ventricle'),
      ],
      options: ['Left Atrium', 'Right Atrium', 'Left Ventricle', 'Right Ventricle', 'Aorta', 'Pulmonary Artery'],
    ),
    DiagramData(
      title: 'Plant Cell',
      imagePath: AppAssets.plantCellDiagram,
      labels: [
        DiagramLabel('Nucleus', Offset(0.5, 0.4), 'Nucleus'),
        DiagramLabel('Cell Wall', Offset(0.1, 0.1), 'Cell Wall'),
        DiagramLabel('Chloroplast', Offset(0.25, 0.25), 'Chloroplast'),
        DiagramLabel('Vacuole', Offset(0.7, 0.6), 'Vacuole'),
      ],
      options: ['Nucleus', 'Cell Wall', 'Chloroplast', 'Vacuole', 'Mitochondria', 'Cytoplasm'],
    ),
    DiagramData(
      title: 'Solar System',
      imagePath: AppAssets.solarSystemDiagram,
      labels: [
        DiagramLabel('Sun', Offset(0.125, 0.5), 'Sun'),
        DiagramLabel('Earth', Offset(0.425, 0.5), 'Earth'),
        DiagramLabel('Jupiter', Offset(0.65, 0.5), 'Jupiter'),
        DiagramLabel('Saturn', Offset(0.8, 0.5), 'Saturn'),
      ],
      options: ['Sun', 'Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn', 'Uranus'],
    ),
  ];
  
  String? _selectedOption;
  DiagramLabel? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _speakWelcome();
    _startGame();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  /// Give the player an exciting welcome to the diagram adventure
  void _speakWelcome() {
    _voiceAssistant.speak(_voiceAssistant.getWelcomeMessage('diagram'));
  }

  /// Start a new diagram challenge with enthusiasm
  void _startGame() {
    if (_currentDiagram < _diagrams.length) {
      final diagram = _diagrams[_currentDiagram];
      _voiceAssistant.speak('Level $_level: Time to explore the ${diagram.title}! 🔬 Let\'s fill in those labels together!');
    }
  }

  /// Handle when player selects an answer option
  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
    _voiceAssistant.speak('Great choice! You picked $option. Now tap where it belongs on the diagram!');
  }

  /// Handle when player selects a label position
  void _selectLabel(DiagramLabel label) {
    if (label.isCompleted) return;
    
    setState(() {
      _selectedLabel = label;
    });
    _voiceAssistant.speak('Perfect! You\'ve chosen a spot on the diagram. Now select the right term to fill it in!');
  }

  /// Process the player's answer with encouraging feedback
  void _fillLabel() {
    if (_selectedOption == null || _selectedLabel == null) {
      _voiceAssistant.speak('Almost there! Pick both a term and a spot on the diagram, then I can help you connect them! 😊');
      return;
    }
    
    final diagram = _diagrams[_currentDiagram];
    final isCorrect = _selectedLabel!.correctAnswer == _selectedOption;
    
    if (isCorrect) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      setState(() {
        _selectedLabel!.isCompleted = true;
        _selectedLabel!.userAnswer = _selectedOption!;
        _score += 20 * _level;
        _selectedOption = null;
        _selectedLabel = null;
      });
      
      _voiceAssistant.speak(_voiceAssistant.getCorrectAnswerMessage());
      
      // Check if diagram is complete
      if (diagram.labels.every((label) => label.isCompleted)) {
        _completeDiagram();
      }
    } else {
      _voiceAssistant.speak('${_voiceAssistant.getIncorrectAnswerMessage()} The correct answer is ${_selectedLabel!.correctAnswer}. Let\'s try another one!');
      
      setState(() {
        _selectedOption = null;
        _selectedLabel = null;
      });
    }
  }

  /// Celebrate completing a diagram
  void _completeDiagram() {
    _voiceAssistant.speak('🎉 Amazing work! You completed the diagram perfectly! Ready for the next challenge?');
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _currentDiagram++;
        _level++;
        
        if (_currentDiagram >= _diagrams.length) {
          _gameComplete();
        } else {
          _startGame();
        }
      });
    });
  }

  /// Celebrate the amazing accomplishment of finishing all diagrams
  void _gameComplete() {
    _voiceAssistant.speak('🏆 Incredible! You\'ve mastered all the diagrams! You scored $_score points and learned so much! You should be really proud of yourself!');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations! 🎉'),
        content: Text('You\'re absolutely amazing! You completed all diagrams and learned so much!\n\n🏆 Final Score: $_score points\n\nYou should be really proud of yourself!'),
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
              _resetGame();
            },
            child: const Text('Play Again! 🚀'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _currentDiagram = 0;
      _selectedOption = null;
      _selectedLabel = null;
      
      // Reset all labels
      for (var diagram in _diagrams) {
        for (var label in diagram.labels) {
          label.isCompleted = false;
          label.userAnswer = null;
        }
      }
    });
    
    _startGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentDiagram >= _diagrams.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final diagram = _diagrams[_currentDiagram];
    final completedLabels = diagram.labels.where((l) => l.isCompleted).length;
    final totalLabels = diagram.labels.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Diagram'),
        backgroundColor: Colors.purple.shade100,
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
                  Colors.purple.shade100,
                  Colors.indigo.shade100,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Game stats
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Level', _level.toString(), Colors.purple),
                        _buildStatCard('Progress', '$completedLabels/$totalLabels', Colors.blue),
                        _buildStatCard('Diagram', diagram.title, Colors.indigo),
                      ],
                    ),
                  ),
                  
                  // Diagram area
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Stack(
                          children: [
                            // Diagram SVG display
                            SvgPicture.asset(
                              diagram.imagePath,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            
                            // Labels
                            ...diagram.labels.map((label) => _buildLabel(label)).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Options area
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select the correct term:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: diagram.options.length,
                              itemBuilder: (context, index) {
                                final option = diagram.options[index];
                                final isUsed = diagram.labels.any((l) => l.userAnswer == option);
                                final isSelected = _selectedOption == option;
                                
                                return GestureDetector(
                                  onTap: isUsed ? null : () => _selectOption(option),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isUsed 
                                          ? Colors.grey.shade300
                                          : isSelected 
                                              ? Colors.purple.shade200
                                              : Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? Colors.purple : Colors.purple.shade200,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isUsed 
                                              ? Colors.grey.shade600
                                              : isSelected 
                                                  ? Colors.purple.shade800
                                                  : Colors.purple.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Fill button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_selectedOption != null && _selectedLabel != null) 
                                  ? _fillLabel 
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Fill Label',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(DiagramLabel label) {
    final isSelected = _selectedLabel == label;
    
    return Positioned(
      left: label.position.dx * 300,
      top: label.position.dy * 200,
      child: GestureDetector(
        onTap: () => _selectLabel(label),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: (isSelected && label.isCompleted) ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: label.isCompleted 
                      ? Colors.green.shade100
                      : isSelected 
                          ? Colors.purple.shade100
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: label.isCompleted 
                        ? Colors.green
                        : isSelected 
                            ? Colors.purple
                            : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  label.isCompleted ? label.userAnswer! : '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: label.isCompleted 
                        ? Colors.green.shade800
                        : isSelected 
                            ? Colors.purple.shade800
                            : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DiagramData {
  final String title;
  final String imagePath;
  final List<DiagramLabel> labels;
  final List<String> options;

  DiagramData({
    required this.title,
    required this.imagePath,
    required this.labels,
    required this.options,
  });
}

class DiagramLabel {
  final String correctAnswer;
  final Offset position;
  bool isCompleted;
  String? userAnswer;

  DiagramLabel(
    this.correctAnswer,
    this.position,
    String correctAnswerParam, {
    this.isCompleted = false,
    this.userAnswer,
  });
}