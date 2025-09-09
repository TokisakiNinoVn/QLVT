import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:txng/services/ticket_service.dart';

class TicketConfirmationScreen extends StatefulWidget {
  const TicketConfirmationScreen({super.key, this.ticketData});

  final Map<String, dynamic>? ticketData;

  @override
  State<TicketConfirmationScreen> createState() =>
      _TicketConfirmationScreenState();
}

class _TicketConfirmationScreenState extends State<TicketConfirmationScreen>
    with SingleTickerProviderStateMixin {
  bool _showQr = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final ticketService = TicketService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleQr() {
    setState(() => _showQr = !_showQr);
    if (_showQr) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _confirmPayment() async {
    try {
      final ticketData =
          widget.ticketData ??
          GoRouterState.of(context).extra as Map<String, dynamic>? ??
          {};

      if (!ticketData.containsKey('train') ||
          !ticketData.containsKey('fullName') ||
          !ticketData.containsKey('phone') ||
          !ticketData.containsKey('age') ||
          !ticketData.containsKey('email')) {
        throw Exception('Thiếu thông tin bắt buộc để tạo vé.');
      }

      final payload = {
        'ticket_id': ticketData['train'],
        'name': ticketData['fullName'],
        'phone': ticketData['phone'],
        'birthday':
            int.tryParse(ticketData['age'].toString()) ??
            (throw Exception('Độ tuổi không hợp lệ.')),
        'email': ticketData['email'],
      };

      // final response = await ticketService.createTicket(payload);
      await ticketService.createTicket(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vé đã được tạo thành công!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo vé: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketData =
        widget.ticketData ??
        GoRouterState.of(context).extra as Map<String, dynamic>? ??
        {};
    final ticket = ticketData['ticket'] ?? {};

    final departureTime =
        ticket['departure_time'] != null
            ? DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(DateTime.parse(ticket['departure_time']))
            : 'N/A';
    final arrivalTime =
        ticket['arrival_time'] != null
            ? DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(DateTime.parse(ticket['arrival_time']))
            : 'N/A';
    final price =
        ticket['price'] != null
            ? NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'VNĐ',
              decimalDigits: 0,
            ).format(int.tryParse(ticket['price'].toString()) ?? 0)
            : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xác nhận vé - Chi tiết vé',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.train_rounded,
                            label: 'Tuyến tàu',
                            value: ticket['route_name'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Khởi hành',
                            value: departureTime,
                          ),
                          _buildInfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Đến',
                            value: arrivalTime,
                          ),
                          _buildInfoRow(
                            icon: Icons.monetization_on_rounded,
                            label: 'Giá vé',
                            value: price,
                          ),
                          _buildInfoRow(
                            icon: Icons.confirmation_number_rounded,
                            label: 'Loại vé',
                            value: ticketData['ticketType'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            icon: Icons.person_rounded,
                            label: 'Họ tên',
                            value: ticketData['fullName'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            icon: Icons.phone_rounded,
                            label: 'Số điện thoại',
                            value: ticketData['phone'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            icon: Icons.cake_rounded,
                            label: 'Độ tuổi',
                            value: ticketData['age']?.toString() ?? 'N/A',
                          ),
                          _buildInfoRow(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: ticketData['email'] ?? 'N/A',
                          ),
                          if (ticket['des'] != null) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Mô tả:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Html(data: ticket['des']),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildGradientButton(
                    context,
                    label: 'Hiển thị mã QR thanh toán',
                    icon: Icons.qr_code_2_rounded,
                    onPressed: _toggleQr,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGradientButton(
                    context,
                    label: 'Xác nhận đã thanh toán',
                    icon: Icons.check_circle_rounded,
                    onPressed: _confirmPayment,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade900],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_showQr)
            GestureDetector(
              onTap: _toggleQr,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                size: 180,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Vui lòng thanh toán số tiền: $price',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade900,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Quét mã QR để thanh toán',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade900,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Column(
                              children: [
                                TextButton.icon(
                                  onPressed: _toggleQr,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.red.shade700,
                                    size: 28,
                                  ),
                                  label: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _confirmPayment,
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.green.shade500,
                                    size: 28,
                                  ),
                                  label: Text(
                                    'Xác nhận đã thanh toán',
                                    style: TextStyle(
                                      color: Colors.green.shade500,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required LinearGradient gradient,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
