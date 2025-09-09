import 'package:flutter/material.dart';
import 'dart:async';

import 'package:txng/services/production_facility/processing_history_service.dart';
import 'package:txng/services/production_facility/additive_products_service.dart';
import 'package:txng/services/production_facility/production_process_service.dart';

class ProcessingHistoryManagementScreen extends StatefulWidget {
  const ProcessingHistoryManagementScreen({super.key});

  @override
  State<ProcessingHistoryManagementScreen> createState() =>
      _ProcessingHistoryScreenState();
}

class _ProcessingHistoryScreenState extends State<ProcessingHistoryManagementScreen> {
  static final ProcessingHistoryService _processingHistoryService =
      ProcessingHistoryService();
  static final AdditiveProductsService _additiveProductsService =
      AdditiveProductsService();
  static final ProductionProcessService _productionProcessService =
      ProductionProcessService();

  List<Map<String, dynamic>> listProcessingHistory = [];
  List<Map<String, dynamic>> listAdditiveProducts = [];
  List<Map<String, dynamic>> listProductionProcess = [];
  List<Map<String, dynamic>> filteredProcessingHistory = [];

  bool _isLoading = true;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAdditiveProducts();
    _loadProcessingHistory();
    _loadProductionProcess();
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
        filteredProcessingHistory =
            listProcessingHistory.where((history) {
              final searchText = _searchController.text.toLowerCase();
              return (history['hoatdong']?.toString().toLowerCase() ?? '')
                      .contains(searchText) ||
                  (history['ghichu']?.toString().toLowerCase() ?? '').contains(
                    searchText,
                  );
            }).toList();
      });
    });
  }

  Future<void> _loadProcessingHistory() async {
    try {
      setState(() => _isLoading = true);
      final response =
          await _processingHistoryService.getAllProcessingHistoryService();
      final rawData = response["data"]?["lichsuchamsocs"]?["data"];

      if (rawData is List) {
        setState(() {
          listProcessingHistory =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          filteredProcessingHistory = List.from(listProcessingHistory);
        });
      } else {
        setState(() {
          listProcessingHistory = [];
          filteredProcessingHistory = [];
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

  Future<void> _loadProductionProcess() async {
    try {
      final response =
          await _productionProcessService.getAllProductionProcessService();
      final rawData = response["data"]?["quytrinhchebiens"];

      if (rawData is List) {
        setState(() {
          listProductionProcess =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
        });
      } else {
        setState(() => listProductionProcess = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải quy trình chăm sóc: $e")),
      );
    }
  }

  Future<void> _loadAdditiveProducts() async {
    try {
      final response =
          await _additiveProductsService.getAllAdditiveProductsService();
      final rawData = response["data"]?["sanphamphugias"]?["data"];
      if (rawData is List) {
        setState(() {
          listAdditiveProducts =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
        });
      } else {
        setState(() => listAdditiveProducts = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải sản phẩm: $e")));
    }
  }

  // void _showProcessingHistoryDetails(Map<String, dynamic> history) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierColor: Colors.black54,
  //     builder:
  //         (context) => Dialog(
  //           insetPadding: const EdgeInsets.symmetric(
  //             horizontal: 20,
  //             vertical: 24,
  //           ),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           elevation: 6,
  //           backgroundColor: Theme.of(context).colorScheme.surface,
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(16),
  //             child: Scaffold(
  //               backgroundColor: Colors.transparent,
  //               appBar: AppBar(
  //                 title: const Text(
  //                   "Chi tiết lịch sử chế biến",
  //                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
  //                 ),
  //                 automaticallyImplyLeading: false,
  //                 actions: [
  //                   IconButton(
  //                     icon: const Icon(Icons.close, size: 22),
  //                     onPressed: () => Navigator.pop(context),
  //                     tooltip: 'Đóng',
  //                   ),
  //                 ],
  //                 shape: const RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.vertical(
  //                     top: Radius.circular(16),
  //                   ),
  //                 ),
  //                 backgroundColor: Theme.of(context).colorScheme.surface,
  //                 elevation: 0,
  //                 shadowColor: Colors.black26,
  //               ),
  //               body: SingleChildScrollView(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     _buildDetailItem(
  //                       "Quy trình chế biến",
  //                       history["hoatdong"]?.toString() ?? "Không có",
  //                       isTitle: true,
  //                       icon: Icons.task_alt,
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildDetailItem(
  //                       "Sản phẩm sử dụng",
  //                       history["sanphamsudung"]?.toString(),
  //                       icon: Icons.science,
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildDetailItem(
  //                       "Ghi chú",
  //                       history["ghichu"]?.toString() ?? "Không có",
  //                       isMultiline: true,
  //                       icon: Icons.note,
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildDetailItem(
  //                       "Ngày tạo",
  //                       _formatDate(history["created_at"]?.toString()),
  //                       icon: Icons.calendar_today,
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildDetailItem(
  //                       "Ngày cập nhật",
  //                       _formatDate(history["updated_at"]?.toString()),
  //                       icon: Icons.update,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //   );
  // }

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

  // String _getProductName(String? productId) {
  //   if (productId == null || productId.isEmpty) return "Không có";
  //   final product = listAdditiveProducts.firstWhere(
  //         (item) => item['id'].toString() == productId,
  //     orElse: () => {'tensanpham': 'Không xác định'},
  //   );
  //   return product['tensanpham']?.toString() ?? 'Không xác định';
  // }

  void _showEditDialog(Map<String, dynamic> history) {
    final TextEditingController hoatDongController = TextEditingController(
      text: history['hoatdong']?.toString(),
    );
    final TextEditingController moTaController = TextEditingController(
      text: history['ghichu']?.toString(),
    );

    // Tìm id quy trình theo tên hoạt động (tenhoatdong)
    String? selectedProcessId =
        listProductionProcess
            .firstWhere(
              (item) =>
                  item['tenhoatdong']?.toString() ==
                  history['hoatdong']?.toString(),
              orElse: () => <String, dynamic>{},
            )['id']
            ?.toString();

    // Tìm id sản phẩm theo tên sản phẩm sử dụng
    String? selectedFertilizerId =
        listAdditiveProducts
            .firstWhere(
              (item) =>
                  item['tensanpham']?.toString() ==
                  history['sanphamsudung']?.toString(),
              orElse: () => <String, dynamic>{},
            )['id']
            ?.toString();

    // showDialog(
    //   context: context,
    //   builder:
    //       (dialogContext) => StatefulBuilder(
    //         builder: (context, setState) {
    //           return Dialog(
    //             insetPadding: const EdgeInsets.all(16),
    //             child: Container(
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(16),
    //                 color: Theme.of(context).colorScheme.surface,
    //               ),
    //               child: Scaffold(
    //                 backgroundColor: Colors.transparent,
    //                 appBar: AppBar(
    //                   title: const Text("Chỉnh sửa lịch sử chế biến"),
    //                   automaticallyImplyLeading: false,
    //                   actions: [
    //                     IconButton(
    //                       icon: const Icon(Icons.close),
    //                       onPressed: () => Navigator.pop(dialogContext),
    //                     ),
    //                   ],
    //                   shape: const RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.vertical(
    //                       top: Radius.circular(16),
    //                     ),
    //                   ),
    //                 ),
    //                 body: SingleChildScrollView(
    //                   padding: const EdgeInsets.all(16),
    //                   child: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       DropdownButtonFormField<String>(
    //                         value: selectedProcessId,
    //                         decoration: InputDecoration(
    //                           labelText: 'Quy trình chăm sóc*',
    //                           border: OutlineInputBorder(
    //                             borderRadius: BorderRadius.circular(12),
    //                           ),
    //                           filled: true,
    //                           fillColor:
    //                               Theme.of(context).colorScheme.surfaceVariant,
    //                         ),
    //                         items: [
    //                           const DropdownMenuItem(
    //                             value: null,
    //                             child: Text('Chưa chọn'),
    //                           ),
    //                           ...listProductionProcess.map(
    //                             (item) => DropdownMenuItem(
    //                               value: item['id'].toString(),
    //                               child: Text(
    //                                 item['tenhoatdong']?.toString() ??
    //                                     'Không có tên',
    //                                 style: const TextStyle(
    //                                   fontSize: 16,
    //                                   color: Colors.black,
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                         onChanged: (value) {
    //                           setState(() {
    //                             selectedProcessId = value;
    //                             final process = listProductionProcess
    //                                 .firstWhere(
    //                                   (p) => p['id'].toString() == value,
    //                                   orElse: () => {'hoatdong': ''},
    //                                 );
    //                             hoatDongController.text =
    //                                 process['hoatdong']?.toString() ?? '';
    //                           });
    //                         },
    //                       ),
    //                       const SizedBox(height: 16),
    //                       DropdownButtonFormField<String>(
    //                         value: selectedFertilizerId,
    //                         decoration: InputDecoration(
    //                           labelText: 'Sản phẩm sử dụng',
    //                           border: OutlineInputBorder(
    //                             borderRadius: BorderRadius.circular(12),
    //                           ),
    //                           filled: true,
    //                           fillColor:
    //                               Theme.of(context).colorScheme.surfaceVariant,
    //                         ),
    //                         items: [
    //                           const DropdownMenuItem(
    //                             value: null,
    //                             child: Text('Chưa chọn'),
    //                           ),
    //                           ...listAdditiveProducts.map(
    //                             (item) => DropdownMenuItem(
    //                               value: item['id'].toString(),
    //                               child: Text(
    //                                 item['tensanpham']?.toString() ??
    //                                     'Không có tên',
    //                                 style: const TextStyle(
    //                                   fontSize: 16,
    //                                   color: Colors.black,
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                         onChanged:
    //                             (value) => setState(
    //                               () => selectedFertilizerId = value,
    //                             ),
    //                       ),
    //                       const SizedBox(height: 16),
    //                       TextField(
    //                         controller: moTaController,
    //                         maxLines: 4,
    //                         decoration: InputDecoration(
    //                           labelText: 'Ghi chú',
    //                           alignLabelWithHint: true,
    //                           border: OutlineInputBorder(
    //                             borderRadius: BorderRadius.circular(12),
    //                           ),
    //                           filled: true,
    //                           fillColor:
    //                               Theme.of(context).colorScheme.surfaceVariant,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 bottomNavigationBar: Padding(
    //                   padding: const EdgeInsets.all(16),
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: OutlinedButton(
    //                           style: OutlinedButton.styleFrom(
    //                             padding: const EdgeInsets.symmetric(
    //                               vertical: 16,
    //                             ),
    //                             shape: RoundedRectangleBorder(
    //                               borderRadius: BorderRadius.circular(12),
    //                             ),
    //                           ),
    //                           onPressed: () => Navigator.pop(dialogContext),
    //                           child: const Text("Hủy"),
    //                         ),
    //                       ),
    //                       const SizedBox(width: 16),
    //                       Expanded(
    //                         child: ElevatedButton(
    //                           style: ElevatedButton.styleFrom(
    //                             padding: const EdgeInsets.symmetric(
    //                               vertical: 16,
    //                             ),
    //                             shape: RoundedRectangleBorder(
    //                               borderRadius: BorderRadius.circular(12),
    //                             ),
    //                           ),
    //                           onPressed: () async {
    //                             if (selectedProcessId == null) {
    //                               ScaffoldMessenger.of(context).showSnackBar(
    //                                 const SnackBar(
    //                                   content: Text(
    //                                     "Vui lòng chọn quy trình chăm sóc",
    //                                   ),
    //                                 ),
    //                               );
    //                               return;
    //                             }
    //
    //                             setState(() => _isLoading = true);
    //
    //                             try {
    //                               final selectedProduct = listAdditiveProducts
    //                                   .firstWhere(
    //                                     (item) =>
    //                                         item['id'].toString() ==
    //                                         selectedFertilizerId,
    //                                     orElse: () => {'tensanpham': null},
    //                                   );
    //
    //                               final response =
    //                                   await _processingHistoryService
    //                                       .updateProcessingHistoryService(
    //                                         history["id"],
    //                                         {
    //                                           "hoatdong":
    //                                               hoatDongController.text,
    //                                           "sanphamsudung":
    //                                               selectedProduct['tensanpham'],
    //                                           "ghichu": moTaController.text,
    //                                           "_method": "PUT",
    //                                         },
    //                                       );
    //
    //                               if (response["status"] == true ||
    //                                   response["code"] == 200) {
    //                                 ScaffoldMessenger.of(context).showSnackBar(
    //                                   const SnackBar(
    //                                     content: Text("Cập nhật thành công!"),
    //                                   ),
    //                                 );
    //                                 await _loadProcessingHistory();
    //                               } else {
    //                                 ScaffoldMessenger.of(context).showSnackBar(
    //                                   SnackBar(
    //                                     content: Text(
    //                                       "Cập nhật thất bại: ${response["message"] ?? "Lỗi không xác định"}",
    //                                     ),
    //                                   ),
    //                                 );
    //                               }
    //                             } catch (e) {
    //                               ScaffoldMessenger.of(context).showSnackBar(
    //                                 SnackBar(
    //                                   content: Text("Lỗi khi cập nhật: $e"),
    //                                 ),
    //                               );
    //                             } finally {
    //                               setState(() => _isLoading = false);
    //                               Navigator.pop(dialogContext);
    //                             }
    //                           },
    //                           child: const Text("Lưu"),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           );
    //         },
    //       ),
    // );
  }

  // void _showAddDialog() {
  //   final TextEditingController hoatDongController = TextEditingController();
  //   final TextEditingController moTaController = TextEditingController();
  //   String? selectedProcessId;
  //   String? selectedFertilizerId;
  //   String? selectedAdditiveProductName;
  //   bool isLoading = false;
  //
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.black54,
  //     builder:
  //         (dialogContext) => StatefulBuilder(
  //           builder: (context, setState) {
  //             return Dialog(
  //               insetPadding: const EdgeInsets.symmetric(
  //                 horizontal: 20,
  //                 vertical: 24,
  //               ),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               elevation: 8,
  //               backgroundColor: Theme.of(context).colorScheme.surface,
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(20),
  //                 child: Scaffold(
  //                   backgroundColor: Colors.transparent,
  //                   appBar: AppBar(
  //                     title: const Text(
  //                       "Thêm lịch sử mới",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 20,
  //                       ),
  //                     ),
  //                     automaticallyImplyLeading: false,
  //                     actions: [
  //                       IconButton(
  //                         icon: const Icon(Icons.close, size: 24),
  //                         onPressed: () => Navigator.pop(dialogContext),
  //                         tooltip: 'Đóng',
  //                       ),
  //                     ],
  //                     shape: const RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.vertical(
  //                         top: Radius.circular(20),
  //                       ),
  //                     ),
  //                     backgroundColor: Theme.of(context).colorScheme.surface,
  //                     elevation: 0,
  //                     shadowColor: Colors.black26,
  //                   ),
  //                   body: SingleChildScrollView(
  //                     padding: const EdgeInsets.all(20),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         DropdownButtonFormField<String>(
  //                           value: selectedProcessId,
  //                           decoration: InputDecoration(
  //                             labelText: 'Quy trình chế biến',
  //                             labelStyle: TextStyle(
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                               borderSide: BorderSide(
  //                                 color: Theme.of(context).colorScheme.outline,
  //                               ),
  //                             ),
  //                             enabledBorder: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                               borderSide: BorderSide(
  //                                 color:
  //                                     Theme.of(
  //                                       context,
  //                                     ).colorScheme.outlineVariant,
  //                               ),
  //                             ),
  //                             filled: true,
  //                             fillColor:
  //                                 Theme.of(context).colorScheme.surfaceVariant,
  //                             prefixIcon: Icon(
  //                               Icons.agriculture,
  //                               color: Colors.black,
  //                             ),
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                               vertical: 12,
  //                             ),
  //                           ),
  //                           items:
  //                               listProductionProcess
  //                                   .map(
  //                                     (item) => DropdownMenuItem(
  //                                       value: item['id'].toString(),
  //                                       child: Text(
  //                                         item['tenhoatdong']?.toString() ??
  //                                             'Không có tên',
  //                                         style: const TextStyle(
  //                                           fontSize: 16,
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   )
  //                                   .toList(),
  //                           onChanged: (value) {
  //                             setState(() {
  //                               selectedProcessId = value;
  //                               final process = listProductionProcess
  //                                   .firstWhere(
  //                                     (p) => p['id'].toString() == value,
  //                                     orElse: () => {'hoatdong': ''},
  //                                   );
  //                               hoatDongController.text =
  //                                   process['hoatdong']?.toString() ?? '';
  //                             });
  //                           },
  //                           dropdownColor:
  //                               Theme.of(context).colorScheme.surface,
  //                           style: const TextStyle(fontSize: 16),
  //                           icon: Icon(
  //                             Icons.arrow_drop_down,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20),
  //                         DropdownButtonFormField<String>(
  //                           value: selectedFertilizerId,
  //                           decoration: InputDecoration(
  //                             labelText: 'Sản phẩm sử dụng',
  //                             labelStyle: TextStyle(
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                               borderSide: BorderSide(
  //                                 color: Theme.of(context).colorScheme.outline,
  //                               ),
  //                             ),
  //                             enabledBorder: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                               borderSide: BorderSide(
  //                                 color:
  //                                     Theme.of(
  //                                       context,
  //                                     ).colorScheme.outlineVariant,
  //                               ),
  //                             ),
  //                             filled: true,
  //                             fillColor:
  //                                 Theme.of(context).colorScheme.surfaceVariant,
  //                             prefixIcon: Icon(
  //                               Icons.science,
  //                               color: Theme.of(context).colorScheme.primary,
  //                             ),
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                               vertical: 12,
  //                             ),
  //                           ),
  //                           items: [
  //                             const DropdownMenuItem(
  //                               value: null,
  //                               child: Text(
  //                                 'Không chọn',
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   color: Colors.black,
  //                                 ),
  //                               ),
  //                             ),
  //                             ...listAdditiveProducts.map(
  //                               (item) => DropdownMenuItem(
  //                                 value: item['id'].toString(),
  //                                 child: Text(
  //                                   item['tensanpham']?.toString() ??
  //                                       'Không có tên',
  //                                   style: const TextStyle(
  //                                     fontSize: 16,
  //                                     color: Colors.black,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                           onChanged:
  //                               (value) => setState(
  //                                 () => selectedFertilizerId = value,
  //                               ),
  //                           dropdownColor:
  //                               Theme.of(context).colorScheme.surface,
  //                           style: const TextStyle(fontSize: 16),
  //                           icon: Icon(
  //                             Icons.arrow_drop_down,
  //                             color: Theme.of(context).colorScheme.primary,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20),
  //                         TextField(
  //                           controller: moTaController,
  //                           maxLines: 4,
  //                           decoration: InputDecoration(
  //                             labelText: 'Mô tả',
  //                             alignLabelWithHint: true,
  //                             labelStyle: TextStyle(
  //                               color: Theme.of(context).colorScheme.primary,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                               borderSide: BorderSide(
  //                                 color: Theme.of(context).colorScheme.outline,
  //                               ),
  //                             ),
  //                             enabledBorder: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                               borderSide: BorderSide(
  //                                 color:
  //                                     Theme.of(
  //                                       context,
  //                                     ).colorScheme.outlineVariant,
  //                               ),
  //                             ),
  //                             filled: true,
  //                             fillColor:
  //                                 Theme.of(context).colorScheme.surfaceVariant,
  //                             prefixIcon: Icon(
  //                               Icons.description,
  //                               color: Theme.of(context).colorScheme.primary,
  //                             ),
  //                             contentPadding: const EdgeInsets.all(16),
  //                           ),
  //                           style: const TextStyle(fontSize: 16),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   bottomNavigationBar: Padding(
  //                     padding: const EdgeInsets.all(20),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: OutlinedButton(
  //                             style: OutlinedButton.styleFrom(
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical: 16,
  //                               ),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12),
  //                               ),
  //                               side: BorderSide(
  //                                 color: Theme.of(context).colorScheme.outline,
  //                               ),
  //                               foregroundColor:
  //                                   Theme.of(context).colorScheme.onSurface,
  //                             ),
  //                             onPressed: () => Navigator.pop(dialogContext),
  //                             child: const Text(
  //                               "Hủy",
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 16),
  //                         Expanded(
  //                           child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical: 16,
  //                               ),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12),
  //                               ),
  //                               backgroundColor:
  //                                   Theme.of(context).colorScheme.primary,
  //                               foregroundColor:
  //                                   Theme.of(context).colorScheme.onPrimary,
  //                               elevation: 2,
  //                             ),
  //                             onPressed:
  //                                 isLoading
  //                                     ? null
  //                                     : () async {
  //                                       if (selectedProcessId == null) {
  //                                         ScaffoldMessenger.of(
  //                                           context,
  //                                         ).showSnackBar(
  //                                           SnackBar(
  //                                             content: const Text(
  //                                               "Vui lòng chọn quy trình chăm sóc",
  //                                             ),
  //                                             behavior:
  //                                                 SnackBarBehavior.floating,
  //                                             backgroundColor:
  //                                                 Theme.of(
  //                                                   context,
  //                                                 ).colorScheme.error,
  //                                             shape: RoundedRectangleBorder(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(8),
  //                                             ),
  //                                           ),
  //                                         );
  //                                         return;
  //                                       }
  //
  //                                       setState(() => isLoading = true);
  //                                       try {
  //                                         final response = await _processingHistoryService
  //                                             .createProcessingHistoryService({
  //                                               "hoatdong":
  //                                                   selectedProcessId != null
  //                                                       ? (listProductionProcess.firstWhere(
  //                                                             (p) =>
  //                                                                 p['id']
  //                                                                     .toString() ==
  //                                                                 selectedProcessId,
  //                                                             orElse:
  //                                                                 () => {
  //                                                                   'tenhoatdong':
  //                                                                       '',
  //                                                                 },
  //                                                           )['tenhoatdong'] ??
  //                                                           '')
  //                                                       : '',
  //                                               "sanphamsudung":
  //                                                   selectedFertilizerId != null
  //                                                       ? (listAdditiveProducts.firstWhere(
  //                                                             (p) =>
  //                                                                 p['id']
  //                                                                     .toString() ==
  //                                                                 selectedFertilizerId,
  //                                                             orElse:
  //                                                                 () => {
  //                                                                   'tensanpham':
  //                                                                       null,
  //                                                                 },
  //                                                           )['tensanpham'] ??
  //                                                           '')
  //                                                       : '',
  //                                               "ghichu": moTaController.text,
  //                                             });
  //
  //                                         if (response["status"] == true ||
  //                                             response["code"] == 200) {
  //                                           ScaffoldMessenger.of(
  //                                             context,
  //                                           ).showSnackBar(
  //                                             SnackBar(
  //                                               content: const Text(
  //                                                 "Thêm mới thành công!",
  //                                               ),
  //                                               behavior:
  //                                                   SnackBarBehavior.floating,
  //                                               backgroundColor: Colors.green,
  //                                               shape: RoundedRectangleBorder(
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(8),
  //                                               ),
  //                                             ),
  //                                           );
  //                                           await _loadProcessingHistory();
  //                                         } else {
  //                                           ScaffoldMessenger.of(
  //                                             context,
  //                                           ).showSnackBar(
  //                                             SnackBar(
  //                                               content: Text(
  //                                                 "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
  //                                               ),
  //                                               behavior:
  //                                                   SnackBarBehavior.floating,
  //                                               backgroundColor:
  //                                                   Theme.of(
  //                                                     context,
  //                                                   ).colorScheme.error,
  //                                               shape: RoundedRectangleBorder(
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(8),
  //                                               ),
  //                                             ),
  //                                           );
  //                                         }
  //                                       } catch (e) {
  //                                         ScaffoldMessenger.of(
  //                                           context,
  //                                         ).showSnackBar(
  //                                           SnackBar(
  //                                             content: Text(
  //                                               "Lỗi khi thêm mới: $e",
  //                                             ),
  //                                             behavior:
  //                                                 SnackBarBehavior.floating,
  //                                             backgroundColor:
  //                                                 Theme.of(
  //                                                   context,
  //                                                 ).colorScheme.error,
  //                                             shape: RoundedRectangleBorder(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(8),
  //                                             ),
  //                                           ),
  //                                         );
  //                                         print("Lỗi khi thêm mới: $e");
  //                                       } finally {
  //                                         setState(() => isLoading = false);
  //                                         Navigator.pop(dialogContext);
  //                                       }
  //                                     },
  //                             child:
  //                                 isLoading
  //                                     ? const SizedBox(
  //                                       height: 20,
  //                                       width: 20,
  //                                       child: CircularProgressIndicator(
  //                                         strokeWidth: 2,
  //                                         color: Colors.white,
  //                                       ),
  //                                     )
  //                                     : const Text(
  //                                       "Thêm",
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                         fontWeight: FontWeight.w600,
  //                                       ),
  //                                     ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //   );
  // }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(raw);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return 'Không xác định';
    }
  }

  // void _confirmDelete(Map<String, dynamic> history) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (dialogContext) => Dialog(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(16),
  //               color: Theme.of(context).colorScheme.surface,
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 AppBar(
  //                   title: const Text("Xác nhận xóa"),
  //                   automaticallyImplyLeading: false,
  //                   actions: [
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.pop(dialogContext),
  //                     ),
  //                   ],
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(16),
  //                   child: Text(
  //                     "Bạn có chắc chắn muốn xóa lịch sử chế biến '${history["tenhoatdong"]}' không?",
  //                     style: const TextStyle(fontSize: 16),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(16),
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: OutlinedButton(
  //                           style: OutlinedButton.styleFrom(
  //                             padding: const EdgeInsets.symmetric(vertical: 16),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           onPressed: () => Navigator.pop(dialogContext),
  //                           child: const Text("Hủy"),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 16),
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor:
  //                                 Theme.of(context).colorScheme.error,
  //                             foregroundColor:
  //                                 Theme.of(context).colorScheme.onError,
  //                             padding: const EdgeInsets.symmetric(vertical: 16),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           onPressed: () async {
  //                             Navigator.pop(dialogContext);
  //                             setState(() => _isLoading = true);
  //                             try {
  //                               final response = await _processingHistoryService
  //                                   .deleteProcessingHistoryService(
  //                                     history["id"],
  //                                     {"_method": "DELETE"},
  //                                   );
  //                               if (response["status"] == true ||
  //                                   response["code"] == 200) {
  //                                 ScaffoldMessenger.of(context).showSnackBar(
  //                                   const SnackBar(
  //                                     content: Text("Xóa lịch sử thành công."),
  //                                   ),
  //                                 );
  //                                 await _loadProcessingHistory();
  //                               } else {
  //                                 ScaffoldMessenger.of(context).showSnackBar(
  //                                   SnackBar(
  //                                     content: Text(
  //                                       "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}",
  //                                     ),
  //                                   ),
  //                                 );
  //                               }
  //                             } catch (e) {
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 SnackBar(
  //                                   content: Text("Lỗi khi xóa lịch sử: $e"),
  //                                 ),
  //                               );
  //                             } finally {
  //                               setState(() => _isLoading = false);
  //                             }
  //                           },
  //                           child: const Text("Xóa"),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử chế biến"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    : filteredProcessingHistory.isEmpty
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
                      itemCount: filteredProcessingHistory.length,
                      itemBuilder: (context, index) {
                        final history = filteredProcessingHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            // onTap: () => _showProcessingHistoryDetails(history),
                            onTap: () {},
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
                                          history["hoatdong"]?.toString() ??
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
                                                onTap: () {}
                                                    // () => Future.delayed(
                                                    //   Duration.zero,
                                                    //   () => _showProcessingHistoryDetails(history,),
                                                    // ),
                                              ),
                                              PopupMenuItem(
                                                child: const Text('Chỉnh sửa'),
                                                onTap:
                                                    () => Future.delayed(
                                                      Duration.zero,
                                                      () => _showEditDialog(
                                                        history,
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
                                                onTap: () {}
                                                    // () => Future.delayed(
                                                    //   Duration.zero,
                                                    //   () => _confirmDelete(
                                                    //     history,
                                                    //   ),
                                                    // ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  if (history["ghichu"] != null &&
                                      history["ghichu"].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        history["ghichu"].toString(),
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
              onPressed: _loadProcessingHistory,
            ),
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
              tooltip: 'Tìm kiếm',
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                    filteredProcessingHistory = List.from(
                      listProcessingHistory,
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _showAddDialog,
        onPressed: () {},
        tooltip: 'Thêm mới',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
