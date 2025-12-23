import 'package:flutter/material.dart';
import '../services/content_processor_service.dart';
import 'educational_wordle_screen.dart';
import 'math_game_screen.dart';
import 'fill_diagram_screen.dart';
import 'audio_repetition_screen.dart';
import 'repeat_game_screen.dart';

// Custom Educational Wordle Screen with generated content
class CustomEducationalWordleScreen extends StatelessWidget {
  final GameContent gameContent;

  const CustomEducationalWordleScreen({
    super.key,
    required this.gameContent,
  });

  @override
  Widget build(BuildContext context) {
    // For now, navigate to the regular Educational Wordle screen
    // In a full implementation, you would pass the custom words to the game
    return const EducationalWordleScreen();
  }
}

// Custom Math Game Screen with generated content
class CustomMathGameScreen extends StatelessWidget {
  final GameContent gameContent;

  const CustomMathGameScreen({
    super.key,
    required this.gameContent,
  });

  @override
  Widget build(BuildContext context) {
    // For now, navigate to the regular Math Game screen
    // In a full implementation, you would pass the custom questions to the game
    return const MathGameScreen();
  }
}

// Custom Fill Diagram Screen with generated content
class CustomFillDiagramScreen extends StatelessWidget {
  final GameContent gameContent;

  const CustomFillDiagramScreen({
    super.key,
    required this.gameContent,
  });

  @override
  Widget build(BuildContext context) {
    // For now, navigate to the regular Fill Diagram screen
    // In a full implementation, you would pass the custom diagrams to the game
    return const FillDiagramScreen();
  }
}

// Custom Audio Repetition Screen with generated content
class CustomAudioRepetitionScreen extends StatelessWidget {
  final GameContent gameContent;

  const CustomAudioRepetitionScreen({
    super.key,
    required this.gameContent,
  });

  @override
  Widget build(BuildContext context) {
    // For now, navigate to the regular Audio Repetition screen
    // In a full implementation, you would pass the custom sequences to the game
    return const AudioRepetitionScreen();
  }
}

// Custom Repeat Game Screen with generated content
class CustomRepeatGameScreen extends StatelessWidget {
  final GameContent gameContent;

  const CustomRepeatGameScreen({
    super.key,
    required this.gameContent,
  });

  @override
  Widget build(BuildContext context) {
    // For now, navigate to the regular Repeat Game screen
    // In a full implementation, you would pass the custom concepts to the game
    return const RepeatGameScreen();
  }
}