import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/ui/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiClient();
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();
  String _gender = 'Other';
  bool _saving = false;
  late Future<Map<String, dynamic>> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final data = Map<String, dynamic>.from(await _api.get('v1/profile') as Map);
    _date.text = '${data['date_of_birth'] ?? ''}';
    _height.text = '${data['height_cm'] ?? ''}';
    _weight.text = '${data['current_weight'] ?? ''}';
    _target.text = '${data['target_weight'] ?? ''}';
    if (['Male', 'Female', 'Other'].contains(data['gender'])) {
      _gender = data['gender'] as String;
    }
    return data;
  }

  @override
  void dispose() {
    _date.dispose();
    _height.dispose();
    _weight.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await _api.patch('v1/profile', {
        'gender': _gender,
        'date_of_birth': _date.text.trim(),
        'height_cm': num.parse(_height.text),
        'current_weight': num.parse(_weight.text),
        'target_weight': num.parse(_target.text),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Account details')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => _profile = _load()),
              child: const Text('Unable to load profile. Try again'),
            ),
          );
        }
        final data = snapshot.data!;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['firstname']} ${data['lastname']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${data['email']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const ['Male', 'Female', 'Other']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                  const SizedBox(height: 14),
                  _field(_date, 'Date of birth (YYYY-MM-DD)'),
                  const SizedBox(height: 14),
                  _field(_height, 'Height (cm)'),
                  const SizedBox(height: 14),
                  _field(_weight, 'Current weight (kg)'),
                  const SizedBox(height: 14),
                  _field(_target, 'Target weight (kg)'),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _saving ? 'Saving...' : 'Save changes',
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  Widget _field(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: label.startsWith('Date')
            ? TextInputType.datetime
            : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? '$label is required' : null,
      );
}
