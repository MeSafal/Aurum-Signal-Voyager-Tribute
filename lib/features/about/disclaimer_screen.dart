import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disclaimer & credits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/about'),
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
                    'Not ours. Not NASA.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 24),
                  _Block(
                    title: 'Media ownership',
                    body:
                        'Every photograph and the Voyager 3D model bundled '
                        'with this app comes from publicly available NASA and '
                        'JPL-Caltech material. Those assets are not ours and '
                        'we claim no copyright over them. All rights remain '
                        'with their respective owners.',
                  ),
                  _Block(
                    title: 'No affiliation',
                    body:
                        'Aurum Signal is an unofficial fan tribute. It is not '
                        'affiliated with, endorsed by, or sponsored by NASA '
                        'or JPL. No NASA logos, insignia, or official marks '
                        'are used.',
                  ),
                  _Block(
                    title: 'Code and fonts',
                    body:
                        'The application code is released under the MIT '
                        'licence. The bundled Cormorant Garamond and '
                        'JetBrains Mono fonts are licensed under the SIL Open '
                        'Font License 1.1; copies are in docs/.',
                  ),
                  _Block(
                    title: 'Copyright concerns',
                    body:
                        'If you believe any material here belongs to you, or '
                        'have any copyright-related concern, write to '
                        'subedigokul119@gmail.com. We will review the request '
                        'and take appropriate action.',
                  ),
                  const SizedBox(height: 16),
                  _Link(
                    label: 'Voyager 3D model source (NASA)',
                    url: 'https://science.nasa.gov/resource/voyager-3d-model/',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Inspired by NASA’s “Shine Bright for Voyager’s '
                    'Light-Day.”',
                    style: Theme.of(context).textTheme.bodySmall,
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

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }
}
