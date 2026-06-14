import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FireworksOverlay extends StatefulWidget {
  const FireworksOverlay({super.key});

  @override
  State<FireworksOverlay> createState() => FireworksOverlayState();
}

class FireworksOverlayState extends State<FireworksOverlay> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<_Rocket> _rockets = [];
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    setState(() {
      // Update rockets
      for (int i = _rockets.length - 1; i >= 0; i--) {
        final rocket = _rockets[i];
        if (rocket.delayFrames > 0) {
          rocket.delayFrames--;
          continue;
        }

        rocket.update();
        if (rocket.exploded) {
          _explode(rocket.x, rocket.y, rocket.color);
          _rockets.removeAt(i);
        }
      }

      // Update particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.update();
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }

      // Stop ticker if nothing is running to save resource
      if (_rockets.isEmpty && _particles.isEmpty) {
        _ticker.stop();
      }
    });
  }

  void shoot() {
    if (!mounted) return;
    
    if (!_ticker.isTicking) {
      _ticker.start();
    }

    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    final colors = [
      const Color(0xFFFF2A6D), // Hot pink
      const Color(0xFF05D9E8), // Neon blue
      const Color(0xFFF5A623), // Vibrant gold
      const Color(0xFF9B51E0), // Deep purple
      const Color(0xFF27AE60), // Emerald green
    ];

    for (int i = 0; i < 3; i++) {
      final x = screenWidth * (0.2 + _random.nextDouble() * 0.6);
      final targetY = screenHeight * (0.15 + _random.nextDouble() * 0.35);
      final color = colors[_random.nextInt(colors.length)];

      _rockets.add(
        _Rocket(
          x: x,
          y: screenHeight,
          targetY: targetY,
          vy: -12 - _random.nextDouble() * 6,
          color: color,
          delayFrames: i * 15, // Launch spaced out by ~250ms
        ),
      );
    }
  }

  void _explode(double x, double y, Color color) {
    final colors = [
      color,
      color.withOpacity(0.8),
      Colors.white,
      _random.nextBool() ? const Color(0xFFFFE066) : const Color(0xFFE2E8F0),
    ];

    // Main circular explosion
    const particleCount = 60;
    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 2.0 + _random.nextDouble() * 6.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed;
      final pColor = colors[_random.nextInt(colors.length)];
      final size = 2.0 + _random.nextDouble() * 4.0;
      final life = 0.8 + _random.nextDouble() * 0.2;
      final decay = 0.01 + _random.nextDouble() * 0.015;

      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: vx,
          vy: vy,
          color: pColor,
          size: size,
          life: life,
          decay: decay,
        ),
      );
    }

    // Secondary micro glitter sparks
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 0.5 + _random.nextDouble() * 3.0;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          color: Colors.white,
          size: 1.5,
          life: 0.5 + _random.nextDouble() * 0.3,
          decay: 0.02 + _random.nextDouble() * 0.02,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rockets.isEmpty && _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _FireworksPainter(
            rockets: _rockets,
            particles: _particles,
          ),
        ),
      ),
    );
  }
}

class _Rocket {
  double x;
  double y;
  double targetY;
  double vy;
  Color color;
  int delayFrames;
  bool exploded = false;
  final List<Offset> trail = [];

  _Rocket({
    required this.x,
    required this.y,
    required this.targetY,
    required this.vy,
    required this.color,
    required this.delayFrames,
  });

  void update() {
    trail.add(Offset(x, y));
    if (trail.length > 8) {
      trail.removeAt(0);
    }

    y += vy;
    vy += 0.15; // slight gravity slowing it down

    if (y <= targetY || vy >= 0) {
      exploded = true;
    }
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double life;
  double decay;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.life,
    required this.decay,
  });

  void update() {
    x += vx;
    y += vy;

    vx *= 0.96;
    vy *= 0.96;
    vy += 0.12;

    life -= decay;
    if (life < 0) life = 0;
  }
}

class _FireworksPainter extends CustomPainter {
  final List<_Rocket> rockets;
  final List<_Particle> particles;

  _FireworksPainter({
    required this.rockets,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final rocket in rockets) {
      if (rocket.delayFrames > 0) continue;

      for (int i = 0; i < rocket.trail.length; i++) {
        final offset = rocket.trail[i];
        final opacity = (i + 1) / rocket.trail.length;
        paint.color = rocket.color.withOpacity(opacity * 0.4);

        final trailSize = 2.0 + (i / rocket.trail.length) * 2.0;
        canvas.drawCircle(offset, trailSize, paint);
      }

      paint.color = Colors.white;
      canvas.drawCircle(Offset(rocket.x, rocket.y), 4.5, paint);
      paint.color = rocket.color;
      canvas.drawCircle(Offset(rocket.x, rocket.y), 3.0, paint);
    }

    for (final p in particles) {
      if (p.life > 0.4) {
        paint.color = p.color.withOpacity(p.life * 0.2);
        canvas.drawCircle(Offset(p.x, p.y), p.size * 2.5, paint);
      }

      paint.color = p.color.withOpacity(p.life);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return true;
  }
}
