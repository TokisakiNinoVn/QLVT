import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../services/farm_management/transport_service.dart';

class TransportManagementScreen extends StatefulWidget {
  const TransportManagementScreen({super.key});

  @override
  State<TransportManagementScreen> createState() =>
      _TransportManagementScreenState();
}

class _TransportManagementScreenState extends State<TransportManagementScreen> {
  static final TransportService _transportService = TransportService();
  List<Map<String, dynamic>> listTransports = [];
  List<Map<String, dynamic>> filteredTransports = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListTransport();
    _searchController.addListener(_filterTransports);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTransports);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListTransport() async {
    try {
      final response = await _transportService.getAllTransportService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listTransports = List<Map<String, dynamic>>.from(rawData);
          filteredTransports = listTransports;
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

  void _filterTransports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTransports = listTransports.where((transport) {
        return (transport["madonvan"]?.toLowerCase().contains(query) ?? false) ||
            (transport["malohang"]?.toLowerCase().contains(query) ?? false) ||
            (transport["soluong"]?.toLowerCase().contains(query) ?? false);
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildTransportCard(Map<String, dynamic> transport) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Add navigation to detail screen if needed
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
                    'Mã đơn vận: ${transport["madonvan"] ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Chip(
                    label: Text(
                      // transport["trangthai"] == 'da_giao' ? 'Đang vận chuyển' : transport["trangthai"] ?? '-',
                      transport["trangthai"] == 'da_giao' ? 'Đã giao' : 'Đang vận chuyển' ??  'Chưa giao',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: transport["trangthai"] == 'dang_van_chuyen'
                        ? Colors.blue
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Lô hàng: ${transport["maconghang"] ?? '-'}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Row(
              //   children: [
              //     const Icon(Icons.scale, size: 20, color: Colors.grey),
              //     const SizedBox(width: 8),
              //     Text(
              //       'Khối lượng: ${transport["soluong"] ?? '-'}',
              //       style: const TextStyle(fontSize: 14, color: Colors.black87),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày gửi: ${_formatDate(transport["ngaygui"])}',
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
                      if (transport["qrcode"] != null) {
                        _showQRCodeDialog(transport["qrcode"]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Không có QR code cho đơn vận này"),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    tooltip: 'Xem QR code',
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.edit, color: Colors.green),
                  //   onPressed: () {
                  //     context.go('');
                  //   },
                  //   tooltip: 'Sửa đơn vận',
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () {},
                  //   tooltip: 'Xóa đơn vận',
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
        _loadListTransport();
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
                    hintText: "Tìm theo mã đơn, mã lô, khối lượng",
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
                  "Quản lý đơn vận",
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
                    onPressed: _loadListTransport,
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
                    : filteredTransports.isEmpty
                    ? Center(
                  child: Text(
                    "Không có dữ liệu đơn vận.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filteredTransports.length,
                  itemBuilder: (context, index) {
                    final transport = filteredTransports[index];
                    return _buildTransportCard(transport);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/transport-management/create');
          if (result == true) {
            _loadListTransport();
          }
        } ,
        tooltip: 'Thêm mới',
        backgroundColor: Colors.blueGrey[700],
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh),
              label: 'Làm mới'),
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