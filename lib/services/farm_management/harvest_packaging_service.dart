import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/farm_management/harvest_packaging_api.dart';

class HarvestPackagingService {
  // Future<Map<String, dynamic>> getDetailsHarvestPackagingService() async {
  //   return await ApiMethodsPrivate.getRequest(
  //     HarvestPackagingApiRoutes.getDetailsHarvestPackagingApiRoutes,
  //   );
  // }
  Future<Map<String, dynamic>> getAllHarvestPackagingService() async {
    return await ApiMethodsPrivate.getRequest(
      HarvestPackagingApiRoutes.getAllHarvestPackagingApi,
    );
  }
  Future<Map<String, dynamic>> getAllNotPackagingHarvestPackagingService() async {
    return await ApiMethodsPrivate.getRequest(
      HarvestPackagingApiRoutes.getAllNotPackagingHarvestPackagingApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createHarvestPackagingService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      HarvestPackagingApiRoutes.createHarvestPackagingApi,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateHarvestPackagingService(
    String code,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${HarvestPackagingApiRoutes.updateHarvestPackagingApi}/$code',
      data,
    );
  }

  Future<Map<String, dynamic>> getDetailsHarvestPackagingService(
    String code,
  ) async {
    return await ApiMethodsPrivate.getRequest(
      '${HarvestPackagingApiRoutes.getInforHarvestPackagingApi}/$code',
    );
  }
  Future<Map<String, dynamic>> getDetailsHarvestPackagingByIdService(
    int id,
  ) async {
    return await ApiMethodsPrivate.getRequest(
      '${HarvestPackagingApiRoutes.getInforHarvestPackagingApi}/$id',
    );
  }
}
