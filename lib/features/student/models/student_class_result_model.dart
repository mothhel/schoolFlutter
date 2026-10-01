import 'student_result_subject_model.dart';

class StudentClassResultModel {
  /*
    هذا الموديل يمثل نتيجة الطالب الكاملة في صف معين.

    يحتوي:
    - الصف
    - الشعبة
    - نوع النتيجة
    - إجمالي الدرجات
    - النسبة
    - الحالة العامة
    - المواد
  */

  final int classRoomId;
  final String classRoomName;
  final int sectionId;
  final String sectionName;
  final String resultType;
  final String resultTitle;
  final double totalScore;
  final double totalMaxScore;
  final double percentage;
  final String overallStatus;
  final List<StudentResultSubjectModel> subjects;

  StudentClassResultModel({
    required this.classRoomId,
    required this.classRoomName,
    required this.sectionId,
    required this.sectionName,
    required this.resultType,
    required this.resultTitle,
    required this.totalScore,
    required this.totalMaxScore,
    required this.percentage,
    required this.overallStatus,
    required this.subjects,
  });

  factory StudentClassResultModel.fromJson(Map<String, dynamic> json) {
    final subjectsJson = json['subjects'] as List<dynamic>? ?? [];

    return StudentClassResultModel(
      classRoomId: json['classRoomId'] ?? 0,
      classRoomName: json['classRoomName'] ?? '',
      sectionId: json['sectionId'] ?? 0,
      sectionName: json['sectionName'] ?? '',
      resultType: json['resultType'] ?? '',
      resultTitle: json['resultTitle'] ?? '',
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      totalMaxScore: (json['totalMaxScore'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      overallStatus: json['overallStatus'] ?? '',
      subjects:
          subjectsJson
              .map(
                (item) => StudentResultSubjectModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
