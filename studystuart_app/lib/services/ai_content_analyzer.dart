import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

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

  // Extract core concepts from any educational material
  Future<CoreConcepts> extractCoreConcepts(String content) async {
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