import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_card.dart';
import '../../../core/ui/primary_button.dart';

enum InputKind { text, number, select, multiline, toggle }

class ResourceField {
  const ResourceField(
    this.key,
    this.label, {
    this.kind = InputKind.text,
    this.required = false,
    this.options = const [],
  });
  final String key;
  final String label;
  final InputKind kind;
  final bool required;
  final List<String> options;
}

class ResourceListScreen extends StatefulWidget {
  const ResourceListScreen({
    super.key,
    required this.title,
    required this.route,
    required this.fields,
    required this.emptyMessage,
    this.icon = Icons.health_and_safety_outlined,
  });
  final String title;
  final String route;
  final List<ResourceField> fields;
  final String emptyMessage;
  final IconData icon;
  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  final _api = ApiClient();
  late Future<List<Map<String, dynamic>>> _items;
  @override
  void initState() {
    super.initState();
    _items = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async =>
      List<Map<String, dynamic>>.from(
        await _api.get('v1/${widget.route}') as List,
      );
  Future<void> _refresh() async {
    setState(() => _items = _load());
  }

  Future<void> _create() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateSheet(
        title: widget.title,
        fields: widget.fields,
        api: _api,
        route: widget.route,
      ),
    );
    if (!mounted || created != true) return;
    await _refresh();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved successfully.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Error(message: _error(snapshot.error), onRetry: _refresh);
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return _Empty(
            icon: widget.icon,
            message: widget.emptyMessage,
            onAdd: _create,
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _Card(
              item: items[index],
              onDelete: () async {
                await _api.delete('v1/${widget.route}/${items[index]['id']}');
                if (!mounted) return;
                await _refresh();
                if (mounted) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(const SnackBar(content: Text('Deleted.')));
                }
              },
            ),
          ),
        );
      },
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.item, required this.onDelete});
  final Map<String, dynamic> item;
  final Future<void> Function() onDelete;
  @override
  Widget build(BuildContext context) {
    final title =
        item['medication_name'] ??
        item['provider_name'] ??
        item['workout_name'] ??
        item['goal_type'] ??
        item['name'] ??
        item['title'] ??
        item['body'] ??
        item['activity_type'] ??
        'AfyaHive item';
    final detail = item.entries
        .where(
          (e) => ![
            'id',
            'user_id',
            'created_at',
            'updated_at',
            'title',
            'body',
          ].contains(e.key),
        )
        .take(2)
        .map((e) => '${e.key.replaceAll('_', ' ')}: ${e.value}')
        .join('\n');
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete item?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) await onDelete();
            },
          ),
        ],
      ),
    );
  }
}

class _CreateSheet extends StatefulWidget {
  const _CreateSheet({
    required this.title,
    required this.fields,
    required this.api,
    required this.route,
  });
  final String title;
  final List<ResourceField> fields;
  final ApiClient api;
  final String route;
  @override
  State<_CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<_CreateSheet> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _values = <String, dynamic>{};
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.key] = TextEditingController();
      if (field.kind == InputKind.select) {
        _values[field.key] = field.options.first;
      }
      if (field.kind == InputKind.toggle) _values[field.key] = true;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{};
      for (final field in widget.fields) {
        if (field.kind == InputKind.select || field.kind == InputKind.toggle) {
          body[field.key] = _values[field.key];
        } else {
          final text = _controllers[field.key]!.text.trim();
          if (text.isNotEmpty) {
            body[field.key] = field.kind == InputKind.number
                ? num.parse(text)
                : text;
          }
        }
      }
      await widget.api.post('v1/${widget.route}', body);
      if (mounted) Navigator.pop(context, true);
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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add ${widget.title}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ...widget.fields.map(_field),
              const SizedBox(height: 12),
              PrimaryButton(
                label: _saving ? 'Saving...' : 'Save',
                onPressed: _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _field(ResourceField field) {
    if (field.kind == InputKind.select) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: _values[field.key] as String,
          decoration: InputDecoration(labelText: field.label),
          items: field.options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) => setState(() => _values[field.key] = value),
        ),
      );
    }
    if (field.kind == InputKind.toggle) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label),
        value: _values[field.key] as bool,
        onChanged: (value) => setState(() => _values[field.key] = value),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controllers[field.key],
        keyboardType: field.kind == InputKind.number
            ? const TextInputType.numberWithOptions(decimal: true)
            : field.kind == InputKind.multiline
            ? TextInputType.multiline
            : null,
        maxLines: field.kind == InputKind.multiline ? 3 : 1,
        decoration: InputDecoration(labelText: field.label),
        validator: field.required
            ? (value) => value == null || value.trim().isEmpty
                  ? '${field.label} is required'
                  : null
            : null,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.message,
    required this.onAdd,
  });
  final IconData icon;
  final String message;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add now'),
          ),
        ],
      ),
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

String _error(Object? error) =>
    error is ApiException ? error.message : 'Unable to load data.';
