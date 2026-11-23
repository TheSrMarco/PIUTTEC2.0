import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/academia/data/academia_repository.dart';
import 'package:piuttec_app/features/rendimiento/data/rendimiento_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Vista previa calcula promedio individual sin inventar uno grupal', () async {
    final academia = AcademiaRepository();
    await academia.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Redes', grupo: '3A', calificacion: 8.0));
    await academia.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Química', calificacion: 10.0));
    await academia.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Cálculo'));
    final repo = RendimientoRepository();
    final report = await repo.cargar();
    expect(report.promedioPersonal, 9.0);
    expect(report.evaluadas, 2);
    expect(report.sinCalificar, 1);
    expect(report.materias.every((m) => m.promedioGrupal == null), isTrue);
    expect(report.demostracion, isTrue);
    academia.dispose(); repo.dispose();
  });

  test('El endpoint de rendimiento recibe JWT y lee la media grupal', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/rendimiento/');
      expect(request.headers['Authorization'], 'Bearer prueba-token');
      return http.Response(jsonEncode({
        'promedio_personal': 9.0,
        'materias_evaluadas': 1,
        'materias_sin_calificar': 0,
        'minimo_grupal': 5,
        'aviso': 'No oficial',
        'materias': [{
          'id': 1, 'nombre': 'Redes', 'grupo': '3A',
          'calificacion': 9.0, 'promedio_grupal': 8.0,
          'participantes': 5, 'diferencia': 1.0,
          'estado_grupal': 'disponible',
        }],
      }), 200);
    });
    final repo = RendimientoRepository(accessToken: 'prueba-token', client: client);
    final report = await repo.cargar();
    expect(report.demostracion, isFalse);
    expect(report.materias.single.promedioGrupal, 8.0);
    expect(report.materias.single.diferencia, 1.0);
    repo.dispose(); client.close();
  });

  test('Un fallo del backend no se transforma en datos locales', () async {
    final client = MockClient((_) async => http.Response('error', 503));
    final repo = RendimientoRepository(accessToken: 'token', client: client);
    await expectLater(repo.cargar(), throwsFormatException);
    repo.dispose(); client.close();
  });
}
