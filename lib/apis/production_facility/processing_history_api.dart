// manager_routes.dart
import '../../config/config.dart';

class ProcessingHistoryApi {
  static final String getAllProcessingHistoryApi = '${Config.domain}/cososanxuat/dslohangtaicssx';
  static final String getDetailsProcessingHistoryApi = '${Config.domain}/cososanxuat/lichsuchebien-api';
  static final String createProcessingHistoryApi = '${Config.domain}/cososanxuat/lichsuchebien-api';
  static final String updateProcessingHistoryApi = '${Config.domain}/cososanxuat/lichsuchebien-api';
  static final String deleteProcessingHistoryApi = '${Config.domain}/cososanxuat/lichsuchebien-api';


  static final String hoanThanhLoHangProcessingHistoryApi = '${Config.domain}/cososanxuat/hoanthanhlohang';
  static final String chonSanPhamDauRaProcessingHistoryApi = '${Config.domain}/cososanxuat/hoanthanhlohang';
  static final String getListProcessingHistoryApi = '${Config.domain}/cososanxuat/lschebientheollohang';
  static final String getListProductApi = '${Config.domain}/cososanxuat/sanpham';
}
