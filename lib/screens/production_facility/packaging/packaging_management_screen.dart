import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/production_facility/packaging_service.dart';
import '../../../services/production_facility/processing_history_service.dart';

class PackagingManagementScreen extends StatefulWidget {
  const PackagingManagementScreen({super.key});

  @override
  State<PackagingManagementScreen> createState() =>
      _PackagingManagementScreenState();
}

class _PackagingManagementScreenState extends State<PackagingManagementScreen> {
  static final PackagingService packagingService = PackagingService();
  static final ProcessingHistoryService _processingHistoryService = ProcessingHistoryService();

  List<Map<String, dynamic>> listPlantingAreas = [];
  List<Map<String, dynamic>> filteredPlantingAreas = [];
  List<Map<String, dynamic>> listSanPhamDauRa = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListPackaging();
    _loadListProduct();
    _searchController.addListener(_filterPackagings);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPackagings);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListPackaging() async {
    try {
      setState(() => _isLoading = true);
      final response = await packagingService.getAllContainerService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listPlantingAreas = List<Map<String, dynamic>>.from(rawData);
          filteredPlantingAreas = listPlantingAreas;
        });
      } else {
        setState(() {
          listPlantingAreas = [];
          filteredPlantingAreas = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu lô hàng: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        throw Exception("Dữ liệu sản phẩm đầu ra không phải là danh sách");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu sản phẩm: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Parse weight and return value in kg
  Map<String, dynamic> _parseWeight(String? weight) {
    if (weight == null || weight.isEmpty) {
      return {'value': 0.0, 'unit': 'kg'};
    }
    try {
      final cleanedWeight = weight.replaceAll(RegExp(r'[^0-9.]'), '');
      final value = double.parse(cleanedWeight);
      return {'value': value, 'unit': 'kg'};
    } catch (e) {
      return {'value': 0.0, 'unit': 'kg'};
    }
  }

  // Format weight for display
  String _formatWeight(double value, String unit) {
    return '${value.toStringAsFixed(2)}kg';
  }

  void _filterPackagings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPlantingAreas = listPlantingAreas.where((area) {
        return (area["malohang"]?.toLowerCase().contains(query) ?? false) ||
            (area["tensanpham"]?.toLowerCase().contains(query) ?? false) ||
            (area["thanhpham"]?.toLowerCase().contains(query) ?? false) ||
            (_formatDate(area["ngaythuhoach"]).contains(query));
      }).toList();
    });
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Chưa có';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw;
    }
  }

  Widget _buildPackagingCard(Map<String, dynamic> plantingArea) {
    final khoiluongThanhpham = _parseWeight(plantingArea["khoiluong_thanhpham"]);
    final khoiluong = _parseWeight(plantingArea["khoiluong"]);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Mã lô: ${plantingArea["malohang"] ?? 'Không có mã'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Sản phẩm: ${plantingArea["tensanpham"] ?? 'Không có tên'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  'Khối lượng thành phẩm: ${_formatWeight(khoiluongThanhpham['value'], khoiluongThanhpham['unit'])}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_box, color: Colors.green),
                      tooltip: 'Đóng gói thành phẩm',
                      onPressed: () => _showCreatePackaging(plantingArea),
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code, color: Colors.green),
                      tooltip: 'Mã QR',
                      onPressed: () {},
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _isSearching = false;
        _searchController.clear();
        context.go("/create-packaging");
      } else if (index == 1) {
        _isSearching = true;
      }
    });
  }

  final TextEditingController _processController = TextEditingController();
  final TextEditingController _packageCountController = TextEditingController();

  void _showCreatePackaging(Map<String, dynamic> history) {
    String? selectedProductId;
    String? selectedProductName;
    double selectedProductWeight = 0.0;
    String selectedProductUnit = 'kg';
    int packageCount = 0;
    bool localProcessError = false;
    bool localPackageError = false;
    bool weightExceedError = false;

    final availableWeight = _parseWeight(history['khoiluong_thanhpham'])['value'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đóng gói sản phẩm'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mã lô: ${history['malohang']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedProductId,
                  decoration: InputDecoration(
                    labelText: 'Chọn sản phẩm đóng gói',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: localProcessError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    prefixIcon: Icon(
                      Icons.pages_outlined,
                      color: localProcessError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                    ),
                    errorText: localProcessError ? 'Vui lòng chọn sản phẩm' : null,
                  ),
                  items: listSanPhamDauRa.map((item) {
                    final weight = item['khoiluong_thanhpham'] ?? item['trongluong'] ?? '0kg';
                    return DropdownMenuItem<String>(
                      value: item['id']?.toString(),
                      child: Text(
                        '${item['tensanpham']} - ${_formatWeight(_parseWeight(weight)['value'], 'kg')}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProductId = value;
                      final selectedItem = listSanPhamDauRa.firstWhere(
                            (item) => item['id']?.toString() == value,
                        orElse: () => {},
                      );
                      selectedProductName = selectedItem['tensanpham']?.toString();
                      final weightInfo = _parseWeight(selectedItem['khoiluong_thanhpham'] ?? selectedItem['trongluong']);
                      selectedProductWeight = weightInfo['value'];
                      selectedProductUnit = weightInfo['unit'];
                      localProcessError = value == null;
                      weightExceedError = packageCount * selectedProductWeight > availableWeight;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Số lượng gói đóng gói',
                  controller: _packageCountController,
                  errorState: localPackageError,
                  setErrorState: (error) => setState(() => localPackageError = error),
                  icon: Icons.format_list_numbered,
                  onTextChanged: (text) => setState(() {
                    packageCount = int.tryParse(text) ?? 0;
                    localPackageError = packageCount <= 0;
                    weightExceedError = packageCount * selectedProductWeight > availableWeight;
                  }),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(
                  'Khối lượng thành phẩm còn lại: ${_formatWeight(availableWeight - (packageCount * selectedProductWeight), 'kg')}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (localProcessError || localPackageError || weightExceedError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weightExceedError
                          ? 'Khối lượng đóng gói vượt quá khối lượng thành phẩm còn lại.'
                          : 'Vui lòng chọn sản phẩm và nhập số lượng gói hợp lệ.',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedProductId == null || packageCount <= 0 || weightExceedError) {
                setState(() {
                  localProcessError = selectedProductId == null;
                  localPackageError = packageCount <= 0;
                  weightExceedError = packageCount * selectedProductWeight > availableWeight;
                });
                return;
              }

              try {
                final totalWeight = packageCount * selectedProductWeight;
                Map<String, dynamic> data = {
                  'malohang': history['malohang'],
                  'tensanpham': selectedProductName,
                  'khoiluong_thanhpham': _formatWeight(availableWeight - totalWeight, 'kg'),
                  'trongluong': _formatWeight(totalWeight, 'kg'),
                  'soluong': packageCount,
                  'masanpham': selectedProductId,
                };

                await packagingService.createPackagingService(data);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tạo thành phẩm đóng gói: $selectedProductName thành công'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                await _loadListPackaging();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi tạo thành phẩm: $e'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool errorState,
    required Function(bool) setErrorState,
    required IconData icon,
    required Function(String) onTextChanged,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Nhập $label',
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorText: errorState ? 'Vui lòng nhập $label hợp lệ' : null,
          ),
          onChanged: onTextChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7EF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: _isSearching
                    ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Tìm theo mã lô, tên sản phẩm, thành phẩm, ngày thu hoạch",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.black87),
                )
                    : const Text(
                  "Quản lý đóng gói",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh, size: 26, color: Colors.blueGrey[600]),
                    onPressed: _loadListPackaging,
                    tooltip: 'Làm mới',
                  ),
                  if (!_isSearching)
                    IconButton(
                      icon: Icon(Icons.search, size: 26, color: Colors.blueGrey[600]),
                      onPressed: () => setState(() => _isSearching = true),
                      tooltip: 'Tìm kiếm',
                    ),
                  if (_isSearching)
                    IconButton(
                      icon: Icon(Icons.close, size: 26, color: Colors.blueGrey[600]),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                          _filterPackagings();
                        });
                      },
                      tooltip: 'Hủy tìm kiếm',
                    ),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.blueGrey[600]))
                    : filteredPlantingAreas.isEmpty
                    ? Center(
                  child: Text(
                    "Không có dữ liệu lô hàng.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filteredPlantingAreas.length,
                  itemBuilder: (context, index) {
                    final packaging = filteredPlantingAreas[index];
                    return _buildPackagingCard(packaging);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}