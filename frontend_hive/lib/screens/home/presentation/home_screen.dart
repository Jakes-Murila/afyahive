import 'package:flutter/material.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/ui/app_card.dart';
import '../../../src/ui/section_header.dart';
import '../../common/presentation/service_catalog.dart';
import '../../common/presentation/resource_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _services = [
    (Icons.calendar_month_outlined, 'Book an\nappointment', Color(0xFFEAF8F2)),
    (Icons.medication_outlined, 'Medicine\nreminders', Color(0xFFFFF7DE)),
    (Icons.video_camera_front_outlined, 'Telemedicine', Color(0xFFF0ECFF)),
    (Icons.folder_shared_outlined, 'Medical\nrecords', Color(0xFFEAF5F7)),
    (Icons.groups_2_outlined, 'Health\ncommunity', Color(0xFFFFEDF5)),
    (Icons.emergency_outlined, 'Emergency\ncontacts', Color(0xFFFFEDEC)),
  ];

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('home-scroll'),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Text(
              'Good morning, Jakes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'A clearer view of your wellbeing today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color.fromARGB(255, 52, 96, 173),
              ),
            ),
            const SizedBox(height: 20),
            _HealthScoreCard(),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Care at your fingertips',
              actionLabel: 'See all',
              onAction: () =>
                  ServiceCatalog.open(context, 'Fitness integration'),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 10,
            childAspectRatio: .72,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final service = _services[index];
            return Semantics(
              button: true,
              label: service.$2.replaceAll('\n', ' '),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ServiceCatalog.open(
                  context,
                  service.$2.replaceAll('\n', ' '),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: service.$3,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(service.$1, color: AppColors.navy),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      service.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }, childCount: _services.length),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const SectionHeader(title: "Today's care plan"),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ResourceListScreen(
                    title: 'Medicine reminders',
                    route: 'reminders',
                    emptyMessage: 'No medicine reminders yet.',
                    icon: Icons.medication_outlined,
                    fields: [
                      ResourceField(
                        'medication_name',
                        'Medicine name',
                        required: true,
                      ),
                      ResourceField(
                        'schedule_time',
                        'Time (HH:MM:SS)',
                        required: true,
                      ),
                      ResourceField(
                        'frequency',
                        'Frequency',
                        kind: InputKind.select,
                        options: ['daily', 'weekly', 'as_needed'],
                      ),
                    ],
                  ),
                ),
              ),
              child: Column(
                children: [
                  _CarePlanRow(
                    icon: Icons.medication_outlined,
                    color: const Color.fromARGB(255, 224, 185, 185),
                    title: 'Medication reminder',
                    subtitle: 'Medicine to be taken',
                    trailing: 'Pending',
                  ),
                  const Divider(height: 24),
                  _CarePlanRow(
                    icon: Icons.event_available_outlined,
                    color: const Color.fromARGB(255, 153, 233, 206),
                    title: 'Medical appointment',
                    subtitle: 'Routine consultation',
                    trailing: 'Confirmed',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Wellness insights'),
            const SizedBox(height: 12),
            const _InsightCard(),
          ]),
        ),
      ),
    ],
  );
}

class _HealthScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.navy, Color(0xFF235B79)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        SizedBox(
          height: 92,
          width: 92,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: .82,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '82',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 27,
                      ),
                    ),
                    Text(
                      'score',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your health snapshot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "You're doing well. One habit needs attention today.",
                style: TextStyle(color: Colors.white70, height: 1.35),
              ),
              SizedBox(height: 10),
              Text(
                'VIEW INSIGHTS',
                style: TextStyle(
                  color: Color(0xFFFFD87B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CarePlanRow extends StatelessWidget {
  const _CarePlanRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.slate),
            ),
          ],
        ),
      ),
      Text(
        trailing,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();
  @override
  Widget build(BuildContext context) => AppCard(
    color: const Color(0xFFFFFBED),
    child: Row(
      children: [
        const Icon(
          Icons.lightbulb_outline_rounded,
          color: AppColors.primary,
          size: 30,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'A short evening walk can help you reach your activity goal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}
