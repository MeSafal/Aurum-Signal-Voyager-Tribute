import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/audio/player_service.dart';
import '../../../core/data/facts.dart';
import '../../../core/settings/settings_provider.dart';

class DatePart extends StatefulWidget {
  const DatePart({
    super.key,
    required this.player,
    required this.settings,
    required this.onComplete,
  });

  final PlayerService player;
  final AppSettings settings;
  final VoidCallback onComplete;

  @override
  State<DatePart> createState() => _DatePartState();
}

class _DatePartState extends State<DatePart>
    with SingleTickerProviderStateMixin {
  static const int _durationMs = 7000;
  late final Ticker _ticker;
  final ValueNotifier<int> _elapsed = ValueNotifier<int>(0);
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _playBurst();
  }

  Future<void> _playBurst() async {
    try {
      final data = await rootBundle.load('assets/audio/vgr_burst.wav');
      final Uint8List bytes = data.buffer.asUint8List();
      if (!mounted) return;
      if (widget.settings.soundOn) {
        await widget.player.playBytes(bytes, onStarted: _beginClock);
      } else {
        _beginClock();
      }
    } catch (_) {
      if (mounted) _beginClock();
    }
  }

  void _beginClock() {
    if (_started || !mounted) return;
    _started = true;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final raw = elapsed.inMilliseconds + widget.settings.latencyOffsetMs;
    _elapsed.value = math.max(0, raw);
    if (!_finished && _elapsed.value >= _durationMs) {
      _finished = true;
      _ticker.stop();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = VoyagerFacts.milestoneUtc.toLocal();
    final localLabel = DateFormat('d MMMM y · HH:mm:ss').format(local);
    final zone = local.timeZoneName;
    final numberFormat = NumberFormat.decimalPattern();

    return ValueListenableBuilder<int>(
      valueListenable: _elapsed,
      builder: (context, now, _) {
        final countProgress = _progress(now, 3000);
        final eased = Curves.easeOutCubic.transform(countProgress);
        final km = VoyagerFacts.milestoneKm * eased;
        final lineProgress = _progress(now - 1200, 4200);
        final reveal = _progress(now, 500);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Opacity(
              opacity: reveal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'VGR · ONE LIGHT-DAY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AurumColors.gold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '18 NOVEMBER 2026',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontVariations: const <FontVariation>[
                            FontVariation.weight(600),
                          ],
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '10:16:07 UTC',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'AurumMono',
                          color: AurumColors.goldLight,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$localLabel · $zone (local)',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: 420,
                    child: Text(
                      VoyagerFacts.milestoneSentence,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '${numberFormat.format(km.round())} km',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'AurumMono',
                          color: AurumColors.gold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: _progress(now - 3000, 700),
                    child: Text(
                      '173.14 AU · 24 h by radio, one way.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 46),
                  SizedBox(
                    width: 420,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 1,
                              color: AurumColors.goldDark.withValues(alpha: 0.5),
                            ),
                            FractionallySizedBox(
                              widthFactor: lineProgress,
                              child: Container(
                                height: 1,
                                color: AurumColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'EARTH',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                '24 HOURS',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AurumColors.gold),
                              ),
                              Text(
                                'VOYAGER',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

double _progress(int value, int span) {
  if (span <= 0) return 1;
  final result = value / span;
  return result < 0 ? 0 : result > 1 ? 1 : result;
}
