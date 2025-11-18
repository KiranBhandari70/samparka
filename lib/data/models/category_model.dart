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
}

