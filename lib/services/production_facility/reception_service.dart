import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/production_facility/reception_api.dart';

class ReceptionService {
  Future<Map<String, dynamic>> getAllReceptionService() async {
    return await ApiMethodsPrivate.getRequest(
      ReceptionApiRoutes.getAllReceptionApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createReceptionService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      ReceptionApiRoutes.createReceptionApi,
      data,
    );
  }
  //
  // // update
  // Future<Map<String, dynamic>> updateReceptionService(
  //   String id,
  //   Map<String, dynamic> data,
  // ) async {
  //   return await ApiMethodsPrivate.postRequest(
  //     '${ReceptionApiRoutes.updateReceptionApi}/$id',
  //     data,
  //   );
  // }
  //
  Future<Map<String, dynamic>> getDetailsReceptionService(String code) async {
    return await ApiMethodsPrivate.getRequest('${ReceptionApiRoutes.getDetailsReceptionApi}/$code');
  }
  //
  // Future<Map<String, dynamic>> getListDiemNhanService() async {
  //   return await ApiMethodsPrivate.getRequest(
  //     ReceptionApiRoutes.listDiemNhanApi,
  //   );
  // }
}
