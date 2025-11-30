import '../models/ticket_model.dart';
import '../repositories/ticket_repository.dart';

class TicketService {
  TicketService._();
  static final TicketService instance = TicketService._();
  final _repository = TicketRepository.instance;

  Future<List<TicketModel>> getUserTickets(String userId) async {
    return _repository.getUserTickets(userId);
  }

  Future<TicketModel> getTicketById(String ticketId) async {
    return _repository.getTicketById(ticketId);
  }

  Future<void> cancelTicket(String ticketId, String userId) async {
    return _repository.cancelTicket(ticketId, userId);
  }
}

