import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';

import '../../../config/color_config.dart';

class FertilizerMedicineCreateScreen extends StatefulWidget {
  const FertilizerMedicineCreateScreen({super.key});

  @override
  State<FertilizerMedicineCreateScreen> createState() =>
      _FertilizerMedicineCreateScreenState();
}

class _FertilizerMedicineCreateScreenState
    extends State<FertilizerMedicineCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCareProcessId;
  bool _isLoading = false;
  static final FertilizerMedicineService _fertilizerMedicineService =
      FertilizerMedicineService();
  static final CareProcessService _listCareProcessService =
      CareProcessService();
  File? _fertilizerMedicineImage;
  late List<Map<String, dynamic>> listCareProcesses = [];

  @override
  void initState() {
    super.initState();
    _loadCareProcesses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null || !mounted) return;

      setState(() {
        _fertilizerMedicineImage = File(pickedFile.path);
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

  Future<void> _loadCareProcesses() async {
    try {
      setState(() => _isLoading = true);
      final response = await _listCareProcessService.getAllCareProcessService();
      final rawData = response["data"]?["quytrinhchamsocs"];

      if (rawData is List) {
        setState(() {
          listCareProcesses =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          listCareProcesses.sort((a, b) => a['sapxep'].compareTo(b['sapxep']));
        });
      } else {
        setState(() {
          listCareProcesses = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFullScreenImage(BuildContext context) {
    if (_fertilizerMedicineImage == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child: Image.file(
                    _fertilizerMedicineImage!,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _deleteAvatar() {
    setState(() {
      _fertilizerMedicineImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa ảnh đại diện'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm vật tư',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        elevation: 0,
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [ColorConfig.primary.shade50, Colors.white],
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  _nameController,
                  'Mã sản phẩm',
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Vui lòng nhập mã sản phẩm' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _birthdateController,
                  'Tên sản phẩm',
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
                ),
                const SizedBox(height: 16),
                // _buildTextField(
                //   _addressController,
                //   'Trọng lượng',
                //   validator:
                //       (value) =>
                //           value!.isEmpty ? 'Vui lòng nhập trọng lượng' : null,
                // ),
                // const SizedBox(height: 16),
                // _buildTextField(
                //   _phoneController,
                //   'Kích thước',
                //   validator:
                //       (value) =>
                //           value!.isEmpty ? 'Vui lòng nhập kích thước' : null,
                // ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  'Mô tả',
                  validator:
                      (value) => value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ảnh đại diện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColorConfig.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: _buildAvatarPicker(context)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Chọn Quy trình chăm sóc',
                    labelStyle: TextStyle(color: ColorConfig.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorConfig.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorConfig.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  value: _selectedCareProcessId,
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() => _selectedCareProcessId = value);
                    }
                  },
                  items:
                      listCareProcesses
                          .map(
                            (careProcess) => DropdownMenuItem(
                              value: careProcess['id'].toString(),
                              child: Text(
                                careProcess['hoatdong'] ??
                                    'Không có tên hoạt động',
                                style: TextStyle(color: ColorConfig.primary),
                              ),
                            ),
                          )
                          .toList(),
                  validator:
                      (value) =>
                          value == null
                              ? 'Vui lòng chọn quy trình chăm sóc'
                              : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);

                              final Map<String, dynamic> data = {
                                'masanpham': _nameController.text.trim(),
                                'tensanpham': _birthdateController.text.trim(),
                                // 'trongluong': _addressController.text.trim(),
                                // 'kichthuoc': _phoneController.text.trim(),
                                'mota': _emailController.text.trim(),
                                'mahoatdong': _selectedCareProcessId,
                              };

                              try {
                                final result = await _fertilizerMedicineService
                                    .createFertilizerMedicineService(
                                      data,
                                      _fertilizerMedicineImage?.path ?? '',
                                    );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thêm mới thành công!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.go("/fertilizer-medicine-management");

                                _formKey.currentState!.reset();
                                setState(() {
                                  _fertilizerMedicineImage = null;
                                  _selectedCareProcessId = null;
                                });
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi tạo: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                print('Lỗi khi tạo: $e');
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConfig.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Lưu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ColorConfig.primary),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorConfig.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorConfig.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildAvatarPicker(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap:
              _fertilizerMedicineImage != null
                  ? () => _showFullScreenImage(context)
                  : _pickAvatar,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: ColorConfig.primary, width: 2),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                _fertilizerMedicineImage != null
                    ? ClipOval(
                      child: Image.file(
                        _fertilizerMedicineImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Center(
                      child: Icon(
                        Icons.add_a_photo,
                        color: ColorConfig.primary,
                        size: 40,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_fertilizerMedicineImage != null)
              TextButton(
                onPressed: _deleteAvatar,
                child: const Text(
                  'Xóa ảnh',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            TextButton(
              onPressed: _pickAvatar,
              child: Text(
                _fertilizerMedicineImage != null ? 'Chọn lại ảnh' : 'Chọn ảnh',
                style: TextStyle(
                  color: ColorConfig.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
