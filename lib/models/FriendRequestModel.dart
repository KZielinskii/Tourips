class FriendRequestModel {
  final String? id;
  final String? asker;
  final String? friend;

  const FriendRequestModel({
  this.id,
  this.asker,
  this.friend,
  });

  toJson() {
    return {
      "asker": asker,
      "friend": friend,
    };
  }

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'],
      asker: json['asker'],
      friend: json['friend'],
    );
  }
}