import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/student_dashboard/dashboard_screen.dart';
import '../../features/battle/battle_screen.dart';
import '../../features/ai_chat/ai_chat_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/forum/forum_screen.dart';
import '../../features/forum/create_post_screen.dart';
import '../../features/forum/post_detail_screen.dart';
import '../../features/course_detail/course_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) =>
            CourseDetailScreen(courseId: state.pathParameters['id'] ?? '1'),
      ),
      GoRoute(
        path: '/forum/create',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/forum/:id',
        builder: (context, state) =>
            PostDetailScreen(postId: state.pathParameters['id'] ?? '1'),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/battle',
                builder: (context, state) => const BattleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/forum',
                builder: (context, state) => const ForumScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
