import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import '../constants/assets.dart';
import 'home_screen.dart';
import 'learning_screen.dart';
import 'converter_screen.dart';
import 'dashboard_screen.dart';
import 'character_creation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final TTSService _ttsService = TTSService();
  int _selectedIndex = 3; // Settings tab is selected
  bool _hasCharacter = true; // Will be loaded from preferences

  @override
  void initState() {
    super.initState();
    _ttsService.speak('Settings screen');
    _checkCharacterStatus();
  }

  Future<void> _checkCharacterStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final characterSkipped = prefs.getBool('character_skipped') ?? false;
      final hasCharacterData = prefs.getString('user_character_data') != null;
      
      setState(() {
        _hasCharacter = hasCharacterData && !characterSkipped;
      });
    } catch (e) {
      debugPrint('Error checking character status: $e');
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LearningScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConverterScreen()),
        );
        break;
      case 3:
        // Stay on Settings
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with logo and profile (no back arrow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue.shade100,
                        ),
                        child: Icon(
                          Icons.settings,
                          size: 40,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      
                      // Title
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      // Notification and Profile
                      Row(
                        children: [
                          Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.notifications_outlined, 
                                    size: 20, color: Colors.blue),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _ttsService.speak('Profile');
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Character Section (if not created or skipped)
                      if (!_hasCharacter) ...[
                        _buildSectionHeader('Character', Icons.person, null),
                        _buildCharacterCreationCard(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Appearance Section
                      _buildSectionHeader('Appearance', Icons.palette, null),
                      _buildThemeCard(),
                      const SizedBox(height: 24),

                      // Audio Section
                      _buildSectionHeader('Audio', Icons.volume_up, null),
                      _buildVolumeCard(),
                      const SizedBox(height: 16),
                      _buildAudioSettingsCard(),
                      const SizedBox(height: 24),

                      // Notifications Section
                      _buildSectionHeader('Notifications', Icons.notifications, AppAssets.notification),
                      _buildNotificationsCard(),
                      const SizedBox(height: 24),

                      // About Section
                      _buildSectionHeader('About', Icons.info, null),
                      _buildAboutCard(),
                      const SizedBox(height: 24),

                      // Reset Button
                      _buildResetButton(),
                      
                      const SizedBox(height: 16),
                      
                      // Logout Button
                      _buildLogoutButton(),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // TTS Button moved to bottom right to avoid blocking UI
          Positioned(
            bottom: 100,
            right: 16,
            child: TTSButton(),
          ),
        ],
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 69,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 21,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.psychology, 'Learning'),
            _buildNavItem(2, Icons.auto_awesome, 'Converter'),
            _buildNavItem(3, Icons.settings, 'Settings'),
            _buildNavItem(4, Icons.dashboard, 'Dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String? assetPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          assetPath != null
              ? Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  color: Theme.of(context).primaryColor,
                )
              : Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 20),
            onPressed: () => _ttsService.speak(title),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCreationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.person_add, color: Colors.blue.shade600),
        ),
        title: Row(
          children: [
            const Expanded(child: Text('Create Your Character')),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              onPressed: () => _ttsService.speak('Create your character'),
            ),
          ],
        ),
        subtitle: const Text('Design your personalized avatar representing Nepal\'s diversity'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _ttsService.speak('Opening character creation');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CharacterCreationScreen(),
            ),
          ).then((_) {
            // Refresh character status when returning
            _checkCharacterStatus();
          });
        },
      ),
    );
  }

  Widget _buildThemeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _settingsService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Theme mode'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    'Light',
                    Icons.light_mode,
                    !_settingsService.isDarkMode,
                    () async {
                      await _settingsService.setThemeMode(ThemeMode.light);
                      _ttsService.speak('Light mode enabled');
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    'Dark',
                    Icons.dark_mode,
                    _settingsService.isDarkMode,
                    () async {
                      await _settingsService.setThemeMode(ThemeMode.dark);
                      _ttsService.speak('Dark mode enabled');
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _settingsService.volume == 0
                      ? Icons.volume_off
                      : _settingsService.volume < 0.5
                          ? Icons.volume_down
                          : Icons.volume_up,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Volume',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${(_settingsService.volume * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Volume control'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.volume_down, color: Colors.grey.shade600),
                Expanded(
                  child: Slider(
                    value: _settingsService.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_settingsService.volume * 100).round()}%',
                    onChanged: (value) async {
                      await _settingsService.setVolume(value);
                      await _ttsService.setVolume(value);
                      setState(() {});
                    },
                    onChangeEnd: (value) {
                      _ttsService.speak('Volume set to ${(value * 100).round()} percent');
                    },
                  ),
                ),
                Icon(Icons.volume_up, color: Colors.grey.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              _ttsService.isEnabled ? Icons.record_voice_over : Icons.voice_over_off,
              color: Theme.of(context).primaryColor,
            ),
            title: Row(
              children: [
                const Expanded(child: Text('Text-to-Speech')),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Text to speech'),
                ),
              ],
            ),
            subtitle: const Text('Read text aloud'),
            value: _ttsService.isEnabled,
            onChanged: (value) async {
              await _ttsService.toggleEnabled();
              _ttsService.speak(value ? 'Text to speech enabled' : 'Text to speech disabled');
              setState(() {});
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              _settingsService.soundEffectsEnabled ? Icons.music_note : Icons.music_off,
              color: Theme.of(context).primaryColor,
            ),
            title: Row(
              children: [
                const Expanded(child: Text('Sound Effects')),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Sound effects'),
                ),
              ],
            ),
            subtitle: const Text('Play sounds during games'),
            value: _settingsService.soundEffectsEnabled,
            onChanged: (value) async {
              await _settingsService.setSoundEffectsEnabled(value);
              _ttsService.speak(value ? 'Sound effects enabled' : 'Sound effects disabled');
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              _settingsService.notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Theme.of(context).primaryColor,
            ),
            title: Row(
              children: [
                const Expanded(child: Text('Push Notifications')),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Push notifications'),
                ),
              ],
            ),
            subtitle: const Text('Receive reminders and updates'),
            value: _settingsService.notificationsEnabled,
            onChanged: (value) async {
              await _settingsService.setNotificationsEnabled(value);
              _ttsService.speak(value ? 'Notifications enabled' : 'Notifications disabled');
              setState(() {});
            },
          ),
          if (_settingsService.notificationsEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              title: Row(
                children: [
                  const Expanded(child: Text('Study Reminders')),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: () => _ttsService.speak('Study reminders'),
                  ),
                ],
              ),
              subtitle: const Text('Daily at 3:00 PM'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  _ttsService.speak(value ? 'Study reminders enabled' : 'Study reminders disabled');
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.emoji_events, color: Theme.of(context).primaryColor),
              title: Row(
                children: [
                  const Expanded(child: Text('Achievement Alerts')),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: () => _ttsService.speak('Achievement alerts'),
                  ),
                ],
              ),
              subtitle: const Text('When you earn badges'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  _ttsService.speak(value ? 'Achievement alerts enabled' : 'Achievement alerts disabled');
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            title: Row(
              children: [
                const Expanded(child: Text('Version')),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Version'),
                ),
              ],
            ),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
            title: Row(
              children: [
                const Expanded(child: Text('Privacy Policy')),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Privacy policy'),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _ttsService.speak('Opening privacy policy');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.description, color: Theme.of(context).primaryColor),
            title: Row(
              children: [
                const Expanded(child: Text('Terms of Service')),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () => _ttsService.speak('Terms of service'),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _ttsService.speak('Opening terms of service');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.restore, color: Colors.red.shade700),
        title: Text(
          'Reset to Defaults',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Restore all settings to default values'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red.shade700),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Settings?'),
              content: const Text('This will restore all settings to their default values.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _settingsService.resetToDefaults();
                    _ttsService.speak('Settings reset to defaults');
                    setState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLogoutButton() {
    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.orange.shade700),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Sign out of your account'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange.shade700),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout?'),
              content: const Text('Are you sure you want to sign out of your account?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Clear login status
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_logged_in', false);
                    await prefs.remove('user_email');
                    await prefs.remove('user_name');
                    
                    _ttsService.speak('Logged out successfully');
                    
                    if (mounted) {
                      Navigator.pop(context); // Close dialog
                      
                      // Navigate back to initial screen loader which will show auth
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }