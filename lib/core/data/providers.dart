import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ephemeris.dart';

final ephemerisProvider = FutureProvider<Ephemeris>((ref) async {
  final json = await rootBundle.loadString('assets/data/v1_distance.json');
  return Ephemeris.fromJsonString(json);
});
