import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:txng/services/production_facility/productionfacility_service.dart';

import '../../../config/color_config.dart';

class InforCSSXScreen extends StatefulWidget {
  const InforCSSXScreen({super.key});

  @override
  State<InforCSSXScreen> createState() =>
      _InforCSSXScreenState();
}

class _InforCSSXScreenState extends State<InforCSSXScreen> {
  static final ProductionFacilityService _plantingareaService = ProductionFacilityService();
  Map<String, dynamic> plantingareaInfor = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _loadProductionFacility();
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

  Future<void> _loadProductionFacility() async {
    try {
      final response =
          await _plantingareaService.getDetailsProductionFacilityService();
      final rawData = response["data"]?["coso"];
      if (rawData is Map<String, dynamic>) {
        setState(() {
          plantingareaInfor = rawData;
        });
      } else {
        setState(() {
          plantingareaInfor = {};
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: Colors.redAccent,
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
      builder:
          (_) => Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.black,
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
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => const Center(
                          child: Text(
                            'Lỗi tải ảnh',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
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
    double latitude = double.tryParse(plantingareaInfor["lat"] ?? "") ?? 0.0;
    double longitude = double.tryParse(plantingareaInfor["lng"] ?? "") ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Thông tin CSSX",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: _loadProductionFacility,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 26),
            onPressed: () {
              context.go("/cssx-management/cssx-update");
            },
            tooltip: 'Chỉnh sửa thông tin',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : plantingareaInfor.isEmpty
              ? Center(
                child: Text(
                  "Không có dữ liệu vùng trồng.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                            _buildDetail(
                              "Tên cơ sở",
                              plantingareaInfor["tencoso"],
                              Icons.location_city,
                            ),
                            _buildDetail(
                              "Chủ sở hữu",
                              plantingareaInfor["chusohuu"],
                              Icons.person,
                            ),
                            _buildDetail(
                              "Mã số thuế",
                              plantingareaInfor["masothue"],
                              Icons.badge,
                            ),
                            _buildDetail(
                              "Mã GLN",
                              plantingareaInfor["ma_gln"],
                              Icons.qr_code,
                            ),
                            _buildDetail(
                              "Địa chỉ",
                              plantingareaInfor["diachi"],
                              Icons.location_on,
                            ),
                            _buildDetail(
                              "Số điện thoại",
                              plantingareaInfor["sodienthoai"],
                              Icons.phone,
                            ),
                            _buildDetail(
                              "Email",
                              plantingareaInfor["email"],
                              Icons.email,
                            ),
                            _buildDetail(
                              "Ngày tạo",
                              _formatDate(plantingareaInfor["created_at"]),
                              Icons.calendar_today,
                            ),
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
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                    plantingareaInfor["chungchi"] != null
                        ? Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap:
                                () => _showCertificateDialog(
                                  plantingareaInfor["chungchi"],
                                ),
                            child: Image.network(
                              plantingareaInfor["chungchi"],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                      color:
                                          ColorConfig.primary,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Text(
                                        'Lỗi tải ảnh chứng chỉ',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
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
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "Không có chứng chỉ.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Chưa có thông tin',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
