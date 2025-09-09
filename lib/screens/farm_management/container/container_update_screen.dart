import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../helpers/snackbar_helper.dart';
import '../../../services/farm_management/container_service.dart';
import '../../../services/farm_management/harvest_packaging_service.dart';

class ContainerUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> container;

  const ContainerUpdateScreen({super.key, required this.container});

  @override
  State<ContainerUpdateScreen> createState() => _ContainerUpdateScreenState();
}

class _ContainerUpdateScreenState extends State<ContainerUpdateScreen> {
  final ContainerService _transportService = ContainerService();
  final HarvestPackagingService _harvestPackagingService = HarvestPackagingService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _listHarvestPackaging = [];
  List<String> _selectedHarvestPackagingIds = [];

  final _weightController = TextEditingController();
  final _shippingDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shippingDateController.text = DateFormat('yyyy-MM-dd').format(
      DateTime.parse(widget.container['created_at'] ?? DateTime.now().toString()),
    );
    _loadListHarvestPackaging();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _shippingDateController.dispose();
    super.dispose();
  }

  void _initializeSelectedHarvests() {
    final lohang = List<String>.from(widget.container['lohang'] ?? []);
    _selectedHarvestPackagingIds = _listHarvestPackaging
        .where((harvest) => lohang.contains(harvest['malohang']))
        .map((harvest) => harvest['id'].toString())
        .toList();
    _weightController.text = widget.container['khoiluong']?.toString() ?? '0';
  }

  Future<void> _loadListHarvestPackaging() async {
    setState(() => _isLoading = true);
    try {
      final response = await _harvestPackagingService.getAllHarvestPackagingService();
      final rawData = response["data"];
      setState(() {
        _listHarvestPackaging = List<Map<String, dynamic>>.from(rawData);
        _initializeSelectedHarvests();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải thông tin lô hàng: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateContainer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final selectedHarvests = _listHarvestPackaging
          .where((harvest) => _selectedHarvestPackagingIds.contains(harvest['id'].toString()))
          .map((harvest) => harvest['malohang'].toString())
          .toList();

      final Map<String, dynamic> data = {
        'lohang': selectedHarvests,
        'ngaygui': _shippingDateController.text,
      };

      await _transportService.updateContainerService(widget.container['id'], data);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Cập nhật công hàng thành công!"),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      SnackbarHelper.showSuccess(context, "Cập nhật công hàng thành công!");

      context.go("/transport-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật công hàng: $e"), backgroundColor: Colors.redAccent),
      );
      print("Lỗi khi cập nhật công hàng: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Cập nhật công hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _updateContainer,
            tooltip: 'Lưu',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[900]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thông tin công hàng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MultiSelectDialogField(
                      items: _listHarvestPackaging.map((harvest) {
                        return MultiSelectItem<String>(
                          harvest['id'].toString(),
                          '${harvest['malohang']}\n${harvest['tensanpham']} (${harvest['khoiluong']})',
                        );
                      }).toList(),
                      initialValue: _selectedHarvestPackagingIds,
                      title: const Text(
                        "Chọn lô hàng",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      selectedColor: Colors.green[600],
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      buttonIcon: Icon(Icons.inventory_2, color: Colors.green[600]),
                      buttonText: Text(
                        _selectedHarvestPackagingIds.isEmpty
                            ? "Chọn lô hàng"
                            : "${_selectedHarvestPackagingIds.length} lô hàng đã chọn",
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onConfirm: (values) {
                        setState(() {
                          _selectedHarvestPackagingIds = List<String>.from(values);
                          int totalWeight = 0;
                          for (var id in values) {
                            final harvest = _listHarvestPackaging.firstWhere(
                                  (h) => h['id'].toString() == id,
                              orElse: () => {},
                            );
                            totalWeight += int.tryParse(harvest['khoiluong']?.toString() ?? '0') ?? 0;
                          }
                          _weightController.text = totalWeight.toString();
                        });
                      },
                      validator: (values) {
                        if (values == null || values.isEmpty) {
                          return 'Vui lòng chọn ít nhất một lô hàng';
                        }
                        return null;
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        chipColor: Colors.green[100]!,
                        textStyle: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _weightController,
                  label: "Tổng khối lượng (kg)",
                  icon: Icons.scale,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn lô hàng để tính khối lượng';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Khối lượng phải là số nguyên dương';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _shippingDateController,
                  label: "Ngày gửi",
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.datetime,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_month, color: Colors.green[600]),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _shippingDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày gửi';
                    }
                    try {
                      DateFormat('yyyy-MM-dd').parse(value);
                      return null;
                    } catch (e) {
                      return 'Định dạng ngày không hợp lệ (yyyy-mm-dd)';
                    }
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateContainer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text("Cập nhật công hàng"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[600]),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[600]!, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          labelStyle: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }
}
