class StudentHomeworkModel {
  /*
    هذا الموديل يمثل واجب واحد قادم من API.

    نستخدمه لعرض:
    - عنوان الواجب
    - الوصف
    - المادة
    - المدرس
    - تاريخ التسليم
    - وقت الإضافة
    - وقت آخر تعديل
    - الصف
    - الشعبة
  */

  final int id;
  final String title;
  final String description;
  final DateTime dueDate;

  final DateTime createdAt;
  final String createdDayName;
  final String createdTime;

  final DateTime? updatedAt;
  final String updatedDayName;
  final String updatedTime;

  final String subjectName;
  final String teacherName;
  final String classRoomName;
  final String sectionName;

  StudentHomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.createdDayName,
    required this.createdTime,
    this.updatedAt,
    required this.updatedDayName,
    required this.updatedTime,
    required this.subjectName,
    required this.teacherName,
    required this.classRoomName,
    required this.sectionName,
  });

  factory StudentHomeworkModel.fromJson(Map<String, dynamic> json) {
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

    return StudentHomeworkModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: parsedDueDate,

      createdAt: parsedCreatedAt,
      createdDayName: json['createdDayName'] ?? '',
      createdTime: json['createdTime'] ?? '',

      updatedAt: parsedUpdatedAt,
      updatedDayName: json['updatedDayName'] ?? '',
      updatedTime: json['updatedTime'] ?? '',

      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      classRoomName: json['classRoomName'] ?? '',
      sectionName: json['sectionName'] ?? '',
    );
  }
}
