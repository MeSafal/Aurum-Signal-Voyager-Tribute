import 'package:flutter_test/flutter_test.dart';
import 'package:aurum_signal/core/morse/morse_timeline.dart';

double _fastestCycle(MorseTimeline timeline) {
  var fastest = 0.0;
  for (var i = 1; i < timeline.events.length; i++) {
    final previous = timeline.events[i - 1];
    final current = timeline.events[i];
    final periodSeconds = (current.startMs - previous.startMs) / 1000;
    if (periodSeconds > 0) {
      fastest = fastest > 1 / periodSeconds ? fastest : 1 / periodSeconds;
    }
  }
  return fastest;
}

void main() {
  test('VGR is 31 units and 6.2 seconds', () {
    final timeline = MorseTimeline(text: 'VGR');
    expect(timeline.totalUnits, 31);
    expect(timeline.totalMs, 6200);
    expect(timeline.letters.map((letter) => letter.text).join(), 'VGR');
  });

  test('VOYAGER is 73 units and 14.6 seconds', () {
    final timeline = MorseTimeline(text: 'VOYAGER');
    expect(timeline.totalUnits, 73);
    expect(timeline.totalMs, 14600);
    expect(timeline.letters.map((letter) => letter.text).join(), 'VOYAGER');
    expect(timeline.events.length, 20);
  });

  test('word boundaries are recorded', () {
    final timeline = MorseTimeline(text: 'VGR VOYAGER');
    expect(timeline.words.map((word) => word.text).toList(), [
      'VGR',
      'VOYAGER',
    ]);
    expect(timeline.events.first.wordIndex, 0);
    expect(timeline.events.last.wordIndex, 1);
  });

  test('no timeline cycles faster than 3 Hz', () {
    for (final text in ['VGR', 'VOYAGER', 'VGR VOYAGER', 'EEEE EEEE']) {
      final timeline = MorseTimeline(text: text);
      for (final event in timeline.events) {
        expect(event.durationMs, greaterThanOrEqualTo(200));
      }
      expect(_fastestCycle(timeline), lessThanOrEqualTo(3));
    }
  });

  test('eventAt resolves the active symbol', () {
    final timeline = MorseTimeline(text: 'VGR');
    final first = timeline.events.first;
    expect(timeline.eventAt(first.startMs), same(first));
    expect(timeline.eventAt(first.endMs), isNot(same(first)));
    expect(timeline.letterAt(first.startMs)?.text, 'V');
  });
}
