import '../models/event_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class EventRepository {
  EventRepository._();

  static final EventRepository instance = EventRepository._();
  final _apiClient = ApiClient.instance;

  Future<List<EventModel>> getEvents({
    String? category,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiEndpoints.events,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseListResponse(response) ?? [];
        // TODO: Parse JSON to EventModel list
        return [];
      }

      throw Exception('Failed to load events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<EventModel> getEventById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.eventById(id));

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // TODO: Parse JSON to EventModel
        throw UnimplementedError('Parse event from JSON');
      }

      throw Exception('Failed to load event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createEvent,
        body: eventData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // TODO: Parse JSON to EventModel
        throw UnimplementedError('Parse event from JSON');
      }

      throw Exception('Failed to create event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateEvent(id),
        body: eventData,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // TODO: Parse JSON to EventModel
        throw UnimplementedError('Parse event from JSON');
      }

      throw Exception('Failed to update event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.deleteEvent(id));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  Future<void> joinEvent(String id) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.joinEvent(id));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to join event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error joining event: $e');
    }
  }

  Future<void> leaveEvent(String id) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.leaveEvent(id));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to leave event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error leaving event: $e');
    }
  }
}
