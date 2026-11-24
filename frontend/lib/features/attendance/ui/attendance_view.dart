import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_remote_view.dart';

/// Selección explícita: con JWT usa Django; sin JWT preserva el pase local.
class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key, this.accessToken});
  final String? accessToken;

  @override
  Widget build(BuildContext context) => accessToken == null || accessToken!.isEmpty
    ? const AttendanceLocalView()
    : AttendanceRemoteView(accessToken: accessToken!);
}

/// Versión Flutter del pase de lista del prototipo HTML: P/R/J/F, porcentaje,
/// registro por fecha, marcación masiva e historial. Guarda DATOS LOCALES.
/// No sincroniza todavía con el backend ni con el localStorage del HTML.
class AttendanceLocalView extends StatefulWidget {
  const AttendanceLocalView({super.key});

  @override
  State<AttendanceLocalView> createState() => _AttendanceLocalViewState();
}

class _AttendanceLocalViewState extends State<AttendanceLocalView> {
  static const _key = 'piuttec_flutter_attendance_v1';
  static const _subjectsSeed = <(String, String, int, int, int, int)>[
    ('TICS-901', 'Bases de Datos Distribuidas', 18, 1, 0, 1),
    ('TICS-902', 'Extracción y Visualización de Datos', 20, 0, 0, 0),
    ('TICS-903', 'Seguridad en Redes y Criptografía', 15, 2, 1, 2),
    ('TICS-904', 'Desarrollo Web Fullstack', 19, 0, 0, 1),
    ('TICS-905', 'Gestión de Proyectos de TI (Scrum)', 17, 1, 0, 2),
    ('TICS-906', 'Inglés Técnico VIII', 14, 1, 0, 3),
  ];

  late List<Map<String, dynamic>> _subjects;
  List<Map<String, String>> _history = [];
  DateTime _day = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subjects = _subjectsSeed.map((row) => <String, dynamic>{
      'code': row.$1, 'name': row.$2,
      'p': row.$3, 'r': row.$4, 'j': row.$5, 'f': row.$6,
    }).toList();
    _load();
  }

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final subjects = (decoded['subjects'] as List<dynamic>).cast<Map<dynamic, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item)).toList();
        final history = (decoded['history'] as List<dynamic>).cast<Map<dynamic, dynamic>>()
          .map((item) => item.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
        if (mounted && subjects.isNotEmpty) {
          setState(() { _subjects = subjects; _history = history; });
        }
      }
    } catch (_) {
      // La interfaz continúa disponible aunque falle el almacenamiento local.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode({'subjects': _subjects, 'history': _history}));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el registro local.')),
        );
      }
    }
  }

  int _pct(Map<String, dynamic> m) {
    final p=m['p'] as int, r=m['r'] as int, j=m['j'] as int, f=m['f'] as int;
    final total=p+r+j+f;
    if (total==0) return 100;
    final valid=(p+r+j-(r~/3)).clamp(0, total);
    return (100*valid/total).round();
  }

  void _record(int index, String status) {
    final now=DateTime.now();
    setState(() {
      final item = _subjects[index];
      final key=status.toLowerCase();
      item[key]=(item[key] as int)+1;
      _history.insert(0, {
        'materia': item['name'] as String,
        'codigo': item['code'] as String,
        'tipo': status, 'fecha': _date(_day), 'hora': _time(now),
      });
    });
    _save();
  }

  Future<void> _markAllPresent() async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Registrar todas como presentes'),
      content: Text('Se añadirá una asistencia a cada asignatura el ${_date(_day)}.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
      ],
    ));
    if (yes != true || !mounted) return;
    for (var i=0;i<_subjects.length;i++) { _record(i,'P'); }
  }

  Future<void> _pickDay() async {
    final selected = await showDatePicker(context: context, initialDate: _day,
      firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (selected != null && mounted) setState(() => _day=selected);
  }

  Widget _statusButton(int i, String label, String tooltip, Color color) =>
      Tooltip(message: tooltip, child: SizedBox(width: 42,
        child: FilledButton(
          key: Key('attendance-$label-$i'),
          style: FilledButton.styleFrom(backgroundColor: color, padding: EdgeInsets.zero),
          onPressed: _loading ? null : () => _record(i,label),
          child: Text(label),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Pase de lista', style: theme.textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Registro local por asignatura. P: presente · R: retardo · J: justificado · F: falta.'),
      const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        OutlinedButton.icon(onPressed: _pickDay, icon: const Icon(Icons.today), label: Text(_date(_day))),
        FilledButton.icon(onPressed: _loading ? null : _markAllPresent,
          icon: const Icon(Icons.done_all), label: const Text('Todos presentes')),
      ]),
      const SizedBox(height: 16),
      for (final (index, m) in _subjects.indexed)
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['name'] as String, style: theme.textTheme.titleMedium),
            Text(m['code'] as String),
            const SizedBox(height: 8),
            Text('P: ${m['p']}   R: ${m['r']}   J: ${m['j']}   F: ${m['f']}   •   ${_pct(m)}%'),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: _pct(m)/100),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 7, children: [
              _statusButton(index,'P','Presente',Colors.green.shade700),
              _statusButton(index,'R','Retardo',Colors.orange.shade800),
              _statusButton(index,'J','Justificado',Colors.blue.shade700),
              _statusButton(index,'F','Falta',Colors.red.shade700),
            ]),
          ],
        ))),
      const SizedBox(height: 20),
      Text('Historial de registros', style: theme.textTheme.titleLarge),
      if (_history.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Sin movimientos nuevos en esta instalación.')),
      for (final item in _history.take(50))
        ListTile(leading: CircleAvatar(child: Text(item['tipo'] ?? '')),
          title: Text(item['materia'] ?? ''),
          subtitle: Text('${item['fecha']} · ${item['hora']}'),
          trailing: Text(item['codigo'] ?? '')),
    ]);
  }
}
