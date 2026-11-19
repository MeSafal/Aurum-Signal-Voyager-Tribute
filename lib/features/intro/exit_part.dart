import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class ExitPart extends StatefulWidget {
  const ExitPart({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<ExitPart> createState() => _ExitPartState();
}

class _ExitPartState extends State<ExitPart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Center(
            child: Transform.scale(
              scale: 0.72 + 0.28 * t,
              child: Transform.rotate(
                angle: (1 - t) * -0.6,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/golden_record_front.jpg',
                    width: 320,
                    height: 320,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 320,
                      height: 320,
                      decoration: const BoxDecoration(
                        color: AurumColors.goldDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
