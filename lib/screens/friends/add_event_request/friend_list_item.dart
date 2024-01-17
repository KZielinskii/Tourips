import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/friend_request_repository.dart';

import '../../../../models/UserModel.dart';
import '../add_friends/list_items/user_list_item_view.dart';

class FriendListItem extends StatefulWidget {
  final UserModel user;
  final List<String> requestList;
  final Function(List<String>) onRequestListChanged;

  const FriendListItem({super.key, required this.user, required this.requestList, required this.onRequestListChanged});

  @override
  _FriendListItemState createState() => _FriendListItemState();
}

class _FriendListItemState extends State<FriendListItem> {
  late final UserModel user = widget.user;
  final FriendRequestRepository friendRequestRepository = FriendRequestRepository();
  bool isButtonEnabled = true;

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
            buttonText: widget.requestList.contains(user.uid)
                ? "Anuluj zaproszenie"
                : "Wyślij zaproszenie",
            onPressed: () {
              _inviteFriend(user.uid);
            },
            isButtonEnabled: isButtonEnabled,
            user: user,
          );
        } else {
          return UserListItemView(
            image: const AssetImage("assets/images/no_image.png"),
            buttonText: widget.requestList.contains(user.uid)
                ? "Anuluj zaproszenie"
                : "Wyślij zaproszenie",
            onPressed: () {
              _inviteFriend(user.uid);
            },
            isButtonEnabled: isButtonEnabled,
            user: user,
          );
        }
      },
    );
  }

  void _inviteFriend(String uid) {
    if (widget.requestList.contains(uid)) {
      widget.requestList.remove(uid);
    } else {
      widget.requestList.add(uid);
    }
    setState(() {});
  }
}
