class TeacherScheduleModel {
  /*
    يمثل حصة واحدة في جدول الأستاذ.
  */

  final int id;
  final String dayName;
  final int periodNumber;
  final String startTime;
  final String endTime;
  final String roomName;
  final String notes;
  final String subjectName;
  final String classRoomName;
  final String sectionName;

  TeacherScheduleModel({
    required this.id,
    required this.dayName,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    required this.roomName,
    required this.notes,
    required this.subjectName,
    required this.classRoomName,
    required this.sectionName,
  });

  factory TeacherScheduleModel.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleModel(
      id: json['id'] ?? 0,
      dayName: json['dayName'] ?? '',
      periodNumber: json['periodNumber'] ?? 0,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      roomName: json['roomName'] ?? '',
      notes: json['notes'] ?? '',
      subjectName: json['subjectName'] ?? '',
      classRoomName: json['classRoomName'] ?? '',
      sectionName: json['sectionName'] ?? '',
    );
  }
}
