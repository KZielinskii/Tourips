import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/signin_screen.dart';
import '../../utils/color_utils.dart';
import '../../widgets/widget.dart';

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
          title: const Text("Potwierdzenie", style: TextStyle(color: Colors.white),),
          content: const Text("Czy napewno zapisać nowy login?",  style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () async {
                await UserRepository().updateUserLogin(
                    user.uid, _loginController.text.toString());
                _toggleEditingLogin();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: const Text(
                "Tak",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                _loginController.text = userModel!.login;
                _toggleEditingLogin();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text(
                "Nie",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],backgroundColor: Colors.black87,
        );
      },
    );
  }

  Future<void> _changePassword() async {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController repeatNewPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Zmiana hasła:"),
            content: Column(
              children: [
                reusableTextField(
                  "Aktualne hasło:",
                  Icons.lock_outline,
                  true,
                  currentPasswordController,
                  true,
                ),
                const SizedBox(height: 16.0),
                reusableTextField(
                  "Nowe hasło:",
                  Icons.lock_outline,
                  true,
                  newPasswordController,
                  true,
                ),
                const SizedBox(height: 16.0),
                reusableTextField(
                  "Powtórz nowe hasło:",
                  Icons.lock_outline,
                  true,
                  repeatNewPasswordController,
                  true,
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Anuluj",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (correctPassword(newPasswordController.text,
                      repeatNewPasswordController.text)) {
                    try {
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: currentPasswordController.text.toString(),
                      );
                      await user.reauthenticateWithCredential(credential);
                      await user.updatePassword(
                          newPasswordController.text.toString());
                      createSnackBar('Hasło zaktualizowane.', context);
                      Navigator.of(context).pop();
                    } catch (error) {
                      createSnackBarError(
                          'Nie udało się zaktualizować hasła!', context);
                    }
                  }
                },
                child: const Text(
                  "Aktualizuj hasło",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Twój profil"),
          backgroundColor: hexStringToColor("0B3963"),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("2F73B1"),
            hexStringToColor("2F73B1"),
            hexStringToColor("0B3963")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.05,
                  MediaQuery.of(context).size.height * 0.1,
                  MediaQuery.of(context).size.width * 0.05,
                  MediaQuery.of(context).size.height * 0.1),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0x55FFFFFF)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _changePassword,
                        child: const Text("Zmień hasło"),
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
          ),
        ));
  }

  bool correctPassword(String password, String passwordRepeat) {
    if (password != passwordRepeat) {
      createSnackBarError("Hasła nie są takie same.", context);
      return false;
    }
    if (password.length < 8) {
      createSnackBarError("Hasło nie może być krótsze niż 8 znaków.", context);
      return false;
    }
    if (!password.contains(RegExp(r'\d'))) {
      createSnackBarError(
          "Hasło musi zawierać co najmniej jedną liczbę.", context);
      return false;
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      createSnackBarError(
          "Hasło musi zawierać co najmniej jeden\nznak specjalny.", context);
      return false;
    }
    return true;
  }
}
