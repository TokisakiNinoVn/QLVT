// auth_routes.dart
import '../config/config.dart';

class AuthApiRoutes {
  static final String loginVungTrong = '${Config.domain}/vungtrong/loginvungtrong';
  static final String loginCSSX = '${Config.domain}/cososanxuat/logincososanxuat';
  static final String register = '${Config.domain}/dang-ky';

  static final String checkTokenTrangTrai = '${Config.domain}/vungtrong/vungtrongrefresh';
  static final String checkTokenCSSX = '${Config.domain}/cososanxuat/cososanxuatrefresh';

}
