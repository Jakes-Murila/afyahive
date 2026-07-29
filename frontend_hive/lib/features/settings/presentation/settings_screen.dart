import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    children: [
      AppCard(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFFFF0D0),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jakes Alvin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Getting healthier, one step at a time',
                    style: TextStyle(color: AppColors.slate, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.slate),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const _SettingsGroup(
        title: 'Care preferences',
        items: [
          const _SettingsItem(
            Icons.notifications_none_rounded,
            'Notifications',
            'Appointments, medicine and wellness alerts',
          ),
          const _SettingsItem(
            Icons.security_outlined,
            'Privacy & security',
            'Data sharing and account protection',
          ),
          const _SettingsItem(
            Icons.language_rounded,
            'Language & region',
            'English - Kenya',
          ),
        ],
      ),
      const SizedBox(height: 20),
      const _SettingsGroup(
        title: 'Support',
        items: [
          const _SettingsItem(
            Icons.help_outline_rounded,
            'Help centre',
            'Find answers and contact support',
          ),
          const _SettingsItem(
            Icons.info_outline_rounded,
            'About AfyaHive',
            'Version 1.0.0',
          ),
        ],
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0xFFFFCDD0)),
        ),
      ),
    ],
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});
  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: AppColors.primary),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                if (index < items.length - 1)
                  const Divider(height: 1, indent: 68),
              ],
            );
          }),
        ),
      ),
    ],
  );
}

class _SettingsItem {
  const _SettingsItem(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}