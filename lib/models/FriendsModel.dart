
class FriendsModel {
  final String? id;
  final String? user;
  final List<String?> friends;

  const FriendsModel({
    this.id,
    required this.user,
    required this.friends,
  });

  toJson() {
    return {
      "user": user,
      "friends": friends,
    };
  }

  factory FriendsModel.fromJson(Map<String, dynamic> json) {
    return FriendsModel(
      id: json['id'],
      user: json['user'],
      friends: List<String?>.from(json['friends'] ?? []),
    );
  }
}