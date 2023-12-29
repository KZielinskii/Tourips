import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourpis/screens/signin_screen.dart';
import '../repository/user_repository.dart';
import '../utils/color_utils.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  static Future<String> uploadImage(File imageFile, String userId) async {
    final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
    //todo error
    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  static Future<void> deleteImage(String imageUrl) async {
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {

          final imageUrl = await uploadImage(_image!, user.uid);

          await UserRepository().updateUserProfileImage(user.uid, imageUrl);

        } catch (e) {
          print("Wystąpił błąd podczas przesyłania obrazu do Firebase Storage: $e");
        }
      }
    }
  }

  Future<void> _loadUserProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await UserRepository().getUserByUid(user.uid);
        if (userData != null) {
          setState(() {
            _imageUrl = userData.profileImageUrl;
          });
        }
      } catch (e) {
        print("Wystąpił błąd podczas wczytywania obrazu profilowego: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Twój profil"),
        backgroundColor: hexStringToColor("2F73B1"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("2F73B1"),
              hexStringToColor("2F73B1"),
              hexStringToColor("DCDCDC"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.photo,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_image != null)
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipOval(
                        child: Image.file(
                          _image!,
                          height: 128,
                          width: 128,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0,
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.2,
              ),
              child: ElevatedButton(
                child: const Text("Wyloguj się"),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    print("Signed Out.");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
