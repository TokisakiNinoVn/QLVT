import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/farm_management/planting_area_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantingAreaService {
  // Lấy danh sách vùng trồng
  Future<Map<String, dynamic>> getListPlantingAreaService() async {
    return await ApiMethodsPrivate.getRequest(
      PlantingAreaApiRoutes.getListPlantingAreaApi,
    );
  }

  Future<Map<String, dynamic>> getDetailsPlantingAreaService() async {
    return await ApiMethodsPrivate.getRequest(
      PlantingAreaApiRoutes.getInforPlantingAreaApi,
    );
  }

  // Lấy thông tin vùng trồng theo mã
  Future<Map<String, dynamic>> getPlantingAreaByCodeService(String code) async {
    return await ApiMethodsPrivate.getRequest(
      '${PlantingAreaApiRoutes.getInforByQRPlantingAreaApi}/$code',
    );
  }

  // Xóa vùng trồng
  Future<Map<String, dynamic>> deletePlantingAreaService(int id) async {
    return await ApiMethodsPrivate.deleteRequest(
      '${PlantingAreaApiRoutes.deletePlantingAreaApi}/$id',
    );
  }

  Future<Map<String, dynamic>> updatePlantingAreaService(
    int id,
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse('${PlantingAreaApiRoutes.updateInforPlantingAreaApi}/$id');
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

  // Tao vùng trồng mới
  Future<Map<String, dynamic>> createPlantingAreaService(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse(PlantingAreaApiRoutes.createPlantingAreaApi);
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
        'Lỗi tạo vùng trồng: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
