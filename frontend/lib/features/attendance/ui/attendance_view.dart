import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../domain/attendance_data.dart';
import 'attendance_view_model.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({
    required this.api,
    required this.authenticated,
    required this.onSignIn,
    super.key,
  });
  final ApiClient api;
  final bool authenticated;
  final VoidCallback onSignIn;

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  late final AttendanceViewModel _model;
  static const _statuses = {
    '': 'Sin registrar',
    'present': 'Presente',
    'late': 'Retardo',
    'absent': 'Falta',
    'justified': 'Justificado',
  };

  @override
  void initState() {
    super.initState();
    _model = AttendanceViewModel(widget.api);
    if (widget.authenticated) _model.loadCourses();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _model.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (mounted && date != null) await _model.loadDay(selectedDate: date);
  }

  Future<void> _selectTime(AttendanceRow row) async {
    final parts = row.timeIn?.split(':');
    final time = await showTimePicker(
      context: context,
      initialTime: parts == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (!mounted || time == null) return;
    _model.update(
      row,
      time:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );
  }

  Widget _studentCard(AttendanceRow row) {
    final enabled = _model.canEdit && !_model.loading;
    final rowKey =
        '${_model.course!.id}-${_model.dateLabel}-${row.enrollmentId}-${_model.revision}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(row.name, style: Theme.of(context).textTheme.titleMedium),
            Text(row.studentCode),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('$rowKey-${row.status}'),
              initialValue: row.status ?? '',
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: _statuses.entries
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.key,
                      child: Text(item.value),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (value) => _model.update(
                      row,
                      status: value!.isEmpty ? null : value,
                      setStatus: true,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('$rowKey-note-${row.status}'),
              initialValue: row.note,
              enabled: enabled && row.status != null,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Observación',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _model.update(row, note: value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: enabled && row.status != null
                      ? () => _selectTime(row)
                      : null,
                  icon: const Icon(Icons.access_time),
                  label: Text(row.timeIn ?? 'Hora de entrada'),
                ),
                if (enabled && row.timeIn != null)
                  IconButton(
                    onPressed: () => _model.update(row, time: ''),
                    tooltip: 'Quitar hora',
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.authenticated) {
      return Center(
        child: FilledButton.icon(
          onPressed: widget.onSignIn,
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión para consultar asistencias'),
        ),
      );
    }
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Pase de lista',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_model.loading) const LinearProgressIndicator(),
          if (_model.error != null) ...[
            const SizedBox(height: 12),
            Text(
              _model.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: _model.loading
                  ? null
                  : _model.courses.isEmpty
                  ? _model.loadCourses
                  : _model.loadDay,
              child: const Text('Recargar'),
            ),
          ],
          if (_model.courses.isEmpty && !_model.loading && _model.error == null)
            const Text(
              'Aún no tienes materias asignadas. Solicita la asignación al administrador.',
            ),
          if (_model.course != null) ...[
            DropdownButtonFormField<int>(
              initialValue: _model.course!.id,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Materia y grupo'),
              items: _model.courses
                  .map(
                    (course) => DropdownMenuItem(
                      value: course.id,
                      child: Text(
                        '${course.name} · ${course.group}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _model.loading || _model.dirty
                  ? null
                  : (id) => _model.loadDay(
                      selectedCourse: _model.courses.firstWhere(
                        (course) => course.id == id,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _model.loading || _model.dirty
                      ? null
                      : _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_model.dateLabel),
                ),
                Text('Periodo ${_model.course!.period}'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.entries
                  .map(
                    (item) => Chip(
                      label: Text(
                        '${item.value}: ${_model.rows.where((row) => (row.status ?? '') == item.key).length}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (_model.canEdit) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _model.loading || _model.rows.isEmpty
                        ? null
                        : _model.markPendingPresent,
                    child: const Text('Marcar pendientes como presentes'),
                  ),
                  FilledButton.icon(
                    onPressed: _model.loading || !_model.dirty
                        ? null
                        : () async {
                            await _model.save();
                            if (!context.mounted || _model.error != null) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Asistencias guardadas'),
                              ),
                            );
                          },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar asistencias'),
                  ),
                  if (_model.dirty)
                    TextButton(
                      onPressed: _model.loading ? null : _model.loadDay,
                      child: const Text('Descartar cambios'),
                    ),
                ],
              ),
              if (_model.dirty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Guarda o descarta los cambios para elegir otra materia o fecha.',
                  ),
                ),
            ],
            const SizedBox(height: 16),
            if (_model.rows.isEmpty && !_model.loading && _model.error == null)
              const Text('Esta materia aún no tiene estudiantes inscritos.'),
            for (final row in _model.rows) _studentCard(row),
          ],
        ],
      ),
    );
  }
}
