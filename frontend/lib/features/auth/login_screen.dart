import 'dart:ui'; // Added for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/services/metamask_service.dart';
import '../../core/providers/auth_state.dart';
import '../../shared/animations/ambient_background.dart';
import '../../shared/animations/breathing_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _metamaskService = MetaMaskService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isMetaMaskLoading = false;

  Future<void> _authenticateWithMetaMask() async {
    setState(() {
      _isMetaMaskLoading = true;
    });

    try {
      if (!_metamaskService.isMetaMaskInstalled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'MetaMask is not installed. Please install MetaMask extension.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Connect wallet
      final wallet = await _metamaskService.connectWallet();
      if (wallet == null) {
        throw Exception('Failed to connect wallet');
      }

      // Authenticate with backend
      final result = await _metamaskService.authenticate(
        studentName: 'Student', // Will be updated after first login
      );

      if (result != null && result['success'] == true) {
        // Update auth state
        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.login(
          result['token'] ?? '',
          role: result['role'] ?? 'student',
          walletAddress: wallet,
        );

        if (mounted) {
          context.go('/student-dashboard');
        }
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('MetaMask authentication failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMetaMaskLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: AmbientBackground(
        child: Center(
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
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textGrey),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 48),
                BreathingCard(
                  glowColor: AppTheme.primaryCyan,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
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
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.3),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          context.go('/forgot-password'),
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: AppTheme.primaryCyan,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  _isLoading = true;
                                                });

                                                try {
                                                  // Step 1: Validate Credentials via Backend
                                                  // Backend sends OTP to email for verification
                                                  await ApiService.post(
                                                    '/api/login',
                                                    {
                                                      'email': _emailController
                                                          .text
                                                          .trim(),
                                                      'password':
                                                          _passwordController
                                                              .text,
                                                      'role': 'student',
                                                    },
                                                  );

                                                  if (mounted) {
                                                    // Step 2: Proceed to OTP Verification
                                                    context.go(
                                                      '/otp-verification?email=${Uri.encodeComponent(_emailController.text.trim())}&role=student',
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Login Failed: $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } finally {
                                                  if (mounted) {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  }
                                                }
                                              }
                                            },
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text("ENTER THE REALM"),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Divider with "OR"
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withOpacity(0.2),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: AppTheme.textGrey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withOpacity(0.2),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

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
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.95, end: 1),
                const SizedBox(height: 24),
                // Instructor Link
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Are you an Instructor?',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.go('/instructor/login'),
                        child: const Text(
                          'Login here',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
