import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/repository/friends_repository.dart';
import 'package:tourpis/screens/friends/add_friends/requests/request_list_item_view.dart';

import '../../../../models/UserModel.dart';

class RequestListItem extends StatelessWidget {
  final UserModel user;
  final FriendRequestRepository friendRequestRepository = FriendRequestRepository();

  RequestListItem({super.key, required this.user});

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
            }, user: user,
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
    User currentUser = FirebaseAuth.instance.currentUser!;
    await friendRequestRepository.deleteRequestByAskerId(askerId, currentUser.uid);
    await FriendsRepository().addFriend(askerId, currentUser.uid);
  }

  Future<void> deleteRequest(String askerId) async {
    User currentUserId = FirebaseAuth.instance.currentUser!;
    await friendRequestRepository.deleteRequestByAskerId(askerId, currentUserId.uid);
  }
}