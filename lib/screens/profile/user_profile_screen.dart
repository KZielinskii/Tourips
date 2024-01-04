import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/repository/user_repository.dart';
import '../../utils/color_utils.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen(this.userId, {super.key});

  final String userId;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _image;
  UserModel? userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userModel = await UserRepository().getUserByUid(widget.userId);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadUserProfileImage() async {
    Reference storageReference =
    FirebaseStorage.instance.ref().child('images/${widget.userId}.png');

    try {
      _image = File((await storageReference.getDownloadURL()).toString());
      setState(() {
        _image = _image;
      });
    } catch (e) {
      print('No image.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? "Ładowanie..." : userModel!.login),
        backgroundColor: hexStringToColor("0B3963"),
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
              hexStringToColor("0B3963")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).size.height * 0.1,
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).size.height * 0.5,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: _image == null
                                ? const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.blueGrey,
                                size: 128,
                              ),
                            )
                                : null,
                          ),
                        ),
                        if (_image != null)
                          GestureDetector(
                            child: ClipOval(
                              child: Image.network(
                                _image!.path,
                                height: 128,
                                width: 128,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildUserInformationCard(
                      "Login: ${isLoading ? 'Ładowanie...' : userModel!.login}",
                    ),
                    const SizedBox(height: 8),
                    _buildUserInformationCard(
                      "Email: ${isLoading ? 'Ładowanie...' : userModel!.email}",
                    ),
                    // Add more user information fields as needed
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInformationCard(String information) {
    return Card(
      color: Colors.white,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          information,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
