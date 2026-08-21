import 'package:flutter/material.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/network/api_client.dart';
import '../../../src/ui/app_card.dart';
import '../../auth/data/auth_session_store.dart';
import '../../auth/presentation/login_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    children: [
      AppCard(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
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
      _SettingsGroup(
        title: 'Care preferences',
        items: [
          _SettingsItem(
            Icons.notifications_none_rounded,
            'Notifications',
            'Appointments, medicine and wellness alerts',
            onTap: () => _showNotice(
              context,
              'Notifications',
              'Notifications are managed through your medicine reminders and appointment schedules.',
            ),
          ),
          _SettingsItem(
            Icons.security_outlined,
            'Privacy & security',
            'Data sharing and account protection',
            onTap: () => _showNotice(
              context,
              'Privacy & security',
              'Your session is protected with an access token. Sign out from this device when you are finished.',
            ),
          ),
          _SettingsItem(
            Icons.language_rounded,
            'Language & region',
            'English - Kenya',
            onTap: () => _showNotice(
              context,
              'Language & region',
              'English - Kenya is currently selected.',
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _SettingsGroup(
        title: 'Support',
        items: [
          _SettingsItem(
            Icons.help_outline_rounded,
            'Help centre',
            'Find answers and contact support',
            onTap: () => _showNotice(
              context,
              'Help centre',
              'For local development support, verify Apache and MySQL are running in XAMPP.',
            ),
          ),
          _SettingsItem(
            Icons.info_outline_rounded,
            'About AfyaHive',
            'Version 1.0.0',
            onTap: () => _showNotice(
              context,
              'About AfyaHive',
              'AfyaHive connects your health information, care plans, and wellness tools in one secure place.',
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => _signOut(context),
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

  static void _showNotice(BuildContext context, String title, String message) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
  static Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to access your health information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ApiClient().post('v1/auth/logout', {});
      } catch (_) {
        // Clearing the local token is still required if the network is unavailable.
      }
      await const AuthSessionStore().clear();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }
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
                      color: AppColors.primary.withValues(alpha: .12),
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
                  onTap: item.onTap,
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
  const _SettingsItem(
    this.icon,
    this.title,
    this.subtitle, {
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
