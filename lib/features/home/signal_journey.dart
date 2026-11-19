import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../core/data/providers.dart';
import '../../widgets/section_header.dart';

class SignalJourney extends ConsumerStatefulWidget {
  const SignalJourney({super.key});

  @override
  ConsumerState<SignalJourney> createState() => _SignalJourneyState();
}

class _SignalJourneyState extends ConsumerState<SignalJourney>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final ephemeris = ref.watch(ephemerisProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '02 · Signal journey',
          title: 'A message you send now.',
        ),
        const SizedBox(height: 20),
        Text(
          'If Earth sent a radio call this instant, it would reach Voyager 1 '
          'roughly one day later. A reply could not return before two days '
          'have passed.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        ephemeris.when(
          loading: () => const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(
            'Using NASA milestone: 24 h one way, 48 h round trip.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          data: (data) {
            final seconds = data.oneWayLightSecondsAt(now);
            final arrival = now.add(Duration(seconds: seconds.round()));
            final reply = now.add(Duration(seconds: (seconds * 2).round()));
            final format = DateFormat('d MMM · HH:mm:ss');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ArrivalRow(
                  label: 'ARRIVES AT VOYAGER',
                  time: format.format(arrival),
                ),
                const SizedBox(height: 12),
                _ArrivalRow(
                  label: 'EARLIEST REPLY',
                  time: format.format(reply),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final progress = Curves.easeInOutCubic.transform(_pulse.value);
            return Column(
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 1,
                      color: AurumColors.goldDark.withValues(alpha: 0.5),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 1,
                        color: AurumColors.gold.withValues(alpha: 0.8),
                      ),
                    ),
                    Positioned(
                      left:
                          progress * (MediaQuery.sizeOf(context).width - 80) -
                          5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AurumColors.goldLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EARTH',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${(VoyagerFacts.oneWayHours).round()} H OF LIGHT',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AurumColors.gold),
                    ),
                    Text(
                      'VOYAGER',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          'A visualisation of light travel — no message is actually sent.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ArrivalRow extends StatelessWidget {
  const _ArrivalRow({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'AurumMono',
                color: AurumColors.goldLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
