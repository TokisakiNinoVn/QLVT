import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/farm_management/harvest_packaging_service.dart';

class HarvestPackagingManagementScreen extends StatefulWidget {
  const HarvestPackagingManagementScreen({super.key});

  @override
  State<HarvestPackagingManagementScreen> createState() =>
      _HarvestPackagingManagementScreenState();
}

class _HarvestPackagingManagementScreenState
    extends State<HarvestPackagingManagementScreen> {
  static final HarvestPackagingService _plantingareaService = HarvestPackagingService();
  List<Map<String, dynamic>> listPlantingareas = [];
  List<Map<String, dynamic>> filteredPlantingareas = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListHarvestPackaging();
    _searchController.addListener(_filterHarvestPackagings);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHarvestPackagings);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListHarvestPackaging() async {
    try {
      final response = await _plantingareaService.getAllHarvestPackagingService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listPlantingareas = List<Map<String, dynamic>>.from(rawData);
          filteredPlantingareas = listPlantingareas;
        });
      } else {
        setState(() {
          listPlantingareas = [];
          filteredPlantingareas = [];
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterHarvestPackagings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPlantingareas =
          listPlantingareas.where((area) {
            return (area["tenvungtrong"]?.toLowerCase().contains(query) ??
                    false) ||
                (area["chusohuu"]?.toLowerCase().contains(query) ?? false) ||
                (area["diachi"]?.toLowerCase().contains(query) ?? false) ||
                (area["masothue"]?.toLowerCase().contains(query) ?? false) ||
                (area["mavungtrong"]?.toLowerCase().contains(query) ?? false);
          }).toList();
    });
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw ?? '';
    }
  }

  Widget _buildHarvestPackagingCard(Map<String, dynamic> plantingArea) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // onTap: () => context.push('/planting-area-details', extra: plantingArea),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plantingArea["malohang"] ?? 'Không có mã lô hàng',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pages_sharp,
                        color: Colors.blueGrey[600],
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Sản phẩm: ${plantingArea["tensanpham"] ?? "Không có tên sản phẩm"}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 8),
                // Text(
                //   "Ngày thu hoạch: ${plantingArea["ngaythuhoach"] ?? 'Chưa có'}",
                //   style: const TextStyle(fontSize: 14, color: Colors.black87),
                // ),
                Text(
                  "Khối lượng: ${plantingArea["khoiluong"] ?? 'Chưa có'} Kg",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                // Text(
                //   "Trạng thái: ${plantingArea["trangthai"] == 'dang_su_dung' ? 'Đang sử dụng': 'Trống'}",
                //   style: const TextStyle(fontSize: 14, color: Colors.black87),
                // ),
                // Text(
                //   "Trạng thái: ${plantingArea["trangthai"] == 'dang_su_dung' ? 'Đang sử dụng' : (plantingArea["trangthai"] == 'trong' ? 'Trống' : 'Không xác định')}",
                //   style: const TextStyle(fontSize: 14, color: Colors.black87),
                // ),

                Text(
                  "Ngày thu hoạch: ${_formatDate(plantingArea["ngaythuhoach"])}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                // const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // IconButton(
                    //   icon: Icon(Icons.visibility, color: Colors.blueGrey[600]),
                    //   tooltip: 'Xem chi tiết',
                    //   onPressed: () {
                    //     context.push(
                    //       '/planting-area-management/planting-area-details',
                    //       extra: plantingArea,
                    //     );
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Chỉnh sửa',
                      onPressed: () {
                        context.push(
                          '/harvest-packaging-management/update-harvest-packaging/${plantingArea["malohang"]}'
                        );
                      },
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.delete, color: Colors.redAccent),
                    //   tooltip: 'Xóa',
                    //   onPressed: () {
                    //     showDialog(
                    //       context: context,
                    //       builder:
                    //           (context) => AlertDialog(
                    //             title: const Text('Xác nhận xóa'),
                    //             content: const Text(
                    //               'Bạn có chắc muốn xóa vùng trồng này?',
                    //             ),
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12),
                    //             ),
                    //             actions: [
                    //               TextButton(
                    //                 onPressed: () => Navigator.pop(context),
                    //                 child: const Text(
                    //                   'Hủy',
                    //                   style: TextStyle(color: Colors.grey),
                    //                 ),
                    //               ),
                    //               TextButton(
                    //                 onPressed: () {
                    //                   // _deleteHarvestPackagingService(
                    //                   //   plantingArea["id"],
                    //                   // );
                    //                   // _loadListHarvestPackaging();
                    //                   Navigator.pop(context);
                    //                 },
                    //                 child: const Text(
                    //                   'Xóa',
                    //                   style: TextStyle(color: Colors.redAccent),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _isSearching = false;
        _searchController.clear();
        context.go("/harvest-packaging-management/harvest-packaging-qr-update");
      } else if (index == 1) {
        _isSearching = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7EF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: _isSearching
                    ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Tìm theo mã lô, tên sản phẩm, ngày thu hoạch, khối lượng",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                )
                    : const Text(
                  "QL đóng gói - Thu hoạch",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 26,
                      color: Colors.blueGrey[600],
                    ),
                    onPressed: _loadListHarvestPackaging,
                    tooltip: 'Làm mới',
                  ),
                  if (!_isSearching)
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 26,
                        color: Colors.blueGrey[600],
                      ),
                      onPressed: () => setState(() => _isSearching = true),
                      tooltip: 'Tìm kiếm',
                    ),
                  if (_isSearching)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 26,
                        color: Colors.blueGrey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                      },
                      tooltip: 'Hủy tìm kiếm',
                    ),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueGrey[600],
                  ),
                )
                    : filteredPlantingareas.isEmpty
                    ? Center(
                  child: Text(
                    "Không có dữ liệu lô hàng.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filteredPlantingareas.length,
                  itemBuilder: (context, index) {
                    final harvestPackaging = filteredPlantingareas[index];
                    return _buildHarvestPackagingCard(harvestPackaging);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => context.go('/harvest-packaging-management/harvest-packaging-qr'),
        onPressed: () async {
          final result = await context.push('/harvest-packaging-management/harvest-packaging-qr');

          if (result == true) {
            _loadListHarvestPackaging();
          }
        },
        tooltip: 'Scan QR chi tiết lô hàng',
        backgroundColor: Colors.blueGrey[700],
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Cập nhật qua QR'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 4,
        onTap: _onItemTapped,
      ),
    );
  }
}
