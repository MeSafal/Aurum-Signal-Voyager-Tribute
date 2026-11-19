import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/data/facts.dart';
import '../../widgets/section_header.dart';
import '../../widgets/scroll_reveal.dart';

class _Milestone {
  const _Milestone({
    required this.date,
    required this.title,
    required this.body,
    this.image,
  });

  final String date;
  final String title;
  final String body;
  final String? image;
}

const List<_Milestone> _milestones = [
  _Milestone(
    date: VoyagerFacts.launchDate,
    title: 'Launch',
    body:
        'Voyager 1 leaves Earth on a Titan IIIE-Centaur, beginning a '
        'grand tour of the outer planets.',
    image: 'assets/images/family_portrait.jpg',
  ),
  _Milestone(
    date: VoyagerFacts.jupiterDate,
    title: 'Jupiter',
    body:
        'Close flyby, new images of the giant planet and its moons, and a '
        'gravity assist toward Saturn.',
    image: 'assets/images/jupiter_v1.jpg',
  ),
  _Milestone(
    date: VoyagerFacts.saturnDate,
    title: 'Saturn',
    body:
        'A pass about ${VoyagerFacts.saturnDistance} above the cloud tops, '
        'then a trajectory out of the ecliptic.',
    image: 'assets/images/saturn_v1.jpg',
  ),
  _Milestone(
    date: VoyagerFacts.paleBlueDotDate,
    title: 'Pale Blue Dot',
    body:
        'From about ${VoyagerFacts.paleBlueDotDistance}, the camera turns '
        'back for one last portrait before being switched off.',
    image: 'assets/images/pale_blue_dot_1990.jpg',
  ),
  _Milestone(
    date: VoyagerFacts.heliopauseDate,
    title: 'Heliopause',
    body:
        'Plasma-wave measurements mark the crossing into interstellar '
        'space.',
  ),
  _Milestone(
    date: '18 November 2026',
    title: 'One light-day',
    body:
        'A symbolic distance marker: one full day of radio travel from '
        'Earth.',
  ),
];

class JourneyTimeline extends StatelessWidget {
  const JourneyTimeline({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: '03 · The journey',
          title: 'Nearly fifty years out.',
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < _milestones.length; i++)
          ScrollReveal(
            scrollController: scrollController,
            delay: Duration(milliseconds: i * 70),
            child: _MilestoneCard(
              milestone: _milestones[i],
              isLast: i == _milestones.length - 1,
            ),
          ),
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.milestone, required this.isLast});

  final _Milestone milestone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Column(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AurumColors.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AurumColors.gold.withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 150,
                  color: AurumColors.gold.withValues(alpha: 0.18),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.date.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AurumColors.gold),
                ),
                const SizedBox(height: 8),
                Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  milestone.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (milestone.image != null) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      milestone.image!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
