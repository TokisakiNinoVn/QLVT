import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:txng/routes/app_router.dart';
// import 'package:txng/services/storage_service.dart';
import 'package:txng/screens/widget/account_screen.dart';
import 'package:txng/screens/farm_management/widgets/vungtrong_quanly_home_widget.dart';
import 'package:txng/screens/farm_management/widgets/vungtrong_nhancong_home_widget.dart';
import 'package:txng/screens/production_facility/widgets/cssx_nhancong_home_widget.dart';
import 'package:txng/screens/production_facility/widgets/cssx_quanly_home_widget.dart';
import 'package:txng/screens/transport/widgets/vanchuyen_nhancong_home_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _roleType;
  String? _roleUser;
  String? textAppbar;

  @override
  void initState() {
    super.initState();
    _loadRoleType();
  }

  Future<void> _loadRoleType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _roleType = prefs.getString('loginOption_type');
      _roleUser = prefs.getString('quyenhan');
      loadTextAppbar();
    });
  }

  void loadTextAppbar() {
    if (_roleType == 'vung_trong') {
      textAppbar =
          _roleUser == 'quanly'
              ? 'Trang trại - Quản lý'
              : 'Trang trại - Nhân công';
    } else if (_roleType == 'cs_san_xuat') {
      textAppbar =
          _roleUser == 'quanly'
              ? 'Cơ sở sản xuất - Quản lý'
              : 'Cơ sở sản xuất - Nhân công';
    } else {
      textAppbar = 'Xin chào!';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('inforUserLogin');
    await prefs.remove('loginOption_type');
    await prefs.remove('quyenhan');
    authState.logout();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận đăng xuất"),
          content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Đăng xuất"),
              onPressed: () async {
                await _logout();
                Navigator.of(context).pop();
                context.go("/option-login");
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text("Đăng xuất thành công!")),
                // );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_roleType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          textAppbar ?? 'Trang chủ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          if (_roleType == 'vung_trong')
            _roleUser == 'quanly'
                ? const VungTrongQuanlyScreen()
                : const VungTrongNhanCongScreen()
          else if (_roleType == 'cs_san_xuat')
            _roleUser == 'quanly'
                ? const CSSXQuanLyScreen()
                : const CSSXNhanCongScreen()
          // else if (_roleType == 'vantai')
          //   const VanTaiNhanCongScreen()
          else
            const Center(child: Text('Đi lạc à bro?!')),
          // const Center(child: Text('Account Screen')),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 10.0,
        color: Colors.white,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex > 1 ? 1 : _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 24.0,
          selectedFontSize: 12.0,
          unselectedFontSize: 10.0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => context.go('/scan-qr'),
        onPressed: () {
          if (_roleType == 'vung_trong') {
            // context.go('/');
            context.go('/scan-qr');
          } else if (_roleType == 'cs_san_xuat') {
            context.go('/scan-qr-cssx');
          } else {
          }
        },
        tooltip: _roleType == 'vung_trong' ? 'Scan QR thêm lịch sử chăm sóc cho vùng trồng' : 'Scan QR thêm lịch sử chế biến cho lô hàng',
        backgroundColor: Colors.blueAccent,
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
