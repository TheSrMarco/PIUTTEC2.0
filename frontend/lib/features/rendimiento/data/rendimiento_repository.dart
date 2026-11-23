import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../academia/data/academia_repository.dart';

class MateriaRendimiento {
  const MateriaRendimiento({
    required this.id,
    required this.nombre,
    required this.grupo,
    required this.calificacion,
    required this.promedioGrupal,
    required this.participantes,
    required this.diferencia,
    required this.estadoGrupal,
  });

  final int id;
  final String nombre;
  final String grupo;
  final double? calificacion;
  final double? promedioGrupal;
  final int? participantes;
  final double? diferencia;
  final String estadoGrupal;

  factory MateriaRendimiento.fromJson(Map<String, dynamic> json) =>
      MateriaRendimiento(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre'] as String,
        grupo: json['grupo'] as String? ?? '',
        calificacion: (json['calificacion'] as num?)?.toDouble(),
        promedioGrupal: (json['promedio_grupal'] as num?)?.toDouble(),
        participantes: (json['participantes'] as num?)?.toInt(),
        diferencia: (json['diferencia'] as num?)?.toDouble(),
        estadoGrupal: json['estado_grupal'] as String,
      );
}

class ReporteRendimiento {
  const ReporteRendimiento({
    required this.promedioPersonal,
    required this.evaluadas,
    required this.sinCalificar,
    required this.materias,
    required this.minimoGrupal,
    required this.aviso,
    required this.demostracion,
  });

  final double? promedioPersonal;
  final int evaluadas;
  final int sinCalificar;
  final List<MateriaRendimiento> materias;
  final int minimoGrupal;
  final String aviso;
  final bool demostracion;

  factory ReporteRendimiento.fromJson(Map<String, dynamic> json) =>
      ReporteRendimiento(
        promedioPersonal: (json['promedio_personal'] as num?)?.toDouble(),
        evaluadas: (json['materias_evaluadas'] as num).toInt(),
        sinCalificar: (json['materias_sin_calificar'] as num).toInt(),
        materias: (json['materias'] as List<dynamic>)
            .map((item) => MateriaRendimiento.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList(),
        minimoGrupal: (json['minimo_grupal'] as num).toInt(),
        aviso: json['aviso'] as String,
        demostracion: false,
      );

  /// La vista previa usa SOLO notas propias guardadas en este navegador.
  /// No fabrica participantes ni medias grupales.
  factory ReporteRendimiento.local(List<MateriaAcademica> materias) {
    final notas = materias
        .where((item) => item.calificacion != null)
        .map((item) => item.calificacion!)
        .toList();
    final personal = notas.isEmpty
        ? null
        : double.parse((notas.reduce((a, b) => a + b) / notas.length)
            .toStringAsFixed(2));
    return ReporteRendimiento(
      promedioPersonal: personal,
      evaluadas: notas.length,
      sinCalificar: materias.length - notas.length,
      materias: [
        for (final materia in materias)
          MateriaRendimiento(
            id: materia.id,
            nombre: materia.nombre,
            grupo: materia.grupo,
            calificacion: materia.calificacion,
            promedioGrupal: null,
            participantes: null,
            diferencia: null,
            estadoGrupal: materia.calificacion == null
                ? 'sin_calificacion'
                : materia.grupo.trim().isEmpty
                    ? 'sin_grupo'
                    : 'sin_datos_grupales_demo',
          ),
      ],
      minimoGrupal: 5,
      aviso: 'La vista previa calcula tus notas locales. No contiene datos '
          'grupales ni calificaciones institucionales.',
      demostracion: true,
    );
  }
}

/// RF-04: resumen individual y media de cohorte desde Django.
/// Los errores de API no se sustituyen por datos de ejemplo.
class RendimientoRepository {
  RendimientoRepository({this.accessToken, http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final String? accessToken;
  final http.Client _client;
  final bool _ownsClient;
  bool get local => accessToken == null || accessToken!.isEmpty;

  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/',
  );

  Future<ReporteRendimiento> cargar() async {
    if (local) {
      final academia = AcademiaRepository();
      try {
        return ReporteRendimiento.local(await academia.listarMaterias());
      } finally {
        academia.dispose();
      }
    }
    final prefix = apiBase.endsWith('/') ? apiBase : '$apiBase/';
    final response = await _client.get(
      Uri.parse(prefix).resolve('rendimiento/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode == 401) {
      throw const FormatException('La sesión caducó. Inicia sesión nuevamente.');
    }
    if (response.statusCode != 200) {
      throw FormatException('Error al consultar rendimiento (HTTP ${response.statusCode}).');
    }
    return ReporteRendimiento.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
