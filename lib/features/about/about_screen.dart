import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../core/data/sources.dart';
import '../../core/settings/settings_provider.dart';
import '../../core/torch/torch_service.dart';
import '../intro/intro_controller.dart';
import '../../widgets/section_header.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About & settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    VoyagerFacts.appName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    VoyagerFacts.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(introControllerProvider.notifier).resetIntro();
                      context.go('/intro');
                    },
                    icon: const Icon(Icons.replay, size: 16),
                    label: const Text('Replay the tribute'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AurumColors.gold,
                      foregroundColor: AurumColors.background,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const SectionHeader(
                    eyebrow: 'Preferences',
                    title: 'Make it yours.',
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Sound'),
                    subtitle: const Text('Morse tones and the low burst'),
                    value: settings.soundOn,
                    onChanged: notifier.setSound,
                  ),
                  SwitchListTile(
                    title: const Text('Haptics'),
                    subtitle: const Text('Gentle taps in sync with the Morse'),
                    value: settings.hapticsOn,
                    onChanged: notifier.setHaptics,
                  ),
                  const _TorchSwitch(),
                  SwitchListTile(
                    title: const Text('Reduce motion'),
                    subtitle: const Text(
                      'Fades instead of ripples and scaling',
                    ),
                    value:
                        settings.reduceMotion ||
                        MediaQuery.of(context).disableAnimations,
                    onChanged: MediaQuery.of(context).disableAnimations
                        ? null
                        : notifier.setReduceMotion,
                  ),
                  const SizedBox(height: 12),
                  ExpansionTile(
                    title: Text(
                      'Advanced sync',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'Audio latency offset: ${settings.latencyOffsetMs} ms',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Slider(
                          value: settings.latencyOffsetMs.toDouble(),
                          min: -200,
                          max: 200,
                          divisions: 40,
                          label: '${settings.latencyOffsetMs} ms',
                          onChanged: (value) =>
                              notifier.setLatencyOffsetMs(value.round()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Text(
                          'If glyphs feel early or late against the tone, '
                          'nudge this value.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const SectionHeader(
                    eyebrow: 'The mission',
                    title: 'What is Voyager?',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Voyager 1 and Voyager 2 were launched in 1977 to explore '
                    'Jupiter, Saturn and the outer solar system. Both kept '
                    'travelling after their planetary encounters. Voyager 1 '
                    'entered interstellar space in 2012 and still returns '
                    'measurements from far beyond the planets.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  _Link(
                    label: 'NASA · Voyager mission overview',
                    url:
                        'https://science.nasa.gov/mission/voyager/mission-overview/',
                  ),
                  _Link(
                    label: 'NASA · The Voyager mission',
                    url: 'https://science.nasa.gov/mission/voyager/',
                  ),
                  const SizedBox(height: 44),
                  const SectionHeader(
                    eyebrow: 'The distance',
                    title: 'What is one light-day?',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Light travels about 25.9 billion kilometres in a day. '
                    'When Voyager 1 is one light-day away, a radio signal '
                    'sent from Earth takes a full 24 hours to reach it — and '
                    'another 24 hours for a reply to come back.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  _Link(
                    label: 'NASA · What is a light-day?',
                    url:
                        'https://science.nasa.gov/mission/voyager/voyager-1/voyager-1-what-is-a-light-day/',
                  ),
                  const SizedBox(height: 44),
                  const SectionHeader(
                    eyebrow: 'Why this app',
                    title: 'A tribute, not a tracking site.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aurum Signal marks Voyager 1 reaching one light-day on '
                    '18 November 2026, and NASA’s “Shine Bright for '
                    'Voyager’s Light-Day” event. The milestone is symbolic: '
                    'nothing changes aboard the spacecraft that day. We '
                    'simply pause to notice how far a human-made object has '
                    'gone.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                          text:
                              'Media ownership, non-affiliation and '
                              'copyright claims are described in the ',
                        ),
                        TextSpan(
                          text: 'Disclaimer & credits',
                          style: const TextStyle(
                            color: AurumColors.gold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.go('/disclaimer'),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Link(
                    label: 'GitHub repository',
                    url: VoyagerFacts.repositoryUrl,
                  ),
                  const SizedBox(height: 48),
                  const SectionHeader(
                    eyebrow: 'Sources',
                    title: 'Read the originals.',
                  ),
                  const SizedBox(height: 12),
                  for (final source in kSourceLinks)
                    _Link(label: source.label, url: source.url),
                  const SizedBox(height: 32),
                  Text(
                    'Crossing one light-day changes nothing about the '
                    'spacecraft. It is a marker we choose to notice.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TorchSwitch extends ConsumerStatefulWidget {
  const _TorchSwitch();

  @override
  ConsumerState<_TorchSwitch> createState() => _TorchSwitchState();
}

class _TorchSwitchState extends ConsumerState<_TorchSwitch> {
  late final Future<bool> _available;

  @override
  void initState() {
    super.initState();
    _available = ref.read(torchServiceProvider).available;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return FutureBuilder<bool>(
      future: _available,
      builder: (context, snapshot) {
        final available = snapshot.data ?? false;
        return SwitchListTile(
          title: const Text('Phone torch'),
          subtitle: Text(
            available
                ? 'Blinks in the same Morse pattern'
                : 'No torch available on this device',
          ),
          value: settings.torchOn && available,
          onChanged: available
              ? (value) => ref.read(settingsProvider.notifier).setTorch(value)
              : null,
        );
      },
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: _open,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AurumColors.goldLight),
              ),
            ),
            const Icon(Icons.open_in_new, size: 15, color: AurumColors.gold),
          ],
        ),
      ),
    );
  }
}
