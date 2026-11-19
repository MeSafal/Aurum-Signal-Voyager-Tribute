import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/data/ephemeris.dart';
import '../../core/data/facts.dart';
import '../../core/data/providers.dart';
import '../../widgets/section_header.dart';

class LiveDistance extends ConsumerStatefulWidget {
  const LiveDistance({super.key});

  @override
  ConsumerState<LiveDistance> createState() => _LiveDistanceState();
}

class _LiveDistanceState extends ConsumerState<LiveDistance> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ephemeris = ref.watch(ephemerisProvider);
    final number = NumberFormat.decimalPattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '01 · Live distance',
          title: 'Still going.',
          trailing: Icon(Icons.radio, color: AurumColors.gold, size: 18),
        ),
        const SizedBox(height: 36),
        ephemeris.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text(
            'Ephemeris unavailable. NASA milestone: '
            '${number.format(VoyagerFacts.milestoneKm.round())} km.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          data: (data) {
            final km = data.distanceKmAt(_now);
            final au = data.auAt(_now);
            final oneWay = Duration(
              seconds: VoyagerFacts.lightSecondsForKm(km).round(),
            );
            final hours = oneWay.inHours;
            final minutes = oneWay.inMinutes.remainder(60);
            final beyond = !_now.isBefore(VoyagerFacts.milestoneUtc);

            return Semantics(
              label: 'Voyager 1 is ${number.format(km.round())} '
                  'kilometres from Earth',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      number.format(km.round()),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontFamily: 'AurumMono',
                            color: AurumColors.goldLight,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'kilometres from Earth',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _Stat(label: 'DISTANCE', value: '${au.toStringAsFixed(2)} AU'),
                      _Stat(
                        label: 'LIGHT TIME',
                        value: '${hours}h ${minutes.toString().padLeft(2, '0')}m',
                      ),
                      _Stat(
                        label: 'SIGNAL DELAY',
                        value: '${(hours * 2)}h ${minutes.toString().padLeft(2, '0')}m round trip',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    beyond
                        ? 'Beyond one light-day.'
                        : 'Approaching one light-day.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AurumColors.gold,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AurumColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AurumColors.gold.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'AurumMono',
                ),
          ),
        ],
      ),
    );
  }
}
