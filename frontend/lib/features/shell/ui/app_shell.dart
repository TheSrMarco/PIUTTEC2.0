import 'package:flutter/material.dart';

import '../../dashboard/ui/dashboard_view.dart';
import '../../privacy/ui/privacy_notice_view.dart';
import '../../refuerzo/ui/refuerzo_quiz_view.dart';
import '../../learning/ui/learning_graph_view.dart';
import '../../preview/ui/academic_preview_views.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  static const _sections = [
    ('Panel Principal', Icons.dashboard_outlined, DashboardView()),
    ('Mis Materias', Icons.menu_book_outlined, SubjectsPreview()),
    (
      'Control de Asistencias',
      Icons.event_available_outlined,
      AttendancePreview(),
    ),
    ('Gestor de Archivos', Icons.folder_open_outlined, FilesPreview()),
    ('Salones y Equipos', Icons.computer_outlined, ResourcesPreview()),
    ('Agenda y Tareas', Icons.checklist_outlined, AgendaPreview()),
    ('Refuerzo Académico', Icons.psychology_outlined, RefuerzoQuizView()),
    ('Mi Neurona UTTEC', Icons.hub_outlined, LearningGraphView()),
    ('Directorio y Promedio', Icons.calculate_outlined, DirectoryPreview()),
    ('Aviso de privacidad', Icons.privacy_tip_outlined, PrivacyNoticeView()),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final navigation = SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/piuttec-ii-logo.png',
                    height: 52,
                    fit: BoxFit.contain,
                    semanticLabel: 'Logo PIUTTEC II',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'PIUTTEC 2.0',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text('Demostración'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) => ListTile(
                selected: _selected == index,
                leading: Icon(_sections[index].$2),
                title: Text(_sections[index].$1),
                onTap: () {
                  setState(() => _selected = index);
                  if (!wide) Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(_sections[_selected].$1)),
      drawer: wide ? null : Drawer(child: navigation),
      body: Row(
        children: [
          if (wide) SizedBox(width: 280, child: navigation),
          if (wide) const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: _selected,
              children: [for (final section in _sections) section.$3],
            ),
          ),
        ],
      ),
    );
  }
}
