import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tourpis/models/MessageModel.dart';
import 'package:tourpis/repository/user_repository.dart';

class ChatRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String toUser, String message) async {
    final String? currentUserId = await UserRepository().getCurrentUserId();
    final Timestamp timestamp = Timestamp.now();

    MessageModel messageModel = MessageModel(
        senderId: toUser,
        receiverId: currentUserId!,
        message: message,
        timestamp: timestamp);

    List<String> ids = [currentUserId, toUser];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageModel.toJson());
  }

  Stream<QuerySnapshot> getMesseges(String userId, String otherId) {
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
