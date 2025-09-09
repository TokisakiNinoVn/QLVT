import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:txng/services/farm_management/care_history_service.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';
import '../../../config/color_config.dart';
import '../../../helpers/format_helper.dart';
import './dialogs.dart';

class CareHistoryManagementScreen extends StatefulWidget {
  final int id;
  final Map<String, dynamic>? plantingArea;
  const CareHistoryManagementScreen({
    super.key,
    required this.id,
    this.plantingArea,
  });

  @override
  State<CareHistoryManagementScreen> createState() => _CareHistoryScreenState();
}

class _CareHistoryScreenState extends State<CareHistoryManagementScreen> {
  static final CareHistoryService _listCareHistoryService =
      CareHistoryService();
  static final FertilizerMedicineService _listFertilizerMedicineService =
      FertilizerMedicineService();
  static final CareProcessService _listCareProcessService =
      CareProcessService();

  late List<Map<String, dynamic>> listCareHistoryes = [];
  late List<Map<String, dynamic>> filteredCareHistoryes = [];
  late List<Map<String, dynamic>> listFertilizerMedicine = [];
  late List<Map<String, dynamic>> listCareProcess = [];
  late List<Map<String, dynamic>> listSupplier = [];

  bool _isLoading = true;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCareHistoryes();
    _loadFertilizerMedicine();
    _loadCareProcess();
    _loadSupplier();
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredCareHistoryes =
            listCareHistoryes.where((history) {
              final searchText = _searchController.text.toLowerCase();
              return (history['tenhoatdong']?.toString().toLowerCase() ?? '')
                      .contains(searchText) ||
                  (history['ghichu']?.toString().toLowerCase() ?? '').contains(
                    searchText,
                  );
            }).toList();
      });
    });
  }

  Future<void> _loadCareHistoryes() async {
    try {
      setState(() => _isLoading = true);
      final response = await _listCareHistoryService
          .getAllCareHistoryByFarmIdService(widget.id);
      final rawData = response["data"]?["lichsuchamsoc"];

      if (rawData is List) {
        setState(() {
          listCareHistoryes =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          filteredCareHistoryes = List.from(listCareHistoryes);
        });
      } else {
        setState(() {
          listCareHistoryes = [];
          filteredCareHistoryes = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSupplier() async {
    final response = await _listCareHistoryService.getListSupplierService();
    final rawData = response["data"]?["data"];
    try {
      if (rawData is List) {
        setState(() {
          listSupplier =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
        });
      } else {
        setState(() => listSupplier = []);
      }
    } catch (e) {
      print("Lỗi khi tải nhà cung cấp: $e");
    }
  }

  Future<void> _loadCareProcess() async {
    try {
      final response = await _listCareProcessService.getAllCareProcessService();
      final rawData = response["data"]?["quytrinhchamsocs"];

      if (rawData is List) {
        setState(() {
          listCareProcess =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
        });
      } else {
        setState(() => listCareProcess = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải quy trình chăm sóc: $e")),
      );
      print("Lỗi khi tải quy trình chăm sóc: $e");
    }
  }

  Future<void> _loadFertilizerMedicine() async {
    try {
      final response =
          await _listFertilizerMedicineService
              .getAllFertilizerMedicineService();
      final rawData = response["data"]?["phanbon_thuocs"]?["data"];
      if (rawData is List) {
        setState(() {
          listFertilizerMedicine =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
        });
      } else {
        setState(() => listFertilizerMedicine = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải sản phẩm: $e")));
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw;
    }
  }

  String _getProductName(String? productId) {
    if (productId == null || productId.isEmpty) return "Không có";
    final product = listFertilizerMedicine.firstWhere(
      (item) => item['id'].toString() == productId,
      orElse: () => {'tensanpham': 'Không xác định'},
    );
    return product['tensanpham']?.toString() ?? 'Không xác định';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử chăm sóc"),
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Center(
              child: Text(
                'Vùng trồng: ${widget.plantingArea?["tenvungtrong"] ?? "Vùng trồng"}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 70 : 0,
            child: _isSearchVisible
                ? Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: '🔍 Tìm kiếm...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCareHistoryes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Không có lịch sử nào',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredCareHistoryes.length,
              itemBuilder: (context, index) {
                final item = filteredCareHistoryes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onTap: () => showAccountDetails(
                      context,
                      item,
                      _getProductName,
                      _formatDate,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: ColorConfig.secondary,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: ColorConfig.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item["tenhoatdong"]?.toString() ?? 'Không có tên',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          FormatHelper.formatDateTime('${item["created_at"]}'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        if (item["ghichu"] != null &&
                            item["ghichu"].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item["ghichu"].toString(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Chi tiết'),
                          onTap: () => Future.delayed(
                            Duration.zero,
                                () => showAccountDetails(
                              context,
                              item,
                              _getProductName,
                              _formatDate,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: const Text('Chỉnh sửa'),
                          onTap: () => Future.delayed(
                            Duration.zero,
                                () => showEditDialog(
                              context,
                              item,
                              listCareProcess,
                              listSupplier,
                              listFertilizerMedicine,
                              _listCareHistoryService,
                              _loadCareHistoryes,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => Future.delayed(
                            Duration.zero,
                                () => confirmDelete(
                              context,
                              item,
                              _listCareHistoryService,
                              _loadCareHistoryes,
                            ),
                          ),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Làm mới',
              onPressed: _loadCareHistoryes,
            ),
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              tooltip: 'Tìm kiếm',
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                    filteredCareHistoryes = List.from(listCareHistoryes);
                  }
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(
            '/create-care-history/${widget.id}',
            extra: widget.plantingArea,
          );
        },
        tooltip: 'Thêm mới',
        backgroundColor: ColorConfig.selectedItemColor,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, size: 32, color: ColorConfig.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

}
