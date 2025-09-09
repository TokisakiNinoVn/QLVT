import 'package:txng/apis/helper/api_methods_private.dart';
import 'package:txng/apis/helper/api_methods_public.dart';
import '../apis/ticket_api.dart';

class TicketService {
  Future<Map<String, dynamic>> sendTicketConfirmation(String qrCode) async {
    return await ApiMethodsPrivate.postRequest(TicketApiRoutes.sendStringCode, {
      'qr_code': qrCode,
    });
  }

  Future<Map<String, dynamic>> getListOfTicket() async {
    return await ApiMethodsPublic.getRequest(TicketApiRoutes.listTicket);
  }

  Future<Map<String, dynamic>> createTicket(data) async {
    return await ApiMethodsPrivate.postRequest(
      TicketApiRoutes.createTicket,
      data,
    );
  }
}
