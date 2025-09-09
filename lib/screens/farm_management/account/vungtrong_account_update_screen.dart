import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:txng/services/farm_management/account_service.dart';

import '../../../config/color_config.dart';

class AccountUpdateScreen extends StatefulWidget {
  final int id;
  const AccountUpdateScreen({super.key, required this.id});

  @override
  State<AccountUpdateScreen> createState() => _AccountUpdateScreenState();
}

class _AccountUpdateScreenState extends State<AccountUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRole = 'quanly';
  bool _isLoading = false;
  static final AccountService _accountService = AccountService();

  final List<String> _roles = ['quanly', 'nhancong'];
  File? _avatarImage;
  String? _networkAvatarUrl;

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
        _avatarImage = File(pickedFile.path);
        _networkAvatarUrl = null;
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

  Future<void> updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        'hoten': _nameController.text.trim(),
        'ngaysinh': _birthdateController.text.trim(),
        'diachi': _addressController.text.trim(),
        'sodienthoai': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'quyenhan': _selectedRole,
        '_method': 'PUT',
      };

      final response = await _accountService.updateAccountService(
        widget.id,
        data,
        _avatarImage?.path ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thành công"),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi cập nhật: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAccountDetails(widget.id);
  }

  Future<void> _loadAccountDetails(int id) async {
    try {
      final response = await _accountService.getDetailsAccountService(id);
      final data = response["data"]?["taikhoanvungtrong"];
      if (data != null && mounted) {
        setState(() {
          _nameController.text = data["hoten"] ?? "";
          _birthdateController.text = data["ngaysinh"] ?? "";
          _addressController.text = data["diachi"] ?? "";
          _phoneController.text = data["sodienthoai"] ?? "";
          _emailController.text = data["email"] ?? "";
          _selectedRole = data["quyenhan"] ?? "quanly";
          final avatar = data["avatar"];
          if (avatar != null && avatar.toString().trim().isNotEmpty) {
            _networkAvatarUrl = avatar;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
    }
  }

  void _showFullScreenImage(BuildContext context) {
    if (_avatarImage == null &&
        (_networkAvatarUrl == null || _networkAvatarUrl!.isEmpty))
      return;

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
                      _avatarImage != null
                          ? Image.file(
                            _avatarImage!,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          )
                          : Image.network(
                            _networkAvatarUrl!,
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
      _avatarImage = null;
      _networkAvatarUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa ảnh đại diện'),
        backgroundColor: Colors.green,
      ),
    );
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

  Widget _buildAvatarPicker(BuildContext context) {
    ImageProvider avatarProvider;

    if (_avatarImage != null) {
      avatarProvider = FileImage(_avatarImage!);
    } else if (_networkAvatarUrl != null && _networkAvatarUrl!.isNotEmpty) {
      avatarProvider = NetworkImage(_networkAvatarUrl!);
    } else {
      avatarProvider = const AssetImage('lib/assets/images/default-avt.png');
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showFullScreenImage(context),
          child: CircleAvatar(radius: 60, backgroundImage: avatarProvider),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickAvatar,
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text(
                'Chọn ảnh',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: ColorConfig.primary),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _deleteAvatar,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Xóa ảnh',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
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
        title: const Text(
          'Cập nhật tài khoản vùng trồng',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              _nameController,
              'Họ và Tên',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập Họ và Tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _birthdateController,
              'Ngày sinh (dd/mm/yyyy)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập Ngày sinh';
                }
                if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                  return 'Ngày sinh không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _addressController,
              'Địa chỉ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập địa chỉ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _phoneController,
              'Số điện thoại',
              type: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _emailController,
              'Email',
              type: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
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
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Quyền hạn',
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
                  borderSide: BorderSide(color: ColorConfig.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                if (value != null) setState(() => _selectedRole = value);
              },
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(
                    role == 'quanly' ? 'Quản lý' : 'Nhân công',
                    style: TextStyle(color: ColorConfig.primary),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : updateAccount,
              icon: const Icon(Icons.save, color: Colors.white),
              label:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Cập nhật thông tin',
                        style: TextStyle(color: Colors.white),
                      ),
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
