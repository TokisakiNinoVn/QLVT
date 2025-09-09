// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// // import '../../../services/farm_management/harvest_packaging_service.dart';
// import '../../../services/farm_management/transport_service.dart';
// import '../../../services/farm_management/container_service.dart';
// import 'package:txng/helpers/select_or_type_helper.dart';
//
// class TransportCreateScreen extends StatefulWidget {
//   const TransportCreateScreen({super.key});
//
//   @override
//   State<TransportCreateScreen> createState() => _TransportCreateScreenState();
// }
//
// class _TransportCreateScreenState extends State<TransportCreateScreen> {
//   final TransportService _transportService = TransportService();
//   final ContainerService _containerService = ContainerService();
//
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//   List<Map<String, dynamic>> _listTaiXe = [];
//   List<Map<String, dynamic>> _listDiemNhan = [];
//   List<Map<String, dynamic>> _listContainer = [];
//   List<Map<String, dynamic>> _listXe = [];
//
//   String? _selectedTaiXeId;
//   String? _selectedXeId;
//   String? _selectedDiemNhanId;
//   String? _selectedHarvestPackagingId;
//
//   // Text controllers
//   final _codeTransportController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _shippingDateController = TextEditingController();
//   final _ghiChuController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _shippingDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     _loadListTaiXe();
//     _loadListDiemNhan();
//     _loadListContainer();
//     _loadListXe();
//   }
//
//   @override
//   void dispose() {
//     _codeTransportController.dispose();
//     _weightController.dispose();
//     // _productNameController.dispose();
//     _shippingDateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadListContainer() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await _containerService.getAllContainerService();
//       final rawData = response["data"];
//       setState(() {
//         _listContainer = List<Map<String, dynamic>>.from(rawData);
//         if (_listContainer.isNotEmpty) {
//           _selectedHarvestPackagingId = _listContainer[0]['id'].toString();
//           _codeTransportController.text = _listContainer[0]['maconghang']?.toString() ?? '';
//           String weight = _listContainer[0]['khoiluong']?.toString() ?? '';
//           _weightController.text = weight.replaceAll(RegExp(r'[^0-9]'), '');
//           // _productNameController.text = _listContainer[0]['tensanpham']?.toString() ?? '';
//         }
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi tải thông tin lô hàng: $e"), backgroundColor: Colors.redAccent),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _loadListTaiXe() async {
//     try {
//       final response = await _transportService.getListTaiXeTransportService();
//       final rawData = response["data"];
//       if (rawData is List) {
//         setState(() {
//           _listTaiXe = List<Map<String, dynamic>>.from(rawData);
//           if (_listTaiXe.isNotEmpty) _selectedTaiXeId = _listTaiXe[0]['id'].toString();
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi tải danh sách tài xế: $e"), backgroundColor: Colors.redAccent),
//       );
//     }
//   }
//   Future<void> _loadListXe() async {
//     try {
//       final response = await _transportService.getListXeService();
//       final rawData = response["xes"];
//       if (rawData is List) {
//         setState(() {
//           _listXe = List<Map<String, dynamic>>.from(rawData);
//           if (_listXe.isNotEmpty) _selectedXeId = _listXe[0]['id'].toString();
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi tải danh sách tài xế: $e"), backgroundColor: Colors.redAccent),
//       );
//     }
//   }
//
//   Future<void> _loadListDiemNhan() async {
//     try {
//       final responseNhan = await _transportService.getListDiemNhanService();
//       setState(() {
//         _listDiemNhan = List<Map<String, dynamic>>.from(responseNhan["data"] ?? []);
//         if (_listDiemNhan.isNotEmpty) _selectedDiemNhanId = _listDiemNhan[0]['id'].toString();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi tải danh sách điểm gửi/nhận: $e"), backgroundColor: Colors.redAccent),
//       );
//     }
//   }
//
//   Future<void> _createTransport() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//     try {
//       final Map<String, dynamic> data = {
//         'maconghang': _codeTransportController.text.trim(),
//         'mataixe': int.parse(_selectedTaiXeId ?? '0'),
//         // 'soluong': int.parse(_weightController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')),
//         'ngaygui': _shippingDateController.text.trim(),
//         'madiemnhan': int.parse(_selectedDiemNhanId ?? '0'),
//         'maxe': int.parse(_selectedXeId ?? '0'),
//         'maHarvestPackaging': int.parse(_selectedHarvestPackagingId ?? '0'),
//         'ghichu': _ghiChuController.text.trim(),
//       };
//
//       final response = await _transportService.createTransportService(data);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Tạo đơn vận chuyển thành công!"),
//           backgroundColor: Colors.green,
//         ),
//       );
//       context.go("/transport-management");
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi tạo đơn vận chuyển: $e"), backgroundColor: Colors.redAccent),
//       );
//       print("Lỗi khi tạo đơn vận chuyển: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => context.pop(),
//         ),
//         title: const Text(
//           "Tạo đơn vận chuyển",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.green[700],
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check, color: Colors.white),
//             onPressed: _isLoading ? null : _createTransport,
//             tooltip: 'Lưu',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.green))
//           : Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.green[50]!, Colors.white],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//               DropdownButtonFormField<String>(
//               value: _selectedHarvestPackagingId,
//               decoration: InputDecoration(
//                 labelText: "Chọn công hàng",
//                 prefixIcon: Icon(Icons.inventory, color: Colors.green[600]),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.green[200]!, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.green[600]!, width: 2),
//                 ),
//                 labelStyle: TextStyle(color: Colors.green[800]),
//               ),
//               items: _listContainer.map<DropdownMenuItem<String>>((harvest) {
//                 return DropdownMenuItem<String>(
//                   value: harvest['id'].toString(),
//                   child: Text(harvest['maconghang'] ?? 'Không rõ'),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedHarvestPackagingId = value;
//                   final selectedHarvest = _listContainer.firstWhere(
//                         (harvest) => harvest['id'].toString() == value,
//                     orElse: () => {},
//                   );
//                   _codeTransportController.text = selectedHarvest['malohang']?.toString() ?? '';
//                   String weight = selectedHarvest['khoiluong']?.toString() ?? '';
//                   _weightController.text = weight.replaceAll(RegExp(r'[^0-9]'), '');
//                 });
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Vui lòng chọn lô hàng';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildTextField(
//               controller: _shippingDateController,
//               label: "Ngày gửi",
//               icon: Icons.calendar_today,
//               keyboardType: TextInputType.datetime,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Vui lòng nhập ngày gửi';
//                 }
//                 try {
//                   DateFormat('yyyy-MM-dd').parse(value);
//                   return null;
//                 } catch (e) {
//                   return 'Định dạng ngày không hợp lệ (yyyy-mm-dd)';
//                 }
//               },
//             ),
//             const SizedBox(height: 16),
//           //   DropdownButtonFormField<String>(
//           //     value: _selectedTaiXeId,
//           //     decoration: InputDecoration(
//           //     labelText: "Tài xế",
//           //     prefixIcon: Icon(Icons.person, color: Colors.green[600]),
//           //     filled: true,
//           //     fillColor: Colors.white,
//           //     border: OutlineInputBorder(
//           //       borderRadius: BorderRadius.circular(12),
//           //       borderSide: BorderSide.none,
//           //     ),
//           //     enabledBorder: OutlineInputBorder(
//           //       borderRadius: BorderRadius.circular(12),
//           //       borderSide: BorderSide(color: Colors.green[200]!, width: 1),
//           //     ),
//           //     focusedBorder: OutlineInputBorder(
//           //       borderRadius: BorderRadius.circular(12),
//           //       borderSide: BorderSide(color: Colors.green[600]!, width: 2),
//           //     ),
//           //     labelStyle: TextStyle(color: Colors.green[800]),
//           //   ),
//           //   items: _listTaiXe.map<DropdownMenuItem<String>>((taiXe) {
//           //     return DropdownMenuItem<String>(
//           //       value: taiXe['id'].toString(),
//           //       child: Text(taiXe['hoten'] ?? 'Không rõ'),
//           //     );
//           //   }).toList(),
//           //   onChanged: (value) {
//           //     setState(() {
//           //       _selectedTaiXeId = value;
//           //     });
//           //   },
//           //   validator: (value) {
//           //     if (value == null || value.isEmpty) {
//           //       return 'Vui lòng chọn tài xế';
//           //     }
//           //     return null;
//           //   },
//           // ),
//
//           AutocompleteField(
//             label: 'Chọn tài xế',
//             controller: ,
//             options: ,
//             fieldKey: '',
//             getSelectedId: () => selectedId,
//             setSelectedId: (id) => setState(() => selectedId = id),
//             errorState: nameHasError,
//             setErrorState: (e) => setState(() => nameHasError = e),
//             icon: Icons.local_shipping,
//           ),
//           const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedXeId,
//               decoration: InputDecoration(
//                 labelText: "Xe",
//                 prefixIcon: Icon(Icons.local_shipping, color: Colors.green[600]),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.green[200]!, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.green[600]!, width: 2),
//                 ),
//                 labelStyle: TextStyle(color: Colors.green[800]),
//               ),
//               items: _listXe.map<DropdownMenuItem<String>>((xe) {
//                 final id = xe['id'].toString();
//                 final loaiXe = xe['loaixe'] ?? 'Không rõ loại';
//                 final bienSo = xe['bienso'] ?? 'Không rõ biển số';
//                 return DropdownMenuItem<String>(
//                   value: id,
//                   child: Text('$loaiXe - $bienSo'),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedXeId = value;
//                 });
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Vui lòng chọn xe';
//                 }
//                 return null;
//               },
//             ),
//             AutocompleteField(
//               label: 'Chọn xe',
//               controller: nameController,
//               options: areaList,
//               fieldKey: '',
//               getSelectedId: () => selectedId,
//               setSelectedId: (id) => setState(() => selectedId = id),
//               errorState: nameHasError,
//               setErrorState: (e) => setState(() => nameHasError = e),
//               icon: Icons.local_shipping,
//             ),
//
//
//           const SizedBox(height: 16),
//           DropdownButtonFormField<String>(
//             value: _selectedDiemNhanId,
//             decoration: InputDecoration(
//               labelText: "Điểm nhận",
//               prefixIcon: Icon(Icons.location_on, color: Colors.green[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.green[200]!, width: 1),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.green[600]!, width: 2),
//               ),
//               labelStyle: TextStyle(color: Colors.green[800]),
//             ),
//             items: _listDiemNhan.map<DropdownMenuItem<String>>((diemNhan) {
//               return DropdownMenuItem<String>(
//                 value: diemNhan['id'].toString(),
//                 child: Text(diemNhan['tencoso'] ?? 'Không rõ'),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedDiemNhanId = value;
//               });
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Vui lòng chọn điểm nhận';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 24),
//           TextFormField(
//             controller: _ghiChuController,
//             decoration: InputDecoration(
//               labelText: "Ghi chú",
//               prefixIcon: Icon(Icons.note, color: Colors.green[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.green[
//                   200]!, width: 1),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: Colors.green[600]!, width: 2),
//               ),
//               labelStyle: TextStyle(color: Colors.green[800]),
//             ),
//             maxLines: 3,
//             minLines: 3,
//           ),
//           const SizedBox(height: 24),
//           Center(
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _createTransport,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green[700],
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//                   : const Text("Tạo đơn vận chuyển"),
//             ),
//           ),
//           ],
//         ),
//       ),
//     ),
//     ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     Widget? suffixIcon,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     bool enabled = true,
//   }) {
//     return TextFormField(
//       controller: controller,
//       enabled: enabled,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.green[600]),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.green[200]!, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.green[600]!, width: 2),
//         ),
//         labelStyle: TextStyle(color: Colors.green[800]),
//       ),
//       validator: validator,
//       keyboardType: keyboardType,
//     );
//   }
// }