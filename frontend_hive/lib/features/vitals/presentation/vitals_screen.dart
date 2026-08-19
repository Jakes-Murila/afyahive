import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_card.dart';
import '../../../core/ui/primary_button.dart';
import '../../../core/ui/section_header.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});
  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _api = ApiClient();
  String _range = 'Week';
  late Future<List<Vital>> _future;
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Vital>> _load() async {
    final data =
        await _api.get('v1/vitals&range=${_range.toLowerCase()}') as List;
    return data
        .map((e) => Vital.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _refresh() async => setState(() => _future = _load());
  Future<void> _add() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddVital(api: _api),
    );
    if (added == true && mounted) {
      await _refresh();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vital reading saved.')));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Vital>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError)
        return _Error(
          message: snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Unable to load vital readings.',
          onRetry: _refresh,
        );
      final readings = snapshot.data!;
      final latest = <String, Vital>{};
      for (final value in readings) {
        latest.putIfAbsent(value.type, () => value);
      }
      return RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          key: const PageStorageKey('vitals-scroll'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Know your numbers',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Record and follow your health readings.',
                    style: TextStyle(color: AppColors.slate),
                  ),
                  const SizedBox(height: 18),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Week', label: Text('Week')),
                      ButtonSegment(value: 'Month', label: Text('Month')),
                      ButtonSegment(value: 'Year', label: Text('Year')),
                    ],
                    selected: {_range},
                    onSelectionChanged: (value) => setState(() {
                      _range = value.first;
                      _future = _load();
                    }),
                  ),
                  const SizedBox(height: 20),
                  _BloodPressure(
                    reading: latest['blood_pressure'],
                    onAdd: _add,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Latest measurements',
                    actionLabel: 'Add reading',
                    onAction: _add,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.18,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Metric(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFD14C5B),
                        title: 'Heart rate',
                        reading: latest['heart_rate'],
                        unit: 'bpm',
                      ),
                      _Metric(
                        icon: Icons.water_drop_rounded,
                        color: const Color(0xFF337ACC),
                        title: 'Blood oxygen',
                        reading: latest['blood_oxygen'],
                        unit: '% SpO₂',
                      ),
                      _Metric(
                        icon: Icons.thermostat_rounded,
                        color: AppColors.primary,
                        title: 'Temperature',
                        reading: latest['temperature'],
                        unit: '°C',
                      ),
                      _Metric(
                        icon: Icons.monitor_weight_outlined,
                        color: const Color(0xFF6C5CC9),
                        title: 'Weight',
                        reading: latest['weight'],
                        unit: 'kg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Health trend'),
                  const SizedBox(height: 12),
                  _Trend(
                    readings: readings
                        .where((v) => v.type == 'heart_rate')
                        .toList(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class Vital {
  const Vital({
    required this.type,
    required this.value,
    required this.secondary,
    required this.unit,
    required this.at,
  });
  final String type;
  final double value;
  final double? secondary;
  final String unit;
  final DateTime at;
  factory Vital.fromJson(Map<String, dynamic> j) => Vital(
    type: j['type'] as String,
    value: double.parse('${j['value']}'),
    secondary: j['secondary_value'] == null
        ? null
        : double.parse('${j['secondary_value']}'),
    unit: j['unit'] as String,
    at: DateTime.parse('${j['recorded_at']}'),
  );
  String get display => type == 'blood_pressure' && secondary != null
      ? '${_number(value)} / ${_number(secondary!)}'
      : _number(value);
  String get status {
    if (type == 'blood_pressure')
      return value >= 180 || (secondary ?? 0) >= 120 || value < 90
          ? 'Abnormal'
          : value >= 130 || (secondary ?? 0) >= 80
          ? 'Above healthy range'
          : 'Within healthy range';
    if (type == 'heart_rate')
      return value < 60 || value > 100 ? 'Abnormal' : 'Normal';
    if (type == 'blood_oxygen')
      return value < 90
          ? 'Abnormal'
          : value < 95
          ? 'Above healthy range'
          : 'Normal';
    if (type == 'temperature')
      return value < 35 || value >= 38
          ? 'Abnormal'
          : value >= 37.5
          ? 'Above healthy range'
          : 'Normal';
    return 'Recorded';
  }

  Color get color => status == 'Abnormal'
      ? AppColors.danger
      : status == 'Above healthy range'
      ? AppColors.primaryDark
      : AppColors.success;
  static String _number(double n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(1);
}

class _BloodPressure extends StatelessWidget {
  const _BloodPressure({required this.reading, required this.onAdd});
  final Vital? reading;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF193A5D), Color(0xFF286184)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: Color(0xFFFFD87B)),
            SizedBox(width: 8),
            Text(
              'BLOOD PRESSURE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          reading?.display ?? 'No reading',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          reading == null
              ? 'Tap the status below to add a reading'
              : 'mmHg · Last updated ${_ago(reading!.at)}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              reading?.status ?? 'Add blood pressure',
              style: TextStyle(
                color: reading?.color ?? Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.color,
    required this.title,
    required this.reading,
    required this.unit,
  });
  final IconData icon;
  final Color color;
  final String title, unit;
  final Vital? reading;
  @override
  Widget build(BuildContext c) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.slate,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          reading == null
              ? 'No reading'
              : '${reading!.display} ${reading!.unit}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          reading?.status ?? unit,
          style: TextStyle(
            color: reading?.color ?? AppColors.slate,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _Trend extends StatelessWidget {
  const _Trend({required this.readings});
  final List<Vital> readings;
  @override
  Widget build(BuildContext c) {
    final points = readings.reversed.take(7).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heart rate · ${points.length} reading${points.length == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 76,
            child: points.length < 2
                ? const Center(
                    child: Text(
                      'Add two heart-rate readings to view a trend.',
                      style: TextStyle(color: AppColors.slate),
                    ),
                  )
                : CustomPaint(
                    painter: _Painter(points.map((e) => e.value).toList()),
                    child: const SizedBox.expand(),
                  ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earlier',
                style: TextStyle(color: AppColors.slate, fontSize: 11),
              ),
              Text(
                'Latest',
                style: TextStyle(color: AppColors.slate, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Painter extends CustomPainter {
  const _Painter(this.values);
  final List<double> values;
  @override
  void paint(Canvas c, Size s) {
    final min = values.reduce((a, b) => a < b ? a : b),
        max = values.reduce((a, b) => a > b ? a : b),
        delta = max - min == 0 ? 1 : max - min,
        path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = s.width * i / (values.length - 1),
          y = s.height - ((values[i] - min) / delta) * (s.height - 8) - 4;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    c.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD14C5B)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _Painter old) => old.values != values;
}

class _AddVital extends StatefulWidget {
  const _AddVital({required this.api});
  final ApiClient api;
  @override
  State<_AddVital> createState() => _AddVitalState();
}

class _AddVitalState extends State<_AddVital> {
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _second = TextEditingController();
  String _type = 'blood_pressure';
  bool _saving = false;
  @override
  void dispose() {
    _value.dispose();
    _second.dispose();
    super.dispose();
  }

  String get unit => switch (_type) {
    'blood_pressure' => 'mmHg',
    'heart_rate' => 'bpm',
    'blood_oxygen' => '% SpO₂',
    'temperature' => '°C',
    'weight' => 'kg',
    _ => '',
  };
  Future<void> save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.api.post('v1/vitals', {
        'type': _type,
        'value': num.parse(_value.text),
        'secondary_value': _type == 'blood_pressure'
            ? num.parse(_second.text)
            : null,
        'unit': unit,
        'recorded_at': DateTime.now()
            .toUtc()
            .toIso8601String()
            .substring(0, 19)
            .replaceAll('T', ' '),
        'source': 'manual',
      });
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext c) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(c).bottom + 20,
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
                'Add vital reading',
                style: Theme.of(
                  c,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Vital type'),
                items:
                    const [
                          ('blood_pressure', 'Blood pressure'),
                          ('heart_rate', 'Heart rate'),
                          ('blood_oxygen', 'Blood oxygen / SpO₂'),
                          ('temperature', 'Body temperature'),
                          ('weight', 'Weight'),
                        ]
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _type == 'blood_pressure'
                      ? 'Systolic (top number)'
                      : 'Value ($unit)',
                ),
                validator: (v) => v != null && num.tryParse(v) != null
                    ? null
                    : 'Enter a valid number',
              ),
              if (_type == 'blood_pressure') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _second,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Diastolic (bottom number)',
                  ),
                  validator: (v) => v != null && num.tryParse(v) != null
                      ? null
                      : 'Enter a valid number',
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: _saving ? 'Saving...' : 'Save reading',
                onPressed: _saving ? null : save,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _ago(DateTime d) {
  final x = DateTime.now().difference(d.toLocal());
  if (x.inMinutes < 1) return 'just now';
  if (x.inHours < 1) return '${x.inMinutes}m ago';
  if (x.inDays < 1) return '${x.inHours}h ago';
  return '${x.inDays}d ago';
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext c) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
