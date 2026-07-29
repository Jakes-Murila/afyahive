import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_card.dart';
import '../../../core/ui/section_header.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});
  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  var _range = 'Week';
  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('vitals-scroll'),
    slivers: [SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      sliver: SliverList(delegate: SliverChildListDelegate([
        Text('Know your numbers', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Trends from your connected health devices', style: TextStyle(color: AppColors.slate)),
        const SizedBox(height: 18),
        SegmentedButton<String>(segments: const [ButtonSegment(value: 'Week', label: Text('Week')), ButtonSegment(value: 'Month', label: Text('Month')), ButtonSegment(value: 'Year', label: Text('Year'))], selected: {_range}, onSelectionChanged: (value) => setState(() => _range = value.first)),
        const SizedBox(height: 20),
        const _BloodPressureCard(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Latest measurements'),
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 2, childAspectRatio: 1.25, crossAxisSpacing: 12, mainAxisSpacing: 12, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: const [
          _VitalMetric(icon: Icons.favorite_rounded, color: Color(0xFFD14C5B), title: 'Heart rate', value: '72', unit: 'bpm', status: 'Normal'),
          _VitalMetric(icon: Icons.water_drop_rounded, color: Color(0xFF337ACC), title: 'Blood oxygen', value: '98', unit: '% SpO₂', status: 'Excellent'),
          _VitalMetric(icon: Icons.thermostat_rounded, color: AppColors.primary, title: 'Temperature', value: '36.8', unit: '°C', status: 'Normal'),
          _VitalMetric(icon: Icons.monitor_weight_outlined, color: Color(0xFF6C5CC9), title: 'Weight', value: '70.5', unit: 'kg', status: 'Stable'),
        ]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Health trend'),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Heart rate · last 7 days', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 18), SizedBox(height: 76, child: CustomPaint(painter: _TrendPainter(color: AppColors.danger), child: const SizedBox.expand())), const SizedBox(height: 6), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Mon', style: TextStyle(color: AppColors.slate, fontSize: 11)), Text('Today', style: TextStyle(color: AppColors.slate, fontSize: 11))])])),
      ])),
    )],
  );
}

class _BloodPressureCard extends StatelessWidget {
  const _BloodPressureCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF193A5D), Color(0xFF286184)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.monitor_heart_outlined, color: Color(0xFFFFD87B)), SizedBox(width: 8), Text('BLOOD PRESSURE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1))]), const SizedBox(height: 14), const Text('118 / 76', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)), const Text('mmHg · Last updated today at 8:42 AM', style: TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 16), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: const Text('Within your healthy range', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)))]));
}

class _VitalMetric extends StatelessWidget {
  const _VitalMetric({required this.icon, required this.color, required this.title, required this.value, required this.unit, required this.status});
  final IconData icon; final Color color; final String title; final String value; final String unit; final String status;
  @override
  Widget build(BuildContext context) => AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const Spacer(), Text(title, style: const TextStyle(fontSize: 12, color: AppColors.slate, fontWeight: FontWeight.w600)), const SizedBox(height: 3), RichText(text: TextSpan(style: DefaultTextStyle.of(context).style, children: [TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)), TextSpan(text: ' $unit', style: const TextStyle(fontSize: 11, color: AppColors.slate))])), const SizedBox(height: 4), Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))]));
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.color}); final Color color;
  @override
  void paint(Canvas canvas, Size size) { final paint = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; final path = Path()..moveTo(0, size.height * .63)..cubicTo(size.width * .16, size.height * .18, size.width * .3, size.height * .78, size.width * .47, size.height * .45)..cubicTo(size.width * .65, size.height * .12, size.width * .82, size.height * .68, size.width, size.height * .25); canvas.drawPath(path, paint); }
  @override bool shouldRepaint(covariant _TrendPainter oldDelegate) => oldDelegate.color != color;
}
