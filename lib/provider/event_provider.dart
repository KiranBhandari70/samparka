import 'package:flutter/foundation.dart';

import '../data/models/event_model.dart';
import '../data/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  EventProvider() : _eventService = EventService.instance;

  final EventService _eventService;

  bool _isLoading = false;
  String? _error;
  List<EventModel> _featuredEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _filteredEvents = [];
  EventModel? _selectedEvent;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get filteredEvents => _filteredEvents;
  EventModel? get selectedEvent => _selectedEvent;

  Future<void> loadFeaturedEvents() async {
    _setLoading(true);
    _clearError();

    try {
      _featuredEvents = await _eventService.getFeaturedEvents();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadUpcomingEvents() async {
    _setLoading(true);
    _clearError();

    try {
      _upcomingEvents = await _eventService.getUpcomingEvents();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> filterEventsByCategory(String? category) async {
    if (category == null) {
      _filteredEvents = _featuredEvents;
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _filteredEvents = await _eventService.getEventsByCategory(category);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      _filteredEvents = _featuredEvents;
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _filteredEvents = await _eventService.searchEvents(query);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadEventDetails(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedEvent = await _eventService.getEventDetails(id);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> joinEvent(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.joinEvent(id);
      await loadFeaturedEvents();
      await loadUpcomingEvents();
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

  Future<bool> leaveEvent(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.leaveEvent(id);
      await loadFeaturedEvents();
      await loadUpcomingEvents();
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
