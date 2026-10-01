class ApiConstants {
  static const String baseUrl = 'http://172.18.96.59:45455/api';

  static const String login = '$baseUrl/Auth/login';

  static const String studentProfile = '$baseUrl/Student/my-profile';

  /*
    هذا API يرجع عدادات الجديد:
    LessonsCount
    HomeworksCount
    AttendanceCount
    ScheduleCount
    NotesCount
  */
  static const String studentNewCounts = '$baseUrl/Student/my-new-counts';

  /*
    هذا API يستخدم عند فتح صفحة معينة
    حتى يتم تصفير عدادها.
    
    نستخدمه هكذا:
    '${ApiConstants.markStudentAreaAsViewed}/Lessons'
  */
  static const String markStudentAreaAsViewed =
      '$baseUrl/Student/mark-my-area-as-viewed';

  static const String lessons = '$baseUrl/Admin/get-lessons';

  static const String homeworks = '$baseUrl/Admin/get-homeworks';

  static String studentAttendance(int studentId) =>
      '$baseUrl/Admin/get-student-attendance/$studentId';

  static const String studentNotes = '$baseUrl/Student/my-notes';

  static String schoolSchedulesByClassSection({
    required int classRoomId,
    required int sectionId,
  }) =>
      '$baseUrl/Admin/get-school-schedules-by-class-section?classRoomId=$classRoomId&sectionId=$sectionId';

  static const String studentGradeClassRooms =
      '$baseUrl/Student/my-grade-classrooms';

  static String studentAssessmentGrades({
    required int classRoomId,
    required String assessmentType,
  }) =>
      '$baseUrl/Student/my-assessment-grades?classRoomId=$classRoomId&assessmentType=$assessmentType';

  static String studentClassResult({
    required int classRoomId,
    required String resultType,
  }) =>
      '$baseUrl/Student/my-class-result?classRoomId=$classRoomId&resultType=$resultType';

  //-------------- الاستاذ -------------------
  static const String teacherProfile = '$baseUrl/Teacher/my-profile';
  static const String teacherSchedule = '$baseUrl/Teacher/my-schedule';
  static const String teacherLessons = '$baseUrl/Teacher/my-lessons';
  static const String teacherAssignments = '$baseUrl/Teacher/my-assignments';
  static const String teacherCreateLesson = '$baseUrl/Teacher/create-lesson';
  static String teacherUpdateLesson(int id) =>
      '$baseUrl/Teacher/update-lesson/$id';

  static String teacherDeleteLesson(int id) =>
      '$baseUrl/Teacher/delete-lesson/$id';

  /*
  روابط واجبات الأستاذ.

  تستخدم في:
  - عرض واجبات الأستاذ
  - إضافة واجب
  - تعديل واجب
  - حذف واجب
*/
  static const String teacherHomeworks = '$baseUrl/Teacher/my-homeworks';

  static const String teacherCreateHomework =
      '$baseUrl/Teacher/create-homework';

  static String teacherUpdateHomework(int id) =>
      '$baseUrl/Teacher/update-homework/$id';

  static String teacherDeleteHomework(int id) =>
      '$baseUrl/Teacher/delete-homework/$id';
}




// static const String baseUrl = 'http://172.17.154.11:45465/api';