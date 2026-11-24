import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/solicitudes_repository.dart';

/// Primera integración real Flutter -> Django para RF-12.
class SolicitudesView extends StatefulWidget {
  const SolicitudesView({super.key, this.accessToken,
    this.isAdministrator = false, this.initialType = 'laboratorio',
    this.initialRecurso = ''});
  final String? accessToken;
  final bool isAdministrator;
  final String initialType;
  final String initialRecurso;

  @override
  State<SolicitudesView> createState() => _SolicitudesViewState();
}

class _SolicitudesViewState extends State<SolicitudesView> {
  late final http.Client _http;
  late final SolicitudesRepository _repository;
  final _recurso = TextEditingController();
  final _motivo = TextEditingController();
  final _inicio = TextEditingController(text: '09:00');
  final _fin = TextEditingController(text: '10:00');
  late String _tipo;
  int? _materiaId;
  List<Map<String, dynamic>> _materias = [];
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  List<Map<String, dynamic>> _solicitudes = [];
  bool _procesando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tipo = widget.initialType;
    _recurso.text = widget.initialRecurso;
    _http = http.Client();
    _repository = SolicitudesRepository(_http, accessToken: widget.accessToken);
    if (_repository.autenticado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _ejecutar(() async {
            await _actualizar();
            _materias = await _repository.listarMaterias();
            if (mounted) setState(() {});
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _recurso.dispose();
    _motivo.dispose();
    _inicio.dispose();
    _fin.dispose();
    _http.close();
    super.dispose();
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    if (_procesando) return;
    setState(() { _procesando = true; _error = null; });
    try {
      await accion();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _actualizar() async {
    final valores = await _repository.listar();
    if (mounted) setState(() => _solicitudes = valores);
  }

  Future<void> _crear() => _ejecutar(() async {
    await _repository.crear(
      tipo: _tipo,
      recurso: _recurso.text,
      fecha: _fecha,
      motivo: _motivo.text,
      inicio: _inicio.text.trim(),
      fin: _fin.text.trim(),
      materiaId: _materiaId,
    );
    _recurso.clear();
    _motivo.clear();
    await _actualizar();
  });

  Future<void> _devolver(int id) => _ejecutar(() async {
    await _repository.registrarDevolucion(id);
    await _actualizar();
  });

  Future<void> _cancelar(int id) => _ejecutar(() async {
    await _repository.cancelar(id);
    await _actualizar();
  });

  Future<void> _revisar(int id, bool aprobar) async {
    String observaciones = '';
    if (!aprobar) {
      final controlador = TextEditingController();
      final respuesta = await showDialog<String>(context: context, builder: (context) =>
        AlertDialog(title: const Text('Motivo del rechazo'),
          content: TextField(controller: controlador, maxLength: 500,
            decoration: const InputDecoration(labelText: 'Observaciones obligatorias')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.of(context).pop(controlador.text.trim()),
              child: const Text('Rechazar')),
          ],
        ));
      controlador.dispose();
      if (respuesta == null || respuesta.isEmpty) return;
      observaciones = respuesta;
    }
    await _ejecutar(() async {
      await _repository.revisar(id, aprobar: aprobar, observaciones: observaciones);
      await _actualizar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final esJustificante = _tipo == 'justificante';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Solicitudes institucionales', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Envía solicitudes y revisa su estado.'),
        const SizedBox(height: 16),
        if (_error != null) Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
        ),
        if (!_repository.autenticado) ...[
          const Card(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Inicia sesión desde el acceso principal para consultar y enviar solicitudes.'),
          )),
        ] else ...[
          const Row(children: [
            Icon(Icons.verified_user_outlined),
            SizedBox(width: 8),
            Expanded(child: Text('Solicitudes de la sesión actual')),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo de solicitud'),
            items: const [
              DropdownMenuItem(value: 'laboratorio', child: Text('Laboratorio')),
              DropdownMenuItem(value: 'equipo', child: Text('Equipo')),
              DropdownMenuItem(value: 'justificante', child: Text('Justificante')),
            ],
            onChanged: _procesando ? null : (value) => setState(() => _tipo = value ?? 'laboratorio'),
          ),
          if (esJustificante) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _materiaId,
              decoration: const InputDecoration(labelText: 'Materia de la falta (opcional)'),
              items: [const DropdownMenuItem<int?>(value: null, child: Text('Sin materia asociada')),
                ..._materias.map((m) => DropdownMenuItem<int?>(
                  value: m['id'] as int, child: Text(m['nombre'] as String))),
              ],
              onChanged: _procesando ? null : (value) => setState(() => _materiaId = value),
            ),
            const Text('Si se aprueba, solo se justifica una falta ya registrada en esa materia y fecha.'),
          ],
          if (!esJustificante) ...[
            const SizedBox(height: 10),
            TextField(controller: _recurso, decoration: const InputDecoration(
              labelText: 'Nombre del laboratorio o equipo', border: OutlineInputBorder())),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('Fecha: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
            onPressed: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: !esJustificante && _fecha.isBefore(DateTime.now())
                    ? DateTime.now().add(const Duration(days: 1))
                    : _fecha,
                firstDate: esJustificante ? DateTime(2025) : DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (fecha != null && mounted) setState(() => _fecha = fecha);
            },
          ),
          if (!esJustificante) Row(children: [
            Expanded(child: TextField(controller: _inicio,
              decoration: const InputDecoration(labelText: 'Inicio HH:MM'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _fin,
              decoration: const InputDecoration(labelText: 'Fin HH:MM'))),
          ]),
          const SizedBox(height: 10),
          TextField(controller: _motivo, maxLines: 2, maxLength: 500,
            decoration: const InputDecoration(labelText: 'Motivo', border: OutlineInputBorder())),
          FilledButton.icon(onPressed: _procesando ? null : _crear,
            icon: const Icon(Icons.add), label: const Text('Enviar solicitud pendiente')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text('Historial', style: Theme.of(context).textTheme.titleLarge)),
            IconButton(onPressed: _procesando ? null : () => _ejecutar(_actualizar),
              icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
          ]),
          if (_solicitudes.isEmpty) const Text('No hay solicitudes registradas.'),
          for (final item in _solicitudes) Card(child: ListTile(
            title: Text('${item['tipo']} · ${item['estado']}${widget.isAdministrator ? ' · ${item['usuario']}' : ''}'),
            subtitle: Text('${item['fecha_solicitada']} · ${item['recurso'] ?? ''}\n'
              '${item['motivo']}'
              '${(item['observaciones_revision'] as String? ?? '').isNotEmpty ? '\nObservación: ${item['observaciones_revision']}' : ''}'),
            isThreeLine: true,
            trailing: widget.isAdministrator && item['tipo'] == 'equipo'
                    && item['estado'] == 'aprobada'
              ? TextButton(onPressed: _procesando ? null : () => _devolver(item['id'] as int),
                  child: const Text('Registrar devolución'))
              : item['estado'] != 'pendiente' ? null
              : widget.isAdministrator
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(tooltip: 'Aprobar solicitud',
                      onPressed: _procesando ? null : () => _revisar(item['id'] as int, true),
                      icon: const Icon(Icons.check_circle_outline)),
                    IconButton(tooltip: 'Rechazar solicitud',
                      onPressed: _procesando ? null : () => _revisar(item['id'] as int, false),
                      icon: const Icon(Icons.cancel_outlined)),
                  ])
                : TextButton(onPressed: _procesando ? null : () => _cancelar(item['id'] as int),
                    child: const Text('Cancelar')),
          )),
        ],
      ],
    );
  }
}
