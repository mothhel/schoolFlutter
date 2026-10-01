import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiClient {
  /*
    هذا الكلاس مسؤول عن التعامل مع API بشكل موحد.

    بدلاً من تكرار الهيدرز في كل صفحة،
    نضعها هنا مرة واحدة.
  */

  final StorageService _storageService = StorageService();

  /*
    تجهيز Headers

    withAuth = true
    يعني نضيف Authorization Bearer Token.

    withAuth = false
    يعني لا نضيف التوكن، مثل طلب Login.
  */
  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _storageService.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /*
    طلب GET
  */
  Future<http.Response> get(String url, {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);

    return http.get(Uri.parse(url), headers: headers);
  }

  /*
    طلب POST
  */
  Future<http.Response> post(
    String url, {
    Object? body,
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);

    return http.post(
      Uri.parse(url),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  /*
    طلب PUT
    سنحتاجه لاحقًا إذا عملنا تعديل بيانات.
  */
  Future<http.Response> put(
    String url, {
    Object? body,
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);

    return http.put(
      Uri.parse(url),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  /*
    طلب DELETE
    سنحتاجه لاحقًا في واجهات المدير.
  */
  Future<http.Response> delete(String url, {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);

    return http.delete(Uri.parse(url), headers: headers);
  }
}
