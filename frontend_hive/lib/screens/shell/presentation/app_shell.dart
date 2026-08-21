import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../vitals/presentation/vitals_screen.dart';
import '../../common/presentation/resource_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _index = 0;
  static const _pages = [HomeScreen(), VitalsScreen(), SettingsScreen()];
  static const _titles = ['AfyaHive', 'My vitals', 'Profile & settings'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          if (_index == 0)
            Hero(
              tag: 'afyahive-logo',
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/images/afyahive_logo.png',
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.local_hospital_rounded),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Go home',
              onPressed: () => setState(() => _index = 0),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          const SizedBox(width: 10),
          Text(
            _titles[_index],
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ResourceListScreen(
                title: 'Notifications',
                route: 'reminders',
                emptyMessage: 'You have no active care notifications.',
                icon: Icons.notifications_none_rounded,
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
          tooltip: 'Notifications',
          icon: Badge(child: const Icon(Icons.notifications_none_rounded)),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: IndexedStack(index: _index, children: _pages),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_heart_outlined),
          selectedIcon: Icon(Icons.monitor_heart_rounded),
          label: 'Vitals',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );
}
