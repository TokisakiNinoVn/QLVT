import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/production_facility/production_process_service.dart';

import '../../../config/color_config.dart';

class ProductionProcessManagementScreen extends StatefulWidget {
  const ProductionProcessManagementScreen({super.key});

  @override
  State<ProductionProcessManagementScreen> createState() =>
      _ProductionProcesstScreenState();
}

class _ProductionProcesstScreenState
    extends State<ProductionProcessManagementScreen> {
  static final ProductionProcessService _listProductionProcessService =
      ProductionProcessService();
  static final FertilizerMedicineService _listFertilizerMedicineService =
      FertilizerMedicineService();
  late List<Map<String, dynamic>> listProductionProcesses = [];
  late List<Map<String, dynamic>> filteredProductionProcesses = [];
  late List<Map<String, dynamic>> listFertilizerMedicine = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProductionProcesses();
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
        filteredProductionProcesses =
            listProductionProcesses.where((account) {
              final searchText = _searchController.text.toLowerCase();
              return account['tenhoatdong'].toLowerCase().contains(searchText) ||
                  account['mota'].toLowerCase().contains(searchText);
            }).toList();
        filteredProductionProcesses.sort(
          (a, b) => a['sapxep'].compareTo(b['sapxep']),
        );
      });
    });
  }

  int _getNextOrderNumber() {
    if (listProductionProcesses.isEmpty) return 1;
    int maxOrder = listProductionProcesses
        .map((e) => e['sapxep'] as int)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  bool _isOrderNumberExist(int orderNumber, {int? excludeId}) {
    return listProductionProcesses.any(
      (process) =>
          process['sapxep'] == orderNumber &&
          (excludeId == null || process['id'] != excludeId),
    );
  }

  List<int> _getUsedOrderNumbers() {
    return listProductionProcesses
        .map<int>((e) => e['sapxep'] as int)
        .toSet()
        .toList()
      ..sort();
  }

  Future<void> _loadProductionProcesses() async {
    try {
      final response =
          await _listProductionProcessService.getAllProductionProcessService();
      final rawData = response["data"]?["quytrinhchebiens"];

      if (rawData is List) {
        setState(() {
          listProductionProcesses =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          listProductionProcesses.sort(
            (a, b) => a['sapxep'].compareTo(b['sapxep']),
          );
          filteredProductionProcesses = List.from(listProductionProcesses);
        });
      } else {
        setState(() {
          listProductionProcesses = [];
          filteredProductionProcesses = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? selectedAccount;

  void _showAccountDetails(Map<String, dynamic> listProductionProcess) {
    setState(() => selectedAccount = listProductionProcess);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text("Chi tiết quy trình chăm sóc"),
                  automaticallyImplyLeading: false,
                  backgroundColor: ColorConfig.primary,
                  foregroundColor: ColorConfig.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        'Hoạt động',
                        listProductionProcess["tenhoatdong"],
                        isTitle: true,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        'Mô tả',
                        listProductionProcess["mota"],
                        isMultiline: true,
                      ),
                      _buildDetailItem(
                        'Thứ tự',
                        listProductionProcess["sapxep"].toString(),
                      ),
                      _buildDetailItem(
                        'Mã vùng trồng',
                        listProductionProcess["mavungtrong"].toString(),
                      ),
                      _buildDetailItem(
                        'Ngày tạo',
                        _formatDate(listProductionProcess["created_at"]),
                      ),
                      _buildDetailItem(
                        'Ngày cập nhật',
                        _formatDate(listProductionProcess["updated_at"]),
                      ),
                      _buildDetailItem(
                        'Mã doanh nghiệp',
                        listProductionProcess["madoanhnghiep"].toString(),
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
    String value, {
    bool isTitle = false,
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTitle ? 18 : 14,
            fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTitle ? 18 : 16,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showEditDialog(Map<String, dynamic> listProductionProcess) {
    final TextEditingController hoatDongController = TextEditingController(
      text: listProductionProcess['tenhoatdong'],
    );
    final TextEditingController moTaController = TextEditingController(
      text: listProductionProcess['mota'],
    );
    int currentOrder = listProductionProcess['sapxep'] as int;

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
                      title: const Text("Chỉnh sửa quy trình chế biến"),
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
                          TextField(
                            controller: hoatDongController,
                            decoration: InputDecoration(
                              labelText: 'Hoạt động*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: moTaController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Mô tả',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Thứ tự:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 32,
                                ),
                                onPressed: () {
                                  if (currentOrder > 1) {
                                    setState(() => currentOrder--);
                                  }
                                },
                              ),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$currentOrder',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() => currentOrder++);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isOrderNumberExist(
                            currentOrder,
                            excludeId: listProductionProcess['id'],
                          ))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Số thứ tự $currentOrder đã được sử dụng',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              foregroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              final usedNumbers = _getUsedOrderNumbers();
                              showDialog(
                                context: context,
                                builder:
                                    (context) => Dialog(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppBar(
                                              title: const Text(
                                                'Chọn số thứ tự',
                                              ),
                                              automaticallyImplyLeading: false,
                                              actions: [
                                                IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 300,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: usedNumbers.length,
                                                itemBuilder: (context, index) {
                                                  final number =
                                                      usedNumbers[index];
                                                  return ListTile(
                                                    title: Text(
                                                      '$number',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    trailing:
                                                        number == currentOrder
                                                            ? const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                            : null,
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      setState(
                                                        () =>
                                                            currentOrder =
                                                                number,
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              );
                            },
                            child: const Text('Chọn từ danh sách có sẵn'),
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
                                if (_isOrderNumberExist(
                                  currentOrder,
                                  excludeId: listProductionProcess['id'],
                                )) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Số thứ tự đã tồn tại, vui lòng chọn số khác",
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                if (!mounted) return;
                                setState(() => _isLoading = true);

                                try {
                                  final response =
                                      await _listProductionProcessService
                                          .updateProductionProcessService(
                                            listProductionProcess["id"],
                                            {
                                              "tenhoatdong":
                                                  hoatDongController.text,
                                              "mota": moTaController.text,
                                              "sapxep": currentOrder,
                                              "_method": "PUT",
                                            },
                                          );

                                  // if (!mounted) return;
                                  if (response["status"] == true ||
                                      response["code"] == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Cập nhật thành công."),
                                      ),
                                    );

                                    setState(() {
                                      final index = listProductionProcesses
                                          .indexWhere(
                                            (acc) =>
                                                acc["id"] ==
                                                listProductionProcess["id"],
                                          );
                                      if (index != -1) {
                                        listProductionProcesses[index]["tenhoatdong"] =
                                            hoatDongController.text;
                                        listProductionProcesses[index]["mota"] =
                                            moTaController.text;
                                        listProductionProcesses[index]["sapxep"] =
                                            currentOrder;

                                        listProductionProcesses.sort(
                                          (a, b) => a['sapxep'].compareTo(
                                            b['sapxep'],
                                          ),
                                        );
                                        filteredProductionProcesses = List.from(
                                          listProductionProcesses,
                                        );
                                      }
                                    });
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
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Lỗi khi cập nhật: $e"),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                                Navigator.pop(dialogContext);
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
    int nextOrder = _getNextOrderNumber();
    final TextEditingController hoatDongController = TextEditingController();
    final TextEditingController moTaController = TextEditingController();
    int currentOrder = nextOrder;

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
                      title: const Text("Thêm quy trình mới"),
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
                          TextField(
                            controller: hoatDongController,
                            decoration: InputDecoration(
                              labelText: 'Hoạt động*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: moTaController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Mô tả',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Thứ tự:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 32,
                                ),
                                onPressed: () {
                                  if (currentOrder > 1) {
                                    setState(() => currentOrder--);
                                  }
                                },
                              ),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$currentOrder',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() => currentOrder++);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isOrderNumberExist(currentOrder))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Số thứ tự $currentOrder đã được sử dụng',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              foregroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              final usedNumbers = _getUsedOrderNumbers();
                              showDialog(
                                context: context,
                                builder:
                                    (context) => Dialog(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppBar(
                                              title: const Text(
                                                'Chọn số thứ tự',
                                              ),
                                              automaticallyImplyLeading: false,
                                              actions: [
                                                IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 300,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: usedNumbers.length,
                                                itemBuilder: (context, index) {
                                                  final number =
                                                      usedNumbers[index];
                                                  return ListTile(
                                                    title: Text(
                                                      '$number',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    trailing:
                                                        number == currentOrder
                                                            ? const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                            : null,
                                                    onTap: () {
                                                      // Navigator.pop(context);
                                                      // setState(() => currentOrder = number);
                                                      Navigator.pop(
                                                        context,
                                                        number,
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              );
                            },
                            child: const Text('Chọn từ danh sách có sẵn'),
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
                                if (hoatDongController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Vui lòng nhập tên hoạt động",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_isOrderNumberExist(currentOrder)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Số thứ tự đã tồn tại, vui lòng chọn số khác",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _isLoading = true);

                                try {
                                  final response =
                                      await _listProductionProcessService
                                          .createProductionProcessService({
                                            "tenhoatdong":
                                                hoatDongController.text,
                                            "mota": moTaController.text,
                                            "sapxep": currentOrder,
                                          });
                                  if (!mounted) return;
                                  if (response["status"] == true ||
                                      response["code"] == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Thêm mới thành công!"),
                                      ),
                                    );
                                    Navigator.pop(dialogContext);
                                    _loadProductionProcesses();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Lỗi khi thêm mới: $e"),
                                    ),
                                  );
                                } finally {
                                  if (!mounted) return;
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: const Text("Thêm"),
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

  void _confirmDelete(Map<String, dynamic> listProductionProcess) {
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
                      "Bạn có chắc chắn muốn xóa quy trình chăm sóc '${listProductionProcess["hoatdong"]}' không?",
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
                                final response =
                                    await _listProductionProcessService
                                        .deleteProductionProcessService(
                                          listProductionProcess["id"],
                                          {"_method": "DELETE"},
                                        );
                                if (response["status"] == true ||
                                    response["code"] == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Xóa quy trình thành công.",
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    listProductionProcesses.removeWhere(
                                      (acc) =>
                                          acc["id"] ==
                                          listProductionProcess["id"],
                                    );
                                    filteredProductionProcesses = List.from(
                                      listProductionProcesses,
                                    );
                                    filteredProductionProcesses.sort(
                                      (a, b) =>
                                          a['sapxep'].compareTo(b['sapxep']),
                                    );
                                  });
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
                                    content: Text("Lỗi khi xóa quy trình: $e"),
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
        title: const Text("Quy trình chế biến"),
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProductionProcesses,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddDialog,
            tooltip: 'Thêm quy trình',
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
                labelText: 'Tìm kiếm theo tên hoặc mô tả',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredProductionProcesses.isEmpty
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
                            'Không có quy trình nào',
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
                      itemCount: filteredProductionProcesses.length,
                      itemBuilder: (context, index) {
                        final listProductionProcess =
                            filteredProductionProcesses[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap:
                                () =>
                                    _showAccountDetails(listProductionProcess),
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
                                          color: ColorConfig.secondary,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${listProductionProcess["sapxep"]}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ColorConfig.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          listProductionProcess["tenhoatdong"],
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
                                                        listProductionProcess,
                                                      ),
                                                    ),
                                              ),
                                              PopupMenuItem(
                                                child: const Text('Chỉnh sửa'),
                                                onTap:
                                                    () => Future.delayed(
                                                      Duration.zero,
                                                      () => _showEditDialog(
                                                        listProductionProcess,
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
                                                        listProductionProcess,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  if (listProductionProcess["mota"] != null &&
                                      listProductionProcess["mota"].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        listProductionProcess["mota"],
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
    );
  }
}
