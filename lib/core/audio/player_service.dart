import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AudioPlayback {
  Future<void> playBytes(Uint8List bytes, {void Function()? onStarted});
}

class PlayerService implements AudioPlayback {
  final AudioPlayer _player = AudioPlayer();

  Stream<PlayerState> get stateStream => _player.onPlayerStateChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  PlayerState get state => _player.state;

  @override
  Future<void> playBytes(Uint8List bytes, {void Function()? onStarted}) async {
    await _player.stop();
    late final StreamSubscription<PlayerState> subscription;
    subscription = _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        subscription.cancel();
        onStarted?.call();
      }
    });
    await _player.play(BytesSource(bytes));
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}

final playerServiceProvider = Provider<AudioPlayback>((ref) {
  final service = PlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});
