import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:txng/services/production_facility/processing_history_service.dart';
import 'package:txng/services/production_facility/additive_products_service.dart';
import 'package:txng/services/production_facility/production_process_service.dart';

import '../../../config/color_config.dart';
import '../../../helpers/snackbar_helper.dart';

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
          // style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => context.pop(),
            tooltip: 'Đóng',
          ),
        ],
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
      ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title: Mã lô hàng
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: ColorConfig.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Mã lô hàng: ${widget.code}",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorConfig.primary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// Các trường input
                    _buildAutocompleteField(
                      label: 'Quy trình chế biến',
                      controller: _processController,
                      options: listProductionProcess,
                      getSelectedId: () => selectedProcessId,
                      setSelectedId: (id) => setState(() => selectedProcessId = id),
                      errorState: _processError,
                      setErrorState: (error) => setState(() => _processError = error),
                      fieldKey: 'tenhoatdong',
                      icon: Icons.refresh_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildAutocompleteField(
                      label: 'Sản phẩm sử dụng',
                      controller: _fertilizerController,
                      options: listAdditiveProducts,
                      getSelectedId: () => selectedFertilizerId,
                      setSelectedId: (id) => setState(() => selectedFertilizerId = id),
                      errorState: _fertilizerError,
                      setErrorState: (error) => setState(() => _fertilizerError = error),
                      fieldKey: 'tensanpham',
                      icon: Icons.science,
                    ),
                    const SizedBox(height: 20),

                    /// Mô tả
                    TextField(
                      controller: moTaController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: ColorConfig.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: ColorConfig.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        prefixIcon: Icon(Icons.description, color: ColorConfig.primary),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    /// Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            onPressed: () => context.pop(),
                            child: const Text(
                              "Hủy",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: ColorConfig.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            // onPressed: isSubmitting ? null : _handleSubmit,
                            onPressed: isSubmitting
                                ? null
                                : () async {
                              if ((selectedProcessId == null || selectedProcessId!.isEmpty) && _processController.text.trim().isEmpty) {
                                setState(() => _processError = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Vui lòng chọn quy trình chế biến"),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() => isSubmitting = true);
                              try {
                                final response = await _processingHistoryService.createProcessingHistoryService({
                                  "malohang": widget.code,
                                  "hoatdong": selectedProcessId != null
                                      ? (listProductionProcess.firstWhere(
                                        (p) => p['id'].toString() == selectedProcessId,
                                    orElse: () => {'tenhoatdong': _processController.text.trim()},
                                  )['tenhoatdong'] ?? _processController.text.trim())
                                      : _processController.text.trim(),
                                  "sanphamsudung": selectedFertilizerId != null
                                      ? (listAdditiveProducts.firstWhere(
                                        (p) => p['id'].toString() == selectedFertilizerId,
                                    orElse: () => {'tensanpham': null},
                                  )['tensanpham'] ?? '')
                                      : '',
                                  "ghichu": moTaController.text,
                                });
                                if (response["status"] == true || response["code"] == 200) {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     content: const Text("Thêm mới thành công!"),
                                  //     behavior: SnackBarBehavior.floating,
                                  //     backgroundColor: Colors.green,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //     ),
                                  //   ),
                                  // );
                                  // Navigator.of(context).pop(true);
                                  // Navigator.pop(context, true);
                                  SnackbarHelper.showSuccess(context, 'Thêm thành công!');
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  final role = prefs.getString('quyenhan');
                                  if (role == 'quanly') {
                                    context.go('/processing-management/processing-history/${widget.code}');
                                  } else {
                                    context.go('/home');
                                  }
                                } else {
                                  print("Lỗi thêm mới: ${response["message"]}");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}"),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("Lỗi thêm mới: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Lỗi khi thêm mới: $e"),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        )

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
            color: ColorConfig.primary,
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
                color: errorState ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorState ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorState ? Theme.of(context).colorScheme.error : ColorConfig.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            prefixIcon: Icon(
              icon,
              color: errorState ? Theme.of(context).colorScheme.error : ColorConfig.primary,
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
                color: ColorConfig.primary
              ),
              onSelected: (String value) {
                setState(() {
                  controller.text = value;
                  final selectedItem = options.firstWhere(
                        (item) => item[fieldKey]?.toString() == value,
                    orElse: () => {'id': null, fieldKey: ''},
                  );
                  final id = selectedItem['id']?.toString();
                  setSelectedId(id);
                  setErrorState(id == null && label == 'Quy trình chế biến');
                  print("Selected $label: $value, ID: $id"); // Debug log
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
              // Only reset selectedId if the input doesn't match any option
              final matchedItem = options.firstWhere(
                    (item) => item[fieldKey]?.toString() == value,
                orElse: () => {'id': null},
              );
              final id = matchedItem['id']?.toString();
              setSelectedId(id);
              print("Text changed for $label: $value, ID: $id"); // Debug log
            });
          },
        ),
      ],
    );
  }
}