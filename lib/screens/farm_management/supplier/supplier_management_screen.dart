import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:txng/config/color_config.dart';
import '../../../helpers/snackbar_helper.dart';
import '../../../services/farm_management/supplier_service.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() =>
      _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  static final SupplierService _supplierService = SupplierService();
  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> filteredSuppliers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Map<String, dynamic>? selectedSupplier;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _filterSuppliers);
  }

  Future<void> _loadSuppliers() async {
    try {
      final response = await _supplierService.getAllSupplierService();
      final rawData = response["data"]?["data"];

      if (rawData is List) {
        setState(() {
          suppliers = rawData.map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item)).toList();
          _filterSuppliers();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSuppliers() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        final name = supplier['tennhacungcap']?.toString().toLowerCase() ?? '';
        final phone = supplier['sodienthoai']?.toString().toLowerCase() ?? '';
        return name.contains(searchTerm) || phone.contains(searchTerm);
      }).toList();
    });
  }

  void _showSupplierDetails(Map<String, dynamic> supplier) {
    setState(() => selectedSupplier = supplier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Thông tin nhà cung cấp",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (supplier["chungchi"] != null)
                  Center(
                    child: GestureDetector(
                      onTap: () => _showFullImage(supplier["chungchi"]),
                      child: Hero(
                        tag: "image-${supplier["id"]}",
                        child: Image.network(
                          supplier["chungchi"],
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildDetail("Tên nhà cung cấp", supplier["tennhacungcap"]),
                _buildDetail("Mã số thuế", supplier["masothue"]),
                _buildDetail("Địa chỉ", supplier["diachi"]),
                _buildDetail("Số điện thoại", supplier["sodienthoai"]),
                _buildDetail("Email", supplier["email"]),
                _buildDetail("Ngày tạo", _formatDate(supplier["created_at"])),
                _buildDetail(
                    "Cập nhật gần nhất", _formatDate(supplier["updated_at"])),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(
                            "/supplier-management/supplier-edit/${supplier['id']}");
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Chỉnh sửa"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(supplier);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Xóa"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "Không có")),
        ],
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Hero(
              tag: "image-${selectedSupplier?["id"]}",
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return "";
    try {
      final date = DateTime.parse(raw);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (_) {
      return raw;
    }
  }

  void _confirmDelete(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa '${supplier['tennhacungcap']}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final response = await _supplierService.deleteSupplierService(
                  supplier["id"],
                );
                if (response["status"] == true || response["code"] == 200) {
                  setState(() {
                    suppliers.removeWhere((e) => e["id"] == supplier["id"]);
                    _filterSuppliers();
                  });
                  SnackbarHelper.showSuccess(context, 'Xóa nhà cung cấp thành công!');
                } else {
                  SnackbarHelper.showError(context, "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}");
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi xóa: $e")),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Xóa"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý nhà cung cấp"),
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        actions: [
          IconButton(
            onPressed: _loadSuppliers,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => context.push("/supplier-management/create-supplier"),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Tìm kiếm theo tên hoặc số điện thoại",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSuppliers.isEmpty
                ? const Center(child: Text("Không có nhà cung cấp nào"))
                : ListView.builder(
              itemCount: filteredSuppliers.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (ctx, index) {
                final supplier = filteredSuppliers[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => _showSupplierDetails(supplier),
                    title: Text(
                      supplier["tennhacungcap"] ?? "Không rõ tên",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(supplier["sodienthoai"] ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.push(
                            '/supplier-management/edit-supplier/${supplier['id']}',
                            extra: supplier,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _confirmDelete(supplier),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
