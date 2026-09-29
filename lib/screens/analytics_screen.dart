import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class AnalyticsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const AnalyticsScreen({super.key, required this.prefs});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _range = 'week';

  @override
  Widget build(BuildContext context) {
    final todayMin = widget.prefs.getInt('today_minutes') ?? 0;
    final streak = widget.prefs.getInt('streak') ?? 0;
    final tasksDone = widget.prefs.getInt('tasks_done') ?? 0;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ANALYTICS',
                  style: FlowText.number(
                      size: 26, spacing: 2, color: FlowColors.textPrimary)),
              Text('LIVE',
                  style: FlowText.label(
                      color: FlowColors.textSecondary, spacing: 1.5)),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: FlowColors.card,
              border: Border.all(color: FlowColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: ['day', 'week', 'month', 'all']
                  .map((r) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _range = r),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding:
                                const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _range == r
                                  ? FlowColors.accent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(r.toUpperCase(),
                                style: FlowText.label(
                                  color: _range == r
                                      ? Colors.white
                                      : FlowColors.textSecondary,
                                  spacing: 1.2,
                                )),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _card(
            '01',
            'COMPARE',
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _ComparePainter(),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _metric(
                    'TOTAL',
                    '${todayMin ~/ 60}H ${(todayMin % 60).toString().padLeft(2, '0')}M',
                    '+0H')),
            const SizedBox(width: 10),
            Expanded(child: _metric('SESSIONS', '0', '')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _metric('TASKS DONE', '$tasksDone', '')),
            const SizedBox(width: 10),
            Expanded(child: _metric('AVG', '0H 00M', '')),
          ]),
          const SizedBox(height: 10),
          _card(
            '02',
            'PEAK HOURS',
            SizedBox(
              height: 84,
              child: CustomPaint(
                painter: _HoursPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('PERSONAL RECORDS',
              style: FlowText.label(
                  color: FlowColors.textMuted, spacing: 1.6)),
          const SizedBox(height: 10),
          _record('Longest streak', '${streak}D'),
          _record('Most in a day', '0H 00M'),
          _record('Best week', '0H 00M'),
          _record('Total sessions', '0'),
        ],
      ),
    );
  }

  Widget _card(String idx, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlowColors.card,
        border: Border.all(color: FlowColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(idx, style: FlowText.label(color: FlowColors.textSecondary)),
            const SizedBox(width: 6),
            Text(title,
                style: FlowText.label(color: FlowColors.textSecondary)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _metric(String label, String value, String delta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlowColors.card,
        border: Border.all(color: FlowColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: FlowText.label(
                  size: 9, color: FlowColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value,
              style: FlowText.number(
                  size: 20, color: FlowColors.textPrimary)),
          if (delta.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(delta,
                style: FlowText.label(color: FlowColors.accent, size: 9)),
          ],
        ],
      ),
    );
  }

  Widget _record(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: FlowColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: FlowText.body(color: FlowColors.textPrimary)),
          Text(value,
              style: FlowText.label(
                  color: FlowColors.textSecondary, spacing: 1)),
        ],
      ),
    );
  }
}

class _ComparePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _line(canvas, size, [0.38, 0.55, 0.62, 0.48, 0.40, 0.08, 0.3],
        FlowColors.textMuted.withOpacity(0.4), 2);
    _line(canvas, size, [0.45, 0.72, 0.58, 0.88, 0.54, 0.12, 0.4],
        FlowColors.accent, 2.5);
  }

  void _line(Canvas c, Size size, List<double> data, Color col, double w) {
    final stepX = size.width / (data.length - 1);
    final pts = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      pts.add(Offset(i * stepX,
          size.height - (data[i].clamp(0.0, 1.0) * (size.height - 12)) - 6));
    }
    final p = Paint()
      ..color = col
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < pts.length - 1; i++) _dash(c, pts[i], pts[i + 1], p);
    for (final pt in pts) {
      c.drawCircle(pt, 3, p);
    }
  }

  void _dash(Canvas c, Offset a, Offset b, Paint p) {
    final t = (b - a).distance;
    if (t == 0) return;
    final dir = (b - a) / t;
    double d = 0;
    while (d < t) {
      c.drawLine(a + dir * d, a + dir * (d + 1.5).clamp(0.0, t), p);
      d += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _HoursPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = <double>[0.05, 0.25, 0.65, 0.88, 0.72, 0.40, 0.15, 0.08];
    final stepX = size.width / (data.length - 1);
    final pts = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      pts.add(Offset(i * stepX,
          size.height - (data[i].clamp(0.0, 1.0) * (size.height - 12)) - 6));
    }
    final p = Paint()
      ..color = FlowColors.accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < pts.length - 1; i++) _dash(canvas, pts[i], pts[i + 1], p);
    for (final pt in pts) {
      canvas.drawCircle(pt, 3, p);
    }
  }

  void _dash(Canvas c, Offset a, Offset b, Paint p) {
    final t = (b - a).distance;
    if (t == 0) return;
    final dir = (b - a) / t;
    double d = 0;
    while (d < t) {
      c.drawLine(a + dir * d, a + dir * (d + 1.5).clamp(0.0, t), p);
      d += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
