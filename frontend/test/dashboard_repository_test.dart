import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/academia/data/academia_repository.dart';
import 'package:piuttec_app/features/agenda/data/agenda_repository.dart';
import 'package:piuttec_app/features/dashboard/data/dashboard_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('La vista previa resume las materias, tareas y horarios guardados', () async {
    final academia = AcademiaRepository();
    final agenda = AgendaRepository();
    final m = await academia.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Programación', calificacion: 8.0));
    await academia.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Química', calificacion: 10.0));
    await academia.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Redes'));
    await academia.guardarHorario(ClaseHorario(
      id: 0, materiaId: m.id, diaSemana: 2, inicio: '08:00', fin: '10:00'));
    await agenda.crear(AgendaItem(
      id: 0, titulo: 'Entrega', tipo: 'tarea',
      fecha: DateTime.now().add(const Duration(days: 2))));
    await agenda.crear(AgendaItem(
      id: 0, titulo: 'Completada', tipo: 'evaluacion', completada: true,
      fecha: DateTime.now().add(const Duration(days: 1))));

    final repo = DashboardRepository();
    final data = await repo.cargar();
    expect(data.local, isTrue);
    expect(data.subjectCount, 3);
    expect(data.gradedSubjects, 2);
    expect(data.average, 9.0);
    expect(data.pendingTasks, 1);
    expect(data.completedTasks, 1);
    expect(data.weeklyClasses, 1);
    expect(data.upcoming.single.title, 'Entrega');
    expect(data.pendingRequests, isNull);
    expect(data.attendance, isNull);
    expect(data.fileCount, isNull);
    repo.dispose(); academia.dispose(); agenda.dispose();
  });

  test('Con JWT consulta únicamente el endpoint protegido de resumen', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/dashboard/resumen/');
      expect(request.headers['Authorization'], 'Bearer jwt-prueba');
      return http.Response(jsonEncode({
        'source': 'django', 'average': 9.1, 'attendance': null,
        'subject_count': 1, 'graded_subjects': 1,
        'pending_tasks': 2, 'completed_tasks': 3,
        'pending_requests': 1, 'approved_requests': 0,
        'weekly_classes': 4, 'file_count': null,
        'subjects': [{'id': 3, 'name': 'Matemáticas', 'grade': 9.1, 'group': '3A'}],
        'upcoming': [{'id': 1, 'title': 'Examen', 'date': '2026-12-02',
          'type': 'evaluacion', 'subject': 'Matemáticas'}],
      }), 200, headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final repo = DashboardRepository(accessToken: 'jwt-prueba', client: client);
    final data = await repo.cargar();
    expect(data.local, isFalse);
    expect(data.average, 9.1);
    expect(data.pendingRequests, 1);
    expect(data.subjects.single.name, 'Matemáticas');
    expect(data.upcoming.single.title, 'Examen');
    repo.dispose(); client.close();
  });

  test('Un error HTTP no activa modo local ni genera cifras falsas', () async {
    final client = MockClient((request) async => http.Response('Error', 503));
    final repo = DashboardRepository(accessToken: 'jwt-prueba', client: client);
    await expectLater(repo.cargar(), throwsFormatException);
    repo.dispose(); client.close();
  });

  test('JWT caducado informa de la sesión y no consulta el almacenamiento local', () async {
    final client = MockClient((_) async => http.Response('{}', 401));
    final repo = DashboardRepository(accessToken: 'jwt-vencido', client: client);
    await expectLater(repo.cargar(), throwsFormatException);
    repo.dispose(); client.close();
  });
}
