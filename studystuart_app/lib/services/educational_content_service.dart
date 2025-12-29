import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class EducationalContentService {
  static final EducationalContentService _instance = EducationalContentService._internal();
  factory EducationalContentService() => _instance;
  EducationalContentService._internal();

  // Educational video APIs and sources
  static const String _khanAcademyAPI = 'https://www.khanacademy.org/api/v1';
  static const String _youtubeEduAPI = 'https://www.googleapis.com/youtube/v3';
  static const String _coursera_API = 'https://api.coursera.org/api';
  
  // Free educational image sources
  static const String _unsplashAPI = 'https://api.unsplash.com';
  static const String _pixabayAPI = 'https://pixabay.com/api';
  
  /// Fetch educational videos based on learning style and topic
  Future<List<EducationalVideo>> fetchEducationalVideos({
    required String learningStyle,
    required String topic,
    int limit = 5,
  }) async {
    try {
      final videos = <EducationalVideo>[];
      
      // Fetch from multiple sources
      final futures = [
        _fetchKhanAcademyVideos(topic, limit ~/ 2),
        _fetchEducationalYouTubeVideos(learningStyle, topic, limit ~/ 2),
      ];
      
      final results = await Future.wait(futures);
      for (final videoList in results) {
        videos.addAll(videoList);
      }
      
      return videos.take(limit).toList();
      
    } catch (e) {
      debugPrint('Error fetching educational videos: $e');
      return _getFallbackVideos(learningStyle, topic);
    }
  }

  /// Fetch educational images for visual learning
  Future<List<EducationalImage>> fetchEducationalImages({
    required String topic,
    int limit = 10,
  }) async {
    try {
      final images = <EducationalImage>[];
      
      // Fetch from multiple image sources
      final futures = [
        _fetchUnsplashImages(topic, limit ~/ 2),
        _fetchPixabayImages(topic, limit ~/ 2),
      ];
      
      final results = await Future.wait(futures);
      for (final imageList in results) {
        images.addAll(imageList);
      }
      
      return images.take(limit).toList();
      
    } catch (e) {
      debugPrint('Error fetching educational images: $e');
      return _getFallbackImages(topic);
    }
  }

  /// Download video content for offline use
  Future<String> downloadVideo(EducationalVideo video) async {
    try {
      final response = await http.get(Uri.parse(video.downloadUrl));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final videoDir = Directory('${directory.path}/videos');
        if (!await videoDir.exists()) {
          await videoDir.create(recursive: true);
        }
        
        final fileName = '${video.id}.mp4';
        final file = File('${videoDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        return file.path;
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading video: $e');
      rethrow;
    }
  }

  /// Download image content for offline use
  Future<String> downloadImage(EducationalImage image) async {
    try {
      final response = await http.get(Uri.parse(image.url));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final imageDir = Directory('${directory.path}/images');
        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }
        
        final fileName = '${image.id}.jpg';
        final file = File('${imageDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        return file.path;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
      rethrow;
    }
  }

  /// Fetch home learning activities from educational databases
  Future<List<HomeActivity>> fetchHomeActivities({
    required String learningStyle,
    required String ageGroup,
  }) async {
    try {
      // In a real implementation, this would fetch from educational APIs
      return _generateHomeActivities(learningStyle, ageGroup);
    } catch (e) {
      debugPrint('Error fetching home activities: $e');
      return _getFallbackActivities(learningStyle);
    }
  }

  // Private methods for API calls

  Future<List<EducationalVideo>> _fetchKhanAcademyVideos(String topic, int limit) async {
    try {
      // Khan Academy API call (requires API key in real implementation)
      final url = '$_khanAcademyAPI/topic/$topic/videos';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['videos'] as List).take(limit).map((video) => 
          EducationalVideo(
            id: video['id'],
            title: video['title'],
            description: video['description'],
            thumbnailUrl: video['thumbnail_url'],
            downloadUrl: video['download_url'],
            duration: video['duration'],
            source: 'Khan Academy',
            learningObjectives: List<String>.from(video['learning_objectives'] ?? []),
          )
        ).toList();
      }
    } catch (e) {
      debugPrint('Khan Academy API error: $e');
    }
    
    return [];
  }

  Future<List<EducationalVideo>> _fetchEducationalYouTubeVideos(String style, String topic, int limit) async {
    try {
      // YouTube Education API call (requires API key)
      final query = '$style learning $topic education';
      final url = '$_youtubeEduAPI/search?part=snippet&q=$query&type=video&maxResults=$limit';
      
      // This would require a YouTube API key in real implementation
      // For now, return sample data
      return _getSampleYouTubeVideos(style, topic, limit);
      
    } catch (e) {
      debugPrint('YouTube API error: $e');
      return [];
    }
  }

  Future<List<EducationalImage>> _fetchUnsplashImages(String topic, int limit) async {
    try {
      // Unsplash API call (requires API key)
      final query = '$topic education learning';
      final url = '$_unsplashAPI/search/photos?query=$query&per_page=$limit';
      
      // This would require an Unsplash API key in real implementation
      return _getSampleUnsplashImages(topic, limit);
      
    } catch (e) {
      debugPrint('Unsplash API error: $e');
      return [];
    }
  }

  Future<List<EducationalImage>> _fetchPixabayImages(String topic, int limit) async {
    try {
      // Pixabay API call (requires API key)
      final query = '$topic+education+learning';
      final url = '$_pixabayAPI/?key=YOUR_API_KEY&q=$query&per_page=$limit';
      
      // This would require a Pixabay API key in real implementation
      return _getSamplePixabayImages(topic, limit);
      
    } catch (e) {
      debugPrint('Pixabay API error: $e');
      return [];
    }
  }

  // Fallback and sample data methods

  List<EducationalVideo> _getFallbackVideos(String style, String topic) {
    return [
      EducationalVideo(
        id: 'fallback_1',
        title: '$style Learning: $topic Fundamentals',
        description: 'Comprehensive introduction to $topic using $style learning methods',
        thumbnailUrl: 'https://via.placeholder.com/320x180/4CAF50/white?text=$style+Learning',
        downloadUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        duration: '15:30',
        source: 'Educational Library',
        learningObjectives: [
          'Understand basic concepts of $topic',
          'Apply $style learning techniques',
          'Practice with real-world examples',
        ],
      ),
      EducationalVideo(
        id: 'fallback_2',
        title: 'Advanced $topic Techniques',
        description: 'Deep dive into advanced $topic concepts for $style learners',
        thumbnailUrl: 'https://via.placeholder.com/320x180/2196F3/white?text=Advanced+$topic',
        downloadUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        duration: '22:45',
        source: 'Educational Library',
        learningObjectives: [
          'Master advanced $topic techniques',
          'Solve complex problems',
          'Create original solutions',
        ],
      ),
    ];
  }

  List<EducationalImage> _getFallbackImages(String topic) {
    return [
      EducationalImage(
        id: 'img_1',
        title: '$topic Concept Map',
        description: 'Visual representation of key $topic concepts',
        url: 'https://via.placeholder.com/800x600/4CAF50/white?text=$topic+Concepts',
        thumbnailUrl: 'https://via.placeholder.com/300x200/4CAF50/white?text=$topic+Concepts',
        source: 'Educational Graphics',
        tags: [topic, 'concept map', 'visual learning'],
      ),
      EducationalImage(
        id: 'img_2',
        title: '$topic Process Diagram',
        description: 'Step-by-step visual guide to $topic processes',
        url: 'https://via.placeholder.com/800x600/2196F3/white?text=$topic+Process',
        thumbnailUrl: 'https://via.placeholder.com/300x200/2196F3/white?text=$topic+Process',
        source: 'Educational Graphics',
        tags: [topic, 'process', 'diagram', 'steps'],
      ),
    ];
  }

  List<EducationalVideo> _getSampleYouTubeVideos(String style, String topic, int limit) {
    return List.generate(limit, (index) => 
      EducationalVideo(
        id: 'yt_${index + 1}',
        title: '$style Learning: $topic Part ${index + 1}',
        description: 'Educational video covering $topic using $style learning methods',
        thumbnailUrl: 'https://via.placeholder.com/320x180/FF5722/white?text=Video+${index + 1}',
        downloadUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_${index + 1}.mp4',
        duration: '${10 + index * 2}:${(index * 15) % 60}',
        source: 'YouTube Education',
        learningObjectives: [
          'Learn $topic concept ${index + 1}',
          'Practice $style learning techniques',
          'Apply knowledge in exercises',
        ],
      )
    );
  }

  List<EducationalImage> _getSampleUnsplashImages(String topic, int limit) {
    return List.generate(limit, (index) => 
      EducationalImage(
        id: 'unsplash_${index + 1}',
        title: '$topic Image ${index + 1}',
        description: 'High-quality educational image related to $topic',
        url: 'https://via.placeholder.com/800x600/9C27B0/white?text=$topic+${index + 1}',
        thumbnailUrl: 'https://via.placeholder.com/300x200/9C27B0/white?text=$topic+${index + 1}',
        source: 'Unsplash',
        tags: [topic, 'education', 'learning', 'visual'],
      )
    );
  }

  List<EducationalImage> _getSamplePixabayImages(String topic, int limit) {
    return List.generate(limit, (index) => 
      EducationalImage(
        id: 'pixabay_${index + 1}',
        title: '$topic Illustration ${index + 1}',
        description: 'Educational illustration for $topic learning',
        url: 'https://via.placeholder.com/800x600/607D8B/white?text=Illustration+${index + 1}',
        thumbnailUrl: 'https://via.placeholder.com/300x200/607D8B/white?text=Illustration+${index + 1}',
        source: 'Pixabay',
        tags: [topic, 'illustration', 'education', 'free'],
      )
    );
  }

  List<HomeActivity> _generateHomeActivities(String style, String ageGroup) {
    final activities = <HomeActivity>[];
    
    switch (style.toLowerCase()) {
      case 'visual':
        activities.addAll([
          HomeActivity(
            id: 'visual_1',
            title: 'Create a Learning Poster',
            description: 'Design a colorful poster summarizing your study topic',
            materials: ['Poster board', 'Colored markers', 'Magazines', 'Glue'],
            duration: '30 minutes',
            difficulty: 'Easy',
            ageGroup: ageGroup,
            instructions: [
              'Choose your main topic',
              'Gather colorful materials',
              'Create a visual layout',
              'Add images and diagrams',
              'Present to family',
            ],
          ),
          HomeActivity(
            id: 'visual_2',
            title: 'Mind Map Creation',
            description: 'Build a comprehensive mind map of your subject',
            materials: ['Large paper', 'Colored pens', 'Ruler'],
            duration: '25 minutes',
            difficulty: 'Medium',
            ageGroup: ageGroup,
            instructions: [
              'Write main topic in center',
              'Add main branches',
              'Use different colors for categories',
              'Add sub-branches with details',
              'Review and memorize',
            ],
          ),
        ]);
        break;
        
      case 'auditory':
        activities.addAll([
          HomeActivity(
            id: 'auditory_1',
            title: 'Record Study Sessions',
            description: 'Create audio recordings of your study materials',
            materials: ['Smartphone', 'Headphones', 'Study notes'],
            duration: '20 minutes',
            difficulty: 'Easy',
            ageGroup: ageGroup,
            instructions: [
              'Prepare your study notes',
              'Record yourself reading aloud',
              'Add explanations and examples',
              'Listen back while walking',
              'Quiz yourself verbally',
            ],
          ),
          HomeActivity(
            id: 'auditory_2',
            title: 'Create Learning Songs',
            description: 'Turn study material into memorable songs or raps',
            materials: ['Music app', 'Lyrics notebook', 'Recording device'],
            duration: '35 minutes',
            difficulty: 'Medium',
            ageGroup: ageGroup,
            instructions: [
              'Choose a familiar tune',
              'Write lyrics with key facts',
              'Practice singing/rapping',
              'Record your performance',
              'Share with friends',
            ],
          ),
        ]);
        break;
        
      case 'kinesthetic':
        activities.addAll([
          HomeActivity(
            id: 'kinesthetic_1',
            title: 'Build Learning Models',
            description: 'Create 3D models to understand concepts',
            materials: ['Clay', 'Building blocks', 'Recyclables'],
            duration: '45 minutes',
            difficulty: 'Medium',
            ageGroup: ageGroup,
            instructions: [
              'Identify key concepts to model',
              'Gather building materials',
              'Construct physical representations',
              'Explain model to others',
              'Test and modify design',
            ],
          ),
          HomeActivity(
            id: 'kinesthetic_2',
            title: 'Movement Learning Games',
            description: 'Use physical movement to memorize information',
            materials: ['Open space', 'Study cards', 'Timer'],
            duration: '20 minutes',
            difficulty: 'Easy',
            ageGroup: ageGroup,
            instructions: [
              'Create gesture for each concept',
              'Practice movements repeatedly',
              'Combine gestures into sequences',
              'Test memory with movements',
              'Teach gestures to others',
            ],
          ),
        ]);
        break;
        
      case 'reading':
        activities.addAll([
          HomeActivity(
            id: 'reading_1',
            title: 'Create Study Guides',
            description: 'Write comprehensive study guides and summaries',
            materials: ['Notebooks', 'Pens', 'Highlighters', 'Textbooks'],
            duration: '40 minutes',
            difficulty: 'Medium',
            ageGroup: ageGroup,
            instructions: [
              'Read source materials carefully',
              'Take detailed notes',
              'Organize information logically',
              'Create summary sections',
              'Review and revise content',
            ],
          ),
          HomeActivity(
            id: 'reading_2',
            title: 'Research Projects',
            description: 'Conduct in-depth research on topics of interest',
            materials: ['Internet access', 'Library books', 'Research template'],
            duration: '60 minutes',
            difficulty: 'Hard',
            ageGroup: ageGroup,
            instructions: [
              'Choose research question',
              'Find multiple sources',
              'Take organized notes',
              'Compare different viewpoints',
              'Write conclusion summary',
            ],
          ),
        ]);
        break;
    }
    
    return activities;
  }

  List<HomeActivity> _getFallbackActivities(String style) {
    return [
      HomeActivity(
        id: 'fallback_1',
        title: 'Basic $style Activity',
        description: 'Simple activity to practice $style learning',
        materials: ['Basic supplies'],
        duration: '15 minutes',
        difficulty: 'Easy',
        ageGroup: 'All ages',
        instructions: ['Follow basic steps', 'Practice regularly', 'Share results'],
      ),
    ];
  }
}

// Data Models

class EducationalVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String downloadUrl;
  final String duration;
  final String source;
  final List<String> learningObjectives;

  EducationalVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.downloadUrl,
    required this.duration,
    required this.source,
    required this.learningObjectives,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'downloadUrl': downloadUrl,
      'duration': duration,
      'source': source,
      'learningObjectives': learningObjectives,
    };
  }

  factory EducationalVideo.fromJson(Map<String, dynamic> json) {
    return EducationalVideo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      downloadUrl: json['downloadUrl'],
      duration: json['duration'],
      source: json['source'],
      learningObjectives: List<String>.from(json['learningObjectives']),
    );
  }
}

class EducationalImage {
  final String id;
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;
  final String source;
  final List<String> tags;

  EducationalImage({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.source,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'source': source,
      'tags': tags,
    };
  }

  factory EducationalImage.fromJson(Map<String, dynamic> json) {
    return EducationalImage(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      source: json['source'],
      tags: List<String>.from(json['tags']),
    );
  }
}

class HomeActivity {
  final String id;
  final String title;
  final String description;
  final List<String> materials;
  final String duration;
  final String difficulty;
  final String ageGroup;
  final List<String> instructions;

  HomeActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.materials,
    required this.duration,
    required this.difficulty,
    required this.ageGroup,
    required this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'materials': materials,
      'duration': duration,
      'difficulty': difficulty,
      'ageGroup': ageGroup,
      'instructions': instructions,
    };
  }

  factory HomeActivity.fromJson(Map<String, dynamic> json) {
    return HomeActivity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      materials: List<String>.from(json['materials']),
      duration: json['duration'],
      difficulty: json['difficulty'],
      ageGroup: json['ageGroup'],
      instructions: List<String>.from(json['instructions']),
    );
  }
}