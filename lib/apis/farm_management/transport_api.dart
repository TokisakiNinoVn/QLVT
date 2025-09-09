import '../../config/config.dart';

class TransportApiRoutes {
  static final String getAllTransportApi = '${Config.domain}/vungtrong/donvan/danhsach';
  static final String createTransportApi = '${Config.domain}/vungtrong/taodonvan';
  static final String updateTransportApi = '${Config.domain}/vungtrong/capnhatdonvan';
  static final String getInforTransportApi = '${Config.domain}/vungtrong/xemdonvan';

  static final String listDiemNhanApi = '${Config.domain}/vungtrong/ttdiemnhan';
  static final String listTaiXeApi = '${Config.domain}/vungtrong/taixe-api';
  static final String listXeApi = '${Config.domain}/vungtrong/xe-api';
}
