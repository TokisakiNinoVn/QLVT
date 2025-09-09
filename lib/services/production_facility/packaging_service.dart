import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:txng/apis/helper/api_methods_private.dart';
import '../../apis/production_facility/packaging_api.dart';

class PackagingService {
  Future<Map<String, dynamic>> getAllPackagingService() async {
    return await ApiMethodsPrivate.getRequest(
      PackagingApiRoutes.listDongGoiPackagingApi,
    );
  }

  Future<Map<String, dynamic>> getAllContainerService() async {
    return await ApiMethodsPrivate.getRequest(
      PackagingApiRoutes.listLoHangPackagingApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createPackagingService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      PackagingApiRoutes.createPackagingApi,
      data,
    );
  }
}
