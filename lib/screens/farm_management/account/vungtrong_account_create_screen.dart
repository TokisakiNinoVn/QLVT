import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:txng/services/farm_management/account_service.dart';

import '../../../config/color_config.dart';

class AccountCreateScreen extends StatefulWidget {
  const AccountCreateScreen({super.key});

  @override
  State<AccountCreateScreen> createState() => _AccountCreateScreenState();
}

class _AccountCreateScreenState extends State<AccountCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'quanly';
  bool _isLoading = false;
  static AccountService _accountService = AccountService();

  final List<String> _roles = ['quanly', 'nhancong'];
  File? _avatarImage;

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
        _avatarImage = File(pickedFile.path);
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

  void _showFullScreenImage(BuildContext context) {
    if (_avatarImage == null) return;

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
                    _avatarImage!,
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
          'Tạo tài khoản vùng trồng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        elevation: 0,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  _nameController,
                  'Họ và Tên',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập Họ và Tên';
                    }
                    if (value.trim().length <= 3) {
                      return 'Họ và Tên phải dài hơn 3 ký tự';
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
                      return 'Định dạng ngày sinh không hợp lệ (dd/mm/yyyy)';
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
                      return 'Vui lòng nhập Địa chỉ';
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
                      return 'Vui lòng nhập Số điện thoại';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Số điện thoại phải có 10 chữ số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  'Email',
                  type: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập Email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _passwordController,
                  'Mật khẩu',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập Mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt';
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
                      borderSide: BorderSide(
                        color: ColorConfig.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  value: _selectedRole,
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() => _selectedRole = value);
                    }
                  },
                  items:
                  _roles
                      .map(
                        (role) => DropdownMenuItem(
                      value: role,
                      child: Text(
                        role == 'quanly' ? 'Quản lý' : 'Nhân công',
                        style: TextStyle(color: ColorConfig.primary),
                      ),
                    ),
                  )
                      .toList(),
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
                                'hoten': _nameController.text.trim(),
                                'ngaysinh': _birthdateController.text.trim(),
                                'diachi': _addressController.text.trim(),
                                'sodienthoai': _phoneController.text.trim(),
                                'email': _emailController.text.trim(),
                                'password': _passwordController.text.trim(),
                                'quyenhan': _selectedRole,
                              };

                              try {
                                final result = await _accountService
                                    .createAccountService(
                                      data,
                                      _avatarImage?.path ?? '',
                                    );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tạo tài khoản thành công! 🎉',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.go("/account-management");

                                _formKey.currentState!.reset();
                                setState(() {
                                  _avatarImage = null;
                                  _selectedRole = 'quanly';
                                });
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi tạo tài khoản: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                print('Lỗi khi tạo tài khoản: $e');
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
                            'Lưu Tài Khoản',
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
              _avatarImage != null
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
                _avatarImage != null
                    ? ClipOval(
                      child: Image.file(
                        _avatarImage!,
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
            if (_avatarImage != null)
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
                _avatarImage != null ? 'Chọn lại ảnh' : 'Chọn ảnh',
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
