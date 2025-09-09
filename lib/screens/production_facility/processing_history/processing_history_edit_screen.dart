import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:txng/services/production_facility/processing_history_service.dart';
import 'package:txng/services/production_facility/additive_products_service.dart';
import 'package:txng/services/production_facility/production_process_service.dart';

class ProcessingHistoryAddScreen extends StatefulWidget {
  final String code;
  const ProcessingHistoryAddScreen({super.key, required this.code});

  @override
  State<ProcessingHistoryAddScreen> createState() => _ProcessingHistoryAddScreenState();
}

class _ProcessingHistoryAddScreenState extends State<ProcessingHistoryAddScreen> {
  static final ProcessingHistoryService _processingHistoryService = ProcessingHistoryService();
  static final AdditiveProductsService _additiveProductsService = AdditiveProductsService();
  static final ProductionProcessService _productionProcessService = ProductionProcessService();

  List<Map<String, dynamic>> listAdditiveProducts = [];
  List<Map<String, dynamic>> listProductionProcess = [];

  bool _isLoading = true;
  bool isSubmitting = false;
  String? selectedProcessId;
  String? selectedFertilizerId;
  bool _processError = false;
  bool _fertilizerError = false;
  final TextEditingController _processController = TextEditingController();
  final TextEditingController _fertilizerController = TextEditingController();
  final TextEditingController moTaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdditiveProducts();
    _loadProductionProcess();
  }

  @override
  void dispose() {
    _processController.dispose();
    _fertilizerController.dispose();
    moTaController.dispose();
    super.dispose();
  }

  Future<void> _loadAdditiveProducts() async {
    try {
      final response = await _additiveProductsService.getAllAdditiveProductsService();
      final rawData = response["data"]?["sanphamphugias"]?["data"];
      if (rawData is List) {
        setState(() {
          listAdditiveProducts = rawData.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          listAdditiveProducts = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải sản phẩm phụ gia: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _loadProductionProcess() async {
    try {
      final response = await _productionProcessService.getAllProductionProcessService();
      final rawData = response["data"]?["quytrinhchebiens"];
      if (rawData is List) {
        setState(() {
          listProductionProcess = rawData.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          listProductionProcess = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải quy trình chế biến: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm lịch sử chế biến',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => context.pop(),
            tooltip: 'Đóng',
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mã lô hàng
                    Text(
                      "Mã lô hàng: ${widget.code}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quy trình chế biến
                    _buildAutocompleteField(
                      label: 'Quy trình chế biến',
                      controller: _processController,
                      options: listProductionProcess,
                      getSelectedId: () => selectedProcessId,
                      setSelectedId: (id) => selectedProcessId = id,
                      errorState: _processError,
                      setErrorState: (error) => _processError = error,
                      fieldKey: 'tenhoatdong',
                      icon: Icons.agriculture,
                    ),
                    const SizedBox(height: 20),
                    // Sản phẩm sử dụng
                    _buildAutocompleteField(
                      label: 'Sản phẩm sử dụng',
                      controller: _fertilizerController,
                      options: listAdditiveProducts,
                      getSelectedId: () => selectedFertilizerId,
                      setSelectedId: (id) => selectedFertilizerId = id,
                      errorState: _fertilizerError,
                      setErrorState: (error) => _fertilizerError = error,
                      fieldKey: 'tensanpham',
                      icon: Icons.science,
                    ),
                    const SizedBox(height: 20),
                    // Mô tả
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
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        prefixIcon: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () => context.pop(),
                              child: const Text(
                                "Hủy",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                elevation: 2,
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                if (selectedProcessId == null) {
                                  setState(() => _processError = true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Vui lòng chọn quy trình chế biến",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => isSubmitting = true);
                                try {
                                  final response = await _processingHistoryService
                                      .createProcessingHistoryService({
                                    "malohang": widget.code,
                                    "hoatdong": selectedProcessId != null
                                        ? (listProductionProcess.firstWhere(
                                          (p) =>
                                      p['id'].toString() ==
                                          selectedProcessId,
                                      orElse: () =>
                                      {'tenhoatdong': ''},
                                    )['tenhoatdong'] ?? '')
                                        : '',
                                    "sanphamsudung": selectedFertilizerId != null
                                        ? (listAdditiveProducts.firstWhere(
                                          (p) =>
                                      p['id'].toString() ==
                                          selectedFertilizerId,
                                      orElse: () =>
                                      {'tensanpham': null},
                                    )['tensanpham'] ?? '')
                                        : '',
                                    "ghichu": moTaController.text,
                                  });
                                  if (response["status"] == true ||
                                      response["code"] == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "Thêm mới thành công!",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                    context.pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Lỗi khi thêm mới: $e"),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                } finally {
                                  setState(() => isSubmitting = false);
                                }
                              },
                              child: isSubmitting
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập hoặc chọn $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorState
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorState
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorState
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            prefixIcon: Icon(
              icon,
              color: errorState
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorText: errorState ? 'Vui lòng nhập hoặc chọn $label' : null,
            errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
            suffixIcon: PopupMenuButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              onSelected: (String value) {
                setState(() {
                  controller.text = value;
                  final selectedItem = options.firstWhere(
                        (item) => item[fieldKey]?.toString() == value,
                    orElse: () => {'id': null},
                  );
                  setSelectedId(selectedItem['id']?.toString());
                  setErrorState(false);
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  if (label == 'Sản phẩm sử dụng')
                    PopupMenuItem<String>(
                      value: '',
                      child: const Text('Không chọn'),
                    ),
                  ...options.map((item) {
                    final value = item[fieldKey]?.toString() ?? 'Không có tên';
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }),
                ];
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              setErrorState(false);
              setSelectedId(null);
            });
          },
        ),
      ],
    );
  }
}