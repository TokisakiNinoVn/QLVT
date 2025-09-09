// auth_routes.dart
import '../config/config.dart';

class TicketApiRoutes {
  static final String sendStringCode = '${Config.domain}/ticket/scan-qr';
  static final String listTicket = '${Config.domain}/app/tickets';
  static final String createTicket = '${Config.domain}/ticket/create';
}
