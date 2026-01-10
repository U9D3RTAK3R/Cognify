import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    if (hasSeenOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A1A),
              Color(0xFF1A0A2E),
              Color(0xFF0A1A2E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles
            ...List.generate(20, (index) {
              return Positioned(
                left: (index * 50.0) % MediaQuery.of(context).size.width,
                top: (index * 80.0) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index.isEven 
                        ? AppTheme.primaryCyan.withOpacity(0.5)
                        : AppTheme.accentPurple.withOpacity(0.5),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 500.ms, delay: (index * 100).ms)
                    .then()
                    .moveY(begin: 0, end: -50, duration: 2.seconds)
                    .fadeOut(),
              );
            }),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryCyan, AppTheme.accentPurple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology_alt,
                      size: 60,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.3)),
                  
                  const SizedBox(height: 32),
                  
                  // App name
                  Text(
                    "COGNIFY",
                    style: AppTheme.headlineLarge.copyWith(
                      color: Colors.white,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  // Tagline
                  Text(
                    "Level Up Your Mind",
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryCyan,
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryCyan.withOpacity(0.5),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
