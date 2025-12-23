import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showForgotPassword = false;
  bool isLoading = false;
  final TTSService _voiceAssistant = TTSService();
  final TTSService _ttsService = TTSService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _setupVoiceAssistant();
  }

  /// Set up our friendly voice assistant and welcome the user
  Future<void> _setupVoiceAssistant() async {
    await _voiceAssistant.initialize();
    _giveWarmWelcome();
  }

  /// Give users a warm, welcoming greeting
  void _giveWarmWelcome() {
    _voiceAssistant.speak('Welcome to Study Stuart! 🌟 I\'m so excited you\'re here! Let\'s get you signed in so we can start your amazing learning journey together!');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      showForgotPassword = false;
      _formKey.currentState?.reset();
    });
    _ttsService.speak(isLogin ? 'Switched to login mode' : 'Switched to sign up mode');
  }

  /// Handle when user forgets their password - be supportive!
  void _showForgotPassword() {
    setState(() {
      showForgotPassword = true;
    });
    _voiceAssistant.speak('No worries! It happens to everyone! 😊 Just enter your email and I\'ll help you reset your password.');
  }

  /// Hide the forgot password form
  void _hideForgotPassword() {
    setState(() {
      showForgotPassword = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (showForgotPassword) {
        // Handle forgot password
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset link sent to your email'),
              backgroundColor: Colors.green,
            ),
          );
          _hideForgotPassword();
        }
      } else if (isLogin) {
        // Handle login
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _ttsService.speak('Login successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Handle signup
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _ttsService.speak('Account created successfully');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Logo
                  Container(
                    width: 79,
                    height: 79,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade100,
                    ),
                    child: Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Toggle Switch
                  if (!showForgotPassword)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!isLogin) _toggleAuthMode();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isLogin ? Theme.of(context).primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Log in',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isLogin ? Colors.white : Color(0xFF6F6B6B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isLogin) _toggleAuthMode();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isLogin ? Theme.of(context).primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Sign up',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !isLogin ? Colors.white : Color(0xFF6F6B6B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (showForgotPassword)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _hideForgotPassword,
                        ),
                        Text(
                          'Forgot Password',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field (only for signup)
                        if (!isLogin && !showForgotPassword) ...[
                          Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'We need your name to get started! What should I call you? 😊';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email field
                        Text(
                          'Your Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'rambahadur01@gmail.com',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'What\'s your email address? I need it to keep your account safe! 📧';
                              }
                              if (!value.contains('@')) {
                                return 'Hmm, that doesn\'t look like a valid email. Could you double-check it? 🤔';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field (not for forgot password)
                        if (!showForgotPassword) ...[
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isLogin ? Colors.red.shade300 : Colors.grey.shade300, 
                                width: 2
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'I need your password to keep your account secure! 🔒';
                                }
                                if (!isLogin && value.length < 6) {
                                  return 'Your password needs to be at least 6 characters long for security! 💪';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          // Error message for login
                          if (isLogin) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Wrong password',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF665D5D),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                        ],

                        // Confirm Password field (only for signup)
                        if (!isLogin && !showForgotPassword) ...[
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Confirm your password',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    showForgotPassword
                                        ? 'Reset Password'
                                        : isLogin
                                            ? 'Continue'
                                            : 'Sign Up',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Or divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 43,
                          child: OutlinedButton(
                            onPressed: () {
                              _ttsService.speak('Google login coming soon');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Google login coming soon!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'Login with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2A2A2A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bottom text and links
                        if (isLogin && !showForgotPassword) ...[
                          Center(
                            child: TextButton(
                              onPressed: _showForgotPassword,
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF648DDB),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF989898),
                              ),
                              children: [
                                TextSpan(
                                  text: isLogin 
                                    ? "Don't have an account? " 
                                    : "Have an account? ",
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _toggleAuthMode,
                                    child: Text(
                                      isLogin ? 'Sign up' : 'Sign in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF116FB8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // TTS Button in top right corner
          const Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TTSButton(),
            ),
          ),
        ],
      ),
    );
  }
}
