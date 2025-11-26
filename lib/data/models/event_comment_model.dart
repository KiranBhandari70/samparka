import 'package:samparka/config/environment.dart';

class EventCommentModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;

  const EventCommentModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  factory EventCommentModel.fromJson(Map<String, dynamic> json) {
    String userId = '';
    String userName = 'Unknown';
    String? avatar;

    final userData = json['user'];
    if (userData is Map<String, dynamic>) {
      userId = userData['_id']?.toString() ?? userData['id']?.toString() ?? '';
      userName = userData['name']?.toString() ?? userName;
      avatar = userData['avatarUrl'] as String?;
    } else if (userData != null) {
      userId = userData.toString();
    } else {
      userId = json['userId']?.toString() ?? '';
    }

    return EventCommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventId: json['event']?.toString() ?? '',
      userId: userId,
      userName: userName,
      userAvatar: avatar,
      content: json['content'] ?? json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': eventId,
      'user': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get avatarUrlResolved {
    if (userAvatar == null || userAvatar!.isEmpty) {
      final initials = Uri.encodeComponent(userName.isNotEmpty ? userName : 'User');
      return 'https://ui-avatars.com/api/?name=$initials&background=2F80ED&color=ffffff';
    }

    if (userAvatar!.startsWith('http')) {
      return userAvatar!;
    }

    final baseUrl = Environment.apiBaseUrl;
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final imagePath = userAvatar!.startsWith('/') ? userAvatar! : '/$userAvatar';
    return '$normalizedBase$imagePath';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '${weeks}w ago';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';
    final years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }
}

