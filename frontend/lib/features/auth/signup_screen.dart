import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  double _passwordStrength = 0.0;
  String _passwordStrengthText = "";
  Color _strengthColor = Colors.grey;

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length > 5) strength += 0.2;
    if (password.length > 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.2) {
        _strengthColor = Colors.red;
        _passwordStrengthText = "Weak";
      } else if (strength <= 0.4) {
        _strengthColor = Colors.orange;
        _passwordStrengthText = "Fair";
      } else if (strength <= 0.6) {
        _strengthColor = Colors.yellow;
        _passwordStrengthText = "Medium";
      } else {
        _strengthColor = Colors.green;
        _passwordStrengthText = "Strong";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child:
                Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryCyan.withOpacity(0.3),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: 30, duration: 3.seconds),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child:
                Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentPurple.withOpacity(0.3),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: 0, end: -20, duration: 4.seconds),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                        "JOIN COGNIFY",
                        style: AppTheme.headlineLarge.copyWith(
                          color: AppTheme.accentPurple,
                          letterSpacing: 4,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    "Begin Your Journey",
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textGrey,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 48),
                  GlassContainer(
                    height: 520,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(24),
                    borderColor: Colors.white.withOpacity(0.1),
                    blur: 20,
                    frostedOpacity: 0.1,
                    color: AppTheme.cardColor.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sign Up", style: AppTheme.headlineMedium),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Username",
                                labelStyle: TextStyle(color: AppTheme.textGrey),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppTheme.primaryCyan,
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: AppTheme.textGrey),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppTheme.primaryCyan,
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onChanged: _checkPasswordStrength,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: AppTheme.textGrey),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.accentPurple,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppTheme.textGrey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            // Password Strength Indicator
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                color: _strengthColor,
                                minHeight: 4,
                              ),
                            ),
                            if (_passwordStrengthText.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _passwordStrengthText,
                                  style: TextStyle(
                                    color: _strengthColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.go(
                                      '/otp-verification?email=${_emailController.text}',
                                    );
                                  }
                                },
                                child: const Text("CREATE ACCOUNT"),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text(
                                  "Already have an account? Login",
                                  style: TextStyle(color: AppTheme.textGrey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.95, end: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
