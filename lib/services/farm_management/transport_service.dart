import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import '../../apis/farm_management/transport_api.dart';

class TransportService {
  Future<Map<String, dynamic>> getAllTransportService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportApiRoutes.getAllTransportApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createTransportService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      TransportApiRoutes.createTransportApi,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateTransportService(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${TransportApiRoutes.updateTransportApi}/$id',
      data,
    );
  }

  Future<Map<String, dynamic>> getListTaiXeTransportService() async {
    return await ApiMethodsPrivate.getRequest(TransportApiRoutes.listTaiXeApi);
  }

  Future<Map<String, dynamic>> getListDiemNhanService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportApiRoutes.listDiemNhanApi,
    );
  }
  Future<Map<String, dynamic>> getListXeService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportApiRoutes.listXeApi,
    );
  }
}
