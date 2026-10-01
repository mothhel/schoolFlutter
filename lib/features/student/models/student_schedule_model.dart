class StudentScheduleModel {
  /*
    هذا الموديل يمثل حصة واحدة في الجدول الدراسي.
  */

  final int id;
  final String dayName;
  final int periodNumber;
  final String startTime;
  final String endTime;
  final String roomName;
  final String notes;
  final String subjectName;
  final String teacherName;
  final String classRoomName;
  final String sectionName;
  final int? classRoomId;
  final int? sectionId;

  StudentScheduleModel({
    required this.id,
    required this.dayName,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    required this.roomName,
    required this.notes,
    required this.subjectName,
    required this.teacherName,
    required this.classRoomName,
    required this.sectionName,
    required this.classRoomId,
    required this.sectionId,
  });

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudentScheduleModel(
      id: json['id'] ?? 0,
      dayName: json['dayName'] ?? '',
      periodNumber: json['periodNumber'] ?? 0,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      roomName: json['roomName'] ?? '',
      notes: json['notes'] ?? '',
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      classRoomName: json['classRoomName'] ?? '',
      sectionName: json['sectionName'] ?? '',
      classRoomId: json['classRoomId'] is int ? json['classRoomId'] : null,
      sectionId: json['sectionId'] is int ? json['sectionId'] : null,
    );
  }
}
