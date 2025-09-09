import 'package:txng/apis/helper/api_methods_private.dart';
import '../../apis/production_facility/processing_history_api.dart';

class ProcessingHistoryService {
  // Future<Map<String, dynamic>> getDetailsProcessingHistoryService() async {
  //   return await ApiMethodsPrivate.getRequest(
  //     ProcessingHistoryApi.getInforProcessingHistoryApi,
  //   );
  // }

  Future<Map<String, dynamic>> getAllProcessingHistoryService() async {
    return await ApiMethodsPrivate.getRequest(
      ProcessingHistoryApi.getAllProcessingHistoryApi,
    );
  }

  // create
  Future<Map<String, dynamic>> createProcessingHistoryService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      ProcessingHistoryApi.createProcessingHistoryApi,
      data,
    );
  }
  Future<Map<String, dynamic>> hoanThanhLoHangProcessingHistoryService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      ProcessingHistoryApi.hoanThanhLoHangProcessingHistoryApi,
      data,
    );
  }
  Future<Map<String, dynamic>> chonSanPhamDauRaProcessingHistoryService(
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      ProcessingHistoryApi.chonSanPhamDauRaProcessingHistoryApi,
      data,
    );
  }

  // update
  Future<Map<String, dynamic>> updateProcessingHistoryService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${ProcessingHistoryApi.updateProcessingHistoryApi}/$id',
      data,
    );
  }

  // delete
  Future<Map<String, dynamic>> deleteProcessingHistoryService(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await ApiMethodsPrivate.postRequest(
      '${ProcessingHistoryApi.deleteProcessingHistoryApi}/$id',
      data,
    );
  }

  // get list processing history by paking code
  Future<Map<String, dynamic>> getListProcessingHistoryByCodeService(String code) async {
    return await ApiMethodsPrivate.getRequest(
      '${ProcessingHistoryApi.getListProcessingHistoryApi}/$code',
    );
  }
  Future<Map<String, dynamic>> getListProductService() async {
    return await ApiMethodsPrivate.getRequest(
      ProcessingHistoryApi.getListProductApi,
    );
  }
}
