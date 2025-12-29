import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_character.dart';
import '../services/emotional_feedback_service.dart';
import '../widgets/study_mascot.dart';
import 'auth_screen.dart';
import 'dart:math';

/// 🎭 Character Creation Screen - Celebrating Nepal's Diversity
/// 
/// This screen allows new users to create their personalized avatar
/// representing Nepal's beautiful ethnic diversity before entering the app.
class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _previewController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _previewAnimation;
  
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;
  
  // Character customization state
  String _characterName = '';
  NepalEthnicity _selectedEthnicity = NepalEthnicity.chhetri;
  Gender _selectedGender = Gender.other;
  SkinTone _selectedSkinTone = SkinTone.medium;
  HairStyle _selectedHairStyle = HairStyle.straight;
  ClothingStyle _selectedClothing = ClothingStyle.casual;
  AccessoryStyle _selectedAccessories = AccessoryStyle.none;
  String _customMessage = '';
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startWelcomeAnimation();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _previewAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeInOut,
    ));
  }

  void _startWelcomeAnimation() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bounceController.forward();
      }
    });
    _previewController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _previewController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
    } else {
      _completeCharacterCreation();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
    }
  }

  void _completeCharacterCreation() async {
    final character = UserCharacter(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _characterName.isEmpty ? 'Learning Hero' : _characterName,
      ethnicity: _selectedEthnicity,
      gender: _selectedGender,
      skinTone: _selectedSkinTone,
      hairStyle: _selectedHairStyle,
      clothing: _selectedClothing,
      accessories: _selectedAccessories,
      customMessage: _customMessage.isEmpty ? null : _customMessage,
      createdAt: DateTime.now(),
    );
    
    // Save character creation status and character data
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('character_created', true);
      await prefs.setString('user_character_data', character.toJson().toString());
      await prefs.setBool('onboarding_completed', true);
      
      // Show success feedback
      EmotionalFeedbackService.celebrateSuccess(
        context,
        type: 'level_up',
        intensity: 3,
      );
      
      // Navigate to auth screen with character
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(userCharacter: character),
        ),
      );
      
    } catch (e) {
      debugPrint('Error saving character data: $e');
      // Still navigate even if saving fails
      EmotionalFeedbackService.celebrateSuccess(
        context,
        type: 'level_up',
        intensity: 3,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(userCharacter: character),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade300,
                  Colors.purple.shade300,
                  Colors.pink.shade200,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header with progress
                _buildHeader(),
                
                // Character preview
                _buildCharacterPreview(),
                
                // Customization steps
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildWelcomeStep(),
                        _buildNameStep(),
                        _buildEthnicityStep(),
                        _buildGenderStep(),
                        _buildAppearanceStep(),
                        _buildStyleStep(),
                        _buildMessageStep(),
                      ],
                    ),
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create Your Character',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1}/$_totalSteps',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterPreview() {
    return AnimatedBuilder(
      animation: _previewAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _previewAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Character emoji display
                Text(
                  _selectedEthnicity.getEmoji(_selectedGender, _selectedSkinTone),
                  style: const TextStyle(fontSize: 60),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _characterName.isEmpty ? 'Your Character' : _characterName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                Text(
                  _selectedEthnicity.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: const Text(
                    '🇳🇵',
                    style: TextStyle(fontSize: 80),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Welcome to StudyStewart!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Let\'s create a character that represents you!\nNepal is beautiful because of its diversity, and so are you! 🌈',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // Quick preset options
            const Text(
              'Quick Start with Presets:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: CharacterPresets.getPresets().take(3).map((preset) {
                return GestureDetector(
                  onTap: () => _selectPreset(preset),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          preset.emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          preset.ethnicity.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),
            
            // Skip option for users who want to customize later
            TextButton(
              onPressed: _skipCharacterCreation,
              child: Text(
                'Skip for now - I\'ll create my character later',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What\'s your name?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'This will be displayed on leaderboards and achievements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          TextField(
            controller: _nameController,
            onChanged: (value) {
              setState(() {
                _characterName = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Don\'t worry, you can change this later in settings!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEthnicityStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Choose your ethnicity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Nepal\'s strength lies in its diversity 🇳🇵',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: NepalEthnicity.values.length,
              itemBuilder: (context, index) {
                final ethnicity = NepalEthnicity.values[index];
                final isSelected = _selectedEthnicity == ethnicity;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEthnicity = ethnicity;
                    });
                    EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade100 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ethnicity.getEmoji(_selectedGender, _selectedSkinTone),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ethnicity.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue.shade800 : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Selected ethnicity info
          if (_selectedEthnicity != NepalEthnicity.chhetri)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _selectedEthnicity.traditionalGreeting,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedEthnicity.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose your gender',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'We celebrate all identities 🏳️‍🌈',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 30),
          
          ...Gender.values.map((gender) {
            final isSelected = _selectedGender == gender;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = gender;
                  });
                  EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade100 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        gender.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        gender.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue.shade800 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAppearanceStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Customize appearance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skin tone
                  _buildCustomizationSection(
                    'Skin Tone',
                    SkinTone.values.map((tone) {
                      return _buildSelectionChip(
                        tone.displayName,
                        tone.modifier,
                        _selectedSkinTone == tone,
                        () => setState(() => _selectedSkinTone = tone),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Hair style
                  _buildCustomizationSection(
                    'Hair Style',
                    HairStyle.values.map((hair) {
                      return _buildSelectionChip(
                        hair.displayName,
                        hair.emoji,
                        _selectedHairStyle == hair,
                        () => setState(() => _selectedHairStyle = hair),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Choose your style',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clothing
                  _buildCustomizationSection(
                    'Clothing Style',
                    ClothingStyle.values.map((clothing) {
                      return _buildSelectionChip(
                        clothing.displayName,
                        clothing.emoji,
                        _selectedClothing == clothing,
                        () => setState(() => _selectedClothing = clothing),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Accessories
                  _buildCustomizationSection(
                    'Accessories',
                    AccessoryStyle.values.map((accessory) {
                      return _buildSelectionChip(
                        accessory.displayName,
                        accessory.emoji,
                        _selectedAccessories == accessory,
                        () => setState(() => _selectedAccessories = accessory),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Personal message',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Add a motivational message that will appear with your character',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          TextField(
            controller: _messageController,
            onChanged: (value) {
              setState(() {
                _customMessage = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'e.g., "Learning is my superpower!"',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.message),
            ),
            maxLines: 2,
            maxLength: 100,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'This is optional - you can skip or add it later!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options,
        ),
      ],
    );
  }

  Widget _buildSelectionChip(String label, String emoji, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji.isNotEmpty) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue.shade800 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentStep == _totalSteps - 1 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _skipCharacterCreation() async {
    try {
      // Mark character creation as completed (skipped) and onboarding as done
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('character_created', true);
      await prefs.setBool('character_skipped', true);
      await prefs.setBool('onboarding_completed', true);
      
      // Navigate directly to auth screen without character
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
      
    } catch (e) {
      debugPrint('Error saving skip status: $e');
      // Still navigate even if saving fails
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    }
  }
    setState(() {
      _characterName = preset.name;
      _selectedEthnicity = preset.ethnicity;
      _selectedGender = preset.gender;
      _selectedSkinTone = preset.skinTone;
      _selectedHairStyle = preset.hairStyle;
      _selectedClothing = preset.clothing;
      _selectedAccessories = preset.accessories;
      _customMessage = preset.customMessage ?? '';
    });
    
    _nameController.text = preset.name;
    _messageController.text = preset.customMessage ?? '';
    
    EmotionalFeedbackService.celebrateSuccess(
      context,
      type: 'correct',
      intensity: 2,
    );
    
    // Skip to final step
    setState(() {
      _currentStep = _totalSteps - 1;
    });
    _pageController.animateToPage(
      _totalSteps - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}
  void _selectPreset(UserCharacter preset) {
    setState(() {
      _characterName = preset.name;
      _selectedEthnicity = preset.ethnicity;
      _selectedGender = preset.gender;
      _selectedSkinTone = preset.skinTone;
      _selectedHairStyle = preset.hairStyle;
      _selectedClothing = preset.clothing;
      _selectedAccessories = preset.accessories;
      _customMessage = preset.customMessage ?? '';
    });
    
    _nameController.text = preset.name;
    _messageController.text = preset.customMessage ?? '';
    
    EmotionalFeedbackService.celebrateSuccess(
      context,
      type: 'correct',
      intensity: 2,
    );
    
    // Skip to final step
    setState(() {
      _currentStep = _totalSteps - 1;
    });
    _pageController.animateToPage(
      _totalSteps - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }