import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/settings_provider.dart';
import '../features/about/about_screen.dart';
import '../features/about/disclaimer_screen.dart';
import '../features/home/home_screen.dart';
import '../features/intro/intro_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final introSeen = ref.read(settingsProvider).introSeen;
  return GoRouter(
    initialLocation: introSeen ? '/' : '/intro',
    routes: [
      GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/disclaimer',
        builder: (context, state) => const DisclaimerScreen(),
      ),
    ],
    errorBuilder: (context, state) => const HomeScreen(),
  );
});
