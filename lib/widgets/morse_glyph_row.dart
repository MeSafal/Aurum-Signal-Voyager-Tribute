import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/morse/morse_timeline.dart';

class MorseGlyphRow extends StatelessWidget {
  const MorseGlyphRow({
    super.key,
    required this.events,
    required this.nowMs,
    required this.letter,
    this.reduceMotion = false,
    this.dotSize = 12,
    this.dashWidth = 48,
    this.glyphHeight = 14,
  });

  final List<MorseEvent> events;
  final int nowMs;
  final String letter;
  final bool reduceMotion;
  final double dotSize;
  final double dashWidth;
  final double glyphHeight;

  @override
  Widget build(BuildContext context) {
    final description = events
        .map((event) => event.symbol == MorseSymbol.dot ? 'dot' : 'dash')
        .join(' ');
    return Semantics(
      label: '$letter in Morse: $description',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _Glyph(
              event: events[i],
              nowMs: nowMs,
              reduceMotion: reduceMotion,
              dotSize: dotSize,
              dashWidth: dashWidth,
              glyphHeight: glyphHeight,
            ),
          ],
        ],
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({
    required this.event,
    required this.nowMs,
    required this.reduceMotion,
    required this.dotSize,
    required this.dashWidth,
    required this.glyphHeight,
  });

  final MorseEvent event;
  final int nowMs;
  final bool reduceMotion;
  final double dotSize;
  final double dashWidth;
  final double glyphHeight;

  @override
  Widget build(BuildContext context) {
    final sinceStart = nowMs - event.startMs;
    final untilEnd = event.endMs - nowMs;
    final active = sinceStart >= -80 && untilEnd >= -120;
    final rise = _clamp(sinceStart / 80);
    final fall = _clamp((event.endMs + 120 - nowMs) / 120);
    final envelope = active ? math.min(rise, fall) : 0.0;
    final opacity = 0.32 + 0.68 * envelope;
    final progress = _clamp(sinceStart / event.durationMs);
    final isDash = event.symbol == MorseSymbol.dash;

    final width = isDash ? dashWidth : dotSize;
    final radius = isDash ? glyphHeight / 2 : dotSize / 2;
    final rippleOpacity = !reduceMotion && active
        ? 0.15 * (1 - _clamp(sinceStart / 600))
        : 0.0;

    return SizedBox(
      width: width,
      height: glyphHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (rippleOpacity > 0.001)
            Container(
              width: width + 18 * _clamp(sinceStart / 600),
              height: glyphHeight + 18 * _clamp(sinceStart / 600),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(radius + 9),
                border: Border.all(
                  color: AurumColors.gold.withValues(alpha: rippleOpacity),
                ),
              ),
            ),
          Container(
            width: width,
            height: isDash ? glyphHeight : dotSize,
            decoration: BoxDecoration(
              color: AurumColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: isDash ? width * progress : dotSize * envelope,
              height: isDash ? glyphHeight : dotSize * envelope,
              decoration: BoxDecoration(
                color: AurumColors.goldLight.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _clamp(double value) => value < 0
      ? 0
      : value > 1
      ? 1
      : value;
}
