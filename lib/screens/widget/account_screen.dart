import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('inforUserLogin');

    if (userData != null) {
      setState(() {
        user = jsonDecode(userData);
      });
    }
  }

  String _checkAvatarLink(String? avatar) {
    if (avatar == null || avatar.isEmpty || !avatar.startsWith('http') || avatar == 'null' || avatar == 'undefined') {
      return "https://i.pinimg.com/736x/35/51/aa/3551aa1febb5d532e2e1909f00c23074.jpg";
    }
    print("Link avatar: ${AppConfig.apiUrlImage}/$avatar");
    return "${AppConfig.apiUrlImage}/$avatar";
  }


  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              _checkAvatarLink(user!['avatar']),
            ),
            onBackgroundImageError: (_, __) => const Icon(Icons.account_circle, size: 100),
          ),
          const SizedBox(height: 16),
          _buildInfoTile('Họ tên', user!['hoten'] ?? 'Không có thông tin'),
          _buildInfoTile('Ngày sinh', user!['ngaysinh']?.toString() ?? 'Không có thông tin'),
          _buildInfoTile('Địa chỉ', user!['diachi'] ?? 'Không có thông tin'),
          _buildInfoTile('Số điện thoại', user!['sodienthoai']),
          // _buildInfoTile('Email', user!['email']),
          _buildInfoTile('Quyền hạn', user!['quyenhan'] == 'quanly' ? 'Quản lý' : 'Nhân công'),
          // _buildInfoTile('Mã vùng trồng', user!['mavungtrong'].toString()),
          // _buildInfoTile('Mã doanh nghiệp', user!['madoanhnghiep'].toString()),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     // Bạn có thể thêm logic "Chỉnh sửa" hoặc "Đăng xuất" tại đây
          //   },
          //   child: const Text('Cập nhật thông tin'),
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
