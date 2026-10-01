class StudentAttendanceModel {
  /*
    هذا الموديل يمثل سجل حضور أو غياب واحد.

    البيانات تأتي من:
    api/Admin/get-student-attendance/{studentId}
  */

  final int id;
  final DateTime attendanceDate;
  final String status;
  final String subjectName;
  final String teacherName;

  StudentAttendanceModel({
    required this.id,
    required this.attendanceDate,
    required this.status,
    required this.subjectName,
    required this.teacherName,
  });

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceModel(
      id: json['id'] ?? 0,
      attendanceDate:
          DateTime.tryParse(json['attendanceDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
    );
  }
}
