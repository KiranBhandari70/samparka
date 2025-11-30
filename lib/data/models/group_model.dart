import '../../config/environment.dart';

/// ---------------------------
/// GROUP MODEL
/// ---------------------------
class GroupModel {
  final String id;
  final String name;
  final String? _description;
  final List<String> keywords;
  final GroupLocation? location;

  final String createdBy;
  final String? createdByName;
  final String? createdByAvatar;

  final List<Member> members;
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
    required this.memberCount,
    required this.createdAt,
    this.imageUrl = '',
  }) : _description = description;

  /// ---------------------------
  /// FROM JSON
  /// ---------------------------
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // --- CREATOR PARSE ---
    String createdById = '';
    String? createdByName;
    String? createdByAvatar;

    if (json['createdBy'] is Map<String, dynamic>) {
      final c = json['createdBy'] as Map<String, dynamic>;

      createdById = c['_id']?.toString() ?? c['id']?.toString() ?? '';
      createdByName = c['name'] as String?;
      createdByAvatar = c['avatarUrl'] as String?;
    } else {
      createdById = json['createdBy']?.toString() ?? '';
    }

    // --- MEMBERS PARSE ---
    final memberList = <Member>[];
    if (json['members'] is List) {
      for (final m in (json['members'] as List)) {
        if (m is Map<String, dynamic>) {
          memberList.add(Member.fromJson(m));
        } else if (m != null) {
          memberList.add(Member(id: m.toString(), name: 'Unknown'));
        }
      }
    }

    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'].map((x) => x.toString()))
          : [],
      location:
      json['location'] != null ? GroupLocation.fromJson(json['location']) : null,
      createdBy: createdById,
      createdByName: createdByName,
      createdByAvatar: createdByAvatar,
      members: memberList,
      memberCount: json['memberCount'] ?? memberList.length,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  /// ---------------------------
  /// TO JSON
  /// ---------------------------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': _description,
      'keywords': keywords,
      'location': location?.toJson(),
      'createdBy': createdBy,
      'members': members.map((m) => m.toJson()).toList(),
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  /// ---------------------------
  /// GETTERS
  /// ---------------------------
  String get description => _description ?? '';

  String get imageUrlOrPlaceholder {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) return imageUrl;
      return '${Environment.apiBaseUrl}$imageUrl';
    }
    return 'https://via.placeholder.com/600x400?text=Group';
  }

  bool isMember(String userId) => members.any((m) => m.id == userId);

  String? get createdByPhotoUrl {
    if (createdByAvatar == null || createdByAvatar!.isEmpty) return null;
    return createdByAvatar!.startsWith('http')
        ? createdByAvatar
        : '${Environment.apiBaseUrl}$createdByAvatar';
  }

  List<Member> get membersData => members;

  int get onlineCount => 0; // If needed later
}

/// ---------------------------
/// MEMBER MODEL
/// ---------------------------
class Member {
  final String id;
  final String name;
  final String? avatarUrl;

  const Member({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  String? get fullAvatarUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;

    return avatarUrl!.startsWith('http')
        ? avatarUrl
        : '${Environment.apiBaseUrl}$avatarUrl';
  }
}

/// ---------------------------
/// GROUP LOCATION
/// ---------------------------
class GroupLocation {
  final String type;
  final List<double> coordinates;
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
          ? List<double>.from(
        json['coordinates'].map((x) => x.toDouble()),
      )
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

/// ---------------------------
/// GROUP MESSAGE
/// ---------------------------
class GroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
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
    String senderId = '';
    String? senderName;
    String? senderAvatar;

    if (json['senderId'] is Map<String, dynamic>) {
      final s = json['senderId'] as Map<String, dynamic>;
      senderId = s['_id']?.toString() ?? s['id']?.toString() ?? '';
      senderName = s['name'] as String?;
      senderAvatar = s['avatarUrl'] as String?;
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

  String get content => message;

  bool get isOwn => false;
}
