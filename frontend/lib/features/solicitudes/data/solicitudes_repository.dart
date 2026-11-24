import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cliente mínimo de RF-12. Mantiene el JWT solo en memoria de esta pantalla.
class SolicitudesRepository {
  SolicitudesRepository(this._client, {this._accessToken});

  final http.Client _client;
  String? _accessToken;
  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/',
  );

  Uri _url(String path) => Uri.parse(
    apiBase.endsWith('/') ? apiBase : '$apiBase/',
  ).resolve(path);

  Map<String, String> _headers() => {
    'Content-Type': 'application/json; charset=utf-8',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  dynamic _parse(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw Exception('El servidor devolvió una respuesta no válida (${response.statusCode}).');
    }
    if (response.statusCode >= 400) {
      // No registrar tokens, credenciales ni respuestas completas en logs.
      throw Exception('Error HTTP ${response.statusCode}. Verifica tus datos o permisos.');
    }
    return data;
  }

  Future<void> login(String usuario, String contrasena) async {
    final response = await _client.post(
      _url('auth/login/'),
      headers: _headers(),
      body: jsonEncode({'username': usuario, 'password': contrasena}),
    ).timeout(const Duration(seconds: 10));
    final result = _parse(response) as Map<String, dynamic>;
    _accessToken = result['access'] as String;
  }

  bool get autenticado => _accessToken != null;

  void logout() => _accessToken = null;

  Future<List<Map<String, dynamic>>> listar() async {
    final response = await _client.get(
      _url('solicitudes/'), headers: _headers(),
    ).timeout(const Duration(seconds: 10));
    final items = _parse(response) as List<dynamic>;
    return items.cast<Map<String, dynamic>>();
  }

  Future<void> crear({
    required String tipo,
    required String recurso,
    required DateTime fecha,
    required String motivo,
    String? inicio,
    String? fin,
    int? materiaId,
  }) async {
    final response = await _client.post(
      _url('solicitudes/'),
      headers: _headers(),
      body: jsonEncode({
        'tipo': tipo,
        if (tipo == 'justificante' && materiaId != null) 'materia': materiaId,
        'recurso': tipo == 'justificante' ? '' : recurso.trim(),
        'fecha_solicitada': '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
        'motivo': motivo.trim(),
        'hora_inicio': tipo == 'justificante' ? null : inicio,
        'hora_fin': tipo == 'justificante' ? null : fin,
      }),
    ).timeout(const Duration(seconds: 10));
    _parse(response);
  }

  Future<List<Map<String, dynamic>>> listarMaterias() async {
    final response = await _client.get(_url('materias/'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    final data = _parse(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> revisar(int id, {required bool aprobar, String observaciones = ''}) async {
    final response = await _client.patch(_url('solicitudes/$id/'),
      headers: _headers(),
      body: jsonEncode({'estado': aprobar ? 'aprobada' : 'rechazada',
        'observaciones_revision': observaciones.trim()}),
    ).timeout(const Duration(seconds: 10));
    _parse(response);
  }

  Future<void> registrarDevolucion(int id) async {
    final response = await _client.patch(_url('solicitudes/$id/'),
      headers: _headers(), body: jsonEncode({'estado': 'devuelta'}),
    ).timeout(const Duration(seconds: 10));
    _parse(response);
  }

  Future<void> cancelar(int id) async {
    final response = await _client.patch(
      _url('solicitudes/$id/'),
      headers: _headers(),
      body: jsonEncode({'estado': 'cancelada'}),
    ).timeout(const Duration(seconds: 10));
    _parse(response);
  }
}
