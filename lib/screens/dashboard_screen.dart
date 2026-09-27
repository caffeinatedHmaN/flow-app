import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  style: GoogleFonts.doto(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: FlowColors.textPrimary,
                  )),
              Text('LIVE',
                  style: GoogleFonts.doto(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: FlowColors.textSecondary,
                  )),
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _range == r ? FlowColors.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(r.toUpperCase(),
                                style: GoogleFonts.doto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: _range == r ? Colors.white : FlowColors.textSecondary,
                                )),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _card(
            idx: '01',
            title: 'COMPARE',
            child: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _CompareChartPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _metric('TOTAL', '${todayMin ~/ 60}H ${(todayMin % 60).toString().padLeft(2, '0')}M', '+0H')),
            const SizedBox(width: 1),
            Expanded(child: _metric('SESSIONS', '0', '')),
          ]),
          const SizedBox(height: 1),
          Row(children: [
            Expanded(child: _metric('TASKS DONE', '$tasksDone', '')),
            const SizedBox(width: 1),
            Expanded(child: _metric('AVG', '0H 00M', '')),
          ]),
          const SizedBox(height: 20),
          _card(
            idx: '02',
            title: 'PEAK HOURS',
            child: SizedBox(
              height: 84,
              child: CustomPaint(
                painter: _HoursChartPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('PERSONAL RECORDS',
              style: GoogleFonts.doto(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: FlowColors.textMuted,
              )),
          const SizedBox(height: 10),
          _record('Longest streak', '${streak}D'),
          _record('Most in a day', '0H 00M'),
          _record('Best week', '0H 00M'),
          _record('Total sessions', '0'),
        ],
      ),
    );
  }

  Widget _card({required String idx, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: FlowColors.card,
        border: Border.all(color: FlowColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(idx, style: GoogleFonts.doto(fontSize: 10, fontWeight: FontWeight.w700, color: FlowColors.textSecondary)),
            const SizedBox(width: 6),
            Text(title, style: GoogleFonts.doto(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: FlowColors.textSecondary)),
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
      decoration: BoxDecoration(color: FlowColors.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.doto(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: FlowColors.textSecondary,
              )),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.doto(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: FlowColors.textPrimary,
              )),
          if (delta.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(delta,
                style: GoogleFonts.doto(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: FlowColors.accent,
                )),
          ],
        ],
      ),
    );
  }

  Widget _record(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: FlowColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: FlowColors.textPrimary,
              )),
          Text(value,
              style: GoogleFonts.doto(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: FlowColors.textSecondary,
              )),
        ],
      ),
    );
  }
}

class _CompareChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thisWeek = <double>[0.45, 0.72, 0.58, 0.88, 0.54, 0.12, 0.4];
    final lastWeek = <double>[0.38, 0.55, 0.62, 0.48, 0.40, 0.08, 0.3];
    _drawLine(canvas, size, lastWeek, FlowColors.textMuted.withOpacity(0.4), 2);
    _drawLine(canvas, size, thisWeek, FlowColors.accent, 2.5);
  }

  void _drawLine(Canvas canvas, Size size, List<double> data, Color color, double w) {
    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].clamp(0.0, 1.0) * (size.height - 12)) - 6;
      points.add(Offset(x, y));
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      _dashed(canvas, points[i], points[i + 1], paint);
    }
    final dot = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 3, dot);
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      final s = a + dir * d;
      final e = a + dir * (d + 1.5).clamp(0.0, total);
      canvas.drawLine(s, e, paint);
      d += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HoursChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = <double>[0.05, 0.25, 0.65, 0.88, 0.72, 0.40, 0.15, 0.08];
    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].clamp(0.0, 1.0) * (size.height - 12)) - 6;
      points.add(Offset(x, y));
    }
    final paint = Paint()
      ..color = FlowColors.accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final total = (points[i + 1] - points[i]).distance;
      final dir = (points[i + 1] - points[i]) / total;
      double d = 0;
      while (d < total) {
        final s = points[i] + dir * d;
        final e = points[i] + dir * (d + 1.5).clamp(0.0, total);
        canvas.drawLine(s, e, paint);
        d += 7;
      }
    }
    final dot = Paint()..color = FlowColors.accent;
    for (final p in points) {
      canvas.drawCircle(p, 3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
