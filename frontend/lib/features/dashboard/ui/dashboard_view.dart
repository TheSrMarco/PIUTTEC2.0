import 'package:flutter/material.dart';

import '../data/dashboard_repository.dart';
import 'dashboard_view_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, this.accessToken});

  final String? accessToken;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = DashboardViewModel(DashboardRepository(accessToken: widget.accessToken));
    _model.load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _number(int? value) => value?.toString() ?? 'N/D';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, child) {
        if (_model.loading && _model.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_model.error case final error?) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: _model.load,
                icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
            ]),
          ));
        }
        final data = _model.data;
        if (data == null) return const SizedBox.shrink();
        final metrics = <(String, String, IconData)>[
          ('Materias registradas', '${data.subjectCount}', Icons.menu_book_outlined),
          ('Promedio personal', data.average?.toStringAsFixed(2) ?? 'N/D', Icons.school_outlined),
          ('Materias evaluadas', '${data.gradedSubjects}', Icons.grading_outlined),
          ('Actividades pendientes', '${data.pendingTasks}', Icons.checklist_outlined),
          ('Actividades completadas', '${data.completedTasks}', Icons.task_alt_outlined),
          ('Clases por semana', '${data.weeklyClasses}', Icons.schedule_outlined),
          ('Solicitudes pendientes', _number(data.pendingRequests), Icons.pending_actions_outlined),
          ('Solicitudes aprobadas', _number(data.approvedRequests), Icons.assignment_turned_in_outlined),
          ('Asistencia personal', data.attendance == null ? 'N/D' : '${data.attendance!.toStringAsFixed(0)}%', Icons.fact_check_outlined),
          if (!data.local) ('Días-materia registrados', '${data.attendanceRecords}', Icons.fact_check_outlined),
          ('Archivos', _number(data.fileCount), Icons.folder_open_outlined),
        ];
        return RefreshIndicator(
          onRefresh: _model.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              Row(children: [
                Expanded(child: Text('Tu actividad académica',
                    style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(tooltip: 'Actualizar datos', onPressed: _model.loading ? null : _model.load,
                    icon: const Icon(Icons.refresh)),
              ]),
              const SizedBox(height: 6),
              Text(data.local
                  ? 'Vista previa: resumen de tus materias y actividades guardadas en este navegador.'
                  : 'Resumen de los registros asociados a tu cuenta de Django.'),
              const SizedBox(height: 8),
              Text(data.local
                  ? 'La asistencia del pase local es demostrativa y no alimenta este panel. Los archivos se consultan al iniciar sesión.'
                  : 'Asistencia = registros personales de práctica, no datos oficiales. N/D = sin registros.',
                style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050 ? 4
                    : constraints.maxWidth >= 640 ? 2 : 1;
                final width = (constraints.maxWidth - 14 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 14, runSpacing: 14,
                  children: [
                    for (final metric in metrics)
                      SizedBox(width: width, child: Card(margin: EdgeInsets.zero,
                        child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
                          Icon(metric.$3, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(metric.$1, style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Text(metric.$2, style: Theme.of(context).textTheme.headlineSmall),
                            ])),
                        ]))),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 26),
              Text('Mis materias', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              if (data.subjects.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(18),
                    child: Text('No hay materias registradas. Añádelas en Academia → Materias y calificaciones.')))
              else
                for (final subject in data.subjects)
                  Card(child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(subject.name),
                    subtitle: subject.group.isEmpty ? null : Text('Grupo ${subject.group}'),
                    trailing: Text(subject.grade == null ? 'Sin calificar'
                      : subject.grade!.toStringAsFixed(2)),
                  )),
              const SizedBox(height: 22),
              Text('Próximas actividades', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              if (data.upcoming.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(18),
                    child: Text('No hay próximas actividades sin completar.')))
              else
                for (final item in data.upcoming)
                  Card(child: ListTile(
                    leading: Icon(item.type == 'evaluacion' ? Icons.edit_note_outlined
                      : item.type == 'evento' ? Icons.event_outlined : Icons.task_outlined),
                    title: Text(item.title),
                    subtitle: Text([item.date, if (item.subject.isNotEmpty) item.subject].join(' · ')),
                    trailing: Text(item.type),
                  )),
            ],
          ),
        );
      },
    );
  }
}
