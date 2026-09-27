import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const DashboardScreen({super.key, required this.prefs});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _ticker;
  int _swElapsedMs = 0;
  bool _swRunning = false;
  DateTime? _swStartedAt;

  @override
  void initState() {
    super.initState();
    _swElapsedMs = widget.prefs.getInt('sw_elapsed_ms') ?? 0;
    _loadState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_swRunning) setState(() {});
    });
  }

  void _loadState() {
    final running = widget.prefs.getBool('sw_running') ?? false;
    final startedAt = widget.prefs.getInt('sw_started_at');
    if (running && startedAt != null) {
      _swRunning = true;
      _swStartedAt = DateTime.fromMillisecondsSinceEpoch(startedAt);
    }
    setState(() {});
  }

  void _toggleStopwatch() {
    setState(() {
      if (_swRunning) {
        if (_swStartedAt != null) {
          _swElapsedMs += DateTime.now().difference(_swStartedAt!).inMilliseconds;
        }
        _swRunning = false;
        _swStartedAt = null;
        widget.prefs.setBool('sw_running', false);
        widget.prefs.setInt('sw_elapsed_ms', _swElapsedMs);
      } else {
        _swRunning = true;
        _swStartedAt = DateTime.now();
        widget.prefs.setBool('sw_running', true);
        widget.prefs.setInt('sw_started_at', _swStartedAt!.millisecondsSinceEpoch);
      }
    });
  }

  int get _liveElapsedMs {
    if (!_swRunning || _swStartedAt == null) return _swElapsedMs;
    return _swElapsedMs + DateTime.now().difference(_swStartedAt!).inMilliseconds;
  }

  String _fmtStopwatch(int ms) {
    final totalSec = ms ~/ 1000;
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    final cs = (ms % 1000) ~/ 10;
    String p(int n) => n.toString().padLeft(2, '0');
    if (h > 0) return '${p(h)}:${p(m)}:${p(s)}.${p(cs)}';
    return '${p(m)}:${p(s)}.${p(cs)}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayMin = widget.prefs.getInt('today_minutes') ?? 0;
    final goalMin = widget.prefs.getInt('goal_minutes') ?? 240;
    final pct = goalMin > 0 ? (todayMin / goalMin * 100).clamp(0, 100).toInt() : 0;
    final streak = widget.prefs.getInt('streak') ?? 0;
    final taskDone = widget.prefs.getInt('tasks_done') ?? 0;
    final taskTotal = widget.prefs.getInt('tasks_total') ?? 0;
    final userName = widget.prefs.getString('user_name') ?? '';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FLOW',
                  style: GoogleFonts.getFont(
                    'Doto',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: FlowColors.textPrimary,
                  )),
              Row(children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: FlowColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: FlowColors.accent.withOpacity(0.9), blurRadius: 8)
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(_timeNow(),
                    style: GoogleFonts.getFont(
                      'Doto',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: FlowColors.textSecondary,
                    )),
              ]),
            ],
          ),
          const SizedBox(height: 22),
          Text('GOOD ${_greeting()}${userName.isNotEmpty ? ', ${userName.toUpperCase()}' : ''}',
              style: GoogleFonts.getFont(
                'Doto',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: FlowColors.textMuted,
              )),
          const SizedBox(height: 6),
          Text(
            streak > 0 ? '$streak day${streak > 1 ? 's' : ''} strong.' : 'Welcome back.',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FlowColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _card(
            idx: '01',
            title: 'TODAY',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.getFont(
                            'Doto',
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                            color: FlowColors.textPrimary,
                          ),
                          children: [
                            TextSpan(text: '${todayMin ~/ 60}'),
                            TextSpan(
                              text: 'H',
                              style: GoogleFonts.getFont(
                                'Doto',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: FlowColors.textMuted,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                                text: '${(todayMin % 60).toString().padLeft(2, '0')}'),
                            TextSpan(
                              text: 'M',
                              style: GoogleFonts.getFont(
                                'Doto',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: FlowColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Text('$pct%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: FlowColors.accent,
                            )),
                        const SizedBox(width: 10),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: FlowColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('GOAL ${goalMin ~/ 60}H',
                              style: GoogleFonts.getFont(
                                'Doto',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: FlowColors.textSecondary,
                              )),
                        ),
                      ]),
                    ],
                  ),
                ),
                _arcRing(pct.toDouble()),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _statCard('02', 'SIGNAL', '$streak', 'DAYS',
                    streak > 0 ? 'ACTIVE' : 'READY')),
            const SizedBox(width: 10),
            Expanded(
                child: _statCard(
                    '03',
                    'TASKS',
                    '$taskDone/$taskTotal',
                    '',
                    taskTotal > 0
                        ? '${(taskDone / taskTotal * 100).round()}%'
                        : '—')),
          ]),
          const SizedBox(height: 10),
          _card(
            idx: '04',
            title: 'HOURS',
            child: SizedBox(
              height: 76,
              child: Row(
                children: List.generate(8, (i) {
                  const segMin = 30;
                  final covered = todayMin - (i * segMin);
                  final full = covered >= segMin;
                  final half = covered > 0 && covered < segMin;
                  final fraction =
                      half ? (covered / segMin).clamp(0.0, 1.0) : (full ? 1.0 : 0.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlowColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: fraction,
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlowColors.textPrimary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _card(
            idx: '05',
            title: 'THIS WEEK',
            child: SizedBox(
              height: 100,
              child: CustomPaint(
                painter: _WeekChartPainter(todayMin),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: FlowColors.card,
              border: Border.all(color: FlowColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text('06',
                          style: GoogleFonts.getFont(
                            'Doto',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: FlowColors.accent,
                          )),
                      const SizedBox(width: 8),
                      Text('STOPWATCH',
                          style: GoogleFonts.getFont(
                            'Doto',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: FlowColors.textSecondary,
                          )),
                    ]),
                    Row(children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: FlowColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: FlowColors.accent.withOpacity(0.9),
                                blurRadius: 8)
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                          _swRunning
                              ? 'RUNNING'
                              : (_swElapsedMs > 0 ? 'PAUSED' : 'READY'),
                          style: GoogleFonts.getFont(
                            'Doto',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: FlowColors.textSecondary,
                          )),
                    ]),
                  ],
                ),
                const SizedBox(height: 14),
                Text(_fmtStopwatch(_liveElapsedMs),
                    style: GoogleFonts.getFont(
                      'Doto',
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      color: FlowColors.textPrimary,
                    )),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TAP PLAY TO START',
                        style: GoogleFonts.getFont(
                          'Doto',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: FlowColors.textMuted,
                        )),
                    GestureDetector(
                      onTap: _toggleStopwatch,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: FlowColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: FlowColors.accent.withOpacity(0.5),
                                blurRadius: 24)
                          ],
                        ),
                        child: Icon(
                          _swRunning ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'LATE NIGHT';
    if (h < 12) return 'MORNING';
    if (h < 18) return 'AFTERNOON';
    return 'EVENING';
  }

  String _timeNow() {
    final now = DateTime.now();
    final h12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ap = now.hour >= 12 ? 'PM' : 'AM';
    return '$h12:${now.minute.toString().padLeft(2, '0')} $ap';
  }

  Widget _card(
      {required String idx, required String title, required Widget child}) {
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
            Text(idx,
                style: GoogleFonts.getFont(
                  'Doto',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FlowColors.textSecondary,
                )),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.getFont(
                  'Doto',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: FlowColors.textSecondary,
                )),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _statCard(
      String idx, String title, String big, String sub, String foot) {
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
            Text(idx,
                style: GoogleFonts.getFont(
                  'Doto',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FlowColors.textSecondary,
                )),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.getFont(
                  'Doto',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: FlowColors.textSecondary,
                )),
          ]),
          const SizedBox(height: 12),
          Text(big,
              style: GoogleFonts.getFont(
                'Doto',
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: FlowColors.textPrimary,
              )),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(sub,
                style: GoogleFonts.getFont(
                  'Doto',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: FlowColors.textMuted,
                )),
          ],
          const SizedBox(height: 8),
          Text(foot,
              style: GoogleFonts.getFont(
                'Doto',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: FlowColors.accent,
              )),
        ],
      ),
    );
  }

  Widget _arcRing(double pct) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CircularProgressIndicator(
              value: pct / 100,
              strokeWidth: 4,
              backgroundColor: FlowColors.border,
              valueColor: AlwaysStoppedAnimation(FlowColors.accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${pct.toInt()}%',
                  style: GoogleFonts.getFont(
                    'Doto',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: FlowColors.textPrimary,
                  )),
              Text('GOAL',
                  style: GoogleFonts.getFont(
                    'Doto',
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: FlowColors.textMuted,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekChartPainter extends CustomPainter {
  final int todayMin;
  _WeekChartPainter(this.todayMin);

  @override
  void paint(Canvas canvas, Size size) {
    final data = <double>[
      0.4,
      0.6,
      0.5,
      0.85,
      0.5,
      0.1,
      todayMin / 240.0
    ];
    final stepX = size.width / (data.length - 1);
    final paint = Paint()
      ..color = FlowColors.accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].clamp(0.0, 1.0) * (size.height - 8)) - 4;
      final dot = Paint()..color = FlowColors.accent;
      canvas.drawCircle(Offset(x, y), i == data.length - 1 ? 4 : 3, dot);
      if (i > 0) {
        final prevX = (i - 1) * stepX;
        final prevY =
            size.height - (data[i - 1].clamp(0.0, 1.0) * (size.height - 8)) - 4;
        _drawDashedLine(canvas, Offset(prevX, prevY), Offset(x, y), paint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dashWidth = 1.5;
    const dashSpace = 5.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    double drawn = 0;
    while (drawn < total) {
      final start = a + dir * drawn;
      final end = a + dir * (drawn + dashWidth).clamp(0.0, total);
      canvas.drawLine(start, end, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
