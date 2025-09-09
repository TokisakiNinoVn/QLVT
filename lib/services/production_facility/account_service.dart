import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/production_facility/account_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  Future<Map<String, dynamic>> getAllAccounService() async {
    return await ApiMethodsPrivate.getRequest(AccountApiRoutes.getAllAccount);
  }

  Future<Map<String, dynamic>> getDetailsAccountService(int id) async {
    return await ApiMethodsPrivate.getRequest(
      '${AccountApiRoutes.getDetailsAccount}/$id',
    );
  }

  Future<Map<String, dynamic>> createAccountService(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse(AccountApiRoutes.createAccount);
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Lỗi tạo tài khoản: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> deleteAccountService(
    int id,
    Map<String, dynamic> data,
  ) async {
    final requestData = {...data, '_method': 'DELETE'};

    return await ApiMethodsPrivate.postRequest(
      '${AccountApiRoutes.deleteAccount}/$id',
      requestData,
    );
  }

  Future<Map<String, dynamic>> updateAccountService(
    int id,
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse("${AccountApiRoutes.createAccount}/$id");
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }

    request.fields['_method'] = 'PUT';

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
    }

    // ✅ Gửi request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // ✅ Xử lý response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Lỗi cập nhật tài khoản: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
