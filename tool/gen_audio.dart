import 'dart:io';

import 'package:voyger/core/audio/synth.dart';
import 'package:voyger/core/morse/morse_timeline.dart';

void main() {
  final output = Directory('assets/audio');
  if (!output.existsSync()) {
    output.createSync(recursive: true);
  }

  final vgr = MorseTimeline(text: 'VGR');
  final voyager = MorseTimeline(text: 'VOYAGER');

  File('${output.path}/vgr_morse.wav').writeAsBytesSync(generateMorseWav(vgr));
  File('${output.path}/vgr_voyager.wav').writeAsBytesSync(generateMorseWav(voyager));
  File('${output.path}/vgr_burst.wav').writeAsBytesSync(generateBurstWav());

  stdout.writeln('Wrote vgr_morse.wav (${vgr.totalMs} ms)');
  stdout.writeln('Wrote vgr_voyager.wav (${voyager.totalMs} ms)');
  stdout.writeln('Wrote vgr_burst.wav (2200 ms)');
}
