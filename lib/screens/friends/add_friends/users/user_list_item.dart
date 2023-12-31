import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/screens/friends/add_friends/users/user_list_item_view.dart';

import '../../../../models/UserModel.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final FriendRequestRepository friendRequestRepository = FriendRequestRepository();

  UserListItem({super.key, required this.user});

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
          return UserListItemView(
            image: NetworkImage(snapshot.data!.path),
            buttonText: "Dodaj znajomego",
            onPressed: () {
              sendRequest(user.uid);
            }, user: user,
          );
        } else {
          return UserListItemView(
            image: const AssetImage("assets/images/no_image.png"),
            buttonText: "Dodaj znajomego",
            onPressed: () {
              sendRequest(user.uid);
            },
            user: user,
          );
        }
      },
    );
  }

  Future<void> sendRequest(String uid) async {
    User asker = FirebaseAuth.instance.currentUser!;
    await friendRequestRepository.createRequest(asker.uid, uid);
  }
}