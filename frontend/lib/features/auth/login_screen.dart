import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

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
                        "COGNIFY",
                        style: AppTheme.headlineLarge.copyWith(
                          color: AppTheme.primaryCyan,
                          letterSpacing: 4,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    "Level Up Your Mind",
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textGrey,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 48),
                  GlassContainer(
                        height: 400,
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
                                Text("Login", style: AppTheme.headlineMedium),
                                const SizedBox(height: 24),
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
                                    labelStyle: TextStyle(
                                      color: AppTheme.textGrey,
                                    ),
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      color: AppTheme.textGrey,
                                    ),
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
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.go('/dashboard');
                                      }
                                    },
                                    child: const Text("ENTER THE REALM"),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: TextButton(
                                    onPressed: () => context.go('/signup'),
                                    child: Text(
                                      "Don't have an account? Sign Up",
                                      style: TextStyle(
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .scaleXY(begin: 0.95, end: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
