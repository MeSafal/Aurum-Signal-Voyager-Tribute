import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:voyger/core/data/ephemeris.dart';
import 'package:voyger/core/data/facts.dart';

void main() {
  late Ephemeris ephemeris;

  setUpAll(() {
    final json = File('assets/data/v1_distance.json').readAsStringSync();
    ephemeris = Ephemeris.fromJsonString(json);
  });

  test('milestone distance is within 0.05 percent of NASA figure', () {
    final distance = ephemeris.distanceKmAt(VoyagerFacts.milestoneUtc);
    final error =
        (distance - VoyagerFacts.milestoneKm).abs() / VoyagerFacts.milestoneKm;
    expect(error, lessThan(0.0005), reason: 'distance=$distance');
  });

  test('interpolates between daily samples', () {
    final start = ephemeris.firstDate.add(const Duration(days: 10));
    final middle = start.add(const Duration(hours: 12));
    final end = start.add(const Duration(days: 1));
    final left = ephemeris.distanceKmAt(start);
    final center = ephemeris.distanceKmAt(middle);
    final right = ephemeris.distanceKmAt(end);
    expect(center, closeTo((left + right) / 2, 5));
  });

  test('173.14 AU is about 24 hours of light time', () {
    final minutes = VoyagerFacts.lightMinutesForAu(VoyagerFacts.milestoneAu);
    expect(minutes / 60, closeTo(24, 0.01));
  });

  test('AU conversion round-trips the milestone', () {
    expect(
      VoyagerFacts.auForKm(VoyagerFacts.milestoneKm),
      closeTo(VoyagerFacts.milestoneAu, 0.02),
    );
  });
}
