import 'package:flutter/material.dart';
import '../../solicitudes/ui/solicitudes_view.dart';
import '../data/recursos_repository.dart';

class RecursosView extends StatefulWidget {
  const RecursosView({super.key, this.accessToken, this.isAdministrator = false});
  final String? accessToken;
  final bool isAdministrator;

  @override
  State<RecursosView> createState() => _RecursosViewState();
}

class _RecursosViewState extends State<RecursosView> {
  RecursosRepository? _repo;
  List<RecursoInstitucional> _items = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.accessToken != null && widget.accessToken!.isNotEmpty) {
      _repo = RecursosRepository(accessToken: widget.accessToken!);
      _actualizar();
    }
  }

  @override
  void dispose() { _repo?.dispose(); super.dispose(); }

  Future<void> _actualizar() async {
    if (_busy || _repo == null) return;
    setState(() { _busy = true; _error = null; });
    try {
      final items = await _repo!.listar();
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _solicitar(RecursoInstitucional item) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Solicitar recurso')),
      body: SolicitudesView(accessToken: widget.accessToken,
        initialType: item.tipo, initialRecurso: item.nombre,
        isAdministrator: widget.isAdministrator),
    )));
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24), children: [
    Text('Laboratorios y equipos', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Catálogo de recursos de prueba. Las solicitudes requieren aprobación administrativa; consultar un recurso no garantiza una reserva.'),
    const SizedBox(height: 16),
    if (_repo == null)
      const Card(child: Padding(padding: EdgeInsets.all(20),
        child: Text('Inicia sesión para consultar los recursos y enviar una solicitud.')))
    else ...[
      Align(alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(onPressed: _busy ? null : _actualizar,
          icon: const Icon(Icons.refresh), label: const Text('Actualizar catálogo'))),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (!_busy && _items.isEmpty)
        const Card(child: Padding(padding: EdgeInsets.all(20),
          child: Text('No se han registrado recursos. Administración puede añadirlos desde Django /admin/.'))),
      for (final item in _items) Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(item.tipo == 'laboratorio' ? Icons.meeting_room_outlined : Icons.laptop_outlined),
            const SizedBox(width: 10), Expanded(child: Text(item.nombre,
              style: Theme.of(context).textTheme.titleMedium)),
          ]),
          if (item.ubicacion.isNotEmpty) Text('Ubicación: ${item.ubicacion}'),
          if (item.capacidad != null) Text('Capacidad: ${item.capacidad}'),
          if (item.descripcion.isNotEmpty) Text(item.descripcion),
          Align(alignment: Alignment.centerRight,
            child: FilledButton.icon(onPressed: () => _solicitar(item),
              icon: const Icon(Icons.add), label: const Text('Solicitar'))),
        ]),
      )),
    ],
  ]);
}
