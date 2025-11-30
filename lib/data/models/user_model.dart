import 'package:samparka/config/environment.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? passwordHash;
  final String authProvider; // "email" or "google"
  final int? age;
  final List<String> interests;
  final String? bio;
  final String? avatarUrl;
  final String? locationLabel;
  final Location? location; // GeoJSON Point with coordinates
  final String role; // "member", "admin", or "business"
  final String verificationStatus; // "not_submitted", "pending", "approved", "rejected"
  final bool verified;
  final VerificationData? verificationData;
  final double rewardBalance;
  final bool blocked;
  final String? businessProfile; // ObjectId reference
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.authProvider = "email",
    this.age,
    this.interests = const [],
    this.bio,
    this.avatarUrl,
    this.locationLabel,
    this.location,
    this.role = "member",
    this.verificationStatus = "not_submitted",
    this.verified = false,
    this.verificationData,
    this.rewardBalance = 0.0,
    this.blocked = false,
    this.businessProfile,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? authProvider,
    int? age,
    List<String>? interests,
    String? bio,
    String? avatarUrl,
    String? locationLabel,
    Location? location,
    String? role,
    String? verificationStatus,
    bool? verified,
    VerificationData? verificationData,
    double? rewardBalance,
    bool? blocked,
    String? businessProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      authProvider: authProvider ?? this.authProvider,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      locationLabel: locationLabel ?? this.locationLabel,
      location: location ?? this.location,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verified: verified ?? this.verified,
      verificationData: verificationData ?? this.verificationData,
      rewardBalance: rewardBalance ?? this.rewardBalance,
      blocked: blocked ?? this.blocked,
      businessProfile: businessProfile ?? this.businessProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'],
      authProvider: json['authProvider'] ?? 'email',
      age: json['age'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : [],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      locationLabel: json['locationLabel'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      role: json['role'] ?? 'member',
      verificationStatus: json['verificationStatus'] ?? 'not_submitted',
      verified: json['verified'] ?? false,
      verificationData: json['verificationData'] != null
          ? VerificationData.fromJson(json['verificationData'])
          : null,
      rewardBalance: (json['rewardBalance'] ?? 0).toDouble(),
      blocked: json['blocked'] ?? false,
      businessProfile: json['businessProfile']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'authProvider': authProvider,
      'age': age,
      'interests': interests,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'locationLabel': locationLabel,
      'location': location?.toJson(),
      'role': role,
      'verificationStatus': verificationStatus,
      'verified': verified,
      'verificationData': verificationData?.toJson(),
      'rewardBalance': rewardBalance,
      'blocked': blocked,
      'businessProfile': businessProfile,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String? get avatarUrlResolved {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    if (avatarUrl!.startsWith('http')) return avatarUrl!;
    return '${Environment.apiBaseUrl}$avatarUrl';
  }

  String get avatarUrlOrPlaceholder {
    return avatarUrlResolved ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name.isNotEmpty ? name : 'User')}'
            '&background=2F80ED&color=ffffff';
  }
}

class Location {
  final String type; // "Point"
  final List<double> coordinates; // [longitude, latitude]

  const Location({
    this.type = "Point",
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null 
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double? get longitude => coordinates.isNotEmpty ? coordinates[0] : null;
  double? get latitude => coordinates.length > 1 ? coordinates[1] : null;
}

class VerificationData {
  final String? phoneNumber;
  final String? citizenshipFrontUrl;
  final String? citizenshipBackUrl;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  const VerificationData({
    this.phoneNumber,
    this.citizenshipFrontUrl,
    this.citizenshipBackUrl,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory VerificationData.fromJson(Map<String, dynamic> json) {
    return VerificationData(
      phoneNumber: json['phoneNumber'],
      citizenshipFrontUrl: json['citizenshipFrontUrl'],
      citizenshipBackUrl: json['citizenshipBackUrl'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy']?.toString(),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'citizenshipFrontUrl': citizenshipFrontUrl,
      'citizenshipBackUrl': citizenshipBackUrl,
      'submittedAt': submittedAt?.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }

  String? get citizenshipFrontUrlResolved {
    if (citizenshipFrontUrl == null || citizenshipFrontUrl!.isEmpty) return null;
    if (citizenshipFrontUrl!.startsWith('http')) return citizenshipFrontUrl!;
    return '${Environment.apiBaseUrl}$citizenshipFrontUrl';
  }

  String? get citizenshipBackUrlResolved {
    if (citizenshipBackUrl == null || citizenshipBackUrl!.isEmpty) return null;
    if (citizenshipBackUrl!.startsWith('http')) return citizenshipBackUrl!;
    return '${Environment.apiBaseUrl}$citizenshipBackUrl';
  }
}

