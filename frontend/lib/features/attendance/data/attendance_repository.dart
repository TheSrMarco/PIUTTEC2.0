import 'dart:convert';

import 'package:http/http.dart' as http;

/// Registro personal de práctica, no asistencia institucional verificada.
class RegistroAsistencia {
  const RegistroAsistencia({required this.id, required this.materiaId,
    required this.materiaNombre, required this.fecha, required this.estado});

  final int id;
  final int materiaId;
  final String materiaNombre;
  final String fecha;
  final String estado;

  factory RegistroAsistencia.fromJson(Map<String, dynamic> data) => RegistroAsistencia(
    id: (data['id'] as num).toInt(),
    materiaId: (data['materia'] as num).toInt(),
    materiaNombre: (data['materia_nombre'] as String?) ?? '',
    fecha: data['fecha'] as String,
    estado: data['estado'] as String,
  );
}

/// Asistencias: siempre se comunica con Django usando JWT; no mezcla cuentas ni
/// activa almacenamiento local cuando la API falla.
class AttendanceRepository {
  AttendanceRepository({required this.accessToken, http.Client? client})
      : _client = client ?? http.Client(), _ownsClient = client == null;

  final String accessToken;
  final http.Client _client;
  final bool _ownsClient;

  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api/');

  Uri _uri([String suffix = '']) {
    final base = _apiBase.endsWith('/') ? _apiBase : '$_apiBase/';
    return Uri.parse(base).resolve('asistencias/$suffix');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': 'Bearer $accessToken',
  };

  dynamic _decode(http.Response response) {
    if (response.statusCode == 401) {
      throw const FormatException('Tu sesión caducó. Inicia sesión nuevamente.');
    }
    if (response.statusCode >= 400) {
      String detail = '';
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map && data.isNotEmpty) detail = ' ${data.values.first}';
      } catch (_) { /* Respuesta sin cuerpo JSON. */ }
      throw FormatException('No se pudo guardar la asistencia (HTTP ${response.statusCode}).$detail');
    }
    if (response.statusCode == 204) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<RegistroAsistencia>> listar() async {
    final response = await _client.get(_uri(), headers: _headers)
        .timeout(const Duration(seconds: 12));
    final data = _decode(response) as List<dynamic>;
    return data.map((value) => RegistroAsistencia.fromJson(
      Map<String, dynamic>.from(value as Map))).toList();
  }

  Future<RegistroAsistencia> registrar({required int materiaId, required String fecha,
    required String estado, int? id}) async {
    if (!{'P', 'R', 'J', 'F'}.contains(estado)) {
      throw const FormatException('Estado de asistencia desconocido.');
    }
    final payload = jsonEncode({
      if (id == null) 'materia': materiaId,
      if (id == null) 'fecha': fecha,
      'estado': estado,
    });
    final response = await (id == null
      ? _client.post(_uri(), headers: _headers, body: payload)
      : _client.patch(_uri('$id/'), headers: _headers, body: payload))
      .timeout(const Duration(seconds: 12));
    return RegistroAsistencia.fromJson(Map<String, dynamic>.from(_decode(response) as Map));
  }

  Future<void> marcarTodas({required String fecha, required List<int> materias}) async {
    if (materias.isEmpty) return;
    final response = await _client.post(_uri('marcar-todas/'),
      headers: _headers, body: jsonEncode({'fecha': fecha, 'materias': materias}))
        .timeout(const Duration(seconds: 12));
    _decode(response);
  }

  Future<void> eliminar(int id) async {
    final response = await _client.delete(_uri('$id/'), headers: _headers)
        .timeout(const Duration(seconds: 12));
    _decode(response);
  }

  void dispose() { if (_ownsClient) _client.close(); }
}
