import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txng/services/farm_management/care_history_service.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';

import '../../../config/color_config.dart';

class AddCareHistoryNormalScreen extends StatefulWidget {
  final int id;
  final Map<String, dynamic>? plantingArea;

  const AddCareHistoryNormalScreen({
    super.key,
    required this.id,
    this.plantingArea,
  });

  @override
  State<AddCareHistoryNormalScreen> createState() =>
      _AddCareHistoryNormalScreenState();
}

class _AddCareHistoryNormalScreenState
    extends State<AddCareHistoryNormalScreen> {
  final CareHistoryService _careHistoryService = CareHistoryService();
  final FertilizerMedicineService _fertilizerMedicineService =
  FertilizerMedicineService();
  final CareProcessService _careProcessService = CareProcessService();
  static final CareHistoryService _listCareHistoryService =
  CareHistoryService();

  List<Map<String, dynamic>> listFertilizerMedicine = [];
  List<Map<String, dynamic>> filteredFertilizerMedicine = [];
  List<Map<String, dynamic>> listCareProcess = [];
  List<Map<String, dynamic>> listSupplier = [];
  bool _isLoading = false;
  bool _isManualInput = false;

  final TextEditingController _hoatDongController = TextEditingController();
  final TextEditingController _tenVungTrongController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  final TextEditingController _fertilizerController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _lieuLuongController = TextEditingController();

  String? _selectedFertilizerId;
  String? _selectedProcessId;
  String? _selectedSupplierId;
  bool _processError = false;
  bool _fertilizerError = false;
  bool _supplierError = false;

  @override
  void initState() {
    super.initState();
    _loadFertilizerMedicine();
    _loadCareProcess();
    _loadSupplier();
    _initPlantingArea();
    _hoatDongController.addListener(_onProcessNameChanged);
  }

  void _initPlantingArea() {
    if (widget.plantingArea != null &&
        widget.plantingArea!['tenvungtrong'] != null) {
      _tenVungTrongController.text =
          widget.plantingArea!['tenvungtrong'].toString();
    }
  }

  void _onProcessNameChanged() {
    final inputText = _hoatDongController.text;
    final selectedProcess = listCareProcess.firstWhere(
          (p) => p['hoatdong']?.toString() == inputText,
      orElse: () => {},
    );

    setState(() {
      if (selectedProcess.isEmpty) {
        // Manual input - show all products
        _isManualInput = true;
        _selectedProcessId = null;
        filteredFertilizerMedicine = List.from(listFertilizerMedicine);
      } else {
        // Selected from dropdown - filter products by mahoatdong (which equals care process id)
        _isManualInput = false;
        _selectedProcessId = selectedProcess['id'].toString();
        final processId = selectedProcess['id'];
        filteredFertilizerMedicine = listFertilizerMedicine
            .where((product) => product['mahoatdong'] == processId)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _hoatDongController.removeListener(_onProcessNameChanged);
    _hoatDongController.dispose();
    _tenVungTrongController.dispose();
    _moTaController.dispose();
    _fertilizerController.dispose();
    _supplierController.dispose();
    _lieuLuongController.dispose();
    super.dispose();
  }

  Future<void> _loadCareProcess() async {
    try {
      final response = await _careProcessService.getAllCareProcessService();
      final rawData = response["data"]?["quytrinhchamsocs"];
      if (rawData is List) {
        setState(() {
          listCareProcess =
              rawData.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        debugPrint("Dữ liệu không phải List, kiểu nhận được: ${rawData.runtimeType}");
        setState(() => listCareProcess = []);
      }
    } catch (e) {
      debugPrint("Lỗi khi tải quy trình chăm sóc: $e");
    }
  }

  Future<void> _loadSupplier() async {
    try {
      final response = await _listCareHistoryService.getListSupplierService();
      final rawData = response["data"]?["data"];
      if (rawData is List) {
        setState(() {
          listSupplier =
              rawData.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        setState(() => listSupplier = []);
      }
    } catch (e) {
      debugPrint("Lỗi khi tải nhà cung cấp: $e");
    }
  }

  Future<void> _loadFertilizerMedicine() async {
    try {
      final response =
      await _fertilizerMedicineService.getAllFertilizerMedicineService();
      final rawData = response["data"]?["phanbon_thuocs"]?["data"];
      if (rawData is List) {
        setState(() {
          listFertilizerMedicine =
              rawData.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
          filteredFertilizerMedicine = List.from(listFertilizerMedicine);
        });
      } else {
        debugPrint("Dữ liệu không phải List, kiểu nhận được: ${rawData.runtimeType}");
        setState(() => listFertilizerMedicine = []);
      }
    } catch (e) {
      debugPrint("Lỗi khi tải sản phẩm: $e");
    }
  }

  Future<void> _submitCareHistory() async {
    bool hasError = false;
    if (_hoatDongController.text.isEmpty) {
      setState(() => _processError = true);
      hasError = true;
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _careHistoryService.createCareHistoryService({
        "quytrinh_id": _selectedProcessId,
        "tenhoatdong": _hoatDongController.text,
        "sanphamsudung": _fertilizerController.text,
        "tennhacungcap": _supplierController.text,
        "ghichu": _moTaController.text,
        "mavungtrong": widget.plantingArea?['mavungtrong'],
        "lieuluong": _lieuLuongController.text,
      });

      if (response["status"] == true || response["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm mới thành công!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        print('Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi thêm mới: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAutocompleteField({
    required String label,
    required TextEditingController controller,
    required List<Map<String, dynamic>> options,
    required String? Function() getSelectedId,
    required Function(String?) setSelectedId,
    required bool errorState,
    required Function(bool) setErrorState,
    required String fieldKey,
    required IconData icon,
    bool showProcessId = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập hoặc chọn $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorState ? Theme.of(context).colorScheme.error : ColorConfig.primary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorState ? Theme.of(context).colorScheme.error : ColorConfig.primary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorState ? Theme.of(context).colorScheme.error : ColorConfig.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              color: errorState ? ColorConfig.primary : ColorConfig.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: errorState ? 'Vui lòng nhập hoặc chọn $label' : null,
            errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (String value) {
                setState(() {
                  controller.text = value;
                  final selectedItem = options.firstWhere(
                        (item) => item[fieldKey]?.toString() == value,
                    orElse: () => {'id': null},
                  );
                  setSelectedId(selectedItem['id']?.toString());
                  setErrorState(false);

                  // Special handling for care process selection
                  if (label == 'Quy trình chăm sóc') {
                    _onProcessNameChanged();
                  }
                });
              },
              itemBuilder: (BuildContext context) {
                return options.map((item) {
                  final value = item[fieldKey]?.toString() ?? 'Không có tên';
                  final processId = showProcessId ? ' (ID: ${item['id']})' : '';
                  return PopupMenuItem<String>(
                    value: value,
                    // child: Text('$value$processId'),
                    child: Text(value),
                  );
                }).toList();
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              setErrorState(false);
              setSelectedId(null);

              // Special handling for care process input
              if (label == 'Quy trình chăm sóc') {
                _onProcessNameChanged();
              }
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Thêm lịch sử chăm sóc mới",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Đóng',
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông tin vùng trồng",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tenVungTrongController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Vùng trồng",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(
                  Icons.map_rounded,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Thông tin chăm sóc",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildAutocompleteField(
              label: 'Quy trình chăm sóc',
              controller: _hoatDongController,
              options: listCareProcess,
              getSelectedId: () => _selectedProcessId,
              setSelectedId: (id) => _selectedProcessId = id,
              errorState: _processError,
              setErrorState: (error) => _processError = error,
              fieldKey: 'hoatdong',
              icon: Icons.agriculture,
              showProcessId: true,
            ),
            const SizedBox(height: 16),
            _buildAutocompleteField(
              label: 'Sản phẩm sử dụng',
              controller: _fertilizerController,
              options: filteredFertilizerMedicine,
              getSelectedId: () => _selectedFertilizerId,
              setSelectedId: (id) => _selectedFertilizerId = id,
              errorState: _fertilizerError,
              setErrorState: (error) => _fertilizerError = error,
              fieldKey: 'tensanpham',
              icon: Icons.spa,
            ),
            const SizedBox(height: 16),
            _buildAutocompleteField(
              label: 'Nhà cung cấp',
              controller: _supplierController,
              options: listSupplier,
              getSelectedId: () => _selectedSupplierId,
              setSelectedId: (id) => _selectedSupplierId = id,
              errorState: _supplierError,
              setErrorState: (error) => _supplierError = error,
              fieldKey: 'tennhacungcap',
              icon: Icons.store,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lieuLuongController,
              decoration: InputDecoration(
                labelText: 'Liều lượng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ColorConfig.primary,
                  ),
                ),
                filled: true,
                fillColor: ColorConfig.white,
                prefixIcon: Icon(
                  Icons.water_drop,
                  color: ColorConfig.primary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mô tả',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _moTaController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập mô tả (nếu có)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: ColorConfig.primary,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Hủy",
                      style: TextStyle(
                        color: ColorConfig.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: ColorConfig.primary,
                    ),
                    onPressed: _isLoading ? null : _submitCareHistory,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Lưu lại",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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