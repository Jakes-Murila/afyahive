import 'package:flutter/material.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/ui/primary_button.dart';
import '../data/auth_repository.dart';
import '../data/auth_session_store.dart';
import 'register_screen.dart';
import '../../shell/presentation/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = true;
  bool _isSubmitting = false;
  final _authRepository = AuthRepository();
  final _sessionStore = const AuthSessionStore();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final session = await _authRepository.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (_rememberMe) await _sessionStore.saveToken(session.accessToken);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'afyahive-logo',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: .15,
                              ),
                              child: Image.asset(
                                'assets/images/afyahive_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'AfyaHive',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                            ),

                            Text(
                              'Healthcare Platform',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Your health,\nall in one place.',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Welcome back to AfyaHive. Continue your care journey securely.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color.fromARGB(255, 55, 61, 173),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }

                          if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }

                          return null;
                        },
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Password recovery'),
                                content: const Text(
                                  'Password recovery has not been configured for this local development server. Please contact your AfyaHive administrator.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      PrimaryButton(
                        label: _isSubmitting
                            ? 'Signing in...'
                            : 'Secure Sign In',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _isSubmitting ? null : _login,
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                          child: const Text(
                            'New to AfyaHive? Create an account',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
