import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import '../../apis/farm_management/container_api.dart';

class ContainerService {
  Future<Map<String, dynamic>> getAllContainerService() async {
    return await ApiMethodsPrivate.getRequest(
      ContainerApiRoutes.getAllContainerApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createContainerService(
    Map<String, dynamic> data,
  ) async {
    print("data lo hang: $data");
    return await ApiMethodsPrivate.postRequest(
      ContainerApiRoutes.createContainerApi,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateContainerService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${ContainerApiRoutes.updateContainerApi}/$id',
      data,
    );
  }

  Future<Map<String, dynamic>> getListLoHangService() async {
    return await ApiMethodsPrivate.getRequest(
      ContainerApiRoutes.listLoHang,
    );
  }
}
