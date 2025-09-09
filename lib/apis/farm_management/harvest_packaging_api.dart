import '../../config/config.dart';

class HarvestPackagingApiRoutes {
  static final String getInforHarvestPackagingApi = '${Config.domain}/vungtrong/xemlohang';
  static final String createHarvestPackagingApi = '${Config.domain}/vungtrong/themlohang';
  static final String updateHarvestPackagingApi = '${Config.domain}/vungtrong/capnhatlohang';
  static final String getAllHarvestPackagingApi = '${Config.domain}/vungtrong/lohang/danhsach';
  static final String getAllNotPackagingHarvestPackagingApi = '${Config.domain}/vungtrong/lohangchuacotrongconghang';

  // static final String deleteHarvestPackagingApi = '${Config.domain}/vungtrong/lichsuchamsoc-api';
  // static final String getAllHarvestPackagingByFarmIdApi =  '${Config.domain}/vungtrong/lichsuchamsoc-api';

  static final String listNhaCungCapApi = '${Config.domain}/nhacungcap/list';
}
