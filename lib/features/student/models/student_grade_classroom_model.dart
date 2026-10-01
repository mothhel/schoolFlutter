class StudentGradeClassRoomModel {
  /*
    يمثل الصف والشعبة التي يوجد للطالب درجات فيها.
  */

  final int classRoomId;
  final String classRoomName;
  final int sectionId;
  final String sectionName;

  StudentGradeClassRoomModel({
    required this.classRoomId,
    required this.classRoomName,
    required this.sectionId,
    required this.sectionName,
  });

  factory StudentGradeClassRoomModel.fromJson(Map<String, dynamic> json) {
    return StudentGradeClassRoomModel(
      classRoomId: json['classRoomId'] ?? 0,
      classRoomName: json['classRoomName'] ?? '',
      sectionId: json['sectionId'] ?? 0,
      sectionName: json['sectionName'] ?? '',
    );
  }
}
