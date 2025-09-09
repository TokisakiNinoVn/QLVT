import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txng/services/auth_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isHaveToken = false;

  String? loginOptionType;

  bool get isLoggedIn => _isLoggedIn;
  bool get isHaveToken => _isHaveToken;

  final AuthService authService = AuthService();

  /// Load token từ local storage để xác định trạng thái login
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isLogin = prefs.getString('isLogin');
    loginOptionType = prefs.getString('loginOption_type');

    if (token == null) {
      // Nếu không có token thì chuyển sang màn hình đăng nhập ngay
      Future.microtask(() {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          Navigator.of(context).pushReplacementNamed('/option-login');
        }
      });
      _isLoggedIn = false;
      _isHaveToken = false;
      notifyListeners();
      return;
    }

    _isHaveToken = true;
    _isLoggedIn = token != null && isLogin == 'true';
    notifyListeners();
  }

  /// Kiểm tra token hợp lệ qua API (gọi từ SplashScreen)
  Future<bool> checkTokenValidity() async {
    final prefs = await SharedPreferences.getInstance();

    if (loginOptionType == 'vung_trong') {
      final response = await authService.checkTokenTrangTraiService();
      if (response['success'] == true || response['status'] == 'success' || response['status'] == 'true') {
        return true;
      }
    } else if (loginOptionType == 'cs_san_xuat') {
      final response = await authService.checkTokenCSSXService();
      if (response['success'] == true || response['status'] == 'success' || response['status'] == 'true') {
        return true;
      }
    }

    // Nếu không hợp lệ thì xoá token và logout
    await logout();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isLogin');
    await prefs.remove('loginOption_type');

    _isLoggedIn = false;
    _isHaveToken = false;
    loginOptionType = null;
    notifyListeners();

    // Chuyển về trang đăng nhập
    Future.microtask(() {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushReplacementNamed('/option-login');
      }
    });
  }

  void login() {
    _isLoggedIn = true;
    _isHaveToken = true;
    notifyListeners();
  }
}
