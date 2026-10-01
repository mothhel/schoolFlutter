class TeacherAssignmentModel {
  /*
    هذا الموديل يمثل تكليف تدريسي واحد للأستاذ.

    يستخدم عند إضافة درس جديد.

    الأستاذ يختار من القائمة:
    المادة - الصف - الشعبة

    لكن الذي نرسله إلى API هو:
    id
  */

  final int id;
  final String subjectName;
  final String classRoomName;
  final String sectionName;
  final String displayName;

  TeacherAssignmentModel({
    required this.id,
    required this.subjectName,
    required this.classRoomName,
    required this.sectionName,
    required this.displayName,
  });

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    final subjectName = json['subjectName'] ?? '';
    final classRoomName = json['classRoomName'] ?? '';
    final sectionName = json['sectionName'] ?? '';

    return TeacherAssignmentModel(
      id: json['id'] ?? 0,
      subjectName: subjectName,
      classRoomName: classRoomName,
      sectionName: sectionName,
      displayName:
          json['displayName'] ?? '$subjectName - $classRoomName - $sectionName',
    );
  }
}
