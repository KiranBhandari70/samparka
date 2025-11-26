import 'dart:io';
import 'package:flutter/foundation.dart';

import '../data/models/event_comment_model.dart';
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
  List<EventModel> _userEvents = [];
  EventModel? _selectedEvent;
  final Map<String, List<EventCommentModel>> _eventComments = {};
  final Set<String> _loadingCommentsForEvents = {};
  final Set<String> _postingCommentsForEvents = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get filteredEvents => _filteredEvents;
  List<EventModel> get userEvents => _userEvents;
  EventModel? get selectedEvent => _selectedEvent;
  List<EventCommentModel> commentsFor(String eventId) => _eventComments[eventId] ?? [];
  bool isCommentsLoading(String eventId) => _loadingCommentsForEvents.contains(eventId);
  bool isPostingComment(String eventId) => _postingCommentsForEvents.contains(eventId);
  int? commentCountFor(String eventId) {
    if (_eventComments.containsKey(eventId)) {
      return _eventComments[eventId]!.length;
    }
    return null;
  }

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

  Future<EventModel> getEventById(String id) async {
    try {
      return await _eventService.getEventDetails(id);
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  Future<bool> createEvent(Map<String, dynamic> eventData, {File? imageFile}) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.createEvent(eventData, imageFile: imageFile);
      // Reload events after creation
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

  Future<bool> updateEvent(String id, Map<String, dynamic> eventData, {File? imageFile}) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.updateEvent(id, eventData, imageFile: imageFile);
      // Reload events after update
      await loadFeaturedEvents();
      await loadUpcomingEvents();
      // Reload user events if we have any
      if (_userEvents.isNotEmpty) {
        await loadUserEvents(_userEvents.first.createdBy);
      }
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

  Future<bool> deleteEvent(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.deleteEvent(id);
      // Remove from local lists
      _featuredEvents.removeWhere((e) => e.id == id);
      _upcomingEvents.removeWhere((e) => e.id == id);
      _filteredEvents.removeWhere((e) => e.id == id);
      _userEvents.removeWhere((e) => e.id == id);
      // Reload events to ensure UI is updated
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

  Future<void> loadUserEvents(String userId) async {
    if (userId.isEmpty) return;
    
    _setLoading(true);
    _clearError();

    try {
      _userEvents = await _eventService.getUserEvents(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadEventComments(String eventId) async {
    if (eventId.isEmpty) return;

    _loadingCommentsForEvents.add(eventId);
    notifyListeners();

    try {
      final comments = await _eventService.getEventComments(eventId);
      _eventComments[eventId] = comments;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _loadingCommentsForEvents.remove(eventId);
      notifyListeners();
    }
  }

  Future<bool> addEventComment(String eventId, String content) async {
    if (eventId.isEmpty || content.trim().isEmpty) return false;

    _postingCommentsForEvents.add(eventId);
    notifyListeners();

    try {
      final newComment = await _eventService.addEventComment(eventId, content.trim());
      final existing = _eventComments[eventId] ?? [];
      _eventComments[eventId] = [newComment, ...existing];
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _postingCommentsForEvents.remove(eventId);
      notifyListeners();
    }
  }

  Future<bool> deleteEventComment(String eventId, String commentId) async {
    if (eventId.isEmpty || commentId.isEmpty) return false;

    _postingCommentsForEvents.add(eventId);
    notifyListeners();

    try {
      await _eventService.deleteEventComment(eventId, commentId);
      final existing = _eventComments[eventId];
      if (existing != null) {
        existing.removeWhere((comment) => comment.id == commentId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _postingCommentsForEvents.remove(eventId);
      notifyListeners();
    }
  }
}
