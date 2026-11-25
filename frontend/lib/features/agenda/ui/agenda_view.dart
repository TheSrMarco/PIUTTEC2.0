import 'package:flutter/material.dart';

import '../data/agenda_repository.dart';

/// Agenda real cuando hay token JWT; guardado local cuando se entra en vista previa.
class AgendaView extends StatefulWidget {
  const AgendaView({super.key, this.accessToken});
  final String? accessToken;

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  late final AgendaRepository _repository;
  List<AgendaItem> _items = [];
  bool _loading = true;
  String? _error;
  String _filter = 'todas';
  DateTime? _desde;
  DateTime? _hasta;

  @override
  void initState() {
    super.initState();
    _repository = AgendaRepository(accessToken: widget.accessToken);
    _reload();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final list = await _repository.listar(desde: _desde, hasta: _hasta);
      if (mounted) setState(() => _items = list);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _notify(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit([AgendaItem? previous]) async {
    final title = TextEditingController(text: previous?.titulo ?? '');
    final subject = TextEditingController(text: previous?.materia ?? '');
    final description = TextEditingController(text: previous?.descripcion ?? '');
    DateTime date = previous?.fecha ?? DateTime.now();
    String type = previous?.tipo ?? 'tarea';
    final previousTime = previous?.hora;
    TimeOfDay? time = previousTime == null ? null : TimeOfDay(
      hour: int.parse(previousTime.split(':')[0]),
      minute: int.parse(previousTime.split(':')[1]),
    );
    final formKey = GlobalKey<FormState>();
    try {
      final result = await showDialog<AgendaItem>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(builder: (context, updateDialog) {
          String dateLabel() => AgendaItem.fechaTexto(date);
          return AlertDialog(
            title: Text(previous == null ? 'Nueva actividad' : 'Editar actividad'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: title, autofocus: true, maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Título *', prefixIcon: Icon(Icons.task_alt)),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Escribe un título' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'tarea', child: Text('Tarea')),
                      DropdownMenuItem(value: 'evaluacion', child: Text('Evaluación')),
                      DropdownMenuItem(value: 'evento', child: Text('Evento')),
                    ],
                    onChanged: (value) => updateDialog(() => type = value ?? 'tarea'),
                  ),
                  TextFormField(controller: subject, maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Materia (opcional)')),
                  TextFormField(controller: description, maxLines: 2, maxLength: 1000,
                    decoration: const InputDecoration(labelText: 'Descripción (opcional)')),
                  const SizedBox(height: 10),
                  Wrap(spacing: 10, runSpacing: 5, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(dateLabel()),
                      onPressed: () async {
                        final chosen = await showDatePicker(context: context, initialDate: date,
                          firstDate: DateTime(2020), lastDate: DateTime(2100));
                        if (chosen != null) updateDialog(() => date = chosen);
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(time?.format(context) ?? 'Sin hora'),
                      onPressed: () async {
                        final chosen = await showTimePicker(context: context, initialTime: time ?? TimeOfDay.now());
                        if (chosen != null) updateDialog(() => time = chosen);
                      },
                    ),
                    if (time != null) IconButton(
                      tooltip: 'Quitar hora', icon: const Icon(Icons.clear),
                      onPressed: () => updateDialog(() => time = null),
                    ),
                  ]),
                ]),
              )),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              FilledButton(onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final hour = time == null ? null
                    : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
                Navigator.pop(context, AgendaItem(
                  id: previous?.id ?? 0,
                  titulo: title.text.trim(),
                  descripcion: description.text.trim(),
                  materia: subject.text.trim(),
                  tipo: type, fecha: date, hora: hour,
                  completada: previous?.completada ?? false,
                ));
              }, child: const Text('Guardar')),
            ],
          );
        }),
      );
      if (result == null) return;
      if (previous == null) {
        await _repository.crear(result);
      } else {
        await _repository.actualizar(result);
      }
      await _reload();
      _notify('Actividad guardada. Aparecerá también en el calendario.');
    } catch (error) {
      _notify('No se pudo guardar: $error');
    } finally {
      title.dispose(); subject.dispose(); description.dispose();
    }
  }

  Future<void> _complete(AgendaItem item, bool completed) async {
    try {
      await _repository.actualizar(item.copyWith(completada: completed));
      await _reload();
    } catch (error) {
      _notify('No se pudo actualizar: $error');
    }
  }

  Future<void> _delete(AgendaItem item) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Eliminar actividad'),
      content: Text('¿Quieres eliminar «${item.titulo}»?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
      ],
    ));
    if (confirmed != true) return;
    try {
      await _repository.eliminar(item.id);
      await _reload();
      _notify('Actividad eliminada.');
    } catch (error) {
      _notify('No se pudo eliminar: $error');
    }
  }

  Future<void> _chooseDateRange() async {
    final now = DateTime.now();
    final initial = _desde == null || _hasta == null
        ? DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day).add(const Duration(days: 30)),
          )
        : DateTimeRange(start: _desde!, end: _hasta!);
    final chosen = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Consultar fechas de evaluación',
      cancelText: 'Cancelar',
      confirmText: 'Consultar',
    );
    if (chosen == null) return;
    setState(() {
      _desde = chosen.start;
      _hasta = chosen.end;
    });
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((item) {
      if (_filter == 'pendientes') return !item.completada;
      if (_filter == 'completadas') return item.completada;
      if (_filter == 'evaluaciones') return item.tipo == 'evaluacion';
      if (_filter == 'tareas') return item.tipo == 'tarea';
      if (_filter == 'eventos') return item.tipo == 'evento';
      return true;
    }).toList();
    final pending = _items.where((item) => !item.completada).length;
    return ListView(padding: const EdgeInsets.all(24), children: [
      Wrap(spacing: 14, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('Agenda y tareas', style: Theme.of(context).textTheme.headlineMedium),
        FilledButton.icon(key: const Key('agenda-create'),
          onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Nueva actividad')),
        IconButton(onPressed: _reload, tooltip: 'Actualizar actividades', icon: const Icon(Icons.refresh)),
      ]),
      const SizedBox(height: 7),
      Text(_repository.local
        ? 'Vista previa: tus actividades se guardan únicamente en este navegador.'
        : 'Tus actividades se guardan en tu cuenta mediante Django.'),
      const SizedBox(height: 18),
      Wrap(spacing: 8, runSpacing: 8, children: [
        Chip(avatar: const Icon(Icons.event_note, size: 17), label: Text('${_items.length} actividades')),
        Chip(avatar: const Icon(Icons.pending_actions, size: 17), label: Text('$pending pendientes')),
        for (final filter in ['todas', 'evaluaciones', 'tareas', 'eventos', 'pendientes', 'completadas'])
          ChoiceChip(label: Text(switch (filter) {
            'todas' => 'Todas',
            'evaluaciones' => 'Evaluaciones',
            'tareas' => 'Tareas',
            'eventos' => 'Eventos',
            'pendientes' => 'Pendientes',
            _ => 'Completadas',
          }),
            selected: _filter == filter, onSelected: (_) => setState(() => _filter = filter)),
        OutlinedButton.icon(
          onPressed: _chooseDateRange,
          icon: const Icon(Icons.date_range),
          label: Text(_desde == null || _hasta == null
              ? 'Consultar por fechas'
              : '${AgendaItem.fechaTexto(_desde!)} – ${AgendaItem.fechaTexto(_hasta!)}'),
        ),
        if (_desde != null || _hasta != null)
          TextButton.icon(
            onPressed: () async {
              setState(() { _desde = null; _hasta = null; });
              await _reload();
            },
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar fechas'),
          ),
      ]),
      const SizedBox(height: 16),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Text(_error!), TextButton(onPressed: _reload, child: const Text('Reintentar')),
      ]))),
      if (!_loading && _error == null && filtered.isEmpty)
        const Card(child: Padding(padding: EdgeInsets.all(22), child: Text('No hay actividades con este filtro. Crea una para empezar.'))),
      for (final item in filtered)
        Card(key: ValueKey('agenda-${item.id}'), child: ListTile(
          leading: Checkbox(value: item.completada,
            onChanged: (value) => _complete(item, value ?? false)),
          title: Text(item.titulo, style: TextStyle(
            decoration: item.completada ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          )),
          subtitle: Text([
            AgendaItem.fechaTexto(item.fecha),
            if (item.hora != null) item.hora!,
            item.tipo == 'evaluacion' ? 'Evaluación' : item.tipo == 'evento' ? 'Evento' : 'Tarea',
            if (item.materia.isNotEmpty) item.materia,
            if (item.descripcion.isNotEmpty) item.descripcion,
          ].join(' · ')),
          isThreeLine: item.descripcion.isNotEmpty,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: 'Editar ${item.titulo}', onPressed: () => _edit(item), icon: const Icon(Icons.edit_outlined)),
            IconButton(tooltip: 'Eliminar ${item.titulo}', onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline)),
          ]),
        )),
    ]);
  }
}
