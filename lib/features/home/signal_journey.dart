import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/data/providers.dart';
import '../../core/settings/settings_provider.dart';
import '../../widgets/section_header.dart';

class SignalJourney extends ConsumerWidget {
  const SignalJourney({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final ephemeris = ref.watch(ephemerisProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final hours = settings.journeyHours.clamp(0.0, 48.0).toDouble();
    final outbound = (hours / 24).clamp(0.0, 1.0).toDouble();
    final returning = ((hours - 24) / 24).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(eyebrow: '02 · Signal journey', title: 'SEND NOW.'),
        const SizedBox(height: 20),
        Text(
          'Drag the signal through its round trip. One day out, one day back.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
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
        const SizedBox(height: 32),
        Slider(
          value: hours,
          min: 0,
          max: 48,
          divisions: 4800,
          label: '${hours.toStringAsFixed(2)} h',
          onChanged: (value) {
            notifier.setJourneyHours(value);
            if (value >= 48 && !settings.journeyCompleted) {
              notifier.markJourneyCompleted();
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('EARTH', style: Theme.of(context).textTheme.labelSmall),
            Text(
              '${hours.toStringAsFixed(2)} H',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AurumColors.gold),
            ),
            Text('VOYAGER', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 24),
        _LegBar(
          label: hours < 24 ? 'OUTBOUND · EARTH → VOYAGER' : 'OUTBOUND · DONE',
          value: outbound,
        ),
        const SizedBox(height: 12),
        _LegBar(
          label: hours < 24
              ? 'RETURN · WAITING FOR REPLY'
              : 'RETURN · VOYAGER → EARTH',
          value: returning,
        ),
        const SizedBox(height: 16),
        Text(
          settings.journeyCompleted
              ? 'Round trip complete. Your celebration appears when you '
                    'reopen the app.'
              : 'A visualisation of light travel — no message is actually sent.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegBar extends StatelessWidget {
  const _LegBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          minHeight: 4,
          backgroundColor: AurumColors.gold.withValues(alpha: 0.12),
          color: AurumColors.gold,
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
