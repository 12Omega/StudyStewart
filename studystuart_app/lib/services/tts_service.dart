import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A friendly text-to-speech service that helps make learning more accessible
/// Think of this as your personal learning assistant that reads everything aloud!
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _speechEngine = FlutterTts();
  bool _voiceAssistantEnabled = true;
  bool _currentlySpeaking = false;

  /// Check if our voice assistant is ready to help
  bool get isEnabled => _voiceAssistantEnabled;
  
  /// Check if I'm currently speaking to you
  bool get isSpeaking => _currentlySpeaking;

  /// Set up our voice assistant to help you learn better
  Future<void> initialize() async {
    // Configure our voice to be clear and friendly
    await _speechEngine.setLanguage("en-US");
    await _speechEngine.setSpeechRate(0.5); // Nice and steady pace
    await _speechEngine.setPitch(1.0); // Natural, friendly tone
    
    // Load your preferred volume settings
    final userPreferences = await SharedPreferences.getInstance();
    final preferredVolume = userPreferences.getDouble('volume') ?? 1.0;
    await _speechEngine.setVolume(preferredVolume);

    // Set up listeners so we know when I'm talking to you
    _speechEngine.setStartHandler(() {
      _currentlySpeaking = true;
    });

    _speechEngine.setCompletionHandler(() {
      _currentlySpeaking = false;
    });

    _speechEngine.setErrorHandler((msg) {
      _currentlySpeaking = false;
    });

    // Remember if you want me to speak or stay quiet
    _voiceAssistantEnabled = userPreferences.getBool('tts_enabled') ?? true;
  }

  /// Let me speak to you! I'll read anything you want to hear
  Future<void> speak(String message) async {
    if (_voiceAssistantEnabled && message.isNotEmpty) {
      await _speechEngine.speak(message);
    }
  }

  /// Shh! I'll stop talking if you need me to
  Future<void> stop() async {
    await _speechEngine.stop();
    _currentlySpeaking = false;
  }

  /// Toggle my voice on or off - you're in control!
  Future<void> toggleEnabled() async {
    _voiceAssistantEnabled = !_voiceAssistantEnabled;
    final userPreferences = await SharedPreferences.getInstance();
    await userPreferences.setBool('tts_enabled', _voiceAssistantEnabled);
    
    if (_voiceAssistantEnabled) {
      await speak("Voice assistant is now on! I'm here to help you learn.");
    } else {
      await stop();
    }
  }

  /// Change how fast I talk - slow and steady or quick and snappy!
  Future<void> setRate(double speechRate) async {
    await _speechEngine.setSpeechRate(speechRate);
  }

  /// Adjust my voice pitch - make me sound just right for you
  Future<void> setPitch(double voicePitch) async {
    await _speechEngine.setPitch(voicePitch);
  }

  /// Adjust how loud I speak - find your perfect volume
  Future<void> setVolume(double volumeLevel) async {
    await _speechEngine.setVolume(volumeLevel);
    final userPreferences = await SharedPreferences.getInstance();
    await userPreferences.setDouble('volume', volumeLevel);
  }

  // Friendly message templates for common situations
  
  /// Welcome messages that make you feel at home
  String getWelcomeMessage(String screenName) {
    switch (screenName.toLowerCase()) {
      case 'home':
        return "Welcome back to Study Stuart! 👋 Ready to learn something awesome? Pick a game to get started!";
      case 'math':
        return "Time for some math magic! 🔢 Let's solve some problems together and have fun with numbers!";
      case 'wordle':
        return "Word puzzle time! 📝 Can you guess the mystery word? You've got this!";
      case 'audio':
        return "Listen up! 🎵 We're going to play with sounds and test your amazing memory!";
      case 'settings':
        return "Welcome to your settings! ⚙️ Make Study Stuart work perfectly for you!";
      case 'diagram':
        return "Time to explore diagrams! 🔬 Let's learn by labeling and discovering together!";
      case 'subway':
        return "All aboard the learning express! 🚇 Run, jump, and answer questions on this exciting adventure!";
      default:
        return "Welcome! Let's make learning fun together! 🌟";
    }
  }

  /// Encouraging messages for correct answers
  String getCorrectAnswerMessage() {
    final encouragingMessages = [
      "🎉 Awesome! You nailed that one!",
      "Fantastic! You're on fire! 🔥",
      "Perfect! You're getting really good at this! 💪",
      "Brilliant! That was exactly right! ⭐",
      "Amazing work! Keep it up! 🚀",
      "Yes! You've got the hang of this! 👏",
      "Excellent! Your brain is working perfectly! 🧠",
      "Wonderful! You're a natural at this! 🌟"
    ];
    return encouragingMessages[(DateTime.now().millisecondsSinceEpoch) % encouragingMessages.length];
  }

  /// Supportive messages for incorrect answers
  String getIncorrectAnswerMessage() {
    final supportiveMessages = [
      "Not quite, but that's okay! Learning happens one step at a time! 💪",
      "Oops! That wasn't it, but you're doing great! Let's keep going! 🌟",
      "Close, but not quite! Don't worry, you'll get the next one! 😊",
      "That's not right, but hey - that's how we learn! Keep trying! 🚀",
      "Almost! You're thinking hard, and that's what matters! 🧠",
      "Not this time, but I believe in you! Let's try the next one! ⭐",
      "Hmm, that wasn't it, but you're getting smarter with every try! 📚"
    ];
    return supportiveMessages[(DateTime.now().millisecondsSinceEpoch) % supportiveMessages.length];
  }

  /// Motivational messages for game completion
  String getGameCompleteMessage(int score, int total) {
    final percentage = (score / total * 100).round();
    
    if (percentage >= 90) {
      return "🏆 Outstanding! You scored $score out of $total! You're absolutely brilliant!";
    } else if (percentage >= 70) {
      return "🎉 Great job! You got $score out of $total right! You're doing really well!";
    } else if (percentage >= 50) {
      return "👍 Good effort! You scored $score out of $total! You're learning and improving!";
    } else {
      return "💪 Nice try! You got $score out of $total! Every attempt makes you stronger!";
    }
  }

  /// Clean up when we're done
  void dispose() {
    _speechEngine.stop();
  }
}