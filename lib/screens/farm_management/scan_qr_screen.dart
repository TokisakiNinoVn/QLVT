import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:txng/utils/permission_utils.dart';
import 'package:txng/services/farm_management/care_history_service.dart';

class ScanQRVTScreen extends StatefulWidget {
  const ScanQRVTScreen({super.key});

  @override
  State<ScanQRVTScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRVTScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final CareHistoryService careHistoryService = CareHistoryService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCameraPermission();
    });
  }

  Future<void> _handleCameraPermission() async {
    try {
      final granted = await checkCameraPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần cấp quyền camera để sử dụng chức năng này'),
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          context.go('/');
        }
      } else if (mounted) {
        await _controller.start();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi khởi tạo camera: $e')));
      }
    }
  }

  // Trích xuất code từ URL QR
  String _extractCodeFromUrl(String url) {
    try {
      final parts = url.split('/');
      return parts.isNotEmpty ? parts.last.trim() : '';
    } catch (e) {
      return '';
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final barcode = capture.barcodes.firstOrNull;
      final value = barcode?.rawValue;

      if (value != null && mounted) {
        await _controller.stop();
        final code = _extractCodeFromUrl(value);
        if (code.isNotEmpty && mounted) {
          // check code vung trong
          final result = await careHistoryService.checkCodeVungTrongService({
            'mavungtrong': value,
          });

          if (result['success'] == false || result['status'] == false || result['data'] == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${result['message']}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating, // tuỳ chọn: để tách khỏi mép dưới
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // tuỳ chọn
                duration: const Duration(seconds: 3), // tuỳ chỉnh thời gian hiển thị
              ),
            );
            await _controller.start();
            return;
          } else {
            context.push('/create/care-history/$code');
          }
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Mã QR không hợp lệ')));
          await _controller.start();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xử lý mã QR: $e')));
        await _controller.start();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Quét mã QR thêm lịch sử chăm sóc')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Text(
                  'Lỗi camera: ${error.toString()}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  const Text(
                    'Đưa mã QR vùng trồng vào vùng quét',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.qr_code_scanner,
                  size: 50,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
