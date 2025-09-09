import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txng/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  final String roleType;
  const LoginScreen({super.key, required this.roleType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;
  bool showPassword = false;
  bool rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadLoginData();
  }

  Future<void> _loadLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;

    if (!remember) return;

    String? loginData;
    if (widget.roleType == 'vung_trong') {
      loginData = prefs.getString('loginVungtrong');
    } else {
      loginData = prefs.getString('loginCSSX');
    }

    if (loginData != null) {
      try {
        final parsed = jsonDecode(loginData);
        phoneController.text = parsed['phone'] ?? '';
        passwordController.text = parsed['password'] ?? '';
        setState(() => rememberMe = true);
      } catch (e) {
        // Trường hợp dữ liệu bị lỗi
        debugPrint('Lỗi khi parse loginData: $e');
      }
    }
  }

  Future<void> handleLogin() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() => isLoading = true);

    try {
      var response;
      if (widget.roleType == 'vung_trong') {
        response = await authService.loginVungTrongService({
          "sodienthoai": phone,
          "password": password,
        });
      } else {
        response = await authService.loginCSSXService({
          "sodienthoai": phone,
          "password": password,
        });
      }

      // print('Response: $response');

      final prefs = await SharedPreferences.getInstance();

      if (response['token'] != null) {
        await prefs.setString('token', response['token']);
        await prefs.setString('inforUserLogin', jsonEncode(response['user']));
        await prefs.setString('loginOption_type', widget.roleType);
        await prefs.setString('quyenhan', response['user']?['quyenhan'] ?? '');
        await prefs.setString('isLogin', 'true');

        if (rememberMe) {
          final loginInfo = jsonEncode({'phone': phone, 'password': password});
          if (widget.roleType == 'vung_trong') {
            await prefs.setString('loginVungtrong', loginInfo);
          } else {
            await prefs.setString('loginCSSX', loginInfo);
          }
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('loginVungtrong');
          await prefs.remove('loginCSSX');
          await prefs.setBool('rememberMe', false);
        }

        authState.login();
        context.go('/');
      } else {
        _showSnack(response['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      _showSnack('Lỗi hệ thống: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String getRoleDisplayName(String roleType) {
    switch (roleType) {
      case 'vung_trong':
        return 'Quản lý trang trại';
      case 'cs_san_xuat':
        return 'Cơ sở sản xuất';
      default:
        return 'Người dùng';
    }
  }

  void _showSnack(String message) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputAction inputAction = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: inputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffix,
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent footer from moving with keyboard
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7EF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/assets/images/logo-login.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đăng nhập với vai trò:\n${getRoleDisplayName(widget.roleType)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: phoneController,
                        label: 'Số điện thoại',
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: passwordController,
                        label: 'Mật khẩu',
                        icon: Icons.lock,
                        obscure: !showPassword,
                        suffix: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[600],
                          ),
                          onPressed:
                              () =>
                                  setState(() => showPassword = !showPassword),
                        ),
                        inputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged:
                                (val) =>
                                    setState(() => rememberMe = val ?? true),
                            checkColor: Colors.white,
                            activeColor: Colors.blueGrey,
                          ),
                          const Text(
                            'Ghi nhớ đăng nhập',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueGrey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Chức năng này chưa được triển khai',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.grey,
                            ),
                          );
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Đổi vai trò đăng nhập',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                color: Colors.grey[100],
                child: Column(
                  children: const [
                    Text(
                      'Phiên bản: 2.4.1.23',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Liên hệ: support@meii.vn',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
