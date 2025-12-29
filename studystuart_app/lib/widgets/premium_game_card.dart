import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/emotional_feedback_service.dart';
import 'study_mascot.dart';
import 'dart:math';

/// 💎 Premium Game Card - Revolut-inspired polish with emotional design
/// 
/// These cards don't just show information - they create an experience.
/// Every interaction feels intentional, smooth, and premium, turning
/// basic game selection into something that feels elevated and engaging.
class PremiumGameCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback onTap;
  final int completedLevels;
  final int totalLevels;
  final bool isLocked;
  final String? lockReason;
  final List<String> achievements;

  const PremiumGameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
    this.completedLevels = 0,
    this.totalLevels = 10,
    this.isLocked = false,
    this.lockReason,
    this.achievements = const [],
  });

  @override
  State<PremiumGameCard> createState() => _PremiumGameCardState();
}

class _PremiumGameCardState extends State<PremiumGameCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startProgressAnimation();
  }

  void _setupAnimations() {
    // Hover animation - subtle elevation and glow
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    // Press animation - tactile feedback
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    // Shimmer animation - premium polish effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Progress animation - show building momentum
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.completedLevels / widget.totalLevels,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
  }

  void _startProgressAnimation() {
    Future.delayed(Duration(milliseconds: Random().nextInt(500)), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  void _onHoverStart() {
    setState(() => _isHovered = true);
    _hoverController.forward();
    EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
  }

  void _onHoverEnd() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTap() {
    if (widget.isLocked) {
      _showLockMessage();
      return;
    }

    // Trigger shimmer effect on tap
    _shimmerController.forward().then((_) {
      _shimmerController.reset();
    });

    EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
    widget.onTap();
  }

  void _showLockMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.lockReason ?? 'Complete previous levels to unlock'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _elevationAnimation,
          _scaleAnimation,
          _progressAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHoverStart(),
              onExit: (_) => _onHoverEnd(),
              child: GestureDetector(
                onTapDown: (_) => _onTapDown(),
                onTapUp: (_) => _onTapUp(),
                onTapCancel: () => _onTapUp(),
                onTap: _onTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.2),
                        blurRadius: _elevationAnimation.value,
                        spreadRadius: _elevationAnimation.value / 4,
                        offset: Offset(0, _elevationAnimation.value / 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background gradient
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.primaryColor,
                                widget.secondaryColor,
                              ],
                            ),
                          ),
                        ),
                        
                        // Shimmer effect overlay
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(
                                  _shimmerAnimation.value * MediaQuery.of(context).size.width,
                                  0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Lock overlay
                        if (widget.isLocked)
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row with icon and achievements
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  
                                  // Achievement badges
                                  if (widget.achievements.isNotEmpty)
                                    Row(
                                      children: widget.achievements.take(3).map((achievement) {
                                        return Container(
                                          margin: const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            achievement,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Title and description
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const Spacer(),
                              
                              // Progress bar with momentum
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _progressAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.5),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 8),
                                  
                                  Text(
                                    '${widget.completedLevels}/${widget.totalLevels}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Hover glow effect
                        if (_isHovered && !widget.isLocked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
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
      ),
    );
  }
}

/// 🎮 Game Card Factory - Pre-configured cards for different game types
class GameCardFactory {
  static PremiumGameCard mathChallenge({
    required VoidCallback onTap,
    int completedLevels = 0,
    bool isLocked = false,
  }) {
    return PremiumGameCard(
      title: 'Math Challenge',
      description: 'Solve problems with speed and accuracy',
      icon: Icons.calculate,
      primaryColor: Colors.blue,
      secondaryColor: Colors.purple,
      onTap: onTap,
      completedLevels: completedLevels,
      totalLevels: 10,
      isLocked: isLocked,
      achievements: completedLevels > 5 ? ['🔥', '⚡'] : [],
    );
  }

  static PremiumGameCard educationalWordle({
    required VoidCallback onTap,
    int completedLevels = 0,
    bool isLocked = false,
  }) {
    return PremiumGameCard(
      title: 'Educational Wordle',
      description: 'Guess words while learning new concepts',
      icon: Icons.text_fields,
      primaryColor: Colors.green,
      secondaryColor: Colors.teal,
      onTap: onTap,
      completedLevels: completedLevels,
      totalLevels: 15,
      isLocked: isLocked,
      achievements: completedLevels > 8 ? ['📚', '🎯'] : [],
    );
  }

  static PremiumGameCard diagramExplorer({
    required VoidCallback onTap,
    int completedLevels = 0,
    bool isLocked = false,
  }) {
    return PremiumGameCard(
      title: 'Diagram Explorer',
      description: 'Label parts of scientific diagrams',
      icon: Icons.science,
      primaryColor: Colors.orange,
      secondaryColor: Colors.red,
      onTap: onTap,
      completedLevels: completedLevels,
      totalLevels: 12,
      isLocked: isLocked,
      achievements: completedLevels > 6 ? ['🔬', '🧠'] : [],
    );
  }

  static PremiumGameCard memoryChallenge({
    required VoidCallback onTap,
    int completedLevels = 0,
    bool isLocked = false,
  }) {
    return PremiumGameCard(
      title: 'Memory Challenge',
      description: 'Remember sequences and patterns',
      icon: Icons.memory,
      primaryColor: Colors.purple,
      secondaryColor: Colors.pink,
      onTap: onTap,
      completedLevels: completedLevels,
      totalLevels: 20,
      isLocked: isLocked,
      achievements: completedLevels > 10 ? ['🧩', '💫'] : [],
    );
  }

  static PremiumGameCard audioRepetition({
    required VoidCallback onTap,
    int completedLevels = 0,
    bool isLocked = false,
  }) {
    return PremiumGameCard(
      title: 'Audio Repetition',
      description: 'Listen and repeat sound sequences',
      icon: Icons.headphones,
      primaryColor: Colors.indigo,
      secondaryColor: Colors.blue,
      onTap: onTap,
      completedLevels: completedLevels,
      totalLevels: 8,
      isLocked: isLocked,
      achievements: completedLevels > 4 ? ['🎵', '👂'] : [],
    );
  }

  static PremiumGameCard wordGames({
    required VoidCallback onTap,
    int completedLevels = 0,
    bool isLocked = false,
  }) {
    return PremiumGameCard(
      title: 'Word Games',
      description: 'Spelling, completion, and matching',
      icon: Icons.spellcheck,
      primaryColor: Colors.teal,
      secondaryColor: Colors.green,
      onTap: onTap,
      completedLevels: completedLevels,
      totalLevels: 18,
      isLocked: isLocked,
      achievements: completedLevels > 9 ? ['✍️', '📖'] : [],
    );
  }
}