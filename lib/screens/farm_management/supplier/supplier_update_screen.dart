import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:txng/services/farm_management/supplier_service.dart';
import '../../../config/color_config.dart';

class SupplierUpdateScreen extends StatefulWidget {
  final int id;
  final Map<String, dynamic> supplier;

  const SupplierUpdateScreen({
    super.key,
    required this.id,
    required this.supplier,
  });

  @override
  State<SupplierUpdateScreen> createState() => _SupplierUpdateScreenState();
}

class _SupplierUpdateScreenState extends State<SupplierUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  static final SupplierService _supplierService = SupplierService();

  File? _chungChiImage;
  String? _networkChungChiUrl;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final supplier = widget.supplier;
    _nameController.text = supplier["tennhacungcap"] ?? "";
    _addressController.text = supplier["diachi"] ?? "";
    _phoneController.text = supplier["sodienthoai"] ?? "";
    final cc = supplier["chungchi"];
    if (cc != null && cc.toString().trim().isNotEmpty) {
      _networkChungChiUrl = cc;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickChungChi() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _chungChiImage = File(pickedFile.path);
        _networkChungChiUrl = null;
      });
    } catch (e) {
      _showSnackBar("Lỗi khi chọn ảnh: $e", isError: true);
    }
  }

  Future<void> updateSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = {
        'tennhacungcap': _nameController.text.trim(),
        'diachi': _addressController.text.trim(),
        'sodienthoai': _phoneController.text.trim(),
      };

      final response = await _supplierService.updateSupplierService(
        widget.id,
        data,
        _chungChiImage?.path ?? '',
      );

      if (mounted) {
        _showSnackBar("Cập nhật thành công");
        context.pop();
      }
    } catch (e) {
      _showSnackBar("Lỗi khi cập nhật: $e", isError: true);
      print("Lỗi khi cập nhật nhà cung cấp: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showFullScreenImage() {
    if (_chungChiImage == null && (_networkChungChiUrl == null || _networkChungChiUrl!.isEmpty)) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: _chungChiImage != null
                  ? Image.file(_chungChiImage!, fit: BoxFit.contain)
                  : Image.network(_networkChungChiUrl!, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteChungChi() {
    setState(() {
      _chungChiImage = null;
      _networkChungChiUrl = null;
    });
    _showSnackBar('Đã xóa ảnh chứng chỉ');
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText, {
        TextInputType type = TextInputType.text,
        String? Function(String?)? validator,
        bool readOnly = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: null,
      minLines: 2,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorConfig.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorConfig.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildChungChiPicker() {
    ImageProvider imageProvider;

    if (_chungChiImage != null) {
      imageProvider = FileImage(_chungChiImage!);
    } else if (_networkChungChiUrl != null && _networkChungChiUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_networkChungChiUrl!);
    } else {
      imageProvider = const AssetImage('lib/assets/images/default-avt.png');
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _showFullScreenImage,
          child: CircleAvatar(radius: 60, backgroundImage: imageProvider),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickChungChi,
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text('Chọn ảnh', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: ColorConfig.primary),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _deleteChungChi,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Xóa ảnh', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật nhà cung cấp', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              _nameController,
              'Tên nhà cung cấp',
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _addressController,
              'Địa chỉ',
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _phoneController,
              'Số điện thoại',
              type: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
                if (!RegExp(r'^[0-9\s\/]+$').hasMatch(value)) return 'Số điện thoại không hợp lệ';
                return null;
              },
              // readOnly: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Ảnh chứng chỉ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ColorConfig.primary),
            ),
            const SizedBox(height: 12),
            Center(child: _buildChungChiPicker()),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : updateSupplier,
              icon: const Icon(Icons.save, color: Colors.white),
              label: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Cập nhật thông tin', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConfig.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
