import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/audio/player_service.dart';
import '../../core/morse/morse_timeline.dart';
import '../../core/settings/settings_provider.dart';
import '../../widgets/starfield.dart';
import 'date_part.dart';
import 'exit_part.dart';
import 'gate_part.dart';
import 'intro_controller.dart';
import 'morse_sequence_part.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  static final MorseTimeline _vgr = MorseTimeline(text: 'VGR');
  static final MorseTimeline _voyager = MorseTimeline(text: 'VOYAGER');
  Timer? _skipTimer;

  @override
  void initState() {
    super.initState();
    _skipTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        ref.read(introControllerProvider.notifier).showSkip();
      }
    });
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    super.dispose();
  }

  Future<void> _finish() async {
    ref.read(introControllerProvider.notifier).finish();
    await ref.read(settingsProvider.notifier).markIntroSeen();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(introControllerProvider);
    final settings = ref.watch(settingsProvider);
    final player = ref.watch(playerServiceProvider);
    final controller = ref.read(introControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Starfield(starCount: 90),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              child: _phaseView(state.phase, settings, player, controller),
            ),
            if (state.skipVisible)
              Positioned(
                top: 12,
                right: 16,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'SKIP',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AurumColors.gold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _phaseView(
    IntroPhase phase,
    AppSettings settings,
    AudioPlayback player,
    IntroController controller,
  ) {
    switch (phase) {
      case IntroPhase.gate:
        return GatePart(key: const ValueKey('gate'), onStart: controller.start);
      case IntroPhase.vgr:
        return MorseSequencePart(
          key: const ValueKey('vgr'),
          timeline: _vgr,
          audioAsset: 'assets/audio/vgr_morse.wav',
          player: player,
          settings: settings,
          onComplete: controller.toDate,
        );
      case IntroPhase.date:
        return DatePart(
          key: const ValueKey('date'),
          player: player,
          settings: settings,
          onComplete: controller.toVoyager,
        );
      case IntroPhase.voyager:
        return MorseSequencePart(
          key: const ValueKey('voyager'),
          timeline: _voyager,
          audioAsset: 'assets/audio/vgr_voyager.wav',
          player: player,
          settings: settings,
          compact: true,
          tailMs: 1800,
          onComplete: controller.toExit,
        );
      case IntroPhase.exit:
        return ExitPart(key: const ValueKey('exit'), onComplete: _finish);
      case IntroPhase.done:
        return const SizedBox.shrink(key: ValueKey('done'));
    }
  }
}
