import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:txng/services/farm_management/care_history_service.dart';
import 'package:txng/services/farm_management/fertilizer_medicine_service.dart';
import 'package:txng/services/farm_management/care_process_service.dart';
import 'package:txng/services/farm_management/plantingarea_service.dart';
import 'package:txng/services/storage_service.dart';
import 'package:txng/config/color_config.dart';
import 'package:txng/helpers/select_or_type_helper.dart';

class AddCareHistoryQRScreen extends StatefulWidget {
  final String? code;
  const AddCareHistoryQRScreen({super.key, this.code});

  @override
  State<AddCareHistoryQRScreen> createState() => _AddCareHistoryScreenState();
}

class _AddCareHistoryScreenState extends State<AddCareHistoryQRScreen> {
  final CareHistoryService _careHistoryService = CareHistoryService();
  final FertilizerMedicineService _fertilizerMedicineService =
  FertilizerMedicineService();
  final CareProcessService _careProcessService = CareProcessService();
  final PlantingAreaService _plantingAreaService = PlantingAreaService();

  List<Map<String, dynamic>> listFertilizerMedicine = [];
  List<Map<String, dynamic>> filteredFertilizerMedicine = [];
  List<Map<String, dynamic>> listCareProcess = [];
  List<Map<String, dynamic>> listSupplier = [];
  Map<String, dynamic> plantingAreaDetails = {};
  int idVungTrong = 0;

  bool _isLoading = false;
  bool _isManualInput = false;
  final TextEditingController _hoatDongController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  final TextEditingController _maCodeController = TextEditingController();
  final TextEditingController _lieuLuongController = TextEditingController();
  final TextEditingController _fertilizerController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

  String? _selectedFertilizerId;
  String? _selectedProcessId;
  String? _selectedSupplierId;

  bool _processError = false;
  bool _fertilizerError = false;
  bool _supplierError = false;

  @override
  void initState() {
    super.initState();
    _loadFertilizerMedicine();
    _loadCareProcess();
    _loadSupplier();
    if (widget.code != null) {
      _loadPlantingAreaDetails(widget.code!);
    }
    _maCodeController.text = widget.code ?? '';
    _hoatDongController.addListener(_onProcessNameChanged);
  }

  @override
  void dispose() {
    _hoatDongController.removeListener(_onProcessNameChanged);
    _hoatDongController.dispose();
    _moTaController.dispose();
    _maCodeController.dispose();
    _lieuLuongController.dispose();
    _fertilizerController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _onProcessNameChanged() {
    final inputText = _hoatDongController.text;
    final selectedProcess = listCareProcess.firstWhere(
          (p) => p['hoatdong']?.toString() == inputText,
      orElse: () => {},
    );

    setState(() {
      if (selectedProcess.isEmpty) {
        // Manual input - show all products
        _isManualInput = true;
        _selectedProcessId = null;
        filteredFertilizerMedicine = List.from(listFertilizerMedicine);
      } else {
        // Selected from dropdown - filter products by mahoatdong (which equals care process id)
        _isManualInput = false;
        _selectedProcessId = selectedProcess['id'].toString();
        final processId = selectedProcess['id'];
        filteredFertilizerMedicine = listFertilizerMedicine
            .where((product) => product['mahoatdong'] == processId)
            .toList();
      }
    });
  }

  Future<void> _loadCareProcess() async {
    final response = await _careProcessService.getAllCareProcessService();
    final rawData = response["data"]?["quytrinhchamsocs"];
    try {
      if (rawData is List) {
        setState(() {
          listCareProcess =
              rawData.map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
              ).toList();
        });
      } else {
        setState(() => listCareProcess = []);
      }
    } catch (e) {
      print("Lỗi khi tải quy trình chăm sóc: $e");
    }
  }

  Future<void> _loadPlantingAreaDetails(String code) async {
    final response = await _plantingAreaService.getPlantingAreaByCodeService(
      code,
    );
    if (response["status"] == true || response["code"] == 200) {
      setState(() {
        plantingAreaDetails = response["data"];
        idVungTrong = plantingAreaDetails['id'];
      });
    } else {
      print(
        "Lỗi khi tải chi tiết vùng trồng: ${response["data"] ?? "Lỗi không xác định"}",
      );
    }
  }

  Future<void> _loadSupplier() async {
    final response = await _careHistoryService.getListSupplierService();
    final rawData = response["data"]?["data"];
    try {
      if (rawData is List) {
        setState(() {
          listSupplier =
              rawData.map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
              ).toList();
        });
      } else {
        setState(() => listSupplier = []);
      }
    } catch (e) {
      print("Lỗi khi tải nhà cung cấp: $e");
    }
  }

  Future<void> _loadFertilizerMedicine() async {
    final response =
    await _fertilizerMedicineService.getAllFertilizerMedicineService();
    final rawData = response["data"]?["phanbon_thuocs"]?["data"];
    try {
      if (rawData is List) {
        setState(() {
          listFertilizerMedicine =
              rawData.map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
              ).toList();
          filteredFertilizerMedicine = List.from(listFertilizerMedicine);
        });
      } else {
        setState(() => listFertilizerMedicine = []);
      }
    } catch (e) {
      print("Lỗi khi tải sản phẩm: $e");
    }
  }

  Future<void> _submitCareHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _careHistoryService.createCareHistoryService({
        "tenhoatdong": _hoatDongController.text,
        "sanphamsudung": _fertilizerController.text,
        "manhacungcap": _supplierController.text,
        "lieu_luong": _lieuLuongController.text,
        "ghichu": _moTaController.text,
        "mavungtrong": widget.code,
      });
      print("Thêm mới lịch sử chăm sóc: $response");

      if (response["status"] == true || response["code"] == 200) {
        var roleType = await StorageService.getData('loginOption_type');
        var quyenhan = await StorageService.getData('quyenhan');
        context.go("/");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Thêm mới lịch sử chăm sóc thành công!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: ColorConfig.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm mới: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImageFullScreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.white),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlantingAreaDetails() {
    double latitude = double.tryParse(plantingAreaDetails["lat"] ?? "") ?? 0.0;
    double longitude = double.tryParse(plantingAreaDetails["lng"] ?? "") ?? 0.0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder:
            (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Chi tiết vùng trồng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Mã vùng trồng',
                        plantingAreaDetails['mavungtrong'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Tên vùng trồng',
                        plantingAreaDetails['tenvungtrong'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Chủ sở hữu',
                        plantingAreaDetails['chusohuu'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Địa chỉ',
                        plantingAreaDetails['diachi'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Số điện thoại',
                        plantingAreaDetails['sodienthoai'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Ngày tạo',
                        plantingAreaDetails['created_at']
                            ?.split('T')
                            .first ??
                            'N/A',
                      ),
                      _buildDetailRow(
                        'Ngày cập nhật',
                        plantingAreaDetails['updated_at']
                            ?.split('T')
                            .first ??
                            'N/A',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ảnh vùng trồng',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap:
                            () => _showImageFullScreen(
                          plantingAreaDetails['chungchi'],
                        ),
                        child: CachedNetworkImage(
                          imageUrl: plantingAreaDetails['chungchi'] ?? 'https://i.pinimg.com/736x/9f/93/ae/9f93ae8f39417cd575e735bf5f1b1505.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget:
                              (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'QR Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showImageFullScreen(
                          plantingAreaDetails['qrcode'] ?? "https://i.pinimg.com/736x/9a/9a/16/9a9a16b12880f1f14dbf3fb2ad64bf95.jpg",
                        ),
                        child: CachedNetworkImage(
                          imageUrl: plantingAreaDetails['qrcode'],
                          height: 150,
                          width: 150,
                          fit: BoxFit.contain,
                          placeholder:
                              (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget:
                              (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vị trí',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Container(
                      //   height: 300,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: Colors.grey[300]!),
                      //   ),
                      //   child: FlutterMap(
                      //     options: MapOptions(
                      //       initialCenter: LatLng(
                      //         double.parse(
                      //           plantingAreaDetails['lat'] ??
                      //               '10.77653',
                      //         ),
                      //         double.parse(
                      //           plantingAreaDetails['lng'] ??
                      //               '106.700981',
                      //         ),
                      //       ),
                      //       initialZoom: 15,
                      //     ),
                      //     children: [
                      //       TileLayer(
                      //         urlTemplate:
                      //         'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      //         subdomains: ['a', 'b', 'c'],
                      //       ),
                      //       MarkerLayer(
                      //         markers: [
                      //           Marker(
                      //             point: LatLng(
                      //               double.parse(
                      //                 plantingAreaDetails['lat'] ?? '10.77653',
                      //               ),
                      //               double.parse(
                      //                 plantingAreaDetails['lng'] ?? '106.700981',
                      //               ),
                      //             ),
                      //             child: const Icon(
                      //               Icons.location_on,
                      //               color: Colors.red,
                      //               size: 40,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(latitude, longitude),
                              initialZoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.txng',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(latitude, longitude),
                                    width: 80,
                                    height: 80,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Thêm lịch sử chăm sóc (QR)",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: ColorConfig.primary,
          foregroundColor: ColorConfig.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showPlantingAreaDetails,
              tooltip: 'Chi tiết vùng trồng',
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _submitCareHistory,
              tooltip: 'Thêm lịch sử chăm sóc',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mã code vùng trồng - widget.code
                    TextField(
                      controller: _maCodeController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Mã code vùng trồng',
                        labelStyle: TextStyle(
                          color: ColorConfig.primary,
                        ),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                        Theme.of(context).colorScheme.background,
                        prefixIcon: const Icon(Icons.qr_code),
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    AutocompleteField(
                      label: 'Quy trình chăm sóc',
                      controller: _hoatDongController,
                      options: listCareProcess,
                      getSelectedId: () => _selectedProcessId,
                      setSelectedId: (id) {
                        setState(() {
                          _selectedProcessId = id;
                          _onProcessNameChanged();
                        });
                      },
                      errorState: _processError,
                      setErrorState: (error) => _processError = error,
                      fieldKey: 'hoatdong',
                      icon: Icons.agriculture,
                      // showProcessId: true,
                    ),
                    const SizedBox(height: 16),
                    AutocompleteField(
                      label: 'Sản phẩm sử dụng',
                      controller: _fertilizerController,
                      options: filteredFertilizerMedicine,
                      getSelectedId: () => _selectedFertilizerId,
                      setSelectedId: (id) => _selectedFertilizerId = id,
                      errorState: _fertilizerError,
                      setErrorState: (error) => _fertilizerError = error,
                      fieldKey: 'tensanpham',
                      icon: Icons.local_florist,
                    ),
                    const SizedBox(height: 16),
                    AutocompleteField(
                      label: 'Nhà cung cấp',
                      controller: _supplierController,
                      options: listSupplier,
                      getSelectedId: () => _selectedSupplierId,
                      setSelectedId: (id) => _selectedSupplierId = id,
                      errorState: _supplierError,
                      setErrorState: (error) => _supplierError = error,
                      fieldKey: 'tennhacungcap',
                      icon: Icons.store,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lieuLuongController,
                      decoration: InputDecoration(
                        labelText: 'Liều lượng thuốc',
                        labelStyle: TextStyle(
                          color: ColorConfig.primary,
                        ),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorConfig.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.background,
                        prefixIcon: Icon(Icons.water_drop, color: ColorConfig.primary),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _moTaController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        labelStyle: TextStyle(
                          color: ColorConfig.primary,
                        ),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorConfig.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.background,
                        prefixIcon: Icon(Icons.description, color: ColorConfig.primary),
                      ),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: ColorConfig.primary,
                              ),
                            ),
                            onPressed: () => context.go("/"),
                            child: Text(
                              "Hủy",
                              style: TextStyle(
                                color: ColorConfig.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: ColorConfig.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: _isLoading ? null : _submitCareHistory,
                            child: const Text("Thêm"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}