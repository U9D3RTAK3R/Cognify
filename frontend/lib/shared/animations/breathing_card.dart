import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_animations.dart';

class BreathingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;

  const BreathingCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor,
  });

  @override
  State<BreathingCard> createState() => _BreathingCardState();
}

class _BreathingCardState extends State<BreathingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.durationBreathing,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (widget.glowColor ?? AppTheme.primaryCyan).withOpacity(0.2 + (_glowAnimation.value / 60)), // Higher base opacity
                  blurRadius: 15 + _glowAnimation.value,
                  spreadRadius: _glowAnimation.value / 3,
                ),
              ],
            ),
            child: widget.onTap != null 
              ? InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(24),
                  child: widget.child,
                ) 
              : widget.child,
          ),
        );
      },
    );
  }
}
