import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/settings/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const AurumSignalApp(),
    ),
  );
}

class AurumSignalApp extends ConsumerStatefulWidget {
  const AurumSignalApp({super.key});

  @override
  ConsumerState<AurumSignalApp> createState() => _AurumSignalAppState();
}

class _AurumSignalAppState extends ConsumerState<AurumSignalApp> {
  bool _celebrationShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCelebrate());
  }

  void _maybeCelebrate() {
    if (!mounted || _celebrationShown) return;
    final settings = ref.read(settingsProvider);
    if (!settings.journeyCompleted || settings.journeyCelebrated) return;

    _celebrationShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: AurumColors.gold),
        title: const Text('ROUND TRIP COMPLETE'),
        content: const Text(
          'Your signal reached Voyager and the earliest reply is home. '
          'That is 48 hours of light time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) {
        ref.read(settingsProvider.notifier).markJourneyCelebrated();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Aurum Signal',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1,
              maxScaleFactor: 2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
