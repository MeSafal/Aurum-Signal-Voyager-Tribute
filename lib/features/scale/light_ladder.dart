import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../core/data/planets.dart';
import '../../widgets/planet_disc.dart';
import '../../widgets/section_header.dart';

class LightLadder extends StatelessWidget {
  const LightLadder({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <_LadderRow>[
      for (final body in kLadderBodies.where((planet) => planet.name != 'Sun'))
        _LadderRow(name: body.name, au: body.distanceAu, planet: body),
      const _LadderRow(name: 'Voyager 1', au: VoyagerFacts.milestoneAu),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '04a · Real scale',
          title: 'A ladder made of light.',
        ),
        const SizedBox(height: 12),
        Text(
          'Sunlight reaches Earth in about eight minutes. A radio wave '
          'needs a full day to reach Voyager 1.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        for (final row in rows) _LightRow(row: row),
      ],
    );
  }
}

class _LadderRow {
  const _LadderRow({required this.name, required this.au, this.planet});

  final String name;
  final double au;
  final Planet? planet;
}

class _LightRow extends StatelessWidget {
  const _LightRow({required this.row});

  final _LadderRow row;

  @override
  Widget build(BuildContext context) {
    final minutes = VoyagerFacts.lightMinutesForAu(row.au);
    final hours = (minutes / 60).floor();
    final rest = minutes - hours * 60;
    final label = hours == 0
        ? '${minutes.round()} min'
        : '$hours h ${rest.round().toString().padLeft(2, '0')} m';
    final width = (minutes / 1440).clamp(0.02, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: row.planet == null
                ? const Icon(Icons.radio, color: AurumColors.gold, size: 16)
                : PlanetDisc(planet: row.planet!, size: 22),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: Text(
              row.name,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 3,
                      color: AurumColors.gold.withValues(alpha: 0.1),
                    ),
                    Container(
                      height: 3,
                      width: constraints.maxWidth * width,
                      color: AurumColors.gold,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 96,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'AurumMono',
                color: AurumColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
