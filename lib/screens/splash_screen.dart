import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/snackbar_helper.dart';
import '../routes/app_router.dart';
import '../states/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestPermissions();

    await authState.loadToken();

    final isValid = await authState.checkTokenValidity();

    if (!mounted) return;

    if (authState.isLoggedIn && isValid) {
      context.go('/home');
    } else {
      context.go('/option-login');
      if (authState.isHaveToken) {
        SnackbarHelper.showSuccess(
          context,
          "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.!",
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      SnackbarHelper.showError(context, "Ứng dụng cần quyền máy ảnh để hoạt động!");
    }

    final photosStatus = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (photosStatus.isDenied || storageStatus.isDenied) {
      SnackbarHelper.showError(context, "Ứng dụng cần quyền truy cập thư viện để hoạt động!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/loading.gif',
              width: 120,
              height: 120,
            ),
            const SizedBox(width: 20),
            const Text(
              'Truy xuất nguồn gốc',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
