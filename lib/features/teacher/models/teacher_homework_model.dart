class TeacherHomeworkModel {
  /*
    هذا الموديل يمثل واجب واحد للأستاذ.

    يحتوي على:
    - بيانات الواجب
    - مهلة التسليم
    - وقت الإضافة
    - وقت آخر تعديل
    - المادة
    - الصف
    - الشعبة
  */

  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int teacherAssignmentId;

  final DateTime createdAt;
  final String createdDayName;
  final String createdTime;

  final DateTime? updatedAt;
  final String updatedDayName;
  final String updatedTime;

  final String subjectName;
  final String classRoomName;
  final String sectionName;

  TeacherHomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.teacherAssignmentId,
    required this.createdAt,
    required this.createdDayName,
    required this.createdTime,
    this.updatedAt,
    required this.updatedDayName,
    required this.updatedTime,
    required this.subjectName,
    required this.classRoomName,
    required this.sectionName,
  });

  factory TeacherHomeworkModel.fromJson(Map<String, dynamic> json) {
    final parsedDueDate =
        DateTime.tryParse(json['dueDate']?.toString() ?? '') ?? DateTime.now();

    final parsedCreatedAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.tryParse(json['createdDate']?.toString() ?? '') ??
        DateTime.tryParse(json['createdOn']?.toString() ?? '') ??
        parsedDueDate;

    final parsedUpdatedAt =
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.tryParse(json['updatedDate']?.toString() ?? '') ??
        DateTime.tryParse(json['updatedOn']?.toString() ?? '');

    return TeacherHomeworkModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: parsedDueDate,
      teacherAssignmentId: json['teacherAssignmentId'] ?? 0,
      createdAt: parsedCreatedAt,
      createdDayName: json['createdDayName'] ?? '',
      createdTime: json['createdTime'] ?? '',
      updatedAt: parsedUpdatedAt,
      updatedDayName: json['updatedDayName'] ?? '',
      updatedTime: json['updatedTime'] ?? '',
      subjectName: json['subjectName'] ?? '',
      classRoomName: json['classRoomName'] ?? '',
      sectionName: json['sectionName'] ?? '',
    );
  }
}
