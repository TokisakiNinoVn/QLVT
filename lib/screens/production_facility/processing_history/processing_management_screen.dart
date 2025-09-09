import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:txng/services/production_facility/processing_history_service.dart';

import '../../../config/color_config.dart';

class ProcessingManagementScreen extends StatefulWidget {
  const ProcessingManagementScreen({super.key});

  @override
  State<ProcessingManagementScreen> createState() => _ProcessingHistoryScreenState();
}

class _ProcessingHistoryScreenState extends State<ProcessingManagementScreen> {
  static final ProcessingHistoryService _processingHistoryService = ProcessingHistoryService();

  List<Map<String, dynamic>> listAdditiveProducts = [];
  List<Map<String, dynamic>> listProcessingHistory = [];
  List<Map<String, dynamic>> filteredProcessingHistory = [];
  List<Map<String, dynamic>> listSanPhamDauRa = [];


  final TextEditingController _processController = TextEditingController();
  String? selectedProcessId;
  final bool _processError = false;

  bool _isLoading = true;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProcessingHistory();
    _loadListProduct();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _processController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredProcessingHistory = listProcessingHistory.where((history) {
          final searchText = _searchController.text.toLowerCase();
          return (history['tensanpham']?.toString().toLowerCase() ?? '').contains(searchText) ||
              (history['malohang']?.toString().toLowerCase() ?? '').contains(searchText);
        }).toList();
      });
    });
  }

  Future<void> _loadProcessingHistory() async {
    try {
      setState(() => _isLoading = true);
      final response = await _processingHistoryService.getAllProcessingHistoryService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listProcessingHistory = rawData
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .where((item) => item['khoiluong_thanhpham'] == null)
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _loadListProduct() async {
    try {
      setState(() => _isLoading = true);
      final response = await _processingHistoryService.getListProductService();
      final rawData = response["data"];

      if (rawData is List) {
        setState(() {
          listSanPhamDauRa = rawData.whereType<Map<String, dynamic>>().toList();
        });
      } else {
        throw Exception("Dữ liệu trả về không phải là danh sách");
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
      print('Lỗi khi tải dữ liệu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOutputProductDialog(Map<String, dynamic> history) {
    String? selectedProductId;
    String customProductName = history['thanhpham']?.toString() ?? '';
    bool localProcessError = false;

    // Set initial value for controller
    _processController.text = customProductName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn hoặc nhập sản phẩm đầu ra'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAutocompleteField(
                label: 'Sản phẩm đầu ra',
                controller: _processController,
                options: listSanPhamDauRa,
                getSelectedId: () => selectedProductId,
                setSelectedId: (id) => setState(() {
                  selectedProductId = id;
                  localProcessError = false;
                }),
                errorState: localProcessError,
                setErrorState: (error) => setState(() => localProcessError = error),
                fieldKey: 'tensanpham',
                icon: Icons.pages_outlined,
                onTextChanged: (text) => setState(() {
                  customProductName = text;
                  // If text doesn't match any existing product, clear selected ID
                  final matchedItem = listSanPhamDauRa.firstWhere(
                        (item) => item['tensanpham']?.toString() == text,
                    orElse: () => {'id': null},
                  );
                  selectedProductId = matchedItem['id']?.toString();
                  localProcessError = text.isEmpty;
                }),
              ),
              if (localProcessError)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Vui lòng chọn hoặc nhập sản phẩm đầu ra.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (customProductName.isEmpty) {
                setState(() {
                  localProcessError = true;
                });
                return;
              }

              try {
                Map<String, dynamic> data = {
                  'malohang': history['malohang'],
                  'thanhpham': customProductName,
                };

                // If a predefined product is selected, include its ID
                if (selectedProductId != null) {
                  data['sanpham_id'] = selectedProductId;
                }

                await _processingHistoryService.chonSanPhamDauRaProcessingHistoryService(data);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã cập nhật sản phẩm đầu ra: $customProductName',
                    ),
                  ),
                );

                // Refresh the history list after update
                await _loadProcessingHistory();
              } catch (e, stackTrace) {
                print('Lỗi khi cập nhật sản phẩm đầu ra: $e');
                print(stackTrace);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xảy ra lỗi khi cập nhật sản phẩm đầu ra.'),
                  ),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(Map<String, dynamic> history) {
    final TextEditingController weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập khối lượng thành phẩm'),
        content: TextField(
          controller: weightController,
          decoration: const InputDecoration(labelText: 'Khối lượng (kg)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final weight = weightController.text;
              if (weight.isNotEmpty) {
                try {
                  Map<String, dynamic> data = {
                    'malohang': history['malohang'],
                    'khoiluong_thanhpham': weight,
                  };
                  await _processingHistoryService.hoanThanhLoHangProcessingHistoryService(data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cập nhật khối lượng: $weight kg')),
                  );
                  await _loadProcessingHistory();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật khối lượng: $e')),
                  );
                }
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showShipmentDetailsDialog(Map<String, dynamic> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết lô hàng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', history['id']?.toString() ?? 'Không xác định'),
              _buildDetailRow('Mã lô hàng', history['malohang'] ?? 'Không xác định'),
              _buildDetailRow('Tên sản phẩm', history['tensanpham'] ?? 'Không xác định'),
              _buildDetailRow('Ngày thu hoạch', _formatDate(history['ngaythuhoach'])),
              _buildDetailRow('Khối lượng', history['khoiluong'] != null ? '${history['khoiluong']} kg' : 'Không xác định'),
              _buildDetailRow('Ngày tạo', _formatDateTime(history['created_at'])),
              _buildDetailRow('Ngày cập nhật', _formatDateTime(history['updated_at'])),
              _buildDetailRow('QR Code', history['qrcode'] ?? 'Không xác định'),
              _buildDetailRow('Lịch sử chăm sóc', history['lichsu_chamsoc']?.toString() ?? 'Không có'),
              _buildDetailRow('Lịch sử chế biến', history['lichsu_chebien']?.toString() ?? 'Không có'),
              _buildDetailRow('Lịch sử vận chuyển', history['lichsu_vanchuyen']?.toString() ?? 'Không có'),
              _buildDetailRow('Mã vùng trồng', history['mavungtrong']?.toString() ?? 'Không xác định'),
              _buildDetailRow('Mã doanh nghiệp', history['madoanhnghiep']?.toString() ?? 'Không xác định'),
              _buildDetailRow('Trạng thái', history['trangthai'] ?? 'Không xác định'),
              _buildDetailRow('In ảnh', history['inanh'] == 0 ? 'Không' : 'Có'),
              _buildDetailRow('Phân loại sản phẩm', history['phanloai_sanpham']?.toString() ?? 'Không xác định'),
              _buildDetailRow('Thành phẩm', history['thanhpham'] ?? 'Không xác định'),
              _buildDetailRow('Khối lượng thành phẩm', history['khoiluong_thanhpham'] != null ? '${history['khoiluong_thanhpham']} kg' : 'Không xác định'),
              _buildDetailRow('Mã sản phẩm', history['masanpham']?.toString() ?? 'Không xác định'),
              _buildDetailRow('Số lượng sản phẩm', history['soluong_sanpham']?.toString() ?? 'Không xác định'),
              _buildDetailRow('Khối lượng dư', history['khoiluong_du'] != null ? '${history['khoiluong_du']} kg' : 'Không xác định'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Không xác định';
    try {
      final dateTime = DateTime.parse(raw);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return 'Không xác định';
    }
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Không xác định';
    try {
      final dateTime = DateTime.parse(raw);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý chế biến"),
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 80 : 0,
            child: _isSearchVisible
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Tìm kiếm theo tên hoặc mã lô hàng',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProcessingHistory.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không có lô hàng nào',
                    style: TextStyle(fontSize: 18),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    history["tensanpham"]?.toString() ?? 'Không có tên',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Mã lô: ${history["malohang"]}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Ngày thu hoạch: ${_formatDate(history["ngaythuhoach"])}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.table_chart_rounded,
                                size: 26,
                                color: Colors.blueGrey[600],
                              ),
                              onPressed: () {
                                _showOutputProductDialog(history);
                              },
                              tooltip: 'Cập nhật SP đầu ra',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.real_estate_agent,
                                size: 26,
                                color: Colors.blueGrey[600],
                              ),
                              // onPressed: () {
                              //   context.go('/processing-management/processing-history/${history['malohang']}');
                              //
                              // },
                              onPressed: () async {
                                final result = await context.push('/processing-management/processing-history/${history['malohang']}');
                                if (result == true) {
                                  _loadProcessingHistory();
                                }
                              } ,
                              tooltip: 'Lịch sử chế biến',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.check,
                                size: 26,
                                color: Colors.blueGrey[600],
                              ),
                              onPressed: () {
                                _showCompleteDialog(history);
                              },
                              tooltip: 'Hoàn thành',
                            ),
                            // IconButton(
                            //   icon: Icon(
                            //     Icons.info,
                            //     size: 26,
                            //     color: Colors.blueGrey[600],
                            //   ),
                            //   onPressed: () {
                            //     _showShipmentDetailsDialog(history);
                            //   },
                            //   tooltip: 'Chi tiết lô hàng',
                            // ),
                          ],
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
                    filteredProcessingHistory = List.from(listProcessingHistory);
                  }
                });
              },
            ),
          ],
        ),
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
    required Function(String) onTextChanged,
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
                color: errorState ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            prefixIcon: Icon(
              icon,
              color: errorState ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
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
                    orElse: () => {'id': null, fieldKey: ''},
                  );
                  final id = selectedItem['id']?.toString();
                  setSelectedId(id);
                  setErrorState(false);
                  onTextChanged(value);
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  if (label == 'Sản phẩm đầu ra')
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
          onChanged: onTextChanged,
        ),
      ],
    );
  }
}