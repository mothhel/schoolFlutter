class StudentNewCountsModel {
  /*
    هذا الموديل يستقبل عدادات الجديد من:
    api/Student/my-new-counts

    ملاحظة:
    أسماء JSON من API غالبًا:
    lessonsCount
    homeworksCount
    attendanceCount
    scheduleCount
    notesCount

    وبسبب C# يرجع الحروف الأولى صغيرة غالبًا.
  */

  final int lessonsCount;
  final int homeworksCount;
  final int attendanceCount;
  final int scheduleCount;
  final int notesCount;

  const StudentNewCountsModel({
    required this.lessonsCount,
    required this.homeworksCount,
    required this.attendanceCount,
    required this.scheduleCount,
    required this.notesCount,
  });

  factory StudentNewCountsModel.fromJson(Map<String, dynamic> json) {
    return StudentNewCountsModel(
      lessonsCount: json['lessonsCount'] ?? json['LessonsCount'] ?? 0,
      homeworksCount: json['homeworksCount'] ?? json['HomeworksCount'] ?? 0,
      attendanceCount: json['attendanceCount'] ?? json['AttendanceCount'] ?? 0,
      scheduleCount: json['scheduleCount'] ?? json['ScheduleCount'] ?? 0,
      notesCount: json['notesCount'] ?? json['NotesCount'] ?? 0,
    );
  }

  static const empty = StudentNewCountsModel(
    lessonsCount: 0,
    homeworksCount: 0,
    attendanceCount: 0,
    scheduleCount: 0,
    notesCount: 0,
  );
}
