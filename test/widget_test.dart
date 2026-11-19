import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aurum_signal/core/audio/player_service.dart';
import 'package:aurum_signal/core/settings/settings_provider.dart';
import 'helpers/fake_player.dart';
import 'package:aurum_signal/features/intro/intro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch shows the transmit gate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerServiceProvider.overrideWithValue(FakePlayer()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: IntroScreen()),
      ),
    );

    expect(find.text('Touch to transmit'), findsOneWidget);
    await tester.tap(find.text('Touch to transmit'));
    await tester.pump();
    expect(find.text('V'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('skip appears after 1.5 seconds', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerServiceProvider.overrideWithValue(FakePlayer()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: IntroScreen()),
      ),
    );
    expect(find.text('SKIP'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.text('SKIP'), findsOneWidget);
  });
}
