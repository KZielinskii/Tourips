import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/signin_screen.dart';
import '../utils/color_utils.dart';
import '../widgets/widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  late User user;
  UserModel? userModel;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatNewPasswordController = TextEditingController();
  bool _isEditingLogin = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userModel = await UserRepository().getUserByUid(user.uid);

    setState(() {
      _emailController.text = user.email ?? "";
      _loginController.text = userModel?.login ?? "";
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    late File imagePath;

    if (pickedFile != null) {
      imagePath = File(pickedFile.path);
    }

    Reference storageReference =
    FirebaseStorage.instance.ref().child('images/${user.uid}.png');

    UploadTask uploadTask = storageReference.putFile(imagePath);
    await uploadTask.whenComplete(() {
      print('Image uploaded');
      _loadUserProfileImage();
    });
  }

  Future<void> _loadUserProfileImage() async {
    setState(() {
      user = FirebaseAuth.instance.currentUser!;
    });

    Reference storageReference =
    FirebaseStorage.instance.ref().child('images/${user.uid}.png');

    try {
      _image = File((await storageReference.getDownloadURL()).toString());
      setState(() {
        _image = _image;
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  void _toggleEditingLogin() {
    setState(() {
      _isEditingLogin = !_isEditingLogin;
    });
  }

  void _saveNewLogin() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy napewno zapisać nowy login?"),
          actions: [
            TextButton(
              onPressed: () async {
                await UserRepository().updateUserLogin(user.uid, _loginController.text.toString());
                _toggleEditingLogin();
                Navigator.of(context).pop();
              },
              child: const Text("Tak"),
            ),
            TextButton(
              onPressed: () async {
                _loginController.text = userModel!.login;
                _toggleEditingLogin();
                Navigator.of(context).pop();
              },
              child: const Text("Nie"),
            ),
          ],
        );
      },
    );
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
                      onTap: _pickImage,
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
                        onTap: _pickImage,
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
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: reusableTextField(
                        "Login:",
                        Icons.person,
                        false,
                        _loginController,
                        _isEditingLogin,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditingLogin ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_isEditingLogin) {
                          _saveNewLogin();
                        } else {
                          _toggleEditingLogin();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color(0x55FFFFFF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
