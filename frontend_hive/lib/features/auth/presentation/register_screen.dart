import 'package:flutter/material.dart';

import '../../../core/ui/primary_button.dart';
import '../../shell/presentation/app_shell.dart';
import '../data/auth_repository.dart';
import '../data/auth_session_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repository = AuthRepository();
  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final session = await _repository.register(
        firstname: _first.text.trim(),
        lastname: _last.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      await const AuthSessionStore().saveToken(session.accessToken);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join AfyaHive',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Create your secure healthcare account.'),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _first,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'First name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _last,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Last name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    validator: (v) =>
                        v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)
                        ? null
                        : 'Enter a valid email',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v?.length ?? 0) >= 8
                        ? null
                        : 'Use at least 8 characters',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _saving ? 'Creating account...' : 'Create account',
                    onPressed: _saving ? null : _register,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
