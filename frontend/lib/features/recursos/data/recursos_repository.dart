import 'dart:convert';
import 'package:http/http.dart' as http;

class RecursoInstitucional {
  const RecursoInstitucional({required this.id, required this.tipo, required this.nombre,
    required this.ubicacion, required this.descripcion, this.capacidad});
  final int id;
  final String tipo;
  final String nombre;
  final String ubicacion;
  final String descripcion;
  final int? capacidad;

  factory RecursoInstitucional.fromJson(Map<String, dynamic> json) => RecursoInstitucional(
    id: (json['id'] as num).toInt(), tipo: json['tipo'] as String,
    nombre: json['nombre'] as String, ubicacion: json['ubicacion'] as String? ?? '',
    descripcion: json['descripcion'] as String? ?? '',
    capacidad: (json['capacidad'] as num?)?.toInt(),
  );
}

class RecursosRepository {
  RecursosRepository({required this.accessToken, http.Client? client})
      : _client = client ?? http.Client(), _owns = client == null;
  final String accessToken;
  final http.Client _client;
  final bool _owns;
  static const _base = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/api/');
  Uri _url(String path) => Uri.parse(_base.endsWith('/') ? _base : '$_base/').resolve(path);

  Future<List<RecursoInstitucional>> listar() async {
    final response = await _client.get(_url('recursos/'),
      headers: {'Authorization': 'Bearer $accessToken'})
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw FormatException('No se pudo consultar el catálogo (HTTP ${response.statusCode}).');
    }
    final items = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return items.map((item) => RecursoInstitucional.fromJson(
      Map<String, dynamic>.from(item as Map))).toList();
  }

  void dispose() { if (_owns) _client.close(); }
}
