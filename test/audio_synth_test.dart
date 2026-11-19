import 'package:flutter_test/flutter_test.dart';
import 'package:aurum_signal/core/audio/synth.dart';
import 'package:aurum_signal/core/morse/morse_timeline.dart';

void main() {
  test('morse WAV has a valid 44-byte PCM header', () {
    final timeline = MorseTimeline(text: 'VGR');
    final bytes = generateMorseWav(timeline);
    expect(bytes.sublist(0, 4), [82, 73, 70, 70]);
    expect(bytes.sublist(8, 12), [87, 65, 86, 69]);
    expect(bytes.length, 44 + (6200 / 1000 * 44100).round() * 2);
  });

  test('burst is audible and bounded', () {
    final bytes = generateBurstWav(durationMs: 500);
    expect(bytes.length, 44 + (0.5 * 44100).round() * 2);
    expect(bytes.skip(44).any((byte) => byte != 0), isTrue);
  });
}
