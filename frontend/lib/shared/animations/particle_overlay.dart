import 'dart:math';
import 'package:flutter/material.dart';

class ParticleOverlay extends StatefulWidget {
  final Color color;
  final int numberOfParticles;

  const ParticleOverlay({
    super.key,
    this.color = Colors.white,
    this.numberOfParticles = 50,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _particles = List.generate(widget.numberOfParticles, (index) {
      return Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3,
        speed: _random.nextDouble() * 0.2 + 0.05,
        theta: _random.nextDouble() * 2 * pi,
      );
    });
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
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            controllerValue: _controller.value,
            color: widget.color.withOpacity(0.3), // Slightly visible
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double theta;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.theta,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double controllerValue;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.controllerValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Move particle
      double dy = particle.speed * 0.01; // Movement per frame approx
      particle.y -= dy;

      // Wrap around
      if (particle.y < 0) {
        particle.y = 1.0;
        particle.x = Random().nextDouble(); // Random x on reset
      }

      // Draw
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // Repaint every frame
  }
}
