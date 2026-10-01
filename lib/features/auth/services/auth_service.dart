import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/login_response_model.dart';

class AuthService {
  /*
    هذا الكلاس مسؤول عن:
    - تسجيل الدخول
    - قراءة نتيجة API
    - حفظ بيانات الدخول في الجهاز
    - تسجيل الخروج
  */

  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    /*
      نرسل طلب Login إلى API.

      ملاحظة:
      withAuth = false
      لأن تسجيل الدخول لا يحتاج Token.
    */
    final response = await _apiClient.post(
      ApiConstants.login,
      withAuth: false,
      body: {'username': username, 'password': password},
    );

    /*
      إذا لم يرجع API status code 200
      نعرض رسالة الخطأ.
    */
    if (response.statusCode != 200) {
      String message = 'اسم المستخدم أو كلمة المرور غير صحيحة';

      if (response.body.isNotEmpty) {
        message = response.body.replaceAll('"', '');
      }

      throw Exception(message);
    }

    /*
      تحويل JSON القادم من API إلى Map.
    */
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    /*
      تحويل البيانات إلى LoginResponseModel.
    */
    final loginResult = LoginResponseModel.fromJson(data);

    if (loginResult.token.isEmpty) {
      throw Exception('لم يتم استلام التوكن من الخادم');
    }

    /*
      حفظ بيانات الدخول في الجهاز.
    */
    await _storageService.saveLoginData(
      token: loginResult.token,
      fullName: loginResult.fullName,
      username: loginResult.username,
      roleName: loginResult.roleName,
      userId: loginResult.userId,
      studentId: loginResult.studentId,
      teacherId: loginResult.teacherId,
      isSystemAdmin: loginResult.isSystemAdmin,
    );

    return loginResult;
  }

  Future<void> logout() async {
    await _storageService.clearLoginData();
  }
}
