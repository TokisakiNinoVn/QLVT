import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:txng/services/farm_management/care_process_service.dart';
import 'package:txng/config/color_config.dart';
import 'care_process_detail_screen.dart';
import 'care_process_edit_screen.dart';

class CareProcessListScreen extends StatefulWidget {
  const CareProcessListScreen({super.key});

  @override
  State<CareProcessListScreen> createState() => _CareProcessListScreenState();
}

class _CareProcessListScreenState extends State<CareProcessListScreen> {
  static final CareProcessService _listCareProcessService = CareProcessService();
  late List<Map<String, dynamic>> listCareProcesses = [];
  late List<Map<String, dynamic>> filteredCareProcesses = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCareProcesses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredCareProcesses = listCareProcesses.where((account) {
          final searchText = _searchController.text.toLowerCase();
          return account['hoatdong'].toLowerCase().contains(searchText) ||
              account['mota'].toLowerCase().contains(searchText);
        }).toList();
        filteredCareProcesses.sort(
              (a, b) => a['sapxep'].compareTo(b['sapxep']),
        );
      });
    });
  }

  Future<void> _loadCareProcesses() async {
    try {
      final response = await _listCareProcessService.getAllCareProcessService();
      final rawData = response["data"]?["quytrinhchamsocs"];
      print('rawData: $rawData');

      if (rawData is List) {
        setState(() {
          listCareProcesses = rawData
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();
          // listCareProcesses.sort((a, b) => a['sapxep'].compareTo(b['sapxep']));
          listCareProcesses.sort((a, b) {
            final aVal = a['sapxep'];
            final bVal = b['sapxep'];
            if (aVal == null && bVal == null) return 0;
            if (aVal == null) return 1; // Đưa phần tử null xuống cuối
            if (bVal == null) return -1;
            return aVal.compareTo(bVal);
          });

          filteredCareProcesses = List.from(listCareProcesses);
        });
      } else {
        setState(() {
          listCareProcesses = [];
          filteredCareProcesses = [];
        });
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")),
      // );
      print('Lỗi khi tải dữ liệu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareProcessEditScreen(
          onSave: _loadCareProcesses,
        ),
      ),
    );
  }

  void _showEditScreen(Map<String, dynamic> listCareProcess) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareProcessEditScreen(
          careProcess: listCareProcess,
          onSave: _loadCareProcesses,
        ),
      ),
    );
  }

  void _showDetailScreen(Map<String, dynamic> listCareProcess) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareProcessDetailScreen(
          careProcess: listCareProcess,
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> listCareProcess) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc chắn muốn xóa quy trình chăm sóc '${listCareProcess["hoatdong"]}' không?",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                final response = await _listCareProcessService
                    .deleteCareProcessService(
                  listCareProcess["id"],
                  {"_method": "DELETE"},
                );
                if (response["status"] == true || response["code"] == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Xóa quy trình thành công.")),
                  );
                  setState(() {
                    listCareProcesses.removeWhere(
                          (acc) => acc["id"] == listCareProcess["id"],
                    );
                    filteredCareProcesses = List.from(listCareProcesses);
                    filteredCareProcesses.sort(
                          (a, b) => a['sapxep'].compareTo(b['sapxep']),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi xóa quy trình: $e")),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quy trình chăm sóc"),
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCareProcesses,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddScreen,
            tooltip: 'Thêm quy trình',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên hoặc mô tả',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCareProcesses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có quy trình nào',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredCareProcesses.length,
              itemBuilder: (context, index) {
                final listCareProcess = filteredCareProcesses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showDetailScreen(listCareProcess),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: ColorConfig.secondary,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${listCareProcess["sapxep"]}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorConfig.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  listCareProcess["hoatdong"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Chi tiết'),
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                          () =>
                                          _showDetailScreen(listCareProcess),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Chỉnh sửa'),
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                          () =>
                                          _showEditScreen(listCareProcess),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                          () =>
                                          _confirmDelete(listCareProcess),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (listCareProcess["mota"] != null &&
                              listCareProcess["mota"].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                listCareProcess["mota"],
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}