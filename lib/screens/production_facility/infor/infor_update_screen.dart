import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:txng/services/production_facility/productionfacility_service.dart';

import '../../../config/color_config.dart';

class InforCSSXUpdateScreen extends StatefulWidget {
  const InforCSSXUpdateScreen({super.key});

  @override
  State<InforCSSXUpdateScreen> createState() =>
      _InforCSSXUpdateScreenState();
}

class _InforCSSXUpdateScreenState
    extends State<InforCSSXUpdateScreen> {
  final ProductionFacilityService _plantingareaService =
  ProductionFacilityService();
  Map<String, dynamic> plantingareaInfor = {};
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  File? _chungChiImage;
  String? _networkChungChiUrl;

  // Text controllers
  final _tenVungTrongController = TextEditingController();
  final _chuSoHuuController = TextEditingController();
  final _maSoThueController = TextEditingController();
  final _maGlnController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _emailController = TextEditingController();
  final _coordinatesController = TextEditingController();

  double _lat = 0.0;
  double _lng = 0.0;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _loadProductionFacility();
  }

  @override
  void dispose() {
    _tenVungTrongController.dispose();
    _chuSoHuuController.dispose();
    _maSoThueController.dispose();
    _maGlnController.dispose();
    _diaChiController.dispose();
    _soDienThoaiController.dispose();
    _emailController.dispose();
    _coordinatesController.dispose();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isPermanentlyDenied
                ? "Vui lòng cấp quyền vị trí trong cài đặt!"
                : "Bị từ chối quyền truy cập vị trí.",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      if (status.isPermanentlyDenied) openAppSettings();
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
          _tenVungTrongController.text = rawData["tencoso"] ?? '';
          _chuSoHuuController.text = rawData["chusohuu"] ?? '';
          _maSoThueController.text = rawData["masothue"] ?? '';
          _maGlnController.text = rawData["ma_gln"] ?? '';
          _diaChiController.text = rawData["diachi"] ?? '';
          _soDienThoaiController.text = rawData["sodienthoai"] ?? '';
          _emailController.text = rawData["email"] ?? '';
          _coordinatesController.text =
          '${rawData["lat"] ?? ''}, ${rawData["lng"] ?? ''}';
          _networkChungChiUrl = rawData["chungchi"];
          _lat = double.tryParse(rawData["lat"] ?? "0.0") ?? 0.0;
          _lng = double.tryParse(rawData["lng"] ?? "0.0") ?? 0.0;
          _isLoading = false;
        });
      } else {
        setState(() {
          plantingareaInfor = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _updateProductionFacility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final coordinates = _extractLatAndLng(_coordinatesController.text);
      final parts = coordinates.split(',');
      final lat = parts.isNotEmpty ? parts[0].trim() : '';
      final lng = parts.length > 1 ? parts[1].trim() : '';

      final Map<String, dynamic> data = {
        'tencoso': _tenVungTrongController.text.trim(),
        'chusohuu': _chuSoHuuController.text.trim(),
        'masothue': _maSoThueController.text.trim(),
        'ma_gln': _maGlnController.text.trim(),
        'diachi': _diaChiController.text.trim(),
        'sodienthoai': _soDienThoaiController.text.trim(),
        'email': _emailController.text.trim(),
        'map': plantingareaInfor['map'] ?? '',
        'lat': lat,
        'lng': lng,
        'chungchi':
        _networkChungChiUrl == null && _chungChiImage == null ? 1 : 0,
      };

      final response = await _plantingareaService.updateProductionFacilityService(data, _chungChiImage?.path ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Cập nhật thông tin thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      context.go("/cssx-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi cập nhật: $e"),
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
      final coordinates = _extractLatAndLng(clipboardData.text);
      _coordinatesController.text = coordinates;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cập nhật thông tin CSSX",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProductionFacility,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorConfig.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
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
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập tên vùng trồng" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _chuSoHuuController,
                  label: "Chủ sở hữu",
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _maSoThueController,
                  label: "Mã số thuế",
                  icon: Icons.receipt,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _maGlnController,
                  label: "Mã GLN",
                  icon: Icons.qr_code,
                ),
                const SizedBox(height: 16),
                _buildTextArea(
                  controller: _diaChiController,
                  label: "Địa chỉ",
                  icon: Icons.location_on,
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _soDienThoaiController,
                  label: "Số điện thoại",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return null;
                    return RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)
                        ? null
                        : "Email không hợp lệ";
                  },
                ),
                const SizedBox(height: 16),
                _buildTextArea(
                  controller: _coordinatesController,
                  label: "Tọa độ (lat, lng)",
                  icon: Icons.map,
                  minLines: 2,
                  maxLines: 3,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _pasteCoordinates,
                    tooltip: 'Dán tọa độ từ bộ nhớ',
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
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  "Chứng chỉ",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorConfig.primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (_chungChiImage != null || _networkChungChiUrl != null) ...[
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          child: _chungChiImage != null
                              ? Image.file(
                            _chungChiImage!,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            _networkChungChiUrl!,
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
                        tooltip: 'Xóa chứng chỉ',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _pickChungChiImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Chọn ảnh chứng chỉ"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: ColorConfig.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProductionFacility,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: ColorConfig.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Lưu thay đổi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorConfig.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorConfig.primary,
            width: 2,
          ),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int minLines = 3,
    int maxLines = 5,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorConfig.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorConfig.primary,
            width: 2,
          ),
        ),
      ),
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
    );
  }
}