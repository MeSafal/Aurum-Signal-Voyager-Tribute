import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/data/planets.dart';
import '../../widgets/planet_disc.dart';
import '../../widgets/section_header.dart';

class SizeLineup extends StatelessWidget {
  const SizeLineup({super.key});

  static const double sunPixels = 260;

  @override
  Widget build(BuildContext context) {
    final sun = kPlanetLineup.first;
    final planets = kPlanetLineup.skip(1).toList();
    final largestPlanet = planets.firstWhere((planet) => planet.name == 'Jupiter');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '04c · Real scale',
          title: 'Size, without flattery.',
        ),
        const SizedBox(height: 12),
        Text(
          'Diameters are proportional within each panel. The Sun is far '
          'larger than every planet combined.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        _ScalePanel(
          title: 'SUN  ·  EARTH  ·  JUPITER',
          children: [
            _ScaledBody(planet: sun, size: sunPixels),
            _ScaledBody(
              planet: kPlanetLineup.firstWhere((planet) => planet.name == 'Earth'),
              size: sunPixels * 12742 / sun.diameterKm,
            ),
            _ScaledBody(
              planet: largestPlanet,
              size: sunPixels * largestPlanet.diameterKm / sun.diameterKm,
            ),
          ],
        ),
        const SizedBox(height: 22),
        _ScalePanel(
          title: 'PLANETS ONLY  ·  JUPITER = 1',
          children: [
            for (final planet in planets)
              _ScaledBody(
                planet: planet,
                size: 96 * planet.diameterKm / largestPlanet.diameterKm,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Mercury, Venus, Mars and the Sun are vector discs; NASA/JPL '
          'images are used where available.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ScalePanel extends StatelessWidget {
  const _ScalePanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AurumColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AurumColors.gold.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 290,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final child in children) ...[
                    child,
                    const SizedBox(width: 22),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaledBody extends StatelessWidget {
  const _ScaledBody({required this.planet, required this.size});

  final Planet planet;
  final double size;

  @override
  Widget build(BuildContext context) {
    final displaySize = size < 8 ? 8.0 : size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlanetDisc(planet: planet, size: displaySize),
        const SizedBox(height: 12),
        SizedBox(
          width: 90,
          child: Text(
            planet.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (size < 8)
          Text(
            'shown at minimum size',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                ),
          ),
      ],
    );
  }
}
