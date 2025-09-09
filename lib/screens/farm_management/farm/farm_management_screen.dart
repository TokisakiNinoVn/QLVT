// lib/screens/farm_management/farm_management_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:txng/services/farm_management/farm_service.dart';
import 'package:txng/config/color_config.dart';

class FarmManagementScreen extends StatefulWidget {
  const FarmManagementScreen({super.key});

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  static final FarmService _farmService = FarmService();
  Map<String, dynamic> farmInfor = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _loadFarm();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Đã được cấp quyền truy cập vị trí!');
    } else if (status.isDenied) {
      print('Bị từ chối quyền truy cập vị trí.');
    } else if (status.isPermanentlyDenied) {
      print('Quyền truy cập bị từ chối vĩnh viễn!');
      openAppSettings();
    }
  }

  Future<void> _loadFarm() async {
    try {
      final response = await _farmService.getDetailsFarmService();
      final rawData = response["data"]?["trangtrai"];
      if (rawData is Map<String, dynamic>) {
        setState(() {
          farmInfor = rawData;
        });
      } else {
        setState(() {
          farmInfor = {};
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: ColorConfig.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw ?? '';
    }
  }

  void _showCertificateDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: ColorConfig.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                      color: ColorConfig.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'Lỗi tải ảnh',
                    style: TextStyle(color: ColorConfig.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: ColorConfig.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double latitude = double.tryParse(farmInfor["lat"] ?? "") ?? 0.0;
    double longitude = double.tryParse(farmInfor["lng"] ?? "") ?? 0.0;

    return Scaffold(
      backgroundColor: ColorConfig.background,
      appBar: AppBar(
        title: const Text(
          "Thông tin Trang trại",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: _loadFarm,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 26),
            onPressed: () {
              context.go("/farm-management/farm-update");
            },
            tooltip: 'Chỉnh sửa thông tin',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: ColorConfig.primary),
      )
          : farmInfor.isEmpty
          ? Center(
        child: Text(
          "Không có dữ liệu trang trại.",
          style: TextStyle(fontSize: 16, color: ColorConfig.textMuted),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetail("Tên trang trại", farmInfor["tentrangtrai"], Icons.location_city),
                    _buildDetail("Chủ sở hữu", farmInfor["chusohuu"], Icons.person),
                    _buildDetail("Mã số thuế", farmInfor["masothue"], Icons.badge),
                    _buildDetail("Mã GLN", farmInfor["ma_gln"], Icons.qr_code),
                    _buildDetail("Địa chỉ", farmInfor["diachi"], Icons.location_on),
                    _buildDetail("Số điện thoại", farmInfor["sodienthoai"], Icons.phone),
                    _buildDetail("Email", farmInfor["email"], Icons.email),
                    _buildDetail("Ngày tạo", _formatDate(farmInfor["created_at"]), Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Bản đồ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConfig.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.txng',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Chứng chỉ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConfig.primary,
              ),
            ),
            const SizedBox(height: 8),
            farmInfor["chungchi"] != null
                ? Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showCertificateDialog(farmInfor["chungchi"]),
                child: Image.network(
                  farmInfor["chungchi"],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: ColorConfig.cardPlaceholder,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: ColorConfig.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: ColorConfig.cardPlaceholder,
                    child: const Center(
                      child: Text(
                        'Lỗi tải ảnh chứng chỉ',
                        style: TextStyle(color: ColorConfig.error),
                      ),
                    ),
                  ),
                ),
              ),
            )
                : Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    "Không có chứng chỉ.",
                    style: TextStyle(fontSize: 16, color: ColorConfig.textMuted),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ColorConfig.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColorConfig.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Chưa có thông tin',
                  style: TextStyle(fontSize: 14, color: ColorConfig.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
