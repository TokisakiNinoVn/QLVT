import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../helpers/snackbar_helper.dart';
import '../../../services/production_facility/reception_service.dart';

class ReceptionCreateQRScreen extends StatefulWidget {
  final String code;
  const ReceptionCreateQRScreen({super.key, required this.code});

  @override
  State<ReceptionCreateQRScreen> createState() => _ReceptionCreateQRScreenState();
}

class _ReceptionCreateQRScreenState extends State<ReceptionCreateQRScreen> {
  final ReceptionService _receptionService = ReceptionService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _receptionInfo = {};

  // Text controllers
  final _codeReceptionController = TextEditingController();
  final _dateReceiveController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedTinhtrang = 'Đủ hàng';

  @override
  void initState() {
    super.initState();
    _codeReceptionController.text = widget.code;
    _dateReceiveController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadDetailsReception();
  }

  @override
  void dispose() {
    _codeReceptionController.dispose();
    _dateReceiveController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDetailsReception() async {
    setState(() => _isLoading = true);
    try {
      final response = await _receptionService.getDetailsReceptionService(widget.code);
      print('data response: $response');
      final rawData = response["data"];
      setState(() {
        _receptionInfo = rawData;
        _codeReceptionController.text = rawData['thongtin_donvan']?['madonvan'] ?? widget.code;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải thông tin lô hàng: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createReception() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = {
        'madonvan': widget.code,
        'tinhtrang': _selectedTinhtrang == 'Đủ hàng' ? 'du_hang' : 'khong_du_hang',
        'ghichu': _noteController.text,
        'ngaynhan': _dateReceiveController.text,
      };

      final response = await _receptionService.createReceptionService(data);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Tiếp nhận đơn hàng thành công!"),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      SnackbarHelper.showSuccess(context, 'Tiếp nhận đơn hàng thành công!');
      context.go("/reception-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo tiếp nhận đơn hàng: $e"), backgroundColor: Colors.redAccent),
      );
      print("Lỗi khi tạo tiếp nhận đơn hàng: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chi tiết đơn vận',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailSection('Thông tin đơn vận', [
                _buildDetailRow('Mã đơn vận', _receptionInfo['thongtin_donvan']?['madonvan']),
                _buildDetailRow('Mã công hàng', _receptionInfo['thongtin_donvan']?['maconghang']),
                _buildDetailRow('Trạng thái', _receptionInfo['thongtin_donvan']?['trangthai']),
                _buildDetailRow('Ngày gửi', _receptionInfo['thongtin_donvan']?['ngaygui']),
              ]),
              _buildDetailSection('Thông tin điểm gửi', [
                _buildDetailRow('Tên trang trại', _receptionInfo['thongtin_diemgui']?['tentrangtrai']),
                _buildDetailRow('Chủ sở hữu', _receptionInfo['thongtin_diemgui']?['chusohuu']),
                _buildDetailRow('Địa chỉ', _receptionInfo['thongtin_diemgui']?['diachi']),
                _buildDetailRow('Số điện thoại', _receptionInfo['thongtin_diemgui']?['sodienthoai']),
                // _buildDetailRow('Email', _receptionInfo['thongtin_diemgui']?['email']),
              ]),
              _buildDetailSection('Thông tin tài xế', [
                _buildDetailRow('Họ tên', _receptionInfo['thongtin_donvan']?['mataixe']),
                // _buildDetailRow('Ngày sinh', _receptionInfo['thongtin_taixe']?['ngaysinh']),
                // _buildDetailRow('Số điện thoại', _receptionInfo['thongtin_taixe']?['sodienthoai']),
                // _buildDetailRow('Địa chỉ', _receptionInfo['thongtin_taixe']?['diachi']),
              ]),
              _buildDetailSection('Thông tin xe', [
                _buildDetailRow('Loại xe', _receptionInfo['thongtin_donvan']?['maxe']),
                // _buildDetailRow('Biển số', _receptionInfo['thongtin_xe']?['bienso']),
                // _buildDetailRow('Chủ sở hữu', _receptionInfo['thongtin_xe']?['chusohuu']),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
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
          "Tiếp nhận đơn hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _createReception,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _codeReceptionController,
                  label: "Mã đơn vận",
                  icon: Icons.text_snippet,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã lô hàng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _dateReceiveController,
                  label: "Ngày nhận",
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày nhận';
                    }
                    try {
                      DateFormat('yyyy-MM-dd').parse(value);
                      return null;
                    } catch (e) {
                      return 'Định dạng ngày không hợp lệ (yyyy-mm-dd)';
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTinhtrang,
                  decoration: InputDecoration(
                    labelText: 'Tình trạng',
                    prefixIcon: Icon(Icons.checklist, color: Colors.green[600]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green[200]!, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green[600]!, width: 1.5),
                    ),
                    labelStyle: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500),
                  ),
                  items: ['Đủ hàng', 'Không đủ hàng']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTinhtrang = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn tình trạng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _noteController,
                  label: "Ghi chú",
                  icon: Icons.note,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => null, // Optional field
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _showDetailsBottomSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Xem chi tiết đơn vận"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createReception,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text("Tạo tiếp nhận đơn hàng"),
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
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[600]!, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red[600]!, width: 1.5),
        ),
        labelStyle: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: keyboardType == TextInputType.multiline ? 3 : 1,
      style: const TextStyle(fontSize: 15),
    );
  }
}