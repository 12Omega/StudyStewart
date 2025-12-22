import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

class ContentProcessorService {
  static final ContentProcessorService _instance = ContentProcessorService._internal();
  factory ContentProcessorService() => _instance;
  ContentProcessorService._internal();

  // Extract text content from different file types
  Future<String> extractTextFromFile(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'txt':
          return await _extractFromTxt(file);
        case 'pdf':
          return await _extractFromPdf(file);
        case 'doc':
        case 'docx':
          return await _extractFromWord(file);
        case 'ppt':
        case 'pptx':
          return await _extractFromPowerPoint(file);
        default:
          throw UnsupportedError('File type .$extension is not supported');
      }
    } catch (e) {
      throw Exception('Failed to extract text from file: $e');
    }
  }

  Future<String> _extractFromTxt(File file) async {
    return await file.readAsString();
  }

  Future<String> _extractFromPdf(File file) async {
    // For now, return a placeholder. In a real implementation, you'd use a PDF parsing library
    return '''
    Sample PDF Content: This is extracted text from a PDF document. 
    It contains educational material about science, mathematics, and history.
    
    Chapter 1: Introduction to Science
    Science is the systematic study of the natural world through observation and experimentation.
    
    Chapter 2: Basic Mathematics
    Mathematics is the language of science and includes arithmetic, algebra, and geometry.
    
    Chapter 3: Historical Context
    Understanding history helps us learn from past events and make better decisions.
    ''';
  }

  Future<String> _extractFromWord(File file) async {
    // For now, return a placeholder. In a real implementation, you'd use a Word parsing library
    return '''
    Sample Word Document Content: Educational material extracted from Word document.
    
    Learning Objectives:
    1. Understand basic scientific principles
    2. Apply mathematical concepts to real-world problems
    3. Analyze historical events and their significance
    
    Key Terms:
    - Hypothesis: A testable explanation for an observation
    - Equation: A mathematical statement showing equality
    - Timeline: A chronological sequence of events
    - Analysis: Detailed examination of elements or structure
    ''';
  }

  Future<String> _extractFromPowerPoint(File file) async {
    // For now, return a placeholder. In a real implementation, you'd use a PowerPoint parsing library
    return '''
    Sample PowerPoint Content: Slide content extracted from presentation.
    
    Slide 1: Introduction
    Welcome to our educational presentation on learning fundamentals.
    
    Slide 2: Key Concepts
    - Active learning improves retention
    - Multiple learning styles exist
    - Practice reinforces knowledge
    
    Slide 3: Applications
    Apply these concepts in various educational games and activities.
    ''';
  }

  // Convert content to different game formats
  GameContent convertToGameContent(String text, String gameType) {
    switch (gameType.toLowerCase()) {
      case 'wordle':
        return _convertToWordle(text);
      case 'math':
        return _convertToMath(text);
      case 'kinetic':
        return _convertToKinetic(text);
      case 'audio':
        return _convertToAudio(text);
      case 'repeat':
        return _convertToRepeat(text);
      case 'runner':
        return _convertToRunner(text);
      default:
        return _convertToWordle(text); // Default to Wordle
    }
  }

  GameContent _convertToWordle(String text) {
    final words = _extractWordsFromText(text);
    final wordList = words.where((word) => word.length == 5).take(20).toList();
    
    return GameContent(
      gameType: 'Educational Wordle',
      title: 'Custom Wordle Game',
      description: 'Guess words from your uploaded content',
      data: {
        'words': wordList.map((word) => {
          'word': word.toUpperCase(),
          'definition': 'Word from your content: ${word.toLowerCase()}'
        }).toList(),
        'category': 'Custom Content'
      },
    );
  }

  GameContent _convertToMath(String text) {
    final numbers = _extractNumbersFromText(text);
    final questions = _generateMathQuestions(numbers);
    
    return GameContent(
      gameType: 'Math Challenge',
      title: 'Custom Math Game',
      description: 'Math problems based on your content',
      data: {
        'questions': questions,
        'difficulty': 'Mixed'
      },
    );
  }

  GameContent _convertToKinetic(String text) {
    final keywords = _extractKeywordsFromText(text);
    
    return GameContent(
      gameType: 'Kinetic Game',
      title: 'Touch & Learn',
      description: 'Interactive game with your content keywords',
      data: {
        'targets': keywords.take(10).map((keyword) => {
          'word': keyword,
          'points': keyword.length * 5
        }).toList(),
        'theme': 'Custom Content'
      },
    );
  }

  GameContent _convertToAudio(String text) {
    final sentences = _extractSentencesFromText(text);
    final sequences = sentences.take(5).map((s) => s.split(' ').take(3).join(' ')).toList();
    
    return GameContent(
      gameType: 'Audio Repetition',
      title: 'Listen & Repeat',
      description: 'Audio sequences from your content',
      data: {
        'sequences': sequences,
        'difficulty': 'Progressive'
      },
    );
  }

  GameContent _convertToRepeat(String text) {
    final concepts = _extractConceptsFromText(text);
    
    return GameContent(
      gameType: 'Repeat Game',
      title: 'Memory Challenge',
      description: 'Remember sequences from your content',
      data: {
        'concepts': concepts.take(15).toList(),
        'maxLevel': 10
      },
    );
  }

  GameContent _convertToRunner(String text) {
    final questions = _extractQuestionsFromText(text);
    
    return GameContent(
      gameType: 'Learning Runner',
      title: 'Educational Runner',
      description: 'Run and answer questions from your content',
      data: {
        'questions': questions,
        'obstacles': ['Knowledge Gap', 'Confusion', 'Distraction'],
        'rewards': ['Understanding', 'Insight', 'Mastery']
      },
    );
  }

  // Helper methods for text processing
  List<String> _extractWordsFromText(String text) {
    final words = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 3 && word.length <= 8)
        .map((word) => word.toLowerCase())
        .toSet()
        .toList();
    
    words.shuffle();
    return words;
  }

  List<int> _extractNumbersFromText(String text) {
    final numberRegex = RegExp(r'\b\d+\b');
    final matches = numberRegex.allMatches(text);
    final numbers = matches
        .map((match) => int.tryParse(match.group(0)!))
        .where((num) => num != null && num! > 0 && num! < 1000)
        .cast<int>()
        .toList();
    
    return numbers.isNotEmpty ? numbers : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  }

  List<Map<String, dynamic>> _generateMathQuestions(List<int> numbers) {
    final random = Random();
    final questions = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 10; i++) {
      final num1 = numbers.isNotEmpty ? numbers[random.nextInt(numbers.length)] : random.nextInt(20) + 1;
      final num2 = numbers.isNotEmpty ? numbers[random.nextInt(numbers.length)] : random.nextInt(20) + 1;
      final operation = ['+', '-', '×', '÷'][random.nextInt(4)];
      
      int answer;
      String question;
      
      switch (operation) {
        case '+':
          answer = num1 + num2;
          question = '$num1 + $num2 = ?';
          break;
        case '-':
          answer = num1 > num2 ? num1 - num2 : num2 - num1;
          question = num1 > num2 ? '$num1 - $num2 = ?' : '$num2 - $num1 = ?';
          break;
        case '×':
          answer = num1 * num2;
          question = '$num1 × $num2 = ?';
          break;
        case '÷':
          final dividend = num1 * num2;
          answer = num1;
          question = '$dividend ÷ $num2 = ?';
          break;
        default:
          answer = num1 + num2;
          question = '$num1 + $num2 = ?';
      }
      
      final wrongAnswers = [
        answer + random.nextInt(10) + 1,
        answer - random.nextInt(10) - 1,
        answer + random.nextInt(5) + 1,
      ].where((ans) => ans != answer && ans > 0).take(3).toList();
      
      final options = [answer, ...wrongAnswers]..shuffle();
      final correctIndex = options.indexOf(answer);
      
      questions.add({
        'question': question,
        'options': options.map((opt) => opt.toString()).toList(),
        'correct': correctIndex,
      });
    }
    
    return questions;
  }

  List<String> _extractKeywordsFromText(String text) {
    final words = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 4 && word.length <= 12)
        .map((word) => word.toLowerCase())
        .toSet()
        .toList();
    
    words.shuffle();
    return words;
  }

  List<String> _extractSentencesFromText(String text) {
    final sentences = text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty && sentence.trim().length > 10)
        .map((sentence) => sentence.trim())
        .toList();
    
    return sentences.take(10).toList();
  }

  List<String> _extractConceptsFromText(String text) {
    final concepts = text
        .split(RegExp(r'[.!?:;]+'))
        .where((concept) => concept.trim().isNotEmpty && concept.trim().length > 5)
        .map((concept) => concept.trim())
        .toList();
    
    return concepts;
  }

  List<Map<String, dynamic>> _extractQuestionsFromText(String text) {
    final sentences = _extractSentencesFromText(text);
    final questions = <Map<String, dynamic>>[];
    final random = Random();
    
    for (final sentence in sentences.take(8)) {
      final words = sentence.split(' ').where((w) => w.length > 3).toList();
      if (words.length >= 4) {
        final missingWordIndex = random.nextInt(words.length);
        final missingWord = words[missingWordIndex];
        final questionText = sentence.replaceFirst(missingWord, '____');
        
        final wrongOptions = words.where((w) => w != missingWord).take(3).toList();
        final options = [missingWord, ...wrongOptions]..shuffle();
        final correctIndex = options.indexOf(missingWord);
        
        questions.add({
          'question': questionText,
          'options': options,
          'correct': correctIndex,
        });
      }
    }
    
    return questions.isNotEmpty ? questions : [
      {
        'question': 'What is the main topic of your content?',
        'options': ['Learning', 'Education', 'Knowledge', 'Study'],
        'correct': 0,
      }
    ];
  }

  // Get supported file types
  List<String> getSupportedFileTypes() {
    return ['txt', 'pdf', 'doc', 'docx', 'ppt', 'pptx'];
  }

  // Validate file type
  bool isFileTypeSupported(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return getSupportedFileTypes().contains(extension);
  }
}

class GameContent {
  final String gameType;
  final String title;
  final String description;
  final Map<String, dynamic> data;

  GameContent({
    required this.gameType,
    required this.title,
    required this.description,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'title': title,
      'description': description,
      'data': data,
    };
  }

  factory GameContent.fromJson(Map<String, dynamic> json) {
    return GameContent(
      gameType: json['gameType'],
      title: json['title'],
      description: json['description'],
      data: json['data'],
    );
  }
}