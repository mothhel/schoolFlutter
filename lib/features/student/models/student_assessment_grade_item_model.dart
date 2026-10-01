class StudentAssessmentGradeItemModel {
  /*
    يمثل درجة مادة واحدة داخل المحصلة.
  */

  final String subjectName;
  final String teacherName;
  final double score;
  final double maxScore;
  final String? notes;

  StudentAssessmentGradeItemModel({
    required this.subjectName,
    required this.teacherName,
    required this.score,
    required this.maxScore,
    this.notes,
  });

  factory StudentAssessmentGradeItemModel.fromJson(Map<String, dynamic> json) {
    return StudentAssessmentGradeItemModel(
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      maxScore: (json['maxScore'] ?? 20).toDouble(),
      notes: json['notes'],
    );
  }
}
