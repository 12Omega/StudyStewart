import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIContentAnalyzer {
  static final AIContentAnalyzer _instance = AIContentAnalyzer._internal();
  factory AIContentAnalyzer() => _instance;
  AIContentAnalyzer._internal();

  GenerativeModel? _model;
  String? _apiKey;

  // Initialize with API key
  void initialize(String apiKey) {
    _apiKey = apiKey;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  bool get isInitialized => _model != null && _apiKey != null;

  // Extract core concepts from any educational material and enhance with internet resources
  Future<EnhancedConcepts> extractAndEnhanceConcepts(String content) async {
    if (!isInitialized) {
      throw Exception('AI service not initialized. Please provide API key.');
    }

    try {
      // Step 1: Extract core concepts from uploaded document
      final coreConcepts = await extractCoreConcepts(content);
      
      // Step 2: Fetch additional educational resources from internet
      final internetResources = await _fetchInternetResources(coreConcepts);
      
      // Step 3: Generate enhanced game content with internet data
      final enhancedGameContent = await _generateEnhancedGameContent(coreConcepts, internetResources);
      
      return EnhancedConcepts(
        originalConcepts: coreConcepts,
        internetResources: internetResources,
        enhancedGameContent: enhancedGameContent,
      );
      
    } catch (e) {
      debugPrint('Error extracting and enhancing concepts: $e');
      // Fallback to original concepts if internet enhancement fails
      final coreConcepts = await extractCoreConcepts(content);
      return EnhancedConcepts(
        originalConcepts: coreConcepts,
        internetResources: InternetResources.empty(),
        enhancedGameContent: [],
      );
    }
  }

  // Fetch educational resources from internet based on main concepts
  Future<InternetResources> _fetchInternetResources(CoreConcepts concepts) async {
    try {
      final List<Future<dynamic>> futures = [
        _fetchWikipediaContent(concepts.subject, concepts.mainTopics),
        _fetchEducationalQuestions(concepts.subject, concepts.keyTerms),
        _fetchPracticeProblems(concepts.subject, concepts.difficulty),
        _fetchRelatedConcepts(concepts.subject, concepts.concepts),
      ];

      final results = await Future.wait(futures);
      
      return InternetResources(
        wikipediaContent: results[0] as List<WikipediaArticle>,
        educationalQuestions: results[1] as List<Question>,
        practiceProblems: results[2] as List<Problem>,
        relatedConcepts: results[3] as List<String>,
      );
      
    } catch (e) {
      debugPrint('Error fetching internet resources: $e');
      return InternetResources.empty();
    }
  }

  // Fetch Wikipedia content for additional context
  Future<List<WikipediaArticle>> _fetchWikipediaContent(String subject, List<String> topics) async {
    final articles = <WikipediaArticle>[];
    
    try {
      for (final topic in topics.take(3)) { // Limit to 3 topics
        final searchQuery = Uri.encodeComponent('$subject $topic');
        final searchUrl = 'https://en.wikipedia.org/api/rest_v1/page/summary/$searchQuery';
        
        final response = await http.get(Uri.parse(searchUrl));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          articles.add(WikipediaArticle(
            title: data['title'] ?? topic,
            summary: data['extract'] ?? 'No summary available',
            url: data['content_urls']?['desktop']?['page'] ?? '',
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching Wikipedia content: $e');
    }
    
    return articles;
  }

  // Generate educational questions using AI with internet context
  Future<List<Question>> _fetchEducationalQuestions(String subject, List<String> keyTerms) async {
    try {
      final prompt = '''
Generate 15 comprehensive educational questions for the subject: $subject
Key terms to focus on: ${keyTerms.join(', ')}

Create questions of varying difficulty levels (Easy, Medium, Hard) that test:
1. Basic understanding and definitions
2. Application of concepts
3. Analysis and critical thinking
4. Real-world applications
5. Problem-solving skills

Format as JSON array:
[
  {
    "question": "Question text",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswer": 0,
    "difficulty": "Easy/Medium/Hard",
    "explanation": "Detailed explanation of the answer",
    "category": "Understanding/Application/Analysis"
  }
]

Provide only the JSON array.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        String cleanedResponse = responseText.trim();
        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        }
        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        }

        final List<dynamic> questionsJson = json.decode(cleanedResponse);
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      }
    } catch (e) {
      debugPrint('Error generating educational questions: $e');
    }
    
    return [];
  }

  // Generate practice problems using AI
  Future<List<Problem>> _fetchPracticeProblems(String subject, String difficulty) async {
    try {
      final prompt = '''
Generate 12 practice problems for the subject: $subject
Difficulty level: $difficulty

Create diverse problem types:
1. Multiple choice problems
2. Fill-in-the-blank exercises
3. Short answer questions
4. Practical application scenarios
5. Step-by-step problem solving

Format as JSON array:
[
  {
    "problem": "Problem statement or question",
    "type": "multiple_choice/fill_blank/short_answer/scenario/step_by_step",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"], // for multiple choice only
    "correctAnswer": "Correct answer or solution",
    "hints": ["Hint 1", "Hint 2", "Hint 3"],
    "solution": "Detailed step-by-step solution",
    "difficulty": "Easy/Medium/Hard",
    "points": 10
  }
]

Provide only the JSON array.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        String cleanedResponse = responseText.trim();
        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        }
        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        }

        final List<dynamic> problemsJson = json.decode(cleanedResponse);
        return problemsJson.map((p) => Problem.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Error generating practice problems: $e');
    }
    
    return [];
  }

  // Fetch related concepts using AI knowledge
  Future<List<String>> _fetchRelatedConcepts(String subject, List<String> concepts) async {
    try {
      final prompt = '''
Based on the subject "$subject" and these core concepts: ${concepts.join(', ')}

Generate a list of 20 related concepts, topics, and skills that students should understand to have comprehensive knowledge in this area.

Include:
1. Prerequisite concepts
2. Advanced topics
3. Real-world applications
4. Cross-disciplinary connections
5. Current trends and developments

Format as a simple JSON array of strings:
["Concept 1", "Concept 2", "Concept 3", ...]

Provide only the JSON array.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        String cleanedResponse = responseText.trim();
        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        }
        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        }

        final List<dynamic> conceptsJson = json.decode(cleanedResponse);
        return conceptsJson.cast<String>();
      }
    } catch (e) {
      debugPrint('Error fetching related concepts: $e');
    }
    
    return [];
  }

  // Generate enhanced game content combining document concepts with internet resources
  Future<List<EnhancedGameContent>> _generateEnhancedGameContent(
    CoreConcepts concepts, 
    InternetResources resources
  ) async {
    try {
      final gameTypes = ['wordle', 'math', 'quiz', 'memory', 'puzzle'];
      final enhancedGames = <EnhancedGameContent>[];

      for (final gameType in gameTypes) {
        final prompt = '''
Create an enhanced $gameType game that combines:

Original Document Concepts:
- Subject: ${concepts.subject}
- Key Terms: ${concepts.keyTerms.join(', ')}
- Main Topics: ${concepts.mainTopics.join(', ')}

Additional Internet Resources:
- Wikipedia Articles: ${resources.wikipediaContent.map((a) => a.title).join(', ')}
- Related Concepts: ${resources.relatedConcepts.take(10).join(', ')}

Generate comprehensive game content in JSON format:
{
  "gameType": "$gameType",
  "title": "Game title",
  "description": "Game description",
  "levels": [
    {
      "level": 1,
      "title": "Level title",
      "content": {
        // Game-specific content structure
      },
      "challenges": ["Challenge 1", "Challenge 2"],
      "rewards": ["Reward 1", "Reward 2"]
    }
  ],
  "totalQuestions": 20,
  "difficulty": "Progressive",
  "learningObjectives": ["Objective 1", "Objective 2"]
}

Provide only the JSON response.
''';

        final response = await _model!.generateContent([Content.text(prompt)]);
        final responseText = response.text;

        if (responseText != null && responseText.isNotEmpty) {
          String cleanedResponse = responseText.trim();
          if (cleanedResponse.startsWith('```json')) {
            cleanedResponse = cleanedResponse.substring(7);
          }
          if (cleanedResponse.endsWith('```')) {
            cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
          }

          final gameJson = json.decode(cleanedResponse);
          enhancedGames.add(EnhancedGameContent.fromJson(gameJson));
        }
      }

      return enhancedGames;
    } catch (e) {
      debugPrint('Error generating enhanced game content: $e');
      return [];
    }
  }
    if (!isInitialized) {
      throw Exception('AI service not initialized. Please provide API key.');
    }

    try {
      final prompt = '''
Analyze the following educational content and extract core concepts for learning games.
Please provide a comprehensive analysis in JSON format with the following structure:

{
  "subject": "Primary subject area (e.g., Mathematics, Science, History, Language Arts, etc.)",
  "gradeLevel": "Estimated grade level (Elementary, Middle School, High School, College)",
  "mainTopics": ["List of 3-5 main topics covered"],
  "keyTerms": ["List of 10-15 important terms/vocabulary words"],
  "concepts": ["List of 5-8 core concepts to understand"],
  "facts": ["List of 8-12 important facts or information"],
  "questions": ["List of 10-15 potential quiz questions"],
  "learningObjectives": ["List of 3-5 learning objectives"],
  "difficulty": "Easy/Medium/Hard",
  "visualElements": ["List of concepts that work well visually"],
  "auditoryElements": ["List of concepts that work well with audio"],
  "kineticElements": ["List of concepts that work well with hands-on activities"],
  "readWriteElements": ["List of concepts that work well with text-based activities"],
  "summary": "Brief 2-3 sentence summary of the content"
}

Content to analyze:
$content

Provide only the JSON response, no additional text.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI service');
      }

      // Clean the response to extract JSON
      String cleanedResponse = responseText.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }

      final jsonData = json.decode(cleanedResponse);
      return CoreConcepts.fromJson(jsonData);

    } catch (e) {
      debugPrint('Error extracting core concepts: $e');
      // Return fallback analysis if AI fails
      return _generateFallbackAnalysis(content);
    }
  }

  // Generate learning style specific content
  Future<LearningStyleContent> generateLearningStyleContent(
    CoreConcepts concepts,
    LearningStyle style,
  ) async {
    if (!isInitialized) {
      throw Exception('AI service not initialized. Please provide API key.');
    }

    try {
      String prompt = _buildLearningStylePrompt(concepts, style);
      
      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI service');
      }

      // Clean and parse JSON response
      String cleanedResponse = responseText.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }

      final jsonData = json.decode(cleanedResponse);
      return LearningStyleContent.fromJson(jsonData, style);

    } catch (e) {
      debugPrint('Error generating learning style content: $e');
      return _generateFallbackLearningContent(concepts, style);
    }
  }

  String _buildLearningStylePrompt(CoreConcepts concepts, LearningStyle style) {
    switch (style) {
      case LearningStyle.visual:
        return '''
Based on these core concepts, create visual learning game content:
Subject: ${concepts.subject}
Main Topics: ${concepts.mainTopics.join(', ')}
Key Terms: ${concepts.keyTerms.join(', ')}
Concepts: ${concepts.concepts.join(', ')}

Generate content optimized for VISUAL learners in JSON format:
{
  "gameType": "Visual Learning Game",
  "activities": [
    {
      "type": "Image Matching",
      "title": "Match Concepts to Images",
      "items": ["List of 8-10 concept-image pairs"],
      "instructions": "Clear instructions for the activity"
    },
    {
      "type": "Diagram Labeling",
      "title": "Label the Diagram",
      "items": ["List of 6-8 diagram elements to label"],
      "instructions": "Instructions for diagram labeling"
    },
    {
      "type": "Color Coding",
      "title": "Color Code Categories",
      "items": ["List of 8-10 items to categorize by color"],
      "instructions": "Instructions for color coding activity"
    }
  ],
  "visualElements": ["List of visual representations needed"],
  "colorSchemes": ["Suggested color schemes for categories"],
  "layoutSuggestions": ["Layout ideas for visual presentation"]
}

Provide only the JSON response.
''';

      case LearningStyle.auditory:
        return '''
Based on these core concepts, create auditory learning game content:
Subject: ${concepts.subject}
Main Topics: ${concepts.mainTopics.join(', ')}
Key Terms: ${concepts.keyTerms.join(', ')}
Concepts: ${concepts.concepts.join(', ')}

Generate content optimized for AUDITORY learners in JSON format:
{
  "gameType": "Auditory Learning Game",
  "activities": [
    {
      "type": "Audio Sequences",
      "title": "Listen and Repeat Patterns",
      "items": ["List of 8-10 audio sequence patterns"],
      "instructions": "Instructions for audio sequence game"
    },
    {
      "type": "Pronunciation Practice",
      "title": "Say It Right",
      "items": ["List of 10-12 terms to practice pronouncing"],
      "instructions": "Instructions for pronunciation practice"
    },
    {
      "type": "Audio Quiz",
      "title": "Listen and Answer",
      "items": ["List of 8-10 audio-based questions"],
      "instructions": "Instructions for audio quiz"
    }
  ],
  "audioElements": ["List of sounds, music, or audio cues needed"],
  "speechPatterns": ["Patterns for text-to-speech emphasis"],
  "rhythmSuggestions": ["Rhythm patterns for memorization"]
}

Provide only the JSON response.
''';

      case LearningStyle.kinesthetic:
        return '''
Based on these core concepts, create kinesthetic learning game content:
Subject: ${concepts.subject}
Main Topics: ${concepts.mainTopics.join(', ')}
Key Terms: ${concepts.keyTerms.join(', ')}
Concepts: ${concepts.concepts.join(', ')}

Generate content optimized for KINESTHETIC learners in JSON format:
{
  "gameType": "Kinesthetic Learning Game",
  "activities": [
    {
      "type": "Touch and Move",
      "title": "Interactive Target Practice",
      "items": ["List of 8-10 interactive targets with concepts"],
      "instructions": "Instructions for touch-based interaction"
    },
    {
      "type": "Gesture Learning",
      "title": "Learn Through Movement",
      "items": ["List of 6-8 gestures paired with concepts"],
      "instructions": "Instructions for gesture-based learning"
    },
    {
      "type": "Building Blocks",
      "title": "Construct Knowledge",
      "items": ["List of 8-10 building elements to arrange"],
      "instructions": "Instructions for construction activity"
    }
  ],
  "interactionTypes": ["Types of touch interactions needed"],
  "movementPatterns": ["Movement patterns for learning"],
  "tactileFeedback": ["Haptic feedback suggestions"]
}

Provide only the JSON response.
''';

      case LearningStyle.readWrite:
        return '''
Based on these core concepts, create reading/writing learning game content:
Subject: ${concepts.subject}
Main Topics: ${concepts.mainTopics.join(', ')}
Key Terms: ${concepts.keyTerms.join(', ')}
Concepts: ${concepts.concepts.join(', ')}

Generate content optimized for READING/WRITING learners in JSON format:
{
  "gameType": "Reading/Writing Learning Game",
  "activities": [
    {
      "type": "Word Puzzles",
      "title": "Educational Wordle",
      "items": ["List of 15-20 key terms for word games"],
      "instructions": "Instructions for word puzzle games"
    },
    {
      "type": "Fill in the Blanks",
      "title": "Complete the Sentences",
      "items": ["List of 10-12 sentences with blanks to fill"],
      "instructions": "Instructions for fill-in-the-blank activity"
    },
    {
      "type": "Text Analysis",
      "title": "Analyze and Categorize",
      "items": ["List of 8-10 text passages to analyze"],
      "instructions": "Instructions for text analysis activity"
    }
  ],
  "textElements": ["Text-based learning materials"],
  "writingPrompts": ["Writing prompts related to concepts"],
  "readingMaterials": ["Suggested reading materials"]
}

Provide only the JSON response.
''';
    }
  }

  // Generate comprehensive multi-style game content
  Future<MultiStyleGameContent> generateMultiStyleContent(CoreConcepts concepts) async {
    if (!isInitialized) {
      throw Exception('AI service not initialized. Please provide API key.');
    }

    try {
      // Generate content for all learning styles
      final visualContent = await generateLearningStyleContent(concepts, LearningStyle.visual);
      final auditoryContent = await generateLearningStyleContent(concepts, LearningStyle.auditory);
      final kineticContent = await generateLearningStyleContent(concepts, LearningStyle.kinesthetic);
      final readWriteContent = await generateLearningStyleContent(concepts, LearningStyle.readWrite);

      return MultiStyleGameContent(
        concepts: concepts,
        visualContent: visualContent,
        auditoryContent: auditoryContent,
        kineticContent: kineticContent,
        readWriteContent: readWriteContent,
      );

    } catch (e) {
      debugPrint('Error generating multi-style content: $e');
      rethrow;
    }
  }

  // Fallback analysis when AI is not available
  CoreConcepts _generateFallbackAnalysis(String content) {
    // Basic text analysis as fallback
    final words = content.toLowerCase().split(RegExp(r'\W+'));
    final sentences = content.split(RegExp(r'[.!?]+'));
    
    return CoreConcepts(
      subject: 'General Education',
      gradeLevel: 'Mixed Level',
      mainTopics: ['Learning', 'Education', 'Knowledge'],
      keyTerms: words.where((w) => w.length > 4).take(10).toList(),
      concepts: ['Understanding', 'Application', 'Analysis'],
      facts: sentences.where((s) => s.trim().isNotEmpty).take(8).toList(),
      questions: ['What is the main idea?', 'How does this apply?'],
      learningObjectives: ['Understand key concepts', 'Apply knowledge'],
      difficulty: 'Medium',
      visualElements: ['Diagrams', 'Charts', 'Images'],
      auditoryElements: ['Pronunciation', 'Audio explanations'],
      kineticElements: ['Interactive exercises', 'Hands-on activities'],
      readWriteElements: ['Text analysis', 'Written exercises'],
      summary: 'Educational content for learning and understanding.',
    );
  }

  LearningStyleContent _generateFallbackLearningContent(CoreConcepts concepts, LearningStyle style) {
    // Generate basic fallback content
    final activities = <Map<String, dynamic>>[];
    
    switch (style) {
      case LearningStyle.visual:
        activities.addAll([
          {
            'type': 'Image Matching',
            'title': 'Match Concepts',
            'items': concepts.keyTerms.take(8).toList(),
            'instructions': 'Match terms to their visual representations'
          }
        ]);
        break;
      case LearningStyle.auditory:
        activities.addAll([
          {
            'type': 'Audio Quiz',
            'title': 'Listen and Learn',
            'items': concepts.keyTerms.take(8).toList(),
            'instructions': 'Listen to terms and answer questions'
          }
        ]);
        break;
      case LearningStyle.kinesthetic:
        activities.addAll([
          {
            'type': 'Touch Practice',
            'title': 'Interactive Learning',
            'items': concepts.keyTerms.take(8).toList(),
            'instructions': 'Touch and interact with learning elements'
          }
        ]);
        break;
      case LearningStyle.readWrite:
        activities.addAll([
          {
            'type': 'Word Games',
            'title': 'Text-based Learning',
            'items': concepts.keyTerms.take(8).toList(),
            'instructions': 'Complete word-based learning activities'
          }
        ]);
        break;
    }

    return LearningStyleContent(
      gameType: '${style.name} Learning Game',
      activities: activities,
      style: style,
    );
  }
}

// Data classes for AI analysis results
class CoreConcepts {
  final String subject;
  final String gradeLevel;
  final List<String> mainTopics;
  final List<String> keyTerms;
  final List<String> concepts;
  final List<String> facts;
  final List<String> questions;
  final List<String> learningObjectives;
  final String difficulty;
  final List<String> visualElements;
  final List<String> auditoryElements;
  final List<String> kineticElements;
  final List<String> readWriteElements;
  final String summary;

  CoreConcepts({
    required this.subject,
    required this.gradeLevel,
    required this.mainTopics,
    required this.keyTerms,
    required this.concepts,
    required this.facts,
    required this.questions,
    required this.learningObjectives,
    required this.difficulty,
    required this.visualElements,
    required this.auditoryElements,
    required this.kineticElements,
    required this.readWriteElements,
    required this.summary,
  });

  factory CoreConcepts.fromJson(Map<String, dynamic> json) {
    return CoreConcepts(
      subject: json['subject'] ?? 'General Education',
      gradeLevel: json['gradeLevel'] ?? 'Mixed Level',
      mainTopics: List<String>.from(json['mainTopics'] ?? []),
      keyTerms: List<String>.from(json['keyTerms'] ?? []),
      concepts: List<String>.from(json['concepts'] ?? []),
      facts: List<String>.from(json['facts'] ?? []),
      questions: List<String>.from(json['questions'] ?? []),
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
      difficulty: json['difficulty'] ?? 'Medium',
      visualElements: List<String>.from(json['visualElements'] ?? []),
      auditoryElements: List<String>.from(json['auditoryElements'] ?? []),
      kineticElements: List<String>.from(json['kineticElements'] ?? []),
      readWriteElements: List<String>.from(json['readWriteElements'] ?? []),
      summary: json['summary'] ?? 'Educational content for learning.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'gradeLevel': gradeLevel,
      'mainTopics': mainTopics,
      'keyTerms': keyTerms,
      'concepts': concepts,
      'facts': facts,
      'questions': questions,
      'learningObjectives': learningObjectives,
      'difficulty': difficulty,
      'visualElements': visualElements,
      'auditoryElements': auditoryElements,
      'kineticElements': kineticElements,
      'readWriteElements': readWriteElements,
      'summary': summary,
    };
  }
}

enum LearningStyle { visual, auditory, kinesthetic, readWrite }

class LearningStyleContent {
  final String gameType;
  final List<Map<String, dynamic>> activities;
  final LearningStyle style;

  LearningStyleContent({
    required this.gameType,
    required this.activities,
    required this.style,
  });

  factory LearningStyleContent.fromJson(Map<String, dynamic> json, LearningStyle style) {
    return LearningStyleContent(
      gameType: json['gameType'] ?? '${style.name} Learning Game',
      activities: List<Map<String, dynamic>>.from(json['activities'] ?? []),
      style: style,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'activities': activities,
      'style': style.name,
    };
  }
}

class MultiStyleGameContent {
  final CoreConcepts concepts;
  final LearningStyleContent visualContent;
  final LearningStyleContent auditoryContent;
  final LearningStyleContent kineticContent;
  final LearningStyleContent readWriteContent;

  MultiStyleGameContent({
    required this.concepts,
    required this.visualContent,
    required this.auditoryContent,
    required this.kineticContent,
    required this.readWriteContent,
  });

  LearningStyleContent getContentForStyle(LearningStyle style) {
    switch (style) {
      case LearningStyle.visual:
        return visualContent;
      case LearningStyle.auditory:
        return auditoryContent;
      case LearningStyle.kinesthetic:
        return kineticContent;
      case LearningStyle.readWrite:
        return readWriteContent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'concepts': concepts.toJson(),
      'visualContent': visualContent.toJson(),
      'auditoryContent': auditoryContent.toJson(),
      'kineticContent': kineticContent.toJson(),
      'readWriteContent': readWriteContent.toJson(),
    };
  }
}

// Enhanced data classes for internet-enhanced learning

class EnhancedConcepts {
  final CoreConcepts originalConcepts;
  final InternetResources internetResources;
  final List<EnhancedGameContent> enhancedGameContent;

  EnhancedConcepts({
    required this.originalConcepts,
    required this.internetResources,
    required this.enhancedGameContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'originalConcepts': originalConcepts.toJson(),
      'internetResources': internetResources.toJson(),
      'enhancedGameContent': enhancedGameContent.map((e) => e.toJson()).toList(),
    };
  }
}

class InternetResources {
  final List<WikipediaArticle> wikipediaContent;
  final List<Question> educationalQuestions;
  final List<Problem> practiceProblems;
  final List<String> relatedConcepts;

  InternetResources({
    required this.wikipediaContent,
    required this.educationalQuestions,
    required this.practiceProblems,
    required this.relatedConcepts,
  });

  factory InternetResources.empty() {
    return InternetResources(
      wikipediaContent: [],
      educationalQuestions: [],
      practiceProblems: [],
      relatedConcepts: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wikipediaContent': wikipediaContent.map((w) => w.toJson()).toList(),
      'educationalQuestions': educationalQuestions.map((q) => q.toJson()).toList(),
      'practiceProblems': practiceProblems.map((p) => p.toJson()).toList(),
      'relatedConcepts': relatedConcepts,
    };
  }
}

class WikipediaArticle {
  final String title;
  final String summary;
  final String url;

  WikipediaArticle({
    required this.title,
    required this.summary,
    required this.url,
  });

  factory WikipediaArticle.fromJson(Map<String, dynamic> json) {
    return WikipediaArticle(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'url': url,
    };
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String difficulty;
  final String explanation;
  final String category;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    required this.explanation,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? 'Understanding',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'explanation': explanation,
      'category': category,
    };
  }
}

class Problem {
  final String problem;
  final String type;
  final List<String> options;
  final String correctAnswer;
  final List<String> hints;
  final String solution;
  final String difficulty;
  final int points;

  Problem({
    required this.problem,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.hints,
    required this.solution,
    required this.difficulty,
    required this.points,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      problem: json['problem'] ?? '',
      type: json['type'] ?? 'multiple_choice',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      hints: List<String>.from(json['hints'] ?? []),
      solution: json['solution'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      points: json['points'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem': problem,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
      'hints': hints,
      'solution': solution,
      'difficulty': difficulty,
      'points': points,
    };
  }
}

class EnhancedGameContent {
  final String gameType;
  final String title;
  final String description;
  final List<GameLevel> levels;
  final int totalQuestions;
  final String difficulty;
  final List<String> learningObjectives;

  EnhancedGameContent({
    required this.gameType,
    required this.title,
    required this.description,
    required this.levels,
    required this.totalQuestions,
    required this.difficulty,
    required this.learningObjectives,
  });

  factory EnhancedGameContent.fromJson(Map<String, dynamic> json) {
    return EnhancedGameContent(
      gameType: json['gameType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      levels: (json['levels'] as List<dynamic>?)
          ?.map((l) => GameLevel.fromJson(l))
          .toList() ?? [],
      totalQuestions: json['totalQuestions'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'title': title,
      'description': description,
      'levels': levels.map((l) => l.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'learningObjectives': learningObjectives,
    };
  }
}

class GameLevel {
  final int level;
  final String title;
  final Map<String, dynamic> content;
  final List<String> challenges;
  final List<String> rewards;

  GameLevel({
    required this.level,
    required this.title,
    required this.content,
    required this.challenges,
    required this.rewards,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    return GameLevel(
      level: json['level'] ?? 1,
      title: json['title'] ?? '',
      content: Map<String, dynamic>.from(json['content'] ?? {}),
      challenges: List<String>.from(json['challenges'] ?? []),
      rewards: List<String>.from(json['rewards'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'content': content,
      'challenges': challenges,
      'rewards': rewards,
    };
  }
}