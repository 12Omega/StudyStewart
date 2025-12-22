import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiKeyService {
  static final ApiKeyService _instance = ApiKeyService._internal();
  factory ApiKeyService() => _instance;
  ApiKeyService._internal();

  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _openaiApiKeyKey = 'openai_api_key';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Gemini API Key management
  Future<void> setGeminiApiKey(String apiKey) async {
    if (_prefs == null) await initialize();
    await _prefs!.setString(_geminiApiKeyKey, apiKey);
    debugPrint('Gemini API key saved');
  }

  String? getGeminiApiKey() {
    if (_prefs == null) return null;
    return _prefs!.getString(_geminiApiKeyKey);
  }

  Future<void> removeGeminiApiKey() async {
    if (_prefs == null) await initialize();
    await _prefs!.remove(_geminiApiKeyKey);
    debugPrint('Gemini API key removed');
  }

  bool hasGeminiApiKey() {
    return getGeminiApiKey() != null && getGeminiApiKey()!.isNotEmpty;
  }

  // OpenAI API Key management (for future use)
  Future<void> setOpenAIApiKey(String apiKey) async {
    if (_prefs == null) await initialize();
    await _prefs!.setString(_openaiApiKeyKey, apiKey);
    debugPrint('OpenAI API key saved');
  }

  String? getOpenAIApiKey() {
    if (_prefs == null) return null;
    return _prefs!.getString(_openaiApiKeyKey);
  }

  Future<void> removeOpenAIApiKey() async {
    if (_prefs == null) await initialize();
    await _prefs!.remove(_openaiApiKeyKey);
    debugPrint('OpenAI API key removed');
  }

  bool hasOpenAIApiKey() {
    return getOpenAIApiKey() != null && getOpenAIApiKey()!.isNotEmpty;
  }

  // Validate API key format
  bool isValidGeminiApiKey(String apiKey) {
    // Basic validation for Gemini API key format
    return apiKey.isNotEmpty && 
           apiKey.length > 20 && 
           apiKey.startsWith('AI') &&
           !apiKey.contains(' ');
  }

  bool isValidOpenAIApiKey(String apiKey) {
    // Basic validation for OpenAI API key format
    return apiKey.isNotEmpty && 
           apiKey.length > 20 && 
           apiKey.startsWith('sk-') &&
           !apiKey.contains(' ');
  }

  // Clear all API keys
  Future<void> clearAllApiKeys() async {
    if (_prefs == null) await initialize();
    await _prefs!.remove(_geminiApiKeyKey);
    await _prefs!.remove(_openaiApiKeyKey);
    debugPrint('All API keys cleared');
  }

  // Check if any AI service is available
  bool hasAnyApiKey() {
    return hasGeminiApiKey() || hasOpenAIApiKey();
  }

  // Get available AI services
  List<String> getAvailableServices() {
    final services = <String>[];
    if (hasGeminiApiKey()) services.add('Google Gemini');
    if (hasOpenAIApiKey()) services.add('OpenAI GPT');
    return services;
  }
}