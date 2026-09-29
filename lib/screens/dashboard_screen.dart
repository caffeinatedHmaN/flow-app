import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const DashboardScreen({super.key, required this.prefs});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _elapsed = ValueNotifier<int>(0);
  Timer? _ticker;
  bool _running = false;
  int _baseMs = 0;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _baseMs = widget.prefs.getInt('sw_elapsed_ms') ?? 0;
    _elapsed.value = _baseMs;
    if (widget.prefs.getBool('sw_running') ?? false) {
      final startMs = widget.prefs.getInt('sw_started_at');
      if (startMs != null) {
        _startedAt = DateTime.fromMillisecondsSinceEpoch(startMs);
        _running = true;
        _startTicker();
      }
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_running || _startedAt == null) return;
      _elapsed.value =
          _baseMs + DateTime.now().difference(_startedAt!).inMilliseconds;
    });
  }

  void _toggle() {
    if (_running) {
      if (_startedAt != null) {
        _baseMs += DateTime.now().difference(_startedAt!).inMilliseconds;
      }
      _running = false;
      _startedAt = null;
      _ticker?.cancel();
      widget.prefs.setBool('sw_running', false);
      widget.prefs.setInt('sw_elapsed_ms', _baseMs);
      _elapsed.value = _baseMs;
    } else {
      _running = true;
      _startedAt = DateTime.now();
      widget.prefs.setBool('sw_running', true);
      widget.prefs.setInt('sw_started_at', _startedAt!.millisecondsSinceEpoch);
      _startTicker();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _elapsed.dispose();
    super.dispose();
  }

  String _fmtSw(int ms) {
    final s = ms ~/ 1000;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final cs = (ms % 1000) ~/ 10;
    String p(int n) => n.toString().padLeft(2, '0');
    return h > 0
        ? '${p(h)}:${p(m)}:${p(sec)}.${p(cs)}'
        : '${p(m)}:${p(sec)}.${p(cs)}';
  }

  @override
  Widget build(BuildContext context) {
    final todayMin = widget.prefs.getInt('today_minutes') ?? 0;
    final goalMin = widget.prefs.getInt('goal_minutes') ?? 240;
    final pct = goalMin > 0
        ? ((todayMin / goalMin) * 100).clamp(0, 100).toInt()
        : 0;
    final streak = widget.prefs.getInt('streak') ?? 0;
    final done = widget.prefs.getInt('tasks_done') ?? 0;
    final total = widget.prefs.getInt('tasks_total') ?? 0;
    final name = widget.prefs.getString('user_name') ?? '';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [
          _topBar(),
          const SizedBox(height: 22),
          Text(
            'GOOD ${_greet()}${name.isNotEmpty ? ', ${name.toUpperCase()}' : ''}',
            style: FlowText.label(color: FlowColors.textMuted, spacing: 2),
          ),
          const SizedBox(height: 6),
          Text(
            streak > 0
                ? '$streak day${streak > 1 ? 's' : ''} strong.'
                : 'Welcome back.',
            style: FlowText.body(
                size: 18, weight: FontWeight.w600, color: FlowColors.textPrimary),
          ),
          const SizedBox(height: 22),
          _todayCard(todayMin, goalMin, pct),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _signalCard(streak)),
              const SizedBox(width: 10),
              Expanded(child: _tasksCard(done, total)),
            ],
          ),
          const SizedBox(height: 10),
          _hoursCard(todayMin),
          const SizedBox(height: 10),
          _weekCard(todayMin),
          const SizedBox(height: 10),
          _stopwatchCard(),
        ],
      ),
    );
  }

  Widget _topBar() {
    final now = DateTime.now();
    final h12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ap = now.hour >= 12 ? 'PM' : 'AM';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('FLOW',
            style: FlowText.number(
                size: 26, spacing: 2, color: FlowColors.textPrimary)),
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
          Text(
            '$h12:${now.minute.toString().padLeft(2, '0')} $ap',
            style: FlowText.label(color: FlowColors.textSecondary, spacing: 1.5),
          ),
        ]),
      ],
    );
  }

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 5) return 'LATE NIGHT';
    if (h < 12) return 'MORNING';
    if (h < 18) return 'AFTERNOON';
    return 'EVENING';
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

  Widget _todayCard(int todayMin, int goalMin, int pct) {
    return _card(
      '01',
      'TODAY',
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: FlowText.number(
                        size: 52, spacing: -2, color: FlowColors.textPrimary),
                    children: [
                      TextSpan(text: '${todayMin ~/ 60}'),
                      TextSpan(
                        text: 'H',
                        style: FlowText.number(
                            size: 18,
                            weight: FontWeight.w600,
                            color: FlowColors.textMuted),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                          text:
                              '${(todayMin % 60).toString().padLeft(2, '0')}'),
                      TextSpan(
                        text: 'M',
                        style: FlowText.number(
                            size: 18,
                            weight: FontWeight.w600,
                            color: FlowColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Text('$pct%',
                      style: FlowText.label(color: FlowColors.accent)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: FlowColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('GOAL ${goalMin ~/ 60}H',
                        style: FlowText.label(
                            color: FlowColors.textSecondary, spacing: 1)),
                  ),
                ]),
              ],
            ),
          ),
          SizedBox(
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
                    Text('$pct%',
                        style: FlowText.number(
                            size: 20, color: FlowColors.textPrimary)),
                    Text('GOAL',
                        style: FlowText.label(
                            size: 7,
                            color: FlowColors.textMuted,
                            spacing: 1.4)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _signalCard(int streak) {
    return _card(
      '02',
      'SIGNAL',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$streak',
              style: FlowText.number(
                  size: 38,
                  spacing: -1,
                  color: FlowColors.textPrimary)),
          const SizedBox(height: 2),
          Text('DAYS',
              style: FlowText.label(
                  size: 9, color: FlowColors.textMuted, spacing: 1)),
          const SizedBox(height: 8),
          Text(streak > 0 ? 'ACTIVE' : 'READY',
              style: FlowText.label(color: FlowColors.accent)),
        ],
      ),
    );
  }

  Widget _tasksCard(int done, int total) {
    final pct = total > 0 ? ((done / total) * 100).round() : 0;
    return _card(
      '03',
      'TASKS',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$done/$total',
              style: FlowText.number(
                  size: 38,
                  spacing: -1,
                  color: FlowColors.textPrimary)),
          const SizedBox(height: 2),
          Text('DONE',
              style: FlowText.label(
                  size: 9, color: FlowColors.textMuted, spacing: 1)),
          const SizedBox(height: 8),
          Text(total > 0 ? '$pct%' : '—',
              style: FlowText.label(color: FlowColors.accent)),
        ],
      ),
    );
  }

  Widget _hoursCard(int todayMin) {
    return _card(
      '04',
      'HOURS',
      SizedBox(
        height: 72,
        child: Row(
          children: List.generate(8, (i) {
            const segMin = 30;
            final covered = todayMin - (i * segMin);
            final full = covered >= segMin;
            final half = covered > 0 && covered < segMin;
            final frac =
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
                      heightFactor: frac,
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
    );
  }

  Widget _weekCard(int todayMin) {
    return _card(
      '05',
      'THIS WEEK',
      SizedBox(
        height: 100,
        child: CustomPaint(
          painter: _WeekPainter(todayMin),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _stopwatchCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text('06',
                    style:
                        FlowText.label(color: FlowColors.accent)),
                const SizedBox(width: 8),
                Text('STOPWATCH',
                    style: FlowText.label(color: FlowColors.textSecondary)),
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
                  _running ? 'RUNNING' : (_baseMs > 0 ? 'PAUSED' : 'READY'),
                  style: FlowText.label(
                      color: FlowColors.textSecondary, spacing: 1.2),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<int>(
            valueListenable: _elapsed,
            builder: (_, ms, __) => Text(
              _fmtSw(ms),
              style: FlowText.number(
                  size: 50, spacing: -2, color: FlowColors.textPrimary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TAP PLAY TO START',
                  style: FlowText.label(
                      color: FlowColors.textMuted, spacing: 1)),
              GestureDetector(
                onTap: _toggle,
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
                    _running ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekPainter extends CustomPainter {
  final int todayMin;
  _WeekPainter(this.todayMin);

  @override
  void paint(Canvas canvas, Size size) {
    final data = <double>[
      0.4,
      0.6,
      0.5,
      0.85,
      0.5,
      0.1,
      (todayMin / 240.0).clamp(0.05, 1.0),
    ];
    final stepX = size.width / (data.length - 1);
    final paint = Paint()
      ..color = FlowColors.accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    Offset? prev;
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] * (size.height - 10)) - 5;
      final curr = Offset(x, y);
      if (prev != null) _dash(canvas, prev, curr, paint);
      canvas.drawCircle(curr, i == data.length - 1 ? 4 : 3, paint);
      prev = curr;
    }
  }

  void _dash(Canvas c, Offset a, Offset b, Paint p) {
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      c.drawLine(a + dir * d, a + dir * (d + 1.5).clamp(0.0, total), p);
      d += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _WeekPainter old) => old.todayMin != todayMin;
}
