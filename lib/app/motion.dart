import 'package:flutter/material.dart';

class Motion {
  static const Duration uiShort = Duration(milliseconds: 300);
  static const Duration uiMedium = Duration(milliseconds: 600);
  static const Duration uiLong = Duration(milliseconds: 900);
  static const Duration story = Duration(milliseconds: 2400);
  static const Duration crossfade = Duration(milliseconds: 900);
  static const Curve easing = Curves.easeInOutCubic;
  static const Curve soft = Curves.easeOutCubic;
  static const Duration breathe = Duration(seconds: 4);
  static const int unitMs = 200;
}
