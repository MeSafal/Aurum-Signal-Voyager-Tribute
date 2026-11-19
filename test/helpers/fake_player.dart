import 'dart:typed_data';

import 'package:aurum_signal/core/audio/player_service.dart';

class FakePlayer implements AudioPlayback {
  @override
  Future<void> playBytes(Uint8List bytes, {void Function()? onStarted}) async {
    onStarted?.call();
  }
}
