import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/features/refuerzo/data/refuerzo_repository.dart';

void main() {
  test('Registra intento sin adjuntar el usuario y lee logros', () async {
    final repo = RefuerzoRepository(accessToken: 'token-test', client: MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer token-test');
      if (request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['aciertos'], 2);
        expect(body.containsKey('usuario'), isFalse);
        return http.Response('{"id":1}', 201);
      }
      return http.Response('{"intentos":1,"mejor_porcentaje":66.67,"promedio_porcentaje":66.67,"logros":["Primera práctica"]}', 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
    }));
    await repo.registrar(tema: 'Redes', aciertos: 2, total: 3);
    final summary = await repo.resumen();
    expect(summary.intentos, 1);
    expect(summary.logros, contains('Primera práctica'));
    repo.dispose();
  });
}
