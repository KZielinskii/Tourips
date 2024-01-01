import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/UserModel.dart';
import 'friends_repository.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

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
      return user;
    } else {
      print('Nie znaleziono użytkownika o podanym UID');
    }
    return null;
  }

  Future<String?> getUserIdByUid(String uid) async {
    QuerySnapshot querySnapshot = await _db
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    return querySnapshot.docs.first.id;
  }

  Future<void> updateUserLogin(String uid, String newLogin) async {
    bool loginExists = await checkIfLoginExists(newLogin);
    if (loginExists) {
      throw Exception('Podany login już istnieje. Wybierz inny.');
    }

    UserModel? userModel = await getUserByUid(uid);
    if (userModel != null) {

      String? id = await getUserIdByUid(uid);
      await _db.collection('users').doc(id).update({'login': newLogin});
      print('Update successful');

      userModel = await getUserByUid(uid);
      print('Updated Login: ${userModel?.login}');
    } else {
      print('UserModel is null, unable to update login.');
    }
  }

  Future<List<UserModel>> getAllUsersExceptFriends({int limit = 10}) async {
    List<UserModel> allUsers = [];
    List<UserModel> friendsList = await FriendsRepository().loadFriendsList();
    String? currentUserId = await UserRepository().getCurrentUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .limit(limit)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      bool isFriend = false;
      UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      if (user.uid != currentUserId) {
        for (var friend in friendsList) {
          if (friend.uid == user.uid) {
            isFriend = true;
          }
        }
        if (!isFriend) allUsers.add(user);
      }
    }

    return allUsers;
  }


}
