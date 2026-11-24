import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Una materia propia del usuario. La calificación es opcional (escala 0–10).
class MateriaAcademica {
  const MateriaAcademica({required this.id, required this.nombre,
    this.docente = '', this.grupo = '', this.aula = '', this.calificacion});

  final int id;
  final String nombre;
  final String docente;
  final String grupo;
  final String aula;
  final double? calificacion;

  factory MateriaAcademica.fromJson(Map<String, dynamic> data) => MateriaAcademica(
    id: (data['id'] as num).toInt(),
    nombre: data['nombre'] as String,
    docente: (data['docente'] as String?) ?? '',
    grupo: (data['grupo'] as String?) ?? '',
    aula: (data['aula'] as String?) ?? '',
    calificacion: data['calificacion'] == null
      ? null : double.parse(data['calificacion'].toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': nombre.trim(), 'docente': docente.trim(),
    'grupo': grupo.trim(), 'aula': aula.trim(),
    'calificacion': calificacion,
  };

  MateriaAcademica copyWith({int? id}) => MateriaAcademica(
    id: id ?? this.id, nombre: nombre, docente: docente,
    grupo: grupo, aula: aula, calificacion: calificacion,
  );
}

/// Clase semanal: diaSemana sigue ISO 8601 (lunes=1, domingo=7).
class ClaseHorario {
  const ClaseHorario({required this.id, required this.materiaId,
    required this.diaSemana, required this.inicio, required this.fin,
    this.materiaNombre = '', this.aula = ''});

  final int id;
  final int materiaId;
  final String materiaNombre;
  final int diaSemana;
  final String inicio;
  final String fin;
  final String aula;

  bool ocurreEnFecha(DateTime fecha) => diaSemana == fecha.weekday;
  static String recortarHora(String text) => text.length >= 5 ? text.substring(0, 5) : text;

  factory ClaseHorario.fromJson(Map<String, dynamic> data) => ClaseHorario(
    id: (data['id'] as num).toInt(),
    materiaId: (data['materia'] as num).toInt(),
    materiaNombre: (data['materia_nombre'] as String?) ?? '',
    diaSemana: (data['dia_semana'] as num).toInt(),
    inicio: recortarHora(data['inicio'] as String),
    fin: recortarHora(data['fin'] as String),
    aula: (data['aula'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'materia': materiaId, 'materia_nombre': materiaNombre,
    'dia_semana': diaSemana, 'inicio': inicio, 'fin': fin, 'aula': aula.trim(),
  };

  ClaseHorario copyWith({int? id, String? materiaNombre}) => ClaseHorario(
    id: id ?? this.id, materiaId: materiaId,
    materiaNombre: materiaNombre ?? this.materiaNombre,
    diaSemana: diaSemana, inicio: inicio, fin: fin, aula: aula,
  );
}

/// Con JWT: API de Django. Sin JWT: datos locales de demostración.
/// Un error del servidor nunca se sustituye silenciosamente por datos locales.
class AcademiaRepository {
  AcademiaRepository({this.accessToken, http.Client? client})
    : _client = client ?? http.Client(), _ownsClient = client == null;

  final String? accessToken;
  final http.Client _client;
  final bool _ownsClient;
  static const _materiasKey = 'piuttec_rf02_materias_demo_v1';
  static const _horariosKey = 'piuttec_rf02_horarios_demo_v1';
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api/');

  bool get local => accessToken == null || accessToken!.isEmpty;
  void dispose() { if (_ownsClient) _client.close(); }

  Uri _url(String collection, [int? id]) {
    final root = _apiBase.endsWith('/') ? _apiBase : '$_apiBase/';
    return Uri.parse(root).resolve(id == null ? '$collection/' : '$collection/$id/');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=utf-8',
    if (!local) 'Authorization': 'Bearer $accessToken',
  };

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 400) {
      if (response.statusCode == 401) {
        throw const FormatException('Sesión caducada. Inicia sesión nuevamente.');
      }
      String message = 'Operación rechazada (HTTP ${response.statusCode}).';
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map && body.isNotEmpty) message = '$message ${body.values.first}';
      } catch (_) { /* Respuesta no JSON. */ }
      throw FormatException(message);
    }
    if (response.statusCode == 204) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<Map<String, dynamic>>> _readLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final data = jsonDecode(raw) as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _writeLocal(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(data))) {
      throw const FormatException('No se pudieron guardar los cambios en este navegador.');
    }
  }

  int _nextId(List<Map<String, dynamic>> data) =>
      data.fold<int>(0, (max, item) => (item['id'] as num).toInt() > max
        ? (item['id'] as num).toInt() : max) + 1;

  Map<String, dynamic> _payload(Map<String, dynamic> data) => Map.of(data)
    ..remove('id')
    ..remove('materia_nombre');

  void _validarMateria(MateriaAcademica materia) {
    if (materia.nombre.trim().isEmpty) throw const FormatException('Escribe el nombre de la materia.');
    if (materia.calificacion != null && (materia.calificacion! < 0 || materia.calificacion! > 10)) {
      throw const FormatException('La calificación debe estar entre 0 y 10.');
    }
  }

  void _validarHorario(ClaseHorario item) {
    if (item.diaSemana < 1 || item.diaSemana > 7 || item.inicio.compareTo(item.fin) >= 0) {
      throw const FormatException('Selecciona un día y un horario de inicio/fin válidos.');
    }
  }

  Future<List<MateriaAcademica>> listarMaterias() async {
    final List<Map<String, dynamic>> data;
    if (local) {
      data = await _readLocal(_materiasKey);
    } else {
      final response = await _client.get(_url('materias'), headers: _headers)
        .timeout(const Duration(seconds: 12));
      data = (_decode(response) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return data.map(MateriaAcademica.fromJson).toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
  }

  Future<List<ClaseHorario>> listarHorarios() async {
    final List<Map<String, dynamic>> data;
    if (local) {
      data = await _readLocal(_horariosKey);
      final materias = {for (final m in await listarMaterias()) m.id: m.nombre};
      for (final row in data) {
        row['materia_nombre'] = materias[(row['materia'] as num).toInt()] ?? 'Materia eliminada';
      }
    } else {
      final response = await _client.get(_url('horarios'), headers: _headers)
        .timeout(const Duration(seconds: 12));
      data = (_decode(response) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return data.map(ClaseHorario.fromJson).toList()..sort((a, b) {
      final day = a.diaSemana.compareTo(b.diaSemana);
      return day != 0 ? day : a.inicio.compareTo(b.inicio);
    });
  }

  Future<MateriaAcademica> guardarMateria(MateriaAcademica item) async {
    _validarMateria(item);
    if (local) {
      final data = await _readLocal(_materiasKey);
      final id = item.id == 0 ? _nextId(data) : item.id;
      if (item.id != 0 && !data.any((row) => row['id'] == id)) {
        throw const FormatException('La materia ya no existe.');
      }
      data.removeWhere((row) => row['id'] == id);
      final saved = item.copyWith(id: id);
      data.add(saved.toJson());
      await _writeLocal(_materiasKey, data);
      return saved;
    }
    final response = await (item.id == 0
      ? _client.post(_url('materias'), headers: _headers, body: jsonEncode(_payload(item.toJson())))
      : _client.patch(_url('materias', item.id), headers: _headers, body: jsonEncode(_payload(item.toJson()))))
      .timeout(const Duration(seconds: 12));
    return MateriaAcademica.fromJson(Map<String, dynamic>.from(_decode(response) as Map));
  }

  Future<void> eliminarMateria(int id) async {
    if (local) {
      final data = await _readLocal(_materiasKey);
      data.removeWhere((row) => row['id'] == id);
      final horarios = await _readLocal(_horariosKey);
      horarios.removeWhere((row) => row['materia'] == id);
      await _writeLocal(_materiasKey, data);
      await _writeLocal(_horariosKey, horarios);
    } else {
      final response = await _client.delete(_url('materias', id), headers: _headers)
        .timeout(const Duration(seconds: 12));
      _decode(response);
    }
  }

  Future<ClaseHorario> guardarHorario(ClaseHorario item) async {
    _validarHorario(item);
    if (local) {
      final materias = await _readLocal(_materiasKey);
      if (!materias.any((row) => row['id'] == item.materiaId)) {
        throw const FormatException('Selecciona una materia existente.');
      }
      final data = await _readLocal(_horariosKey);
      final overlap = data.any((row) => row['id'] != item.id
        && row['dia_semana'] == item.diaSemana
        && (row['inicio'] as String).compareTo(item.fin) < 0
        && (row['fin'] as String).compareTo(item.inicio) > 0);
      if (overlap) throw const FormatException('Ese horario se traslapa con otra clase.');
      final id = item.id == 0 ? _nextId(data) : item.id;
      if (item.id != 0 && !data.any((row) => row['id'] == id)) {
        throw const FormatException('La clase ya no existe.');
      }
      data.removeWhere((row) => row['id'] == id);
      final saved = item.copyWith(id: id);
      data.add(saved.toJson());
      await _writeLocal(_horariosKey, data);
      return saved;
    }
    final response = await (item.id == 0
      ? _client.post(_url('horarios'), headers: _headers, body: jsonEncode(_payload(item.toJson())))
      : _client.patch(_url('horarios', item.id), headers: _headers, body: jsonEncode(_payload(item.toJson()))))
      .timeout(const Duration(seconds: 12));
    return ClaseHorario.fromJson(Map<String, dynamic>.from(_decode(response) as Map));
  }

  Future<void> eliminarHorario(int id) async {
    if (local) {
      final data = await _readLocal(_horariosKey);
      data.removeWhere((row) => row['id'] == id);
      await _writeLocal(_horariosKey, data);
    } else {
      final response = await _client.delete(_url('horarios', id), headers: _headers)
        .timeout(const Duration(seconds: 12));
      _decode(response);
    }
  }
}
