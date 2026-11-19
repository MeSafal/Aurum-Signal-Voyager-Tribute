import 'dart:convert';

import 'facts.dart';

class _DistancePoint {
  final DateTime time;
  final double km;

  const _DistancePoint(this.time, this.km);
}

class Ephemeris {
  final List<_DistancePoint> _points;
  final String source;
  final String generatedAt;

  Ephemeris._(this._points, this.source, this.generatedAt);

  factory Ephemeris.fromJson(Map<String, dynamic> json) {
    final points = <_DistancePoint>[];
    for (final item in json['points'] as List<dynamic>) {
      final map = item as Map<String, dynamic>;
      points.add(
        _DistancePoint(
          DateTime.parse('${map['date'] as String}T00:00:00Z'),
          (map['km'] as num).toDouble(),
        ),
      );
    }
    if (points.isEmpty) {
      throw const FormatException('Ephemeris contains no points');
    }
    points.sort((a, b) => a.time.compareTo(b.time));
    return Ephemeris._(
      List.unmodifiable(points),
      json['source'] as String? ?? '',
      json['generatedAt'] as String? ?? '',
    );
  }

  factory Ephemeris.fromJsonString(String source) =>
      Ephemeris.fromJson(jsonDecode(source) as Map<String, dynamic>);

  DateTime get firstDate => _points.first.time;
  DateTime get lastDate => _points.last.time;

  double distanceKmAt(DateTime utc) {
    final time = utc.toUtc();
    if (!time.isAfter(_points.first.time)) return _points.first.km;
    if (!time.isBefore(_points.last.time)) return _points.last.km;

    var low = 0;
    var high = _points.length - 1;
    while (high - low > 1) {
      final middle = (low + high) ~/ 2;
      if (_points[middle].time.isAfter(time)) {
        high = middle;
      } else {
        low = middle;
      }
    }
    final left = _points[low];
    final right = _points[high];
    final fraction =
        time.difference(left.time).inMicroseconds /
        right.time.difference(left.time).inMicroseconds;
    return left.km + fraction * (right.km - left.km);
  }

  double oneWayLightSecondsAt(DateTime utc) =>
      VoyagerFacts.lightSecondsForKm(distanceKmAt(utc));

  double auAt(DateTime utc) => VoyagerFacts.auForKm(distanceKmAt(utc));
}
