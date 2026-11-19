import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup');
});

class AppSettings {
  final bool soundOn;
  final bool hapticsOn;
  final bool torchOn;
  final bool reduceMotion;
  final bool introSeen;
  final int latencyOffsetMs;
  final double journeyHours;
  final bool journeyCompleted;
  final bool journeyCelebrated;

  const AppSettings({
    this.soundOn = true,
    this.hapticsOn = false,
    this.torchOn = false,
    this.reduceMotion = false,
    this.introSeen = false,
    this.latencyOffsetMs = 0,
    this.journeyHours = 0,
    this.journeyCompleted = false,
    this.journeyCelebrated = false,
  });

  AppSettings copyWith({
    bool? soundOn,
    bool? hapticsOn,
    bool? torchOn,
    bool? reduceMotion,
    bool? introSeen,
    int? latencyOffsetMs,
    double? journeyHours,
    bool? journeyCompleted,
    bool? journeyCelebrated,
  }) {
    return AppSettings(
      soundOn: soundOn ?? this.soundOn,
      hapticsOn: hapticsOn ?? this.hapticsOn,
      torchOn: torchOn ?? this.torchOn,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      introSeen: introSeen ?? this.introSeen,
      latencyOffsetMs: latencyOffsetMs ?? this.latencyOffsetMs,
      journeyHours: journeyHours ?? this.journeyHours,
      journeyCompleted: journeyCompleted ?? this.journeyCompleted,
      journeyCelebrated: journeyCelebrated ?? this.journeyCelebrated,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _soundKey = 'settings.sound';
  static const _hapticsKey = 'settings.haptics';
  static const _torchKey = 'settings.torch';
  static const _reduceMotionKey = 'settings.reduceMotion';
  static const _introSeenKey = 'intro.seen';
  static const _latencyKey = 'settings.audioLatencyMs';
  static const _journeyKey = 'journey.hours';
  static const _journeyCompletedKey = 'journey.completed';
  static const _journeyCelebratedKey = 'journey.celebrated';

  @override
  AppSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return AppSettings(
      soundOn: prefs.getBool(_soundKey) ?? true,
      hapticsOn: prefs.getBool(_hapticsKey) ?? false,
      torchOn: prefs.getBool(_torchKey) ?? false,
      reduceMotion: prefs.getBool(_reduceMotionKey) ?? false,
      introSeen: prefs.getBool(_introSeenKey) ?? false,
      latencyOffsetMs: prefs.getInt(_latencyKey) ?? 0,
      journeyHours: prefs.getDouble(_journeyKey) ?? 0,
      journeyCompleted: prefs.getBool(_journeyCompletedKey) ?? false,
      journeyCelebrated: prefs.getBool(_journeyCelebratedKey) ?? false,
    );
  }

  Future<void> setSound(bool value) =>
      _write(_soundKey, value, next: state.copyWith(soundOn: value));

  Future<void> setHaptics(bool value) =>
      _write(_hapticsKey, value, next: state.copyWith(hapticsOn: value));

  Future<void> setTorch(bool value) =>
      _write(_torchKey, value, next: state.copyWith(torchOn: value));

  Future<void> setReduceMotion(bool value) => _write(
    _reduceMotionKey,
    value,
    next: state.copyWith(reduceMotion: value),
  );

  Future<void> setLatencyOffsetMs(int value) =>
      _write(_latencyKey, value, next: state.copyWith(latencyOffsetMs: value));

  Future<void> setJourneyHours(double value) =>
      _write(_journeyKey, value, next: state.copyWith(journeyHours: value));

  Future<void> markJourneyCompleted() => _write(
    _journeyCompletedKey,
    true,
    next: state.copyWith(journeyCompleted: true),
  );

  Future<void> markJourneyCelebrated() => _write(
    _journeyCelebratedKey,
    true,
    next: state.copyWith(journeyCelebrated: true),
  );

  Future<void> markIntroSeen() =>
      _write(_introSeenKey, true, next: state.copyWith(introSeen: true));

  Future<void> resetIntro() =>
      _write(_introSeenKey, false, next: state.copyWith(introSeen: false));

  Future<void> _write(
    String key,
    Object value, {
    required AppSettings next,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      await prefs.setInt(key, value as int);
    }
    state = next;
  }
}
