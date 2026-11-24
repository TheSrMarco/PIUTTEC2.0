import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResumenRefuerzo {
  const ResumenRefuerzo({required this.intentos, this.mejor, this.promedio,
    this.logros = const []});
  final int intentos;
  final double? mejor;
  final double? promedio;
  final List<String> logros;
}

class RefuerzoRepository {
  RefuerzoRepository({this.accessToken, http.Client? client})
    : _client = client ?? http.Client(), _ownClient = client == null;
  final String? accessToken;
  final http.Client _client;
  final bool _ownClient;
  static const _base = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/');
  Uri _url(String path) => Uri.parse(_base.endsWith('/') ? _base : '$_base/').resolve(path);
  bool get isDemo => accessToken == null || accessToken!.isEmpty;
  void dispose() { if (_ownClient) _client.close(); }

  Future<void> registrar({required String tema, required int aciertos, required int total,
    String carrera = '', int? cuatrimestre, int? parcial}) async {
    if (isDemo) {
      final preferences = await SharedPreferences.getInstance();
      final key = 'piuttec_refuerzo_personal_v1';
      final previous = preferences.getStringList(key) ?? [];
      await preferences.setStringList(key, [...previous, '$aciertos/$total']);
      return;
    }
    final response = await _client.post(_url('refuerzo/intentos/'),
      headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
      body: jsonEncode({'tema': tema, 'carrera': carrera,
        'cuatrimestre': cuatrimestre, 'parcial': parcial,
        'aciertos': aciertos, 'total': total}),
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode != 201) {
      throw FormatException('No se guardó el intento (HTTP ${response.statusCode}).');
    }
  }

  Future<ResumenRefuerzo> resumen() async {
    if (isDemo) {
      final preferences = await SharedPreferences.getInstance();
      final list = preferences.getStringList('piuttec_refuerzo_personal_v1') ?? [];
      final values = <double>[];
      for (final item in list) {
        final parts = item.split('/');
        if (parts.length != 2) continue;
        final correct = int.tryParse(parts[0]);
        final total = int.tryParse(parts[1]);
        if (correct != null && total != null && total > 0) values.add(100 * correct / total);
      }
      final best = values.isEmpty ? null : values.reduce((a,b) => a > b ? a : b);
      return ResumenRefuerzo(intentos: values.length, mejor: best,
        promedio: values.isEmpty ? null : values.reduce((a,b) => a+b) / values.length,
        logros: [if (values.isNotEmpty) 'Primera práctica',
          if (values.length >= 5) 'Constancia: cinco intentos',
          if (values.any((v) => v == 100)) 'Puntuación perfecta']);
    }
    final response = await _client.get(_url('refuerzo/intentos/resumen/'),
      headers: {'Authorization': 'Bearer $accessToken'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw FormatException('No se pudo cargar el progreso (HTTP ${response.statusCode}).');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return ResumenRefuerzo(intentos: (data['intentos'] as num).toInt(),
      mejor: (data['mejor_porcentaje'] as num?)?.toDouble(),
      promedio: (data['promedio_porcentaje'] as num?)?.toDouble(),
      logros: (data['logros'] as List<dynamic>).cast<String>());
  }
}
