import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/morse/morse_timeline.dart';

class MorseBeacon extends StatelessWidget {
  const MorseBeacon({
    super.key,
    required this.timeline,
    required this.nowMs,
    this.reduceMotion = false,
    this.size = 96,
  });

  final MorseTimeline timeline;
  final int nowMs;
  final bool reduceMotion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final event = timeline.eventAt(nowMs);
    final level = _level(event);
    final lampColor = Color.lerp(AurumColors.surface, AurumColors.gold, level);

    return Semantics(
      label: event == null ? 'Signal off' : 'Signal ${event.symbol.name}',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (level > 0 && !reduceMotion)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AurumColors.gold.withValues(alpha: 0.05 + 0.1 * level),
                ),
              ),
            Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AurumColors.gold.withValues(alpha: 0.35),
                ),
              ),
            ),
            Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lampColor ?? AurumColors.surface,
                boxShadow: level > 0 && !reduceMotion
                    ? [
                        BoxShadow(
                          color: AurumColors.gold.withValues(
                            alpha: 0.35 * level,
                          ),
                          blurRadius: 18 * level,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _level(MorseEvent? event) {
    if (event == null) return 0;
    if (reduceMotion) return 1;

    const fadeMs = 70.0;
    final rise = math.min(1.0, (nowMs - event.startMs) / fadeMs);
    final fall = math.min(1.0, (event.endMs - nowMs) / fadeMs);
    return math.max(0.0, math.min(rise, fall));
  }
}
