import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../services/farm_management/harvest_packaging_service.dart';
import '../../../services/farm_management/transport_service.dart';

class TransportCreateQRScreen extends StatefulWidget {
  final String code;
  const TransportCreateQRScreen({super.key, required this.code});

  @override
  State<TransportCreateQRScreen> createState() => _TransportCreateQRScreenState();
}

class _TransportCreateQRScreenState extends State<TransportCreateQRScreen> {
  final TransportService _transportService = TransportService();
  final HarvestPackagingService _harvestPackagingService = HarvestPackagingService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _listTaiXe = [];
  // List<Map<String, dynamic>> _listDiemGui = [];
  List<Map<String, dynamic>> _listDiemNhan = [];
  List<Map<String, dynamic>> _listHarvestPackaging = [];
  Map<String, dynamic> _harvestPackagingInfo = {};

  String? _selectedTaiXeId;
  String? _selectedDiemGuiId;
  String? _selectedDiemNhanId;

  // Text controllers
  final _codeTransportController = TextEditingController();
  final _weightController = TextEditingController();
  final _productNameController = TextEditingController();
  final _shippingDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeTransportController.text = widget.code;
    _shippingDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadListTaiXe();
    _loadListDiemGuiNhan();
    _loadDetailsHarvestPackaging();
  }

  @override
  void dispose() {
    _codeTransportController.dispose();
    _weightController.dispose();
    _productNameController.dispose();
    _shippingDateController.dispose();
    super.dispose();
  }

  Future<void> _loadDetailsHarvestPackaging() async {
    setState(() => _isLoading = true);
    try {
      final response = await _harvestPackagingService.getDetailsHarvestPackagingService(widget.code);
      final rawData = response["data"];
      setState(() {
        _harvestPackagingInfo = rawData;
        _codeTransportController.text = rawData['malohang'] ?? widget.code;
        _weightController.text = rawData['khoiluong']?.toString() ?? '';
        _productNameController.text = rawData['tensanpham'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải thông tin lô hàng: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadListTaiXe() async {
    try {
      final response = await _transportService.getListTaiXeTransportService();
      final rawData = response["data"];
      print('DS taixxe: $rawData');
      if (rawData is List) {
        setState(() {
          _listTaiXe = List<Map<String, dynamic>>.from(rawData);
          if (_listTaiXe.isNotEmpty) _selectedTaiXeId = _listTaiXe[0]['id'].toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải danh sách tài xế: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _loadListDiemGuiNhan() async {
    try {
      // Giả định có API lấy danh sách điểm gửi/nhận, bạn cần thay bằng API thực tế
      final responseNhan = await _transportService.getListDiemNhanService();
      setState(() {
        _listDiemNhan = List<Map<String, dynamic>>.from(responseNhan["data"] ?? []);
        if (_listDiemNhan.isNotEmpty) _selectedDiemNhanId = _listDiemNhan[0]['id'].toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải danh sách điểm gửi/nhận: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _createTransport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = {
        'malohang': _codeTransportController.text.trim(),
        'mataixe': int.parse(_selectedTaiXeId ?? '0'),
        'soluong': int.parse(_weightController.text.trim()),
        'trangthai': "dang_cho",
        'ngaygui': _shippingDateController.text.trim(),
        'madiemgui': int.parse(_selectedDiemGuiId ?? '0'),
        'madiemnhan': int.parse(_selectedDiemNhanId ?? '0'),
        // 'tensanpham': _productNameController.text.trim(),
      };

      final response = await _transportService.createTransportService(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tạo đơn vận chuyển thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      context.go("/transport-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo đơn vận chuyển: $e"), backgroundColor: Colors.redAccent),
      );
      print("Lỗi khi tạo đơn vận chuyển: $e");
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
          "Tạo đơn vận chuyển",
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
            onPressed: _isLoading ? null : _createTransport,
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
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _codeTransportController,
                  label: "Mã lô hàng",
                  icon: Icons.text_snippet,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã lô hàng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _productNameController,
                  label: "Tên sản phẩm",
                  icon: Icons.local_offer,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _weightController,
                  label: "Khối lượng (kg)",
                  icon: Icons.scale,
                  keyboardType: TextInputType.number,
                  // enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập khối lượng';
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTaiXeId,
                  decoration: InputDecoration(
                    labelText: "Tài xế",
                    prefixIcon: Icon(Icons.person, color: Colors.green[600]),
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
                  items: _listTaiXe.map<DropdownMenuItem<String>>((taiXe) {
                    return DropdownMenuItem<String>(
                      value: taiXe['id'].toString(),
                      child: Text(taiXe['hoten'] ?? 'Không rõ'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTaiXeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn tài xế';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // DropdownButtonFormField<String>(
                //   value: _selectedDiemGuiId,
                //   decoration: InputDecoration(
                //     labelText: "Điểm gửi",
                //     prefixIcon: Icon(Icons.location_on, color: Colors.green[600]),
                //     filled: true,
                //     fillColor: Colors.white,
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide.none,
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide(color: Colors.green[200]!, width: 1),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                //     ),
                //     labelStyle: TextStyle(color: Colors.green[800]),
                //   ),
                //   items: _listDiemGui.map<DropdownMenuItem<String>>((diemGui) {
                //     return DropdownMenuItem<String>(
                //       value: diemGui['id'].toString(),
                //       child: Text(diemGui['name'] ?? 'Không rõ'),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       _selectedDiemGuiId = value;
                //     });
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Vui lòng chọn điểm gửi';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDiemNhanId,
                  decoration: InputDecoration(
                    labelText: "Điểm nhận",
                    prefixIcon: Icon(Icons.location_on, color: Colors.green[600]),
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
                  items: _listDiemNhan.map<DropdownMenuItem<String>>((diemNhan) {
                    return DropdownMenuItem<String>(
                      value: diemNhan['id'].toString(),
                      child: Text(diemNhan['tencoso'] ?? 'Không rõ'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDiemNhanId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn điểm nhận';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTransport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                        : const Text("Tạo đơn vận chuyển"),
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