import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/production_facility/transport_api.dart';

class TransportService {
  Future<Map<String, dynamic>> getAllTransportService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportCSSXApiRoutes.getAllTransportCSSXApi,
    );
  }
  Future<Map<String, dynamic>> getAllSpTransportService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportCSSXApiRoutes.getListSpTrongKhoCSSXApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createTransportService(
      Map<String, dynamic> data,
      ) async {
    return await ApiMethodsPrivate.postRequest(
      TransportCSSXApiRoutes.createTransportCSSXApi,
      data,
    );
  }

  // update
  // Future<Map<String, dynamic>> updateTransportService(
  //   String id,
  //   Map<String, dynamic> data,
  // ) async {
  //   return await ApiMethodsPrivate.postRequest(
  //     '${TransportCSSXApiRoutes.updateTransportApi}/$id',
  //     data,
  //   );
  // }

  Future<Map<String, dynamic>> getListTaiXeTransportService() async {
    return await ApiMethodsPrivate.getRequest(TransportCSSXApiRoutes.listTaiXeApi);
  }

  Future<Map<String, dynamic>> getListDiemNhanService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportCSSXApiRoutes.listDaily,
    );
  }
  Future<Map<String, dynamic>> getListXeService() async {
    return await ApiMethodsPrivate.getRequest(
      TransportCSSXApiRoutes.listXeApi,
    );
  }
}
