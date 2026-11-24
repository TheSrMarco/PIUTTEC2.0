import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/features/agenda/data/agenda_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Vista previa permite crear, leer, actualizar y borrar actividades locales', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = AgendaRepository();
    final created = await repository.crear(AgendaItem(
      id: 0,
      titulo: '  Parcial de programación  ',
      tipo: 'evaluacion',
      fecha: DateTime(2026, 11, 24),
      hora: '12:30',
    ));
    expect(created.id, greaterThan(0));
    expect((await repository.listar()).single.titulo, 'Parcial de programación');

    final anotherInstance = AgendaRepository();
    expect((await anotherInstance.listar()).single.id, created.id);
    await anotherInstance.actualizar(created.copyWith(completada: true));
    expect((await repository.listar()).single.completada, isTrue);
    await repository.eliminar(created.id);
    expect(await anotherInstance.listar(), isEmpty);
    repository.dispose();
    anotherInstance.dispose();
  });

  test('La agenda autenticada envía JWT y utiliza la API REST', () async {
    final captured = <http.Request>[];
    final item = AgendaItem(id: 0, titulo: 'Entrega', fecha: DateTime(2026, 11, 24));
    final client = MockClient((request) async {
      captured.add(request);
      expect(request.headers['authorization'], 'Bearer token-prueba');
      if (request.method == 'POST') {
        final content = jsonDecode(request.body) as Map<String, dynamic>;
        expect(content['titulo'], 'Entrega');
        return http.Response(jsonEncode({...content, 'id': 7}), 201,
          headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (request.method == 'GET') {
        return http.Response(jsonEncode([{...item.toJson(), 'id': 7}]), 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('', 204);
    });
    final repository = AgendaRepository(accessToken: 'token-prueba', client: client);
    final result = await repository.crear(item);
    expect(result.id, 7);
    expect((await repository.listar()).single.titulo, 'Entrega');
    await repository.eliminar(7);
    expect(captured.map((request) => request.method).toList(), ['POST', 'GET', 'DELETE']);
    expect(captured.last.url.path, endsWith('/api/agenda/7/'));
    repository.dispose();
  });

  test('En caso de 401 no convierte la operación autenticada en demo local', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async => http.Response('{"detail":"unauthorized"}', 401));
    final repository = AgendaRepository(accessToken: 'token-caducado', client: client);
    expect(repository.listar(), throwsA(isA<FormatException>()));
    repository.dispose();
  });
}
