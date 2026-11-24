import 'package:flutter/material.dart';
import '../../academia/data/academia_repository.dart';

/// Directorio de práctica formado únicamente por los docentes que el usuario
/// escribió en sus materias. No usa contactos institucionales externos.
class DocentesView extends StatefulWidget {
  const DocentesView({super.key, this.accessToken});
  final String? accessToken;

  @override
  State<DocentesView> createState() => _DocentesViewState();
}

class _DocentesViewState extends State<DocentesView> {
  late final AcademiaRepository _repository;
  List<MateriaAcademica> _materias = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = AcademiaRepository(accessToken: widget.accessToken);
    _actualizar();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _actualizar() async {
    if (_cargando) return;
    setState(() { _cargando = true; _error = null; });
    try {
      final materias = await _repository.listarMaterias();
      if (mounted) setState(() => _materias = materias);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final porNombre = <String, List<MateriaAcademica>>{};
    for (final materia in _materias) {
      final docente = materia.docente.trim();
      if (docente.isEmpty) continue;
      porNombre.putIfAbsent(docente, () => []).add(materia);
    }
    final docentes = porNombre.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text('Directorio docente', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Directorio personal formado con los docentes que registraste en tus materias; no son datos oficiales de contacto.'),
      const SizedBox(height: 16),
      Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(
        onPressed: _cargando ? null : _actualizar,
        icon: const Icon(Icons.refresh), label: const Text('Actualizar docentes'))),
      if (_cargando) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (!_cargando && docentes.isEmpty && _error == null)
        const Card(child: Padding(padding: EdgeInsets.all(20),
          child: Text('Aún no tienes docentes registrados. Agrega el nombre del docente en Academia → Materias y calificaciones.'))),
      for (final nombre in docentes)
        Card(child: ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(nombre),
          subtitle: Text('Materias: ${porNombre[nombre]!.map((m) => m.nombre).join(', ')}'),
        )),
    ]);
  }
}
