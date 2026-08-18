import 'package:flutter/material.dart';

import '../../shell/presentation/app_shell.dart';
import '../data/auth_session_store.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _sessionStore = const AuthSessionStore();
  late final Future<String?> _token = _sessionStore.readToken();

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _token,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return snapshot.data == null || snapshot.data!.isEmpty
          ? const LoginScreen()
          : const AppShell();
    },
  );
}
