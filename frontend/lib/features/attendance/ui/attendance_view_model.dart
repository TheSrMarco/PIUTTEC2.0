import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../domain/attendance_data.dart';

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel(this._api);

  final ApiClient _api;
  List<AttendanceCourse> courses = [];
  AttendanceCourse? course;
  List<AttendanceRow> rows = [];
  DateTime date = DateTime.now();
  bool canEdit = false;
  bool loading = false;
  bool dirty = false;
  String? error;
  int revision = 0;
  bool _disposed = false;

  String get dateLabel =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (loading || _disposed) return;
    loading = true;
    error = null;
    _notify();
    try {
      await action();
    } on ApiException catch (failure) {
      if (!_disposed) error = failure.message;
    } catch (_) {
      if (!_disposed) {
        error = 'No pudimos conectar con el servidor. Inténtalo de nuevo.';
      }
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> loadCourses() => _run(() async {
    final data = await _api.get('courses/');
    if (_disposed) return;
    courses = (data['courses'] as List<dynamic>)
        .map((json) => AttendanceCourse.fromJson(json as Map<String, dynamic>))
        .toList();
    course = courses.firstOrNull;
    if (course != null) await _fetchDay();
  });

  Future<void> loadDay({
    AttendanceCourse? selectedCourse,
    DateTime? selectedDate,
  }) => _run(() async {
    course = selectedCourse ?? course;
    date = selectedDate ?? date;
    rows = [];
    dirty = false;
    await _fetchDay();
  });

  Future<void> _fetchDay() async {
    final data = await _api.get(
      'courses/${course!.id}/attendance/?date=$dateLabel',
    );
    if (!_disposed) _apply(data);
  }

  void _apply(Map<String, dynamic> data) {
    rows = (data['students'] as List<dynamic>)
        .map((json) => AttendanceRow.fromJson(json as Map<String, dynamic>))
        .toList();
    canEdit = data['can_edit'] as bool;
    dirty = false;
    revision++;
  }

  void update(
    AttendanceRow row, {
    String? status,
    String? note,
    String? time,
    bool setStatus = false,
  }) {
    if (!canEdit || loading) return;
    if (setStatus) {
      row.status = status;
      if (status == null) {
        row.note = '';
        row.timeIn = null;
      }
    }
    if (note != null) row.note = note;
    if (time != null) row.timeIn = time.isEmpty ? null : time;
    dirty = true;
    _notify();
  }

  void markPendingPresent() {
    if (!canEdit || loading) return;
    for (final row in rows.where((row) => row.status == null)) {
      row.status = 'present';
      dirty = true;
    }
    _notify();
  }

  Future<void> save() => _run(() async {
    final data = await _api.post('courses/${course!.id}/attendance/', {
      'date': dateLabel,
      'records': rows.map((row) => row.toJson()).toList(),
    });
    if (!_disposed) _apply(data);
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
