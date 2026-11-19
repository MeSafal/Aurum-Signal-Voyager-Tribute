import 'package:flutter_riverpod/flutter_riverpod.dart';

enum IntroPhase { gate, vgr, date, voyager, exit, done }

class IntroState {
  final IntroPhase phase;
  final bool skipVisible;

  const IntroState({this.phase = IntroPhase.gate, this.skipVisible = false});

  IntroState copyWith({IntroPhase? phase, bool? skipVisible}) {
    return IntroState(
      phase: phase ?? this.phase,
      skipVisible: skipVisible ?? this.skipVisible,
    );
  }
}

final introControllerProvider = NotifierProvider<IntroController, IntroState>(
  IntroController.new,
);

class IntroController extends Notifier<IntroState> {
  @override
  IntroState build() => const IntroState();

  void showSkip() {
    if (state.skipVisible) return;
    state = state.copyWith(skipVisible: true);
  }

  void start() => state = state.copyWith(phase: IntroPhase.vgr);

  void toDate() => state = state.copyWith(phase: IntroPhase.date);

  void toVoyager() => state = state.copyWith(phase: IntroPhase.voyager);

  void toExit() =>
      state = state.copyWith(phase: IntroPhase.exit, skipVisible: false);

  void finish() =>
      state = state.copyWith(phase: IntroPhase.done, skipVisible: false);

  void resetIntro() => state = const IntroState();
}
