import 'dart:math' as math;
import 'dart:typed_data';

import '../morse/morse_timeline.dart';

const int kSampleRate = 44100;
const double kMorseFrequency = 660;
const double kMorseAmplitude = 0.6;
const int kEnvelopeMs = 6;

Uint8List generateMorseWav(MorseTimeline timeline) {
  final sampleCount = (timeline.totalMs / 1000 * kSampleRate).round();
  final samples = Float64List(sampleCount);
  final attackSamples = (kEnvelopeMs / 1000 * kSampleRate).round();

  for (final event in timeline.events) {
    final start = (event.startMs / 1000 * kSampleRate).round();
    final length = (event.durationMs / 1000 * kSampleRate).round();
    for (var i = 0; i < length && start + i < sampleCount; i++) {
      final rise = attackSamples == 0 ? 1.0 : math.min(1.0, i / attackSamples);
      final fall = attackSamples == 0
          ? 1.0
          : math.min(1.0, (length - 1 - i) / attackSamples);
      final envelope = math.min(rise, fall);
      samples[start + i] +=
          kMorseAmplitude *
          envelope *
          math.sin(2 * math.pi * kMorseFrequency * i / kSampleRate);
    }
  }

  return encodeWav(samples);
}

Uint8List generateBurstWav({int durationMs = 2200}) {
  final sampleCount = (durationMs / 1000 * kSampleRate).round();
  final samples = Float64List(sampleCount);
  final durationSeconds = durationMs / 1000;
  var seed = 0x2545F491;
  var lowPass = 0.0;

  for (var i = 0; i < sampleCount; i++) {
    final t = i / kSampleRate;
    final phase = 2 * math.pi * (48 * t + 15 * t * t / durationSeconds);
    final envelope = math.exp(-1.4 * t) * math.min(1.0, t / 0.08);
    final swell = 0.46 * envelope * math.sin(phase);

    seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    final white = (seed / 0xFFFFFFFF) * 2 - 1;
    lowPass += 0.02 * (white - lowPass);
    final shimmer = 0.12 * envelope * lowPass;

    var overtone = 0.0;
    if (t < 0.12) {
      overtone = 0.08 * (1 - t / 0.12) * math.sin(2 * math.pi * 1320 * t);
    }
    samples[i] = swell + shimmer + overtone;
  }

  return encodeWav(samples);
}

Uint8List encodeWav(Float64List samples) {
  final data = ByteData(44 + samples.length * 2);
  void writeString(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeString(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, kSampleRate, Endian.little);
  data.setUint32(28, kSampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  writeString(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    data.setInt16(44 + i * 2, (clamped * 32767).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}
