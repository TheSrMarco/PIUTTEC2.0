import 'dart:convert';
import 'package:http/http.dart' as http;

/// Tokens exclusivamente en memoria. No se guardan en localStorage.
class AuthSession {
  const AuthSession({required this.username, required this.accessToken,
    required this.refreshToken, this.role = 'student'});
  final String username;
  final String accessToken;
  final String refreshToken;
  final String role;

  bool get isAdministrator => role == 'administrator';

  AuthSession copyWith({String? username, String? accessToken,
      String? refreshToken, String? role}) => AuthSession(
        username: username ?? this.username,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        role: role ?? this.role);
}

class UserProfile {
  const UserProfile({required this.id, required this.username, required this.email,
    required this.firstName, required this.lastName, required this.role,
    this.isStaff = false, this.isActive = true});

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isStaff;
  final bool isActive;

  factory UserProfile.fromJson(Map<String, dynamic> data) => UserProfile(
    id: (data['id'] as num).toInt(),
    username: data['username'] as String? ?? '',
    email: data['email'] as String? ?? '',
    firstName: data['first_name'] as String? ?? '',
    lastName: data['last_name'] as String? ?? '',
    role: data['role'] as String? ?? 'student',
    isStaff: data['is_staff'] as bool? ?? false,
    isActive: data['is_active'] as bool? ?? true,
  );
}

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? _defaultClient;

  static final http.Client _defaultClient = http.Client();
  final http.Client _client;
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api/',
  );

  Uri _url(String path) => Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/')
      .resolve(path);

  Future<dynamic> _request(String method, String path,
      {String? accessToken, Map<String, dynamic>? body}) async {
    final request = http.Request(method, _url(path));
    request.headers['Accept'] = 'application/json';
    if (accessToken != null) request.headers['Authorization'] = 'Bearer $accessToken';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)));
    dynamic data;
    if (response.bodyBytes.isNotEmpty) {
      try { data = jsonDecode(utf8.decode(response.bodyBytes)); }
      catch (_) { throw FormatException('La API devolvió una respuesta inválida (HTTP ${response.statusCode}).'); }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        throw const FormatException('Credenciales incorrectas o sesión caducada.');
      }
      if (response.statusCode == 403) {
        throw const FormatException('Tu cuenta no tiene permiso para esta operación.');
      }
      if (data is Map) {
        final messages = <String>[];
        for (final entry in data.entries) {
          final value = entry.value;
          final detail = value is List ? value.join(', ') : value.toString();
          messages.add(entry.key == 'detail' || entry.key == 'non_field_errors'
              ? detail : '${entry.key}: $detail');
        }
        throw FormatException(messages.join('\n'));
      }
      throw FormatException('Error de la API: HTTP ${response.statusCode}.');
    }
    return data;
  }

  Future<AuthSession> signIn(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      throw const FormatException('Introduce usuario y contraseña.');
    }
    final data = await _request('POST', 'auth/login/',
        body: {'username': username.trim(), 'password': password});
    if (data is! Map<String, dynamic> || data['access'] is! String || data['refresh'] is! String) {
      throw const FormatException('Respuesta de autenticación inválida.');
    }
    final profile = await getProfile(data['access'] as String);
    return AuthSession(username: profile.username, accessToken: data['access'] as String,
      refreshToken: data['refresh'] as String,
      role: profile.isStaff ? 'administrator' : profile.role);
  }

  Future<UserProfile> register({required String username, required String email,
      required String firstName, required String lastName, required String password,
      required String passwordConfirm, required bool acceptedPrivacy}) async {
    final data = await _request('POST', 'auth/register/', body: {
      'username': username.trim(), 'email': email.trim(),
      'first_name': firstName.trim(), 'last_name': lastName.trim(),
      'password': password, 'password_confirm': passwordConfirm,
      'accepted_privacy': acceptedPrivacy,
    });
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfile> getProfile(String token) async => UserProfile.fromJson(
      await _request('GET', 'auth/me/', accessToken: token) as Map<String, dynamic>);

  Future<UserProfile> updateProfile(String token, {required String username,
      required String firstName, required String lastName, required String email}) async {
    final data = await _request('PATCH', 'auth/me/', accessToken: token, body: {
      'username': username.trim(), 'first_name': firstName.trim(),
      'last_name': lastName.trim(), 'email': email.trim(),
    });
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword(String token, {required String current,
      required String next, required String confirmation}) async {
    await _request('POST', 'auth/change-password/', accessToken: token, body: {
      'current_password': current,
      'new_password': next,
      'new_password_confirm': confirmation,
    });
  }

  Future<void> deleteAccount(String token) async {
    await _request('DELETE', 'auth/me/', accessToken: token);
  }

  Future<void> signOut(AuthSession session) async {
    await _request('POST', 'auth/logout/', accessToken: session.accessToken,
        body: {'refresh': session.refreshToken});
  }

  Future<List<UserProfile>> listUsers(String token) async {
    final data = await _request('GET', 'auth/users/', accessToken: token);
    if (data is! List) throw const FormatException('Formato inesperado de usuarios.');
    return data.map((item) => UserProfile.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<UserProfile> createUser(String token, {required String username,
      required String email, required String firstName, required String lastName,
      required String password}) async {
    final data = await _request('POST', 'auth/users/', accessToken: token, body: {
      'username': username, 'email': email, 'first_name': firstName, 'last_name': lastName,
      'password': password, 'password_confirm': password, 'accepted_privacy': true,
    });
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfile> updateUser(String token, UserProfile user, {String? role,
      bool? isActive, String? username, String? email}) async {
    final data = await _request('PATCH', 'auth/users/${user.id}/', accessToken: token, body: {
      'role': role ?? user.role, 'is_active': isActive ?? user.isActive,
      'username': username ?? user.username, 'email': email ?? user.email,
    });
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteUser(String token, int id) async {
    await _request('DELETE', 'auth/users/$id/', accessToken: token);
  }

  Future<AuthSession> refreshSession(AuthSession current) async {
    final data = await _request('POST', 'auth/refresh/', body: {'refresh': current.refreshToken});
    if (data is! Map<String, dynamic> || data['access'] is! String) {
      throw const FormatException('Respuesta de renovación inválida.');
    }
    return current.copyWith(accessToken: data['access'] as String,
        refreshToken: data['refresh'] as String? ?? current.refreshToken);
  }
}
