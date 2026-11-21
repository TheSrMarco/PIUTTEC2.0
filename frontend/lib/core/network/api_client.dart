import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
}

class ApiClient {
  ApiClient(this._client, {this.onSessionExpired});

  final http.Client _client;
  final void Function()? onSessionExpired;
  String? _access;
  String? _refresh;
  int _generation = 0;
  Future<bool>? _renewal;
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/',
  );

  void setSession(String access, String refresh) {
    _generation++;
    _access = access;
    _refresh = refresh;
  }

  void clearSession() {
    _generation++;
    _access = null;
    _refresh = null;
  }

  Uri _uri(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(base).resolve(path);
  }

  Future<Map<String, dynamic>> get(String path) => _request('GET', path);
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) =>
      _request('POST', path, data: data);

  Future<bool> _renewAccess() async {
    final generation = _generation;
    final response = await _client
        .post(
          _uri('auth/refresh/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': _refresh}),
        )
        .timeout(const Duration(seconds: 10));
    if (generation != _generation) return false;
    if (response.statusCode == 200) {
      _access =
          (jsonDecode(response.body) as Map<String, dynamic>)['access']
              as String;
      return true;
    }
    clearSession();
    onSessionExpired?.call();
    return false;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? data,
    bool retry = true,
  }) async {
    final generation = _generation;
    final request = http.Request(method, _uri(path));
    request.headers['Content-Type'] = 'application/json';
    if (_access != null) request.headers['Authorization'] = 'Bearer $_access';
    if (data != null) request.body = jsonEncode(data);
    final response = await _client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 401 &&
        retry &&
        _refresh != null &&
        generation == _generation) {
      final renewal = _renewal ??= _renewAccess();
      bool renewed;
      try {
        renewed = await renewal;
      } finally {
        if (identical(_renewal, renewal)) _renewal = null;
      }
      if (renewed) return _request(method, path, data: data, retry: false);
    }
    Map<String, dynamic> decoded = {};
    try {
      decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      // Los errores de un servidor intermedio pueden venir en HTML.
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded['detail'];
      throw ApiException(
        response.statusCode,
        detail is String ? detail : 'Revisa los datos de la solicitud.',
      );
    }
    return decoded;
  }
}
