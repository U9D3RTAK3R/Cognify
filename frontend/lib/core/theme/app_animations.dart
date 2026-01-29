import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  // Durations
  static const Duration durationShort = Duration(milliseconds: 300);
  static const Duration durationMedium = Duration(milliseconds: 600);
  static const Duration durationLong = Duration(milliseconds: 1000);
  static const Duration durationBreathing = Duration(seconds: 4);

  // Curves
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.easeOutBack;

  // Page Transition
  static Widget pageTransitionWrapper({required Widget child}) {
    return child.animate()
        .fadeIn(duration: durationMedium, curve: curveSmooth)
        .slideY(begin: 0.05, end: 0, duration: durationMedium, curve: curveSmooth);
  }

  // Text Animation
  static Widget textFadeIn(Widget child, {Duration? delay}) {
    return child.animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: durationShort)
        .slideX(begin: -0.05, end: 0, duration: durationShort, curve: curveSmooth);
  }
}
