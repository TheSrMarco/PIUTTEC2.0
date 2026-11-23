/// RF-01: datos registrados por el usuario, no valores predefinidos.
class DashboardSubject {
  const DashboardSubject({required this.name, this.grade, this.group = ''});

  final String name;
  final double? grade;
  final String group;

  factory DashboardSubject.fromJson(Map<String, dynamic> json) => DashboardSubject(
    name: json['name'] as String,
    grade: (json['grade'] as num?)?.toDouble(),
    group: (json['group'] as String?) ?? '',
  );
}

class DashboardUpcoming {
  const DashboardUpcoming({
    required this.title,
    required this.date,
    required this.type,
    this.subject = '',
  });

  final String title;
  final String date;
  final String type;
  final String subject;

  factory DashboardUpcoming.fromJson(Map<String, dynamic> json) => DashboardUpcoming(
    title: json['title'] as String,
    date: json['date'] as String,
    type: json['type'] as String,
    subject: (json['subject'] as String?) ?? '',
  );
}

class DashboardData {
  const DashboardData({
    required this.local,
    required this.average,
    required this.subjectCount,
    required this.gradedSubjects,
    required this.pendingTasks,
    required this.completedTasks,
    required this.weeklyClasses,
    required this.subjects,
    required this.upcoming,
    this.pendingRequests,
    this.approvedRequests,
    this.attendance,
    this.attendanceRecords = 0,
    this.fileCount,
  });

  /// Cuentas Django: fuente auténtica y separada por usuario.
  /// Solo el frontend en Vista previa lee sus propios registros locales.
  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    local: false,
    average: (json['average'] as num?)?.toDouble(),
    attendance: (json['attendance'] as num?)?.toDouble(),
    attendanceRecords: (json['attendance_records'] as num?)?.toInt() ?? 0,
    subjectCount: (json['subject_count'] as num).toInt(),
    gradedSubjects: (json['graded_subjects'] as num).toInt(),
    pendingTasks: (json['pending_tasks'] as num).toInt(),
    completedTasks: (json['completed_tasks'] as num).toInt(),
    pendingRequests: (json['pending_requests'] as num).toInt(),
    approvedRequests: (json['approved_requests'] as num).toInt(),
    weeklyClasses: (json['weekly_classes'] as num).toInt(),
    fileCount: (json['file_count'] as num?)?.toInt(),
    subjects: (json['subjects'] as List<dynamic>)
        .map((item) => DashboardSubject.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
    upcoming: (json['upcoming'] as List<dynamic>)
        .map((item) => DashboardUpcoming.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );

  final bool local;
  final double? average;
  final double? attendance;
  final int attendanceRecords;
  final int subjectCount;
  final int gradedSubjects;
  final int pendingTasks;
  final int completedTasks;
  final int? pendingRequests;
  final int? approvedRequests;
  final int weeklyClasses;
  final int? fileCount;
  final List<DashboardSubject> subjects;
  final List<DashboardUpcoming> upcoming;
}
