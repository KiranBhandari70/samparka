import '../../config/environment.dart';

class GroupModel {
  final String id;
  final String name;
  final String? _description;
  final List<String> keywords;
  final GroupLocation? location;
  final String createdBy;
  final String? createdByName;
  final String? createdByAvatar;
  final List<String> members;
  final int memberCount;
  final DateTime createdAt;
  final String imageUrl;

  const GroupModel({
    required this.id,
    required this.name,
    String? description,
    this.keywords = const [],
    this.location,
    required this.createdBy,
    this.createdByName,
    this.createdByAvatar,
    this.members = const [],
    this.memberCount = 0,
    required this.createdAt,
    this.imageUrl = '',
  }) : _description = description;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final createdByData = json['createdBy'];
    String createdById = '';
    String? createdByName;
    String? createdByAvatar;

    if (createdByData is Map<String, dynamic>) {
      createdById = createdByData['_id']?.toString() ?? createdByData['id']?.toString() ?? '';
      createdByName = createdByData['name'] as String?;
      createdByAvatar = createdByData['avatarUrl'] as String?;
    } else {
      createdById = createdByData?.toString() ?? '';
    }

    final members = <String>[];
    if (json['members'] is List) {
      for (final member in (json['members'] as List)) {
        if (member is Map<String, dynamic>) {
          members.add(member['_id']?.toString() ?? member['id']?.toString() ?? '');
        } else if (member != null) {
          members.add(member.toString());
        }
      }
    }

    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] as String?,
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'].map((k) => k.toString()))
          : [],
      location: json['location'] != null ? GroupLocation.fromJson(json['location']) : null,
      createdBy: createdById,
      createdByName: createdByName,
      createdByAvatar: createdByAvatar,
      members: members,
      memberCount: json['memberCount'] ?? members.length,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': _description,
      'keywords': keywords,
      'location': location?.toJson(),
      'createdBy': createdBy,
      'members': members,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  String get description => _description ?? '';

  String get imageUrlOrPlaceholder {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return imageUrl;
      }
      return '${Environment.apiBaseUrl}$imageUrl';
    }
    return 'https://via.placeholder.com/600x400?text=Group';
  }

  bool isMember(String userId) => members.contains(userId);

  int get onlineCount => 0; // Placeholder until real-time presence is implemented
}

class GroupLocation {
  final String type; // "Point"
  final List<double> coordinates; // [longitude, latitude]
  final String? placeName;

  const GroupLocation({
    this.type = "Point",
    required this.coordinates,
    this.placeName,
  });

  factory GroupLocation.fromJson(Map<String, dynamic> json) {
    return GroupLocation(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [],
      placeName: json['placeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'placeName': placeName,
    };
  }

  double? get longitude => coordinates.isNotEmpty ? coordinates[0] : null;
  double? get latitude => coordinates.length > 1 ? coordinates[1] : null;
}

class GroupMessage {
  final String id;
  final String groupId; // ObjectId reference
  final String senderId; // ObjectId reference (can be string or populated object)
  final String? senderName; // From populated senderId
  final String? senderAvatar; // From populated senderId
  final String message;
  final List<String> attachments;
  final DateTime sentAt;

  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.message,
    this.attachments = const [],
    required this.sentAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    // Handle populated senderId (object) or just ID (string)
    String senderId;
    String? senderName;
    String? senderAvatar;

    if (json['senderId'] is Map) {
      final sender = json['senderId'] as Map<String, dynamic>;
      senderId = sender['_id']?.toString() ?? sender['id']?.toString() ?? '';
      senderName = sender['name'] as String?;
      senderAvatar = sender['avatarUrl'] as String?;
    } else {
      senderId = json['senderId']?.toString() ?? '';
    }

    return GroupMessage(
      id: json['_id'] ?? json['id'] ?? '',
      groupId: json['groupId']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: json['message'] ?? json['content'] ?? '',
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      sentAt: json['sentAt'] != null 
          ? (json['sentAt'] is String 
              ? DateTime.parse(json['sentAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['sentAt']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'groupId': groupId,
      'senderId': senderId,
      'message': message,
      'attachments': attachments,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  // Convenience getters for backward compatibility
  String get content => message;
  bool get isOwn => false; // Should be computed based on current user
}

