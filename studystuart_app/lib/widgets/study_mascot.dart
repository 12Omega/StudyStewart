import 'package:flutter/material.dart';
import 'dart:math';

/// 🦉 StudyStuart Mascot - Your Learning Companion
/// 
/// Inspired by Duolingo's character animation system, this mascot provides
/// emotional feedback through facial expressions, animations, and reactions
/// that make the learning experience feel more human and engaging.
class StudyMascot extends StatefulWidget {
  final MascotEmotion emotion;
  final MascotSize size;
  final bool isAnimated;
  final String? message;
  final VoidCallback? onTap;

  const StudyMascot({
    super.key,
    this.emotion = MascotEmotion.happy,
    this.size = MascotSize.medium,
    this.isAnimated = true,
    this.message,
    this.onTap,
  });

  @override
  State<StudyMascot> createState() => _StudyMascotState();
}

class _StudyMascotState extends State<StudyMascot>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _bounceController;
  late AnimationController _breatheController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isAnimated) {
      _startIdleAnimations();
    }
  }

  void _setupAnimations() {
    // Blinking animation - makes mascot feel alive
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation - for celebrations and interactions
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Breathing animation - subtle life-like movement
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOut,
    ));
  }

  void _startIdleAnimations() {
    // Random blinking
    _scheduleRandomBlink();
    
    // Continuous breathing
    _breatheController.repeat(reverse: true);
  }

  void _scheduleRandomBlink() {
    final random = Random();
    final delay = 2000 + random.nextInt(3000); // 2-5 seconds
    
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && widget.isAnimated) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _scheduleRandomBlink();
          });
        });
      }
    });
  }

  void _triggerReaction() {
    switch (widget.emotion) {
      case MascotEmotion.celebrating:
      case MascotEmotion.excited:
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
        break;
      default:
        // Gentle bounce for other emotions
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _bounceController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerReaction();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_breatheAnimation, _bounceAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _breatheAnimation.value * (1.0 + _bounceAnimation.value * 0.1),
            child: Container(
              width: _getMascotSize(),
              height: _getMascotSize(),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _getMascotColor().withOpacity(0.9),
                    _getMascotColor(),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getMascotColor().withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Body
                  Container(
                    width: _getMascotSize() * 0.8,
                    height: _getMascotSize() * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getMascotColor(),
                        width: 3,
                      ),
                    ),
                  ),
                  
                  // Eyes
                  Positioned(
                    top: _getMascotSize() * 0.25,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEye(isLeft: true),
                        SizedBox(width: _getMascotSize() * 0.15),
                        _buildEye(isLeft: false),
                      ],
                    ),
                  ),
                  
                  // Mouth
                  Positioned(
                    top: _getMascotSize() * 0.55,
                    child: _buildMouth(),
                  ),
                  
                  // Special effects for certain emotions
                  if (widget.emotion == MascotEmotion.celebrating)
                    ..._buildCelebrationEffects(),
                  
                  // Message bubble
                  if (widget.message != null)
                    Positioned(
                      top: -40,
                      child: _buildMessageBubble(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEye({required bool isLeft}) {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Container(
          width: _getMascotSize() * 0.12,
          height: _getMascotSize() * 0.12 * _blinkAnimation.value,
          decoration: BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: _blinkAnimation.value > 0.5
              ? Container(
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMouth() {
    switch (widget.emotion) {
      case MascotEmotion.happy:
      case MascotEmotion.celebrating:
        return Container(
          width: _getMascotSize() * 0.2,
          height: _getMascotSize() * 0.1,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      
      case MascotEmotion.excited:
        return Container(
          width: _getMascotSize() * 0.15,
          height: _getMascotSize() * 0.15,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        );
      
      case MascotEmotion.thinking:
        return Container(
          width: _getMascotSize() * 0.08,
          height: _getMascotSize() * 0.08,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        );
      
      case MascotEmotion.encouraging:
        return Container(
          width: _getMascotSize() * 0.18,
          height: _getMascotSize() * 0.08,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(15),
          ),
        );
      
      case MascotEmotion.sleepy:
        return Container(
          width: _getMascotSize() * 0.1,
          height: _getMascotSize() * 0.04,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
        );
    }
  }

  List<Widget> _buildCelebrationEffects() {
    return [
      // Sparkles around the mascot
      ...List.generate(6, (index) {
        final angle = (index * 60) * (pi / 180);
        final radius = _getMascotSize() * 0.6;
        return Positioned(
          left: _getMascotSize() / 2 + cos(angle) * radius - 5,
          top: _getMascotSize() / 2 + sin(angle) * radius - 5,
          child: AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + _bounceAnimation.value * 0.5,
                child: const Text(
                  '✨',
                  style: TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        );
      }),
    ];
  }

  Widget _buildMessageBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        widget.message!,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  double _getMascotSize() {
    switch (widget.size) {
      case MascotSize.small:
        return 60.0;
      case MascotSize.medium:
        return 80.0;
      case MascotSize.large:
        return 120.0;
    }
  }

  Color _getMascotColor() {
    switch (widget.emotion) {
      case MascotEmotion.happy:
        return Colors.blue;
      case MascotEmotion.celebrating:
        return Colors.orange;
      case MascotEmotion.excited:
        return Colors.red;
      case MascotEmotion.thinking:
        return Colors.purple;
      case MascotEmotion.encouraging:
        return Colors.green;
      case MascotEmotion.sleepy:
        return Colors.grey;
    }
  }
}

/// 🎭 Mascot Emotions - Different states for different learning moments
enum MascotEmotion {
  happy,        // Default friendly state
  celebrating,  // When user gets something right
  excited,      // When starting new challenges
  thinking,     // When user is working on problems
  encouraging,  // When user needs motivation
  sleepy,       // When user hasn't been active
}

/// 📏 Mascot Sizes - Different sizes for different contexts
enum MascotSize {
  small,   // For compact spaces
  medium,  // Default size
  large,   // For main interactions
}

/// 🎪 Mascot Reactions - Pre-built reactions for common scenarios
class MascotReactions {
  static Widget correctAnswer({MascotSize size = MascotSize.medium}) {
    return StudyMascot(
      emotion: MascotEmotion.celebrating,
      size: size,
      message: "Great job! 🎉",
    );
  }

  static Widget encouragement({MascotSize size = MascotSize.medium}) {
    return StudyMascot(
      emotion: MascotEmotion.encouraging,
      size: size,
      message: "You've got this! 💪",
    );
  }

  static Widget thinking({MascotSize size = MascotSize.medium}) {
    return StudyMascot(
      emotion: MascotEmotion.thinking,
      size: size,
      message: "Hmm, let me think... 🤔",
    );
  }

  static Widget welcome({MascotSize size = MascotSize.large}) {
    return StudyMascot(
      emotion: MascotEmotion.excited,
      size: size,
      message: "Ready to learn? 🚀",
    );
  }

  static Widget levelUp({MascotSize size = MascotSize.large}) {
    return StudyMascot(
      emotion: MascotEmotion.celebrating,
      size: size,
      message: "Level up! Amazing! 🏆",
    );
  }
}