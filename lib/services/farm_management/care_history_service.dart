import 'package:txng/apis/helper/api_methods_private.dart';
import '../../apis/farm_management/care_history_api.dart';

class CareHistoryService {
  Future<Map<String, dynamic>> getDetailsCareHistoryService() async {
    return await ApiMethodsPrivate.getRequest(
      CareHistoryApiRoutes.getInforCareHistoryApi,
    );
  }

  // Load danh sách nhà cung cấp
  Future<Map<String, dynamic>> getListSupplierService() async {
    return await ApiMethodsPrivate.getRequest(
      CareHistoryApiRoutes.listNhaCungCapApi,
    );
  }

  Future<Map<String, dynamic>> getAllCareHistoryService() async {
    return await ApiMethodsPrivate.getRequest(
      CareHistoryApiRoutes.getAllCareHistoryApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createCareHistoryService(
    Map<String, dynamic> data,
  ) async {
    print("data add lscs: $data");
    return await ApiMethodsPrivate.postRequest(
      CareHistoryApiRoutes.createCareHistoryApi,
      data,
    );
  }
  Future<Map<String, dynamic>> checkCodeVungTrongService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      CareHistoryApiRoutes.checkCodeVungTrongApi,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateCareHistoryService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${CareHistoryApiRoutes.updateCareHistoryApi}/$id',
      data,
    );
  }

  // delete
  Future<Map<String, dynamic>> deleteCareHistoryService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${CareHistoryApiRoutes.deleteCareHistoryApi}/$id',
      data,
    );
  }

  // get all care history by farm id
  Future<Map<String, dynamic>> getAllCareHistoryByFarmIdService(int id) async {
    return await ApiMethodsPrivate.getRequest(
      '${CareHistoryApiRoutes.getAllCareHistoryByFarmIdApi}/$id',
    );
  }
}
