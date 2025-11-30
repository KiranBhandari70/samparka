import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';
import '../../config/environment.dart';

class TicketRepository {
  TicketRepository._();
  static final TicketRepository instance = TicketRepository._();

  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/api/v1/tickets/user/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['tickets'] != null) {
          final List<dynamic> ticketsJson = data['tickets'];
          return ticketsJson.map((json) => TicketModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load tickets: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching tickets: $e');
    }
  }

  Future<TicketModel> getTicketById(String ticketId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/api/v1/tickets/$ticketId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['ticket'] != null) {
          return TicketModel.fromJson(data['ticket']);
        }
      }
      throw Exception('Failed to load ticket: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching ticket: $e');
    }
  }

  Future<void> cancelTicket(String ticketId, String userId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/api/v1/tickets/$ticketId/cancel');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to cancel ticket');
      }
    } catch (e) {
      throw Exception('Error cancelling ticket: $e');
    }
  }
}

