import 'package:txng/apis/helper/api_methods_public.dart';
import 'package:txng/apis/helper/api_methods_private.dart';
import '../apis/auth_api.dart';

class AuthService {
  Future<Map<String, dynamic>> loginVungTrongService(data) async {
    return await ApiMethodsPublic.postRequest(AuthApiRoutes.loginVungTrong, body: data);
  }

  Future<Map<String, dynamic>> registerService(data) async {
    return await ApiMethodsPublic.postRequest(AuthApiRoutes.register, body: data);
  }

  Future<Map<String, dynamic>> loginCSSXService(data) async {
    return await ApiMethodsPublic.postRequest(AuthApiRoutes.loginCSSX, body: data);
  }

  Future<Map<String, dynamic>> checkTokenTrangTraiService() async {
    final response = await ApiMethodsPrivate.getRequest(AuthApiRoutes.checkTokenTrangTrai);
    return response;
  }
  Future<Map<String, dynamic>> checkTokenCSSXService() async {
    return await ApiMethodsPrivate.getRequest(AuthApiRoutes.checkTokenCSSX);
  }
}
