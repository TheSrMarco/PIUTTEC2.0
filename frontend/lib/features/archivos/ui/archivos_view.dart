import 'package:file_selector/file_selector.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/archivos_repository.dart';

class ArchivosView extends StatefulWidget {
  const ArchivosView({super.key, this.accessToken});
  final String? accessToken;

  @override
  State<ArchivosView> createState() => _ArchivosViewState();
}

class _ArchivosViewState extends State<ArchivosView> {
  ArchivosRepository? _repo;
  final _materia = TextEditingController();
  List<ArchivoAcademico> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.accessToken != null && widget.accessToken!.isNotEmpty) {
      _repo = ArchivosRepository(accessToken: widget.accessToken!);
      _actualizar();
    }
  }

  @override
  void dispose() {
    _repo?.dispose();
    _materia.dispose();
    super.dispose();
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    if (_loading || _repo == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      await accion();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _actualizar() => _ejecutar(() async {
    final archivos = await _repo!.listar();
    if (mounted) setState(() => _items = archivos);
  });

  Future<void> _subir() => _ejecutar(() async {
    const allowed = XTypeGroup(label: 'Documentos e imágenes', extensions: [
      'pdf', 'docx', 'xlsx', 'csv', 'txt', 'png', 'jpg', 'jpeg',
    ], uniformTypeIdentifiers: ['public.content', 'public.image']);
    final seleccionado = await openFile(acceptedTypeGroups: [allowed]);
    if (seleccionado == null) return;
    final tamano = await seleccionado.length();
    if (tamano < 1 || tamano > 10 * 1024 * 1024) {
      throw const FormatException('Solo se admiten archivos de hasta 10 MB.');
    }
    final datos = await seleccionado.readAsBytes();
    await _repo!.subir(nombre: seleccionado.name, contenido: datos,
      materia: _materia.text.trim());
    _materia.clear();
    final archivos = await _repo!.listar();
    if (mounted) setState(() => _items = archivos);
  });

  Future<void> _descargar(ArchivoAcademico item) => _ejecutar(() async {
    final datos = await _repo!.descargar(item.id);
    final lastDot = item.nombre.lastIndexOf('.');
    final extension = lastDot >= 0 ? item.nombre.substring(lastDot + 1) : 'bin';
    final baseName = lastDot >= 0 ? item.nombre.substring(0, lastDot) : item.nombre;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await FileSaver.instance.saveToDownloads(name: baseName, bytes: datos,
        fileExtension: extension, mimeType: MimeType.custom,
        customMimeType: 'application/octet-stream');
    } else {
      await FileSaver.instance.saveFile(name: baseName, bytes: datos,
        fileExtension: extension, mimeType: MimeType.custom,
        customMimeType: 'application/octet-stream');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo exportado correctamente.')));
    }
  });

  Future<void> _eliminar(ArchivoAcademico item) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar archivo'),
      content: Text('¿Eliminar "${item.nombre}"? Esta acción no se puede deshacer.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))],
    ));
    if (ok != true) return;
    await _ejecutar(() async {
      await _repo!.eliminar(item.id);
      final archivos = await _repo!.listar();
      if (mounted) setState(() => _items = archivos);
    });
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Gestor de archivos', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Documentos de práctica privados por cuenta. Formatos PDF, Word, Excel, CSV, texto e imágenes. Máximo 10 MB.'),
      const SizedBox(height: 16),
      if (_repo == null)
        const Card(child: Padding(padding: EdgeInsets.all(20),
          child: Text('Inicia sesión con Django para subir y administrar archivos. La Vista previa no almacena documentos.')))
      else ...[
        TextField(controller: _materia, maxLength: 120,
          decoration: const InputDecoration(labelText: 'Materia (opcional)', border: OutlineInputBorder())),
        Wrap(spacing: 12, children: [
          FilledButton.icon(onPressed: _loading ? null : _subir,
            icon: const Icon(Icons.upload_file), label: const Text('Subir archivo')),
          OutlinedButton.icon(onPressed: _loading ? null : _actualizar,
            icon: const Icon(Icons.refresh), label: const Text('Actualizar')),
        ]),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) Padding(padding: const EdgeInsets.all(12),
          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 20),
        if (_items.isEmpty) const Text('Todavía no tienes archivos guardados.')
        else for (final item in _items) Card(child: ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(item.nombre),
          subtitle: Text('${item.materia.isEmpty ? 'Sin materia' : item.materia} · ${(item.tamano / 1024).toStringAsFixed(1)} KB'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: 'Descargar', onPressed: _loading ? null : () => _descargar(item),
              icon: const Icon(Icons.download_outlined)),
            IconButton(tooltip: 'Eliminar', onPressed: _loading ? null : () => _eliminar(item),
              icon: const Icon(Icons.delete_outline)),
          ]),
        )),
      ],
    ],
  );
}
