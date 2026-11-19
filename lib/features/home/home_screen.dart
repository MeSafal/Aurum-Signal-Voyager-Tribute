import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../widgets/record_watermark.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/section_header.dart';
import '../../widgets/starfield.dart';
import '../intro/intro_controller.dart';
import '../pale_blue_dot/pale_blue_dot_section.dart';
import '../scale/distance_scroll.dart';
import '../scale/light_ladder.dart';
import '../scale/size_lineup.dart';
import 'journey_timeline.dart';
import 'live_distance.dart';
import 'signal_journey.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scaleKey = GlobalKey();
  final GlobalKey _dotKey = GlobalKey();
  int _destination = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position =
        box.localToGlobal(Offset.zero).dy + _scrollController.offset;
    _scrollController.animateTo(
      position - 40,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onDestination(int index) {
    setState(() => _destination = index);
    switch (index) {
      case 0:
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      case 1:
        _scrollTo(_scaleKey);
      case 2:
        _scrollTo(_dotKey);
      case 3:
        context.go('/about');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Starfield(starCount: 90),
          Positioned.fill(
            child: RecordWatermark(scrollController: _scrollController),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroHeader(
                        onReplay: () {
                          ref
                              .read(introControllerProvider.notifier)
                              .resetIntro();
                          context.go('/intro');
                        },
                      ),
                      const SizedBox(height: 56),
                      ScrollReveal(
                        scrollController: _scrollController,
                        child: const LiveDistance(),
                      ),
                      const SizedBox(height: 84),
                      ScrollReveal(
                        scrollController: _scrollController,
                        child: const SignalJourney(),
                      ),
                      const SizedBox(height: 84),
                      JourneyTimeline(scrollController: _scrollController),
                      const SizedBox(height: 84),
                      Container(
                        key: _scaleKey,
                        child: Column(
                          children: [
                            ScrollReveal(
                              scrollController: _scrollController,
                              child: const LightLadder(),
                            ),
                            const SizedBox(height: 72),
                            ScrollReveal(
                              scrollController: _scrollController,
                              child: const DistanceScroll(),
                            ),
                            const SizedBox(height: 72),
                            ScrollReveal(
                              scrollController: _scrollController,
                              child: const SizeLineup(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 84),
                      Container(
                        key: _dotKey,
                        child: ScrollReveal(
                          scrollController: _scrollController,
                          child: const PaleBlueDotSection(),
                        ),
                      ),
                      const SizedBox(height: 84),
                      ScrollReveal(
                        scrollController: _scrollController,
                        child: const AboutTeaser(),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        VoyagerFacts.symbolicNote,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _destination,
        onDestinationSelected: _onDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.straighten_outlined),
            selectedIcon: Icon(Icons.straighten),
            label: 'Scale',
          ),
          NavigationDestination(
            icon: Icon(Icons.brightness_2_outlined),
            selectedIcon: Icon(Icons.brightness_2),
            label: 'Dot',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.onReplay});

  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AURUM SIGNAL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AurumColors.gold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'One light-day',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                VoyagerFacts.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onReplay,
          icon: const Icon(Icons.replay, size: 16),
          label: const Text('REPLAY'),
        ),
      ],
    );
  }
}

class AboutTeaser extends StatelessWidget {
  const AboutTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '06 · About',
          title: 'Credits & settings.',
        ),
        const SizedBox(height: 18),
        Text(
          'Images: NASA/JPL-Caltech. An unofficial fan tribute, not '
          'affiliated with or endorsed by NASA.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () => context.go('/about'),
            style: FilledButton.styleFrom(
              backgroundColor: AurumColors.gold,
              foregroundColor: AurumColors.background,
            ),
            child: const Text('Open about & settings'),
          ),
        ),
      ],
    );
  }
}
