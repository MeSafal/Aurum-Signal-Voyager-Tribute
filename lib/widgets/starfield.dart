import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

class Starfield extends StatefulWidget {
  const Starfield({super.key, this.starCount = 60});

  final int starCount;

  @override
  State<Starfield> createState() => _StarfieldState();
}

class _StarfieldState extends State<Starfield>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();
    final random = math.Random(1977);
    _stars = List.generate(widget.starCount, (_) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.4 + random.nextDouble() * 0.7,
        opacity: 0.06 + random.nextDouble() * 0.16,
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _StarPainter(_stars, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double opacity;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double drift;

  const _StarPainter(this.stars, this.drift);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final y = ((star.y + drift * 0.04) % 1) * size.height;
      canvas.drawCircle(
        Offset(star.x * size.width, y),
        star.radius,
        Paint()
          ..color = AurumColors.text.withValues(alpha: star.opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      oldDelegate.drift != drift || oldDelegate.stars != stars;
}
