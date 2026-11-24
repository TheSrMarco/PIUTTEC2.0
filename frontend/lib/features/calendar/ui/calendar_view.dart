import 'package:flutter/material.dart';

import '../../agenda/data/agenda_repository.dart';
import '../../academia/data/academia_repository.dart';

/// Calendario con actividades de la agenda; conserva las fechas ilustrativas solo en vista previa.
class CalendarView extends StatefulWidget {
  const CalendarView({super.key, this.accessToken});
  final String? accessToken;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

enum _CalendarMode { month, week, day }

class _AcademicEvent {
  const _AcademicEvent(this.date, this.hour, this.title, this.subject, this.color,
      {this.isSample = false, this.completed = false, this.isClass = false});
  final DateTime date;
  final String hour;
  final String title;
  final String subject;
  final Color color;
  final bool isSample;
  final bool completed;
  final bool isClass;
}

class _CalendarViewState extends State<CalendarView> {
  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const _days = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
  static final _events = [
    _AcademicEvent(DateTime(2026, 11, 23), '10:00', 'Revisión de la documentación', 'Desarrollo Web Integral', Color(0xFF077F64), isSample: true),
    _AcademicEvent(DateTime(2026, 11, 24), '13:00', 'Entrega PIUTTEC 2.0', 'Proyecto académico', Color(0xFF0C9963), isSample: true),
    _AcademicEvent(DateTime(2026, 11, 25), '09:00', 'Actividad de inglés', 'Inglés VIII', Color(0xFFB7641D), isSample: true),
  ];

  late final AgendaRepository _agendaRepository;
  late final AcademiaRepository _academiaRepository;
  List<ClaseHorario> _clasesSemanales = [];
  String? _horarioError;
  List<_AcademicEvent> _savedEvents = [];
  String? _agendaError;

  @override
  void initState() {
    super.initState();
    _agendaRepository = AgendaRepository(accessToken: widget.accessToken);
    _academiaRepository = AcademiaRepository(accessToken: widget.accessToken);
    _loadAgenda();
    _loadHorarios();
  }

  @override
  void dispose() {
    _agendaRepository.dispose();
    _academiaRepository.dispose();
    super.dispose();
  }

  Future<void> _loadAgenda() async {
    try {
      final items = await _agendaRepository.listar();
      if (!mounted) return;
      setState(() {
        _savedEvents = items.map((item) {
          final color = switch (item.tipo) {
            'evaluacion' => const Color(0xFFAD6A1C),
            'evento' => const Color(0xFF2867B0),
            _ => const Color(0xFF079D60),
          };
          return _AcademicEvent(item.fecha, item.hora ?? '', item.titulo,
              item.materia, color, completed: item.completada);
        }).toList();
        _agendaError = null;
      });
    } catch (error) {
      if (mounted) setState(() => _agendaError = error.toString());
    }
  }

  Future<void> _loadHorarios() async {
    try {
      final horarios = await _academiaRepository.listarHorarios();
      if (!mounted) return;
      setState(() { _clasesSemanales = horarios; _horarioError = null; });
    } catch (error) {
      if (mounted) setState(() => _horarioError = error.toString());
    }
  }

  late DateTime _visible = _dateOnly(DateTime.now());
  late DateTime _selected = _dateOnly(DateTime.now());
  _CalendarMode _mode = _CalendarMode.month;

  static DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  static DateTime _startOfWeek(DateTime date) => _dateOnly(date.subtract(Duration(days: date.weekday % 7)));
  String _dayTitle(DateTime date) => '${date.day} de ${_months[date.month - 1]} de ${date.year}';
  List<_AcademicEvent> _eventsOn(DateTime date) => [
    if (_agendaRepository.local) ..._events.where((event) => _sameDay(event.date, date)),
    ..._savedEvents.where((event) => _sameDay(event.date, date)),
    ..._clasesSemanales.where((horario) => horario.ocurreEnFecha(date)).map((horario) =>
      _AcademicEvent(date, '${horario.inicio}–${horario.fin}',
        horario.materiaNombre, horario.aula.isEmpty ? 'Clase semanal' : 'Aula ${horario.aula}',
        const Color(0xFF0E9876), isClass: true)),
  ];

  void _move(int amount) {
    setState(() {
      switch (_mode) {
        case _CalendarMode.month:
          _visible = DateTime(_visible.year, _visible.month + amount, 1);
          break;
        case _CalendarMode.week:
          _visible = _visible.add(Duration(days: 7 * amount));
          break;
        case _CalendarMode.day:
          _visible = _visible.add(Duration(days: amount));
          break;
      }
      _selected = _visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 720;
      final period = switch (_mode) {
        _CalendarMode.month => '${_months[_visible.month - 1]} de ${_visible.year}',
        _CalendarMode.week => '${_dayTitle(_startOfWeek(_visible))} · semana',
        _CalendarMode.day => _dayTitle(_visible),
      };
      return ListView(
        padding: EdgeInsets.all(compact ? 12 : 26),
        children: [
          Wrap(spacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('Calendario académico', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            IconButton(onPressed: () { _loadAgenda(); _loadHorarios(); }, tooltip: 'Actualizar calendario', icon: const Icon(Icons.refresh)),
          ]),
          if (_agendaError != null) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('No se pudo actualizar la agenda: $_agendaError'),
          ),
          if (_horarioError != null) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('No se pudieron cargar los horarios: $_horarioError'),
          ),
          const SizedBox(height: 17),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(compact ? 9 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () => _move(-1), icon: const Icon(Icons.chevron_left), tooltip: 'Anterior'),
                        IconButton(onPressed: () => _move(1), icon: const Icon(Icons.chevron_right), tooltip: 'Siguiente'),
                        OutlinedButton(onPressed: () => setState(() { _visible = _dateOnly(DateTime.now()); _selected = _visible; }), child: const Text('Hoy')),
                      ]),
                      Text(period, style: TextStyle(fontSize: compact ? 18 : 24, fontWeight: FontWeight.w800)),
                      SegmentedButton<_CalendarMode>(
                        showSelectedIcon: false,
                        style: const ButtonStyle(visualDensity: VisualDensity.compact),
                        segments: const [
                          ButtonSegment(value: _CalendarMode.month, label: Text('Mes')),
                          ButtonSegment(value: _CalendarMode.week, label: Text('Semana')),
                          ButtonSegment(value: _CalendarMode.day, label: Text('Día')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (selection) => setState(() { _mode = selection.first; _visible = _selected; }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  if (_mode == _CalendarMode.month) _monthGrid(context, compact),
                  if (_mode == _CalendarMode.week) _weekGrid(context, compact),
                  if (_mode == _CalendarMode.day) _dayAgenda(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Agenda del ${_dayTitle(_selected)}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (_eventsOn(_selected).isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('No hay actividades registradas para esta fecha.')),
                for (final event in _eventsOn(_selected))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: event.color.withValues(alpha: .14), child: Icon(Icons.event_note, color: event.color)),
                    title: Text(event.title),
                    subtitle: Text([
                      if (event.hour.isNotEmpty) event.hour,
                      if (event.subject.isNotEmpty) event.subject,
                    ].join(' · ')),
                    trailing: Chip(label: Text(event.isClass ? 'Clase' : event.isSample ? 'Ejemplo' : event.completed ? 'Hecha' : 'Agenda')),
                  ),
              ]),
            ),
          ),
        ],
      );
    });
  }

  Widget _dayTile(BuildContext context, DateTime date, {required bool compact, bool outside = false}) {
    final selected = _sameDay(date, _selected);
    final today = _sameDay(date, _dateOnly(DateTime.now()));
    final events = _eventsOn(date);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => setState(() { _selected = date; _visible = date; }),
      child: Container(
        height: compact ? 66 : 103,
        padding: EdgeInsets.all(compact ? 4 : 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer.withValues(alpha: .52) : Colors.transparent,
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: .45), width: .5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: today ? scheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(50)),
            child: Text('${date.day}', style: TextStyle(
              color: today ? scheme.onPrimary : outside ? scheme.onSurface.withValues(alpha: .36) : scheme.onSurface,
              fontSize: compact ? 11 : 13,
              fontWeight: today || selected ? FontWeight.bold : FontWeight.normal,
            )),
          ),
          const Spacer(),
          if (events.isNotEmpty)
            compact
                ? Align(alignment: Alignment.bottomCenter, child: Wrap(spacing: 2, children: [
                    for (final item in events.take(3)) Container(width: 6, height: 6, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
                  ]))
                : Align(alignment: Alignment.bottomLeft, child: Column(children: [
                    for (final item in events.take(2)) Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(color: item.color.withValues(alpha: .1), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: item.color, fontWeight: FontWeight.w700)),
                    ),
                  ])),
        ]),
      ),
    );
  }

  Widget _weekdayHeader(BuildContext context) {
    return Row(children: [
      for (final day in _days)
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(day, textAlign: TextAlign.center, style: TextStyle(
            color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        )),
    ]);
  }

  Widget _monthGrid(BuildContext context, bool compact) {
    final first = DateTime(_visible.year, _visible.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    return Column(children: [
      _weekdayHeader(context),
      for (var week = 0; week < 6; week++)
        Row(children: [
          for (var day = 0; day < 7; day++)
            Expanded(child: _dayTile(context, DateTime(start.year, start.month, start.day + week * 7 + day),
              compact: compact,
              outside: DateTime(start.year, start.month, start.day + week * 7 + day).month != _visible.month)),
        ]),
    ]);
  }

  Widget _weekGrid(BuildContext context, bool compact) {
    final start = _startOfWeek(_visible);
    return Column(children: [
      _weekdayHeader(context),
      Row(children: [
        for (var day = 0; day < 7; day++)
          Expanded(child: _dayTile(context, DateTime(start.year, start.month, start.day + day), compact: compact)),
      ]),
    ]);
  }

  Widget _dayAgenda(BuildContext context) {
    final events = _eventsOn(_visible);
    return Column(children: [
      for (final event in events.where((e) => e.hour.isEmpty))
        ListTile(leading: const Icon(Icons.event_outlined),
          title: Text(event.title),
          subtitle: Text(event.subject.isEmpty ? 'Sin hora' : '${event.subject} · sin hora')),
      for (var hour = 8; hour < 20; hour++)
        Container(
          constraints: const BoxConstraints(minHeight: 47),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant))),
          child: Row(children: [
            SizedBox(width: 66, child: Text('${hour.toString().padLeft(2, '0')}:00', style: Theme.of(context).textTheme.labelSmall)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final event in events.where((e) => int.tryParse(e.hour.split(':').first) == hour))
                Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Chip(label: Text('${event.hour} · ${event.title}'),
                  avatar: CircleAvatar(backgroundColor: event.color, radius: 5))),
            ])),
          ]),
        ),
    ]);
  }
}
