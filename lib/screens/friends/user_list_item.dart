import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/UserModel.dart';

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
      print('Error loading image: $e');
      return File("assets/images/logo.png");
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _loadUserProfileImage(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return RoundedImageWithButton(
            image: FileImage(snapshot.data!),
            buttonText: "Dodaj znajomego",
            onPressed: () {
              //todo Dodaj logikę dodawania znajomego
            }, user: user,
          );
        } else {
          // Tutaj można umieścić wstępną grafikę, jeśli zdjęcie nie zostało jeszcze załadowane
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class RoundedImageWithButton extends StatelessWidget {
  final ImageProvider image;
  final String buttonText;
  final VoidCallback onPressed;
  final UserModel user;

  const RoundedImageWithButton({
    super.key,
    required this.image,
    required this.buttonText,
    required this.onPressed,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: image,
            ),
            const SizedBox(width: 16),
            Text(user.login),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.person_add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}