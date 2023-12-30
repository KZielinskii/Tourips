import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/repository/user_repository.dart';

import '../models/FriendsModel.dart';
import '../models/UserModel.dart';

class FriendsRepository {
  final _db = FirebaseFirestore.instance;
  final userRepository = UserRepository();

  Future<FriendsModel?> getFriendsList() async {
    try {
      DocumentSnapshot documentSnapshot =
      await _db.collection('friends').doc(userRepository.getCurrentUserId().toString()).get();

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