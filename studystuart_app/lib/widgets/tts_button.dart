import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class TTSButton extends StatefulWidget {
  const TTSButton({super.key});

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> with SingleTickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTTSSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Audio'),
              subtitle: const Text('Read text aloud'),
              value: _ttsService.isEnabled,
              onChanged: (value) async {
                await _ttsService.toggleEnabled();
                setState(() {});
                if (mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Audio will automatically read text on screen to help with reading.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTTSSettings,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _ttsService.isEnabled ? Colors.blue : Colors.grey,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              _ttsService.isEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
              size: 24,
            ),
            if (_ttsService.isSpeaking)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    transform: Matrix4.identity()
                      ..scale(1.0 + (_animationController.value * 0.3)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
