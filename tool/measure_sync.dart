import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aurum_signal/core/audio/synth.dart';
import 'package:aurum_signal/core/morse/morse_timeline.dart';

class DetectedRun {
  int start;
  int end;

  DetectedRun(this.start, this.end);
}

List<DetectedRun> detectRuns(Uint8List wav, int sampleRate) {
  final byteData = ByteData.sublistView(wav, 44);
  final count = (wav.length - 44) ~/ 2;
  final values = Int16List(count);
  for (var i = 0; i < count; i++) {
    values[i] = byteData.getInt16(i * 2, Endian.little);
  }
  final window = (0.003 * sampleRate).round();
  final envelope = Float32List(values.length);
  for (var i = 0; i < values.length; i++) {
    var peak = 0;
    final from = max(0, i - window);
    final to = min(values.length - 1, i + window);
    for (var j = from; j <= to; j++) {
      final absolute = values[j].abs();
      if (absolute > peak) peak = absolute;
    }
    envelope[i] = peak / 32767;
  }

  final runs = <DetectedRun>[];
  DetectedRun? current;
  for (var i = 0; i < envelope.length; i++) {
    if (current == null && envelope[i] > 0.05) {
      current = DetectedRun(i, i);
    } else if (current != null) {
      current.end = i;
      if (envelope[i] < 0.02) {
        runs.add(current);
        current = null;
      }
    }
  }
  if (current != null) runs.add(current);
  return runs;
}

void main() {
  const sampleRate = kSampleRate;
  for (final entry in {
    'VGR': MorseTimeline(text: 'VGR'),
    'VOYAGER': MorseTimeline(text: 'VOYAGER'),
  }.entries) {
    final wav = generateMorseWav(entry.value);
    final runs = detectRuns(wav, sampleRate);
    var maxDelta = 0.0;
    var total = 0.0;
    var count = 0;
    for (var i = 0; i < min(runs.length, entry.value.events.length); i++) {
      final event = entry.value.events[i];
      final run = runs[i];
      final startMs = run.start / sampleRate * 1000;
      final endMs = run.end / sampleRate * 1000;
      final startDelta = (startMs - event.startMs - 6).abs();
      final endDelta = (endMs - event.endMs + 6).abs();
      final delta = max(startDelta, endDelta);
      maxDelta = max(maxDelta, delta);
      total += delta;
      count++;
    }
    stdout.writeln(
      '${entry.key}: events=${entry.value.events.length} '
      'detected=${runs.length} maxDelta=${maxDelta.toStringAsFixed(2)}ms '
      'meanDelta=${(total / count).toStringAsFixed(2)}ms',
    );
  }
}
