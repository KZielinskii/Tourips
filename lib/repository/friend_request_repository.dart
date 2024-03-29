import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/FriendRequestModel.dart';
import 'package:tourpis/repository/user_repository.dart';

import '../models/UserModel.dart';

class FriendRequestRepository {
  final _db = FirebaseFirestore.instance;
  final UserRepository _userRepository = UserRepository();

  Future<bool> createRequest(String askerId, String friendId) async {
    final existingRequest = await _db
        .collection('requests')
        .where('asker', isEqualTo: askerId)
        .where('friend', isEqualTo: friendId)
        .get();

    final reverseExistingRequest = await _db
        .collection('requests')
        .where('asker', isEqualTo: friendId)
        .where('friend', isEqualTo: askerId)
        .get();

    if (existingRequest.docs.isEmpty && reverseExistingRequest.docs.isEmpty) {
      FriendRequestModel friendRequest = FriendRequestModel(
        asker: askerId,
        friend: friendId,
      );

      await _db.collection('requests').doc().set(friendRequest.toJson());
      print('Friend request created successfully!');
      return true;
    } else {
      print('Similar friend request already exists.');
      return false;
    }
  }

  Future<int> getRequestCountToUser() async {
    String? currentUserId = await _userRepository.getCurrentUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('friend', isEqualTo: currentUserId)
        .get();

    int count = querySnapshot.size;
    return count;
  }

  Future<List<UserModel>> getAllRequestToUser() async {
    List<UserModel> allRequest = [];
    String? currentUserId = await _userRepository.getCurrentUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('friend', isEqualTo: currentUserId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      FriendRequestModel requestModel = FriendRequestModel.fromJson(doc.data() as Map<String, dynamic>);
      UserModel? user = await _userRepository.getUserByUid(requestModel.asker);
      allRequest.add(user!);
    }

    return allRequest;
  }

  Future<List<UserModel>> getAllRequestFromUser(String userId) async {
    List<UserModel> allRequest = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('asker', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      FriendRequestModel requestModel = FriendRequestModel.fromJson(doc.data() as Map<String, dynamic>);
      UserModel? user = await _userRepository.getUserByUid(requestModel.friend);
      allRequest.add(user!);
    }

    return allRequest;
  }

  Future<void> deleteRequestByAskerId(String askerId, String currentUserId) async {
    CollectionReference requests = FirebaseFirestore.instance.collection('requests');

    QuerySnapshot querySnapshot = await requests
        .where('asker', isEqualTo: askerId)
        .where('friend', isEqualTo: currentUserId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await requests.doc(querySnapshot.docs.first.id).delete();
      print('Request deleted successfully');
    } else {
      print('No matching request found');
    }
  }
}