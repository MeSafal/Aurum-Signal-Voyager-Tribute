import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../widgets/starfield.dart';

class GatePart extends StatefulWidget {
  const GatePart({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<GatePart> createState() => _GatePartState();
}

class _GatePartState extends State<GatePart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Starfield(starCount: 70),
        Center(
          child: Semantics(
            button: true,
            label: 'Touch to begin the tribute',
            child: GestureDetector(
              onTap: widget.onStart,
              child: AnimatedBuilder(
                animation: _breath,
                builder: (context, _) {
                  final opacity = 0.6 + 0.4 * _breath.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AurumColors.gold,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AurumColors.goldDark,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Touch to transmit',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AurumColors.goldLight,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A sound-and-light tribute · best with sound on',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: Text(
            'AURUM SIGNAL',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
