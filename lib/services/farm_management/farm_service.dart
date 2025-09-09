import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/farm_management/farm_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmService {
  Future<Map<String, dynamic>> getDetailsFarmService() async {
    return await ApiMethodsPrivate.getRequest(FarmApiRoutes.getInforFarmApi);
  }

  // Lấy thông tin vùng trồng theo mã
  // Future<Map<String, dynamic>> getFarmByCodeService(String code) async {
  //   return await ApiMethodsPrivate.getRequest(
  //     '${FarmApiRoutes.getInforByQRFarmApi}/$code',
  //   );
  // }

  Future<Map<String, dynamic>> updateFarmService(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse(FarmApiRoutes.updateInforFarmApi);
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (filePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('chungchi', filePath),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Lỗi cập nhật tài khoản: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
