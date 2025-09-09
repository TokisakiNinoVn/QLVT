import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/farm_management/care_process_api.dart';
import '../../apis/production_facility/production_process_api.dart';

class ProductionProcessService {
  Future<Map<String, dynamic>> getDetailsProductionProcessService() async {
    return await ApiMethodsPrivate.getRequest(
      ProductionProcessApiRoutes.getDetailsProductionProcessApiRoutes,
    );
  }

  Future<Map<String, dynamic>> getAllProductionProcessService() async {
    return await ApiMethodsPrivate.getRequest(
      ProductionProcessApiRoutes.getAllProductionProcessApiRoutes,
    );
  }

  // create
  Future<Map<String, dynamic>> createProductionProcessService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      ProductionProcessApiRoutes.createProductionProcessApiRoutes,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateProductionProcessService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${ProductionProcessApiRoutes.updateProductionProcessApiRoutes}/$id',
      data,
    );
  }

  // delete
  Future<Map<String, dynamic>> deleteProductionProcessService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${ProductionProcessApiRoutes.deleteProductionProcessApiRoutes}/$id',
      data,
    );
  }
}
