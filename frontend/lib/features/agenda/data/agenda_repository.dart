import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Una actividad pertenece al estudiante en la API o al almacén local de la demo.
class AgendaItem {
  const AgendaItem({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.descripcion = '',
    this.materia = '',
    this.tipo = 'tarea',
    this.hora,
    this.completada = false,
  });

  final int id;
  final String titulo;
  final DateTime fecha;
  final String descripcion;
  final String materia;
  final String tipo;
  final String? hora;
  final bool completada;

  static String fechaTexto(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    final rawHora = json['hora'] as String?;
    return AgendaItem(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      descripcion: (json['descripcion'] as String?) ?? '',
      materia: (json['materia'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? 'tarea',
      hora: rawHora?.split(':').take(2).join(':'),
      completada: (json['completada'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo.trim(),
    'fecha': fechaTexto(fecha),
    'descripcion': descripcion.trim(),
    'materia': materia.trim(),
    'tipo': tipo,
    'hora': hora,
    'completada': completada,
  };

  AgendaItem copyWith({int? id, String? titulo, DateTime? fecha,
    String? descripcion, String? materia, String? tipo,
    String? hora, bool clearHora = false, bool? completada}) => AgendaItem(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    fecha: fecha ?? this.fecha,
    descripcion: descripcion ?? this.descripcion,
    materia: materia ?? this.materia,
    tipo: tipo ?? this.tipo,
    hora: clearHora ? null : (hora ?? this.hora),
    completada: completada ?? this.completada,
  );
}

/// Cuenta de Django: operaciones REST con JWT. Vista previa: persistencia local.
/// Nunca convierte automáticamente un fallo de red en guardado local.
class AgendaRepository {
  AgendaRepository({this.accessToken, http.Client? client})
    : _client = client ?? http.Client(), _ownsClient = client == null;

  final String? accessToken;
  final http.Client _client;
  final bool _ownsClient;
  static const _localKey = 'piuttec_agenda_demo_v1';
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api/',
  );

  bool get local => accessToken == null || accessToken!.isEmpty;
  void dispose() { if (_ownsClient) _client.close(); }

  Uri _url([int? id]) {
    final root = _apiBase.endsWith('/') ? _apiBase : '$_apiBase/';
    final path = id == null ? 'agenda/' : 'agenda/$id/';
    return Uri.parse(root).resolve(path);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=utf-8',
    if (!local) 'Authorization': 'Bearer $accessToken',
  };

  dynamic _extract(http.Response response) {
    if (response.statusCode >= 400) {
      if (response.statusCode == 401) {
        throw const FormatException('Tu sesión ha caducado. Cierra sesión e inicia de nuevo.');
      }
      throw FormatException('La operación no se completó (HTTP ${response.statusCode}).');
    }
    if (response.statusCode == 204) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<AgendaItem>> _readLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((entry) => AgendaItem.fromJson(Map<String, dynamic>.from(entry as Map))).toList();
  }

  Future<void> _writeLocal(List<AgendaItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_localKey, jsonEncode(items.map((e) => e.toJson()).toList()));
    if (!saved) throw const FormatException('No se pudo guardar la agenda local.');
  }

  Future<List<AgendaItem>> listar({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final List<AgendaItem> items;
    if (local) {
      items = await _readLocal();
      items.removeWhere((item) {
        if (desde != null && item.fecha.isBefore(DateTime(desde.year, desde.month, desde.day))) {
          return true;
        }
        if (hasta != null && item.fecha.isAfter(DateTime(hasta.year, hasta.month, hasta.day))) {
          return true;
        }
        return false;
      });
    } else {
      final query = <String, String>{};
      if (desde != null) query['desde'] = fechaTexto(desde);
      if (hasta != null) query['hasta'] = fechaTexto(hasta);
      final response = await _client.get(
        _url().replace(queryParameters: query),
        headers: _headers,
      )
          .timeout(const Duration(seconds: 12));
      final data = _extract(response) as List<dynamic>;
      items = data.map((entry) => AgendaItem.fromJson(Map<String, dynamic>.from(entry as Map))).toList();
    }
    items.sort((a, b) {
      final date = a.fecha.compareTo(b.fecha);
      if (date != 0) return date;
      return (a.hora ?? '').compareTo(b.hora ?? '');
    });
    return items;
  }

  Future<AgendaItem> crear(AgendaItem item) async {
    if (item.titulo.trim().isEmpty) throw const FormatException('Escribe el título.');
    if (local) {
      final items = await _readLocal();
      final next = items.fold<int>(0, (max, current) => current.id > max ? current.id : max) + 1;
      final created = item.copyWith(id: next);
      items.add(created);
      await _writeLocal(items);
      return created;
    }
    final response = await _client.post(_url(), headers: _headers, body: jsonEncode(item.toJson()))
        .timeout(const Duration(seconds: 12));
    return AgendaItem.fromJson(Map<String, dynamic>.from(_extract(response) as Map));
  }

  Future<AgendaItem> actualizar(AgendaItem item) async {
    if (item.titulo.trim().isEmpty) throw const FormatException('Escribe el título.');
    if (local) {
      final items = await _readLocal();
      final pos = items.indexWhere((other) => other.id == item.id);
      if (pos < 0) throw const FormatException('La actividad ya no existe.');
      items[pos] = item;
      await _writeLocal(items);
      return item;
    }
    final response = await _client.patch(_url(item.id), headers: _headers, body: jsonEncode(item.toJson()))
        .timeout(const Duration(seconds: 12));
    return AgendaItem.fromJson(Map<String, dynamic>.from(_extract(response) as Map));
  }

  Future<void> eliminar(int id) async {
    if (local) {
      final items = await _readLocal();
      items.removeWhere((item) => item.id == id);
      await _writeLocal(items);
    } else {
      final response = await _client.delete(_url(id), headers: _headers)
          .timeout(const Duration(seconds: 12));
      _extract(response);
    }
  }
}
