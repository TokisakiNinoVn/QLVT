import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:txng/services/farm_management/farm_service.dart';
import 'package:txng/config/color_config.dart';

class FarmUpdateScreen extends StatefulWidget {
  const FarmUpdateScreen({super.key});

  @override
  State<FarmUpdateScreen> createState() => _FarmUpdateScreenState();
}

class _FarmUpdateScreenState extends State<FarmUpdateScreen> {
  final FarmService _farmService = FarmService();
  Map<String, dynamic> farmInfor = {};
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
  final _madoanhnghiepController = TextEditingController();

  double _lat = 0.0;
  double _lng = 0.0;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _loadFarm();
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
    _madoanhnghiepController.dispose();
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
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (status.isPermanentlyDenied) openAppSettings();
    }
  }

  Future<void> _loadFarm() async {
    try {
      final response = await _farmService.getDetailsFarmService();
      final rawData = response["data"]?["trangtrai"];

      if (rawData is Map<String, dynamic>) {
        setState(() {
          farmInfor = rawData;
          _tenVungTrongController.text = rawData["tentrangtrai"] ?? '';
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
          _madoanhnghiepController.text = rawData["madoanhnghiep"] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          farmInfor = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
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
        maxHeight: 800,
        maxWidth: 800,
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
            behavior: SnackBarBehavior.floating,
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

  Future<void> _updateFarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final coordinates = _extractLatAndLng(_coordinatesController.text);
      final parts = coordinates.split(',');
      final lat = parts.isNotEmpty ? parts[0].trim() : '';
      final lng = parts.length > 1 ? parts[1].trim() : '';

      final Map<String, dynamic> data = {
        'id': farmInfor['id'],
        'tentrangtrai': _tenVungTrongController.text.trim(),
        'chusohuu': _chuSoHuuController.text.trim(),
        'masothue': _maSoThueController.text.trim(),
        'ma_gln': _maGlnController.text.trim(),
        'diachi': _diaChiController.text.trim(),
        'sodienthoai': _soDienThoaiController.text.trim(),
        'email': _emailController.text.trim(),
        'map': farmInfor['map'] ?? '',
        'madoanhnghiep': _madoanhnghiepController.text.trim(),
        'lat': lat,
        'lng': lng,
        'chungchi':
        _networkChungChiUrl == null && _chungChiImage == null ? 1 : 0,
      };

      final response = await _farmService.updateFarmService(
        data,
        _chungChiImage?.path ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Cập nhật thông tin thành công!"),
          backgroundColor: ColorConfig.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      context.go("/farm-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi cập nhật: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
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
    if (clipboardData?.text != null) {
      final coordinates = _extractLatAndLng(clipboardData!.text!);
      _coordinatesController.text = coordinates;
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool multiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: ColorConfig.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConfig.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConfig.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConfig.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConfig.error),
          ),
          filled: true,
          fillColor: ColorConfig.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(color: ColorConfig.textPrimary),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: multiLine ? 3 : 1,
        minLines: multiLine ? 3 : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật thông tin trang trại",
          style: TextStyle(
            color: ColorConfig.white
          ),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _updateFarm,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(
        color: ColorConfig.primary,
      ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _tenVungTrongController,
                label: "Tên trang trại",
                multiLine: true,
                validator: (value) => value!.isEmpty
                    ? "Vui lòng nhập tên trang trại"
                    : null,
              ),
              _buildTextFormField(
                controller: _chuSoHuuController,
                label: "Chủ sở hữu",
              ),
              _buildTextFormField(
                controller: _maSoThueController,
                label: "Mã số thuế",
              ),
              _buildTextFormField(
                controller: _maGlnController,
                label: "Mã GLN",
              ),
              _buildTextFormField(
                controller: _madoanhnghiepController,
                label: "Mã doanh nghiệp",
              ),
              _buildTextFormField(
                controller: _diaChiController,
                label: "Địa chỉ",
                multiLine: true,
              ),
              _buildTextFormField(
                controller: _soDienThoaiController,
                label: "Số điện thoại",
                keyboardType: TextInputType.phone,
              ),
              _buildTextFormField(
                controller: _emailController,
                label: "Email",
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
              _buildTextFormField(
                controller: _coordinatesController,
                label: "Tọa độ (lat, lng)",
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final parts = value.split(',');
                  if (parts.length != 2) return "Tọa độ không hợp lệ";
                  if (double.tryParse(parts[0].trim()) == null ||
                      double.tryParse(parts[1].trim()) == null) {
                    return "Tọa độ phải là số";
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: _pasteCoordinates,
                  tooltip: 'Dán tọa độ từ clipboard',
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Chứng chỉ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColorConfig.deepGreen, // Màu tiêu đề phụ
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_chungChiImage != null || _networkChungChiUrl != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorConfig.lightGreen),
                        color: ColorConfig.cardPlaceholder,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _chungChiImage != null
                            ? Image.file(_chungChiImage!, fit: BoxFit.cover)
                            : Image.network(_networkChungChiUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.error,
                              color: ColorConfig.error,
                              size: 40,
                            )),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _deleteChungChiImage,
                    tooltip: 'Xóa chứng chỉ',
                    style: IconButton.styleFrom(
                      backgroundColor: ColorConfig.error, // Màu nút xóa
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ],
                ),
              OutlinedButton.icon(
                onPressed: _pickChungChiImage,
                icon: Icon(Icons.image, color: ColorConfig.primary),
                label: Text(
                  "Chọn ảnh chứng chỉ",
                  style: TextStyle(color: ColorConfig.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorConfig.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateFarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConfig.primary,
                    foregroundColor: ColorConfig.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Lưu thay đổi"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
