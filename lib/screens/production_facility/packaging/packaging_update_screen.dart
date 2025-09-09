import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txng/services/farm_management/plantingarea_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../services/farm_management/harvest_packaging_service.dart';

class HarvestPackagingUpdateScreen extends StatefulWidget {
  final String code; // Change from String? to String
  const HarvestPackagingUpdateScreen({super.key, required this.code});

  @override
  State<HarvestPackagingUpdateScreen> createState() =>
      _HarvestPackagingUpdateScreenState();
}

class _HarvestPackagingUpdateScreenState
    extends State<HarvestPackagingUpdateScreen> {
  final HarvestPackagingService _harvestPackagingService =
      HarvestPackagingService();
  final PlantingAreaService _plantingAreaService = PlantingAreaService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _plantingAreas = [];
  Map<String, dynamic> _harvestPackagingInfo = {};
  String? _selectedPlantingAreaId;

  // Text controllers
  final _codeHarvestPackagingController = TextEditingController();
  final _weightController = TextEditingController();
  final _productNameController = TextEditingController();
  final _harvestDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeHarvestPackagingController.text = widget.code;
    _harvestDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
    _loadPlantingAreas();
    _loadDetailsHarvestPackaging();
  }

  @override
  void dispose() {
    _codeHarvestPackagingController.dispose();
    _weightController.dispose();
    _productNameController.dispose();
    _harvestDateController.dispose();
    super.dispose();
  }

  Future<void> _loadDetailsHarvestPackaging() async {
    setState(() => _isLoading = true);
    try {
      final response = await _harvestPackagingService
          .getDetailsHarvestPackagingService(widget.code);
      final rawData = response["data"];
      setState(() {
        _harvestPackagingInfo = rawData;
        _codeHarvestPackagingController.text =
            rawData['malohang'] ?? widget.code;
        _weightController.text = rawData['khoiluong']?.toString() ?? '';
        _productNameController.text = rawData['tensanpham'] ?? '';
        _harvestDateController.text =
            rawData['ngaythuhoach'] ??
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        _selectedPlantingAreaId = rawData['mavungtrong']?.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateHarvestPackaging() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = {
        'malohang': _codeHarvestPackagingController.text.trim(),
        'ngaythuhoach': _harvestDateController.text.trim(),
        'khoiluong': int.parse(_weightController.text.trim()),
        'tensanpham': _productNameController.text.trim(),
        'mavungtrong': int.parse(_selectedPlantingAreaId ?? '1'),
      };

      final response = await _harvestPackagingService
          .updateHarvestPackagingService(widget.code, data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thu hoạch thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      context.go("/harvest-packaging-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi cập nhật: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
      print("Lỗi khi cập nhật thu hoạch: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPlantingAreas() async {
    try {
      final response = await _plantingAreaService.getListPlantingAreaService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          _plantingAreas = List<Map<String, dynamic>>.from(rawData);
        });
      } else {
        setState(() {
          _plantingAreas = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải danh sách vùng trồng: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          "Cập nhật thông tin thu hoạch",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _updateHarvestPackaging,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green[50]!, Colors.white],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _codeHarvestPackagingController,
                          label: "Mã lô hàng",
                          icon: Icons.text_snippet,
                          enabled: false, // Disable code field for update
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mã lô hàng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _harvestDateController,
                          label: "Ngày thu hoạch",
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập ngày thu hoạch';
                            }
                            try {
                              DateFormat('yyyy-MM-dd').parse(value);
                              return null;
                            } catch (e) {
                              return 'Định dạng ngày không hợp lệ (yyyy-mm-dd)';
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _weightController,
                          label: "Khối lượng (kg)",
                          icon: Icons.scale,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập khối lượng';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Khối lượng phải là số nguyên dương';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _productNameController,
                          label: "Tên sản phẩm",
                          icon: Icons.local_offer,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên sản phẩm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPlantingAreaId,
                          decoration: InputDecoration(
                            labelText: "Vùng trồng",
                            prefixIcon: Icon(
                              Icons.forest,
                              color: Colors.green[600],
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green[200]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green[600]!,
                                width: 2,
                              ),
                            ),
                            labelStyle: TextStyle(color: Colors.green[800]),
                          ),
                          items:
                              _plantingAreas.map<DropdownMenuItem<String>>((
                                area,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: area['id'].toString(),
                                  child: Text(
                                    area['tenvungtrong'] ?? 'Không rõ',
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlantingAreaId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn vùng trồng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _updateHarvestPackaging,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 40,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text("Cập nhật thu hoạch"),
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
