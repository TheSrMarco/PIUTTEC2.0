import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/features/attendance/data/attendance_repository.dart';

void main() {
  const sample = {
    'id': 12, 'materia': 4, 'materia_nombre': 'Biología',
    'fecha': '2026-11-20', 'estado': 'P',
  };

  test('Listar usa JWT y transforma la respuesta del backend', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/asistencias/');
      expect(request.headers['Authorization'], 'Bearer prueba');
      return http.Response(jsonEncode([sample]), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final repo = AttendanceRepository(accessToken: 'prueba', client: client);
    final registros = await repo.listar();
    expect(registros.single.materiaNombre, 'Biología');
    expect(registros.single.estado, 'P');
    repo.dispose(); client.close();
  });

  test('Registrar crea un registro para una fecha y materia', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/asistencias/');
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      expect(data['materia'], 4);
      expect(data['fecha'], '2026-11-20');
      expect(data['estado'], 'P');
      return http.Response(jsonEncode(sample), 201,
        headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final repo = AttendanceRepository(accessToken: 'prueba', client: client);
    expect((await repo.registrar(materiaId: 4, fecha: '2026-11-20', estado: 'P')).id, 12);
    repo.dispose(); client.close();
  });

  test('Actualizar utiliza PATCH sin modificar materia o fecha', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/asistencias/12/');
      expect(jsonDecode(request.body), {'estado': 'J'});
      return http.Response(jsonEncode({...sample, 'estado': 'J'}), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final repo = AttendanceRepository(accessToken: 'prueba', client: client);
    expect((await repo.registrar(id: 12, materiaId: 4, fecha: '2026-11-20', estado: 'J')).estado, 'J');
    repo.dispose(); client.close();
  });

  test('Marcación masiva utiliza el endpoint transaccional', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/asistencias/marcar-todas/');
      expect(jsonDecode(request.body), {'fecha': '2026-11-20', 'materias': [4, 5]});
      return http.Response('{"actualizadas":2,"fecha":"2026-11-20"}', 200);
    });
    final repo = AttendanceRepository(accessToken: 'prueba', client: client);
    await repo.marcarTodas(fecha: '2026-11-20', materias: [4, 5]);
    repo.dispose(); client.close();
  });

  test('Eliminar utiliza la API y admite HTTP 204', () async {
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(request.url.path, '/api/asistencias/12/');
      return http.Response('', 204);
    });
    final repo = AttendanceRepository(accessToken: 'prueba', client: client);
    await repo.eliminar(12);
    repo.dispose(); client.close();
  });

  test('JWT vencido genera error y no sustituye datos por demo', () async {
    final client = MockClient((_) async => http.Response('{"detail":"No"}', 401));
    final repo = AttendanceRepository(accessToken: 'vencido', client: client);
    await expectLater(repo.listar(), throwsFormatException);
    repo.dispose(); client.close();
  });

  test('Un estado no permitido se rechaza antes del POST', () async {
    final client = MockClient((_) async => fail('No debe llamar API'));
    final repo = AttendanceRepository(accessToken: 'prueba', client: client);
    await expectLater(repo.registrar(materiaId: 4, fecha: '2026-11-20', estado: 'Z'),
      throwsFormatException);
    repo.dispose(); client.close();
  });
}
