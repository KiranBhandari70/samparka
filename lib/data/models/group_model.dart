import 'user_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int memberCount;
  final int onlineCount;
  final bool isJoined;
  final List<GroupMessage> messages;

  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
    required this.onlineCount,
    this.isJoined = false,
    this.messages = const [],
  });
}

class GroupMessage {
  final String id;
  final UserModel sender;
  final String content;
  final DateTime sentAt;
  final bool isOwn;

  const GroupMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.sentAt,
    this.isOwn = false,
  });
}

