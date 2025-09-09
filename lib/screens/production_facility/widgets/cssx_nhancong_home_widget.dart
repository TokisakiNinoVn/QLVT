import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CSSXNhanCongScreen extends StatelessWidget {
  const CSSXNhanCongScreen({super.key});

  final List<_MenuCategory> menuCategories = const [
    // _MenuCategory(
    //   title: 'Quản lý cơ sở sản xuất',
    //   items: [
    //     _MenuItem(id: 1, title: 'Thông tin CSSX', icon: Icons.info),
    //     _MenuItem(id: 2, title: 'Quản lý tài khoản CSSX', icon: Icons.manage_accounts_sharp),
    //   ],
    // ),
    _MenuCategory(
      title: 'Quản lý quy trình',
      items: [
        // _MenuItem(id: 3, title: 'Quản lý quy trình chế biến', icon: Icons.change_circle_outlined),
        // _MenuItem(id: 4, title: 'QL sản phẩm - phụ gia', icon: Icons.medication),
        // _MenuItem(id: 5, title: 'Tiếp nhận nguyên liệu', icon: Icons.downloading_sharp),
        _MenuItem(id: 6, title: 'Quét QR thêm lịch sử chế biến cho lô hàng', icon: Icons.qr_code_scanner),
      ],
    ),
    // _MenuCategory(
    //   title: 'Quản lý thành phẩm',
    //   items: [
    //     _MenuItem(id: 8, title: 'Đóng gói thành phẩm', icon: Icons.pages_outlined),
    //     _MenuItem(id: 9, title: 'Phân phối đại lý', icon: Icons.local_shipping),
    //   ],
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menuCategories.length,
        itemBuilder: (context, categoryIndex) {
          final category = menuCategories[categoryIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
              ...category.items
                  .asMap()
                  .entries
                  .map((entry) {
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 3,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        switch (item.id) {
                          case 1:
                            context.push('/cssx-management');
                            break;
                          case 2:
                            context.push('/cssx-account-management');
                            break;
                          case 3:
                            context.push('/production-process-management');
                            break;
                          case 4:
                            context.push('/additive-products-management');
                            break;
                          case 5:
                            context.push('/reception-management');
                            break;
                          case 6:
                            // context.push('/processing-management');
                            context.push('/scan-qr-cssx');
                            break;
                          case 7:
                            context.push('/finished-product-log');
                            break;
                          case 8:
                            context.push('/packaging-management');
                            break;
                          case 9:
                            context.push('/transport-cssx-management');
                            break;
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.green[700],
                            size: 24,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.green[300],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

  class _MenuItem {
  final int id;
  final String title;
  final IconData icon;

  const _MenuItem({required this.id, required this.title, required this.icon});
  }

  class _MenuCategory {
  final String title;
  final List<_MenuItem> items;

  const _MenuCategory({required this.title, required this.items});
  }
