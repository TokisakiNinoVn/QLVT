import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/farm_management/care_process_api.dart';

class CareProcessService {
  Future<Map<String, dynamic>> getDetailsCareProcessService() async {
    return await ApiMethodsPrivate.getRequest(
      CareProcessApiRoutes.getDetailsCareProcessApiRoutes,
    );
  }

  Future<Map<String, dynamic>> getAllCareProcessService() async {
    return await ApiMethodsPrivate.getRequest(
      CareProcessApiRoutes.getAllCareProcessApiRoutes,
    );
  }

  // create
  Future<Map<String, dynamic>> createCareProcessService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      CareProcessApiRoutes.createCareProcessApiRoutes,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateCareProcessService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${CareProcessApiRoutes.updateCareProcessApiRoutes}/$id',
      data,
    );
  }

  // delete
  Future<Map<String, dynamic>> deleteCareProcessService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${CareProcessApiRoutes.deleteCareProcessApiRoutes}/$id',
      data,
    );
  }
}
