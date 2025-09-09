import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    await authState.loadToken();

    final isValid = await authState.checkTokenValidity();

    if (!mounted) return;

    if (authState.isLoggedIn && isValid) {
      context.go('/home');
    } else {
      context.go('/option-login');
      if (authState.isHaveToken) {
        SnackbarHelper.showSuccess(context, "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.!");
      }
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
