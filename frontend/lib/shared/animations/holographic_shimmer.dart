import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HolographicShimmer extends StatefulWidget {
  final Widget child;

  const HolographicShimmer({super.key, required this.child});

  @override
  State<HolographicShimmer> createState() => _HolographicShimmerState();
}

class _HolographicShimmerState extends State<HolographicShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.white,
                Colors.white,
                Colors.white,
                AppTheme.primaryCyan, // Subtle tint
                Colors.white,
                Colors.white,
              ],
              stops: [
                0.0,
                0.3,
                0.4 + 0.2 * _controller.value, // Move shim
                0.5 + 0.2 * _controller.value,
                0.6 + 0.2 * _controller.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
