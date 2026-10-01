class TeacherProfileModel {
  /*
    هذا الموديل يمثل بيانات الأستاذ القادمة من API.

    نستخدمه في لوحة الأستاذ لعرض:
    - الاسم
    - اسم المستخدم
    - رقم الأستاذ
    - الهاتف
    - التخصص إن وجد
  */

  final int id;
  final String teacherNumber;
  final String fullName;
  final String username;
  final String phoneNumber;
  final String specialization;

  TeacherProfileModel({
    required this.id,
    required this.teacherNumber,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    required this.specialization,
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileModel(
      id: json['id'] ?? 0,
      teacherNumber: json['teacherNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      specialization: json['specialization'] ?? '',
    );
  }
}
