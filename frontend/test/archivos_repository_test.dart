import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/features/archivos/data/archivos_repository.dart';

void main() {
  test('Listado de archivos requiere JWT y convierte metadatos', () async {
    final repository = ArchivosRepository(accessToken: 'token-test', client: MockClient((request) async {
      expect(request.url.path, '/api/archivos/');
      expect(request.headers['Authorization'], 'Bearer token-test');
      return http.Response('[{"id":3,"nombre":"entrega.pdf","materia":"DWI","tamano":1024,"creado_en":"2026-11-23T00:00:00Z"}]', 200);
    }));
    final list = await repository.listar();
    expect(list.single.nombre, 'entrega.pdf');
    expect(list.single.tamano, 1024);
    repository.dispose();
  });

  test('Rechaza archivo vacío y mayor a 10 MB antes de transmitir', () async {
    final repository = ArchivosRepository(accessToken: 'token-test', client: MockClient((request) async => http.Response('', 500)));
    await expectLater(repository.subir(nombre: 'vacio.pdf', contenido: Uint8List(0)), throwsFormatException);
    await expectLater(repository.subir(nombre: 'grande.pdf', contenido: Uint8List(10 * 1024 * 1024 + 1)), throwsFormatException);
    repository.dispose();
  });
}
