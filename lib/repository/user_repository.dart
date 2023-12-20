import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/UserModel.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Future<bool> checkIfLoginExists(String login) async {
    QuerySnapshot querySnapshot = await _db
        .collection('users')
        .where('login', isEqualTo: login)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> createUser(String login, String email, String uid) async {

    UserModel user = UserModel(login: login, email: email, uid: uid);
    await _db.collection('users').doc().set(user.toJson());
  }

  Future<UserModel?> getUserByUid(String uid) async {
    QuerySnapshot querySnapshot = await _db
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      UserModel user = UserModel.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
      print('Znaleziono użytkownika: ${user.login}');
      return user;
    } else {
      print('Nie znaleziono użytkownika o podanym UID');
    }
    return null;
  }
}
