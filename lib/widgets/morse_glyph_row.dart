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
    final active = nowMs >= event.startMs && nowMs < event.endMs;
    final opacity = active ? 1.0 : (reduceMotion ? 0.38 : 0.28);
    final color = active ? AurumColors.gold : AurumColors.secondary;
    final isDash = event.symbol == MorseSymbol.dash;
    final width = isDash ? dashWidth : dotSize;
    final height = isDash ? glyphHeight : dotSize;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
