import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../widgets/section_header.dart';

class PaleBlueDotSection extends StatelessWidget {
  const PaleBlueDotSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '05 · Pale Blue Dot',
          title: 'Look again.',
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/pale_blue_dot_2020.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: AurumColors.surface,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: AurumColors.gold),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x9905060D),
                        Colors.transparent,
                        Color(0xCC05060D),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AurumColors.gold.withValues(alpha: 0.55),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 18,
                  right: 20,
                  child: Semantics(
                    label: 'Earth as seen from about six billion kilometres',
                    child: Text(
                      'Earth · ${VoyagerFacts.paleBlueDotDate} · '
                      '${VoyagerFacts.paleBlueDotDistance}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AurumColors.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'The camera was pointed back at Earth minutes before it was '
          'switched off for good. The 2020 processing lets us see the same '
          'moment more clearly.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
