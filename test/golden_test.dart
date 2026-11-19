import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aurum_signal/app/theme.dart';
import 'helpers/fake_player.dart';
import 'package:aurum_signal/core/morse/morse_timeline.dart';
import 'package:aurum_signal/core/settings/settings_provider.dart';
import 'package:aurum_signal/features/intro/date_part.dart';
import 'package:aurum_signal/widgets/morse_glyph_row.dart';

void main() {
  testWidgets('VGR glyph row golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final timeline = MorseTimeline(text: 'VGR');
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: ColoredBox(
            color: AurumColors.background,
            child: Center(
              child: MorseGlyphRow(
                letter: 'V',
                events: timeline.eventsForLetter(0),
                nowMs: 100,
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(MorseGlyphRow),
      matchesGoldenFile('goldens/vgr_glyph_row.png'),
    );
  });

  testWidgets('date card golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final player = FakePlayer();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: ColoredBox(
            color: AurumColors.background,
            child: DatePart(
              player: player,
              settings: const AppSettings(soundOn: false),
              onComplete: noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    await expectLater(
      find.byType(DatePart),
      matchesGoldenFile('goldens/date_card.png'),
    );
  });
}

void noop() {}
