import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventService {
  EventService._();

  static final EventService instance = EventService._();
  final _repository = EventRepository.instance;

  Future<List<EventModel>> getFeaturedEvents() async {
    return _repository.getEvents(limit: 10);
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    return _repository.getEvents(limit: 20);
  }

  Future<List<EventModel>> getEventsByCategory(String category) async {
    return _repository.getEvents(category: category);
  }

  Future<List<EventModel>> searchEvents(String query) async {
    return _repository.getEvents(searchQuery: query);
  }

  Future<EventModel> getEventDetails(String id) async {
    return _repository.getEventById(id);
  }

  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    return _repository.createEvent(eventData);
  }

  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData) async {
    return _repository.updateEvent(id, eventData);
  }

  Future<void> deleteEvent(String id) async {
    return _repository.deleteEvent(id);
  }

  Future<void> joinEvent(String id) async {
    return _repository.joinEvent(id);
  }

  Future<void> leaveEvent(String id) async {
    return _repository.leaveEvent(id);
  }
}
