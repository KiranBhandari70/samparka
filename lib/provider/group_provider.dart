import 'package:flutter/foundation.dart';

import '../data/models/group_model.dart';
import '../data/services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  GroupProvider() : _groupService = GroupService.instance;

  final GroupService _groupService;

  bool _isLoading = false;
  String? _error;
  List<GroupModel> _groups = [];
  List<GroupModel> _myGroups = [];
  List<GroupModel> _suggestedGroups = [];
  GroupModel? _selectedGroup;
  List<GroupMessage> _messages = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<GroupModel> get groups => _groups;
  List<GroupModel> get myGroups => _myGroups;
  List<GroupModel> get suggestedGroups => _suggestedGroups;
  GroupModel? get selectedGroup => _selectedGroup;
  List<GroupMessage> get messages => _messages;

  Future<void> loadGroups() async {
    _setLoading(true);
    _clearError();

    try {
      _groups = await _groupService.getGroups();
      _myGroups = _groups.where((g) => g.isJoined).toList();
      _suggestedGroups = _groups.where((g) => !g.isJoined).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadGroupDetails(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedGroup = await _groupService.getGroupById(id);
      if (_selectedGroup != null) {
        _messages = await _groupService.getMessages(id);
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> joinGroup(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.joinGroup(id);
      await loadGroups();
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

  Future<bool> leaveGroup(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.leaveGroup(id);
      await loadGroups();
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

  Future<bool> sendMessage(String groupId, String content) async {
    _setLoading(true);
    _clearError();

    try {
      final message = await _groupService.sendMessage(groupId, content);
      _messages.add(message);
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

  Future<void> loadMessages(String groupId) async {
    _setLoading(true);
    _clearError();

    try {
      _messages = await _groupService.getMessages(groupId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
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
