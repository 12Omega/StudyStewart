import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/tts_service.dart';
import '../services/content_processor_service.dart';
import '../services/notification_service.dart';
import '../services/ai_content_analyzer.dart';
import '../widgets/tts_button.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'custom_game_screens.dart';
import 'enhanced_game_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TTSService _ttsService = TTSService();
  final ContentProcessorService _contentProcessor = ContentProcessorService();
  final AIContentAnalyzer _aiAnalyzer = AIContentAnalyzer();
  final TextEditingController _textController = TextEditingController();
  
  int _selectedIndex = 2; // Converter tab is selected
  LearningStyle? _selectedLearningStyle;
  String _selectedGameType = '';
  File? _selectedFile;
  bool _isProcessing = false;
  
  CoreConcepts? _extractedConcepts;
  EnhancedConcepts? _enhancedConcepts;
  MultiStyleGameContent? _multiStyleContent;

  @override
  void initState() {
    super.initState();
    _speakWelcome();
  }

  void _speakWelcome() {
    _ttsService.speak('Study Material Converter. Upload documents or paste text to convert into engaging learning games.');
  }

  void _selectLearningStyle(LearningStyle style) {
    setState(() {
      _selectedLearningStyle = style;
    });
    _ttsService.speak('Selected ${style.name} learning style');
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      _showErrorMessage('Please enter an API key');
      return;
    }

    if (!_apiKeyService.isValidGeminiApiKey(apiKey)) {
      _showErrorMessage('Invalid Gemini API key format. Please check your key.');
      return;
    }

    try {
      await _apiKeyService.setGeminiApiKey(apiKey);
      _aiAnalyzer.initialize(apiKey);
      
      setState(() {
        _useAI = true;
        _showApiKeyInput = false;
      });
      
      _apiKeyController.clear();
      _ttsService.speak('API key saved successfully. AI analysis is now enabled.');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key saved! AI analysis is now enabled.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorMessage('Error saving API key: $e');
    }
  }

  void _showErrorMessage(String message) {
    _ttsService.speak(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _toggleAI() {
    setState(() {
      _useAI = !_useAI;
    });
    _ttsService.speak(_useAI ? 'AI analysis enabled' : 'AI analysis disabled');
  }

  void _showApiKeyDialog() {
    setState(() {
      _showApiKeyInput = true;
    });
  }

  void _clearMaterials() {
    setState(() {
      _selectedFile = null;
      _textController.clear();
      _selectedLearningStyle = null;
      _selectedGameType = '';
      _generatedContent = null;
      _isProcessing = false;
      _uploadedDocuments.clear();
    });
    
    _ttsService.speak('Study materials cleared. Ready for new content.');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study materials cleared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Clear Materials?'),
            ],
          ),
          content: const Text(
            'This will remove all uploaded files, text content, and generated games. Are you sure you want to continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearMaterials();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LearningScreen()),
        );
        break;
      case 2:
        // Stay on Converter
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
    }
  }

  // Removed - replaced with _selectLearningStyle

  void _selectGameType(String gameType) {
    setState(() {
      _selectedGameType = gameType;
    });
    _ttsService.speak('Selected $gameType game type');
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _contentProcessor.getSupportedFileTypes(),
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final document = StudyDocument.fromFile(
          result.files.single.path!,
          result.files.single.name,
        );
        
        setState(() {
          _selectedFile = file;
          _uploadedDocuments.add(document);
        });
        
        _ttsService.speak('File selected: ${result.files.single.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected: ${result.files.single.name}')),
        );
      }
    } catch (e) {
      _ttsService.speak('Error selecting file');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _convertWithAI() async {
    if (_textController.text.isEmpty && _selectedFile == null) {
      _ttsService.speak('Please enter text or upload a file');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or upload a file')),
      );
      return;
    }

    // Check if AI is initialized (you might want to add API key setup)
    if (!_aiAnalyzer.isInitialized) {
      _showApiKeyDialog();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      String content = '';
      
      if (_selectedFile != null) {
        _ttsService.speak('Processing uploaded file for AI analysis');
        content = await _contentProcessor.extractTextFromFile(_selectedFile!);
      } else {
        content = _textController.text;
      }

      if (content.trim().isEmpty) {
        throw Exception('No content found to process');
      }

      await _performAIAnalysis(content);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      _ttsService.speak('Error during AI enhanced conversion');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showApiKeyDialog() {
    final apiKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.key, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI API Key Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To use AI Enhanced Learning, please provide your Google Gemini API key:'),
            SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Enter your API key here',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 12),
            Text(
              'Get your free API key from: https://makersuite.google.com/app/apikey',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final apiKey = apiKeyController.text.trim();
              if (apiKey.isNotEmpty) {
                _aiAnalyzer.initialize(apiKey);
                Navigator.of(context).pop();
                _convertWithAI(); // Retry conversion
                _ttsService.speak('API key saved. Starting AI enhanced conversion.');
              }
            },
            child: Text('Save & Continue'),
          ),
        ],
      ),
    );
  }
    if (_textController.text.isEmpty && _selectedFile == null) {
      _ttsService.speak('Please enter text or upload a file');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or upload a file')),
      );
      return;
    }

    if (_selectedGameType.isEmpty) {
      _ttsService.speak('Please select a game type');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game type')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      String content = '';
      
      if (_selectedFile != null) {
        _ttsService.speak('Processing uploaded file');
        content = await _contentProcessor.extractTextFromFile(_selectedFile!);
      } else {
        content = _textController.text;
      }

      if (content.trim().isEmpty) {
        throw Exception('No content found to process');
      }

      await _performContentConversion(content);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      _ttsService.speak('Error converting content');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _performContentConversion(String content) async {
    _ttsService.speak('Converting content to $_selectedGameType game');
    
    final gameContent = _contentProcessor.convertToGameContent(content, _selectedGameType);
    
    setState(() {
      _generatedContent = gameContent;
      _isProcessing = false;
    });

    _ttsService.speak('Content converted successfully! Ready to play ${gameContent.gameType}');
    
    // Show success dialog
    _showConversionSuccessDialog(gameContent);
  }

  Future<void> _performAIAnalysis(String content) async {
    _ttsService.speak('AI is analyzing your content and fetching comprehensive learning resources from the internet');
    
    try {
      // Step 1: Extract core concepts and enhance with internet resources
      final enhancedConcepts = await _aiAnalyzer.extractAndEnhanceConcepts(content);
      
      setState(() {
        _extractedConcepts = enhancedConcepts.originalConcepts;
        _enhancedConcepts = enhancedConcepts;
      });

      _ttsService.speak('Analysis complete! Found ${enhancedConcepts.originalConcepts.keyTerms.length} key terms and ${enhancedConcepts.internetResources.educationalQuestions.length} additional questions from internet resources. Enhanced games are ready for all learning styles.');

      // Step 2: Generate content for all learning styles with enhanced data
      final multiStyleContent = await _aiAnalyzer.generateMultiStyleContent(enhancedConcepts.originalConcepts);
      
      setState(() {
        _multiStyleContent = multiStyleContent;
        _isProcessing = false;
      });

      _ttsService.speak('AI has created comprehensive personalized games with internet-enhanced content for visual, auditory, kinesthetic, and reading learners. Choose your preferred learning style.');
      
      // Show enhanced AI analysis results
      _showEnhancedAIAnalysisResults(enhancedConcepts, multiStyleContent);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      _ttsService.speak('Error during AI analysis with internet enhancement');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _performBasicConversion(String content) async {
    if (_selectedGameType.isEmpty) {
      _ttsService.speak('Please select a game type');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game type')),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    _ttsService.speak('Converting content to $_selectedGameType game');
    
    final gameContent = _contentProcessor.convertToGameContent(content, _selectedGameType);
    
    setState(() {
      _generatedContent = gameContent;
      _isProcessing = false;
    });

    _ttsService.speak('Content converted successfully! Ready to play ${gameContent.gameType}');
    
    // Show success dialog
    _showConversionSuccessDialog(gameContent);
  }

  void _showEnhancedAIAnalysisResults(EnhancedConcepts enhancedConcepts, MultiStyleGameContent multiStyleContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue),
              SizedBox(width: 8),
              Text('Enhanced AI Analysis Results'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Original Document Analysis
                _buildAnalysisSection(
                  'Document Analysis',
                  Icons.description,
                  [
                    'Subject: ${enhancedConcepts.originalConcepts.subject}',
                    'Grade Level: ${enhancedConcepts.originalConcepts.gradeLevel}',
                    'Difficulty: ${enhancedConcepts.originalConcepts.difficulty}',
                    'Key Terms: ${enhancedConcepts.originalConcepts.keyTerms.length} found',
                    'Main Topics: ${enhancedConcepts.originalConcepts.mainTopics.join(', ')}',
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Internet Resources
                _buildAnalysisSection(
                  'Internet Resources Added',
                  Icons.public,
                  [
                    'Wikipedia Articles: ${enhancedConcepts.internetResources.wikipediaContent.length}',
                    'Educational Questions: ${enhancedConcepts.internetResources.educationalQuestions.length}',
                    'Practice Problems: ${enhancedConcepts.internetResources.practiceProblems.length}',
                    'Related Concepts: ${enhancedConcepts.internetResources.relatedConcepts.length}',
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Enhanced Games Available
                _buildAnalysisSection(
                  'Enhanced Games Created',
                  Icons.games,
                  [
                    'Total Enhanced Games: ${enhancedConcepts.enhancedGameContent.length}',
                    'Learning Styles: Visual, Auditory, Kinesthetic, Reading/Writing',
                    'Total Questions: ${enhancedConcepts.internetResources.educationalQuestions.length + enhancedConcepts.internetResources.practiceProblems.length}',
                    'Comprehensive Coverage: Document + Internet Resources',
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Learning Style Selection
                Text(
                  'Choose Your Learning Style:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildLearningStyleChip(LearningStyle.visual, 'Visual', Icons.visibility),
                    _buildLearningStyleChip(LearningStyle.auditory, 'Auditory', Icons.hearing),
                    _buildLearningStyleChip(LearningStyle.kinesthetic, 'Kinesthetic', Icons.touch_app),
                    _buildLearningStyleChip(LearningStyle.readWrite, 'Reading/Writing', Icons.edit),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: _selectedLearningStyle != null
                  ? () {
                      Navigator.of(context).pop();
                      _launchEnhancedGame();
                    }
                  : null,
              child: Text('Start Enhanced Game'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisSection(String title, IconData icon, List<String> items) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(left: 28, bottom: 4),
            child: Text(
              '• $item',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLearningStyleChip(LearningStyle style, String label, IconData icon) {
    final isSelected = _selectedLearningStyle == style;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLearningStyle = style;
        });
        _ttsService.speak('Selected $label learning style');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEnhancedGame() {
    if (_selectedLearningStyle == null || _enhancedConcepts == null) {
      _ttsService.speak('Please select a learning style first');
      return;
    }

    _ttsService.speak('Launching enhanced ${_selectedLearningStyle!.name} learning game with comprehensive internet resources');
    
    // Navigate to enhanced game screen with all the data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedGameScreen(
          enhancedConcepts: _enhancedConcepts!,
          selectedLearningStyle: _selectedLearningStyle!,
          multiStyleContent: _multiStyleContent!,
        ),
      ),
    );
  }
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('AI Analysis Complete!'),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearMaterials();
                },
                icon: Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Clear analysis',
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject: ${concepts.subject}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Grade Level: ${concepts.gradeLevel}'),
                      Text('Difficulty: ${concepts.difficulty}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Summary:', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(concepts.summary),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Text('${concepts.keyTerms.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Text('Key Terms', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Text('${concepts.learningObjectives.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Text('Objectives', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Choose your learning style:', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showLearningStyleSelection(multiStyleContent);
              },
              child: const Text('Choose Learning Style'),
            ),
          ],
        );
      },
    );
  }

  void _showLearningStyleSelection(MultiStyleGameContent multiStyleContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Your Learning Style'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AI has created personalized games for each learning style:'),
              const SizedBox(height: 16),
              ...LearningStyle.values.map((style) {
                final content = multiStyleContent.getContentForStyle(style);
                return Card(
                  child: ListTile(
                    leading: Icon(_getLearningStyleIcon(style), color: Colors.blue),
                    title: Text(_getLearningStyleTitle(style)),
                    subtitle: Text('${content.activities.length} activities generated'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _launchLearningStyleGame(style, multiStyleContent);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        );
      },
    );
  }

  void _showConversionSuccessDialog(GameContent gameContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conversion Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Game Type: ${gameContent.gameType}'),
              const SizedBox(height: 8),
              Text('Title: ${gameContent.title}'),
              const SizedBox(height: 8),
              Text('Description: ${gameContent.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchCustomGame(gameContent);
              },
              child: const Text('Play Now'),
            ),
          ],
        );
      },
    );
  }

  IconData _getLearningStyleIcon(LearningStyle style) {
    switch (style) {
      case LearningStyle.visual:
        return Icons.visibility;
      case LearningStyle.auditory:
        return Icons.hearing;
      case LearningStyle.kinesthetic:
        return Icons.touch_app;
      case LearningStyle.readWrite:
        return Icons.edit;
    }
  }

  String _getLearningStyleTitle(LearningStyle style) {
    switch (style) {
      case LearningStyle.visual:
        return 'Visual Learning';
      case LearningStyle.auditory:
        return 'Auditory Learning';
      case LearningStyle.kinesthetic:
        return 'Kinesthetic Learning';
      case LearningStyle.readWrite:
        return 'Reading/Writing Learning';
    }
  }

  void _launchLearningStyleGame(LearningStyle style, MultiStyleGameContent multiStyleContent) {
    final content = multiStyleContent.getContentForStyle(style);
    
    _ttsService.speak('Launching ${_getLearningStyleTitle(style)} game');
    
    // For now, navigate to appropriate game based on learning style
    // In full implementation, pass the AI-generated content to the games
    switch (style) {
      case LearningStyle.visual:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomFillDiagramScreen(
              gameContent: GameContent(
                gameType: 'Visual Learning Game',
                title: content.gameType,
                description: 'AI-generated visual learning activities',
                data: {'activities': content.activities},
              ),
            ),
          ),
        );
        break;
      case LearningStyle.auditory:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomAudioRepetitionScreen(
              gameContent: GameContent(
                gameType: 'Auditory Learning Game',
                title: content.gameType,
                description: 'AI-generated auditory learning activities',
                data: {'activities': content.activities},
              ),
            ),
          ),
        );
        break;
      case LearningStyle.kinesthetic:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomFillDiagramScreen(
              gameContent: GameContent(
                gameType: 'Kinesthetic Learning Game',
                title: content.gameType,
                description: 'AI-generated kinesthetic learning activities',
                data: {'activities': content.activities},
              ),
            ),
          ),
        );
        break;
      case LearningStyle.readWrite:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomEducationalWordleScreen(
              gameContent: GameContent(
                gameType: 'Reading/Writing Learning Game',
                title: content.gameType,
                description: 'AI-generated reading/writing activities',
                data: {'activities': content.activities},
              ),
            ),
          ),
        );
        break;
    }
  }

  void _launchCustomGame(GameContent gameContent) {
    // Navigate to the appropriate game screen with custom content
    switch (gameContent.gameType.toLowerCase()) {
      case 'educational wordle':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomEducationalWordleScreen(gameContent: gameContent),
          ),
        );
        break;
      case 'math challenge':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomMathGameScreen(gameContent: gameContent),
          ),
        );
        break;
      case 'diagram':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomFillDiagramScreen(gameContent: gameContent),
          ),
        );
        break;
      case 'audio repetition':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomAudioRepetitionScreen(gameContent: gameContent),
          ),
        );
        break;
      case 'repeat game':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomRepeatGameScreen(gameContent: gameContent),
          ),
        );
        break;
      default:
        // Default to Educational Wordle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomEducationalWordleScreen(gameContent: gameContent),
          ),
        );
    }
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
                // Header with logo and profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Container(
                        width: 75,
                        height: 75,
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
                      
                      // Notification and Profile
                      Row(
                        children: [
                          Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.notifications_outlined, size: 20),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _ttsService.speak('Profile');
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Clear Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Study Material Converter',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            if (_selectedFile != null || _textController.text.isNotEmpty || _uploadedDocuments.isNotEmpty)
                              IconButton(
                                onPressed: _showClearConfirmation,
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.orange,
                                ),
                                tooltip: 'Clear all materials',
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Materials Status
                        if (_selectedFile != null || _textController.text.isNotEmpty || _uploadedDocuments.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Materials Loaded',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (_selectedFile != null)
                                  Text('📄 File: ${_selectedFile!.path.split('/').last}'),
                                if (_textController.text.isNotEmpty)
                                  Text('📝 Text: ${_textController.text.length} characters'),
                                if (_uploadedDocuments.isNotEmpty)
                                  Text('📚 Documents: ${_uploadedDocuments.length} uploaded'),
                              ],
                            ),
                          ),
                        
                        Text(
                          'Upload Material',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Upload Section
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _uploadFile,
                              child: Container(
                                width: double.infinity,
                                height: 155,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedFile != null ? Colors.green : Colors.grey.shade300, 
                                    width: 2
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: _selectedFile != null ? Colors.green.shade50 : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                                      size: 48,
                                      color: _selectedFile != null ? Colors.green : Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _selectedFile != null 
                                        ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                                        : 'Tap to select files',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedFile != null ? Colors.green.shade700 : Colors.grey.shade700,
                                        fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Supported: TXT, PDF, DOC, DOCX, PPT, PPTX',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Remove file button
                            if (_selectedFile != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                    _ttsService.speak('File removed');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Text Input
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 97,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _textController.text.isNotEmpty ? Colors.blue.shade300 : Colors.grey.shade300
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _textController.text.isNotEmpty ? Colors.blue.shade50 : null,
                              ),
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                expands: true,
                                onChanged: (value) {
                                  setState(() {}); // Refresh UI when text changes
                                },
                                decoration: InputDecoration(
                                  hintText: 'Paste your text here',
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            
                            // Clear text button
                            if (_textController.text.isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _textController.clear();
                                    });
                                    _ttsService.speak('Text cleared');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Game Type Selection
                        Text(
                          'Choose Game Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _buildGameTypeCard('Educational Wordle', Icons.school, 'wordle'),
                            _buildGameTypeCard('Math Challenge', Icons.calculate, 'math'),
                            _buildGameTypeCard('Fill Diagram', Icons.quiz, 'diagram'),
                            _buildGameTypeCard('Audio Repetition', Icons.hearing, 'audio'),
                            _buildGameTypeCard('Repeat Game', Icons.replay, 'repeat'),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Convert Buttons
                        Column(
                          children: [
                            // Basic Convert Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _convertContent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isProcessing ? Colors.grey : Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isProcessing
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Processing...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Convert to Game',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // AI Enhanced Convert Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _convertWithAI,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isProcessing ? Colors.grey : Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.psychology, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AI Enhanced Learning',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'AI Enhanced: Analyzes your document + fetches comprehensive learning resources from internet',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Positioned TTS Button in bottom right
          const PositionedTTSButton(),
        ],
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 69,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 21,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.psychology, 'Learning'),
            _buildNavItem(2, Icons.auto_awesome, 'Converter'),
            _buildNavItem(3, Icons.settings, 'Setting'),
            _buildNavItem(4, Icons.dashboard, 'Dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeCard(String title, IconData icon, String gameType) {
    final isSelected = _selectedGameType == gameType;
    
    return GestureDetector(
      onTap: () => _selectGameType(gameType),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
  Future<void> _convertContent() async {
    if (_textController.text.isEmpty && _selectedFile == null) {
      _ttsService.speak('Please enter text or upload a file');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or upload a file')),
      );
      return;
    }

    if (_selectedGameType.isEmpty) {
      _ttsService.speak('Please select a game type');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game type')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      String content = '';
      
      if (_selectedFile != null) {
        _ttsService.speak('Processing uploaded file');
        content = await _contentProcessor.extractTextFromFile(_selectedFile!);
      } else {
        content = _textController.text;
      }

      if (content.trim().isEmpty) {
        throw Exception('No content found to process');
      }

      await _performBasicConversion(content);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      _ttsService.speak('Error converting content');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _performBasicConversion(String content) async {
    _ttsService.speak('Converting content to $_selectedGameType game');
    
    final gameContent = _contentProcessor.convertToGameContent(content, _selectedGameType);
    
    setState(() {
      _isProcessing = false;
    });

    _ttsService.speak('Content converted successfully! Ready to play ${gameContent.gameType}');
    
    // Show success dialog and navigate to game
    _showConversionSuccessDialog(gameContent);
  }

  void _showConversionSuccessDialog(GameContent gameContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Conversion Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your content has been converted to:'),
              SizedBox(height: 8),
              Text(
                gameContent.gameType,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(gameContent.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchGame(gameContent);
              },
              child: Text('Play Game'),
            ),
          ],
        );
      },
    );
  }

  void _launchGame(GameContent gameContent) {
    _ttsService.speak('Launching ${gameContent.gameType}');
    
    // Navigate to appropriate game screen based on game type
    switch (gameContent.gameType.toLowerCase()) {
      case 'educational wordle':
        Navigator.pushNamed(context, '/wordle', arguments: gameContent);
        break;
      case 'math challenge':
        Navigator.pushNamed(context, '/math', arguments: gameContent);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Game type ${gameContent.gameType} not yet implemented')),
        );
    }
  }