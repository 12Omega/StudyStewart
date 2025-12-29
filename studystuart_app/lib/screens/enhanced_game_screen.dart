import 'package:flutter/material.dart';
import '../services/ai_content_analyzer.dart';
import '../services/tts_service.dart';
import '../services/emotional_feedback_service.dart';

class EnhancedGameScreen extends StatefulWidget {
  final EnhancedConcepts enhancedConcepts;
  final LearningStyle selectedLearningStyle;
  final MultiStyleGameContent multiStyleContent;

  const EnhancedGameScreen({
    super.key,
    required this.enhancedConcepts,
    required this.selectedLearningStyle,
    required this.multiStyleContent,
  });

  @override
  State<EnhancedGameScreen> createState() => _EnhancedGameScreenState();
}

class _EnhancedGameScreenState extends State<EnhancedGameScreen>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  late TabController _tabController;
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalQuestions = 0;
  bool _showAnswer = false;
  List<Question> _currentQuestions = [];
  List<Problem> _currentProblems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeGameContent();
    _speakWelcome();
  }

  void _initializeGameContent() {
    _currentQuestions = widget.enhancedConcepts.internetResources.educationalQuestions;
    _currentProblems = widget.enhancedConcepts.internetResources.practiceProblems;
    _totalQuestions = _currentQuestions.length + _currentProblems.length;
  }

  void _speakWelcome() {
    final style = widget.selectedLearningStyle.name;
    final subject = widget.enhancedConcepts.originalConcepts.subject;
    _ttsService.speak('Welcome to your enhanced $style learning experience for $subject. This game combines your document content with comprehensive internet resources for complete understanding.');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced ${widget.selectedLearningStyle.name.toUpperCase()} Learning'),
        backgroundColor: _getStyleColor(),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.quiz), text: 'Questions'),
            Tab(icon: Icon(Icons.assignment), text: 'Problems'),
            Tab(icon: Icon(Icons.public), text: 'Resources'),
            Tab(icon: Icon(Icons.analytics), text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestionsTab(),
          _buildProblemsTab(),
          _buildResourcesTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Color _getStyleColor() {
    switch (widget.selectedLearningStyle) {
      case LearningStyle.visual:
        return Colors.purple;
      case LearningStyle.auditory:
        return Colors.orange;
      case LearningStyle.kinesthetic:
        return Colors.green;
      case LearningStyle.readWrite:
        return Colors.blue;
    }
  }

  Widget _buildQuestionsTab() {
    if (_currentQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No questions available', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    final question = _currentQuestions[_currentQuestionIndex % _currentQuestions.length];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _currentQuestions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_getStyleColor()),
          ),
          SizedBox(height: 16),
          
          // Question info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_currentQuestions.length}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  question.difficulty,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Question text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              question.question,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return _buildAnswerOption(question, index);
              },
            ),
          ),
          
          // Explanation (shown after answer)
          if (_showAnswer) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(question.explanation),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Next question button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStyleColor(),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentQuestionIndex < _currentQuestions.length - 1
                      ? 'Next Question'
                      : 'Complete Questions',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption(Question question, int index) {
    final isCorrect = index == question.correctAnswer;
    final isSelected = _showAnswer;
    
    Color? backgroundColor;
    Color? borderColor;
    
    if (_showAnswer) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
      } else {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _showAnswer ? null : () => _selectAnswer(index, question),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _showAnswer && isCorrect ? Colors.green : Colors.grey.shade300,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: _showAnswer && isCorrect ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(fontSize: 14),
                ),
              ),
              if (_showAnswer && isCorrect)
                Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProblemsTab() {
    if (_currentProblems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No practice problems available', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _currentProblems.length,
      itemBuilder: (context, index) {
        final problem = _currentProblems[index];
        return _buildProblemCard(problem, index);
      },
    );
  }

  Widget _buildProblemCard(Problem problem, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          'Problem ${index + 1}: ${problem.type.replaceAll('_', ' ').toUpperCase()}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${problem.difficulty} • ${problem.points} points',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  problem.problem,
                  style: TextStyle(fontSize: 16),
                ),
                
                if (problem.options.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Options:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...problem.options.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text('${String.fromCharCode(65 + entry.key)}. ${entry.value}'),
                    );
                  }),
                ],
                
                SizedBox(height: 16),
                
                ExpansionTile(
                  title: Text('Hints', style: TextStyle(color: Colors.orange)),
                  children: problem.hints.map((hint) => 
                    ListTile(
                      leading: Icon(Icons.lightbulb_outline, color: Colors.orange),
                      title: Text(hint),
                    )
                  ).toList(),
                ),
                
                ExpansionTile(
                  title: Text('Solution', style: TextStyle(color: Colors.green)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Answer: ${problem.correctAnswer}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(problem.solution),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    final resources = widget.enhancedConcepts.internetResources;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wikipedia Articles
          if (resources.wikipediaContent.isNotEmpty) ...[
            _buildResourceSection(
              'Wikipedia Articles',
              Icons.public,
              resources.wikipediaContent.map((article) => 
                _buildWikipediaCard(article)
              ).toList(),
            ),
            SizedBox(height: 24),
          ],
          
          // Related Concepts
          if (resources.relatedConcepts.isNotEmpty) ...[
            _buildResourceSection(
              'Related Concepts to Explore',
              Icons.explore,
              [_buildConceptsGrid(resources.relatedConcepts)],
            ),
            SizedBox(height: 24),
          ],
          
          // Original Document Summary
          _buildResourceSection(
            'Your Document Analysis',
            Icons.description,
            [_buildDocumentSummary()],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _getStyleColor()),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getStyleColor(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildWikipediaCard(WikipediaArticle article) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              article.summary,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (article.url.isNotEmpty) ...[
              SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  _ttsService.speak('Opening Wikipedia article: ${article.title}');
                  // In a real app, you would open the URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Would open: ${article.url}')),
                  );
                },
                child: Text(
                  'Read full article →',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConceptsGrid(List<String> concepts) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: concepts.take(20).map((concept) => 
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStyleColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getStyleColor().withOpacity(0.3)),
          ),
          child: Text(
            concept,
            style: TextStyle(
              color: _getStyleColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ).toList(),
    );
  }

  Widget _buildDocumentSummary() {
    final concepts = widget.enhancedConcepts.originalConcepts;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject: ${concepts.subject}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Grade Level: ${concepts.gradeLevel}'),
            Text('Difficulty: ${concepts.difficulty}'),
            SizedBox(height: 12),
            Text(
              'Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(concepts.summary),
            SizedBox(height: 12),
            Text(
              'Key Terms: ${concepts.keyTerms.join(', ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    final totalResources = widget.enhancedConcepts.internetResources.educationalQuestions.length +
                          widget.enhancedConcepts.internetResources.practiceProblems.length +
                          widget.enhancedConcepts.internetResources.wikipediaContent.length;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          
          _buildProgressCard(
            'Questions Completed',
            _currentQuestionIndex,
            _currentQuestions.length,
            Icons.quiz,
            Colors.blue,
          ),
          
          _buildProgressCard(
            'Current Score',
            _score,
            _currentQuestions.length,
            Icons.star,
            Colors.orange,
          ),
          
          _buildProgressCard(
            'Total Resources',
            totalResources,
            totalResources,
            Icons.library_books,
            Colors.green,
          ),
          
          SizedBox(height: 24),
          
          Text(
            'Learning Style: ${widget.selectedLearningStyle.name.toUpperCase()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getStyleColor(),
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Subject: ${widget.enhancedConcepts.originalConcepts.subject}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          
          Text(
            'Enhanced with ${widget.enhancedConcepts.internetResources.relatedConcepts.length} related concepts from internet',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, int current, int total, IconData icon, Color color) {
    final percentage = total > 0 ? current / total : 0.0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '$current / $total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _selectAnswer(int selectedIndex, Question question) {
    setState(() {
      _showAnswer = true;
    });
    
    final isCorrect = selectedIndex == question.correctAnswer;
    if (isCorrect) {
      _score++;
      _ttsService.speak('Correct! ${question.explanation}');
      EmotionalFeedbackService.provideMicroFeedback(context, 'success');
    } else {
      _ttsService.speak('Incorrect. The correct answer is ${question.options[question.correctAnswer]}. ${question.explanation}');
      EmotionalFeedbackService.provideMicroFeedback(context, 'error');
    }
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _showAnswer = false;
    });
    
    if (_currentQuestionIndex >= _currentQuestions.length) {
      _showCompletionDialog();
    } else {
      _ttsService.speak('Next question');
    }
  }

  void _showCompletionDialog() {
    final percentage = (_score / _currentQuestions.length * 100).round();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Questions Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Score: $_score / ${_currentQuestions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('$percentage% correct'),
            SizedBox(height: 16),
            Text('Continue exploring practice problems and resources!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _tabController.animateTo(1); // Switch to problems tab
            },
            child: Text('Practice Problems'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to converter
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
    
    _ttsService.speak('Congratulations! You scored $_score out of ${_currentQuestions.length}. That\'s $percentage percent correct.');
  }
}