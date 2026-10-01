class LoginResponseModel {
  /*
    هذا الموديل يستقبل نتيجة تسجيل الدخول من API.

    API يرجع:
    - token
    - userId
    - fullName
    - username
    - roleName
    - studentId إذا كان طالب
    - teacherId إذا كان مدرس
    - isSystemAdmin إذا كان مدير النظام الرئيسي
  */

  final String message;
  final String token;
  final int userId;
  final String fullName;
  final String username;
  final int roleId;
  final String roleName;
  final bool isActive;
  final bool isSystemAdmin;
  final int? studentId;
  final int? teacherId;

  LoginResponseModel({
    required this.message,
    required this.token,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    required this.isSystemAdmin,
    this.studentId,
    this.teacherId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? '',
      isActive: json['isActive'] ?? false,
      isSystemAdmin: json['isSystemAdmin'] ?? false,
      studentId: json['studentId'],
      teacherId: json['teacherId'],
    );
  }
}
