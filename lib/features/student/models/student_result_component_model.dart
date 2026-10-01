class StudentResultComponentModel {
  /*
    هذا الموديل يمثل جزء من نتيجة المادة.

    مثال:
    - المحصلة الأولى
    - نتيجة نصف العام
    - المحصلة الثانية
    - نتيجة نهاية العام
  */

  final String key;
  final String title;
  final double score;
  final double maxScore;

  StudentResultComponentModel({
    required this.key,
    required this.title,
    required this.score,
    required this.maxScore,
  });

  factory StudentResultComponentModel.fromJson(Map<String, dynamic> json) {
    return StudentResultComponentModel(
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      maxScore: (json['maxScore'] ?? 0).toDouble(),
    );
  }
}
