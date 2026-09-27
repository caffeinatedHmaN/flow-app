import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(FlowApp(prefs: prefs));
}

class FlowApp extends StatelessWidget {
  final SharedPreferences prefs;
  const FlowApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLOW',
      debugShowCheckedModeBanner: false,
      theme: FlowTheme.deerflow(),
      home: RootShell(prefs: prefs),
    );
  }
}

class RootShell extends StatefulWidget {
  final SharedPreferences prefs;
  const RootShell({super.key, required this.prefs});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(prefs: widget.prefs),
      TimerScreen(prefs: widget.prefs),
      TasksScreen(prefs: widget.prefs),
      AnalyticsScreen(prefs: widget.prefs),
      SettingsScreen(prefs: widget.prefs),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: FlowColors.surface,
          border: Border(top: BorderSide(color: FlowColors.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home),
                _navItem(1, Icons.timer_outlined, Icons.timer),
                _navItem(2, Icons.check_circle_outline, Icons.check_circle),
                _navItem(3, Icons.bar_chart_outlined, Icons.bar_chart),
                _navItem(4, Icons.settings_outlined, Icons.settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData activeIcon) {
    final selected = _index == idx;
    return GestureDetector(
      onTap: () => setState(() => _index = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? FlowColors.accent : Colors.transparent,
          boxShadow: selected
              ? [BoxShadow(color: FlowColors.accent.withOpacity(0.5), blurRadius: 20)]
              : null,
        ),
        child: Icon(
          selected ? activeIcon : icon,
          size: 18,
          color: selected ? Colors.white : FlowColors.textMuted,
        ),
      ),
    );
  }
}
