import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/config/app_config.dart';

import '../../../config/color_config.dart';
import '../../../helpers/snackbar_helper.dart';

class FertilizerMedicineManagementScreen extends StatefulWidget {
  const FertilizerMedicineManagementScreen({super.key});

  @override
  State<FertilizerMedicineManagementScreen> createState() =>
      _FertilizerMedicineManagementScreenState();
}

class _FertilizerMedicineManagementScreenState
    extends State<FertilizerMedicineManagementScreen> {
  static final FertilizerMedicineService _fertilizerMedicineService =
      FertilizerMedicineService();
  late List<Map<String, dynamic>> listFertilizerMedicine = [];
  late List<Map<String, dynamic>> filteredFertilizerMedicines = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadFertilizerMedicines();
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
      _filterFertilizerMedicines();
    });
  }

  Future<void> _loadFertilizerMedicines() async {
    try {
      final response =
          await _fertilizerMedicineService.getAllFertilizerMedicineService();
      final rawData = response["data"]?["phanbon_thuocs"]?["data"];

      if (rawData is List) {
        setState(() {
          listFertilizerMedicine =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          _filterFertilizerMedicines();
        });
      } else {
        setState(() {
          listFertilizerMedicine = [];
          filteredFertilizerMedicines = [];
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

  void _filterFertilizerMedicines() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedFilter == 'all') {
        filteredFertilizerMedicines =
            listFertilizerMedicine.where((fertilizer) {
              final name =
                  fertilizer['tensanpham']?.toString().toLowerCase() ?? '';
              final code =
                  fertilizer['masanpham']?.toString().toLowerCase() ?? '';
              return name.contains(searchTerm) || code.contains(searchTerm);
            }).toList();
      } else {
        filteredFertilizerMedicines =
            listFertilizerMedicine.where((fertilizer) {
              final statusMatch =
                  fertilizer['mahoatdong'] ==
                  (_selectedFilter == 'active' ? 1 : 0);
              if (!statusMatch) return false;
              final name =
                  fertilizer['tensanpham']?.toString().toLowerCase() ?? '';
              final code =
                  fertilizer['masanpham']?.toString().toLowerCase() ?? '';
              return name.contains(searchTerm) || code.contains(searchTerm);
            }).toList();
      }
    });
  }

  Map<String, dynamic>? selectedFertilizerMedicine;

  void _showFertilizerMedicineDetails(Map<String, dynamic> fertilizer) {
    setState(() => selectedFertilizerMedicine = fertilizer);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(0),
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Thông tin chi tiết"),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showFullImage(fertilizer["hinhanh"]),
                      child: Hero(
                        tag: "image-${fertilizer['id']}",
                        child: Image.network(
                          _checkImageLink(fertilizer["hinhanh"]),
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 120,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildFertilizerMedicineInfoList(fertilizer),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            context.go(
                              "/fertilizer-medicine-management/fertilizer-medicine-update/${fertilizer['id']}",
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Chỉnh sửa"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _confirmDelete(fertilizer),
                          icon: const Icon(Icons.delete),
                          label: const Text("Xóa"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
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
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.9),
              body: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: "image-${selectedFertilizerMedicine?['id']}",
                      child: InteractiveViewer(
                        child: Image.network(
                          _checkImageLink(imageUrl),
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 200,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  List<Widget> _buildFertilizerMedicineInfoList(
    Map<String, dynamic> fertilizer,
  ) {
    final entries = {
      "Tên sản phẩm": [Icons.label, fertilizer["tensanpham"]],
      "Mã sản phẩm": [Icons.code, fertilizer["masanpham"]],
      // "Trọng lượng": [Icons.line_weight, fertilizer["trongluong"]],
      // "Kích thước": [Icons.straighten, fertilizer["kichthuoc"]],
      "Mô tả": [Icons.description, fertilizer["mota"]],
      "Trạng thái": [
        Icons.toggle_on,
        fertilizer["mahoatdong"] == 1 ? 'Hoạt động' : 'Không hoạt động',
      ],
      "Ngày tạo": [Icons.calendar_today, _formatDate(fertilizer["created_at"])],
      "Cập nhật gần nhất": [
        Icons.update,
        _formatDate(fertilizer["updated_at"]),
      ],
    };

    return entries.entries.map((e) {
      return ListTile(
        leading: Icon(
          e.value[0] as IconData,
          color: ColorConfig.primary,
        ),
        title: Text(
          "${e.key}:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          e.value[1]?.toString() ?? '',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }).toList();
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

  String _checkImageLink(String imagePath) {
    if (imagePath.isEmpty) {
      return "https://i.pinimg.com/736x/35/51/aa/3551aa1febb5d532e2e1909f00c23074.jpg";
    }
    if (!imagePath.startsWith('http')) {
      return "${AppConfig.apiUrlImage}/$imagePath";
    }
    return imagePath;
  }

  void _confirmDelete(Map<String, dynamic> fertilizer) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: Text(
              "Bạn có chắc chắn muốn xóa '${fertilizer["tensanpham"]}' không?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  setState(() => _isLoading = true);
                  try {
                    final response = await _fertilizerMedicineService
                        .deleteFertilizerMedicineService(fertilizer["id"], {
                          "_method": "DELETE",
                        });
                    if (response["status"] == true || response["code"] == 200) {
                      setState(() {
                        listFertilizerMedicine.removeWhere(
                          (item) => item["id"] == fertilizer["id"],
                        );
                        _filterFertilizerMedicines();
                      });
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Đã xóa thành công.")),
                      // );
                      SnackbarHelper.showSuccess(context, "Đã xóa thành công.");
                    } else {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text(
                      //       "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                      //     ),
                      //   ),
                      // );
                      SnackbarHelper.showError(context, "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}");
                    }
                  } catch (e) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text("Lỗi khi xóa sản phẩm: $e")),
                    // );
                    SnackbarHelper.showError(context, "Lỗi khi xóa sản phẩm: $e");

                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text("Xóa"),
              ),
            ],
          ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lọc theo trạng thái',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _selectedFilter == 'all',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'all';
                          _filterFertilizerMedicines();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Hoạt động'),
                      selected: _selectedFilter == 'active',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'active';
                          _filterFertilizerMedicines();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Không hoạt động'),
                      selected: _selectedFilter == 'inactive',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'inactive';
                          _filterFertilizerMedicines();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý vật tư"),
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: _loadFertilizerMedicines,
        //     tooltip: 'Làm mới',
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.add_circle_outline),
        //     onPressed:
        //         () => context.push(
        //           '/fertilizer-medicine-management/fertilizer-medicine-create',
        //         ),
        //     tooltip: 'Thêm sản phẩm',
        //   ),
        //   // IconButton(
        //   //   icon: const Icon(Icons.filter_alt),
        //   //   onPressed: _showFilterBottomSheet,
        //   //   tooltip: 'Lọc sản phẩm',
        //   // ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên hoặc mã sản phẩm',
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
                    : filteredFertilizerMedicines.isEmpty
                    ? const Center(child: Text('Không có vật tư nào'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredFertilizerMedicines.length,
                      itemBuilder: (context, index) {
                        final fertilizer = filteredFertilizerMedicines[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap:
                                () =>
                                    _showFertilizerMedicineDetails(fertilizer),
                            leading: Image.network(
                              _checkImageLink(fertilizer["hinhanh"]),
                              width: 70,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                  ),
                            ),
                            title: Text(
                              fertilizer["tensanpham"] ?? 'Không có tên',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fertilizer["masanpham"] ?? "Không có mã",
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                // Text(
                                //   fertilizer["mahoatdong"] == 1
                                //       ? 'Hoạt động'
                                //       : 'Không hoạt động',
                                //   style: TextStyle(
                                //     color:
                                //         fertilizer["mahoatdong"] == 1
                                //             ? Theme.of(
                                //               context,
                                //             ).colorScheme.primary
                                //             : Theme.of(
                                //               context,
                                //             ).colorScheme.secondary,
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                // ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color:
                                        ColorConfig.primary,
                                  ),
                                  onPressed: () {
                                    context.push(
                                      '/fertilizer-medicine-management/fertilizer-medicine-update/${fertilizer['id']}',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _confirmDelete(fertilizer),
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
              onPressed: _loadFertilizerMedicines,
            ),
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Thêm mới',
              onPressed: () {
                context.go('/fertilizer-medicine-management/fertilizer-medicine-create');
              },
            ),
          ],
        ),
      ),
    );
  }
}
