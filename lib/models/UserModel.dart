class UserModel {
  final String? id;
  final String login;
  final String email;
  final String uid;

  const UserModel({
    this.id,
    required this.login,
    required this.email,
    required this.uid,
  });

  toJson() {
    return {
      "login": login,
      "email": email,
      "uid": uid,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      login: json['login'],
      email: json['email'],
      uid: json['uid'],
    );
  }
}