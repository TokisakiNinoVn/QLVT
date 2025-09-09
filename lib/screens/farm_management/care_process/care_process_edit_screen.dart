import 'package:flutter/material.dart';
import 'package:txng/services/farm_management/care_process_service.dart';
import 'package:txng/config/color_config.dart';
import 'package:txng/helpers/snackbar_helper.dart';

class CareProcessEditScreen extends StatefulWidget {
  final Map<String, dynamic>? careProcess;
  final VoidCallback onSave;

  const CareProcessEditScreen({super.key, this.careProcess, required this.onSave});

  @override
  State<CareProcessEditScreen> createState() => _CareProcessEditScreenState();
}

class _CareProcessEditScreenState extends State<CareProcessEditScreen> {
  static final CareProcessService _listCareProcessService = CareProcessService();
  late List<Map<String, dynamic>> listCareProcesses = [];
  late TextEditingController hoatDongController;
  late TextEditingController moTaController;
  late int currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    hoatDongController = TextEditingController(text: widget.careProcess?['hoatdong'] ?? '');
    moTaController = TextEditingController(text: widget.careProcess?['mota'] ?? '');
    currentOrder = widget.careProcess?['sapxep'] ?? _getNextOrderNumber();
    _loadCareProcesses();
  }

  @override
  void dispose() {
    hoatDongController.dispose();
    moTaController.dispose();
    super.dispose();
  }

  Future<void> _loadCareProcesses() async {
    try {
      final response = await _listCareProcessService.getAllCareProcessService();
      final rawData = response["data"]?["quytrinhchamsocs"];
      if (rawData is List) {
        setState(() {
          listCareProcesses = rawData
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();
        });
      }
    } catch (e) {
      // Handle error silently as it's only for order number validation
    }
  }

  int _getNextOrderNumber() {
    if (listCareProcesses.isEmpty) return 1;
    int maxOrder = listCareProcesses
        .map((e) => e['sapxep'] as int)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  bool _isOrderNumberExist(int orderNumber, {int? excludeId}) {
    return listCareProcesses.any(
          (process) =>
      process['sapxep'] == orderNumber &&
          (excludeId == null || process['id'] != excludeId),
    );
  }

  List<int> _getUsedOrderNumbers() {
    return listCareProcesses
        .map<int>((e) => e['sapxep'] as int)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.careProcess == null
            ? "Thêm quy trình mới"
            : "Chỉnh sửa quy trình chăm sóc"),
        backgroundColor: ColorConfig.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thứ tự quy trình:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 32),
                  onPressed: () {
                    if (currentOrder > 1) {
                      setState(() => currentOrder--);
                    }
                  },
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
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
                  icon: const Icon(Icons.add_circle_outline, size: 32),
                  onPressed: () {
                    setState(() => currentOrder++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isOrderNumberExist(currentOrder, excludeId: widget.careProcess?['id']))
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
                backgroundColor: ColorConfig.primary,
                foregroundColor: ColorConfig.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                final usedNumbers = _getUsedOrderNumbers();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Chọn số thứ tự'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: usedNumbers.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Không có số thứ tự nào khả dụng'),
                      )
                          : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: usedNumbers.map((number) {
                            return ListTile(
                              title: Text(
                                '$number',
                                style: const TextStyle(fontSize: 16, color: ColorConfig.black),
                              ),
                              trailing: number == currentOrder
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => currentOrder = number);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Đóng"),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Chọn từ danh sách có sẵn',
                style: TextStyle(fontSize: 16, color: ColorConfig.white),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConfig.primary,
                      foregroundColor: ColorConfig.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (hoatDongController.text.isEmpty && widget.careProcess == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập tên hoạt động")),
                        );
                        return;
                      }

                      if (_isOrderNumberExist(currentOrder, excludeId: widget.careProcess?['id'])) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Số thứ tự đã tồn tại, vui lòng chọn số khác")),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      try {
                        if (widget.careProcess == null) {
                          // Add new
                          final response = await _listCareProcessService.createCareProcessService({
                            "hoatdong": hoatDongController.text,
                            "mota": moTaController.text,
                            "sapxep": currentOrder,
                          });
                          if (response["status"] == true || response["code"] == 200) {
                            SnackbarHelper.showSuccess(context, 'Thêm mới thành công!');
                            widget.onSave();
                            Navigator.pop(context);
                          } else {
                            SnackbarHelper.showSuccess(
                              context,
                              'Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định!"}',
                            );
                          }
                        } else {
                          // Update existing
                          final response = await _listCareProcessService.updateCareProcessService(
                            widget.careProcess!["id"],
                            {
                              "hoatdong": hoatDongController.text,
                              "mota": moTaController.text,
                              "sapxep": currentOrder,
                              "_method": "PUT",
                            },
                          );
                          if (response["status"] == true || response["code"] == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cập nhật thành công.")),
                            );
                            widget.onSave();
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Cập nhật thất bại: ${response["message"] ?? "Lỗi không xác định"}")),
                            );
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi: $e")),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    child: Text(widget.careProcess == null ? "Thêm" : "Lưu"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}