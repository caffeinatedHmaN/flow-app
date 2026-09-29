import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class TimerScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const TimerScreen({super.key, required this.prefs});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _remaining = ValueNotifier<int>(0);
  String _mode = 'work';
  bool _running = false;
  int _lapIndex = 0;
  int _laps = 0;
  Timer? _ticker;
  DateTime? _startedAt;

  int get _work => widget.prefs.getInt('work_minutes') ?? 40;
  int get _short => 5;
  int get _long => 15;
  int get _breakAfter => widget.prefs.getInt('long_break_after') ?? 4;

  @override
  void initState() {
    super.initState();
    _laps = widget.prefs.getInt('pomo_laps') ?? 0;
    _remaining.value = _dur(_mode);
  }

  int _dur(String m) {
    if (m == 'work') return _work * 60;
    if (m == 'short') return _short * 60;
    if (m == 'long') return _long * 60;
    return 0;
  }

  void _start() {
    _running = true;
    _startedAt = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_startedAt == null) return;
      final el =
          DateTime.now().difference(_startedAt!).inMilliseconds / 1000;
      final rem = _dur(_mode) - el;
      if (rem <= 0) {
        _complete();
      } else {
        _remaining.value = rem.ceil();
      }
    });
    setState(() {});
  }

  void _pause() {
    _ticker?.cancel();
    _running = false;
    setState(() {});
  }

  void _reset() {
    _ticker?.cancel();
    _running = false;
    _remaining.value = _dur(_mode);
    setState(() {});
  }

  void _complete() {
    _ticker?.cancel();
    _running = false;
    if (_mode == 'work') {
      _laps++;
      widget.prefs.setInt('pomo_laps', _laps);
      final today = widget.prefs.getInt('today_minutes') ?? 0;
      widget.prefs.setInt('today_minutes', today + _work);
      _lapIndex++;
      if (_lapIndex >= _breakAfter) {
        _mode = 'long';
        _lapIndex = 0;
      } else {
        _mode = 'short';
      }
    } else {
      _mode = 'work';
    }
    _remaining.value = _dur(_mode);
    setState(() {});
  }

  void _switch(String m) {
    if (_running) return;
    _ticker?.cancel();
    _mode = m;
    _remaining.value = _dur(m);
    setState(() {});
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _mode == 'work'
        ? 'FOCUS'
        : (_mode == 'short' ? 'SHORT BREAK' : 'LONG BREAK');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('POMODORO',
                    style: FlowText.number(
                        size: 26,
                        spacing: 2,
                        color: FlowColors.textPrimary)),
                Text(_running ? 'RUNNING' : 'ARMED',
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
                children: [
                  _tab('work', 'FOCUS'),
                  _tab('short', 'SHORT'),
                  _tab('long', 'LONG'),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Text(label,
                      style: FlowText.label(
                          color: FlowColors.accent, spacing: 2.5)),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _remaining,
                    builder: (_, sec, __) => Text(
                      _fmt(sec),
                      style: FlowText.number(
                          size: 84,
                          spacing: -4,
                          color: FlowColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('LAPS COMPLETED $_laps',
                      style: FlowText.label(
                          color: FlowColors.textSecondary, spacing: 2)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_breakAfter, (i) {
                      final done = i < _lapIndex;
                      final current = i == _lapIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? FlowColors.textPrimary
                              : Colors.transparent,
                          border: Border.all(
                            color: current
                                ? FlowColors.accent
                                : FlowColors.border,
                            width: current ? 2 : 1,
                          ),
                          boxShadow: current
                              ? [
                                  BoxShadow(
                                      color: FlowColors.accent
                                          .withOpacity(0.6),
                                      blurRadius: 10)
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: FlowColors.card,
                      border: Border.all(color: FlowColors.border),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.refresh,
                        color: FlowColors.textSecondary, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _running ? _pause : _start,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: FlowColors.accent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                              color: FlowColors.accent.withOpacity(0.4),
                              blurRadius: 30)
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _running
                            ? 'PAUSE'
                            : _mode == 'work'
                                ? 'START FOCUS'
                                : 'START BREAK',
                        style: FlowText.label(
                            color: Colors.white, spacing: 1.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String m, String label) {
    final active = _mode == m;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switch(m),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? FlowColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: FlowText.label(
                  color: active ? Colors.white : FlowColors.textSecondary,
                  spacing: 1.2)),
        ),
      ),
    );
  }
}
