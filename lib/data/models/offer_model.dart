import 'package:samparka/config/environment.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String businessName;
  final String category;
  final String discountType;
  final double discountValue;
  final int pointsRequired;
  final String? imageUrl;
  final String? termsAndConditions;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? maxRedemptions;
  final int currentRedemptions;
  final bool isActive;
  final String createdBy;
  final String? createdByName;
  final String? createdByAvatar;
  final OfferLocation? location;
  final ContactInfo? contactInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.businessName,
    required this.category,
    required this.discountType,
    required this.discountValue,
    required this.pointsRequired,
    this.imageUrl,
    this.termsAndConditions,
    required this.validFrom,
    required this.validUntil,
    this.maxRedemptions,
    required this.currentRedemptions,
    required this.isActive,
    required this.createdBy,
    this.createdByName,
    this.createdByAvatar,
    this.location,
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing for createdBy
    String createdBy = '';
    String? createdByName;
    String? createdByAvatar;

    if (json['createdBy'] != null) {
      if (json['createdBy'] is String) {
        createdBy = json['createdBy'] as String;
      } else if (json['createdBy'] is Map<String, dynamic>) {
        final createdByMap = json['createdBy'] as Map<String, dynamic>;
        createdBy = createdByMap['_id'] ?? '';
        createdByName = createdByMap['name'] as String?;
        createdByAvatar = createdByMap['avatarUrl'] as String?;
      }
    }

    return OfferModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      businessName: json['businessName'] ?? '',
      category: json['category'] ?? 'others',
      discountType: json['discountType'] ?? 'percentage',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      pointsRequired: (json['pointsRequired'] ?? 0).toInt(),
      imageUrl: json['imageUrl'],
      termsAndConditions: json['termsAndConditions'],
      validFrom: DateTime.parse(json['validFrom'] ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(json['validUntil'] ?? DateTime.now().toIso8601String()),
      maxRedemptions: json['maxRedemptions']?.toInt(),
      currentRedemptions: (json['currentRedemptions'] ?? 0).toInt(),
      isActive: json['isActive'] ?? true,
      createdBy: createdBy,
      createdByName: createdByName,
      createdByAvatar: createdByAvatar,
      location: json['location'] != null ? OfferLocation.fromJson(json['location']) : null,
      contactInfo: json['contactInfo'] != null ? ContactInfo.fromJson(json['contactInfo']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'businessName': businessName,
      'category': category,
      'discountType': discountType,
      'discountValue': discountValue,
      'pointsRequired': pointsRequired,
      'imageUrl': imageUrl,
      'termsAndConditions': termsAndConditions,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
      'isActive': isActive,
      'createdBy': createdBy,
      'location': location?.toJson(),
      'contactInfo': contactInfo?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Getters
  bool get isExpired => validUntil.isBefore(DateTime.now());
  
  bool get isAvailable {
    if (!isActive || isExpired) return false;
    if (maxRedemptions != null && currentRedemptions >= maxRedemptions!) return false;
    return true;
  }

  String get discountText {
    switch (discountType) {
      case 'percentage':
        return '${discountValue.toInt()}% OFF';
      case 'fixed_amount':
        return 'NPR ${discountValue.toInt()} OFF';
      case 'free_item':
        return 'Free Item';
      case 'buy_one_get_one':
        return 'Buy 1 Get 1';
      default:
        return 'Special Offer';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'food':
        return 'Food & Dining';
      case 'retail':
        return 'Retail & Shopping';
      case 'entertainment':
        return 'Entertainment';
      case 'services':
        return 'Services';
      case 'health':
        return 'Health & Wellness';
      case 'travel':
        return 'Travel & Tourism';
      default:
        return 'Others';
    }
  }

  String get imageUrlOrPlaceholder {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400';
    }
    if (imageUrl!.startsWith('http')) {
      return imageUrl!;
    }
    return '${Environment.apiBaseUrl}$imageUrl';
  }

  String get validityText {
    final now = DateTime.now();
    final difference = validUntil.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inDays > 0) {
      return 'Valid for ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Valid for ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Expires soon';
    }
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? businessName,
    String? category,
    String? discountType,
    double? discountValue,
    int? pointsRequired,
    String? imageUrl,
    String? termsAndConditions,
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxRedemptions,
    int? currentRedemptions,
    bool? isActive,
    String? createdBy,
    String? createdByName,
    String? createdByAvatar,
    OfferLocation? location,
    ContactInfo? contactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      imageUrl: imageUrl ?? this.imageUrl,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      maxRedemptions: maxRedemptions ?? this.maxRedemptions,
      currentRedemptions: currentRedemptions ?? this.currentRedemptions,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByAvatar: createdByAvatar ?? this.createdByAvatar,
      location: location ?? this.location,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OfferLocation {
  final String type;
  final List<double> coordinates;
  final String? address;
  final String? city;

  const OfferLocation({
    required this.type,
    required this.coordinates,
    this.address,
    this.city,
  });

  factory OfferLocation.fromJson(Map<String, dynamic> json) {
    return OfferLocation(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? [0.0, 0.0]),
      address: json['address'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'address': address,
      'city': city,
    };
  }
}

class ContactInfo {
  final String? phone;
  final String? email;
  final String? website;

  const ContactInfo({
    this.phone,
    this.email,
    this.website,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'website': website,
    };
  }
}

class OfferCategory {
  final String value;
  final String label;

  const OfferCategory({
    required this.value,
    required this.label,
  });

  factory OfferCategory.fromJson(Map<String, dynamic> json) {
    return OfferCategory(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}

class RedemptionResult {
  final OfferSummary offer;
  final int pointsDeducted;
  final int newBalance;
  final String redemptionCode;

  const RedemptionResult({
    required this.offer,
    required this.pointsDeducted,
    required this.newBalance,
    required this.redemptionCode,
  });

  factory RedemptionResult.fromJson(Map<String, dynamic> json) {
    return RedemptionResult(
      offer: OfferSummary.fromJson(json['offer']),
      pointsDeducted: (json['pointsDeducted'] ?? 0).toInt(),
      newBalance: (json['newBalance'] ?? 0).toInt(),
      redemptionCode: json['redemptionCode'] ?? '',
    );
  }
}

class OfferSummary {
  final String title;
  final String businessName;
  final String discountText;

  const OfferSummary({
    required this.title,
    required this.businessName,
    required this.discountText,
  });

  factory OfferSummary.fromJson(Map<String, dynamic> json) {
    return OfferSummary(
      title: json['title'] ?? '',
      businessName: json['businessName'] ?? '',
      discountText: json['discountText'] ?? '',
    );
  }
}
