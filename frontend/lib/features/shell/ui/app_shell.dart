import 'package:flutter/material.dart';

import '../../dashboard/ui/dashboard_view.dart';
import '../../auth/data/session_controller.dart';
import '../../attendance/ui/attendance_view.dart';
import '../../privacy/ui/privacy_notice_view.dart';
import '../../refuerzo/ui/refuerzo_quiz_view.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.session,
    required this.onLogin,
    required this.onLogout,
    super.key,
  });

  final SessionController session;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  List<(String, IconData, Widget?)> get _sections => [
    ('Panel Principal', Icons.dashboard_outlined, const DashboardView()),
    ('Mis Materias', Icons.menu_book_outlined, null),
    (
      'Control de Asistencias',
      Icons.event_available_outlined,
      AttendanceView(
        api: widget.session.api,
        authenticated: widget.session.user != null,
        onSignIn: widget.onLogin,
      ),
    ),
    ('Gestor de Archivos', Icons.folder_open_outlined, null),
    ('Salones y Equipos', Icons.computer_outlined, null),
    ('Agenda y Tareas', Icons.checklist_outlined, null),
    ('Refuerzo Académico', Icons.psychology_outlined, const RefuerzoQuizView()),
    ('Directorio y Promedio', Icons.calculate_outlined, null),
    (
      'Aviso de privacidad',
      Icons.privacy_tip_outlined,
      const PrivacyNoticeView(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final navigation = SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.school, size: 36),
                SizedBox(height: 8),
                Text(
                  'PIUTTEC 2.0',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text('Desarrollo local'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (widget.session.user case final user?) Text(user.name),
                TextButton.icon(
                  onPressed: widget.session.user == null
                      ? widget.onLogin
                      : widget.onLogout,
                  icon: Icon(
                    widget.session.user == null ? Icons.login : Icons.logout,
                  ),
                  label: Text(
                    widget.session.user == null
                        ? 'Iniciar sesión'
                        : 'Cerrar sesión',
                  ),
                ),
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
              children: [
                for (final (title, icon, page) in _sections)
                  page ??
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'En desarrollo',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
