import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:txng/services/farm_management/care_history_service.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';
import 'package:txng/services/farm_management/plantingarea_service.dart';
import 'package:txng/services/storage_service.dart';

import '../../../config/color_config.dart';

class PlantingAreaQRDetailsVTScreen extends StatefulWidget {
  final String? code;

  const PlantingAreaQRDetailsVTScreen({super.key, this.code});

  @override
  State<PlantingAreaQRDetailsVTScreen> createState() =>
      _PlantingAreaQRDetailsVTScreenState();
}

class _PlantingAreaQRDetailsVTScreenState extends State<PlantingAreaQRDetailsVTScreen> {
  Map<String, dynamic> plantingareaInfor = {};
  PlantingAreaService _plantingareaService = PlantingAreaService();
  bool _isLoading = true;
  final _tenVungTrongController = TextEditingController();
  final _chuSoHuuController = TextEditingController();
  final _maSoThueController = TextEditingController();
  // final _maGlnController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  // final _emailController = TextEditingController();
  final _coordinatesController = TextEditingController();
  String? _networkChungChiUrl;

  @override
  void initState() {
    super.initState();
    _loadPlantingArea();
  }

  @override
  void dispose() {
    _tenVungTrongController.dispose();
    _chuSoHuuController.dispose();
    _maSoThueController.dispose();
    // _maGlnController.dispose();
    _diaChiController.dispose();
    _soDienThoaiController.dispose();
    // _emailController.dispose();
    _coordinatesController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantingArea() async {
    final response = await _plantingareaService.getPlantingAreaByCodeService(widget.code ?? '');
    print("response: $response");
    final rawData = response["data"];

    setState(() {
      plantingareaInfor = rawData;
      _tenVungTrongController.text = rawData["tenvungtrong"] ?? '';
      _chuSoHuuController.text = rawData["chusohuu"] ?? '';
      _maSoThueController.text = rawData["masothue"] ?? '';
      // _maGlnController.text = rawData["ma_gln"] ?? '';
      _diaChiController.text = rawData["diachi"] ?? '';
      _soDienThoaiController.text = rawData["sodienthoai"] ?? '';
      // _emailController.text = rawData["email"] ?? '';
      _coordinatesController.text =
      '${rawData["lat"] ?? ''}, ${rawData["lng"] ?? ''}';
      _networkChungChiUrl = rawData["chungchi"];
      _isLoading = false;
    });
  }

  // Function to copy coordinates to clipboard
  void _copyCoordinatesToClipboard() {
    final coordinates = _coordinatesController.text;
    Clipboard.setData(ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép tọa độ vào bộ nhớ đệm')),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool multiLine = false,
    bool showCopyButton = false, // Added parameter for copy button
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              readOnly: true,
              maxLines: multiLine ? 3 : 1,
              minLines: multiLine ? 3 : 1,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (showCopyButton) // Conditionally show copy button
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.copy, color: ColorConfig.primary),
                onPressed: _copyCoordinatesToClipboard,
                tooltip: 'Sao chép tọa độ',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Thông tin vùng trồng",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _tenVungTrongController,
                label: "Tên vùng trồng",
                multiLine: true,
              ),
              _buildTextFormField(
                controller: _chuSoHuuController,
                label: "Chủ sở hữu",
              ),
              _buildTextFormField(
                controller: _maSoThueController,
                label: "Mã số thuế",
              ),
              // _buildTextFormField(
              //   controller: _maGlnController,
              //   label: "M Dlaczego GLN",
              // ),
              _buildTextFormField(
                controller: _diaChiController,
                label: "Địa chỉ",
                multiLine: true,
              ),
              _buildTextFormField(
                controller: _soDienThoaiController,
                label: "Số điện thoại",
              ),
              // _buildTextFormField(
              //   controller: _emailController,
              //   label: "Email",
              // ),
              _buildTextFormField(
                controller: _coordinatesController,
                label: "Tọa độ (lat, lng)",
                showCopyButton: true, // Enable copy button for coordinates
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Ảnh vùng trồng",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_networkChungChiUrl != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _networkChungChiUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi tiết vùng trồng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildViewMode(),
      ),
    );
  }
}