import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class MockData {
  MockData._();

  static final UserModel currentUser = UserModel(
    id: 'user_1',
    name: 'Kiran Bhandari',
    username: '@kimchaystar',
    avatarUrl:
    'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?fit=crop&w=200&q=80',
    location: 'Kupundole, Lalitpur',
    interests: const ['Tech', 'Music', 'Sports', 'Art', 'Wellness'],
  );

  static final List<EventModel> featuredEvents = [
    EventModel(
      id: 'event_1',
      title: 'Indie Music Night',
      dateTime: DateTime(2025, 11, 2, 19, 0),
      locationName: 'The Blue Note Cafe',
      address: 'Jhamsikhel, Lalitpur',
      category: EventCategory.music,
      imageUrl:
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?fit=crop&w=800&q=80',
      description:
      'Join us for an intimate evening filled with soulful indie performances, authentic conversations, and great vibes.',
      attendeeCount: 45,
      capacity: 60,
      host: currentUser,
    ),
    EventModel(
      id: 'event_2',
      title: 'Tech Startup Networking',
      dateTime: DateTime(2025, 11, 5, 18, 30),
      locationName: 'Innovation Hub',
      address: 'Pulchowk, Lalitpur',
      category: EventCategory.tech,
      imageUrl:
      'https://images.unsplash.com/photo-1542744173-05336fcc7ad4?fit=crop&w=800&q=80',
      description:
      'Meet founders, investors, and engineers building the next wave of Nepali startups.',
      attendeeCount: 32,
      capacity: 80,
      host: currentUser,
    ),
    EventModel(
      id: 'event_3',
      title: 'Morning Fitness Bootcamp',
      dateTime: DateTime(2025, 11, 4, 7, 0),
      locationName: 'City Park',
      address: 'Jawalakhel',
      category: EventCategory.sports,
      imageUrl:
      'https://images.unsplash.com/photo-1554298060-7d2c892c8c9b?fit=crop&w=800&q=80',
      description:
      'Start your day with an energetic bootcamp session led by certified trainers.',
      attendeeCount: 20,
      capacity: 40,
      host: currentUser,
    ),
  ];

  static final List<EventModel> upcomingEvents = [
    EventModel(
      id: 'event_4',
      title: 'Moonlight Music Night',
      dateTime: DateTime(2025, 10, 31, 19, 0),
      locationName: 'Pizza Circle',
      address: 'Kupundole, Lalitpur',
      category: EventCategory.music,
      imageUrl:
      'https://images.unsplash.com/photo-1519074002996-a69e7ac46a42?fit=crop&w=800&q=80',
      description:
      'Enjoy an evening of live indie music featuring local artists with great vibes, good company, and amazing performances.',
      attendeeCount: 54,
      capacity: 80,
      host: currentUser,
    ),
    EventModel(
      id: 'event_5',
      title: 'Creative Artists Hub Meetup',
      dateTime: DateTime(2025, 11, 12, 16, 0),
      locationName: 'Art Station Nepal',
      address: 'Patan Durbar Square',
      category: EventCategory.art,
      imageUrl:
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?fit=crop&w=800&q=80',
      description:
      'Share your creativity, learn new techniques, and meet fellow artists from the valley.',
      attendeeCount: 28,
      capacity: 40,
      host: currentUser,
    ),
  ];

  static final List<GroupModel> groups = [
    GroupModel(
      id: 'group_1',
      name: 'Tech Entrepreneurs',
      description: 'For startup founders and tech enthusiasts',
      imageUrl:
      'https://images.unsplash.com/photo-1551836022-4c4c79ecde51?fit=crop&w=1200&q=80',
      memberCount: 1243,
      onlineCount: 45,
      isJoined: true,
      messages: [
        GroupMessage(
          id: 'msg_1',
          sender: UserModel(
            id: 'user_2',
            name: 'Prince Thapa',
            username: '@prince',
            avatarUrl:
            'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?fit=crop&w=200&q=80',
            location: 'Kathmandu, Nepal',
          ),
          content:
          'Hey everyone! Excited for the networking event tomorrow!',
          sentAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        GroupMessage(
          id: 'msg_2',
          sender: currentUser,
          content: 'Same here! Can\'t wait to meet everyone.',
          sentAt: DateTime.now().subtract(const Duration(hours: 1)),
          isOwn: true,
        ),
        GroupMessage(
          id: 'msg_3',
          sender: UserModel(
            id: 'user_3',
            name: 'Sakshyam Joshi',
            username: '@sakshyam',
            avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?fit=crop&w=200&q=80',
            location: 'Bhaktapur, Nepal',
          ),
          content: 'I\'ll be bringing some startup pitch decks to share ideas!',
          sentAt: DateTime.now().subtract(const Duration(minutes: 40)),
        ),
      ],
    ),
    GroupModel(
      id: 'group_2',
      name: 'Creative Artists Hub',
      description: 'Share your art and learn new techniques',
      imageUrl:
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?fit=crop&w=1200&q=80',
      memberCount: 645,
      onlineCount: 18,
      isJoined: false,
      messages: const [],
    ),
  ];

  static List<Color> categoryColors(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return [const Color(0xFFFF9F1C), const Color(0xFFFFBF69)];
      case EventCategory.art:
        return [const Color(0xFFFF3D77), const Color(0xFFFF6F91)];
      case EventCategory.sports:
        return [const Color(0xFF2ECC71), const Color(0xFF55E693)];
      case EventCategory.tech:
        return [const Color(0xFF0984E3), const Color(0xFF74B9FF)];
      case EventCategory.social:
        return [const Color(0xFFF53B57), const Color(0xFFFF6B81)];
      case EventCategory.food:
        return [const Color(0xFFFF5E57), const Color(0xFFFF9A8B)];
      case EventCategory.wellness:
        return [const Color(0xFF6C5CE7), const Color(0xFFB49BF7)];
      case EventCategory.others:
        return [const Color(0xFF636E72), const Color(0xFFB2BEC3)];
    }
  }

  static List<EventCategory> get categories => EventCategory.values.toList();
}


