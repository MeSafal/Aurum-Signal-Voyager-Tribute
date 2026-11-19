import 'package:flutter/material.dart';

import '../core/data/planets.dart';

class PlanetDisc extends StatelessWidget {
  const PlanetDisc({
    super.key,
    required this.planet,
    required this.size,
    this.showLabel = false,
  });

  final Planet planet;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final disc = ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: planet.imageAsset == null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.35),
                    colors: [
                      Color(planet.color),
                      Color(planet.color).withValues(alpha: 0.55),
                      const Color(0xFF05060D),
                    ],
                  ),
                ),
              )
            : Image.asset(
                planet.imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    ColoredBox(color: Color(planet.color)),
              ),
      ),
    );

    if (!showLabel) return disc;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        disc,
        const SizedBox(height: 8),
        Text(planet.name, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
