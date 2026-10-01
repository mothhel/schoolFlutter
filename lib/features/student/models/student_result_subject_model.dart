import 'student_result_component_model.dart';

class StudentResultSubjectModel {
  /*
    هذا الموديل يمثل نتيجة مادة واحدة.

    يعرض:
    - اسم المادة
    - اسم المدرس
    - مكونات النتيجة
    - المجموع
    - النسبة
    - الحالة
  */

  final String subjectName;
  final String teacherName;
  final List<StudentResultComponentModel> components;
  final double totalScore;
  final double totalMaxScore;
  final double percentage;
  final String status;

  StudentResultSubjectModel({
    required this.subjectName,
    required this.teacherName,
    required this.components,
    required this.totalScore,
    required this.totalMaxScore,
    required this.percentage,
    required this.status,
  });

  factory StudentResultSubjectModel.fromJson(Map<String, dynamic> json) {
    final componentsJson = json['components'] as List<dynamic>? ?? [];

    return StudentResultSubjectModel(
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      components:
          componentsJson
              .map(
                (item) => StudentResultComponentModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      totalMaxScore: (json['totalMaxScore'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}
