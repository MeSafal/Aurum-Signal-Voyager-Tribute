import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/motion.dart';
import '../../../app/theme.dart';
import '../../../core/audio/player_service.dart';
import '../../../core/morse/morse_timeline.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../widgets/morse_glyph_row.dart';

class MorseSequencePart extends StatefulWidget {
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
  final PlayerService player;
  final AppSettings settings;
  final VoidCallback onComplete;
  final int tailMs;
  final bool compact;

  @override
  State<MorseSequencePart> createState() => _MorseSequencePartState();
}

class _MorseSequencePartState extends State<MorseSequencePart>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _elapsed = ValueNotifier<int>(0);
  late final DateTime _anchor;
  int _lastEventIndex = -1;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
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
    final now = math.max(0, raw);
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
    }

    if (!_finished && now >= widget.timeline.totalMs + widget.tailMs) {
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
    return ValueListenableBuilder<int>(
      valueListenable: _elapsed,
      builder: (context, now, _) {
        return widget.compact
            ? _VoyagerLayout(
                timeline: widget.timeline,
                nowMs: now,
                reduceMotion: _reduceMotion(context),
              )
            : _VgrLayout(
                timeline: widget.timeline,
                nowMs: now,
                reduceMotion: _reduceMotion(context),
              );
      },
    );
  }

  bool _reduceMotion(BuildContext context) =>
      widget.settings.reduceMotion || MediaQuery.of(context).disableAnimations;
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
    final captionOpacity = _progress(
      nowMs - (timeline.totalMs - 200),
      700,
    );
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final span in timeline.letters) ...[
                  if (span.index > 0) const SizedBox(width: 54),
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
            const SizedBox(height: 56),
            SizedBox(
              height: 70,
              child: Opacity(
                opacity: captionOpacity,
                child: Text(
                  'V · G · R — Voyager\'s call sign.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
    final glow = _progress(nowMs - timeline.totalMs, 1500) * 0.2;
    final glowColor = Color.lerp(
      AurumColors.text,
      AurumColors.goldLight,
      glow / 0.2,
    );
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final span in timeline.letters) ...[
              if (span.index > 0) const SizedBox(width: 22),
              _Letter(
                letter: span.text,
                events: timeline.eventsForLetter(span.index),
                nowMs: nowMs,
                reduceMotion: reduceMotion,
                span: span,
                color: glowColor,
              ),
            ],
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
    this.span,
    this.color,
  });

  final String letter;
  final List<MorseEvent> events;
  final int nowMs;
  final bool reduceMotion;
  final bool large;
  final MorseSpan? span;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final active = span != null &&
        nowMs >= span!.startMs &&
        nowMs < span!.endMs + 160;
    final completed = span != null && nowMs >= span!.endMs;
    final emphasis = active ? _progress(nowMs - span!.startMs, 160) : 0.0;
    final opacity = span == null ? 1.0 : active ? 0.35 + 0.65 * emphasis : completed ? 1 : 0.35;
    final scale = reduceMotion || !active ? 1.0 : 1 + 0.04 * emphasis;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              letter,
              style: (large
                      ? Theme.of(context).textTheme.displayLarge
                      : Theme.of(context).textTheme.displayMedium)
                  ?.copyWith(
                    color: color ?? AurumColors.text,
                    fontVariations: const <FontVariation>[
                      FontVariation.weight(600),
                    ],
                  ),
            ),
            const SizedBox(height: 18),
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
      ),
    );
  }
}

double _progress(int value, int span) {
  if (span <= 0) return 1;
  final result = value / span;
  return result < 0 ? 0 : result > 1 ? 1 : result;
}
