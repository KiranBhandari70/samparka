class UserModel {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String location;
  final List<String> interests;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.location,
    this.interests = const [],
  });
}

