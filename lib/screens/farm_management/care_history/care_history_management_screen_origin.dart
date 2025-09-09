import 'package:flutter/material.dart';
import 'dart:async';

import 'package:txng/services/farm_management/care_history_service.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';

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

  void _showAccountDetails(Map<String, dynamic> listCareHistory) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text(
                    "Chi tiết lịch sử chăm sóc",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Đóng',
                    ),
                  ],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  shadowColor: Colors.black26,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        "Hoạt động",
                        listCareHistory["tenhoatdong"]?.toString() ??
                            "Không có",
                        isTitle: true,
                        icon: Icons.task_alt,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        "Sản phẩm sử dụng",
                        _getProductName(
                          listCareHistory["sanphamsudung"]?.toString(),
                        ),
                        icon: Icons.science,
                      ),
                      _buildDetailItem(
                        "Nhà cung cấp",
                        listCareHistory["nhacungcap"]?["tencungcap"]
                                ?.toString() ??
                            "Không có",
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        "Ghi chú",
                        listCareHistory["ghichu"]?.toString() ?? "Không có",
                        isMultiline: true,
                        icon: Icons.note,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        "Ngày tạo",
                        _formatDate(listCareHistory["created_at"]?.toString()),
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        "Ngày cập nhật",
                        _formatDate(listCareHistory["updated_at"]?.toString()),
                        icon: Icons.update,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String? value, {
    bool isTitle = false,
    bool isMultiline = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: isTitle ? 18 : 16,
                fontWeight: isTitle ? FontWeight.w600 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Text(
            value ?? 'Không có',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              height: isMultiline ? 1.4 : null,
            ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getProductName(String? productId) {
    if (productId == null || productId.isEmpty) return "Không có";
    final product = listFertilizerMedicine.firstWhere(
      (item) => item['id'].toString() == productId,
      orElse: () => {'tensanpham': 'Không xác định'},
    );
    return product['tensanpham']?.toString() ?? 'Không xác định';
  }

  void _showEditDialog(Map<String, dynamic> listCareHistory) {
    final TextEditingController hoatDongController = TextEditingController(
      text: listCareHistory['tenhoatdong']?.toString(),
    );
    final TextEditingController moTaController = TextEditingController(
      text: listCareHistory['ghichu']?.toString(),
    );
    String? selectedFertilizerId = listCareHistory['masp']?.toString();
    String? selectedProcessId = listCareHistory['maquytrinh']?.toString();
    String? _selectedSupplierId = listCareHistory['manhacungcap']?.toString();

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      title: const Text("Chỉnh sửa lịch sử chăm sóc"),
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value:
                                listCareHistory['maquytrinh']?.toString() ==
                                        selectedProcessId
                                    ? selectedProcessId
                                    : null,
                            decoration: InputDecoration(
                              labelText: 'Quy trình chăm sóc*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Chưa chọn'),
                              ),
                              ...listCareProcess.map(
                                (item) => DropdownMenuItem(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['hoatdong']?.toString() ??
                                        'Không có tên',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedProcessId = value;
                                final process = listCareProcess.firstWhere(
                                  (p) => p['id'].toString() == value,
                                  orElse: () => {'hoatdong': ''},
                                );
                                hoatDongController.text =
                                    process['hoatdong']?.toString() ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedSupplierId,
                            decoration: InputDecoration(
                              labelText: 'Nhà cung cấp',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              prefixIcon: Icon(
                                Icons.store,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Chưa chọn',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ...listSupplier.map(
                                (item) => DropdownMenuItem(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['tennhacungcap']?.toString() ??
                                        'Không có tên',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged:
                                (value) =>
                                    setState(() => _selectedSupplierId = value),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            style: const TextStyle(fontSize: 16),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value:
                                listFertilizerMedicine.any(
                                      (item) =>
                                          item['id'].toString() ==
                                          selectedFertilizerId,
                                    )
                                    ? selectedFertilizerId
                                    : null,
                            decoration: InputDecoration(
                              labelText: 'Sản phẩm sử dụng',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              // fillColor: Colors.black,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Chưa chọn'),
                              ),
                              ...listFertilizerMedicine.map(
                                (item) => DropdownMenuItem(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['tensanpham']?.toString() ??
                                        'Không có tên',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                            onChanged:
                                (value) => setState(
                                  () => selectedFertilizerId = value,
                                ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: moTaController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Ghi chú',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("Hủy"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                if (selectedProcessId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Vui lòng chọn quy trình chăm sóc",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  final response = await _listCareHistoryService
                                      .updateCareHistoryService(
                                        listCareHistory["id"],
                                        {
                                          "quytrinh_id": selectedProcessId,
                                          "tenhoatdong":
                                              hoatDongController.text,
                                          "sanphamsudung": selectedFertilizerId,
                                          "ghichu": moTaController.text,
                                          "_method": "PUT",
                                        },
                                      );

                                  if (response["status"] == true ||
                                      response["code"] == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Cập nhật thành công!"),
                                      ),
                                    );
                                    _loadCareHistoryes();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Cập nhật thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Lỗi khi cập nhật: $e"),
                                    ),
                                  );
                                } finally {
                                  setState(() => _isLoading = false);
                                  Navigator.pop(dialogContext);
                                }
                              },
                              child: const Text("Lưu"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showAddDialog() {
    final TextEditingController hoatDongController = TextEditingController();
    final TextEditingController moTaController = TextEditingController();
    String? selectedFertilizerId;
    String? selectedProcessId;
    String? _selectedSupplierId;
    bool _isLoading = false;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      title: const Text(
                        "Thêm lịch sử mới",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 24),
                          onPressed: () => Navigator.pop(dialogContext),
                          tooltip: 'Đóng',
                        ),
                      ],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      shadowColor: Colors.black26,
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedProcessId,
                            decoration: InputDecoration(
                              labelText: 'Quy trình chăm sóc',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              prefixIcon: Icon(
                                Icons.agriculture,
                                color: Colors.black,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items:
                                listCareProcess
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: Text(
                                          item['hoatdong']?.toString() ??
                                              'Không có tên',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedProcessId = value;
                                final process = listCareProcess.firstWhere(
                                  (p) => p['id'].toString() == value,
                                  orElse: () => {'hoatdong': ''},
                                );
                                hoatDongController.text =
                                    process['hoatdong']?.toString() ?? '';
                              });
                            },
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            style: const TextStyle(fontSize: 16),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedSupplierId,
                            decoration: InputDecoration(
                              labelText: 'Nhà cung cấp',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              prefixIcon: Icon(
                                Icons.store,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Chưa chọn',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ...listSupplier.map(
                                (item) => DropdownMenuItem(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['tennhacungcap']?.toString() ??
                                        'Không có tên',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged:
                                (value) =>
                                    setState(() => _selectedSupplierId = value),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            style: const TextStyle(fontSize: 16),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: selectedFertilizerId,
                            decoration: InputDecoration(
                              labelText: 'Sản phẩm sử dụng',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              prefixIcon: Icon(
                                Icons.science,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Không chọn',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ...listFertilizerMedicine.map(
                                (item) => DropdownMenuItem(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['tensanpham']?.toString() ??
                                        'Không có tên',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged:
                                (value) => setState(
                                  () => selectedFertilizerId = value,
                                ),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            style: const TextStyle(fontSize: 16),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: moTaController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Mô tả',
                              alignLabelWithHint: true,
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              prefixIcon: Icon(
                                Icons.description,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                "Hủy",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                elevation: 2,
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () async {
                                        if (selectedProcessId == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                "Vui lòng chọn quy trình chăm sóc",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() => _isLoading = true);
                                        try {
                                          final response =
                                              await _listCareHistoryService
                                                  .createCareHistoryService({
                                                    "quytrinh_id":
                                                        selectedProcessId,
                                                    "tenhoatdong":
                                                        hoatDongController.text,
                                                    "sanphamsudung":
                                                        selectedFertilizerId,
                                                    "ghichu":
                                                        moTaController.text,
                                                  });

                                          if (response["status"] == true ||
                                              response["code"] == 200) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Thêm mới thành công!",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            );
                                            _loadCareHistoryes();
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Lỗi khi thêm mới: $e",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        } finally {
                                          setState(() => _isLoading = false);
                                          Navigator.pop(dialogContext);
                                        }
                                      },
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        "Thêm",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
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

  void _confirmDelete(Map<String, dynamic> listCareHistory) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: const Text("Xác nhận xóa"),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Bạn có chắc chắn muốn xóa lịch sử chăm sóc '${listCareHistory["tenhoatdong"]}' không?",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text("Hủy"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onError,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              setState(() => _isLoading = true);
                              try {
                                final response = await _listCareHistoryService
                                    .deleteCareHistoryService(
                                      listCareHistory["id"],
                                      {"_method": "DELETE"},
                                    );
                                if (response["status"] == true ||
                                    response["code"] == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Xóa lịch sử thành công."),
                                    ),
                                  );
                                  _loadCareHistoryes();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Lỗi khi xóa lịch sử: $e"),
                                  ),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                            child: const Text("Xóa"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử chăm sóc"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Text hiển thị tên vùng trồng
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Vùng trồng: ${widget.plantingArea?["tenvungtrong"] ?? "Vùng trồng"}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 80 : 0,
            child:
                _isSearchVisible
                    ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm theo tên hoặc mô tả',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).colorScheme.surfaceContainer,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredCareHistoryes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có lịch sử nào',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
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
                        final listCareHistory = filteredCareHistoryes[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showAccountDetails(listCareHistory),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          listCareHistory["tenhoatdong"]
                                                  ?.toString() ??
                                              'Không có tên',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton(
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                child: const Text('Chi tiết'),
                                                onTap:
                                                    () => Future.delayed(
                                                      Duration.zero,
                                                      () => _showAccountDetails(
                                                        listCareHistory,
                                                      ),
                                                    ),
                                              ),
                                              PopupMenuItem(
                                                child: const Text('Chỉnh sửa'),
                                                onTap:
                                                    () => Future.delayed(
                                                      Duration.zero,
                                                      () => _showEditDialog(
                                                        listCareHistory,
                                                      ),
                                                    ),
                                              ),
                                              PopupMenuItem(
                                                child: const Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onTap:
                                                    () => Future.delayed(
                                                      Duration.zero,
                                                      () => _confirmDelete(
                                                        listCareHistory,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  if (listCareHistory["ghichu"] != null &&
                                      listCareHistory["ghichu"]
                                          .toString()
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        listCareHistory["ghichu"].toString(),
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Làm mới',
              onPressed: _loadCareHistoryes,
            ),
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
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
        onPressed: _showAddDialog,
        tooltip: 'Thêm mới',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
