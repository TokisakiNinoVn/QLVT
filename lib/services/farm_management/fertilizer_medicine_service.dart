import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/farm_management/account_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apis/farm_management/fertilizer_medicine_api.dart';

class FertilizerMedicineService {
  Future<Map<String, dynamic>> getAllFertilizerMedicineService() async {
    return await ApiMethodsPrivate.getRequest(
      FertilizerMedicineApiRoutes.getAllFertilizerMedicineApiRoutes,
    );
  }

  Future<Map<String, dynamic>> getDetailsFertilizerMedicineService(
    int id,
  ) async {
    return await ApiMethodsPrivate.getRequest(
      '${FertilizerMedicineApiRoutes.getDetailsFertilizerMedicineApiRoutes}/$id',
    );
  }

  Future<Map<String, dynamic>> createFertilizerMedicineService(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse(
      FertilizerMedicineApiRoutes.createFertilizerMedicineApiRoutes,
    );
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('hinhanh', filePath));
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

  Future<Map<String, dynamic>> deleteFertilizerMedicineService(
    int id,
    Map<String, dynamic> data,
  ) async {
    final requestData = {...data, '_method': 'DELETE'};

    return await ApiMethodsPrivate.postRequest(
      '${FertilizerMedicineApiRoutes.deleteFertilizerMedicineApiRoutes}/$id',
      requestData,
    );
  }

  Future<Map<String, dynamic>> updateFertilizerMedicineService(
    int id,
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse(
      "${FertilizerMedicineApiRoutes.updateFertilizerMedicineApiRoutes}/$id",
    );
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
