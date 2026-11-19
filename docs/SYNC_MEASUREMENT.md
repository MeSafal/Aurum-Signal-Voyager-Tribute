# Sync measurement

The same `MorseTimeline` instance generates the WAV files, the glyph
animation, haptics and captions. The visual clock starts on the audio player's
`playing` state and adds the stored latency offset.

## Deterministic sample-level check

`dart run tool/measure_sync.dart` synthesises each Morse WAV, detects tone
runs from the PCM samples and compares them with the timeline event
boundaries. A 6 ms envelope allowance is applied to each edge.

Latest result:

```text
VGR:     events=10 detected=10 maxDelta=8.74ms meanDelta=8.68ms
VOYAGER: events=20 detected=20 maxDelta=8.74ms meanDelta=8.71ms
```

Worst-case generated-audio/timeline drift is **8.74 ms**, inside the 40 ms
acceptance target.

## Eye safety

- Unit tests assert no timeline symbol is shorter than 200 ms and no
  consecutive-symbol cycle is faster than 3 Hz. With u = 200 ms the fastest
  rhythm is 2.5 Hz.
- Dot/dash glyphs use 80 ms rise and 120 ms fall envelopes; a dash fills left
  to right. Ripples peak at 15% opacity. The record watermark is at 11%
  opacity and the background luminance is constant.
- Reduce Motion replaces ripples and scaling with opacity only.

## Device measurement

No physical Android device was available in the build environment, so an
on-device audio-output-to-pixel measurement was not taken. The Settings →
Advanced sync slider (−200…+200 ms) is provided for owner-side calibration;
default is 0 ms. Record measured drift here after testing on a handset.
