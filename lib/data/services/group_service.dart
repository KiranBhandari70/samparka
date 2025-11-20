import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../models/group_model.dart';

class GroupService {
  GroupService._();

  static final GroupService instance = GroupService._();
  final _apiClient = ApiClient.instance;

  Future<List<GroupModel>> getGroups({
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiEndpoints.groups,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseListResponse(response) ?? [];
        // TODO: Parse JSON to GroupModel list
        return [];
      }

      throw Exception('Failed to load groups: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching groups: $e');
    }
  }

  Future<GroupModel> getGroupById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.groupById(id));

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // TODO: Parse JSON to GroupModel
        throw UnimplementedError('Parse group from JSON');
      }

      throw Exception('Failed to load group: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching group: $e');
    }
  }

  Future<GroupModel> createGroup(Map<String, dynamic> groupData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createGroup,
        body: groupData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // TODO: Parse JSON to GroupModel
        throw UnimplementedError('Parse group from JSON');
      }

      throw Exception('Failed to create group: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  Future<void> joinGroup(String id) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.joinGroup(id));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to join group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error joining group: $e');
    }
  }

  Future<void> leaveGroup(String id) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.leaveGroup(id));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to leave group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error leaving group: $e');
    }
  }

  Future<List<GroupMessage>> getMessages(String groupId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.groupMessages(groupId));

      if (response.statusCode == 200) {
        final data = _apiClient.parseListResponse(response) ?? [];
        // TODO: Parse JSON to GroupMessage list
        return [];
      }

      throw Exception('Failed to load messages: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<GroupMessage> sendMessage(String groupId, String content) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendMessage(groupId),
        body: {'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _apiClient.parseResponse(response);
        // TODO: Parse JSON to GroupMessage
        throw UnimplementedError('Parse message from JSON');
      }

      throw Exception('Failed to send message: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
