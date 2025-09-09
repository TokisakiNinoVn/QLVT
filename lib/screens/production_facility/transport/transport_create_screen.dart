import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:txng/config/color_config.dart';

import '../../../helpers/autocomplete_field_helper.dart';
import '../../../helpers/snackbar_helper.dart';
import '../../../services/production_facility/transport_service.dart';

class TransportCreateCSSXScreenV2 extends StatefulWidget {
  const TransportCreateCSSXScreenV2({super.key});

  @override
  State<TransportCreateCSSXScreenV2> createState() => _TransportCreateScreenState();
}

class _TransportCreateScreenState extends State<TransportCreateCSSXScreenV2> {
  final TransportService _transportService = TransportService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _listTaiXe = [];
  List<Map<String, dynamic>> _listDiemNhan = [];
  List<Map<String, dynamic>> _listSanPham = [];
  List<Map<String, dynamic>> _listXe = [];
  List<Map<String, dynamic>> _selectedProducts = [];

  String? _selectedTaiXeId;
  String? _selectedXeId;
  String? _selectedDiemNhanId;

  final _codeTransportController = TextEditingController();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  final _taiXeController = TextEditingController();
  final _xeController = TextEditingController();

  bool _taiXeError = false;
  bool _xeError = false;

  @override
  void initState() {
    super.initState();
    _loadListTaiXe();
    _loadListDiemNhan();
    _loadListSPTrongKho();
    _loadListXe();
  }

  @override
  void dispose() {
    _codeTransportController.dispose();
    _weightController.dispose();
    _noteController.dispose();
    _taiXeController.dispose();
    _xeController.dispose();
    super.dispose();
  }

  Future<void> _loadListSPTrongKho() async {
    setState(() => _isLoading = true);
    try {
      final response = await _transportService.getAllSpTransportService();
      final rawData = response["data"];
      setState(() {
        _listSanPham = List<Map<String, dynamic>>.from(rawData);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải thông tin danh sach san pham trong kho: $e"),
            backgroundColor: Colors.redAccent,
          ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadListTaiXe() async {
    try {
      final response = await _transportService.getListTaiXeTransportService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          _listTaiXe = List<Map<String, dynamic>>.from(rawData);
          if (_listTaiXe.isNotEmpty) _selectedTaiXeId = _listTaiXe[0]['id'].toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải danh sách tài xế: $e"),
            backgroundColor: Colors.redAccent,
          )
      );
    }
  }

  Future<void> _loadListXe() async {
    try {
      final response = await _transportService.getListXeService();
      final rawData = response["xes"];
      if (rawData is List) {
        setState(() {
          _listXe = List<Map<String, dynamic>>.from(rawData);
          if (_listXe.isNotEmpty) _selectedXeId = _listXe[0]['id'].toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải danh sách xe: $e"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _loadListDiemNhan() async {
    try {
      final responseNhan = await _transportService.getListDiemNhanService();
      setState(() {
        _listDiemNhan = List<Map<String, dynamic>>.from(responseNhan["data"] ?? []);
        if (_listDiemNhan.isNotEmpty) _selectedDiemNhanId = _listDiemNhan[0]['id'].toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải danh sách điểm gửi/nhận: $e"),
            backgroundColor: Colors.redAccent,
          ));
    }
  }

  Future<void> _createTransport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_taiXeController.text.isEmpty) {
      setState(() => _taiXeError = true);
      return;
    }
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn ít nhất một sản phẩm"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = {
        'malohang': _codeTransportController.text.trim(),
        // 'mataixe': int.parse(_selectedTaiXeId ?? '0'),
        'mataixe': _taiXeController.text.trim(), // Gửi tên tài xế,
        'madiemnhan': int.parse(_selectedDiemNhanId ?? '0'),
        // 'maxe': int.parse(_selectedXeId ?? '0'),
        'maxe': _xeController.text.trim(), // Gửi biển số xe,
        'ghichu': _noteController.text.trim(),
        'items': _selectedProducts.map((product) => {
          'soluong': product['selectedQuantity'],
          'ghichu': product['note'] ?? '',
          'spkho_id': product['id'],
        }).toList(),
      };

      final response = await _transportService.createTransportService(data);
      SnackbarHelper.showSuccess(context, 'Tạo đơn phân phối thành công!');
      Navigator.of(context).pop(true);
      // context.go("/transport-cssx-management");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo đơn phân phối: $e"),
            backgroundColor: Colors.redAccent),
      );
      print("Lỗi khi tạo đơn phân phối: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['tensanpham'] ?? 'Không có tên'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mã lô hàng: ${product['malohang'] ?? 'Không có'}'),
              const SizedBox(height: 8),
              Text('Trọng lượng: ${product['trongluong'] ?? 'Không có'}'),
              const SizedBox(height: 8),
              Text('Kích thước: ${product['kichthuoc'] ?? 'Không có'}'),
              const SizedBox(height: 8),
              Text('Mô tả: ${product['mota'] ?? 'Không có'}'),
              const SizedBox(height: 8),
              Text('Số lượng hiện có: ${product['soluong'] ?? '0'}'),
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

  void _addProductToOrder(Map<String, dynamic> product) {
    final quantityController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm ${product['tensanpham']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng',
                  hintText: 'Nhập số lượng',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  final quantity = int.tryParse(value) ?? 0;
                  if (quantity <= 0) {
                    return 'Số lượng phải lớn hơn 0';
                  }
                  if (quantity > (product['soluong'] ?? 0)) {
                    return 'Số lượng vượt quá số lượng hiện có';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Nhập ghi chú (nếu có)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            // onPressed: () {
            //   final quantity = int.tryParse(quantityController.text) ?? 0;
            //   if (quantity <= 0 || quantity > (product['soluong'] ?? 0)) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text('Số lượng không hợp lệ'),
            //         backgroundColor: Colors.redAccent,
            //       ),
            //     );
            //     return;
            //   }
            //
            //   setState(() {
            //     _selectedProducts.add({
            //       ...product,
            //       'selectedQuantity': quantity,
            //       'note': noteController.text,
            //     });
            //   });
            //   Navigator.pop(context);
            // },
          onPressed: () {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0 || quantity > (product['soluong'] ?? 0)) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Số lượng không hợp lệ'),
    backgroundColor: Colors.redAccent,
    ),
    );
    return;
    }

    setState(() {
    // Thêm vào danh sách đã chọn
    _selectedProducts.add({
    ...product,
    'selectedQuantity': quantity,
    'note': noteController.text,
    });

    // Trừ số lượng sản phẩm trong kho
    final index = _listSanPham.indexWhere((e) => e['id'] == product['id']);
    if (index != -1) {
    _listSanPham[index]['soluong'] =
    (_listSanPham[index]['soluong'] as int) - quantity;
    }
    });
    Navigator.pop(context);
    },
    child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // void _removeProduct(int index) {
  //   setState(() {
  //     _selectedProducts.removeAt(index);
  //   });
  // }

  void _removeProduct(int index) {
    final removedProduct = _selectedProducts[index];
    final removedQuantity = removedProduct['selectedQuantity'];

    setState(() {
      // Cộng lại số lượng vào kho
      final khoIndex = _listSanPham.indexWhere((e) => e['id'] == removedProduct['id']);
      if (khoIndex != -1) {
        _listSanPham[khoIndex]['soluong'] =
            (_listSanPham[khoIndex]['soluong'] as int) + removedQuantity;
      }

      _selectedProducts.removeAt(index);
    });
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
          "Tạo đơn phân phối",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      child: Text(diemNhan['tendaily'] ?? 'Không rõ'),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: "Ghi chú đơn hàng",
                    prefixIcon: Icon(Icons.note, color: Colors.green[600]),
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
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Danh sách sản phẩm trong kho",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                ..._listSanPham.map((product) => ListTile(
                  title: Text(product['tensanpham'] ?? 'Không có tên'),
                  subtitle: Text('Số lượng: ${product['soluong']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.blue),
                        onPressed: () => _showProductDetails(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () => _addProductToOrder(product),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                const Text(
                  "Sản phẩm đã chọn",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Chưa có sản phẩm nào được chọn"),
                  )
                else
                  ..._selectedProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(product['tensanpham'] ?? 'Không có tên'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Số lượng: ${product['selectedQuantity']}'),
                            if (product['note'] != null && product['note'].isNotEmpty)
                              Text('Ghi chú: ${product['note']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeProduct(index),
                        ),
                      ),
                    );
                  }),
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
                        : const Text("Tạo đơn phân phối"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}