import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../core/data/planets.dart';
import '../../widgets/planet_disc.dart';
import '../../widgets/section_header.dart';

class DistanceScroll extends StatelessWidget {
  const DistanceScroll({super.key});

  static const double pixelsPerAu = 90;
  static const double endAu = VoyagerFacts.milestoneAu + 4;

  @override
  Widget build(BuildContext context) {
    final markers = kPlanetLineup
        .where((planet) => planet.distanceAu > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '04b · Real scale',
          title: 'The long, empty stretch.',
        ),
        const SizedBox(height: 12),
        Text(
          'One astronomical unit is the same width everywhere below. '
          'Markers are not drawn to size.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: AurumColors.surface.withValues(alpha: 0.55),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: endAu * pixelsPerAu,
                height: 250,
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      right: 24,
                      top: 118,
                      child: Container(
                        height: 1,
                        color: AurumColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    for (final item in markers.asMap().entries)
                      _Marker(
                        x: item.value.distanceAu * pixelsPerAu,
                        label: item.value.name,
                        au: item.value.distanceAu,
                        labelAbove: item.key < 4 && item.key.isEven,
                        child: PlanetDisc(planet: item.value, size: 22),
                      ),
                    _Marker(
                      x: 0,
                      label: 'Sun',
                      au: 0,
                      labelAbove: true,
                      child: PlanetDisc(planet: kPlanetLineup.first, size: 28),
                    ),
                    Positioned(
                      left: 82 * pixelsPerAu,
                      top: 44,
                      child: Opacity(
                        opacity: 0.65,
                        child: Text(
                          'still travelling…',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    _Marker(
                      x: VoyagerFacts.milestoneAu * pixelsPerAu,
                      label: 'Voyager 1',
                      au: VoyagerFacts.milestoneAu,
                      highlight: true,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AurumColors.goldLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 AU', style: Theme.of(context).textTheme.labelSmall),
            Text(
              '${VoyagerFacts.milestoneAu.toStringAsFixed(2)} AU',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AurumColors.gold),
            ),
          ],
        ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.x,
    required this.label,
    required this.au,
    required this.child,
    this.highlight = false,
    this.labelAbove = false,
  });

  final double x;
  final String label;
  final double au;
  final Widget child;
  final bool highlight;
  final bool labelAbove;

  @override
  Widget build(BuildContext context) {
    final caption = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: highlight ? AurumColors.gold : null,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 88,
          child: Text(
            '${au.toStringAsFixed(au < 10 ? 2 : 1)} AU',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'AurumMono'),
          ),
        ),
      ],
    );
    final stem = Container(
      width: 1,
      height: 28,
      color: AurumColors.gold.withValues(alpha: 0.24),
    );
    final children = labelAbove
        ? <Widget>[
            caption,
            const SizedBox(height: 10),
            child,
            const SizedBox(height: 10),
            stem,
          ]
        : <Widget>[
            child,
            const SizedBox(height: 10),
            stem,
            const SizedBox(height: 6),
            caption,
          ];

    return Positioned(
      left: x,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
