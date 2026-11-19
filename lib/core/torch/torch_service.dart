import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torch_light/torch_light.dart';

abstract class TorchControl {
  Future<bool> get available;
  Future<void> setOn();
  Future<void> setOff();
  Future<void> forceOff();
}

class TorchService implements TorchControl {
  bool _wanted = false;
  Future<void> _queue = Future.value();

  @override
  Future<bool> get available async {
    if (kIsWeb) return false;
    try {
      return await TorchLight.isTorchAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setOn() {
    if (kIsWeb || _wanted) return Future.value();
    _wanted = true;
    return _enqueue(() async {
      try {
        await TorchLight.enableTorch();
      } catch (_) {
        _wanted = false;
      }
    });
  }

  @override
  Future<void> setOff() {
    if (kIsWeb || !_wanted) return Future.value();
    _wanted = false;
    return _enqueue(_disable);
  }

  @override
  Future<void> forceOff() {
    _wanted = false;
    if (kIsWeb) return Future.value();
    return _enqueue(_disable);
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _queue = _queue.catchError((_) {}).then((_) => action());
    return _queue;
  }

  Future<void> _disable() async {
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }
}

final torchServiceProvider = Provider<TorchControl>((ref) {
  final service = TorchService();
  ref.onDispose(() => unawaited(service.forceOff()));
  return service;
});
