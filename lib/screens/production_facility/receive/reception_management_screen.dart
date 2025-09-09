import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:txng/services/production_facility/reception_service.dart';

import '../../../config/color_config.dart';

class ReceptionManagementScreen extends StatefulWidget {
  const ReceptionManagementScreen({super.key});

  @override
  State<ReceptionManagementScreen> createState() =>
      _ReceptionManagementScreenState();
}

class _ReceptionManagementScreenState extends State<ReceptionManagementScreen> {
  static final ReceptionService _transportService = ReceptionService();
  List<Map<String, dynamic>> listReceptions = [];
  List<Map<String, dynamic>> filteredReceptions = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListReception();
    _searchController.addListener(_filterReceptions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterReceptions);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListReception() async {
    try {
      final response = await _transportService.getAllReceptionService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listReceptions = List<Map<String, dynamic>>.from(rawData);
          filteredReceptions = listReceptions;
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

  void _filterReceptions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredReceptions = listReceptions.where((reception) {
        return (reception["madonvan"]?.toLowerCase().contains(query) ?? false) ||
            (reception["maconghang"]?.toLowerCase().contains(query) ?? false);
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

  Widget _buildReceptionCard(Map<String, dynamic> reception) {
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
                    'Mã đơn vận: ${reception["madonvan"] ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Chip(
                    label: Text(
                      // reception["tinhtrang"] == 'du_hang' ? 'Đủ' : reception["tinhtrang"] ?? '-',
                      reception["tinhtrang"] == 'du_hang' ? 'Đủ' : 'Đủ' ?? '-',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: reception["tinhtrang"] == 'du'
                        ? Colors.green
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
                    'Mã container: ${reception["maconghang"] ?? '-'}',
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
                    'Ngày nhận: ${_formatDate(reception["created_at"])}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              if (reception["ghichu"] != null && reception["ghichu"].isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.note, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ghi chú: ${reception["ghichu"]}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
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
        // context.go("/transport-management/transport-create");
        _loadListReception();
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
                    hintText: "Tìm theo mã đơn, mã container",
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
                  "Tiếp nhận nguyên liệu",
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
                    onPressed: _loadListReception,
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
                    : filteredReceptions.isEmpty
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
                  itemCount: filteredReceptions.length,
                  itemBuilder: (context, index) {
                    final reception = filteredReceptions[index];
                    return _buildReceptionCard(reception);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => context.go('/reception-management/scan-qr'),
        onPressed: () async {
          final result = await context.push('/reception-management/scan-qr');
          if (result == true) {
            _loadListReception();
          }
        } ,
        tooltip: 'Thêm mới',
        backgroundColor: ColorConfig.selectedItemColor,
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
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