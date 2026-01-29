import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_bottom_nav.dart';
import '../animations/ambient_background.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(child: navigationShell),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
