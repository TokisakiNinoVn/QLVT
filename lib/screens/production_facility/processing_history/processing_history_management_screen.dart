import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:txng/services/production_facility/processing_history_service.dart';
import 'package:txng/services/production_facility/additive_products_service.dart';
import 'package:txng/services/production_facility/production_process_service.dart';

import '../../../config/color_config.dart';

class ProcessingHistoryManagementScreen extends StatefulWidget {
  final String code;
  const ProcessingHistoryManagementScreen({super.key, required this.code});

  @override
  State<ProcessingHistoryManagementScreen> createState() => _ProcessingHistoryManagementScreenState();
}

class _ProcessingHistoryManagementScreenState extends State<ProcessingHistoryManagementScreen> {
  static final ProcessingHistoryService _processingHistoryService = ProcessingHistoryService();
  static final AdditiveProductsService _additiveProductsService = AdditiveProductsService();
  static final ProductionProcessService _productionProcessService = ProductionProcessService();

  List<Map<String, dynamic>> listAdditiveProducts = [];
  List<Map<String, dynamic>> listProductionProcess = [];
  List<Map<String, dynamic>> listProcessingHistory = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListProcessingHistory();
  }

  Future<void> _loadListProcessingHistory() async {
    try {
      setState(() => _isLoading = true);
      final response = await _processingHistoryService.getListProcessingHistoryByCodeService(widget.code);
      final rawData = response["data"];

      if (rawData is List) {
        setState(() {
          listProcessingHistory = rawData.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        setState(() {
          listProcessingHistory = [];
        });
      }
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

  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  Future<void> _deleteProcessingHistory(int id) async {
    try {
      Map<String, dynamic> data = {
        '_method': 'DELETE'
      };
      await _processingHistoryService.deleteProcessingHistoryService(id, data);
      await _loadListProcessingHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Xóa lịch sử chế biến thành công"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi xóa: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa lịch sử chế biến này?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProcessingHistory(id);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LSCB lô: ${widget.code}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Color(0xFF00695C), Color(0xFF00ACC1)],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
        elevation: 2,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00695C)),
          ),
        )
            : listProcessingHistory.isEmpty
            ? Center(
          child: Text(
            'Không có dữ liệu lịch sử chế biến',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: listProcessingHistory.length,
          itemBuilder: (context, index) {
            final item = listProcessingHistory[index];
            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20.0),
                  title: Text(
                    item['hoatdong'] ?? 'Không xác định',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: ColorConfig.primary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Sản phẩm sử dụng: ${item['sanphamsudung'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Thời gian: ${_formatDateTime(item['thoigian'])}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nhân công: ${item['nhancongthuchien'] ?? 'N/A'} người',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ghi chú: ${item['ghichu'] ?? 'Không có ghi chú'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   icon: Icon(Icons.edit, color: ColorConfig.primary),
                      //   tooltip: 'Sửa',
                      //   onPressed: () {
                      //     context.go(
                      //       '/processing-management/processing-history-edit/${widget.code}/${item['id']}',
                      //       extra: item,
                      //     );
                      //   },
                      // ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Xóa',
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, item['id']);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: Colors.white,
        elevation: 8,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF00695C), size: 28),
                tooltip: 'Làm mới',
                onPressed: _loadListProcessingHistory,
              ),
              IconButton(
                icon: const Icon(Icons.search_off, color: Color(0xFF00695C), size: 28),
                tooltip: 'Tìm kiếm',
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/processing-management/processing-history-create/${widget.code}');
        },
        tooltip: 'Thêm mới',
        backgroundColor: ColorConfig.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}