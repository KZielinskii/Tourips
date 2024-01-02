import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/UserModel.dart';
import 'friend_request_repository.dart';
import 'friends_repository.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<bool> checkIfLoginExists(String login) async {
    QuerySnapshot querySnapshot =
        await _db.collection('users').where('login', isEqualTo: login).get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> createUser(String login, String email, String uid) async {
    UserModel user = UserModel(login: login, email: email, uid: uid);
    await _db.collection('users').doc().set(user.toJson());
  }

  Future<UserModel?> getUserByUid(String uid) async {
    QuerySnapshot querySnapshot =
        await _db.collection('users').where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      UserModel user = UserModel.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
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

  Future<List<UserModel>> getAllUsersExceptFriends() async {
    FriendRequestRepository friendRequestRepository = FriendRequestRepository();
    FriendsRepository friendsRepository = FriendsRepository();

    List<UserModel> allUsers = [];
    List<UserModel> friendsList = await friendsRepository.loadFriendsList();
    String? userId = await getCurrentUserId();
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').limit(64).get();

    List<UserModel> sentRequestsList =
        await friendRequestRepository.getAllRequestFromUser(userId!);
    List<UserModel> receivedRequestsList =
        await friendRequestRepository.getAllRequestToUser();

    print(friendsList.length);
    print(sentRequestsList.length);
    print(receivedRequestsList.first.login);
    print(allUsers.length);

    allUsers = querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .where((user) =>
            user.uid != userId &&
            !friendsList.any((friend) => friend.uid == user.uid) &&
            user.uid != userId &&
            !sentRequestsList
                .any((requestUser) => requestUser.uid == user.uid) &&
            !receivedRequestsList
                .any((requestUser) => requestUser.uid == user.uid))
        .toList();

    print(allUsers.length);

    return allUsers;
  }
}
