import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../services/farm_management/container_service.dart';

class ContainerManagementScreen extends StatefulWidget {
  const ContainerManagementScreen({super.key});

  @override
  State<ContainerManagementScreen> createState() =>
      _ContainerManagementScreenState();
}

class _ContainerManagementScreenState extends State<ContainerManagementScreen> {
  static final ContainerService _containerService = ContainerService();
  List<Map<String, dynamic>> listContainers = [];
  List<Map<String, dynamic>> filteredContainers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListContainer();
    _searchController.addListener(_filterContainers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContainers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListContainer() async {
    try {
      final response = await _containerService.getAllContainerService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listContainers = List<Map<String, dynamic>>.from(rawData);
          filteredContainers = listContainers;
          _isLoading = false;
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterContainers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredContainers = listContainers.where((container) {
        // Tìm kiếm theo maconghang, lohang, và khoiluong
        final maCongHang = container["maconghang"]?.toLowerCase() ?? '';
        final khoiLuong = container["khoiluong"]?.toString().toLowerCase() ?? '';
        // Xử lý lohang là chuỗi JSON hoặc danh sách
        String loHang = '';
        if (container["lohang"] is String) {
          loHang = container["lohang"].toLowerCase();
        } else if (container["lohang"] is List) {
          loHang = (container["lohang"] as List).join(',').toLowerCase();
        }
        return maCongHang.contains(query) ||
            loHang.contains(query) ||
            khoiLuong.contains(query);
      }).toList();
    });
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  void _showQRCodeDialog(String qrCodeUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  qrCodeUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Lỗi khi tải QR code',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContainerCard(Map<String, dynamic> container) {
    // Xử lý lohang để hiển thị
    String loHangDisplay = '';
    if (container["lohang"] is String) {
      try {
        loHangDisplay = (jsonDecode(container["lohang"]) as List).join(', ');
      } catch (_) {
        loHangDisplay = container["lohang"];
      }
    } else if (container["lohang"] is List) {
      loHangDisplay = (container["lohang"] as List).join(', ');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Thêm điều hướng đến màn hình chi tiết nếu cần
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mã công hàng: ${container["maconghang"] ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),


                ],
              ),
              // Chip(
              //   label: Text(
              //     container["trangthai"] == 'dang_van_chuyen' ? 'Đang vận chuyển' : container["trangthai"]?.toUpperCase() ?? '-',
              //     style: const TextStyle(color: Colors.white, fontSize: 12),
              //   ),
              //   backgroundColor: container["trangthai"] == 'dang_van_chuyen'
              //       ? Colors.blue
              //       : Colors.grey,
              //   padding: const EdgeInsets.symmetric(horizontal: 5),
              // ),
              // const SizedBox(height: 8),
              // Row(
              //   children: [
              //     const Icon(Icons.inventory_2, size: 20, color: Colors.grey),
              //     const SizedBox(width: 8),
              //     Expanded(
              //       child: Text(
              //         'Lô hàng: ${loHangDisplay.isEmpty ? '-' : loHangDisplay}',
              //         style: const TextStyle(fontSize: 14, color: Colors.black87),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.scale, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Khối lượng: ${container["khoiluong"] ?? '-'} kg',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày tạo: ${_formatDate(container["created_at"])}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.blueGrey),
                    onPressed: () {
                      if (container["qrcode"] != null) {
                        _showQRCodeDialog(container["qrcode"]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Không có QR code cho công hàng này"),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    tooltip: 'Xem QR code',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      context.go('/container-management/container-update/${container["id"]}', extra: container);
                    },
                    tooltip: 'Sửa công hàng',
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () {},
                  //   tooltip: 'Xóa công hàng',
                  // ),
                ],
              ),
            ],
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
        // context.go("/container-management/create");
        _loadListContainer();
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
                    hintText: "Tìm theo mã công hàng, mã lô, khối lượng",
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
                  "Quản lý công hàng",
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
                    onPressed: _loadListContainer,
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
                    : filteredContainers.isEmpty
                    ? Center(
                  child: Text(
                    "Không có dữ liệu công hàng.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filteredContainers.length,
                  itemBuilder: (context, index) {
                    final container = filteredContainers[index];
                    return _buildContainerCard(container);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/container-management/create-container');
          if (result == true) {
            _loadListContainer();
          };
        },
        tooltip: 'Thêm mới',
        backgroundColor: Colors.blueGrey[700],
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Tải lại'),
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