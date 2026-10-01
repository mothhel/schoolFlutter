class StudentLessonModel {
  /*
    هذا الموديل يمثل درس واحد من الدروس القادمة من API.

    الهدف:
    - قراءة بيانات الدرس
    - قراءة وقت الإضافة إذا كان موجودًا
    - قراءة وقت آخر تعديل إذا كان موجودًا
    - ترتيب الدروس لاحقًا حسب وقت الإضافة
    - إظهار وقت التعديل للطالب إذا قام الأستاذ بتعديل الدرس

    ملاحظة:
    بعض الـ APIs ترجع وقت الإضافة باسم:
    createdAt
    أو createdDate
    أو createdOn

    وبعضها يرجع وقت التعديل باسم:
    updatedAt
    أو updatedDate
    أو updatedOn

    لذلك وضعنا أكثر من احتمال حتى لا يحدث خطأ.
  */

  final int id;
  final String title;
  final String description;

  /*
    تاريخ الدرس نفسه.
  */
  final DateTime lessonDate;

  /*
    وقت إضافة الدرس.
  */
  final DateTime createdAt;

  /*
    اسم يوم الإضافة ووقت الإضافة إذا رجعوا من API.
  */
  final String createdDayName;
  final String createdTime;

  /*
    وقت آخر تعديل على الدرس.
    يكون null إذا لم يتم تعديل الدرس.
  */
  final DateTime? updatedAt;
  final String updatedDayName;
  final String updatedTime;

  final String subjectName;
  final String teacherName;
  final String classRoomName;
  final String sectionName;

  StudentLessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonDate,
    required this.createdAt,
    required this.createdDayName,
    required this.createdTime,
    this.updatedAt,
    required this.updatedDayName,
    required this.updatedTime,
    required this.subjectName,
    required this.teacherName,
    required this.classRoomName,
    required this.sectionName,
  });

  factory StudentLessonModel.fromJson(Map<String, dynamic> json) {
    final parsedLessonDate =
        DateTime.tryParse(json['lessonDate']?.toString() ?? '') ??
        DateTime.now();

    final parsedCreatedAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.tryParse(json['createdDate']?.toString() ?? '') ??
        DateTime.tryParse(json['createdOn']?.toString() ?? '') ??
        parsedLessonDate;

    final parsedUpdatedAt =
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.tryParse(json['updatedDate']?.toString() ?? '') ??
        DateTime.tryParse(json['updatedOn']?.toString() ?? '');

    return StudentLessonModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      lessonDate: parsedLessonDate,
      createdAt: parsedCreatedAt,

      /*
        هذه القيم إذا لم ترجع من API نخليها فارغة،
        وبعدها في الشاشة يمكننا توليد اليوم والوقت من createdAt.
      */
      createdDayName: json['createdDayName'] ?? '',
      createdTime: json['createdTime'] ?? '',

      /*
        إذا لم يتم تعديل الدرس، تبقى updatedAt = null.
      */
      updatedAt: parsedUpdatedAt,
      updatedDayName: json['updatedDayName'] ?? '',
      updatedTime: json['updatedTime'] ?? '',

      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      classRoomName: json['classRoomName'] ?? '',
      sectionName: json['sectionName'] ?? '',
    );
  }
}
