import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/emotional_feedback_service.dart';

/// 🔊 Enhanced TTS Button - Positioned Bottom Right with Premium Design
/// 
/// This floating action button provides voice assistance control with
/// smooth animations and consistent positioning across all screens.
class TTSButton extends StatefulWidget {
  final bool showLabel;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const TTSButton({
    super.key,
    this.showLabel = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> 
    with SingleTickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulse animation if speaking
    if (_ttsService.isSpeaking) {
      _animationController.repeat(reverse: true);
    }
  }

  void _showTTSSettings() {
    // Provide haptic feedback
    EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.volume_up_rounded,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Audio Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Enable Voice Assistant',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Read text aloud and provide audio feedback'),
                    value: _ttsService.isEnabled,
                    activeColor: Colors.blue,
                    onChanged: (value) async {
                      await _ttsService.toggleEnabled();
                      setState(() {});
                      if (mounted) Navigator.pop(context);
                      
                      // Provide feedback
                      _ttsService.speak(value 
                          ? 'Voice assistant enabled! I\'ll help guide you through your learning journey! 🔊'
                          : 'Voice assistant disabled. You can re-enable it anytime from this button.');
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The voice assistant helps with navigation, celebrates your achievements, and provides encouraging feedback during learning.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTTSSettings,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _ttsService.isSpeaking ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _ttsService.isEnabled 
                      ? [Colors.blue.shade400, Colors.blue.shade600]
                      : [Colors.grey.shade400, Colors.grey.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_ttsService.isEnabled ? Colors.blue : Colors.grey).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _ttsService.isEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  
                  // Speaking indicator
                  if (_ttsService.isSpeaking)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🎯 Positioned TTS Button - Consistent Bottom Right Placement
/// 
/// This widget provides consistent positioning for the TTS button
/// across all screens with proper safe area handling.
class PositionedTTSButton extends StatelessWidget {
  final bool showLabel;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const PositionedTTSButton({
    super.key,
    this.showLabel = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: SafeArea(
        child: TTSButton(
          showLabel: showLabel,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      ),
    );
  }
}
