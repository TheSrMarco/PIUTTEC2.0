import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';

class SessionUser {
  SessionUser.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String,
      role = json['role'] as String;

  final int id;
  final String name;
  final String role;
}

class SessionController extends ChangeNotifier {
  SessionController({http.Client? client}) : _client = client ?? http.Client() {
    api = ApiClient(_client, onSessionExpired: logout);
  }

  final http.Client _client;
  late final ApiClient api;
  SessionUser? user;
  int _revision = 0;
  bool _disposed = false;

  Future<void> login(String username, String password) async {
    final revision = ++_revision;
    try {
      final tokens = await api.post('auth/login/', {
        'username': username.trim(),
        'password': password,
      });
      if (_disposed || revision != _revision) {
        throw StateError('El inicio de sesión fue cancelado.');
      }
      api.setSession(tokens['access'] as String, tokens['refresh'] as String);
      final profile = await api.get('auth/me/');
      if (_disposed || revision != _revision) {
        throw StateError('El inicio de sesión fue cancelado.');
      }
      user = SessionUser.fromJson(profile);
      notifyListeners();
    } catch (_) {
      if (revision == _revision) api.clearSession();
      rethrow;
    }
  }

  void logout() {
    _revision++;
    api.clearSession();
    user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    api.clearSession();
    _client.close();
    super.dispose();
  }
}
