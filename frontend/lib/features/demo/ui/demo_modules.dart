import 'package:flutter/material.dart';

/// Pantallas de demostración. La etiqueta "Datos de ejemplo" evita confundir
/// esta interfaz con un módulo conectado a registros institucionales.
class DemoModuleView extends StatefulWidget {
  const DemoModuleView({super.key, required this.module});
  final String module;

  @override
  State<DemoModuleView> createState() => _DemoModuleViewState();
}

class _DemoModuleViewState extends State<DemoModuleView> {
  final Set<int> _doneTasks = <int>{};
  String _selectedFilter = 'Todas';

  void _demoAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action: vista demostrativa. La operación real requiere conexión con Django.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _moduleInfo(widget.module);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(info.$2, size: 35, color: Theme.of(context).colorScheme.primary),
            Text(info.$1, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        Text(info.$3, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        ..._buildContent(widget.module),
      ],
    );
  }

  (String, IconData, String) _moduleInfo(String id) {
    switch (id) {
      case 'dashboard': return ('Mi actividad académica', Icons.dashboard_outlined, 'Consulta rápida de tu cuatrimestre y próximos compromisos.');
      case 'materias': return ('Mis materias', Icons.menu_book_outlined, 'Calificaciones, docentes y seguimiento por asignatura.');
      case 'asistencias': return ('Asistencias', Icons.fact_check_outlined, 'Consulta de asistencias y alertas preventivas.');
      case 'archivos': return ('Gestor de archivos', Icons.folder_open_outlined, 'Documentos y materiales por materia.');
      case 'reservas': return ('Salones y equipos', Icons.meeting_room_outlined, 'Consulta de recursos y vista previa del flujo de préstamos.');
      case 'agenda': return ('Agenda y tareas', Icons.event_note_outlined, 'Calendario de actividades, evaluaciones y entregas.');
      case 'directorio': return ('Directorio y promedio', Icons.calculate_outlined, 'Contacto docente y comparativo académico.');
      case 'tramites': return ('Trámites y justificantes', Icons.description_outlined, 'Seguimiento visual de solicitudes administrativas.');
      default: return ('Módulo', Icons.school_outlined, 'En preparación.');
    }
  }

  List<Widget> _buildContent(String module) {
    switch (module) {
      case 'dashboard': return _dashboard();
      case 'materias': return _materias();
      case 'asistencias': return _asistencias();
      case 'archivos': return _archivos();
      case 'reservas': return _reservas();
      case 'agenda': return _agenda();
      case 'directorio': return _directorio();
      case 'tramites': return _tramites();
      default: return [const Text('Módulo en preparación.')];
    }
  }

  Widget _panel({required String title, required Widget child, IconData? icon}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [if (icon != null) Icon(icon, size: 20), if (icon != null) const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 13),
            child,
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon, {String? detail}) {
    return SizedBox(
      width: 215,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(title),
              if (detail != null) Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String subtitle, IconData icon, {String? status, VoidCallback? action, String? actionLabel}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        isThreeLine: subtitle.contains('\n'),
        trailing: action == null
          ? (status == null ? null : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 95), child: Text(status, textAlign: TextAlign.end)))
          : TextButton(onPressed: action, child: Text(actionLabel ?? 'Ver')),
      ),
    );
  }

  List<Widget> _dashboard() => [
    const Text('¡Bienvenido al cuatrimestre septiembre–diciembre 2026!'),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: [
      _stat('Promedio general', '9.1', Icons.insights_outlined),
      _stat('Asistencia', '92 %', Icons.event_available_outlined),
      _stat('Materias activas', '6', Icons.menu_book_outlined),
      _stat('Tareas pendientes', '3', Icons.assignment_outlined),
    ]),
    const SizedBox(height: 20),
    _panel(title: 'Próximas entregas', icon: Icons.event_outlined, child: Column(children: [
      _row('Proyecto integrador', 'Desarrollo Web Integral · Mar 24 nov', Icons.code, status: 'Próximo'),
      _row('Reporte de pruebas', 'Gestión de Software · Lun 23 nov', Icons.fact_check_outlined, status: 'Pendiente'),
      _row('Revisión de diagramas', 'Arquitectura · Mar 24 nov', Icons.account_tree_outlined, status: 'En progreso'),
    ])),
    const SizedBox(height: 12),
    _panel(title: 'Avisos académicos', icon: Icons.notifications_none, child: const Text('Recuerda revisar el calendario de actividades y las solicitudes de préstamo de equipos.')),
  ];

  List<Widget> _materias() {
    const data = [
      ('Desarrollo Web Integral', 'Lorena Ramírez · 9.4', 0.94),
      ('Dirección de Equipos', 'Docente de asignatura · 9.2', 0.92),
      ('Extracción de Conocimiento', 'Docente de asignatura · 9.0', 0.90),
      ('Inglés VIII', 'Docente de asignatura · 8.8', 0.88),
      ('Integración de Sistemas', 'Docente de asignatura · 9.1', 0.91),
      ('Gestión de Proyectos', 'Docente de asignatura · 9.3', 0.93),
    ];
    return [
      Wrap(spacing: 8, runSpacing: 8, children: [_stat('Asignaturas activas', '6', Icons.menu_book), _stat('Promedio simulado', '9.1', Icons.insights)]),
      const SizedBox(height: 16),
      for (final item in data) _panel(title: item.$1, icon: Icons.class_outlined, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(item.$2), const SizedBox(height: 10), LinearProgressIndicator(value: item.$3), const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _demoAction('Detalle de la materia'), icon: const Icon(Icons.open_in_new), label: const Text('Ver detalles')))],
      )),
    ];
  }

  List<Widget> _asistencias() => [
    Wrap(spacing: 8, runSpacing: 8, children: [_stat('Asistencia global', '92 %', Icons.check_circle_outline), _stat('Inasistencias', '4', Icons.event_busy_outlined), _stat('Retardos', '2', Icons.access_time_outlined)]),
    const SizedBox(height: 18),
    _panel(title: 'Asistencias por asignatura', icon: Icons.fact_check_outlined, child: Column(children: [
      for (final item in <(String, double)>[
        ('Desarrollo Web Integral', 0.96), ('Inglés VIII', 0.88), ('Gestión de Proyectos', 0.93), ('Extracción de Conocimiento', 0.91),
      ]) Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Column(children: [
        Row(children: [Expanded(child: Text(item.$1)), Text('${(item.$2 * 100).round()} %')]),
        const SizedBox(height: 7), LinearProgressIndicator(value: item.$2),
      ])),
    ])),
    _panel(title: 'Control por fecha', icon: Icons.calendar_today_outlined, child: Column(children: [
      _row('Viernes 20 de noviembre', 'Desarrollo Web Integral', Icons.event_available, status: 'Presente'),
      _row('Jueves 19 de noviembre', 'Inglés VIII', Icons.event_available, status: 'Presente'),
      _row('Miércoles 18 de noviembre', 'Gestión de Proyectos', Icons.schedule_outlined, status: 'Retardo'),
    ])),
  ];

  List<Widget> _archivos() => [
    _panel(title: 'Carpetas académicas', icon: Icons.folder_outlined, child: Wrap(spacing: 8, runSpacing: 8, children: [
      for (final item in ['Desarrollo Web', 'Inglés', 'Gestión de Proyectos', 'Extracción de Conocimiento'])
        ActionChip(avatar: const Icon(Icons.folder_open_outlined, size: 16), label: Text(item), onPressed: () => _demoAction('Abrir carpeta $item')),
    ])),
    const SizedBox(height: 12),
    _panel(title: 'Documentos recientes', icon: Icons.description_outlined, child: Column(children: [
      _row('Reporte_Proyecto.pdf', 'Desarrollo Web · 18 nov 2026', Icons.picture_as_pdf_outlined, status: 'PDF'),
      _row('Evidencias_Parcial.docx', 'Gestión de Proyectos · 17 nov 2026', Icons.description_outlined, status: 'DOCX'),
      _row('Resultados_Pruebas.csv', 'Extracción de Conocimiento · 16 nov 2026', Icons.table_chart_outlined, status: 'CSV'),
      Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => _demoAction('Subir archivo'), icon: const Icon(Icons.upload_file), label: const Text('Subir archivo'))),
    ])),
  ];

  List<Widget> _reservas() => [
    _panel(title: 'Disponibilidad de recursos (simulada)', icon: Icons.meeting_room_outlined, child: Column(children: [
      _row('Laboratorio de Redes', 'Capacidad: 28 equipos · Edificio TIC', Icons.lan_outlined,
        action: () => _demoAction('Solicitud de Laboratorio de Redes'), actionLabel: 'Solicitar'),
      _row('Laboratorio de Software', 'Capacidad: 32 equipos · Edificio TIC', Icons.computer_outlined,
        action: () => _demoAction('Solicitud de Laboratorio de Software'), actionLabel: 'Solicitar'),
      _row('Proyector multimedia', 'Equipo portátil · Inventario TIC', Icons.videocam_outlined,
        action: () => _demoAction('Solicitud de proyector'), actionLabel: 'Solicitar'),
      _row('Laptop de préstamo', 'Equipo de cómputo · Inventario TIC', Icons.laptop_outlined,
        action: () => _demoAction('Solicitud de laptop'), actionLabel: 'Solicitar'),
    ])),
    const SizedBox(height: 12),
    _panel(title: 'Mis préstamos', icon: Icons.history_outlined, child: Column(children: [
      _row('Laboratorio de Software', 'Jueves 19 nov · 12:00–14:00', Icons.meeting_room_outlined, status: 'Ejemplo'),
      _row('Proyector multimedia', 'Martes 17 nov · 10:00–12:00', Icons.videocam_outlined, status: 'Ejemplo'),
    ])),
  ];

  List<Widget> _agenda() {
    const tasks = [
      ('Entrega PIUTTEC 2.0', '24 nov · Desarrollo Web Integral'),
      ('Revisión de documentación', '23 nov · Gestión de Proyectos'),
      ('Examen diagnóstico de inglés', '25 nov · Inglés VIII'),
      ('Presentación de resultados', '26 nov · Extracción de Conocimiento'),
    ];
    return [
      Wrap(spacing: 8, runSpacing: 8, children: [
        _stat('Tareas', '${tasks.length}', Icons.task_alt_outlined),
        _stat('Marcadas en esta vista', '${_doneTasks.length}', Icons.done_all_outlined),
      ]),
      const SizedBox(height: 16),
      _panel(title: 'Próximas tareas', icon: Icons.event_note_outlined, child: Column(children: [
        for (var index = 0; index < tasks.length; index++) CheckboxListTile(
          value: _doneTasks.contains(index),
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(tasks[index].$1), subtitle: Text(tasks[index].$2),
          onChanged: (value) => setState(() {
            if (value ?? false) {
              _doneTasks.add(index);
            } else {
              _doneTasks.remove(index);
            }
          }),
        ),
        const Text('Las marcas de esta pantalla solo duran mientras la vista está abierta.'),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _demoAction('Añadir tarea'), icon: const Icon(Icons.add), label: const Text('Nueva tarea'))),
      ])),
    ];
  }

  List<Widget> _directorio() => [
    Wrap(spacing: 8, runSpacing: 8, children: [
      _stat('Promedio personal', '9.1', Icons.person_outline),
      _stat('Promedio grupal', '8.7', Icons.groups_outlined),
    ]),
    const SizedBox(height: 14),
    _panel(title: 'Comparativo por materia', icon: Icons.bar_chart_outlined, child: Column(children: [
      for (final item in <(String, double, double)>[
        ('Desarrollo Web Integral', 0.94, 0.85), ('Inglés VIII', 0.88, 0.84),
        ('Gestión de Proyectos', 0.93, 0.89), ('Extracción de Conocimiento', 0.90, 0.87),
      ]) Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(item.$1), const SizedBox(height: 5),
          LinearProgressIndicator(value: item.$2), const SizedBox(height: 4),
          LinearProgressIndicator(value: item.$3, color: Colors.blueGrey),
        ],
      )),
      const Wrap(spacing: 12, children: [Chip(label: Text('Primera barra: alumno')), Chip(label: Text('Segunda: grupo'))]),
    ])),
    _panel(title: 'Directorio académico (demostración)', icon: Icons.contacts_outlined, child: Column(children: [
      _row('Coordinación de carrera', 'Atención de estudiantes', Icons.apartment_outlined, action: () => _demoAction('Ver directorio')),
      _row('Servicios escolares', 'Trámites y constancias', Icons.support_agent_outlined, action: () => _demoAction('Ver contacto')),
    ])),
  ];

  List<Widget> _tramites() {
    const items = [
      ('Justificante de inasistencia', 'Ejemplo: 17 nov · Inglés VIII', 'En revisión'),
      ('Constancia de estudios', 'Ejemplo: 13 nov · Servicios escolares', 'Aprobado'),
      ('Préstamo de laboratorio', 'Ejemplo: 10 nov · Laboratorio TIC', 'Devuelto'),
    ];
    final filtered = _selectedFilter == 'Todas' ? items : items.where((x) => x.$3 == _selectedFilter).toList();
    return [
      _panel(title: 'Historial visual', icon: Icons.receipt_long_outlined, child: Column(children: [
        Wrap(spacing: 8, children: [for (final filter in ['Todas', 'En revisión', 'Aprobado', 'Devuelto'])
          ChoiceChip(label: Text(filter), selected: _selectedFilter == filter,
            onSelected: (_) => setState(() => _selectedFilter = filter))]),
        const SizedBox(height: 12),
        for (final item in filtered) _row(item.$1, item.$2, Icons.article_outlined, status: item.$3),
        Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => _demoAction('Crear justificante'), icon: const Icon(Icons.add_circle_outline), label: const Text('Nuevo trámite'))),
      ])),
    ];
  }
}
