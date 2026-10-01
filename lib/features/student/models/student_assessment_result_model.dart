import 'student_assessment_grade_item_model.dart';

class StudentAssessmentResultModel {
  /*
    يمثل نتيجة محصلة كاملة:
    - الصف
    - الشعبة
    - اسم المحصلة
    - المواد والدرجات
  */

  final int classRoomId;
  final String classRoomName;
  final int sectionId;
  final String sectionName;
  final String assessmentType;
  final String assessmentTitle;
  final List<StudentAssessmentGradeItemModel> items;

  StudentAssessmentResultModel({
    required this.classRoomId,
    required this.classRoomName,
    required this.sectionId,
    required this.sectionName,
    required this.assessmentType,
    required this.assessmentTitle,
    required this.items,
  });

  factory StudentAssessmentResultModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return StudentAssessmentResultModel(
      classRoomId: json['classRoomId'] ?? 0,
      classRoomName: json['classRoomName'] ?? '',
      sectionId: json['sectionId'] ?? 0,
      sectionName: json['sectionName'] ?? '',
      assessmentType: json['assessmentType'] ?? '',
      assessmentTitle: json['assessmentTitle'] ?? '',
      items:
          itemsJson
              .map(
                (item) => StudentAssessmentGradeItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
