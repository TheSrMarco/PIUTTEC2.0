class AttendanceCourse {
  AttendanceCourse.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String,
      group = json['group'] as String,
      period = json['period'] as String;

  final int id;
  final String name;
  final String group;
  final String period;
}

class AttendanceRow {
  AttendanceRow.fromJson(Map<String, dynamic> json)
    : enrollmentId = json['enrollment_id'] as int,
      name = json['name'] as String,
      studentCode = json['student_code'] as String,
      status = json['status'] as String?,
      note = json['note'] as String,
      timeIn = json['time_in'] as String?,
      version = json['version'] as int;

  final int enrollmentId;
  final String name;
  final String studentCode;
  final int version;
  String? status;
  String note;
  String? timeIn;

  Map<String, dynamic> toJson() => {
    'enrollment_id': enrollmentId,
    'status': status,
    'note': note,
    'time_in': timeIn,
    'version': version,
  };
}
