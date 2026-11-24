import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ArchivoAcademico {
  const ArchivoAcademico({required this.id, required this.nombre,
    required this.materia, required this.tamano, required this.fecha});
  final int id;
  final String nombre;
  final String materia;
  final int tamano;
  final String fecha;

  factory ArchivoAcademico.fromJson(Map<String, dynamic> json) => ArchivoAcademico(
    id: (json['id'] as num).toInt(),
    nombre: json['nombre'] as String,
    materia: json['materia'] as String? ?? '',
    tamano: (json['tamano'] as num).toInt(),
    fecha: json['creado_en'] as String,
  );
}

class ArchivosRepository {
  ArchivosRepository({required this.accessToken, http.Client? client})
      : _client = client ?? http.Client(), _ownClient = client == null;
  final String accessToken;
  final http.Client _client;
  final bool _ownClient;
  static const _base = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/');
  Uri _url(String path) => Uri.parse(_base.endsWith('/') ? _base : '$_base/').resolve(path);
  Map<String, String> get _auth => {'Authorization': 'Bearer $accessToken'};

  void dispose() { if (_ownClient) _client.close(); }

  void _check(http.Response response, {int expected = 200}) {
    if (response.statusCode == 401) {
      throw const FormatException('La sesión caducó. Vuelve a iniciar sesión.');
    }
    if (response.statusCode != expected) {
      throw FormatException('No se pudo completar la operación (HTTP ${response.statusCode}).');
    }
  }

  Future<List<ArchivoAcademico>> listar() async {
    final response = await _client.get(_url('archivos/'), headers: _auth)
        .timeout(const Duration(seconds: 15));
    _check(response);
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data.map((item) => ArchivoAcademico.fromJson(
      Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<void> subir({required String nombre, required Uint8List contenido,
      String materia = ''}) async {
    if (contenido.isEmpty || contenido.length > 10 * 1024 * 1024) {
      throw const FormatException('El archivo debe pesar entre 1 byte y 10 MB.');
    }
    final request = http.MultipartRequest('POST', _url('archivos/'))
      ..headers.addAll(_auth)
      ..fields['materia'] = materia
      ..files.add(http.MultipartFile.fromBytes('archivo', contenido, filename: nombre));
    final streamed = await _client.send(request).timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamed);
    _check(response, expected: 201);
  }

  Future<Uint8List> descargar(int id) async {
    final response = await _client.get(_url('archivos/$id/descargar/'), headers: _auth)
        .timeout(const Duration(seconds: 25));
    _check(response);
    return response.bodyBytes;
  }

  Future<void> eliminar(int id) async {
    final response = await _client.delete(_url('archivos/$id/'), headers: _auth)
        .timeout(const Duration(seconds: 15));
    _check(response, expected: 204);
  }
}
