import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/FriendRequestModel.dart';

class FriendRequestRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createRequest(String askerId, String friendId) async {
    FriendRequestModel friendRequest = FriendRequestModel(asker: askerId, friend: friendId);
    await _db.collection('requests').doc().set(friendRequest.toJson());
  }

  Future<void> deleteRequest(String requestId) async {
    await _db.collection('requests').doc(requestId).delete();
  }
}