import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../core/audio/player_service.dart';
import '../../../core/morse/morse_timeline.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../core/torch/torch_service.dart';
import '../../../widgets/morse_beacon.dart';
import '../../../widgets/morse_glyph_row.dart';

class MorseSequencePart extends ConsumerStatefulWidget {
  const MorseSequencePart({
    super.key,
    required this.timeline,
    required this.audioAsset,
    required this.player,
    required this.settings,
    required this.onComplete,
    this.tailMs = 300,
    this.compact = false,
  });

  final MorseTimeline timeline;
  final String audioAsset;
  final AudioPlayback player;
  final AppSettings settings;
  final VoidCallback onComplete;
  final int tailMs;
  final bool compact;

  @override
  ConsumerState<MorseSequencePart> createState() => _MorseSequencePartState();
}

class _MorseSequencePartState extends ConsumerState<MorseSequencePart>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final TorchControl _torch;
  final ValueNotifier<int> _elapsed = ValueNotifier<int>(0);
  int _lastEventIndex = -1;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _torch = ref.read(torchServiceProvider);
    _ticker = createTicker(_onTick);
    _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    try {
      final data = await rootBundle.load(widget.audioAsset);
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
    final now = raw < 0 ? 0 : raw;
    _elapsed.value = now;

    var activeIndex = -1;
    for (var i = 0; i < widget.timeline.events.length; i++) {
      final event = widget.timeline.events[i];
      if (now >= event.startMs && now < event.endMs) {
        activeIndex = i;
        break;
      }
    }
    if (activeIndex != _lastEventIndex) {
      _lastEventIndex = activeIndex;
      if (activeIndex >= 0 && widget.settings.hapticsOn) {
        final event = widget.timeline.events[activeIndex];
        if (event.symbol == MorseSymbol.dot) {
          HapticFeedback.lightImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
      if (widget.settings.torchOn) {
        if (activeIndex >= 0) {
          _torch.setOn();
        } else {
          _torch.setOff();
        }
      }
    }

    if (!_finished && now >= widget.timeline.totalMs + widget.tailMs) {
      _finished = true;
      _ticker.stop();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    unawaited(_torch.forceOff());
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _elapsed,
      builder: (context, now, _) {
        final reduceMotion =
            widget.settings.reduceMotion ||
            MediaQuery.of(context).disableAnimations;
        return widget.compact
            ? _VoyagerLayout(
                timeline: widget.timeline,
                nowMs: now,
                reduceMotion: reduceMotion,
              )
            : _VgrLayout(
                timeline: widget.timeline,
                nowMs: now,
                reduceMotion: reduceMotion,
              );
      },
    );
  }
}

class _VgrLayout extends StatelessWidget {
  const _VgrLayout({
    required this.timeline,
    required this.nowMs,
    required this.reduceMotion,
  });

  final MorseTimeline timeline;
  final int nowMs;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MorseBeacon(
              timeline: timeline,
              nowMs: nowMs,
              reduceMotion: reduceMotion,
              size: 92,
            ),
            const SizedBox(height: 24),
            Text(
              'VGR',
              style: theme.textTheme.displaySmall?.copyWith(
                color: AurumColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Voyager's call sign",
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final span in timeline.letters) ...[
                  if (span.index > 0) const SizedBox(width: 40),
                  _Letter(
                    letter: span.text,
                    events: timeline.eventsForLetter(span.index),
                    nowMs: nowMs,
                    reduceMotion: reduceMotion,
                    large: true,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),
            Text('Listen for three letters', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _VoyagerLayout extends StatelessWidget {
  const _VoyagerLayout({
    required this.timeline,
    required this.nowMs,
    required this.reduceMotion,
  });

  final MorseTimeline timeline;
  final int nowMs;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MorseBeacon(
              timeline: timeline,
              nowMs: nowMs,
              reduceMotion: reduceMotion,
              size: 76,
            ),
            const SizedBox(height: 20),
            Text(
              'VOYAGER',
              style: theme.textTheme.displaySmall?.copyWith(
                color: AurumColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The spacecraft',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final span in timeline.letters) ...[
                  if (span.index > 0) const SizedBox(width: 14),
                  _Letter(
                    letter: span.text,
                    events: timeline.eventsForLetter(span.index),
                    nowMs: nowMs,
                    reduceMotion: reduceMotion,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Same signal, longer message',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({
    required this.letter,
    required this.events,
    required this.nowMs,
    required this.reduceMotion,
    this.large = false,
  });

  final String letter;
  final List<MorseEvent> events;
  final int nowMs;
  final bool reduceMotion;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final active = events.any(
      (event) => nowMs >= event.startMs && nowMs < event.endMs,
    );
    return Opacity(
      opacity: active ? 1 : 0.72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            letter,
            style:
                (large
                        ? Theme.of(context).textTheme.displayLarge
                        : Theme.of(context).textTheme.displayMedium)
                    ?.copyWith(color: AurumColors.text),
          ),
          const SizedBox(height: 16),
          MorseGlyphRow(
            letter: letter,
            events: events,
            nowMs: nowMs,
            reduceMotion: reduceMotion,
            dotSize: large ? 14 : 9,
            dashWidth: large ? 54 : 34,
            glyphHeight: large ? 18 : 12,
          ),
        ],
      ),
    );
  }
}
