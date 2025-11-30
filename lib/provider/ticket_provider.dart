import 'package:flutter/foundation.dart';
import '../data/models/ticket_model.dart';
import '../data/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  TicketProvider() : _ticketService = TicketService.instance;

  final TicketService _ticketService;

  bool _isLoading = false;
  String? _error;
  List<TicketModel> _userTickets = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TicketModel> get userTickets => _userTickets;
  int get ticketCount => _userTickets.length;
  List<TicketModel> get activeTickets => _userTickets.where((t) => t.isActive).toList();

  Future<void> loadUserTickets(String userId) async {
    if (userId.isEmpty) return;

    _setLoading(true);
    _clearError();

    try {
      _userTickets = await _ticketService.getUserTickets(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> cancelTicket(String ticketId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _ticketService.cancelTicket(ticketId, userId);
      // Remove from local list
      _userTickets.removeWhere((t) => t.id == ticketId);
      // Reload tickets to ensure UI is updated
      await loadUserTickets(userId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? value) {
    _error = value;
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}

