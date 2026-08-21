import 'package:flutter/material.dart';

import '../src/theme/app_theme.dart';
import '../screens/auth/presentation/auth_gate.dart';

class AfyaHiveApp extends StatelessWidget {
  const AfyaHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfyaHive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
