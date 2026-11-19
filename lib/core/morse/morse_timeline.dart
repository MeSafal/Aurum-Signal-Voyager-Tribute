import 'morse_table.dart';

enum MorseSymbol { dot, dash }

class MorseEvent {
  final int startMs;
  final int endMs;
  final int letterIndex;
  final int symbolIndex;
  final int wordIndex;
  final String letter;
  final MorseSymbol symbol;

  const MorseEvent({
    required this.startMs,
    required this.endMs,
    required this.letterIndex,
    required this.symbolIndex,
    required this.wordIndex,
    required this.letter,
    required this.symbol,
  });

  int get durationMs => endMs - startMs;

  @override
  String toString() => '$letter:${symbol.name}@$startMs-$endMs';
}

class MorseSpan {
  final int index;
  final String text;
  final int startMs;
  final int endMs;

  const MorseSpan({
    required this.index,
    required this.text,
    required this.startMs,
    required this.endMs,
  });
}

class MorseTimeline {
  final String text;
  final int unitMs;
  final int trailingMs;
  final List<MorseEvent> events;
  final List<MorseSpan> letters;
  final List<MorseSpan> words;
  final int totalMs;

  MorseTimeline._({
    required this.text,
    required this.unitMs,
    required this.trailingMs,
    required this.events,
    required this.letters,
    required this.words,
    required this.totalMs,
  });

  factory MorseTimeline({
    required String text,
    int unitMs = 200,
    int trailingMs = 0,
    Map<String, String> codes = morseCodes,
  }) {
    final normalized = text.toUpperCase();
    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final allEvents = <MorseEvent>[];
    final letterSpans = <MorseSpan>[];
    final wordSpans = <MorseSpan>[];
    var cursor = 0;
    var letterIndex = 0;

    for (var wordIndex = 0; wordIndex < tokens.length; wordIndex++) {
      final word = tokens[wordIndex];
      final wordStart = cursor;

      for (
        var wordLetterIndex = 0;
        wordLetterIndex < word.length;
        wordLetterIndex++
      ) {
        final letter = word[wordLetterIndex];
        final code = codes[letter] ?? '';
        final letterStart = cursor;

        for (var symbolIndex = 0; symbolIndex < code.length; symbolIndex++) {
          final isDash = code[symbolIndex] == '-';
          final duration = isDash ? 3 * unitMs : unitMs;
          allEvents.add(
            MorseEvent(
              startMs: cursor,
              endMs: cursor + duration,
              letterIndex: letterIndex,
              symbolIndex: symbolIndex,
              wordIndex: wordIndex,
              letter: letter,
              symbol: isDash ? MorseSymbol.dash : MorseSymbol.dot,
            ),
          );
          cursor += duration;
          if (symbolIndex < code.length - 1) {
            cursor += unitMs;
          }
        }

        letterSpans.add(
          MorseSpan(
            index: letterIndex,
            text: letter,
            startMs: letterStart,
            endMs: cursor,
          ),
        );
        letterIndex++;
        if (wordLetterIndex < word.length - 1) {
          cursor += 3 * unitMs;
        }
      }

      wordSpans.add(
        MorseSpan(
          index: wordIndex,
          text: word,
          startMs: wordStart,
          endMs: cursor,
        ),
      );
      if (wordIndex < tokens.length - 1) {
        cursor += 7 * unitMs;
      }
    }

    return MorseTimeline._(
      text: normalized,
      unitMs: unitMs,
      trailingMs: trailingMs,
      events: List.unmodifiable(allEvents),
      letters: List.unmodifiable(letterSpans),
      words: List.unmodifiable(wordSpans),
      totalMs: cursor + trailingMs,
    );
  }

  int get totalUnits => (totalMs / unitMs).round();

  List<MorseEvent> eventsForLetter(int index) =>
      events.where((event) => event.letterIndex == index).toList();

  MorseEvent? eventAt(int milliseconds) {
    for (final event in events) {
      if (milliseconds >= event.startMs && milliseconds < event.endMs) {
        return event;
      }
    }
    return null;
  }

  MorseSpan? letterAt(int milliseconds) {
    for (final span in letters) {
      if (milliseconds >= span.startMs && milliseconds < span.endMs) {
        return span;
      }
    }
    return null;
  }
}

int morseDurationUnits(String text, {int trailingUnits = 0}) =>
    MorseTimeline(text: text, trailingMs: trailingUnits * 200).totalUnits;
