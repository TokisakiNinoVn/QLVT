// file: lib/api_methods_private.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txng/routes/app_router.dart';
import 'package:txng/apis/auth_api.dart';

import '../../helpers/snackbar_helper.dart';
import '../../screens/option_login.dart';

class ApiMethodsPrivate {

  // Hàm lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // static Future<void> _handle401() async {
  //   final context = rootNavigatorKey.currentContext;
  //
  //   // Xóa token khỏi SharedPreferences
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('token');
  //
  //   if (context != null) {
  //     // Hiển thị snackbar
  //     try {
  //       SnackbarHelper.showSuccess(context, "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
  //       Future.microtask(() {
  //         context.go('/option-login');
  //       });
  //       // Hoặc dùng cách khác cũng ổn:
  //       // WidgetsBinding.instance.addPostFrameCallback((_) {
  //       //   context.go('/option-login');
  //       // });
  //     } catch (e) {
  //         print('Lỗi chuyển ma hình: $e');
  //     }
  //
  //   }
  // }
  static Future<void> _handle401() async {
    final context = rootNavigatorKey.currentContext;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isLogin');
    await prefs.remove('loginOption_type');

    if (context != null) {
        SnackbarHelper.showError(context, "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OptionLoginScreen(),
          ),
        );
    }
  }


  // POST
  static Future<Map<String, dynamic>> postRequest(
      String url, Map<String, dynamic> body) async {
    try {
      String? token = await getToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        _handle401();
        return {'status': 'error', 'message': 'Unauthorized'};
      }

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Unknown error.',
        };
      }
    } catch (e) {
      if (kDebugMode) print('API Post Error: $e');
      return {
        'status': 'error',
        'message': 'Cannot connect to the server. Please try again later: $e',
      };
    }
  }

  // GET
  static Future<Map<String, dynamic>> getRequest(String url) async {
    try {
      String? token = await getToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        _handle401();
        return {'status': 'error', 'message': 'Unauthorized'};
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('API GET Error: $e');
      return {'error': e.toString()};
    }
  }

  // PUT
  static Future<Map<String, dynamic>> putRequest(
      String url, Map<String, dynamic> body) async {
    try {
      String? token = await getToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        _handle401();
        return {'status': 'error', 'message': 'Unauthorized'};
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('API PUT Error: $e');
      return {'error': e.toString()};
    }
  }

  // DELETE
  static Future<Map<String, dynamic>> deleteRequest(String url) async {
    try {
      String? token = await getToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        _handle401();
        return {'status': 'error', 'message': 'Unauthorized'};
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('API DELETE Error: $e');
      return {'error': e.toString()};
    }
  }
}
