import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:txng/config/app_config.dart';
import '../../../services/production_facility/additive_products_service.dart';
import '../../../services/production_facility/production_process_service.dart';

class AdditiveProductsUpdateScreen extends StatefulWidget {
  final int id;
  const AdditiveProductsUpdateScreen({super.key, required this.id});

  @override
  State<AdditiveProductsUpdateScreen> createState() =>
      _AdditiveProductsUpdateScreenState();
}

class _AdditiveProductsUpdateScreenState
    extends State<AdditiveProductsUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedProductionProcessId;
  bool _isLoading = false;
  static final AdditiveProductsService _fertilizerMedicineService =
      AdditiveProductsService();
  static final ProductionProcessService _listProductionProcessService =
      ProductionProcessService();
  File? _fertilizerMedicineImage;
  String? _networkImageUrl;
  late List<Map<String, dynamic>> listProductionProcesses = [];

  @override
  void initState() {
    super.initState();
    _loadProductionProcesses();
    _loadDetailsAdditiveProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
        _networkImageUrl =
            null; // Clear network image when a new local image is picked
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

  Future<void> _loadProductionProcesses() async {
    try {
      setState(() => _isLoading = true);
      final response =
          await _listProductionProcessService.getAllProductionProcessService();
      final rawData = response["data"]?["quytrinhchebiens"];

      if (rawData is List) {
        setState(() {
          listProductionProcesses =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          listProductionProcesses.sort(
            (a, b) => a['sapxep'].compareTo(b['sapxep']),
          );
        });
      } else {
        setState(() {
          listProductionProcesses = [];
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

  Future<void> _loadDetailsAdditiveProducts() async {
    try {
      setState(() => _isLoading = true);
      final response = await _fertilizerMedicineService
          .getDetailsAdditiveProductsService(widget.id);
      final rawData = response["data"]?["sanphamphugia"];
      if (rawData != null && mounted) {
        setState(() {
          _nameController.text = rawData['masanpham'] ?? '';
          _birthdateController.text = rawData['tensanpham'] ?? '';
          _addressController.text = rawData['trongluong'] ?? '';
          _phoneController.text = rawData['kichthuoc'] ?? '';
          _emailController.text = rawData['mota'] ?? '';
          _selectedProductionProcessId = rawData['mahoatdong']?.toString();
          if (rawData['hinhanh'] != null) {
            _networkImageUrl = '${AppConfig.apiUrlImage}/${rawData['hinhanh']}';
            _fertilizerMedicineImage =
                null; // Ensure local image is null if using network image
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFullScreenImage(BuildContext context) {
    if (_fertilizerMedicineImage == null && _networkImageUrl == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child:
                      _fertilizerMedicineImage != null
                          ? Image.file(
                            _fertilizerMedicineImage!,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          )
                          : Image.network(
                            _networkImageUrl!,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            errorBuilder:
                                (context, error, stackTrace) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 40,
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
      _networkImageUrl = null;
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
          'Cập nhật SP phụ gia',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
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
                _buildTextField(
                  _addressController,
                  'Trọng lượng',
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Vui lòng nhập trọng lượng' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _phoneController,
                  'Kích thước',
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Vui lòng nhập kích thước' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  'Mô tả',
                  validator:
                      (value) => value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ảnh đại diện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: _buildAvatarPicker(context)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Chọn Quy trình chăm sóc',
                    labelStyle: const TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.teal,
                        width: 2,
                      ),
                    ),
                  ),
                  value:
                      listProductionProcesses.any(
                            (e) =>
                                e['id'].toString() ==
                                _selectedProductionProcessId,
                          )
                          ? _selectedProductionProcessId
                          : null,
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() => _selectedProductionProcessId = value);
                    }
                  },
                  items:
                      listProductionProcesses.map((careProcess) {
                        final idStr = careProcess['id'].toString();
                        return DropdownMenuItem<String>(
                          value: idStr,
                          child: Text(
                            careProcess['hoatdong'] ?? 'Không có tên hoạt động',
                            style: const TextStyle(color: Colors.teal),
                          ),
                        );
                      }).toList(),
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
                                'trongluong': _addressController.text.trim(),
                                'kichthuoc': _phoneController.text.trim(),
                                'mota': _emailController.text.trim(),
                                'mahoatdong': _selectedProductionProcessId,
                              };

                              try {
                                final result = await _fertilizerMedicineService
                                    .updateAdditiveProductsService(
                                      widget.id,
                                      data,
                                      _fertilizerMedicineImage?.path ?? '',
                                    );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cập nhật thành công!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.go("/fertilizer-medicine-management");

                                _formKey.currentState!.reset();
                                setState(() {
                                  _fertilizerMedicineImage = null;
                                  _networkImageUrl = null;
                                  _selectedProductionProcessId = null;
                                });
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi cập nhật: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                print('Lỗi khi cập nhật: $e');
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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
                            'Cập nhật',
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
        labelStyle: const TextStyle(color: Colors.teal),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
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
              (_fertilizerMedicineImage != null || _networkImageUrl != null)
                  ? () => _showFullScreenImage(context)
                  : _pickAvatar,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 2),
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
                    : _networkImageUrl != null
                    ? ClipOval(
                      child: Image.network(
                        _networkImageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.teal,
                                size: 40,
                              ),
                            ),
                      ),
                    )
                    : const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.teal,
                        size: 40,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_fertilizerMedicineImage != null || _networkImageUrl != null)
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
                (_fertilizerMedicineImage != null || _networkImageUrl != null)
                    ? 'Chọn lại ảnh'
                    : 'Chọn ảnh',
                style: const TextStyle(
                  color: Colors.teal,
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
