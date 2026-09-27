import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const SettingsScreen({super.key, required this.prefs});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [
          Text('SETTINGS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: FlowColors.textPrimary,
              )),
          const SizedBox(height: 24),
          _sectionLabel('YOU'),
          _settingRow('Your name', widget.prefs.getString('user_name') ?? '— NOT SET', () => _editText('user_name')),
          _sectionLabel('THEME'),
          _themeRow('DeerFlow (dark orange)', 'deerflow'),
          _themeRow('Paper (warm light)', 'paper'),
          _themeRow('Midnight (blue dark)', 'midnight'),
          _sectionLabel('POMODORO'),
          _settingRow('Work duration', '${widget.prefs.getInt('work_minutes') ?? 40} MIN', () => _editInt('work_minutes', 5, 180)),
          _settingRow('Long break after', '${widget.prefs.getInt('long_break_after') ?? 4} POMOS', () => _editInt('long_break_after', 2, 10)),
          _sectionLabel('GOAL'),
          _settingRow('Daily minutes', '${widget.prefs.getInt('goal_minutes') ?? 240} MIN', () => _editInt('goal_minutes', 30, 720)),
          _sectionLabel('DATA'),
          _settingRow('Reset all data', '', _reset),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: FlowColors.textMuted,
          )),
    );
  }

  Widget _settingRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: FlowColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }

  Widget _themeRow(String label, String themeKey) {
    final current = widget.prefs.getString('theme') ?? 'deerflow';
    final active = current == themeKey;
    return GestureDetector(
      onTap: () {
        widget.prefs.setString('theme', themeKey);
        FlowColors.applyTheme(themeKey);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? FlowColors.accent : Colors.transparent,
                border: Border.all(color: FlowColors.border),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editText(String key) {
    final ctrl = TextEditingController(text: widget.prefs.getString(key) ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlowColors.card,
        title: Text('YOUR NAME',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: FlowColors.textPrimary,
            )),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.jetBrainsMono(color: FlowColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: FlowColors.border,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL',
                  style: GoogleFonts.jetBrainsMono(color: FlowColors.textSecondary))),
          TextButton(
            onPressed: () {
              widget.prefs.setString(key, ctrl.text.trim());
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('SAVE',
                style: GoogleFonts.jetBrainsMono(color: FlowColors.accent)),
          ),
        ],
      ),
    );
  }

  void _editInt(String key, int min, int max) {
    final ctrl = TextEditingController(text: '${widget.prefs.getInt(key) ?? min}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlowColors.card,
        title: Text(key.toUpperCase().replaceAll('_', ' '),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: FlowColors.textPrimary,
            )),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: GoogleFonts.jetBrainsMono(color: FlowColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: FlowColors.border,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL',
                  style: GoogleFonts.jetBrainsMono(color: FlowColors.textSecondary))),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v >= min && v <= max) {
                widget.prefs.setInt(key, v);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('SAVE',
                style: GoogleFonts.jetBrainsMono(color: FlowColors.accent)),
          ),
        ],
      ),
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlowColors.card,
        title: Text('RESET ALL DATA',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: FlowColors.textPrimary,
            )),
        content: Text('Erases everything. Cannot be undone.',
            style: GoogleFonts.jetBrainsMono(color: FlowColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL',
                  style: GoogleFonts.jetBrainsMono(color: FlowColors.textSecondary))),
          TextButton(
            onPressed: () async {
              await widget.prefs.clear();
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('RESET',
                style: GoogleFonts.jetBrainsMono(color: FlowColors.accent)),
          ),
        ],
      ),
    );
  }
}
