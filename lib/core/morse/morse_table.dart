const Map<String, String> morseCodes = {
  'A': '.-',
  'B': '-...',
  'C': '-.-.',
  'D': '-..',
  'E': '.',
  'F': '..-.',
  'G': '--.',
  'H': '....',
  'I': '..',
  'J': '.---',
  'K': '-.-',
  'L': '.-..',
  'M': '--',
  'N': '-.',
  'O': '---',
  'P': '.--.',
  'Q': '--.-',
  'R': '.-.',
  'S': '...',
  'T': '-',
  'U': '..-',
  'V': '...-',
  'W': '.--',
  'X': '-..-',
  'Y': '-.--',
  'Z': '--..',
};

String morseFor(String letter) => morseCodes[letter.toUpperCase()] ?? '';

String describeMorse(String letter) => morseFor(letter)
    .split('')
    .map((symbol) {
      return symbol == '.' ? 'dot' : 'dash';
    })
    .join(' ');
