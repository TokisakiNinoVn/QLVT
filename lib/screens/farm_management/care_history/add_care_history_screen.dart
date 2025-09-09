import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txng/services/farm_management/care_history_service.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';

class AddCareHistoryScreen extends StatefulWidget {
  const AddCareHistoryScreen({super.key});

  @override
  State<AddCareHistoryScreen> createState() => _AddCareHistoryScreenState();
}

class _AddCareHistoryScreenState extends State<AddCareHistoryScreen> {
  final CareHistoryService _careHistoryService = CareHistoryService();
  final FertilizerMedicineService _fertilizerMedicineService =
  FertilizerMedicineService();
  final CareProcessService _careProcessService = CareProcessService();

  List<Map<String, dynamic>> listFertilizerMedicine = [];
  List<Map<String, dynamic>> filteredFertilizerMedicine = [];
  List<Map<String, dynamic>> listCareProcess = [];
  bool _isLoading = false;
  bool _isManualInput = false;

  final TextEditingController _hoatDongController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  String? _selectedFertilizerId;
  String? _selectedProcessId;

  @override
  void initState() {
    super.initState();
    _loadFertilizerMedicine();
    _loadCareProcess();
    _hoatDongController.addListener(_onProcessNameChanged);
  }

  @override
  void dispose() {
    _hoatDongController.removeListener(_onProcessNameChanged);
    _hoatDongController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  void _onProcessNameChanged() {
    final inputText = _hoatDongController.text;
    final selectedProcess = listCareProcess.firstWhere(
          (p) => p['hoatdong']?.toString() == inputText,
      orElse: () => {},
    );

    setState(() {
      if (selectedProcess.isEmpty) {
        _isManualInput = true;
        _selectedProcessId = null;
        filteredFertilizerMedicine = listFertilizerMedicine;
      } else {
        _isManualInput = false;
        _selectedProcessId = selectedProcess['id'].toString();
        filteredFertilizerMedicine = listFertilizerMedicine
            .where((item) => item['mahoatdong'] == selectedProcess['mahoatdong'])
            .toList();
      }
    });
  }

  Future<void> _loadCareProcess() async {
    final response = await _careProcessService.getAllCareProcessService();
    final rawData = response["data"]?["quytrinhchamsocs"];
    try {
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
        print(
          "Dữ liệu không phải List, kiểu nhận được: ${rawData.runtimeType}",
        );
        setState(() => listCareProcess = []);
      }
    } catch (e) {
      print("Lỗi khi tải quy trình chăm sóc: $e");
    }
  }

  Future<void> _loadFertilizerMedicine() async {
    final response =
    await _fertilizerMedicineService.getAllFertilizerMedicineService();
    final rawData = response["data"]?["phanbon_thuocs"]?["data"];
    try {
      if (rawData is List) {
        setState(() {
          listFertilizerMedicine =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
              )
                  .toList();
          filteredFertilizerMedicine = listFertilizerMedicine;
        });
      } else {
        print(
          "Dữ liệu không phải List, kiểu nhận được: ${rawData.runtimeType}",
        );
        setState(() => listFertilizerMedicine = []);
      }
    } catch (e) {
      print("Lỗi khi tải sản phẩm: $e");
    }
  }

  Future<void> _submitCareHistory() async {
    if (!_isManualInput && _selectedProcessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn quy trình chăm sóc")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _careHistoryService.createCareHistoryService({
        "quytrinh_id": _selectedProcessId,
        "tenhoatdong": _hoatDongController.text,
        "sanphamsudung": _selectedFertilizerId,
        "ghichu": _moTaController.text,
      });

      if (response["status"] == true || response["code"] == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Thêm mới thành công!")));
        context.go("/");
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm mới: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Thêm lịch sử mới"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go("/"),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hoatDongController,
              decoration: InputDecoration(
                labelText: 'Quy trình chăm sóc*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFertilizerId,
              decoration: InputDecoration(
                labelText: 'Sản phẩm sử dụng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Không chọn'),
                ),
                ...filteredFertilizerMedicine.map(
                      (item) => DropdownMenuItem(
                    value: item['id'].toString(),
                    child: Text(
                      '${item['tensanpham']?.toString() ?? 'Không có tên'} (${item['mahoatdong'] ?? ''})',
                    ),
                  ),
                ),
              ],
              onChanged:
                  (value) =>
                  setState(() => _selectedFertilizerId = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _moTaController,
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
            const SizedBox(height: 16),
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
                    onPressed: () => context.go("/"),
                    child: const Text("Hủy"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitCareHistory,
                    child: const Text("Thêm"),
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