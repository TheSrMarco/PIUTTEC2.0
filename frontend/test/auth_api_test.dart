import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/features/auth/data/auth_session.dart';

void main() {
  test('Registro envía datos a Django y no solicita rol administrador', () async {
    final api = AuthApi(client: MockClient((request) async {
      expect(request.url.path, '/api/auth/register/');
      expect(request.method, 'POST');
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload['accepted_privacy'], isTrue);
      expect(payload.containsKey('role'), isFalse);
      return http.Response(jsonEncode({
        'id': 1, 'username': 'alumno1', 'email': 'alumno@example.test',
        'first_name': 'Alma', 'last_name': 'Prueba', 'role': 'student',
      }), 201, headers: {'content-type': 'application/json'});
    }));
    final profile = await api.register(username: 'alumno1', email: 'alumno@example.test',
      firstName: 'Alma', lastName: 'Prueba', password: 'Secreta2026!ok',
      passwordConfirm: 'Secreta2026!ok', acceptedPrivacy: true);
    expect(profile.role, 'student');
    expect(profile.username, 'alumno1');
  });

  test('Login consulta perfil con Bearer token de Django', () async {
    final api = AuthApi(client: MockClient((request) async {
      if (request.url.path.endsWith('/auth/login/')) {
        expect(jsonDecode(request.body)['password'], 'Prueba2026!');
        return http.Response('{"access":"token-abc","refresh":"refresh-def"}', 200);
      }
      expect(request.url.path, '/api/auth/me/');
      expect(request.headers['Authorization'], 'Bearer token-abc');
      return http.Response('{"id":2,"username":"alumno","email":"alumno@example.test","role":"student"}', 200);
    }));
    final session = await api.signIn('alumno', 'Prueba2026!');
    expect(session.username, 'alumno');
    expect(session.accessToken, 'token-abc');
  });

  test('Actualizar perfil no envía privilegios', () async {
    final api = AuthApi(client: MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/auth/me/');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body.containsKey('role'), isFalse);
      expect(body.containsKey('is_staff'), isFalse);
      return http.Response('{"id":3,"username":"nuevo","email":"nuevo@example.test","role":"student"}', 200);
    }));
    final profile = await api.updateProfile('token', username: 'nuevo',
      firstName: '', lastName: '', email: 'nuevo@example.test');
    expect(profile.username, 'nuevo');
  });

  test('Cerrar sesión envía refresh para revocación', () async {
    final api = AuthApi(client: MockClient((request) async {
      expect(request.url.path, '/api/auth/logout/');
      expect(jsonDecode(request.body)['refresh'], 'refresh-123');
      return http.Response('', 204);
    }));
    await api.signOut(const AuthSession(username: 'alumno', accessToken: 'a', refreshToken: 'refresh-123'));
  });

  test('Los errores de validación se presentan en español', () async {
    final api = AuthApi(client: MockClient((_) async =>
      http.Response('{"email":["Este correo ya está registrado."]}', 400,
        headers: {'content-type': 'application/json; charset=utf-8'})));
    expect(() => api.register(username: 'estudiante', email: 'estudiante@example.test',
      firstName: '', lastName: '', password: 'Prueba2026!largo',
      passwordConfirm: 'Prueba2026!largo', acceptedPrivacy: true),
      throwsA(isA<FormatException>()));
  });
}
