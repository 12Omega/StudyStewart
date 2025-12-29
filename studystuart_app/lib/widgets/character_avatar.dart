import 'package:flutter/material.dart';
import '../models/user_character.dart';
import '../services/emotional_feedback_service.dart';
import 'dart:math';

/// 🎭 Character Avatar Widget - Displaying User Characters with Personality
/// 
/// This widget displays user characters in various contexts like leaderboards,
/// profiles, and game screens, bringing their customized avatars to life
/// with animations and cultural representation.
class CharacterAvatar extends StatefulWidget {
  final UserCharacter character;
  final AvatarSize size;
  final bool showName;
  final bool showEthnicity;
  final bool showMessage;
  final bool isAnimated;
  final bool showBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  const CharacterAvatar({
    super.key,
    required this.character,
    this.size = AvatarSize.medium,
    this.showName = true,
    this.showEthnicity = false,
    this.showMessage = false,
    this.isAnimated = true,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  });

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _setupAnimations();
      _startIdleAnimations();
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  void _startIdleAnimations() {
    if (widget.isAnimated) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _triggerBounce() {
    if (widget.isAnimated) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _pulseController.dispose();
      _bounceController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerBounce();
        EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
        widget.onTap?.call();
      },
      child: widget.isAnimated
          ? AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value * _bounceAnimation.value,
                  child: _buildAvatarContent(),
                );
              },
            )
          : _buildAvatarContent(),
    );
  }

  Widget _buildAvatarContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar circle
        Container(
          width: _getAvatarSize(),
          height: _getAvatarSize(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _getEthnicityGradient(),
            border: widget.showBorder
                ? Border.all(
                    color: widget.borderColor ?? Colors.white,
                    width: 3,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main character emoji
              Text(
                widget.character.emoji,
                style: TextStyle(
                  fontSize: _getEmojiSize(),
                ),
              ),
              
              // Clothing overlay
              if (widget.character.clothing != ClothingStyle.casual)
                Positioned(
                  bottom: _getAvatarSize() * 0.1,
                  child: Text(
                    widget.character.clothing.emoji,
                    style: TextStyle(
                      fontSize: _getEmojiSize() * 0.3,
                    ),
                  ),
                ),
              
              // Accessories overlay
              if (widget.character.accessories != AccessoryStyle.none)
                Positioned(
                  top: _getAvatarSize() * 0.1,
                  right: _getAvatarSize() * 0.1,
                  child: Text(
                    widget.character.accessories.emoji,
                    style: TextStyle(
                      fontSize: _getEmojiSize() * 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Character info
        if (widget.showName || widget.showEthnicity || widget.showMessage) ...[
          const SizedBox(height: 8),
          
          if (widget.showName)
            Text(
              widget.character.name,
              style: TextStyle(
                fontSize: _getNameFontSize(),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          
          if (widget.showEthnicity) ...[
            const SizedBox(height: 2),
            Text(
              widget.character.ethnicity.displayName,
              style: TextStyle(
                fontSize: _getSubtextFontSize(),
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (widget.showMessage && widget.character.customMessage != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${widget.character.customMessage}"',
                style: TextStyle(
                  fontSize: _getSubtextFontSize() - 1,
                  fontStyle: FontStyle.italic,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ],
    );
  }

  double _getAvatarSize() {
    switch (widget.size) {
      case AvatarSize.small:
        return 40.0;
      case AvatarSize.medium:
        return 60.0;
      case AvatarSize.large:
        return 80.0;
      case AvatarSize.extraLarge:
        return 120.0;
    }
  }

  double _getEmojiSize() {
    switch (widget.size) {
      case AvatarSize.small:
        return 20.0;
      case AvatarSize.medium:
        return 30.0;
      case AvatarSize.large:
        return 40.0;
      case AvatarSize.extraLarge:
        return 60.0;
    }
  }

  double _getNameFontSize() {
    switch (widget.size) {
      case AvatarSize.small:
        return 10.0;
      case AvatarSize.medium:
        return 12.0;
      case AvatarSize.large:
        return 14.0;
      case AvatarSize.extraLarge:
        return 16.0;
    }
  }

  double _getSubtextFontSize() {
    switch (widget.size) {
      case AvatarSize.small:
        return 8.0;
      case AvatarSize.medium:
        return 10.0;
      case AvatarSize.large:
        return 12.0;
      case AvatarSize.extraLarge:
        return 14.0;
    }
  }

  LinearGradient _getEthnicityGradient() {
    // Create gradients that reflect cultural colors and themes
    switch (widget.character.ethnicity) {
      case NepalEthnicity.sherpa:
      case NepalEthnicity.tibetan:
        return LinearGradient(
          colors: [Colors.orange.shade200, Colors.red.shade200],
        );
      
      case NepalEthnicity.newar:
        return LinearGradient(
          colors: [Colors.purple.shade200, Colors.pink.shade200],
        );
      
      case NepalEthnicity.tharu:
        return LinearGradient(
          colors: [Colors.green.shade200, Colors.teal.shade200],
        );
      
      case NepalEthnicity.magar:
      case NepalEthnicity.gurung:
        return LinearGradient(
          colors: [Colors.blue.shade200, Colors.indigo.shade200],
        );
      
      case NepalEthnicity.madhesi:
        return LinearGradient(
          colors: [Colors.yellow.shade200, Colors.orange.shade200],
        );
      
      case NepalEthnicity.bahunBrahmin:
        return LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
        );
      
      default:
        return LinearGradient(
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        );
    }
  }
}

/// 📏 Avatar Size Options
enum AvatarSize {
  small,      // 40px - for compact lists
  medium,     // 60px - for cards and general use
  large,      // 80px - for profiles and highlights
  extraLarge, // 120px - for main displays
}

/// 🏆 Leaderboard Character Widget - Special version for leaderboards
class LeaderboardCharacterAvatar extends StatelessWidget {
  final UserCharacter character;
  final int rank;
  final int score;
  final bool isCurrentUser;

  const LeaderboardCharacterAvatar({
    super.key,
    required this.character,
    required this.rank,
    required this.score,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Character avatar
          CharacterAvatar(
            character: character,
            size: AvatarSize.medium,
            showName: false,
            isAnimated: isCurrentUser,
            showBorder: rank <= 3,
            borderColor: _getRankColor(),
          ),
          
          const SizedBox(width: 12),
          
          // Character info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                          color: isCurrentUser ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ),
                    if (rank <= 3)
                      Text(
                        _getTrophyEmoji(),
                        style: const TextStyle(fontSize: 20),
                      ),
                  ],
                ),
                
                Text(
                  character.ethnicity.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                Text(
                  '$score XP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange.shade300;
      default:
        return Colors.blue;
    }
  }

  String _getTrophyEmoji() {
    switch (rank) {
      case 1:
        return '🏆';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}

/// 🎮 Game Character Widget - For in-game displays
class GameCharacterAvatar extends StatefulWidget {
  final UserCharacter character;
  final String? currentEmotion;
  final String? statusMessage;

  const GameCharacterAvatar({
    super.key,
    required this.character,
    this.currentEmotion,
    this.statusMessage,
  });

  @override
  State<GameCharacterAvatar> createState() => _GameCharacterAvatarState();
}

class _GameCharacterAvatarState extends State<GameCharacterAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _emotionController;
  late Animation<double> _emotionAnimation;

  @override
  void initState() {
    super.initState();
    _emotionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _emotionAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _emotionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(GameCharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentEmotion != oldWidget.currentEmotion) {
      _triggerEmotionAnimation();
    }
  }

  void _triggerEmotionAnimation() {
    _emotionController.forward().then((_) {
      _emotionController.reverse();
    });
  }

  @override
  void dispose() {
    _emotionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _emotionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _emotionAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CharacterAvatar(
                character: widget.character,
                size: AvatarSize.large,
                showName: true,
                showEthnicity: false,
                isAnimated: true,
              ),
              
              if (widget.statusMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    widget.statusMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}