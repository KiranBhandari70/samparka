class GroupModel {
  final String id;
  final String name;
  final String? _description;
  final String keyword;
  final GroupLocation? location;
  final String createdBy; // ObjectId reference
  final List<String> members; // List of ObjectId references
  final int memberCount;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    String? description,
    required this.keyword,
    this.location,
    required this.createdBy,
    this.members = const [],
    this.memberCount = 0,
    required this.createdAt,
  }) : _description = description;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] as String?,
      keyword: json['keyword'] ?? '',
      location: json['location'] != null 
          ? GroupLocation.fromJson(json['location']) 
          : null,
      createdBy: json['createdBy']?.toString() ?? '',
      members: json['members'] != null
          ? json['members'].map((m) => m.toString()).toList().cast<String>()
          : [],
      memberCount: json['memberCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': _description,
      'keyword': keyword,
      'location': location?.toJson(),
      'createdBy': createdBy,
      'members': members,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Description getter - non-nullable for UI compatibility
  String get description => _description ?? '';
  
  // Convenience getters for UI compatibility
  String get imageUrl => ''; // Not in backend schema - use placeholder
  int get onlineCount => 0; // Not in backend schema - use placeholder
  bool get isJoined => false; // Should be computed based on current user membership
  List<GroupMessage> get messages => []; // Messages are in separate collection
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
  final String senderId; // ObjectId reference
  final String message;
  final List<String> attachments;
  final DateTime sentAt;

  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.message,
    this.attachments = const [],
    required this.sentAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['_id'] ?? json['id'] ?? '',
      groupId: json['groupId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      message: json['message'] ?? '',
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      sentAt: json['sentAt'] != null 
          ? DateTime.parse(json['sentAt']) 
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

