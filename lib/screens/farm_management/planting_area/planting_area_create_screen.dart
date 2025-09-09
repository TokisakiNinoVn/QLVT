import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:txng/config/color_config.dart';
import 'package:txng/services/farm_management/plantingarea_service.dart';
import 'package:txng/helpers/snackbar_helper.dart';

class PlantingAreaCreateScreen extends StatefulWidget {
  const PlantingAreaCreateScreen({super.key});

  @override
  State<PlantingAreaCreateScreen> createState() =>
      _PlantingAreaCreateScreenState();
}

class _PlantingAreaCreateScreenState extends State<PlantingAreaCreateScreen> {
  final PlantingAreaService _plantingareaService = PlantingAreaService();
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  File? _chungChiImage;
  String? _networkChungChiUrl;

  // Text controllers
  final _tenVungTrongController = TextEditingController();
  final _chuSoHuuController = TextEditingController();
  final _maSoThueController = TextEditingController();
  // final _maGlnController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  // final _emailController = TextEditingController();
  final _coordinatesController = TextEditingController();
  // final _madoanhnghiepController = TextEditingController();
  final _dienTichController = TextEditingController();

  final double _lat = 0.0;
  final double _lng = 0.0;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
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
    // _madoanhnghiepController.dispose();
    _dienTichController.dispose();
    super.dispose();
  }

  Future<void> _pickChungChiImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null || !mounted) return;

      setState(() {
        _chungChiImage = File(pickedFile.path);
        _networkChungChiUrl = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi chọn ảnh: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _deleteChungChiImage() {
    setState(() {
      _chungChiImage = null;
      _networkChungChiUrl = null;
    });
  }

  Future<void> _createPlantingArea() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final coordinates = _extractLatAndLng(_coordinatesController.text);
      final parts = coordinates.split(',');
      final lat = parts.isNotEmpty ? parts[0].trim() : '';
      final lng = parts.length > 1 ? parts[1].trim() : '';

      final Map<String, dynamic> data = {
        'tenvungtrong': _tenVungTrongController.text.trim(),
        'chusohuu': _chuSoHuuController.text.trim(),
        // 'masothue': _maSoThueController.text.trim(),
        // 'ma_gin': _maGlnController.text.trim(),
        'diachi': _diaChiController.text.trim(),
        'sodienthoai': _soDienThoaiController.text.trim(),
        // 'email': _emailController.text.trim(),
        // 'madoanhnghiep': _madoanhnghiepController.text.trim(),
        'dientich': _dienTichController.text.trim(),
        'map': null,
        'lat': lat,
        'lng': lng,
        'chungchi':
            _networkChungChiUrl == null && _chungChiImage == null ? 1 : 0,
      };

      final response = await _plantingareaService.createPlantingAreaService(
        data,
        _chungChiImage?.path ?? '',
      );
      SnackbarHelper.showSuccess(context, "Tạo vùng trồng thành công!");
      // context.go("/planting-area-management");
      Navigator.of(context).pop(true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tạo: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _extractLatAndLng(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parts = raw.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim())?.toString() ?? '';
        final lng = double.tryParse(parts[1].trim())?.toString() ?? '';
        return '$lat,$lng';
      }
    } catch (_) {}
    return raw;
  }

  Future<void> _pasteCoordinates() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final raw = clipboardData.text!.replaceAll(' ', '');
      final fixed = _convertCommaDecimalToDot(raw);
      _coordinatesController.text = fixed;
    }
  }

  /// Chuyển từ "21,5055349,105,8414795" -> "21.5055349,105.8414795"
  String _convertCommaDecimalToDot(String input) {
    final parts = input.split(',');
    if (parts.length < 4) return input; // fallback nếu không đúng format

    final lat = '${parts[0]}.${parts[1]}';
    final lng = '${parts[2]}.${parts[3]}';

    return '$lat,$lng';
  }


  Future<void> _loadPlantingArea() async {
    setState(() => _isLoading = false);
  }

  Future<void> requestLocationPermission() async {
    await Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Tạo Vùng Trồng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorConfig.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _createPlantingArea,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Container(
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.topCenter,
                //     end: Alignment.bottomCenter,
                //     colors: [Colors.green[50]!, Colors.white],
                //   ),
                // ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _tenVungTrongController,
                          label: "Tên vùng trồng",
                          icon: Icons.local_florist,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? "Vui lòng nhập tên vùng trồng"
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _dienTichController,
                          label: "Diện tích (m2)",
                          icon: Icons.square_foot,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final double? dienTich = double.tryParse(value);
                            if (dienTich == null || dienTich <= 0) {
                              return "Diện tích phải là số dương";
                            }
                            return null;
                          }
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _chuSoHuuController,
                          label: "Chủ sở hữu",
                          icon: Icons.person,
                        ),
                        // const SizedBox(height: 16),
                        // _buildTextField(
                        //   controller: _maSoThueController,
                        //   label: "Mã số thuế",
                        //   icon: Icons.description,
                        // ),
                        // const SizedBox(height: 16),
                        // _buildTextField(
                        //   controller: _madoanhnghiepController,
                        //   label: "Mã doanh nghiệp",
                        //   icon: Icons.description,
                        // ),
                        const SizedBox(height: 16),
                        // _buildTextField(
                        //   controller: _maGlnController,
                        //   label: "Mã GLN",
                        //   icon: Icons.qr_code,
                        // ),
                        // const SizedBox(height: 16),
                        _buildTextField(
                          controller: _diaChiController,
                          label: "Địa chỉ",
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _soDienThoaiController,
                          label: "Số điện thoại",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        // const SizedBox(height: 16),
                        // _buildTextField(
                        //   controller: _emailController,
                        //   label: "Email",
                        //   icon: Icons.email,
                        //   keyboardType: TextInputType.emailAddress,
                        //   validator: (value) {
                        //     if (value!.isEmpty) return null;
                        //     return RegExp(
                        //           r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        //         ).hasMatch(value)
                        //         ? null
                        //         : "Email không hợp lệ";
                        //   },
                        // ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _coordinatesController,
                          label: "Tọa độ (lat, lng)",
                          icon: Icons.map,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.paste, color: Colors.green),
                            onPressed: _pasteCoordinates,
                            tooltip: 'Dán tọa độ',
                          ),
                            validator: (value) {
                              if (value!.isEmpty) return null;
                              final parts = value.split(',');
                              if (parts.length != 2) return "Tọa độ không hợp lệ";
                              if (double.tryParse(parts[0].trim()) == null ||
                                  double.tryParse(parts[1].trim()) == null) {
                                return "Tọa độ phải là số";
                              }
                              return null;
                            }
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Ảnh vùng trồng",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_chungChiImage != null ||
                            _networkChungChiUrl != null) ...[
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image:
                                          _chungChiImage != null
                                              ? FileImage(_chungChiImage!)
                                              : NetworkImage(
                                                    _networkChungChiUrl!,
                                                  )
                                                  as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: _deleteChungChiImage,
                                  tooltip: 'Xóa ảnh',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton.icon(
                          onPressed: _pickChungChiImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Chọn ảnh vùng trồng"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createPlantingArea,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 40,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text("Tạo Vùng Trồng"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.green[800]),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
