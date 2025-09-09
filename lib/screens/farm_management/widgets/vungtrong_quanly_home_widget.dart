import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txng/config/color_config.dart';

class VungTrongQuanlyScreen extends StatelessWidget {
  const VungTrongQuanlyScreen({super.key});

  final List<_MenuCategory> menuCategories = const [
    _MenuCategory(
      title: 'Thông Tin Trang Trại',
      items: [
        _MenuItem(id: 1, title: 'Thông tin trang trại', icon: Icons.map),
      ],
    ),
    _MenuCategory(
      title: 'Quản Lý Vùng Trồng',
      items: [
        _MenuItem(
          id: 2,
          title: 'Quản lý vùng trồng',
          icon: Icons.energy_savings_leaf,
        ),
        _MenuItem(
          id: 9,
          title: 'Quản lý nhà cung cấp',
          icon: Icons.shopping_cart,
        ),
        _MenuItem(
          id: 3,
          title: 'Quản lý tài khoản trang trại',
          icon: Icons.manage_accounts_sharp,
        ),
        _MenuItem(
          id: 4,
          title: 'Quản lý quy trình chăm sóc',
          icon: Icons.local_florist,
        ),
        _MenuItem(id: 5, title: 'Quản lý vật tư', icon: Icons.medication),
      ],
    ),
    _MenuCategory(
      title: 'Hậu Cần',
      items: [
        _MenuItem(id: 6, title: 'Thu hoạch – đóng gói', icon: Icons.inventory_2),
        _MenuItem(id: 7, title: 'Đóng công', icon: Icons.pages_outlined),
        _MenuItem(id: 8, title: 'Vận chuyển', icon: Icons.local_shipping),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.background,
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final category = menuCategories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorConfig.deepGreen,
                        ),
                      ),
                    ),
                    ...category.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Card(
                        elevation: 2,
                        shadowColor: ColorConfig.cardPlaceholder,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: ColorConfig.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: ColorConfig.secondary.withOpacity(0.2),
                          onTap: () {
                            switch (item.id) {
                              case 1:
                                context.push('/farm-management');
                                break;
                              case 2:
                                context.push('/planting-area-management');
                                break;
                              case 3:
                                context.push('/account-management');
                                break;
                              case 4:
                                context.push('/care-process-management');
                                break;
                              case 5:
                                context.push('/fertilizer-medicine-management');
                                break;
                              case 6:
                                context.push('/harvest-packaging-management');
                                break;
                              case 7:
                                context.push('/container-management');
                                break;
                              case 8:
                                context.push('/transport-management');
                                break;
                              case 9:
                                context.push('/supplier-management');
                                break;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  ColorConfig.white,
                                  ColorConfig.extraLightGreen,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColorConfig.lightGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: ColorConfig.primary,
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConfig.textPrimary,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: ColorConfig.secondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                );
              },
              childCount: menuCategories.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
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