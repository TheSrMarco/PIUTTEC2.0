import 'package:flutter/material.dart';

import '../data/academia_repository.dart';

enum AcademiaSeccion { materias, horarios }

/// RF-02: materias y horarios editables, sin tocar pase de lista ni calificaciones oficiales.
class AcademiaView extends StatefulWidget {
  const AcademiaView({super.key, this.accessToken,
    this.seccion = AcademiaSeccion.materias});
  final String? accessToken;
  final AcademiaSeccion seccion;

  @override
  State<AcademiaView> createState() => _AcademiaViewState();
}

class _AcademiaViewState extends State<AcademiaView> {
  static const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  late final AcademiaRepository _repository;
  List<MateriaAcademica> _materias = [];
  List<ClaseHorario> _horarios = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = AcademiaRepository(accessToken: widget.accessToken);
    _cargar();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final materias = await _repository.listarMaterias();
      final horarios = await _repository.listarHorarios();
      if (mounted) setState(() { _materias = materias; _horarios = horarios; });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mensaje(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _guardarMateria([MateriaAcademica? previous]) async {
    final formKey = GlobalKey<FormState>();
    var nombre = previous?.nombre ?? '';
    var docente = previous?.docente ?? '';
    var aula = previous?.aula ?? '';
    var grupo = previous?.grupo ?? '';
    var nota = previous?.calificacion?.toStringAsFixed(2) ?? '';
    try {
      final result = await showDialog<MateriaAcademica>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(previous == null ? 'Nueva materia' : 'Editar materia'),
          content: SizedBox(width: 440, child: SingleChildScrollView(
            child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                key: const Key('materia-nombre'), initialValue: nombre,
                onChanged: (value) => nombre = value, maxLength: 120,
                decoration: const InputDecoration(labelText: 'Materia *'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Indica el nombre' : null,
              ),
              TextFormField(initialValue: docente, onChanged: (value) => docente = value, maxLength: 120,
                decoration: const InputDecoration(labelText: 'Docente (opcional)')),
              TextFormField(initialValue: grupo, onChanged: (value) => grupo = value, maxLength: 50,
                decoration: const InputDecoration(labelText: 'Grupo (opcional)')),
              TextFormField(initialValue: aula, onChanged: (value) => aula = value, maxLength: 80,
                decoration: const InputDecoration(labelText: 'Aula habitual (opcional)')),
              TextFormField(
                initialValue: nota, onChanged: (value) => nota = value,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Calificación (opcional, 0–10)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed < 0 || parsed > 10) return 'Utiliza una calificación entre 0 y 10';
                  if (!RegExp(r'^\d{1,2}([.,]\d{1,2})?$').hasMatch(value.trim())) return 'Máximo dos decimales';
                  return null;
                },
              ),
            ]))),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(key: const Key('materia-guardar'), onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final rawNota = nota.trim().replaceAll(',', '.');
              Navigator.pop(dialogContext, MateriaAcademica(
                id: previous?.id ?? 0, nombre: nombre.trim(),
                docente: docente.trim(), grupo: grupo.trim(),
                aula: aula.trim(),
                calificacion: rawNota.isEmpty ? null : double.parse(rawNota),
              ));
            }, child: const Text('Guardar')),
          ],
        ),
      );
      if (result == null) return;
      await _repository.guardarMateria(result);
      await _cargar();
      _mensaje('Materia guardada.');
    } catch (error) {
      _mensaje('No se pudo guardar la materia: $error');
    }
  }

  TimeOfDay _time(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _timeText(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _guardarHorario([ClaseHorario? previous]) async {
    if (_materias.isEmpty) {
      _mensaje('Primero registra una materia.');
      return;
    }
    var materiaId = previous?.materiaId ?? _materias.first.id;
    var dia = previous?.diaSemana ?? 1;
    var inicio = previous == null ? const TimeOfDay(hour: 8, minute: 0) : _time(previous.inicio);
    var fin = previous == null ? const TimeOfDay(hour: 9, minute: 0) : _time(previous.fin);
    var aula = previous?.aula ?? '';
    try {
      final result = await showDialog<ClaseHorario>(context: context,
        builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, update) => AlertDialog(
          title: Text(previous == null ? 'Nueva clase semanal' : 'Editar horario'),
          content: SizedBox(width: 440, child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: materiaId,
                decoration: const InputDecoration(labelText: 'Materia'),
                items: [for (final m in _materias)
                  DropdownMenuItem(value: m.id, child: Text(m.nombre, overflow: TextOverflow.ellipsis))],
                onChanged: (value) { if (value != null) update(() => materiaId = value); },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                initialValue: dia,
                decoration: const InputDecoration(labelText: 'Día de la semana'),
                items: [for (var i = 1; i <= 7; i++) DropdownMenuItem(value: i, child: Text(_dias[i - 1]))],
                onChanged: (value) { if (value != null) update(() => dia = value); },
              ),
              const SizedBox(height: 15),
              Wrap(spacing: 12, runSpacing: 9, children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text('Inicio ${_timeText(inicio)}'),
                  onPressed: () async {
                    final chosen = await showTimePicker(context: dialogContext, initialTime: inicio);
                    if (chosen != null) update(() => inicio = chosen);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text('Fin ${_timeText(fin)}'),
                  onPressed: () async {
                    final chosen = await showTimePicker(context: dialogContext, initialTime: fin);
                    if (chosen != null) update(() => fin = chosen);
                  },
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(initialValue: aula, onChanged: (value) => aula = value, maxLength: 80,
                decoration: const InputDecoration(labelText: 'Aula (opcional)')),
            ],
          ))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(key: const Key('horario-guardar'), onPressed: () {
              final start = _timeText(inicio);
              final end = _timeText(fin);
              if (start.compareTo(end) >= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(
                  content: Text('La hora final debe ser posterior a la inicial.')));
                return;
              }
              Navigator.pop(dialogContext, ClaseHorario(
                id: previous?.id ?? 0, materiaId: materiaId,
                diaSemana: dia, inicio: start, fin: end, aula: aula.trim(),
              ));
            }, child: const Text('Guardar')),
          ],
        )),
      );
      if (result == null) return;
      await _repository.guardarHorario(result);
      await _cargar();
      _mensaje('Horario guardado. Visible también en el calendario.');
    } catch (error) {
      _mensaje('No se pudo guardar el horario: $error');
    }
  }

  Future<void> _eliminarMateria(MateriaAcademica materia) async {
    final count = _horarios.where((h) => h.materiaId == materia.id).length;
    final confirmed = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text('¿Eliminar «${materia.nombre}» y sus $count horario(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ));
    if (confirmed != true) return;
    try {
      await _repository.eliminarMateria(materia.id);
      await _cargar();
    } catch (error) { _mensaje('No se pudo eliminar: $error'); }
  }

  Future<void> _eliminarHorario(ClaseHorario horario) async {
    final confirmed = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: Text('¿Eliminar la clase del ${_dias[horario.diaSemana - 1]}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ));
    if (confirmed != true) return;
    try {
      await _repository.eliminarHorario(horario.id);
      await _cargar();
    } catch (error) { _mensaje('No se pudo eliminar: $error'); }
  }

  @override
  Widget build(BuildContext context) {
    final showHorarios = widget.seccion == AcademiaSeccion.horarios;
    return ListView(padding: const EdgeInsets.all(24), children: [
      Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(showHorarios ? 'Horario semanal' : 'Mis materias',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        FilledButton.icon(
          key: Key(showHorarios ? 'academia-crear-horario' : 'academia-crear-materia'),
          onPressed: showHorarios ? () => _guardarHorario() : () => _guardarMateria(),
          icon: const Icon(Icons.add), label: Text(showHorarios ? 'Nueva clase' : 'Nueva materia'),
        ),
        IconButton(onPressed: _cargar, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
      ]),
      const SizedBox(height: 9),
      if (_repository.local)
        const Text('Vista previa · Los datos se guardan en este navegador.'),
      if (!_repository.local)
        const Text('Materias y clases guardadas en tu cuenta.'),
      const SizedBox(height: 15),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(18),
        child: Column(children: [Text(_error!), TextButton(onPressed: _cargar, child: const Text('Reintentar'))]))),
      if (!_loading && _error == null && !showHorarios && _materias.isEmpty)
        const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Aún no hay materias. Agrega una para comenzar.'))),
      if (!_loading && _error == null && showHorarios && _horarios.isEmpty)
        const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Aún no hay clases. Primero registra una materia y después su horario semanal.'))),
      if (!_loading && _error == null && !showHorarios)
        for (final m in _materias)
          Card(key: ValueKey('materia-${m.id}'), child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.menu_book_outlined)),
            title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text([
              if (m.docente.isNotEmpty) m.docente,
              if (m.grupo.isNotEmpty) 'Grupo ${m.grupo}',
              if (m.aula.isNotEmpty) 'Aula ${m.aula}',
              if (m.calificacion != null) 'Calificación ${m.calificacion!.toStringAsFixed(2)}',
              '${_horarios.where((h) => h.materiaId == m.id).length} clase(s)/semana',
            ].join(' · ')),
            isThreeLine: true,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Editar materia',
                onPressed: () => _guardarMateria(m)),
              IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar materia',
                onPressed: () => _eliminarMateria(m)),
            ]),
          )),
      if (!_loading && _error == null && showHorarios)
        for (final day in [1, 2, 3, 4, 5, 6, 7])
          if (_horarios.any((h) => h.diaSemana == day)) ...[
            Padding(padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(_dias[day - 1], style: Theme.of(context).textTheme.titleLarge)),
            for (final h in _horarios.where((h) => h.diaSemana == day))
              Card(key: ValueKey('horario-${h.id}'), child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.schedule_outlined)),
                title: Text(h.materiaNombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${h.inicio}–${h.fin}${h.aula.isEmpty ? '' : ' · ${h.aula}'}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Editar clase',
                    onPressed: () => _guardarHorario(h)),
                  IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar clase',
                    onPressed: () => _eliminarHorario(h)),
                ]),
              )),
          ],
    ]);
  }
}
