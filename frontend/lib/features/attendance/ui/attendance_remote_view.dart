import 'package:flutter/material.dart';

import '../../academia/data/academia_repository.dart';
import '../data/attendance_repository.dart';

/// Asistencias: registro personal respaldado por Django, separado del pase local
/// de demostración. Solo aparecen materias previamente registradas en RF-02.
class AttendanceRemoteView extends StatefulWidget {
  const AttendanceRemoteView({super.key, required this.accessToken});
  final String accessToken;

  @override
  State<AttendanceRemoteView> createState() => _AttendanceRemoteViewState();
}

class _AttendanceRemoteViewState extends State<AttendanceRemoteView> {
  late final AcademiaRepository _academia;
  late final AttendanceRepository _asistencias;
  List<MateriaAcademica> _materias = [];
  List<RegistroAsistencia> _registros = [];
  DateTime _dia = DateTime.now();
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _academia = AcademiaRepository(accessToken: widget.accessToken);
    _asistencias = AttendanceRepository(accessToken: widget.accessToken);
    _cargar();
  }

  @override
  void dispose() {
    _academia.dispose();
    _asistencias.dispose();
    super.dispose();
  }

  String _fecha(DateTime fecha) =>
    '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final materias = await _academia.listarMaterias();
      final registros = await _asistencias.listar();
      if (!mounted) return;
      setState(() { _materias = materias; _registros = registros; });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  RegistroAsistencia? _registroDelDia(int materiaId) {
    for (final registro in _registros) {
      if (registro.materiaId == materiaId && registro.fecha == _fecha(_dia)) return registro;
    }
    return null;
  }

  Future<void> _guardar(MateriaAcademica materia, String estado) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final anterior = _registroDelDia(materia.id);
      await _asistencias.registrar(materiaId: materia.id, fecha: _fecha(_dia),
        estado: estado, id: anterior?.id);
      await _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asistencia guardada en Django.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _eliminar(RegistroAsistencia registro) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await _asistencias.eliminar(registro.id);
      await _cargar();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _todosPresentes() async {
    if (_busy || _materias.isEmpty) return;
    final aceptar = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Todos presentes'),
      content: Text('Se registrará P para las ${_materias.length} materias el ${_fecha(_dia)}. '
        'Los estados existentes de ese día serán reemplazados.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
      ],
    ));
    if (aceptar != true || !mounted) return;
    setState(() { _busy = true; _error = null; });
    try {
      await _asistencias.marcarTodas(fecha: _fecha(_dia),
        materias: _materias.map((m) => m.id).toList());
      await _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materias registradas como presentes.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _seleccionarDia() async {
    final hoy = DateTime.now();
    final nuevo = await showDatePicker(context: context, initialDate: _dia,
      firstDate: DateTime(2020), lastDate: hoy);
    if (nuevo != null && mounted) setState(() => _dia = nuevo);
  }

  int? _porcentaje(int materiaId) {
    final registros = _registros.where((r) => r.materiaId == materiaId);
    final total = registros.length;
    if (total == 0) return null;
    final p = registros.where((r) => r.estado == 'P').length;
    final r = registros.where((r) => r.estado == 'R').length;
    final j = registros.where((r) => r.estado == 'J').length;
    return ((p + r + j - (r ~/ 3)) * 100 / total).round();
  }

  Widget _botonEstado(MateriaAcademica materia, String estado, String nombre, Color color) {
    final actual = _registroDelDia(materia.id)?.estado == estado;
    return Tooltip(message: nombre, child: SizedBox(width: 47,
      child: FilledButton(
        key: Key('remote-attendance-$estado-${materia.id}'),
        style: FilledButton.styleFrom(backgroundColor: color, padding: EdgeInsets.zero,
          side: actual ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none),
        onPressed: _loading || _busy ? null : () => _guardar(materia, estado),
        child: Text(estado),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(padding: const EdgeInsets.all(22), children: [
      Text('Pase de lista', style: theme.textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Registro personal de práctica en Django. No equivale a asistencia oficial validada por un docente.'),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        OutlinedButton.icon(onPressed: _busy ? null : _seleccionarDia,
          icon: const Icon(Icons.today), label: Text(_fecha(_dia))),
        FilledButton.icon(onPressed: _loading || _busy || _materias.isEmpty ? null : _todosPresentes,
          icon: const Icon(Icons.done_all), label: const Text('Todos presentes')),
        OutlinedButton.icon(onPressed: _loading || _busy ? null : _cargar,
          icon: const Icon(Icons.refresh), label: const Text('Actualizar')),
      ]),
      if (_loading) const Padding(padding: EdgeInsets.all(18), child: LinearProgressIndicator()),
      if (_busy) const Padding(padding: EdgeInsets.all(18), child: LinearProgressIndicator()),
      if (_error != null)
        Card(child: Padding(padding: const EdgeInsets.all(14),
          child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)))),
      if (!_loading && _materias.isEmpty && _error == null)
        const Card(child: Padding(padding: EdgeInsets.all(18),
          child: Text('Aún no tienes materias registradas. Añádelas en Academia → Materias y calificaciones.'))),
      for (final materia in _materias)
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(materia.nombre, style: theme.textTheme.titleMedium),
            if (materia.grupo.isNotEmpty) Text('Grupo ${materia.grupo}'),
            const SizedBox(height: 6),
            Text('Acumulado: ${_porcentaje(materia.id) == null ? 'N/D' : '${_porcentaje(materia.id)}%'} · '
              '${_registros.where((r) => r.materiaId == materia.id).length} días registrados'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              _botonEstado(materia, 'P', 'Presente', Colors.green.shade700),
              _botonEstado(materia, 'R', 'Retardo', Colors.orange.shade800),
              _botonEstado(materia, 'J', 'Justificado', Colors.blue.shade700),
              _botonEstado(materia, 'F', 'Falta', Colors.red.shade700),
              if (_registroDelDia(materia.id) != null)
                IconButton(
                  tooltip: 'Quitar registro de este día',
                  onPressed: _busy ? null : () => _eliminar(_registroDelDia(materia.id)!),
                  icon: const Icon(Icons.delete_outline),
                ),
            ]),
          ],
        ))),
      const SizedBox(height: 22),
      Text('Historial de registros', style: theme.textTheme.titleLarge),
      if (_registros.isEmpty && !_loading)
        const Padding(padding: EdgeInsets.all(12), child: Text('Sin registros en tu cuenta.')),
      for (final registro in _registros.take(100))
        ListTile(
          leading: CircleAvatar(child: Text(registro.estado)),
          title: Text(registro.materiaNombre),
          subtitle: Text(registro.fecha),
          trailing: Text(_nombreEstado(registro.estado)),
        ),
    ]);
  }

  String _nombreEstado(String estado) => switch (estado) {
    'P' => 'Presente', 'R' => 'Retardo', 'J' => 'Justificado',
    'F' => 'Falta', _ => estado,
  };
}
