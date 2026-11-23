import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/features/recursos/data/recursos_repository.dart';

void main() {
  test('Catálogo lee datos Django del usuario autorizado', () async {
    final repository = RecursosRepository(accessToken: 'token-demo', client: MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer token-demo');
      expect(request.url.path, '/api/recursos/');
      return http.Response('[{"id":1,"tipo":"equipo","nombre":"Laptop demo","ubicacion":"Lab","descripcion":"","capacidad":1}]', 200);
    }));
    final items = await repository.listar();
    expect(items.single.nombre, 'Laptop demo');
    expect(items.single.capacidad, 1);
    repository.dispose();
  });
}
