import 'category_model.dart';
import 'user_model.dart';

class EventModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final String locationName;
  final String address;
  final EventCategory category;
  final String imageUrl;
  final String description;
  final int attendeeCount;
  final int capacity;
  final UserModel host;

  const EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.locationName,
    required this.address,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.attendeeCount,
    required this.capacity,
    required this.host,
  });

  String get timeLabel {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final hour12 = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
