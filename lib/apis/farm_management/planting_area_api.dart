// manager_routes.dart
import '../../config/config.dart';

class PlantingAreaApiRoutes {
  static final String getInforByQRPlantingAreaApi = '${Config.domain}/vungtrong/xemvungquaQR';
  static final String updateInforPlantingAreaApi = '${Config.domain}/vungtrong/capnhattt';
  static final String deletePlantingAreaApi = '${Config.domain}/vungtrong/xoavungtrong';
  static final String getInforPlantingAreaApi = '${Config.domain}/vungtrong';
  static final String createPlantingAreaApi = '${Config.domain}/vungtrong/themvung';
  static final String getListPlantingAreaApi = '${Config.domain}/vungtrong/dsvungtrong';

}
