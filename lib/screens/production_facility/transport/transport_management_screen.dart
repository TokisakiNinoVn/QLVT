import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:txng/services/production_facility/transport_service.dart';

class TransportManagementCSSXScreen extends StatefulWidget {
  const TransportManagementCSSXScreen({super.key});

  @override
  State<TransportManagementCSSXScreen> createState() => _TransportManagementCSSXScreenState();
}

class _TransportManagementCSSXScreenState extends State<TransportManagementCSSXScreen> {
  final TransportService _transportService = TransportService();
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

  /// Loads transport data from the service
  Future<void> _loadListTransport() async {
    setState(() => _isLoading = true);
    try {
      final response = await _transportService.getAllTransportService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listTransports = List<Map<String, dynamic>>.from(rawData);
          filteredTransports = listTransports;
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar("Dữ liệu không đúng định dạng");
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi khi tải dữ liệu: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Filters transports based on search query
  void _filterTransports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTransports = listTransports.where((transport) {
        final madonvan = transport["madonvan"]?.toString().toLowerCase() ?? '';
        final maconghang = transport["maconghang"]?.toString().toLowerCase() ?? '';
        return madonvan.contains(query) || maconghang.contains(query);
      }).toList();
    });
  }

  /// Formats date string to dd/MM/yyyy HH:mm
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  /// Shows error message in a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Displays QR code in a dialog
  void _showQRCodeDialog(String qrCodeUrl) {
    if (qrCodeUrl.isEmpty) {
      _showErrorSnackBar("Không có QR code để hiển thị");
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
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
                        color: Colors.blueGrey,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Lỗi khi tải QR code',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 28,
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

  /// Displays transport details in a dialog
  void _showDetailDialog(Map<String, dynamic> transport) {
    final products = _parseProducts(transport['sanpham']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Chi tiết đơn vận ${transport['madonvan'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Mã đơn vận', transport['madonvan'] ?? '-'),
                _buildDetailRow('Mã công hàng', transport['maconghang'] ?? '-'),
                _buildDetailRow('Điểm gửi', transport['madiemgui']?.toString() ?? '-'),
                _buildDetailRow('Điểm nhận', transport['madiemnhan']?.toString() ?? '-'),
                _buildDetailRow('Tài xế', transport['mataixe']?.toString() ?? '-'),
                _buildDetailRow('Trạng thái', _formatStatus(transport['trangthai'] ?? '-')),
                _buildDetailRow('Ngày gửi', _formatDate(transport['ngaygui'])),
                _buildDetailRow('Ngày nhận', _formatDate(transport['ngaynhan'])),
                _buildDetailRow('Mã xe', transport['maxe']?.toString() ?? '-'),
                _buildDetailRow('Ghi chú', transport['ghichu'] ?? '-'),
                _buildDetailRow('Ngày tạo', _formatDate(transport['created_at'])),
                _buildDetailRow('Ngày cập nhật', _formatDate(transport['updated_at'])),
                const SizedBox(height: 16),
                const Text(
                  'Sản phẩm:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (products.isEmpty)
                  const Text(
                    'Không có sản phẩm',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                else
                  ...products.map((product) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Mã sản phẩm kho', product['spkho_id']?.toString() ?? '-'),
                        _buildDetailRow('Số lượng', product['soluong']?.toString() ?? '-'),
                        _buildDetailRow('Ghi chú SP', product['ghichu'] ?? '-'),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Colors.blueGrey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Parses JSON string of products safely
  List<dynamic> _parseProducts(String? jsonString) {
    try {
      return jsonDecode(jsonString ?? '[]') as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  /// Builds a row for detail display
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats transport status
  String _formatStatus(String status) {
    switch (status) {
      case 'dang_van_chuyen':
        return 'Đang vận chuyển';
      case 'da_giao':
        return 'Đã giao';
      case 'huy':
        return 'Đã hủy';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  /// Builds a card for each transport
  Widget _buildTransportCard(Map<String, dynamic> transport) {
    final products = _parseProducts(transport['sanpham']);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Mã đơn: ${transport['madonvan'] ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showQRCodeDialog(transport['qrcode'] ?? ''),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.blueGrey,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Trạng thái: ${_formatStatus(transport['trangthai'] ?? '-')}',
              style: TextStyle(
                color: transport['trangthai'] == 'dang_van_chuyen'
                    ? Colors.orange
                    : transport['trangthai'] == 'da_giao'
                    ? Colors.green
                    : Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày gửi: ${_formatDate(transport['ngaygui'])}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Số lượng SP: ${products.length}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showDetailDialog(transport),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Xem chi tiết', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles bottom navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _isSearching = false;
        _searchController.clear();
        _loadListTransport();
      } else if (index == 1) {
        _isSearching = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(FocusNode());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    hintText: "Tìm theo mã đơn, mã công hàng",
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
                  "Phân phối đại lý",
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
                          filteredTransports = listTransports;
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
                    : RefreshIndicator(
                  onRefresh: _loadListTransport,
                  color: Colors.blueGrey[600],
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filteredTransports.length,
                    itemBuilder: (context, index) {
                      final transport = filteredTransports[index];
                      return _buildTransportCard(transport);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => context.go('/transport-cssx-management/create-transport-cssx'),
        onPressed: () async {
          final result = await context.push('/transport-cssx-management/create-transport-cssx');
          if (result == true) {
            _loadListTransport();
          }
        } ,
        tooltip: 'Thêm đơn vận mới',
        backgroundColor: Colors.blueGrey[700],
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh_outlined),
            label: 'Làm mới',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
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