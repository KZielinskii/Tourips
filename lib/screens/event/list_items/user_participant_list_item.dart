import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/event_participants_repository.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/screens/event/list_items/user_participant_list_item_view.dart';
import 'package:tourpis/widgets/widget.dart';

import '../../../../../models/UserModel.dart';

class UserParticipantListItem extends StatefulWidget {
  final UserModel user;
  final String eventId;
  final bool isOwner;

  const UserParticipantListItem({super.key, required this.user, required this.eventId, required this.isOwner});

  @override
  _UserParticipantListItemState createState() => _UserParticipantListItemState();
}

class _UserParticipantListItemState extends State<UserParticipantListItem> {

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
          return UserParticipantListItemView(
            image: NetworkImage(snapshot.data!.path),
            buttonText: "Usuń",
            onPressed: () {
              if (widget.isOwner) {
                deleteFromEvent(widget.user.uid);
              }
            },
            isButtonEnabled: isButtonEnabled && widget.isOwner,
            user: widget.user,
          );
        } else {
          return UserParticipantListItemView(
            image: const AssetImage("assets/images/no_image.png"),
            buttonText: "Usuń",
            onPressed: () {
              if (widget.isOwner) {
                deleteFromEvent(widget.user.uid);
              }
            },
            isButtonEnabled: isButtonEnabled && widget.isOwner,
            user: widget.user,
          );
        }
      },
    );
  }

  Future<void> deleteFromEvent(String uid) async {
    try {
      if (isButtonEnabled) {
        bool confirmed = await showDeleteConfirmationDialog(context);

        if (confirmed) {
          await EventParticipantsRepository().removeUserFromEvent(uid, widget.eventId);
          await EventRepository().decrementParticipantsCount(widget.eventId);
          setState(() {
            isButtonEnabled = false;
            createSnackBar("Usunięto użytkownika z wydarzenia.", context);
          });
        }
      }
    } catch (e) {
      setState(() {
        createSnackBarError("Błąd serwera.", context);
      });
    }
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Potwierdzenie",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Czy na pewno chcesz usunąć użytkownika z wydarzenia?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                completer.complete(false);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: const Text(
                "Anuluj",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                completer.complete(true);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text(
                "Usuń",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          backgroundColor: Colors.black87,
        );
      },
    );
    return completer.future;
  }

}