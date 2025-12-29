import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// 🎭 Emotional Feedback Service - Making Learning Feel Human
/// 
/// Inspired by Duolingo's character animation system, this service provides
/// emotional feedback loops that keep users engaged through micro-interactions,
/// celebrations, and character responses that feel alive and personal.
class EmotionalFeedbackService {
  static final EmotionalFeedbackService _instance = EmotionalFeedbackService._internal();
  factory EmotionalFeedbackService() => _instance;
  EmotionalFeedbackService._internal();

  final Random _random = Random();

  /// 🎉 Celebration Animations - Make every win feel special
  static void celebrateSuccess(BuildContext context, {
    String type = 'correct',
    int intensity = 1, // 1-3 scale
  }) {
    // Haptic feedback for tactile celebration
    HapticFeedback.lightImpact();
    
    switch (intensity) {
      case 1:
        HapticFeedback.selectionClick();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        break;
      case 3:
        HapticFeedback.heavyImpact();
        break;
    }

    // Show celebration overlay
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => CelebrationOverlay(type: type, intensity: intensity),
    );
  }

  /// ⚡ Micro-interaction Feedback - Instant emotional responses
  static void provideMicroFeedback(BuildContext context, String feedbackType) {
    switch (feedbackType) {
      case 'button_press':
        HapticFeedback.selectionClick();
        break;
      case 'correct_answer':
        HapticFeedback.mediumImpact();
        break;
      case 'wrong_answer':
        HapticFeedback.heavyImpact();
        break;
      case 'level_up':
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.heavyImpact();
        });
        break;
    }
  }

  /// 🌟 Progress Momentum - Show building something over time
  static Widget createProgressAnimation({
    required double progress,
    required String label,
    Color? color,
    bool showSparkles = true,
  }) {
    return ProgressMomentumWidget(
      progress: progress,
      label: label,
      color: color ?? Colors.blue,
      showSparkles: showSparkles,
    );
  }

  /// 🎭 Character Expressions - Emotional mascot responses
  List<String> getCharacterExpression(String emotion) {
    switch (emotion) {
      case 'encouraging':
        return ['😊', '👍', '🌟', '💪', '🎯'];
      case 'celebrating':
        return ['🎉', '🥳', '⭐', '🏆', '💫'];
      case 'thinking':
        return ['🤔', '💭', '🧠', '💡', '🔍'];
      case 'supportive':
        return ['🤗', '💙', '🌈', '☀️', '🌸'];
      case 'excited':
        return ['🚀', '⚡', '🔥', '💥', '✨'];
      default:
        return ['😊', '👍', '🌟'];
    }
  }

  /// 🎨 Dynamic Color Emotions - Colors that respond to user state
  Color getEmotionalColor(String emotion, {double opacity = 1.0}) {
    switch (emotion) {
      case 'success':
        return Colors.green.withOpacity(opacity);
      case 'encouragement':
        return Colors.blue.withOpacity(opacity);
      case 'celebration':
        return Colors.orange.withOpacity(opacity);
      case 'focus':
        return Colors.purple.withOpacity(opacity);
      case 'energy':
        return Colors.red.withOpacity(opacity);
      case 'calm':
        return Colors.teal.withOpacity(opacity);
      default:
        return Colors.blue.withOpacity(opacity);
    }
  }

  /// 🎵 Emotional Sound Patterns - Audio feedback that feels human
  List<String> getEncouragingPhrases() {
    return [
      "Amazing work! 🌟",
      "You're on fire! 🔥",
      "Brilliant thinking! 💡",
      "Keep it up, superstar! ⭐",
      "You've got this! 💪",
      "Fantastic job! 🎉",
      "Way to go! 🚀",
      "Outstanding! 🏆",
      "You're unstoppable! ⚡",
      "Perfect! 💫"
    ];
  }

  String getRandomEncouragement() {
    final phrases = getEncouragingPhrases();
    return phrases[_random.nextInt(phrases.length)];
  }
}

/// 🎊 Celebration Overlay Widget - Visual celebration that feels rewarding
class CelebrationOverlay extends StatefulWidget {
  final String type;
  final int intensity;

  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.intensity,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.intensity * 200)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCelebrationEmoji(),
                        style: TextStyle(
                          fontSize: 40 + (widget.intensity * 10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getCelebrationText(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCelebrationEmoji() {
    switch (widget.type) {
      case 'correct':
        return ['🎉', '⭐', '🌟', '💫'][widget.intensity - 1];
      case 'level_up':
        return ['🚀', '🏆', '👑'][widget.intensity - 1];
      case 'streak':
        return ['🔥', '⚡', '💥'][widget.intensity - 1];
      default:
        return '🎉';
    }
  }

  String _getCelebrationText() {
    switch (widget.type) {
      case 'correct':
        return ['Nice!', 'Great!', 'Amazing!'][widget.intensity - 1];
      case 'level_up':
        return ['Level Up!', 'New Level!', 'Mastery!'][widget.intensity - 1];
      case 'streak':
        return ['Streak!', 'On Fire!', 'Unstoppable!'][widget.intensity - 1];
      default:
        return 'Awesome!';
    }
  }
}

/// 📈 Progress Momentum Widget - Show building something over time
class ProgressMomentumWidget extends StatefulWidget {
  final double progress;
  final String label;
  final Color color;
  final bool showSparkles;

  const ProgressMomentumWidget({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.showSparkles = true,
  });

  @override
  State<ProgressMomentumWidget> createState() => _ProgressMomentumWidgetState();
}

class _ProgressMomentumWidgetState extends State<ProgressMomentumWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutBack,
    ));

    _progressController.forward();
    if (widget.showSparkles) {
      _sparkleController.repeat();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.8 * _progressAnimation.value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
            if (widget.showSparkles)
              AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return Positioned(
                    left: (MediaQuery.of(context).size.width * 0.8 * widget.progress) - 10,
                    top: -2,
                    child: Transform.scale(
                      scale: 1.0 + (0.2 * sin(_sparkleController.value * 2 * pi)),
                      child: const Text(
                        '✨',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(widget.progress * 100).toInt()}% Complete',
          style: TextStyle(
            fontSize: 12,
            color: widget.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}