import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/repository/user_repository.dart';

import '../models/FriendsModel.dart';
import '../models/UserModel.dart';

class FriendsRepository {
  final _db = FirebaseFirestore.instance;
  final userRepository = UserRepository();

  Future<FriendsModel?> getFriendsList() async {
    try {
      String? currentUserId = await userRepository.getCurrentUserId();
      DocumentSnapshot documentSnapshot = await _db.collection('friends').doc(currentUserId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        return FriendsModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("Błąd podczas pobierania listy znajomych: $e");
      return null;
    }
  }

  Future<void> addFriend(String firstFriendUid, String secondFriendUid) async {
    try {
      DocumentReference firstFriendRef =
      _db.collection('friends').doc(firstFriendUid);
      DocumentReference secondFriendRef =
      _db.collection('friends').doc(secondFriendUid);

      DocumentSnapshot firstFriendSnapshot = await firstFriendRef.get();
      DocumentSnapshot secondFriendSnapshot = await secondFriendRef.get();

      FriendsModel firstFriendModel;
      FriendsModel secondFriendModel;

      if (firstFriendSnapshot.exists) {
        firstFriendModel = FriendsModel.fromJson(firstFriendSnapshot.data() as Map<String, dynamic>);
      } else {
        firstFriendModel = FriendsModel(user: firstFriendUid, friends: []);
      }

      if (secondFriendSnapshot.exists) {
        secondFriendModel = FriendsModel.fromJson(secondFriendSnapshot.data() as Map<String, dynamic>);
      } else {
        secondFriendModel = FriendsModel(user: secondFriendUid, friends: []);
      }

      if (!firstFriendModel.friends.contains(secondFriendUid)) {
        firstFriendModel.friends.add(secondFriendUid);
        await firstFriendRef.set(firstFriendModel.toJson());
      }

      if (!secondFriendModel.friends.contains(firstFriendUid)) {
        secondFriendModel.friends.add(firstFriendUid);
        await secondFriendRef.set(secondFriendModel.toJson());
      }
    } catch (e) {
      print("Błąd podczas dodawania znajomego: $e");
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      DocumentReference documentReference =
      _db.collection('friends').doc(userRepository.getCurrentUserId().toString());

      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        FriendsModel friendsModel =
        FriendsModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        friendsModel.friends.remove(friendId);

        await documentReference.update(friendsModel.toJson());
      }
    } catch (e) {
      print("Błąd podczas usuwania znajomego: $e");
    }
  }

  Future<List<UserModel>> loadFriendsList() async {
    FriendsModel? friendsModel = await getFriendsList();
    List<UserModel> friendsList = [];

    if (friendsModel != null) {
      for (String? friendId in friendsModel.friends) {
        if (friendId != null) {
          UserModel? friend = await UserRepository().getUserByUid(friendId);
          if (friend != null) {
            friendsList.add(friend);
          }
        }
      }
    }
    return friendsList;
  }
}