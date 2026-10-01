class TeacherLessonModel {
  /*
    هذا الموديل يمثل درس واحد للأستاذ.

    يحتوي على:
    - بيانات الدرس
    - تاريخ الدرس
    - وقت الإضافة
    - وقت آخر تعديل
  */

  final int id;
  final String title;
  final String description;
  final DateTime lessonDate;
  final int teacherAssignmentId;
  final String subjectName;
  final String classRoomName;
  final String sectionName;

  final DateTime? createdAt;
  final String createdDayName;
  final String createdTime;

  final DateTime? updatedAt;
  final String updatedDayName;
  final String updatedTime;

  TeacherLessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonDate,
    required this.teacherAssignmentId,
    required this.subjectName,
    required this.classRoomName,
    required this.sectionName,
    this.createdAt,
    required this.createdDayName,
    required this.createdTime,
    this.updatedAt,
    required this.updatedDayName,
    required this.updatedTime,
  });

  factory TeacherLessonModel.fromJson(Map<String, dynamic> json) {
    final createdAtText = json['createdAt']?.toString();
    final updatedAtText = json['updatedAt']?.toString();

    return TeacherLessonModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      lessonDate: DateTime.tryParse(json['lessonDate'] ?? '') ?? DateTime.now(),
      teacherAssignmentId: json['teacherAssignmentId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      classRoomName: json['classRoomName'] ?? '',
      sectionName: json['sectionName'] ?? '',

      createdAt:
          createdAtText == null || createdAtText.isEmpty
              ? null
              : DateTime.tryParse(createdAtText),
      createdDayName: json['createdDayName'] ?? '',
      createdTime: json['createdTime'] ?? '',

      updatedAt:
          updatedAtText == null || updatedAtText.isEmpty
              ? null
              : DateTime.tryParse(updatedAtText),
      updatedDayName: json['updatedDayName'] ?? '',
      updatedTime: json['updatedTime'] ?? '',
    );
  }
}
