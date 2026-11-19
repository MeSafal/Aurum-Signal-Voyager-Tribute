import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aurum_signal/app/router.dart';
import 'package:aurum_signal/core/audio/player_service.dart';
import 'package:aurum_signal/core/settings/settings_provider.dart';
import 'helpers/fake_player.dart';
import 'package:aurum_signal/features/intro/intro_controller.dart';
import 'package:aurum_signal/features/intro/intro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('router starts at the gate on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({'intro.seen': false});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerServiceProvider.overrideWithValue(FakePlayer()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    expect(router.routeInformationProvider.value.uri.path, '/intro');
  });

  testWidgets('router starts at the app when intro was seen', (tester) async {
    SharedPreferences.setMockInitialValues({'intro.seen': true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerServiceProvider.overrideWithValue(FakePlayer()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    expect(router.routeInformationProvider.value.uri.path, '/');
  });

  testWidgets('intro moves gate → VGR → date → VOYAGER', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.sound': false});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerServiceProvider.overrideWithValue(FakePlayer()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(introControllerProvider.notifier);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: IntroScreen()),
      ),
    );

    expect(find.text('TAP TO BEGIN'), findsOneWidget);
    controller.start();
    await tester.pump();
    expect(find.text('V'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);

    controller.toVoyager();
    await tester.pump();
    for (final letter in ['V', 'O', 'Y', 'A', 'G', 'E', 'R']) {
      expect(find.text(letter), findsWidgets);
    }
  });

  testWidgets('reduce motion setting renders the morse row', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.sound': false,
      'settings.reduceMotion': true,
    });
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
    container.read(introControllerProvider.notifier).start();
    await tester.pump();
    expect(container.read(settingsProvider).reduceMotion, isTrue);
    expect(find.text('V'), findsOneWidget);
  });
}
