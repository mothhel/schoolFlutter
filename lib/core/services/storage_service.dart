import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  /*
    هذا الكلاس مسؤول عن حفظ وقراءة بيانات تسجيل الدخول.

    نستخدم SharedPreferences لأنها مناسبة لحفظ بيانات بسيطة مثل:
    - Token
    - RoleName
    - StudentId
  */

  static const String _tokenKey = 'token';
  static const String _fullNameKey = 'fullName';
  static const String _usernameKey = 'username';
  static const String _roleNameKey = 'roleName';
  static const String _userIdKey = 'userId';
  static const String _studentIdKey = 'studentId';
  static const String _teacherIdKey = 'teacherId';
  static const String _isSystemAdminKey = 'isSystemAdmin';

  /*
    حفظ بيانات تسجيل الدخول بعد نجاح Login
  */
  Future<void> saveLoginData({
    required String token,
    required String fullName,
    required String username,
    required String roleName,
    required int userId,
    int? studentId,
    int? teacherId,
    required bool isSystemAdmin,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_fullNameKey, fullName);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleNameKey, roleName);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setBool(_isSystemAdminKey, isSystemAdmin);

    /*
      نحفظ StudentId فقط إذا كان المستخدم طالبًا
    */
    if (studentId != null) {
      await prefs.setInt(_studentIdKey, studentId);
    } else {
      await prefs.remove(_studentIdKey);
    }

    /*
      نحفظ TeacherId فقط إذا كان المستخدم مدرسًا
    */
    if (teacherId != null) {
      await prefs.setInt(_teacherIdKey, teacherId);
    } else {
      await prefs.remove(_teacherIdKey);
    }
  }

  /*
    قراءة التوكن
  */
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /*
    قراءة الاسم الكامل
  */
  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullNameKey);
  }

  /*
    قراءة اسم المستخدم
  */
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /*
    قراءة الدور
    Student / Teacher / Admin
  */
  Future<String?> getRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleNameKey);
  }

  /*
    قراءة رقم المستخدم
  */
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /*
    قراءة رقم الطالب
  */
  Future<int?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_studentIdKey);
  }

  /*
    قراءة رقم المدرس
  */
  Future<int?> getTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_teacherIdKey);
  }

  /*
    هل المستخدم مدير النظام الرئيسي؟
  */
  Future<bool> getIsSystemAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSystemAdminKey) ?? false;
  }

  /*
    هل المستخدم مسجل دخول؟
    إذا كان عنده Token يعني دخل سابقًا.
  */
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /*
    حذف بيانات تسجيل الدخول عند Logout
  */
  Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
