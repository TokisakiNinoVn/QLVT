import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter/cupertino.dart';

import '../../../config/color_config.dart';
import '../../../helpers/snackbar_helper.dart';
import '../../../services/farm_management/container_service.dart';
import '../../../services/farm_management/harvest_packaging_service.dart';

class ContainerCreateScreen extends StatefulWidget {
  const ContainerCreateScreen({super.key});

  @override
  State<ContainerCreateScreen> createState() => _ContainerCreateScreenState();
}

class _ContainerCreateScreenState extends State<ContainerCreateScreen> {
  final ContainerService _transportService = ContainerService();
  final HarvestPackagingService _harvestPackagingService = HarvestPackagingService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _listHarvestPackaging = [];
  List<String> _selectedHarvestPackagingIds = [];

  // Text controllers
  final _weightController = TextEditingController();
  final _shippingDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shippingDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadListHarvestPackaging();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _shippingDateController.dispose();
    super.dispose();
  }

  // Hàm để định dạng lại khối lượng
  String _formatWeight(String weight) {
    return weight.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _loadListHarvestPackaging() async {
    setState(() => _isLoading = true);
    try {
      final response = await _harvestPackagingService.getAllNotPackagingHarvestPackagingService();
      final rawData = response["data"];
      setState(() {
        _listHarvestPackaging = List<Map<String, dynamic>>.from(rawData);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải thông tin lô hàng: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createContainer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final selectedHarvests = _listHarvestPackaging.where(
            (harvest) => _selectedHarvestPackagingIds.contains(harvest['id'].toString()),
      ).map((harvest) => harvest['malohang'].toString()).toList();

      final Map<String, dynamic> data = {
        'lohang': selectedHarvests,
        'ngaygui': _shippingDateController.text,
      };

      final response = await _transportService.createContainerService(data);
      SnackbarHelper.showSuccess(context, 'Tạo công hàng thành công');
      Navigator.of(context).pop(true); // Trả về true để báo là có cập nhật
      // context.go("/container-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo công hàng: $e"), backgroundColor: Colors.redAccent),
      );
      print("Lỗi khi tạo công hàng: $e");
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
          "Tạo công hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _createContainer,
            tooltip: 'Lưu',
          ),
        ],
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
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showSelectLohangBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.green[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedHarvestPackagingIds.isEmpty
                                ? 'Chọn lô hàng'
                                : 'Đã chọn ${_selectedHarvestPackagingIds.length} lô hàng',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(Icons.expand_more, color: Colors.green[600])
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Display selected shipments
                if (_selectedHarvestPackagingIds.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lô hàng đã chọn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._selectedHarvestPackagingIds.map((id) {
                          final harvest = _listHarvestPackaging.firstWhere(
                                (h) => h['id'].toString() == id,
                            orElse: () => {},
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mã lô: ${harvest['malohang']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${harvest['khoiluong']} kg',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
                    onPressed: _isLoading ? null : _createContainer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text("Tạo công hàng"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectLohangBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final Set<String> tempSelected = Set.from(_selectedHarvestPackagingIds);
        return StatefulBuilder(
          builder: (context, setModalState) {
            int totalWeight = 0;
            for (var id in tempSelected) {
              final harvest = _listHarvestPackaging.firstWhere(
                    (h) => h['id'].toString() == id,
                orElse: () => {},
              );
              final raw = harvest['khoiluong']?.toString() ?? '0';
              final formatted = _formatWeight(raw);
              totalWeight += int.tryParse(formatted) ?? 0;
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // "Chọn lô hàng ++",
                              "Chọn lô hàng\n(Đang có: ${_listHarvestPackaging.length} lô hàng)",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đã chọn: ${tempSelected.length} lô',
                                style: TextStyle(color: Colors.green[800]),
                              ),
                              Text(
                                'Tổng: $totalWeight kg',
                                style: TextStyle(color: Colors.green[800]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _listHarvestPackaging.length,
                            itemBuilder: (context, index) {
                              final harvest = _listHarvestPackaging[index];
                              final id = harvest['id'].toString();
                              final selected = tempSelected.contains(id);
                              return CheckboxListTile(
                                value: selected,
                                onChanged: (checked) {
                                  setModalState(() {
                                    if (checked == true) {
                                      tempSelected.add(id);
                                    } else {
                                      tempSelected.remove(id);
                                    }
                                  });
                                },
                                title: Text('Mã lô hàng: ${harvest['malohang']}'),
                                subtitle: Text('Sản phẩm: ${harvest['tensanpham']} (${harvest['khoiluong']} kg)'),
                              );
                            },
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.check, color: ColorConfig.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConfig.primary,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedHarvestPackagingIds = tempSelected.toList();

                              int totalWeight = 0;
                              for (var id in _selectedHarvestPackagingIds) {
                                final harvest = _listHarvestPackaging.firstWhere(
                                      (h) => h['id'].toString() == id,
                                  orElse: () => {},
                                );
                                final raw = harvest['khoiluong']?.toString() ?? '0';
                                final formatted = _formatWeight(raw);
                                totalWeight += int.tryParse(formatted) ?? 0;
                              }

                              _weightController.text = totalWeight.toString();
                            });
                          },
                          label: const Text("Xác nhận", style: TextStyle(
                            color: ColorConfig.white,
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

          },
        );
      },
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
    return TextFormField(
      controller: controller,
      enabled: enabled,
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
        labelStyle: TextStyle(color: Colors.green[800]),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}