import 'package:flutter/foundation.dart';

import '../data/dashboard_repository.dart';
import '../domain/dashboard_data.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._repository);

  final DashboardRepository _repository;
  DashboardData? data;
  bool loading = false;
  String? error;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed || loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.cargar();
      if (_disposed) return;
      data = result;
    } catch (ex) {
      if (_disposed) return;
      error = ex is FormatException
          ? ex.message
          : 'No pudimos cargar el panel. Verifica la conexión o los datos guardados.';
    } finally {
      if (!_disposed) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.dispose();
    super.dispose();
  }
}
