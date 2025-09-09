import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  }

  // Yêu cầu quyền nếu chưa có
  final result = await Permission.camera.request();
  return result.isGranted;
}
