import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_state.dart';
import '../../core/providers/auth_state.dart';
import '../../core/providers/gamification_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.post('/api/verify', {
        'email': widget.email,
        'code': _otp,
      });

      if (response['success'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        if (response['token'] != null) {
          await prefs.setString('token', response['token']);
          // Update Auth Provider state explicitly
          ref.read(authProvider.notifier).login(response['token']);
        }
        await prefs.setString(
          'user_email',
          widget.email,
        ); // Save email for updates

        // Refresh gamification stats to ensure they are loaded for the new user
        ref.refresh(gamificationProvider);

        // Sync user data to state
        if (response['user'] != null) {
          debugPrint('DEBUG: Setting user data: ${response['user']}');
          ref.read(userStateProvider.notifier).setUser(response['user']);
        } else {
          debugPrint('DEBUG: No user data in response: $response');
        }

        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      await ApiService.post('/api/login', {
        'email': widget.email,
        'password': widget.password,
        'role': 'student', // Default or need to pass role too?
        // For simplicity assuming student or logic handles it.
        // LoginHandler requires role? "role": req.Role.
        // I should probably pass role too if needed, but LoginHandler might default?
        // Let's check backend. LoginHandler uses req.Role for analytics but not logic?
        // Wait, GenerateJWT uses user.Role from DB.
        // LoginHandler analytics uses req.Role.
        // So hardcoding 'student' here for resend is probably fine or I pass role too.
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP resent to ${widget.email}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryCyan.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: Stack(
        children: [
          // Animated background circles
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      height: 350,
                      width: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryCyan.withOpacity(0.4),
                            AppTheme.primaryCyan.withOpacity(0.1),
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: 20, duration: 4.seconds),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child:
                Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentPurple.withOpacity(0.4),
                            AppTheme.accentPurple.withOpacity(0.1),
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: 0, end: -15, duration: 3.seconds),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon with animation
                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryCyan.withOpacity(0.3),
                              AppTheme.accentPurple.withOpacity(0.3),
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primaryCyan.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 48,
                          color: AppTheme.primaryCyan,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 32),
                  Text(
                        "VERIFY YOUR IDENTITY",
                        style: AppTheme.headlineLarge.copyWith(
                          color: AppTheme.primaryCyan,
                          letterSpacing: 3,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the 6-digit code sent to",
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textGrey,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),
                  // OTP Input Card
                  GlassContainer(
                        height: 320,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(24),
                        borderColor: Colors.white.withOpacity(0.1),
                        blur: 20,
                        frostedOpacity: 0.1,
                        color: AppTheme.cardColor.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // OTP Input Fields
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                        width: 45,
                                        height: 55,
                                        child: TextField(
                                          controller: _otpControllers[index],
                                          focusNode: _focusNodes[index],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          maxLength: 1,
                                          style: AppTheme.headlineMedium
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            counterText: '',
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryCyan
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryCyan
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryCyan,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty && index < 5) {
                                              _focusNodes[index + 1]
                                                  .requestFocus();
                                            } else if (value.isEmpty &&
                                                index > 0) {
                                              _focusNodes[index - 1]
                                                  .requestFocus();
                                            }
                                            if (_otp.length == 6) {
                                              setState(() {
                                                _errorMessage = null;
                                              });
                                            }
                                          },
                                        ),
                                      )
                                      .animate(delay: (100 * index).ms)
                                      .fadeIn()
                                      .slideY(begin: 0.3, end: 0);
                                }),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              // Verify Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.bgBlack,
                                          ),
                                        )
                                      : const Text("VERIFY CODE"),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Resend OTP
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the code? ",
                                    style: TextStyle(color: AppTheme.textGrey),
                                  ),
                                  TextButton(
                                    onPressed: _resendOtp,
                                    child: Text(
                                      "Resend",
                                      style: TextStyle(
                                        color: AppTheme.primaryCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .scaleXY(begin: 0.95, end: 1),
                  const SizedBox(height: 24),
                  // Back button
                  TextButton.icon(
                    onPressed: () => context.go('/signup'),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppTheme.textGrey,
                    ),
                    label: Text(
                      "Back to Sign Up",
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
