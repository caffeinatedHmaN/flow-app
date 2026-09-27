import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class TimerScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const TimerScreen({super.key, required this.prefs});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  String _mode = 'work';
  int _remainingSec = 40 * 60;
  bool _running = false;
  int _lapIndex = 0;
  int _lapsCompleted = 0;
  Timer? _ticker;
  DateTime? _startedAt;

  int get _workMinutes => widget.prefs.getInt('work_minutes') ?? 40;
  int get _shortBreak => widget.prefs.getInt('short_break') ?? 5;
  int get _longBreak => widget.prefs.getInt('long_break') ?? 15;
  int get _longBreakAfter => widget.prefs.getInt('long_break_after') ?? 4;

  @override
  void initState() {
    super.initState();
    _lapsCompleted = widget.prefs.getInt('pomo_laps') ?? 0;
    _remainingSec = _durationFor(_mode);
  }

  int _durationFor(String mode) {
    switch (mode) {
      case 'work':
        return _workMinutes * 60;
      case 'short':
        return _shortBreak * 60;
      case 'long':
        return _longBreak * 60;
    }
    return 0;
  }

  void _start() {
    setState(() {
      _running = true;
      _startedAt = DateTime.now();
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_startedAt == null) return;
      final elapsed = DateTime.now().difference(_startedAt!).inMilliseconds / 1000;
      final remaining = _durationFor(_mode) - elapsed;
      if (remaining <= 0) {
        _complete();
      } else {
        setState(() => _remainingSec = remaining.ceil());
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remainingSec = _durationFor(_mode);
    });
  }

  void _complete() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      if (_mode == 'work') {
        _lapsCompleted++;
        widget.prefs.setInt('pomo_laps', _lapsCompleted);
        final today = widget.prefs.getInt('today_minutes') ?? 0;
        widget.prefs.setInt('today_minutes', today + _workMinutes);
        _lapIndex++;
        if (_lapIndex >= _longBreakAfter) {
          _mode = 'long';
          _lapIndex = 0;
        } else {
          _mode = 'short';
        }
      } else {
        _mode = 'work';
      }
      _remainingSec = _durationFor(_mode);
    });
  }

  void _switchMode(String mode) {
    if (_running) return;
    _ticker?.cancel();
    setState(() {
      _mode = mode;
      _remainingSec = _durationFor(mode);
    });
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _modeLabel {
    switch (_mode) {
      case 'work':
        return 'FOCUS';
      case 'short':
        return 'SHORT BREAK';
      case 'long':
        return 'LONG BREAK';
    }
    return '';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    style: GoogleFonts.getFont(
                      'Doto',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: FlowColors.textPrimary,
                    )),
                Text(_running ? 'RUNNING' : 'ARMED',
                    style: GoogleFonts.getFont(
                      'Doto',
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
                  Text(_modeLabel,
                      style: GoogleFonts.getFont(
                        'Doto',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                        color: FlowColors.accent,
                      )),
                  const SizedBox(height: 12),
                  Text(_fmt(_remainingSec),
                      style: GoogleFonts.getFont(
                        'Doto',
                        fontSize: 88,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -4,
                        color: FlowColors.textPrimary,
                      )),
                  const SizedBox(height: 20),
                  Text('LAPS COMPLETED $_lapsCompleted',
                      style: GoogleFonts.getFont(
                        'Doto',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: FlowColors.textSecondary,
                      )),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_longBreakAfter, (i) {
                      final done = i < _lapIndex;
                      final current = i == _lapIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              done ? FlowColors.textPrimary : Colors.transparent,
                          border: Border.all(
                            color: current ? FlowColors.accent : FlowColors.border,
                            width: current ? 2 : 1,
                          ),
                          boxShadow: current
                              ? [
                                  BoxShadow(
                                      color: FlowColors.accent.withOpacity(0.6),
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
                        style: GoogleFonts.getFont(
                          'Doto',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
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

  Widget _tab(String mode, String label) {
    final active = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? FlowColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.getFont(
                'Doto',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: active ? Colors.white : FlowColors.textSecondary,
              )),
        ),
      ),
    );
  }
}
