import 'package:flutter/material.dart';
import 'category_model.dart';
import 'user_model.dart';

class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? _categoryString; // Category name from backend
  final DateTime startsAt;
  final DateTime? endsAt;
  final int capacity;
  final String? imageUrl;
  final List<String> tags;
  final List<TicketTier> ticketTiers;
  final double rewardBoost;
  final bool isSponsored;
  final EventLocation? location;
  final String createdBy;
  final List<String> attendees;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    String? category,
    required this.startsAt,
    this.endsAt,
    this.capacity = 50,
    this.imageUrl,
    this.tags = const [],
    this.ticketTiers = const [],
    this.rewardBoost = 50.0,
    this.isSponsored = false,
    this.location,
    required this.createdBy,
    this.attendees = const [],
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : _categoryString = category;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'],
      startsAt: json['startsAt'] != null
          ? DateTime.parse(json['startsAt'])
          : DateTime.now(),
      endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : null,
      capacity: json['capacity'] ?? 50,
      imageUrl: json['imageUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      ticketTiers: json['ticketTiers'] != null
          ? (json['ticketTiers'] as List)
          .map((t) => TicketTier.fromJson(t))
          .toList()
          : [],
      rewardBoost: (json['rewardBoost'] ?? 50).toDouble(),
      isSponsored: json['isSponsored'] ?? false,
      location: json['location'] != null
          ? EventLocation.fromJson(json['location'])
          : null,
      createdBy: json['createdBy']?.toString() ?? '',
      attendees: json['attendees'] != null
          ? List<String>.from(json['attendees'].map((a) => a.toString()))
          : [],
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': _categoryString,
      'startsAt': startsAt.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
      'capacity': capacity,
      'imageUrl': imageUrl,
      'tags': tags,
      'ticketTiers': ticketTiers.map((t) => t.toJson()).toList(),
      'rewardBoost': rewardBoost,
      'isSponsored': isSponsored,
      'location': location?.toJson(),
      'createdBy': createdBy,
      'attendees': attendees,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // -------------------
  // Convenience getters
  // -------------------

  DateTime get dateTime => startsAt;
  String get locationName => location?.placeName ?? '';
  int get attendeeCount => attendees.length;

  String get imageUrlOrPlaceholder =>
      (imageUrl != null && imageUrl!.isNotEmpty)
          ? imageUrl!
          : 'https://via.placeholder.com/400x250';

  String? get categoryString => _categoryString;

  EventCategory get category {
    if (_categoryString == null) return EventCategory.others;
    return EventCategoryX.fromString(_categoryString!) ?? EventCategory.others;
  }

  List<Color> get categoryColors => category.colors;

  UserModel? get host => null; // TODO: fetch using createdBy

  String get timeLabel {
    final hour = startsAt.hour;
    final minute = startsAt.minute;
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

class TicketTier {
  final String label;
  final double price;
  final String currency;
  final double? rewardPoints;

  const TicketTier({
    required this.label,
    this.price = 0.0,
    this.currency = "NPR",
    this.rewardPoints,
  });

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    return TicketTier(
      label: json['label'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'NPR',
      rewardPoints: json['rewardPoints'] != null
          ? (json['rewardPoints'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'price': price,
      'currency': currency,
      'rewardPoints': rewardPoints,
    };
  }
}

class EventLocation {
  final String type;
  final List<double> coordinates;
  final String? placeName;
  final String? address;

  const EventLocation({
    this.type = "Point",
    required this.coordinates,
    this.placeName,
    this.address,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [],
      placeName: json['placeName'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'placeName': placeName,
      'address': address,
    };
  }

  double? get longitude => coordinates.isNotEmpty ? coordinates[0] : null;
  double? get latitude => coordinates.length > 1 ? coordinates[1] : null;
}
