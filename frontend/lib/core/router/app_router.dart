import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/student_dashboard/dashboard_screen.dart';
import '../../features/ai_chat/ai_chat_screen.dart';
import '../../features/battle/battle_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/forum/forum_screen.dart';
import '../../features/forum/create_post_screen.dart';
import '../../features/forum/post_detail_screen.dart';
import '../../features/course_detail/course_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/service_agent_chat_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

// Instructor Imports
import '../../features/instructor/auth/instructor_login_screen.dart';
import '../../features/instructor/auth/instructor_signup_screen.dart';
import '../../features/instructor/dashboard/instructor_dashboard_screen.dart';
import '../../features/instructor/courses/instructor_courses_screen.dart';
import '../../features/instructor/tracking/instructor_tracking_screen.dart';
import '../../features/instructor/certificates/instructor_certificates_screen.dart';
import '../../features/instructor/profile/instructor_profile_screen.dart';
import '../../features/instructor/editor/content_editor_screen.dart';
import '../../features/instructor/shared/instructor_shell.dart';
import '../../features/instructor/profile/instructor_edit_profile_screen.dart';
import '../../features/instructor/forum/instructor_forum_screen.dart';
import '../../features/instructor/certificates/certificate_history_screen.dart';

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
        path: '/otp-verification',
        builder: (context, state) => OtpVerificationScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
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
        path: '/instructor/forum/create',
        builder: (context, state) =>
            const CreatePostScreen(fromInstructor: true),
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
      GoRoute(
        path: '/battle',
        builder: (context, state) => const BattleScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile/help/chat',
        builder: (context, state) => const ServiceAgentChatScreen(),
      ),

      // Instructor Auth Routes
      GoRoute(
        path: '/instructor/login',
        builder: (context, state) => const InstructorLoginScreen(),
      ),
      GoRoute(
        path: '/instructor/signup',
        builder: (context, state) => const InstructorSignupScreen(),
      ),
      GoRoute(
        path: '/instructor/editor',
        builder: (context, state) => const ContentEditorScreen(),
      ),
      GoRoute(
        path: '/instructor/profile/edit',
        builder: (context, state) => const InstructorEditProfileScreen(),
      ),
      GoRoute(
        path: '/instructor/forum',
        builder: (context, state) => const InstructorForumScreen(),
      ),
      GoRoute(
        path: '/instructor/certificates/history',
        builder: (context, state) => const CertificateHistoryScreen(),
      ),

      // Student Shell
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
                path: '/ai-chat',
                builder: (context, state) => const AiChatScreen(),
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

      // Instructor Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return InstructorShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/instructor/dashboard',
                builder: (context, state) => const InstructorDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/instructor/courses',
                builder: (context, state) => const InstructorCoursesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/instructor/tracking',
                builder: (context, state) => const InstructorTrackingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/instructor/certificates',
                builder: (context, state) =>
                    const InstructorCertificatesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/instructor/profile',
                builder: (context, state) => const InstructorProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
