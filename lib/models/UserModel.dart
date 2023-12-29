class UserModel {
  final String? id;
  final String login;
  final String email;
  final String uid;
  final String profileImageUrl;

  const UserModel({
    this.id,
    required this.login,
    required this.email,
    required this.uid,
    required this.profileImageUrl,
  });

  toJson() {
    return {
      "login": login,
      "email": email,
      "uid": uid,
      "profileImageUrl": profileImageUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      login: json['login'],
      email: json['email'],
      uid: json['uid'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}