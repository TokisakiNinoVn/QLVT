import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/permission_utils.dart';
import 'package:txng/services/ticket_service.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final ticketService = TicketService();
  String? qrText;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCameraPermission();
    });
  }

  Future<void> _handleCameraPermission() async {
    final granted = await checkCameraPermission();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần cấp quyền camera để sử dụng chức năng này'),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/');
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_showResult) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value != null) {
      setState(() {
        qrText = value;
        _showResult = true;
      });
      _controller.stop();
      _showBottomSheet();
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_handle, size: 30, color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'Xác nhận vé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                qrText ?? '',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.start();
                      setState(() {
                        _showResult = false;
                      });
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Quét lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (qrText != null) {
                        print('QR Text: $qrText');
                        final response = await ticketService
                            .sendTicketConfirmation(qrText!);
                        print('Response: $response');

                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vé đã được xác nhận!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: ${response['message']}'),
                            ),
                          );
                        }

                        // Đóng Bottom Sheet và quay lại trang chủ
                        Navigator.pop(context);
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Xác nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Quét mã QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            // allowDuplicates: false,
            onDetect: _onDetect,
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
              children: const [
                Text(
                  'Đưa mã QR vào vùng quét',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Icon(Icons.qr_code_scanner, size: 50, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
