import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.rocket_launch,
      'title': 'Level Up Your Mind',
      'description': 'Transform learning into an epic adventure. Earn XP, unlock achievements, and climb the leaderboards!',
      'color': AppTheme.primaryCyan,
    },
    {
      'icon': Icons.sports_esports,
      'title': 'Battle Knowledge Bosses',
      'description': 'Challenge yourself with Pokemon-style MCQ battles. Defeat bosses by answering questions correctly!',
      'color': AppTheme.accentPurple,
    },
    {
      'icon': Icons.psychology,
      'title': 'Ask the Oracle',
      'description': 'Your AI-powered study companion. Get instant help, explanations, and personalized guidance.',
      'color': const Color(0xFF00FF7F),
    },
    {
      'icon': Icons.forum,
      'title': 'Join the Community',
      'description': 'Connect with fellow learners. Share knowledge, ask questions, and grow together!',
      'color': AppTheme.accentPink,
    },
  ];

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E), Color(0xFF0A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    "Skip",
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
                  ),
                ),
              ),
              
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPage(
                      icon: page['icon'] as IconData,
                      title: page['title'] as String,
                      description: page['description'] as String,
                      accentColor: page['color'] as Color,
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
              
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? _pages[_currentPage]['color'] as Color
                          : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage]['color'] as Color,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
