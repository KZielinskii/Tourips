import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/event_request_repository.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/screens/event/user_request_list_item_view.dart';
import 'package:tourpis/widgets/widget.dart';

import '../../../../models/UserModel.dart';

class UserRequestListItem extends StatefulWidget {
  final UserModel user;
  final String eventId;

  const UserRequestListItem({super.key, required this.user, required this.eventId});

  @override
  _UserRequestListItemState createState() => _UserRequestListItemState();
}

class _UserRequestListItemState extends State<UserRequestListItem> {

  final FriendRequestRepository friendRequestRepository = FriendRequestRepository();
  bool isButtonEnabled = true;

  Future<File?> _loadUserProfileImage(String userId) async {
    Reference storageReference =
    FirebaseStorage.instance.ref().child('images/${widget.user.uid}.png');

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
      future: _loadUserProfileImage(widget.user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return UserRequestListItemView(
            image: NetworkImage(snapshot.data!.path),
            buttonText: "Zaakceptuj",
            onPressed: () {
              acceptRequest(widget.user.uid);
            },
            isButtonEnabled: isButtonEnabled,
            user: widget.user,
          );
        } else {
          return UserRequestListItemView(
            image: const AssetImage("assets/images/no_image.png"),
            buttonText: "Zaakceptuj",
            onPressed: () {
              acceptRequest(widget.user.uid);
            },
            isButtonEnabled: isButtonEnabled,
            user: widget.user,
          );
        }
      },
    );
  }

  Future<void> acceptRequest(String uid) async {
    try {
      if(isButtonEnabled) {
        await EventRequestRepository().acceptRequest(widget.eventId, uid);
        setState(() {
          isButtonEnabled = false;
          createSnackBar("Pomyślnie dodano do wydarzenia.", context);
        });
      }

    } catch (e) {
      setState(() {
        createSnackBarError("Błąd serwera.", context);
      });
    }
  }
}