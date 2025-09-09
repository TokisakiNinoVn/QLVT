import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:txng/services/farm_management/plantingarea_service.dart';
import 'package:txng/config/color_config.dart';

class PlantingAreaManagementScreen extends StatefulWidget {
  const PlantingAreaManagementScreen({super.key});

  @override
  State<PlantingAreaManagementScreen> createState() =>
      _PlantingAreaManagementScreenState();
}

class _PlantingAreaManagementScreenState
    extends State<PlantingAreaManagementScreen> {
  static final PlantingAreaService _plantingareaService = PlantingAreaService();
  List<Map<String, dynamic>> listPlantingareas = [];
  List<Map<String, dynamic>> filteredPlantingareas = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _loadListPlantingArea();
    _searchController.addListener(_filterPlantingAreas);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPlantingAreas);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Đã được cấp quyền truy cập vị trí!');
    } else if (status.isDenied) {
      print('Bị từ chối quyền truy cập vị trí.');
    } else if (status.isPermanentlyDenied) {
      print('Quyền truy cập bị từ chối vĩnh viễn!');
      openAppSettings();
    }
  }

  Future<void> _loadListPlantingArea() async {
    try {
      final response = await _plantingareaService.getListPlantingAreaService();
      final rawData = response["data"];
      if (rawData is List) {
        setState(() {
          listPlantingareas = List<Map<String, dynamic>>.from(rawData);
          filteredPlantingareas = listPlantingareas;
        });
      } else {
        setState(() {
          listPlantingareas = [];
          filteredPlantingareas = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPlantingAreas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPlantingareas =
          listPlantingareas.where((area) {
            return (area["tenvungtrong"]?.toLowerCase().contains(query) ?? false) ||
                (area["chusohuu"]?.toLowerCase().contains(query) ?? false) ||
                (area["diachi"]?.toLowerCase().contains(query) ?? false) ||
                (area["masothue"]?.toLowerCase().contains(query) ?? false) ||
                (area["mavungtrong"]?.toLowerCase().contains(query) ?? false);
          }).toList();
    });
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw ?? '';
    }
  }

  // Hàm xóa vùng trồng
  Future<void> _deletePlantingAreaService(int id) async {
    try {
      final response = await _plantingareaService.deletePlantingAreaService(id);
      if (response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Xóa vùng trồng thành công"),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadListPlantingArea();
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi xóa vùng trồng: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deletePlantingArea(int id) async {
    try {
      await _plantingareaService.deletePlantingAreaService(id);
      await _loadListPlantingArea();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Xóa vùng trồng thành công"),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi xóa vùng trồng: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPlantingAreaCard(Map<String, dynamic> plantingArea) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: ColorConfig.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/planting-area-management/planting-area-details', extra: plantingArea),
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
                        plantingArea["tenvungtrong"] ?? 'Không có tên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ColorConfig.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorConfig.cardPlaceholder,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_city,
                        color: ColorConfig.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plantingArea["diachi"] ?? 'Không có địa chỉ',
                  style: TextStyle(fontSize: 14, color: ColorConfig.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  "Chủ sở hữu: ${plantingArea["chusohuu"] ?? 'Không có dữ liệu'}",
                  style: TextStyle(fontSize: 14, color: ColorConfig.textSecondary),
                ),
                Text(
                  "Ngày tạo: ${_formatDate(plantingArea["created_at"])}",
                  style: TextStyle(fontSize: 14, color: ColorConfig.textMuted),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.visibility, color: ColorConfig.secondary),
                      tooltip: 'Xem chi tiết',
                      onPressed: () {
                        context.push(
                          '/planting-area-management/planting-area-details',
                          extra: plantingArea,
                        );
                      },
                      hoverColor: ColorConfig.lightGreen,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: ColorConfig.selectedItemColor),
                      tooltip: 'Chỉnh sửa',
                      onPressed: () {
                        context.push(
                          '/planting-area-management/planting-area-edit',
                          extra: plantingArea,
                        );
                      },
                      hoverColor: ColorConfig.lightGreen,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: ColorConfig.error),
                      tooltip: 'Xóa',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: ColorConfig.white,
                            title: Text('Xác nhận xóa', style: TextStyle(color: ColorConfig.textPrimary)),
                            content: Text(
                              'Bạn có chắc muốn xóa vùng trồng này?',
                              style: TextStyle(color: ColorConfig.textSecondary),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => _deletePlantingArea(plantingArea['id']),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(color: ColorConfig.textMuted),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deletePlantingAreaService(plantingArea["id"]);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Xóa',
                                  style: TextStyle(color: ColorConfig.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      hoverColor: ColorConfig.lightGreen,
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: ColorConfig.primary),
                      tooltip: 'Lịch sử chăm sóc',
                      onPressed: () {
                        context.push(
                          '/care-history-management/${plantingArea["id"]}',
                          extra: plantingArea,
                        );
                      },
                      hoverColor: ColorConfig.lightGreen,
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
    setState(() async {
      _selectedIndex = index;
      if (index == 0) {
        _isSearching = false;
        _searchController.clear();
        final result = await context.push('/planting-area-management/planting-area-create');

        if (result == true) {
          _loadListPlantingArea();
        }
      } else if (index == 1) {
        _isSearching = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ColorConfig.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorConfig.white60, ColorConfig.white60],
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
                    hintText:
                    "Tìm theo tên, chủ sở hữu, địa chỉ, mã số thuế, mã vùng trồng",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorConfig.lightGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorConfig.primary),
                    ),
                    filled: true,
                    fillColor: ColorConfig.white,
                    hintStyle: TextStyle(color: ColorConfig.textMuted),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(color: ColorConfig.textPrimary),
                )
                    : Text(
                  "Quản lý vùng trồng",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: ColorConfig.white,
                  ),
                ),
                backgroundColor: ColorConfig.primary,
                foregroundColor: ColorConfig.white,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 26,
                      color: ColorConfig.white,
                    ),
                    onPressed: _loadListPlantingArea,
                    tooltip: 'Làm mới',
                    hoverColor: ColorConfig.secondary,
                  ),
                  if (!_isSearching)
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 26,
                        color: ColorConfig.white,
                      ),
                      onPressed: () => setState(() => _isSearching = true),
                      tooltip: 'Tìm kiếm',
                      hoverColor: ColorConfig.secondary,
                    ),
                  if (_isSearching)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 26,
                        color: ColorConfig.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                      },
                      tooltip: 'Hủy tìm kiếm',
                      hoverColor: ColorConfig.secondary,
                    ),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: ColorConfig.primary,
                  ),
                )
                    : filteredPlantingareas.isEmpty
                    ? Center(
                  child: Text(
                    "Không có dữ liệu vùng trồng.",
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConfig.textMuted,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filteredPlantingareas.length,
                  itemBuilder: (context, index) {
                    final plantingArea = filteredPlantingareas[index];
                    return _buildPlantingAreaCard(plantingArea);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/planting-area-management/scan-qr-detailsvt'),
        tooltip: 'Scan QR chi tiết vùng trồng',
        backgroundColor: ColorConfig.selectedItemColor,
        elevation: 6.0,
        shape: const CircleBorder(),
        child: Icon(Icons.qr_code_scanner, size: 32, color: ColorConfig.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm mới'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ColorConfig.selectedItemColor,
        unselectedItemColor: ColorConfig.unselectedItemColor,
        backgroundColor: ColorConfig.white,
        elevation: 4,
        onTap: _onItemTapped,
      ),
    );
  }


}
