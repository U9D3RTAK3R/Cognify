import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/user_state.dart';

void main() {
  runApp(const ProviderScope(child: CognifyApp()));
}

class CognifyApp extends ConsumerWidget {
  const CognifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final userState = ref.watch(userStateProvider);
    final isDarkMode = userState.settings.isDarkMode;

    return MaterialApp.router(
      title: 'Cognify',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
