import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? iconUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'iconUrl': iconUrl,
    };
  }
}

// ------------------------
// EventCategory enum + extension
// ------------------------
enum EventCategory {
  music,
  art,
  sports,
  tech,
  social,
  food,
  wellness,
  others,
}

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.music:
        return 'Music';
      case EventCategory.art:
        return 'Art';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.tech:
        return 'Tech';
      case EventCategory.social:
        return 'Social';
      case EventCategory.food:
        return 'Food';
      case EventCategory.wellness:
        return 'Wellness';
      case EventCategory.others:
        return 'Others';
    }
  }

  // Gradient colors for UI
  List<Color> get colors {
    switch (this) {
      case EventCategory.music:
        return [Colors.purple, Colors.pink];
      case EventCategory.art:
        return [Colors.orange, Colors.deepOrange];
      case EventCategory.sports:
        return [Colors.green, Colors.lightGreen];
      case EventCategory.tech:
        return [Colors.blue, Colors.lightBlue];
      case EventCategory.social:
        return [Colors.teal, Colors.cyan];
      case EventCategory.food:
        return [Colors.red, Colors.orangeAccent];
      case EventCategory.wellness:
        return [Colors.indigo, Colors.blueGrey];
      case EventCategory.others:
        return [AppColors.primary];
    }
  }

  static EventCategory? fromString(String name) {
    switch (name.toLowerCase()) {
      case 'music':
        return EventCategory.music;
      case 'art':
        return EventCategory.art;
      case 'sports':
        return EventCategory.sports;
      case 'tech':
        return EventCategory.tech;
      case 'social':
        return EventCategory.social;
      case 'food':
        return EventCategory.food;
      case 'wellness':
        return EventCategory.wellness;
      case 'others':
        return EventCategory.others;
      default:
        return null;
    }
  }
}
