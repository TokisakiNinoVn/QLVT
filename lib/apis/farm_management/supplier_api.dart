// manager_routes.dart
import '../../config/config.dart';

class SupplierApiRoutes {
  static final String getAllSupplier = '${Config.domain}/nhacungcap/list';
  static final String createSupplier = '${Config.domain}/nhacungcap/themnhacungcap';
  static final String updateSupplier = '${Config.domain}/nhacungcap/capnhat';
  static final String deleteSupplier = '${Config.domain}/nhacungcap/delete';
}
