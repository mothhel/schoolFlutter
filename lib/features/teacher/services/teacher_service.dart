import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../models/teacher_profile_model.dart';
import '../models/teacher_schedule_model.dart';
import '../models/teacher_assignment_model.dart';
import '../models/teacher_lesson_model.dart';
import '../models/teacher_homework_model.dart';

class TeacherService {
  // الكلاس يخص التالي :
  // 1 -  هذا الكلاس مسؤول عن طلبات الأستاذ من API.
  // 2 -  جلب جدول الأستاذ الحالي من API.
  // 3 -   جلب التكليفات الخاصة بالأستاذ الحالي.
  // 4 -   جلب دروس الأستاذ الحالي فقط.
  // 5 -   تعديل درس موجود.
  // 6 -   حذف درس موجود.
  // 7 -   خصائص اضافة وتعديل وحذف واجب

  // 1 -------------------------------------------------------
  //   هذا الكلاس مسؤول عن طلبات الأستاذ من API.

  /*
    هذا الكلاس مسؤول عن طلبات الأستاذ من API.

    الآن سنبدأ فقط بجلب بيانات الأستاذ.
    لاحقًا نضيف:
    - جدولي الدراسي
    - دروسي
    - واجباتي
    - حضور وغياب
    - درجات
  */

  final ApiClient _apiClient = ApiClient();

  Future<TeacherProfileModel> getMyProfile() async {
    final response = await _apiClient.get(
      ApiConstants.teacherProfile,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل بيانات الأستاذ';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return TeacherProfileModel.fromJson(data);
  }

  // 2 ---------------------------------------------------------------
  //   جلب جدول الأستاذ الحالي من API.

  Future<List<TeacherScheduleModel>> getMySchedule() async {
    /*
    جلب جدول الأستاذ الحالي من API.
  */

    final response = await _apiClient.get(
      ApiConstants.teacherSchedule,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل جدول الأستاذ';

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
                  TeacherScheduleModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    return schedules;
  }

  // 3 ---------------------------------------------------------------
  //   جلب التكليفات الخاصة بالأستاذ الحالي.

  Future<List<TeacherAssignmentModel>> getMyAssignments() async {
    /*
    جلب التكليفات الخاصة بالأستاذ الحالي.

    تستخدم في صفحة إضافة درس حتى يختار الأستاذ:
    المادة - الصف - الشعبة
  */

    final response = await _apiClient.get(
      ApiConstants.teacherAssignments,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل تكليفات الأستاذ';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map(
          (item) =>
              TeacherAssignmentModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // 4 -------------------------------------------------------------------
  //   جلب دروس الأستاذ الحالي فقط.

  Future<List<TeacherLessonModel>> getMyLessons() async {
    /*
    جلب دروس الأستاذ الحالي فقط.
  */

    final response = await _apiClient.get(
      ApiConstants.teacherLessons,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل دروس الأستاذ';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    final lessons =
        data
            .map(
              (item) =>
                  TeacherLessonModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    /*
    نرتب الدروس من الأقدم إلى الأحدث.
    يعني:
    - الذي أضيف أولًا يظهر في البداية
    - الذي أضيف أخيرًا يظهر في الأخير
  */
    lessons.sort((a, b) {
      final aDate = a.createdAt ?? a.lessonDate;
      final bDate = b.createdAt ?? b.lessonDate;

      return aDate.compareTo(bDate);
    });

    return lessons;
  }

  Future<void> createLesson({
    required int teacherAssignmentId,
    required String title,
    required String description,
    required DateTime lessonDate,
  }) async {
    /*
    إضافة درس جديد من حساب الأستاذ.

    الرابط المستخدم:
    api/Teacher/create-lesson
  */

    final response = await _apiClient.post(
      ApiConstants.teacherCreateLesson,
      withAuth: true,
      body: {
        'teacherAssignmentId': teacherAssignmentId,
        'title': title,
        'description': description,
        'lessonDate': lessonDate.toIso8601String(),
      },
    );

    if (response.statusCode != 200) {
      String message = 'تعذر إضافة الدرس';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }

  // 5 ---------------------------------------------------------------------
  //   تعديل درس موجود.

  Future<void> updateLesson({
    required int lessonId,
    required int teacherAssignmentId,
    required String title,
    required String description,
    required DateTime lessonDate,
  }) async {
    /*
    تعديل درس موجود.

    الرابط:
    PUT api/Teacher/update-lesson/{id}
  */

    final response = await _apiClient.put(
      ApiConstants.teacherUpdateLesson(lessonId),
      withAuth: true,
      body: {
        'teacherAssignmentId': teacherAssignmentId,
        'title': title,
        'description': description,
        'lessonDate': lessonDate.toIso8601String(),
      },
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تعديل الدرس';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }

  // 6 -----------------------------------------------------------------------
  //   حذف درس موجود.

  Future<void> deleteLesson({required int lessonId}) async {
    /*
    حذف درس موجود.

    الرابط:
    DELETE api/Teacher/delete-lesson/{id}
  */

    final response = await _apiClient.delete(
      ApiConstants.teacherDeleteLesson(lessonId),
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر حذف الدرس';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }

  // 7 ---------------------------------------------------------------------
  //  خصائص اضافة وتعديل وحذف واجب

  Future<List<TeacherHomeworkModel>> getMyHomeworks() async {
    /*
    جلب واجبات الأستاذ الحالي من API.

    الرابط:
    GET api/Teacher/my-homeworks
  */

    final response = await _apiClient.get(
      ApiConstants.teacherHomeworks,
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تحميل واجبات الأستاذ';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    final homeworks =
        data
            .map(
              (item) =>
                  TeacherHomeworkModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    /*
    الترتيب المطلوب:
    أول واجب أضيف يظهر في البداية
    وآخر واجب أضيف يظهر في الأخير.
  */
    homeworks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return homeworks;
  }

  Future<void> createHomework({
    required int teacherAssignmentId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    /*
    إضافة واجب جديد.

    الرابط:
    POST api/Teacher/create-homework
  */

    final response = await _apiClient.post(
      ApiConstants.teacherCreateHomework,
      withAuth: true,
      body: {
        'teacherAssignmentId': teacherAssignmentId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
      },
    );

    if (response.statusCode != 200) {
      String message = 'تعذر إضافة الواجب';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }

  Future<void> updateHomework({
    required int homeworkId,
    required int teacherAssignmentId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    /*
    تعديل واجب موجود.

    الرابط:
    PUT api/Teacher/update-homework/{id}
  */

    final response = await _apiClient.put(
      ApiConstants.teacherUpdateHomework(homeworkId),
      withAuth: true,
      body: {
        'teacherAssignmentId': teacherAssignmentId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
      },
    );

    if (response.statusCode != 200) {
      String message = 'تعذر تعديل الواجب';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }

  Future<void> deleteHomework({required int homeworkId}) async {
    /*
    حذف واجب موجود.

    الرابط:
    DELETE api/Teacher/delete-homework/{id}
  */

    final response = await _apiClient.delete(
      ApiConstants.teacherDeleteHomework(homeworkId),
      withAuth: true,
    );

    if (response.statusCode != 200) {
      String message = 'تعذر حذف الواجب';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }
  }
}
