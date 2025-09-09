import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../helpers/snackbar_helper.dart';
import '../../../services/farm_management/transport_service.dart';
import '../../../services/farm_management/container_service.dart';
import 'package:txng/helpers/autocomplete_field_helper.dart';

class TransportCreateScreen extends StatefulWidget {
  const TransportCreateScreen({super.key});

  @override
  State<TransportCreateScreen> createState() => _TransportCreateScreenState();
}

class _TransportCreateScreenState extends State<TransportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransportService _transportService = TransportService();
  final ContainerService _containerService = ContainerService();

  bool _isLoading = false;

  final _codeTransportController = TextEditingController();
  final _weightController = TextEditingController();
  final _shippingDateController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final _taiXeController = TextEditingController();
  final _xeController = TextEditingController();

  List<Map<String, dynamic>> _listTaiXe = [];
  List<Map<String, dynamic>> _listDiemNhan = [];
  List<Map<String, dynamic>> _listContainer = [];
  List<Map<String, dynamic>> _listXe = [];

  String? _selectedTaiXeId;
  String? _selectedXeId;
  String? _selectedDiemNhanId;
  String? _selectedHarvestPackagingId;

  bool _taiXeError = false;
  bool _xeError = false;

  @override
  void initState() {
    super.initState();
    _shippingDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadListTaiXe();
    _loadListDiemNhan();
    _loadListContainer();
    _loadListXe();
  }

  @override
  void dispose() {
    _codeTransportController.dispose();
    _weightController.dispose();
    _shippingDateController.dispose();
    _ghiChuController.dispose();
    _taiXeController.dispose();
    _xeController.dispose();
    super.dispose();
  }

  Future<void> _loadListContainer() async {
    try {
      final response = await _containerService.getAllContainerService();
      final rawData = response["data"];
      setState(() {
        _listContainer = List<Map<String, dynamic>>.from(rawData);
        if (_listContainer.isNotEmpty) {
          final first = _listContainer[0];
          _selectedHarvestPackagingId = first['id'].toString();
          _codeTransportController.text = first['maconghang'] ?? '';
          _weightController.text = (first['khoiluong'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
        }
      });
    } catch (e) {
      _showError("Lỗi khi tải thông tin lô hàng: $e");
    }
  }

  Future<void> _loadListTaiXe() async {
    try {
      final response = await _transportService.getListTaiXeTransportService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          _listTaiXe = List<Map<String, dynamic>>.from(rawData);
        });
      }
    } catch (e) {
      _showError("Lỗi khi tải danh sách tài xế: $e");
    }
  }

  Future<void> _loadListXe() async {
    try {
      final response = await _transportService.getListXeService();
      final rawData = response["xes"];
      if (rawData is List) {
        setState(() {
          _listXe = List<Map<String, dynamic>>.from(rawData);
        });
      }
    } catch (e) {
      _showError("Lỗi khi tải danh sách xe: $e");
    }
  }

  Future<void> _loadListDiemNhan() async {
    try {
      final response = await _transportService.getListDiemNhanService();
      setState(() {
        _listDiemNhan = List<Map<String, dynamic>>.from(response["data"] ?? []);
      });
    } catch (e) {
      _showError("Lỗi khi tải điểm nhận: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _createTransport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_taiXeController.text.isEmpty) {
      setState(() => _taiXeError = true);
      return;
    }
    if (_xeController.text.isEmpty) {
      setState(() => _xeError = true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'maconghang': _codeTransportController.text.trim(),
        'mataixe': _taiXeController.text.trim(), // Gửi tên tài xế
        'ngaygui': _shippingDateController.text.trim(),
        'madiemnhan': int.parse(_selectedDiemNhanId ?? '0'),
        'maxe': _xeController.text.trim(), // Gửi biển số xe
        'maHarvestPackaging': int.parse(_selectedHarvestPackagingId ?? '0'),
        'ghichu': _ghiChuController.text.trim(),
      };

      await _transportService.createTransportService(data);
      SnackbarHelper.showSuccess(context, 'Tạo đơn vận chuyển thành công!');
      Navigator.of(context).pop(true);
    } catch (e) {
      _showError("Lỗi khi tạo đơn vận chuyển: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: const Text("Tạo đơn vận chuyển", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _createTransport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdownContainer(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _shippingDateController,
                label: "Ngày gửi",
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập ngày gửi';
                  try {
                    DateFormat('yyyy-MM-dd').parse(value);
                    return null;
                  } catch (_) {
                    return 'Sai định dạng (yyyy-mm-dd)';
                  }
                },
              ),
              const SizedBox(height: 16),
              AutocompleteField(
                label: 'Tài xế',
                controller: _taiXeController,
                options: _listTaiXe,
                fieldKey: 'hoten',
                getSelectedId: () => _selectedTaiXeId,
                setSelectedId: (id) => setState(() => _selectedTaiXeId = id),
                errorState: _taiXeError,
                setErrorState: (val) => setState(() => _taiXeError = val),
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              AutocompleteField(
                label: 'Xe',
                controller: _xeController,
                options: _listXe,
                fieldKey: 'bienso',
                getSelectedId: () => _selectedXeId,
                setSelectedId: (id) => setState(() => _selectedXeId = id),
                errorState: _xeError,
                setErrorState: (val) => setState(() => _xeError = val),
                icon: Icons.local_shipping,
              ),
              const SizedBox(height: 16),
              _buildDropdownDiemNhan(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ghiChuController,
                label: "Ghi chú",
                icon: Icons.note,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createTransport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Tạo đơn vận chuyển"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer() {
    return DropdownButtonFormField<String>(
      value: _selectedHarvestPackagingId,
      decoration: _dropdownDecoration("Chọn công hàng", Icons.inventory),
      items: _listContainer.map((item) {
        return DropdownMenuItem(
          value: item['id'].toString(),
          child: Text(item['maconghang'] ?? 'Không rõ'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedHarvestPackagingId = value;
          final selected = _listContainer.firstWhere((x) => x['id'].toString() == value, orElse: () => {});
          _codeTransportController.text = selected['maconghang'] ?? '';
          _weightController.text = (selected['khoiluong'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
        });
      },
      validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn công hàng' : null,
    );
  }

  Widget _buildDropdownDiemNhan() {
    return DropdownButtonFormField<String>(
      value: _selectedDiemNhanId,
      decoration: _dropdownDecoration("Điểm nhận", Icons.location_on),
      items: _listDiemNhan.map((diem) {
        return DropdownMenuItem<String>(
          value: diem['id'].toString(),
          child: Text(diem['tencoso'] ?? 'Không rõ'),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDiemNhanId = value),
      validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn điểm nhận' : null,
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green[600]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[200]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[600]!, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.green[800]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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