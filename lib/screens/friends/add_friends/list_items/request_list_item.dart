import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/repository/friends_repository.dart';
import 'package:tourpis/screens/friends/add_friends/list_items/request_list_item_view.dart';
import 'package:tourpis/widgets/widget.dart';

import '../../../../models/UserModel.dart';

class RequestListItem extends StatelessWidget {
  final UserModel user;
  final Function onUpdate;
  final BuildContext context;
  final FriendRequestRepository friendRequestRepository =
      FriendRequestRepository();

  RequestListItem({super.key, required this.user, required this.onUpdate, required this.context});

  Future<File?> _loadUserProfileImage(String userId) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('images/${user.uid}.png');

    try {
      String downloadURL = await storageReference.getDownloadURL();
      File imageFile = File(downloadURL);
      return imageFile;
    } catch (e) {
      print('Error loading image.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _loadUserProfileImage(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return RequestListItemView(
            image: NetworkImage(snapshot.data!.path),
            buttonFirstText: "Zaakceptuj",
            buttonSecondText: "Odrzuć",
            onPressedFirst: () {
              acceptRequest(user.uid);
            },
            onPressedSecond: () {
              deleteRequest(user.uid);
            },
            user: user,
          );
        } else {
          return RequestListItemView(
            image: const AssetImage("assets/images/no_image.png"),
            buttonFirstText: "Zaakceptuj",
            buttonSecondText: "Odrzuć",
            onPressedFirst: () {
              acceptRequest(user.uid);
            },
            onPressedSecond: () {
              deleteRequest(user.uid);
            },
            user: user,
          );
        }
      },
    );
  }

  Future<void> acceptRequest(String askerId) async {
    try {
      User currentUser = FirebaseAuth.instance.currentUser!;
      await friendRequestRepository.deleteRequestByAskerId(
          askerId, currentUser.uid);
      await FriendsRepository().addFriend(askerId, currentUser.uid);
      onUpdate();
      createSnackBar("Dodano użytkownia do grona znajomych.", context);
    } catch (error) {
      print('Error adding a user.');
      createSnackBarError("Błąd serwera.", context);
    }
  }

  Future<void> deleteRequest(String askerId) async {
    try {
      User currentUserId = FirebaseAuth.instance.currentUser!;
      await friendRequestRepository.deleteRequestByAskerId(
          askerId, currentUserId.uid);
      onUpdate();
      createSnackBar("Zaproszenie usunięte", context);
    } catch (error) {
      print('Error deleting request.');
      createSnackBarError("Błąd serwera.", context);
    }
  }
}
