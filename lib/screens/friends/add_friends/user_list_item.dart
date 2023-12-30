import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/screens/friends/add_friends/list_item_view.dart';

import '../../../models/UserModel.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;

  const UserListItem({super.key, required this.user});

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
          return ListItemView(
            image: NetworkImage(snapshot.data!.path),
            buttonText: "Dodaj znajomego",
            onPressed: () {
              //todo Dodaj logikę dodawania znajomego
            }, user: user,
          );
        } else {
          return ListItemView(
            image: const AssetImage("assets/images/no_image.png"),
            buttonText: "Dodaj znajomego",
            onPressed: () {
              //todo Dodaj logikę dodawania znajomego
            },
            user: user,
          );
        }
      },
    );
  }
}