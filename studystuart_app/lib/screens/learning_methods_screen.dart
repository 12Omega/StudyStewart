import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/tts_service.dart';
import '../services/emotional_feedback_service.dart';
import '../services/educational_content_service.dart';
import '../widgets/tts_button.dart';

class LearningMethodsScreen extends StatefulWidget {
  const LearningMethodsScreen({super.key});

  @override
  State<LearningMethodsScreen> createState() => _LearningMethodsScreenState();
}

class _LearningMethodsScreenState extends State<LearningMethodsScreen>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  final EducationalContentService _contentService = EducationalContentService();
  late TabController _tabController;
  
  bool _isLoadingContent = false;
  Map<String, List<LearningResource>> _downloadedResources = {};
  Map<String, List<EducationalVideo>> _educationalVideos = {};
  Map<String, List<EducationalImage>> _educationalImages = {};
  Map<String, List<HomeActivity>> _homeActivities = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _speakWelcome();
    _loadInternetResources();
  }

  void _speakWelcome() {
    _ttsService.speak('Welcome to Learning Methods! Discover different ways to learn effectively and try practical activities at home.');
  }

  Future<void> _loadInternetResources() async {
    setState(() {
      _isLoadingContent = true;
    });

    try {
      // Load resources for each learning style
      final styles = ['visual', 'auditory', 'kinesthetic', 'reading'];
      
      for (final style in styles) {
        // Fetch educational videos
        final videos = await _contentService.fetchEducationalVideos(
          learningStyle: style,
          topic: 'general education',
          limit: 3,
        );
        
        // Fetch educational images (for visual style)
        final images = style == 'visual' 
          ? await _contentService.fetchEducationalImages(
              topic: 'learning methods',
              limit: 5,
            )
          : <EducationalImage>[];
        
        // Fetch home activities
        final activities = await _contentService.fetchHomeActivities(
          learningStyle: style,
          ageGroup: 'teen',
        );
        
        setState(() {
          _educationalVideos[style] = videos;
          _educationalImages[style] = images;
          _homeActivities[style] = activities;
        });
        
        // Also load the original learning resources
        await _fetchLearningResources(style);
      }
    } catch (e) {
      debugPrint('Error loading internet resources: $e');
    }

    setState(() {
      _isLoadingContent = false;
    });
  }

  Future<void> _fetchLearningResources(String learningStyle) async {
    try {
      // Simulate fetching educational content from various APIs
      final resources = await _getEducationalContent(learningStyle);
      setState(() {
        _downloadedResources[learningStyle] = resources;
      });
    } catch (e) {
      debugPrint('Error fetching $learningStyle resources: $e');
    }
  }

  Future<List<LearningResource>> _getEducationalContent(String style) async {
    // In a real implementation, you would fetch from educational APIs
    // For now, we'll create comprehensive sample content
    
    switch (style) {
      case 'visual':
        return [
          LearningResource(
            title: 'Mind Mapping Techniques',
            description: 'Learn to create visual mind maps for better understanding',
            type: ResourceType.video,
            url: 'https://example.com/mindmapping.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/4CAF50/white?text=Mind+Maps',
            homeActivity: 'Create a colorful mind map of your favorite subject using colored pens and paper',
            materials: ['Colored pens', 'Large paper', 'Ruler'],
            duration: '15 minutes',
          ),
          LearningResource(
            title: 'Visual Note-Taking Methods',
            description: 'Transform boring notes into engaging visual summaries',
            type: ResourceType.image,
            url: 'https://via.placeholder.com/400x300/2196F3/white?text=Visual+Notes',
            thumbnailUrl: 'https://via.placeholder.com/300x200/2196F3/white?text=Visual+Notes',
            homeActivity: 'Convert your class notes into visual diagrams with symbols and drawings',
            materials: ['Notebook', 'Colored pencils', 'Highlighters'],
            duration: '20 minutes',
          ),
          LearningResource(
            title: 'Infographic Creation',
            description: 'Design infographics to summarize complex information',
            type: ResourceType.video,
            url: 'https://example.com/infographics.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/FF9800/white?text=Infographics',
            homeActivity: 'Create an infographic about your daily routine or favorite hobby',
            materials: ['Computer/tablet', 'Design app', 'Images'],
            duration: '30 minutes',
          ),
        ];
      
      case 'auditory':
        return [
          LearningResource(
            title: 'Audio Recording Study Method',
            description: 'Record and listen to your own study materials',
            type: ResourceType.video,
            url: 'https://example.com/audio-study.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/E91E63/white?text=Audio+Study',
            homeActivity: 'Record yourself reading chapter summaries, then listen while walking',
            materials: ['Smartphone', 'Headphones', 'Quiet space'],
            duration: '25 minutes',
          ),
          LearningResource(
            title: 'Music and Memory Techniques',
            description: 'Use rhythm and melody to memorize information',
            type: ResourceType.video,
            url: 'https://example.com/music-memory.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/9C27B0/white?text=Music+Memory',
            homeActivity: 'Create a song or rap about your study topic using familiar tunes',
            materials: ['Music app', 'Lyrics notebook', 'Recording device'],
            duration: '20 minutes',
          ),
          LearningResource(
            title: 'Discussion and Debate Practice',
            description: 'Learn through verbal interaction and explanation',
            type: ResourceType.image,
            url: 'https://via.placeholder.com/400x300/607D8B/white?text=Discussion',
            thumbnailUrl: 'https://via.placeholder.com/300x200/607D8B/white?text=Discussion',
            homeActivity: 'Explain your study topic to family members or record yourself teaching',
            materials: ['Family/friends', 'Study materials', 'Timer'],
            duration: '15 minutes',
          ),
        ];
      
      case 'kinesthetic':
        return [
          LearningResource(
            title: 'Hands-On Science Experiments',
            description: 'Learn through physical experimentation and manipulation',
            type: ResourceType.video,
            url: 'https://example.com/experiments.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/4CAF50/white?text=Experiments',
            homeActivity: 'Conduct simple kitchen science experiments related to your studies',
            materials: ['Kitchen items', 'Safety equipment', 'Notebook'],
            duration: '45 minutes',
          ),
          LearningResource(
            title: 'Movement-Based Learning',
            description: 'Use physical movement to reinforce learning concepts',
            type: ResourceType.video,
            url: 'https://example.com/movement-learning.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/FF5722/white?text=Movement',
            homeActivity: 'Create physical gestures for each concept you need to remember',
            materials: ['Open space', 'Study cards', 'Timer'],
            duration: '20 minutes',
          ),
          LearningResource(
            title: 'Building and Construction Learning',
            description: 'Build models to understand complex concepts',
            type: ResourceType.image,
            url: 'https://via.placeholder.com/400x300/795548/white?text=Building',
            thumbnailUrl: 'https://via.placeholder.com/300x200/795548/white?text=Building',
            homeActivity: 'Build 3D models of concepts using clay, blocks, or recyclables',
            materials: ['Clay/blocks', 'Recyclable materials', 'Glue'],
            duration: '35 minutes',
          ),
        ];
      
      case 'reading':
        return [
          LearningResource(
            title: 'Advanced Note-Taking Systems',
            description: 'Master Cornell notes, outline method, and charting',
            type: ResourceType.video,
            url: 'https://example.com/note-systems.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/3F51B5/white?text=Note+Systems',
            homeActivity: 'Practice different note-taking methods with your textbooks',
            materials: ['Notebooks', 'Pens', 'Textbooks', 'Ruler'],
            duration: '30 minutes',
          ),
          LearningResource(
            title: 'Speed Reading Techniques',
            description: 'Increase reading speed while maintaining comprehension',
            type: ResourceType.video,
            url: 'https://example.com/speed-reading.mp4',
            thumbnailUrl: 'https://via.placeholder.com/300x200/009688/white?text=Speed+Reading',
            homeActivity: 'Practice speed reading exercises with newspaper articles',
            materials: ['Newspapers/articles', 'Timer', 'Comprehension questions'],
            duration: '25 minutes',
          ),
          LearningResource(
            title: 'Research and Analysis Methods',
            description: 'Develop critical thinking through research techniques',
            type: ResourceType.image,
            url: 'https://via.placeholder.com/400x300/FF9800/white?text=Research',
            thumbnailUrl: 'https://via.placeholder.com/300x200/FF9800/white?text=Research',
            homeActivity: 'Research a topic using multiple sources and create a comparison chart',
            materials: ['Internet access', 'Library books', 'Chart paper'],
            duration: '40 minutes',
          ),
        ];
      
      default:
        return [];
    }
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
        title: Text('Learning Methods'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          TTSButton(
            text: 'Learning Methods Screen. Discover different ways to learn effectively beyond repetition.',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.visibility), text: 'Visual'),
            Tab(icon: Icon(Icons.hearing), text: 'Auditory'),
            Tab(icon: Icon(Icons.touch_app), text: 'Kinesthetic'),
            Tab(icon: Icon(Icons.menu_book), text: 'Reading'),
          ],
        ),
      ),
      body: _isLoadingContent
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Loading learning resources from internet...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLearningStyleTab('visual', 'Visual Learning', Colors.green),
                _buildLearningStyleTab('auditory', 'Auditory Learning', Colors.orange),
                _buildLearningStyleTab('kinesthetic', 'Kinesthetic Learning', Colors.red),
                _buildLearningStyleTab('reading', 'Reading/Writing Learning', Colors.blue),
              ],
            ),
    );
  }

  Widget _buildLearningStyleTab(String style, String title, Color color) {
    final resources = _downloadedResources[style] ?? [];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getStyleIcon(style), color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  _getStyleDescription(style),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Learning Methods Section
          Text(
            'Learning Methods & Home Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Resources List
          if (resources.isEmpty)
            _buildLoadingCard()
          else
            ...resources.map((resource) => _buildResourceCard(resource, color)),
          
          SizedBox(height: 24),
          
          // Educational Videos Section
          if (_educationalVideos[style]?.isNotEmpty == true) ...[
            Text(
              'Educational Videos from Internet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            ...(_educationalVideos[style] ?? []).map((video) => _buildVideoCard(video, color)),
            SizedBox(height: 24),
          ],
          
          // Educational Images Section (for visual learning)
          if (style == 'visual' && _educationalImages[style]?.isNotEmpty == true) ...[
            Text(
              'Educational Images from Internet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            _buildImageGrid(_educationalImages[style]!, color),
            SizedBox(height: 24),
          ],
          
          // Home Activities Section
          if (_homeActivities[style]?.isNotEmpty == true) ...[
            Text(
              'Recommended Home Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            ...(_homeActivities[style] ?? []).map((activity) => _buildActivityCard(activity, color)),
            SizedBox(height: 24),
          ],
          
          SizedBox(height: 24),
          
          // Tips Section
          _buildTipsSection(style, color),
          
          SizedBox(height: 24),
          
          // Benefits Section
          _buildBenefitsSection(style, color),
        ],
      ),
    );
  }

  Widget _buildResourceCard(LearningResource resource, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail/Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      resource.type == ResourceType.video ? Icons.play_circle_fill : Icons.image,
                      size: 64,
                      color: color,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        resource.type == ResourceType.video ? 'VIDEO' : 'IMAGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  resource.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Home Activity Section
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, color: color, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Try at Home',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        resource.homeActivity,
                        style: TextStyle(fontSize: 14),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Materials needed
                      Row(
                        children: [
                          Icon(Icons.build, color: Colors.grey.shade600, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Materials: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              resource.materials.join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      // Duration
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Duration: ${resource.duration}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadResource(resource),
                        icon: Icon(Icons.download, size: 18),
                        label: Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareActivity(resource),
                        icon: Icon(Icons.share, size: 18),
                        label: Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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

  Widget _buildLoadingCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('Loading learning resources...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(String style, Color color) {
    final tips = _getStyleTips(style);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: color),
              SizedBox(width: 8),
              Text(
                'Pro Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(String style, Color color) {
    final benefits = _getStyleBenefits(style);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: color),
              SizedBox(width: 8),
              Text(
                'Benefits of ${_getStyleName(style)} Learning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: benefits.map((benefit) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                benefit,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getStyleIcon(String style) {
    switch (style) {
      case 'visual': return Icons.visibility;
      case 'auditory': return Icons.hearing;
      case 'kinesthetic': return Icons.touch_app;
      case 'reading': return Icons.menu_book;
      default: return Icons.school;
    }
  }

  String _getStyleDescription(String style) {
    switch (style) {
      case 'visual':
        return 'Learn through images, diagrams, colors, and spatial understanding. Visual learners process information best when they can see it represented graphically.';
      case 'auditory':
        return 'Learn through listening, speaking, and sound. Auditory learners understand information better when they hear it or discuss it aloud.';
      case 'kinesthetic':
        return 'Learn through movement, touch, and hands-on activities. Kinesthetic learners need physical interaction with materials to understand concepts.';
      case 'reading':
        return 'Learn through reading, writing, and text-based activities. Reading/writing learners prefer information presented in written form.';
      default:
        return 'Discover your unique learning style and methods.';
    }
  }

  String _getStyleName(String style) {
    switch (style) {
      case 'visual': return 'Visual';
      case 'auditory': return 'Auditory';
      case 'kinesthetic': return 'Kinesthetic';
      case 'reading': return 'Reading/Writing';
      default: return 'Learning';
    }
  }

  List<String> _getStyleTips(String style) {
    switch (style) {
      case 'visual':
        return [
          'Use different colors for different topics or categories',
          'Create flowcharts and diagrams to show relationships',
          'Use highlighters to emphasize important information',
          'Draw pictures or symbols to represent concepts',
          'Organize information in tables and charts',
        ];
      case 'auditory':
        return [
          'Read your notes aloud to reinforce learning',
          'Create rhymes or songs to remember information',
          'Discuss topics with friends or family members',
          'Listen to educational podcasts or audiobooks',
          'Record lectures and review them later',
        ];
      case 'kinesthetic':
        return [
          'Take frequent breaks to move around while studying',
          'Use manipulatives and hands-on materials',
          'Act out scenarios or role-play concepts',
          'Build models or create physical representations',
          'Study while walking or doing light exercise',
        ];
      case 'reading':
        return [
          'Take detailed written notes during lectures',
          'Rewrite information in your own words',
          'Create lists, outlines, and written summaries',
          'Use flashcards with written definitions',
          'Read multiple sources on the same topic',
        ];
      default:
        return [];
    }
  }

  List<String> _getStyleBenefits(String style) {
    switch (style) {
      case 'visual':
        return ['Better memory retention', 'Faster information processing', 'Improved organization', 'Enhanced creativity', 'Clearer understanding'];
      case 'auditory':
        return ['Improved listening skills', 'Better verbal communication', 'Enhanced memory through repetition', 'Social learning benefits', 'Musical memory aids'];
      case 'kinesthetic':
        return ['Better focus through movement', 'Practical skill development', 'Improved problem-solving', 'Physical memory reinforcement', 'Real-world application'];
      case 'reading':
        return ['Strong analytical skills', 'Detailed comprehension', 'Research proficiency', 'Writing improvement', 'Independent learning'];
      default:
        return [];
    }
  }

  Future<void> _downloadResource(LearningResource resource) async {
    _ttsService.speak('Downloading ${resource.title}');
    
    try {
      // Show download progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading ${resource.title}...'),
            ],
          ),
        ),
      );

      // Simulate download process
      await Future.delayed(Duration(seconds: 2));
      
      // In a real implementation, you would:
      // 1. Download the actual file from resource.url
      // 2. Save it to device storage
      // 3. Update local database
      
      Navigator.of(context).pop(); // Close progress dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${resource.title} downloaded successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _viewDownloadedResource(resource),
          ),
        ),
      );
      
      EmotionalFeedbackService.provideMicroFeedback(context, 'success');
      
    } catch (e) {
      Navigator.of(context).pop(); // Close progress dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewDownloadedResource(LearningResource resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resource.description),
            SizedBox(height: 16),
            Text(
              'Home Activity:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(resource.homeActivity),
            SizedBox(height: 12),
            Text(
              'Materials: ${resource.materials.join(', ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              'Duration: ${resource.duration}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
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
              _startActivity(resource);
            },
            child: Text('Start Activity'),
          ),
        ],
      ),
    );
  }

  void _startActivity(LearningResource resource) {
    _ttsService.speak('Starting activity: ${resource.title}. ${resource.homeActivity}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.green),
            SizedBox(width: 8),
            Text('Activity Started!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Timer set for ${resource.duration}'),
            SizedBox(height: 16),
            Text(
              resource.homeActivity,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Good luck with your learning activity!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _shareActivity(LearningResource resource) {
    _ttsService.speak('Sharing ${resource.title} activity');
    
    // In a real implementation, you would use the share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activity shared: ${resource.title}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Data Models
class LearningResource {
  final String title;
  final String description;
  final ResourceType type;
  final String url;
  final String thumbnailUrl;
  final String homeActivity;
  final List<String> materials;
  final String duration;

  LearningResource({
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.thumbnailUrl,
    required this.homeActivity,
    required this.materials,
    required this.duration,
  });
}

enum ResourceType { video, image, audio, document }
  Widget _buildVideoCard(EducationalVideo video, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 64,
                      color: color,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        video.source,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Video Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  video.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                
                if (video.learningObjectives.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    'Learning Objectives:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  ...video.learningObjectives.map((objective) => 
                    Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: color)),
                          Expanded(
                            child: Text(
                              objective,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadVideo(video),
                        icon: Icon(Icons.download, size: 18),
                        label: Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _watchVideo(video),
                        icon: Icon(Icons.play_arrow, size: 18),
                        label: Text('Watch'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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

  Widget _buildImageGrid(List<EducationalImage> images, Color color) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _buildImageCard(image, color);
      },
    );
  }

  Widget _buildImageCard(EducationalImage image, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Thumbnail
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: color,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          image.source,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Image Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  Expanded(
                    child: Text(
                      image.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Download Button
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () => _downloadImage(image),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
    );
  }

  Widget _buildActivityCard(HomeActivity activity, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          activity.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
            SizedBox(width: 4),
            Text(
              activity.duration,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getDifficultyColor(activity.difficulty),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                activity.difficulty,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                
                SizedBox(height: 16),
                
                // Materials Section
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build, color: color, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Materials Needed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: activity.materials.map((material) => 
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              material,
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          )
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Instructions Section
                Text(
                  'Step-by-Step Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                
                ...activity.instructions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final instruction = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            instruction,
                            style: TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                SizedBox(height: 16),
                
                // Start Activity Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startHomeActivity(activity),
                    icon: Icon(Icons.play_arrow),
                    label: Text('Start Activity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  Future<void> _downloadVideo(EducationalVideo video) async {
    _ttsService.speak('Downloading video: ${video.title}');
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading ${video.title}...'),
              SizedBox(height: 8),
              Text(
                'Duration: ${video.duration}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );

      // Use the educational content service to download
      final filePath = await _contentService.downloadVideo(video);
      
      Navigator.of(context).pop(); // Close progress dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video downloaded successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _showVideoInfo(video, filePath),
          ),
        ),
      );
      
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadImage(EducationalImage image) async {
    _ttsService.speak('Downloading image: ${image.title}');
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading ${image.title}...'),
            ],
          ),
        ),
      );

      final filePath = await _contentService.downloadImage(image);
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _watchVideo(EducationalVideo video) {
    _ttsService.speak('Opening video: ${video.title}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${video.duration}'),
            Text('Source: ${video.source}'),
            SizedBox(height: 12),
            Text(video.description),
            if (video.learningObjectives.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Learning Objectives:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...video.learningObjectives.map((obj) => Text('• $obj')),
            ],
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
              // In a real app, you would open the video player
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Would open video player for: ${video.title}')),
              );
            },
            child: Text('Watch Now'),
          ),
        ],
      ),
    );
  }

  void _showVideoInfo(EducationalVideo video, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Video Downloaded'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${video.title} has been downloaded successfully!'),
            SizedBox(height: 8),
            Text('File location: $filePath'),
            SizedBox(height: 12),
            Text('You can now watch this video offline anytime.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _startHomeActivity(HomeActivity activity) {
    _ttsService.speak('Starting home activity: ${activity.title}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.green),
            SizedBox(width: 8),
            Text('Activity Started!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              activity.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('Duration: ${activity.duration}'),
            Text('Difficulty: ${activity.difficulty}'),
            SizedBox(height: 12),
            Text('Follow the step-by-step instructions and enjoy learning!'),
            SizedBox(height: 16),
            Text(
              'Materials needed: ${activity.materials.join(', ')}',
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
              Navigator.of(context).pop();
              _ttsService.speak('Good luck with your ${activity.title} activity! Remember to follow each step carefully.');
            },
            child: Text('Start Now!'),
          ),
        ],
      ),
    );
  }