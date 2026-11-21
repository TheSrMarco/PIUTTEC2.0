import 'package:flutter/material.dart';

// Visual previews only. These views do not read or modify academic records.
class SubjectsPreview extends StatelessWidget {
  const SubjectsPreview({super.key});

  @override
  Widget build(BuildContext context) => _PreviewPage(
    title: 'Tu cuatrimestre, en un solo lugar',
    description: 'Consulta tus materias, horarios y avance académico.',
    children: [
      const _Metrics(
        items: [
          ('Materias', '4'),
          ('Promedio', '8.9'),
          ('Cuatrimestre', '6.º'),
        ],
      ),
      const _Heading('Materias inscritas'),
      for (final subject in _subjects)
        _InfoCard(
          icon: subject.icon,
          title: subject.name,
          badge: '${subject.grade}',
          description: '${subject.schedule}\n${subject.room}',
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Avance del curso · ${subject.progress}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: subject.progress / 100,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      const _Heading('Rendimiento por materia'),
      const Text('Comparación ilustrativa con el promedio del grupo.'),
      const SizedBox(height: 12),
      for (final subject in _subjects)
        _InfoCard(
          icon: Icons.bar_chart_outlined,
          title: subject.name,
          description:
              'Tu calificación: ${subject.grade}   ·   Promedio grupal: ${subject.groupGrade}',
        ),
    ],
  );
}

class AttendancePreview extends StatelessWidget {
  const AttendancePreview({super.key});

  @override
  Widget build(BuildContext context) => _PreviewPage(
    title: 'Cada clase cuenta',
    description: 'Resumen de asistencia y seguimiento de justificantes.',
    children: [
      const _Metrics(
        items: [('Asistencia', '93%'), ('Asistencias', '42'), ('Faltas', '3')],
      ),
      const _Heading('Asistencia por materia'),
      for (final item in [
        ('Redes digitales', '12 de 13 clases', '92%'),
        ('Programación', '11 de 12 clases', '92%'),
        ('Matemáticas', '10 de 10 clases', '100%'),
        ('Inteligencia artificial', '9 de 10 clases', '90%'),
      ])
        _InfoCard(
          icon: Icons.fact_check_outlined,
          title: item.$1,
          description: item.$2,
          badge: item.$3,
        ),
      const _Heading('Últimos registros'),
      const _InfoCard(
        icon: Icons.check_circle_outline,
        title: 'Redes digitales',
        description: '18 de noviembre · 07:00 a 09:00',
        badge: 'Asistencia',
      ),
      const _InfoCard(
        icon: Icons.schedule_outlined,
        title: 'Programación',
        description: '17 de noviembre · 09:00 a 11:00',
        badge: 'Retardo',
      ),
      const _InfoCard(
        icon: Icons.event_busy_outlined,
        title: 'Inteligencia artificial',
        description: '16 de noviembre · 11:00 a 13:00',
        badge: 'Falta',
      ),
      const _Heading('Mis justificantes'),
      const _InfoCard(
        icon: Icons.description_outlined,
        title: 'Justificante de inasistencia',
        description: 'Folio de ejemplo JUS-003 · 16 de noviembre\nEn revisión por el área correspondiente.',
        badge: 'En revisión',
      ),
      const _PreviewAction(label: 'Solicitar justificante', icon: Icons.add),
    ],
  );
}

class FilesPreview extends StatelessWidget {
  const FilesPreview({super.key});

  @override
  Widget build(BuildContext context) => _PreviewPage(
    title: 'Tus recursos de estudio',
    description: 'Organiza apuntes, materiales y entregas por materia.',
    children: [
      const _Metrics(
        items: [
          ('Archivos', '8'),
          ('Carpetas', '4'),
          ('Espacio usado', '24 MB'),
        ],
      ),
      const _Heading('Carpetas por materia'),
      _ResponsiveCards(
        children: [
          for (final subject in _subjects)
            _InfoCard(
              icon: Icons.folder_outlined,
              title: subject.name,
              description: '2 archivos · Material de ejemplo',
            ),
        ],
      ),
      const _Heading('Archivos recientes'),
      const _InfoCard(
        icon: Icons.picture_as_pdf_outlined,
        title: 'Guía de subredes.pdf',
        description: 'Redes digitales · 2.4 MB · 18 de noviembre',
        badge: 'PDF',
      ),
      const _InfoCard(
        icon: Icons.code_outlined,
        title: 'Práctica de funciones.dart',
        description: 'Programación · 12 KB · 17 de noviembre',
        badge: 'Código',
      ),
      const _InfoCard(
        icon: Icons.slideshow_outlined,
        title: 'Introducción al perceptrón.pptx',
        description: 'Inteligencia artificial · 5.1 MB · 16 de noviembre',
        badge: 'Presentación',
      ),
      const _PreviewAction(
        label: 'Subir archivo',
        icon: Icons.upload_file_outlined,
      ),
    ],
  );
}

class ResourcesPreview extends StatelessWidget {
  const ResourcesPreview({super.key});

  @override
  Widget build(BuildContext context) => _PreviewPage(
    title: 'Espacios y herramientas para aprender',
    description: 'Consulta espacios, equipos y el estado de tus solicitudes.',
    children: [
      const _Metrics(
        items: [
          ('Espacios disponibles', '2'),
          ('Equipos disponibles', '8'),
          ('Solicitudes', '2'),
        ],
      ),
      const _Heading('Salones y laboratorios'),
      const _ResponsiveCards(
        children: [
          _InfoCard(
            icon: Icons.computer_outlined,
            title: 'Laboratorio de cómputo A',
            description: '30 lugares · Proyector · Internet\nHorario de ejemplo: 13:00 a 15:00',
            badge: 'Disponible',
          ),
          _InfoCard(
            icon: Icons.router_outlined,
            title: 'Laboratorio de redes',
            description: '24 lugares · Routers · Switches\nHorario de ejemplo: 15:00 a 17:00',
            badge: 'Disponible',
          ),
          _InfoCard(
            icon: Icons.meeting_room_outlined,
            title: 'Sala de trabajo colaborativo',
            description: '12 lugares · Pantalla\nSin disponibilidad en el horario mostrado.',
            badge: 'Ocupado',
          ),
        ],
      ),
      const _Heading('Préstamo de equipos'),
      const _InfoCard(
        icon: Icons.laptop_outlined,
        title: 'Laptop para prácticas',
        description: '5 unidades disponibles · Uso en instalaciones',
        badge: 'Disponible',
      ),
      const _InfoCard(
        icon: Icons.videocam_outlined,
        title: 'Proyector portátil',
        description: '3 unidades disponibles · Préstamo por sesión',
        badge: 'Disponible',
      ),
      const _PreviewAction(label: 'Nueva solicitud', icon: Icons.add),
      const _Heading('Seguimiento de solicitudes'),
      const _InfoCard(
        icon: Icons.pending_actions_outlined,
        title: 'Reserva de laboratorio de redes',
        description: 'RES-004 · 24 de noviembre · 15:00 a 17:00\nSolicitud recibida; pendiente de autorización.',
        badge: 'Pendiente',
      ),
      const _InfoCard(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Préstamo de laptop',
        description: 'PRE-002 · 23 de noviembre · 09:00 a 11:00\nEjemplo de una solicitud autorizada.',
        badge: 'Autorizado',
      ),
    ],
  );
}

class AgendaPreview extends StatelessWidget {
  const AgendaPreview({super.key});

  @override
  Widget build(BuildContext context) => _PreviewPage(
    title: 'Organiza tu próxima semana',
    description: 'Entregas, evaluaciones y clases en una misma agenda.',
    children: [
      const _Metrics(
        items: [
          ('Tareas pendientes', '3'),
          ('Evaluaciones', '1'),
          ('Entregadas', '2'),
        ],
      ),
      const _Heading('Próximas entregas'),
      const _InfoCard(
        icon: Icons.assignment_outlined,
        title: 'Práctica de direccionamiento IP',
        description: 'Redes digitales · 23 de noviembre · 23:59\nDiseñar el direccionamiento de dos subredes.',
        badge: 'Pendiente',
      ),
      const _InfoCard(
        icon: Icons.code_outlined,
        title: 'Ejercicios de funciones',
        description: 'Programación · 24 de noviembre · 18:00\nResolver los ejercicios de parámetros y retorno.',
        badge: 'En proceso',
      ),
      const _InfoCard(
        icon: Icons.psychology_outlined,
        title: 'Resumen del perceptrón',
        description: 'Inteligencia artificial · 25 de noviembre · 23:59\nRelacionar entradas, pesos y salida.',
        badge: 'Pendiente',
      ),
      const _Heading('Evaluaciones'),
      const _InfoCard(
        icon: Icons.quiz_outlined,
        title: 'Evaluación de derivadas',
        description: 'Matemáticas · 26 de noviembre · 09:00\nRepaso: reglas de derivación y aplicaciones.',
        badge: 'Programada',
      ),
      const _Heading('Horario de ejemplo'),
      for (final subject in _subjects)
        _InfoCard(
          icon: Icons.calendar_today_outlined,
          title: subject.name,
          description: '${subject.schedule} · ${subject.room}',
        ),
      const _PreviewAction(
        label: 'Agregar recordatorio',
        icon: Icons.notification_add_outlined,
      ),
    ],
  );
}

class DirectoryPreview extends StatelessWidget {
  const DirectoryPreview({super.key});

  @override
  Widget build(BuildContext context) => _PreviewPage(
    title: 'Tu comunidad académica',
    description: 'Directorio de referencia y resumen de tus calificaciones.',
    children: [
      const _Heading('Directorio docente'),
      _ResponsiveCards(
        children: [
          for (final subject in _subjects)
            _InfoCard(
              icon: Icons.person_outline,
              title: 'Docente de ${subject.name}',
              description: 'Contacto ilustrativo · Sin datos personales\nAtención: lunes a viernes, 13:00 a 14:00\nConsulta presencial en coordinación.',
            ),
        ],
      ),
      const _Heading('Áreas de apoyo'),
      const _InfoCard(
        icon: Icons.support_agent_outlined,
        title: 'Servicios escolares',
        description: 'Orientación sobre trámites y documentación.\nHorario de ejemplo: 09:00 a 16:00.',
      ),
      const _InfoCard(
        icon: Icons.school_outlined,
        title: 'Coordinación académica',
        description: 'Orientación sobre materias y seguimiento académico.\nHorario de ejemplo: 09:00 a 15:00.',
      ),
      const _Heading('Vista previa del promedio'),
      const _Metrics(
        items: [('Promedio simple', '8.9'), ('Materias consideradas', '4')],
      ),
      for (final subject in _subjects)
        _InfoCard(
          icon: subject.icon,
          title: subject.name,
          badge: '${subject.grade}',
          description: 'Calificación de ejemplo',
        ),
      const Text(
        'Promedio ilustrativo de cuatro calificaciones con el mismo peso. No representa un historial oficial.',
      ),
      const _PreviewAction(
        label: 'Editar calificaciones de ejemplo',
        icon: Icons.calculate_outlined,
      ),
    ],
  );
}

const _subjects = [
  (
    name: 'Redes digitales',
    grade: 9.2,
    groupGrade: 8.4,
    progress: 72,
    schedule: 'Lunes y miércoles · 07:00 a 09:00',
    room: 'Laboratorio de redes',
    icon: Icons.router_outlined,
  ),
  (
    name: 'Programación',
    grade: 8.7,
    groupGrade: 8.2,
    progress: 65,
    schedule: 'Martes y jueves · 09:00 a 11:00',
    room: 'Laboratorio de cómputo A',
    icon: Icons.code_outlined,
  ),
  (
    name: 'Matemáticas',
    grade: 9.0,
    groupGrade: 8.5,
    progress: 80,
    schedule: 'Lunes y jueves · 09:00 a 11:00',
    room: 'Aula 204',
    icon: Icons.functions,
  ),
  (
    name: 'Inteligencia artificial',
    grade: 8.5,
    groupGrade: 8.1,
    progress: 60,
    schedule: 'Miércoles y viernes · 11:00 a 13:00',
    room: 'Laboratorio de cómputo A',
    icon: Icons.psychology_outlined,
  ),
];

class _PreviewPage extends StatelessWidget {
  const _PreviewPage({
    required this.title,
    required this.description,
    required this.children,
  });
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Vista previa · Datos de ejemplo'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              ...children,
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 16),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.items});
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) => _ResponsiveCards(
    children: [
      for (final item in items)
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.$1, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  item.$2,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _ResponsiveCards extends StatelessWidget {
  const _ResponsiveCards({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900
          ? 3
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      final width = (constraints.maxWidth - 16 * (columns - 1)) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    this.footer,
  });
  final IconData icon;
  final String title;
  final String description;
  final String? badge;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (badge != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Chip(label: Text(badge!)),
            ),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(height: 1.6)),
          if (footer != null) ...[const SizedBox(height: 16), footer!],
        ],
      ),
    ),
  );
}

class _PreviewAction extends StatelessWidget {
  const _PreviewAction({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: null,
          icon: Icon(icon),
          label: Text(label),
        ),
        const SizedBox(height: 8),
        const Text(
          'Acción disponible en una próxima versión.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    ),
  );
}
