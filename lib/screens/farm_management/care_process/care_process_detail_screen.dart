import 'package:flutter/material.dart';
import 'package:txng/config/color_config.dart';

class CareProcessDetailScreen extends StatelessWidget {
  final Map<String, dynamic> careProcess;

  const CareProcessDetailScreen({super.key, required this.careProcess});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw;
    }
  }

  Widget _buildDetailItem(
      String label,
      String value, {
        bool isTitle = false,
        bool isMultiline = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTitle ? 18 : 14,
            fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTitle ? 18 : 16,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết quy trình chăm sóc"),
        backgroundColor: ColorConfig.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
              'Hoạt động',
              careProcess["hoatdong"],
              isTitle: true,
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              'Mô tả',
              careProcess["mota"],
              isMultiline: true,
            ),
            _buildDetailItem(
              'Thứ tự',
              careProcess["sapxep"].toString(),
            ),
            // _buildDetailItem(
            //   'Mã vùng trồng',
            //   careProcess["mavungtrong"].toString(),
            // ),
            _buildDetailItem(
              'Ngày tạo',
              _formatDate(careProcess["created_at"]),
            ),
            _buildDetailItem(
              'Ngày cập nhật',
              _formatDate(careProcess["updated_at"]),
            ),
            // _buildDetailItem(
            //   'Mã doanh nghiệp',
            //   careProcess["madoanhnghiep"].toString(),
            // ),
          ],
        ),
      ),
    );
  }
}