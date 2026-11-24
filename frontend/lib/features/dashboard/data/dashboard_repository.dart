import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../academia/data/academia_repository.dart';
import '../../agenda/data/agenda_repository.dart';
import '../domain/dashboard_data.dart';

/// RF-01: con JWT consulta Django; en Vista previa resume los datos locales
/// existentes de RF-02 y RF-03. Nunca utiliza el fixture del antiguo dashboard.
class DashboardRepository {
  DashboardRepository({this.accessToken, http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final String? accessToken;
  final http.Client _client;
  final bool _ownsClient;

  bool get local => accessToken == null || accessToken!.isEmpty;

  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api/',
  );

  Future<DashboardData> cargar() async {
    if (local) return _cargarLocal();
    final base = _apiBase.endsWith('/') ? _apiBase : '$_apiBase/';
    final response = await _client.get(
      Uri.parse(base).resolve('dashboard/resumen/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode == 401) {
      throw const FormatException('La sesión caducó. Inicia sesión nuevamente.');
    }
    if (response.statusCode != 200) {
      throw FormatException('No se pudo cargar el panel (HTTP ${response.statusCode}).');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Formato inesperado en el resumen académico.');
    }
    return DashboardData.fromJson(decoded);
  }

  Future<DashboardData> _cargarLocal() async {
    final academia = AcademiaRepository();
    final agenda = AgendaRepository();
    try {
      final materias = await academia.listarMaterias();
      final horarios = await academia.listarHorarios();
      final actividades = await agenda.listar();
      final notas = materias.where((item) => item.calificacion != null)
          .map((item) => item.calificacion!).toList();
      final promedio = notas.isEmpty
          ? null
          : double.parse((notas.reduce((a, b) => a + b) / notas.length)
              .toStringAsFixed(2));
      final pendientes = actividades.where((item) => !item.completada &&
          (item.tipo == 'tarea' || item.tipo == 'evaluacion'));
      final completadas = actividades.where((item) => item.completada &&
          (item.tipo == 'tarea' || item.tipo == 'evaluacion'));
      final hoy = DateTime.now();
      final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final proximas = actividades.where((item) => !item.completada &&
          !DateTime(item.fecha.year, item.fecha.month, item.fecha.day).isBefore(fechaHoy))
          .take(5);
      return DashboardData(
        local: true,
        average: promedio,
        subjectCount: materias.length,
        gradedSubjects: notas.length,
        pendingTasks: pendientes.length,
        completedTasks: completadas.length,
        weeklyClasses: horarios.length,
        // Solicitudes y asistencia no se sincronizan en el modo local.
        pendingRequests: null,
        approvedRequests: null,
        attendance: null,
        fileCount: null,
        subjects: [
          for (final materia in materias)
            DashboardSubject(name: materia.nombre, grade: materia.calificacion,
                group: materia.grupo),
        ],
        upcoming: [
          for (final item in proximas)
            DashboardUpcoming(title: item.titulo,
                date: AgendaItem.fechaTexto(item.fecha), type: item.tipo,
                subject: item.materia),
        ],
      );
    } finally {
      academia.dispose();
      agenda.dispose();
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
