import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../models/student_profile_model.dart';
import '../models/student_lesson_model.dart';
import '../models/student_new_counts_model.dart';
import '../models/student_homework_model.dart';
import '../models/student_attendance_model.dart';
import '../models/student_note_model.dart';
import '../models/student_schedule_model.dart';
import '../models/student_grade_classroom_model.dart';
import '../models/student_assessment_result_model.dart';
import '../models/student_class_result_model.dart';

class StudentService {
  /*
    هذا الكلاس مسؤول عن طلبات الطالب من API.

    حاليًا:
    
    - 1 جلب سجل الحضور والغياب الخاص بالطالب الحالي
    - 2 نطلب كل الواجبات  حسب صف وشعبة الطالب
    - 3  جلب عدادات الجديد للطالب الحالي
    - 4 تصفير عداد قسم معين عند فتحه
    - 5 جلب الملف الشخصي للطالب
    - 6 جلب دروس الطالب حسب الصف والشعبة
    - 7  جلب ملاحظات الطالب الحالي
    - 8  جلب الجدول الدراسي حسب الصف والشعبة
    - 9  جلب الصفوف التي يوجد للطالب درجات فيها
    - 10  جلب درجات الطالب حسب الصف ونوع المحصلة
    - 11  جلب نتيجة الطالب حسب الصف ونوع النتيجة


  */

  final ApiClient _apiClient = ApiClient();

  // 1 --------------------------------------------------------------
  // 1 جلب سجل الحضور والغياب الخاص بالطالب الحالي

  Future<List<StudentAttendanceModel>> getMyAttendance({
    required int studentId,
  }) async {
    /*
    جلب سجل الحضور والغياب الخاص بالطالب الحالي.

    نستخدم StudentId القادم من my-profile.
  */

    final response = await _apiClient.get(
      ApiConstants.studentAttendance(studentId),
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل سجل الحضور والغياب';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    final attendances =
        data
            .map(
              (item) =>
                  StudentAttendanceModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    /*
    نرتب السجلات من الأحدث إلى الأقدم.
  */
    attendances.sort((a, b) => a.attendanceDate.compareTo(b.attendanceDate));

    return attendances;
  }

  // 2 -----------------------------------------------------------------
  // 2 نطلب كل الواجبات  حسب صف وشعبة الطالب

  Future<List<StudentHomeworkModel>> getMyHomeworks({
    required String classRoomName,
    required String sectionName,
  }) async {
    /*
    نطلب كل الواجبات من API ثم نفلترها داخل التطبيق
    حسب صف وشعبة الطالب.

    هذا نفس منطق الويب حاليًا.
  */

    final response = await _apiClient.get(
      ApiConstants.homeworks,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل الواجبات';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    final allHomeworks =
        data
            .map(
              (item) =>
                  StudentHomeworkModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    final filteredHomeworks =
        allHomeworks.where((homework) {
          return homework.classRoomName.trim().toLowerCase() ==
                  classRoomName.trim().toLowerCase() &&
              homework.sectionName.trim().toLowerCase() ==
                  sectionName.trim().toLowerCase();
        }).toList();

    /*
    نرتب الواجبات حسب أقرب تاريخ تسليم.
  */
    filteredHomeworks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return filteredHomeworks;
  }

  // 3 -----------------------------------------------------------------

  Future<StudentNewCountsModel> getMyNewCounts() async {
    /*
    جلب عدادات الجديد للطالب الحالي.
    يعتمد على التوكن المحفوظ في StorageService.
  */
    final response = await _apiClient.get(
      ApiConstants.studentNewCounts,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل عدادات الجديد';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return StudentNewCountsModel.fromJson(data);
  }

  // 4 -----------------------------------------------------------------
  // تصفير عداد قسم معين عند فتحه

  Future<void> markAreaAsViewed(String areaKey) async {
    /*
    تصفير عداد قسم معين عند فتحه.

    areaKey:
    Lessons
    Homeworks
    Attendance
    Schedule
    Notes
  */
    final response = await _apiClient.post(
      '${ApiConstants.markStudentAreaAsViewed}/$areaKey',
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحديث حالة المشاهدة';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }

  // 5 -----------------------------------------------------------------
  // جلب الملف الشخصي للطالب بياناته

  Future<StudentProfileModel> getMyProfile() async {
    final response = await _apiClient.get(
      ApiConstants.studentProfile,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل بيانات الطالب';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return StudentProfileModel.fromJson(data);
  }

  // 6 -----------------------------------------------------------------
  //  جلب دروس الطالب حسب الصف والشعبة

  Future<List<StudentLessonModel>> getMyLessons({
    required String classRoomName,
    required String sectionName,
  }) async {
    /*
      نطلب كل الدروس من API ثم نفلترها داخل التطبيق
      حسب صف وشعبة الطالب، مثل ما عملنا في schoolWeb.

      لاحقًا يمكننا عمل API خاص:
      api/Student/my-lessons
      ليكون أفضل، لكن الآن نستخدم الموجود.
    */

    final response = await _apiClient.get(ApiConstants.lessons, withAuth: true);

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل الدروس';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    final allLessons =
        data
            .map(
              (item) =>
                  StudentLessonModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    final notes =
        allLessons.where((lesson) {
          return lesson.classRoomName.trim().toLowerCase() ==
                  classRoomName.trim().toLowerCase() &&
              lesson.sectionName.trim().toLowerCase() ==
                  sectionName.trim().toLowerCase();
        }).toList();

    /*
  نرتب الملاحظات من الأقدم إلى الأحدث.
  يعني:
  - الذي أضيف أولًا يظهر في البداية
  - الذي أضيف أخيرًا يظهر في الأخير
*/
    notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return notes;
  }

  // 7 -----------------------------------------------------------------
  //  جلب ملاحظات الطالب الحالي.

  Future<List<StudentNoteModel>> getMyNotes() async {
    /*
    جلب ملاحظات الطالب الحالي.

    API يرجع غالبًا بهذا الشكل:
    {
      notes: [...]
    }

    لذلك نقرأ notes من JSON.
  */

    final response = await _apiClient.get(
      ApiConstants.studentNotes,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل الملاحظات';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final notesJson = data['notes'] as List<dynamic>? ?? [];

    final notes =
        notesJson
            .map(
              (item) => StudentNoteModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    /*
    نرتب الملاحظات من الأحدث إلى الأقدم.
  */
    notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return notes;
  }

  // 8 -----------------------------------------------------------------
  //  جلب الجدول الدراسي حسب الصف والشعبة.

  Future<List<StudentScheduleModel>> getMySchedule({
    required int classRoomId,
    required int sectionId,
  }) async {
    /*
    جلب الجدول الدراسي حسب الصف والشعبة.
  */

    final response = await _apiClient.get(
      ApiConstants.schoolSchedulesByClassSection(
        classRoomId: classRoomId,
        sectionId: sectionId,
      ),
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل الجدول الدراسي';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    final schedules =
        data
            .map(
              (item) =>
                  StudentScheduleModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    final dayOrder = {
      'السبت': 1,
      'الأحد': 2,
      'الاثنين': 3,
      'الثلاثاء': 4,
      'الأربعاء': 5,
      'الخميس': 6,
    };

    schedules.sort((a, b) {
      final dayCompare = (dayOrder[a.dayName] ?? 99).compareTo(
        dayOrder[b.dayName] ?? 99,
      );

      if (dayCompare != 0) {
        return dayCompare;
      }

      return a.periodNumber.compareTo(b.periodNumber);
    });

    return schedules;
  }

  // 9 -----------------------------------------------------------------
  //   جلب الصفوف التي يوجد للطالب درجات فيها

  Future<List<StudentGradeClassRoomModel>> getMyGradeClassRooms() async {
    /*
    جلب الصفوف التي يوجد للطالب درجات فيها.
  */

    final response = await _apiClient.get(
      ApiConstants.studentGradeClassRooms,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل الصفوف الخاصة بالدرجات';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map(
          (item) =>
              StudentGradeClassRoomModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // 10 -----------------------------------------------------------------
  //  جلب درجات الطالب حسب الصف ونوع المحصلة.

  Future<StudentAssessmentResultModel> getMyAssessmentGrades({
    required int classRoomId,
    required String assessmentType,
  }) async {
    /*
    جلب درجات الطالب حسب الصف ونوع المحصلة.

    assessmentType:
    First
    Second
  */

    final response = await _apiClient.get(
      ApiConstants.studentAssessmentGrades(
        classRoomId: classRoomId,
        assessmentType: assessmentType,
      ),
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل درجات المحصلة';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return StudentAssessmentResultModel.fromJson(data);
  }

  // 11 -----------------------------------------------------------------
  //   جلب نتيجة الطالب حسب الصف ونوع النتيجة

  Future<StudentClassResultModel> getMyClassResult({
    required int classRoomId,
    required String resultType,
  }) async {
    /*
    جلب نتيجة الطالب حسب الصف ونوع النتيجة.

    resultType:
    MidYear = نتيجة نصف العام
    FinalYear = نتيجة نهاية العام
  */

    final response = await _apiClient.get(
      ApiConstants.studentClassResult(
        classRoomId: classRoomId,
        resultType: resultType,
      ),
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل النتيجة';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return StudentClassResultModel.fromJson(data);
  }
}
