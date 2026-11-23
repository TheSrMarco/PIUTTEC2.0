import 'package:flutter/material.dart';
import '../../calendar/ui/calendar_view.dart';
import '../../agenda/ui/agenda_view.dart';
import '../../recursos/ui/recursos_view.dart';
import '../../archivos/ui/archivos_view.dart';
import '../../academia/ui/academia_view.dart';
import '../../rendimiento/ui/rendimiento_view.dart';
import '../../attendance/ui/attendance_view.dart';
import '../../dashboard/ui/dashboard_view.dart';
import '../../docentes/ui/docentes_view.dart';
import '../../privacy/ui/privacy_notice_view.dart';
import '../../refuerzo/ui/refuerzo_quiz_view.dart';
import '../../learning/ui/learning_graph_view.dart';
import '../../solicitudes/ui/solicitudes_view.dart';
import '../../auth/data/auth_session.dart';
import '../../profile/ui/profile_view.dart';
import '../../profile/ui/users_admin_view.dart';

/// PIUTTEC original: únicamente patrón visual de menú lateral desplegable.
/// Contenido de este menú: exclusivamente el alcance de PIUTTEC 2.0.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.onLogout, this.demoMode = true, this.username, this.accessToken, this.isAdministrator = false, this.onProfileUpdated});
  final VoidCallback? onLogout;
  final bool demoMode;
  final String? username;
  final String? accessToken;
  final bool isAdministrator;
  final ValueChanged<UserProfile>? onProfileUpdated;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _NavPage {
  const _NavPage(this.id, this.label, this.icon, this.page);
  final String id;
  final String label;
  final IconData icon;
  final Widget page;
}
class _NavGroup {
  const _NavGroup(this.title, this.icon, this.pages);
  final String title;
  final IconData icon;
  final List<_NavPage> pages;
}

class _AppShellState extends State<AppShell> {
  String _selected = 'calendar';
  List<_NavGroup> get _groups => <_NavGroup>[
    _NavGroup('Inicio', Icons.home_outlined, [
      _NavPage('calendar', 'Calendario', Icons.calendar_month_outlined, CalendarView(accessToken: widget.accessToken)),
      _NavPage('dashboard', 'Panel académico', Icons.dashboard_outlined, DashboardView(accessToken: widget.accessToken)),
      _NavPage('agenda', 'Agenda, tareas y evaluaciones', Icons.event_note_outlined, AgendaView(accessToken: widget.accessToken)),
    ]),
    _NavGroup('Academia', Icons.school_outlined, [
      _NavPage('subjects', 'Materias y calificaciones', Icons.menu_book_outlined, AcademiaView(accessToken: widget.accessToken)),
      _NavPage('timetable', 'Horario de clases', Icons.schedule_outlined, AcademiaView(accessToken: widget.accessToken, seccion: AcademiaSeccion.horarios)),
      _NavPage('attendance', 'Pase de lista y asistencias', Icons.fact_check_outlined, AttendanceView(accessToken: widget.accessToken)),
      _NavPage('grades', 'Comparativo académico', Icons.analytics_outlined, RendimientoView(accessToken: widget.accessToken)),
      _NavPage('teachers', 'Directorio docente', Icons.people_outline, DocentesView(accessToken: widget.accessToken)),
    ]),
    _NavGroup('Servicios y solicitudes', Icons.assignment_outlined, [
      _NavPage('requests', 'Trámites y justificantes', Icons.description_outlined, SolicitudesView(accessToken: widget.accessToken, initialType: 'justificante', isAdministrator: widget.isAdministrator)),
      _NavPage('rf12', 'Mis solicitudes', Icons.cloud_upload_outlined, SolicitudesView(accessToken: widget.accessToken, isAdministrator: widget.isAdministrator)),
    ]),
    _NavGroup('Recursos', Icons.computer_outlined, [
      _NavPage('resources', 'Laboratorios y equipos', Icons.meeting_room_outlined, RecursosView(accessToken: widget.accessToken, isAdministrator: widget.isAdministrator)),
      _NavPage('documents', 'Gestor de archivos', Icons.folder_outlined, ArchivosView(accessToken: widget.accessToken)),
    ]),
    _NavGroup('Aprendizaje', Icons.psychology_outlined, [
      _NavPage('quiz', 'Refuerzo académico', Icons.quiz_outlined, RefuerzoQuizView(accessToken: widget.accessToken)),
      _NavPage('neurona', 'Mi Neurona UTTEC', Icons.hub_outlined, const LearningGraphView()),
    ]),
    _NavGroup('Sistema', Icons.settings_outlined, [
      if (widget.accessToken != null)
        _NavPage('profile', 'Mi perfil', Icons.manage_accounts_outlined,
          ProfileView(accessToken: widget.accessToken!,
            onUpdated: (user) { widget.onProfileUpdated?.call(user); },
            onLoggedOut: () { widget.onLogout?.call(); })),
      if (widget.accessToken != null && widget.isAdministrator)
        _NavPage('users', 'Gestión de usuarios', Icons.admin_panel_settings_outlined,
          UsersAdminView(accessToken: widget.accessToken!)),
      _NavPage('privacy', 'Privacidad del prototipo', Icons.privacy_tip_outlined, PrivacyNoticeView()),
    ]),
  ];

  _NavPage get _active => _groups.expand((group) => group.pages)
      .firstWhere((page) => page.id == _selected);

  void _navigate(String next, bool wide) {
    setState(() => _selected = next);
    if (!wide) Navigator.of(context).pop();
  }

  Widget _logo() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        'assets/branding/piuttec-ii-logo.png',
        width: 225, height: 75, fit: BoxFit.contain,
        semanticLabel: 'PIUTTEC II',
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1030;
    final active = _active;
    final navigation = SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF079D60), Color(0xFF00664E), Color(0xFF003F4A)],
        )),
        child: Column(children: [
          _logo(),
          const Divider(color: Colors.white24),
          Expanded(child: ListView(children: [
            for (final group in _groups)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey<String>(group.title),
                  initiallyExpanded: group.pages.any((page) => page.id == _selected),
                  leading: Icon(group.icon, color: Colors.white),
                  title: Text(group.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    for (final page in group.pages)
                      ListTile(
                        selected: _selected == page.id,
                        selectedTileColor: Colors.white24,
                        leading: Icon(page.icon, color: Colors.white70, size: 19),
                        title: Text(page.label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        onTap: () => _navigate(page.id, wide),
                      ),
                  ],
                ),
              ),
          ])),
          const Divider(color: Colors.white24),
          ListTile(
            title: Text(widget.username ?? 'Invitado', style: const TextStyle(color: Colors.white)),
            subtitle: Text(widget.demoMode ? 'Vista previa' : 'Sesión activa', style: const TextStyle(color: Colors.white70)),
            leading: const Icon(Icons.account_circle_outlined, color: Colors.white),
            onTap: widget.accessToken == null ? null : () => setState(() => _selected = 'profile'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout), label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
            ),
          ),
        ]),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(active.label),
      ),
      drawer: wide ? null : Drawer(width: 315, child: navigation),
      body: Row(children: [
        if (wide) SizedBox(width: 315, child: navigation),
        if (wide) const VerticalDivider(width: 1),
        Expanded(child: KeyedSubtree(key: ValueKey<String>("$_selected:${widget.accessToken ?? 'demo'}"), child: active.page)),
      ]),
    );
  }
}
