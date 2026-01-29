import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedNeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isPrimary;

  const AnimatedNeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.isPrimary = false,
  });

  @override
  State<AnimatedNeonButton> createState() => _AnimatedNeonButtonState();
}

class _AnimatedNeonButtonState extends State<AnimatedNeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? (widget.isPrimary ? AppTheme.primaryCyan : Colors.white);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: widget.isPrimary ? color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(widget.isPrimary ? 0.8 : 0.3),
                  width: 1,
                ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: color, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
