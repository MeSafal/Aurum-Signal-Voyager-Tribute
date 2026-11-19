import 'package:flutter/material.dart';

import '../app/theme.dart';

class RecordWatermark extends StatefulWidget {
  const RecordWatermark({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<RecordWatermark> createState() => _RecordWatermarkState();
}

class _RecordWatermarkState extends State<RecordWatermark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.scrollController, _idle]),
          builder: (context, _) {
            final size = MediaQuery.sizeOf(context);
            final diameter = size.shortestSide * 1.05;
            final turns =
                (widget.scrollController.offset / 2600 + _idle.value * 0.12) /
                (2 * 3.141592653589793);
            return Center(
              child: Opacity(
                opacity: 0.11,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(turns),
                  child: SizedBox.square(
                    dimension: diameter,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/golden_record_front.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => CustomPaint(
                          painter: const _VectorRecordPainter(),
                          size: Size.square(diameter),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VectorRecordPainter extends CustomPainter {
  const _VectorRecordPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF0C0F20));
    for (var i = 1; i <= 9; i++) {
      canvas.drawCircle(
        center,
        radius * (1 - i * 0.085),
        Paint()
          ..color = AurumColors.gold.withValues(alpha: i.isEven ? 0.25 : 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i % 3 == 0 ? 3 : 1.5,
      );
    }
    canvas.drawCircle(center, radius * 0.22, Paint()..color = AurumColors.gold);
  }

  @override
  bool shouldRepaint(covariant _VectorRecordPainter oldDelegate) => false;
}
