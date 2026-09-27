import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class TasksScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const TasksScreen({super.key, required this.prefs});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final g = widget.prefs.getString('groups_json');
    final t = widget.prefs.getString('tasks_json');
    if (g != null) _groups = List<Map<String, dynamic>>.from(jsonDecode(g));
    if (t != null) _tasks = List<Map<String, dynamic>>.from(jsonDecode(t));
    setState(() {});
  }

  void _save() {
    widget.prefs.setString('groups_json', jsonEncode(_groups));
    widget.prefs.setString('tasks_json', jsonEncode(_tasks));
    widget.prefs.setInt('tasks_done', _tasks.where((t) => t['done'] == true).length);
    widget.prefs.setInt('tasks_total', _tasks.length);
  }

  void _addTask(String? groupId) {
    final titleCtrl = TextEditingController();
    String? selectedGroupId = groupId;
    String repeat = 'none';

    showModalBottomSheet(
      context: context,
      backgroundColor: FlowColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModal) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEW TASK',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: FlowColors.textPrimary,
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                style: GoogleFonts.jetBrainsMono(color: FlowColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: FlowColors.textMuted),
                  filled: true,
                  fillColor: FlowColors.border,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('GROUP',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: FlowColors.textMuted,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  _chip('NONE', selectedGroupId == null,
                      () => setModal(() => selectedGroupId = null)),
                  ..._groups.map((g) => _chip(
                        (g['name'] as String).toUpperCase(),
                        selectedGroupId == g['id'],
                        () => setModal(() => selectedGroupId = g['id']),
                      )),
                ],
              ),
              const SizedBox(height: 20),
              Text('REPEAT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: FlowColors.textMuted,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  _chip('NONE', repeat == 'none', () => setModal(() => repeat = 'none')),
                  _chip('DAILY', repeat == 'daily', () => setModal(() => repeat = 'daily')),
                  _chip('WEEKLY', repeat == 'weekly', () => setModal(() => repeat = 'weekly')),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: FlowColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text('CANCEL',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: FlowColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;
                        setState(() {
                          _tasks.add({
                            'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            'title': title,
                            'done': false,
                            'groupId': selectedGroupId,
                            'repeat': repeat,
                          });
                        });
                        _save();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: FlowColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text('ADD TASK',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? FlowColors.accent.withOpacity(0.12) : FlowColors.border,
          border: Border.all(color: active ? FlowColors.accent : Colors.transparent),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: active ? FlowColors.accent : FlowColors.textSecondary,
            )),
      ),
    );
  }

  void _addGroup() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlowColors.card,
        title: Text('NEW GROUP',
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
            hintText: 'Group name',
            hintStyle: TextStyle(color: FlowColors.textMuted),
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
                style: GoogleFonts.jetBrainsMono(color: FlowColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              setState(() {
                _groups.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': name,
                });
              });
              _save();
              Navigator.pop(context);
            },
            child: Text('CREATE',
                style: GoogleFonts.jetBrainsMono(color: FlowColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((t) => t['done'] == true).length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TASKS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: FlowColors.textPrimary,
                  )),
              Text('$done / ${_tasks.length}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: FlowColors.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () => _addTask(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: FlowColors.accent.withOpacity(0.06),
                border: Border.all(color: FlowColors.accent),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Text('+',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      color: FlowColors.accent,
                    )),
                const SizedBox(width: 10),
                Text('ADD TASK',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: FlowColors.accent,
                    )),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          ..._groups.map((g) {
            final groupTasks =
                _tasks.where((t) => t['groupId'] == g['id']).toList();
            final groupDone =
                groupTasks.where((t) => t['done'] == true).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              decoration: BoxDecoration(
                color: FlowColors.card,
                border: Border.all(color: FlowColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: FlowColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text((g['name'] as String).toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: FlowColors.textPrimary,
                            )),
                      ]),
                      Text('$groupDone/${groupTasks.length}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: FlowColors.textSecondary,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...groupTasks.map((t) => _taskRow(t)),
                  GestureDetector(
                    onTap: () => _addTask(g['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        Text('+',
                            style: GoogleFonts.jetBrainsMono(
                                color: FlowColors.textMuted, fontSize: 14)),
                        const SizedBox(width: 8),
                        Text('ADD TASK',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: FlowColors.textMuted,
                            )),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: _addGroup,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: FlowColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text('+ NEW GROUP',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: FlowColors.textSecondary,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(Map<String, dynamic> t) {
    final done = t['done'] == true;
    return GestureDetector(
      onTap: () {
        setState(() {
          t['done'] = !done;
        });
        _save();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: done ? FlowColors.accent : Colors.transparent,
                border: Border.all(
                    color: done ? FlowColors.accent : FlowColors.textMuted),
                borderRadius: BorderRadius.circular(5),
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t['title'] ?? '',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: done ? FlowColors.textMuted : FlowColors.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
