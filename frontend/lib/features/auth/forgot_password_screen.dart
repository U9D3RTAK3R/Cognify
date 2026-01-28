import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? backPath;

  const ForgotPasswordScreen({super.key, this.backPath});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('/api/forgot-password', {
        'email': _emailController.text.trim(),
      });

      if (mounted) {
        // Check if user needs to sign up
        if (response['shouldSignup'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not registered. Redirecting to Sign Up...'),
              backgroundColor: Colors.orange,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.go('/signup');
          }
          return;
        }

        // Success - navigate to OTP verification
        context.go(
          '/reset-password-otp',
          extra: {'email': _emailController.text.trim()},
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString();

        // Check for signup redirect in error
        if (errorMsg.contains('not registered') ||
            errorMsg.contains('sign up')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not registered. Redirecting to Sign Up...'),
              backgroundColor: Colors.orange,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.go('/signup');
          }
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(widget.backPath ?? '/login'),
        ),
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentPurple.withOpacity(0.2),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: 20, duration: 3.seconds),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: AppTheme.primaryCyan,
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: 24),
                  Text(
                    "Forgot Password?",
                    style: AppTheme.headlineMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email to receive a reset code",
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),

                  GlassContainer(
                        height: 220,
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
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
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
                                    labelText: "Email Address",
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
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _sendOTP,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text("SEND RESET CODE"),
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
