import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/signin_screen.dart';

import '../utils/color_utils.dart';
import '../widgets/widget.dart';
import 'home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _passwordRepeatTextController =
      TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _loginTextController = TextEditingController();
  final userRepository = UserRepository();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("2F73B1"),
              hexStringToColor("2F73B1"),
              hexStringToColor("0B3963")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.1,
                    MediaQuery.of(context).size.height * 0,
                    MediaQuery.of(context).size.width * 0.1,
                    MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/logo_text.png"),
                    reusableTextField("Wprowadź login", Icons.person_outline,
                        false, _loginTextController, true),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField("Wprowadź email", Icons.person_outline,
                        false, _emailTextController, true),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField("Wprowadź hasło", Icons.lock_outline,
                        true, _passwordTextController, true),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField("Powtórz hasło", Icons.lock_outline, true,
                        _passwordRepeatTextController, true),
                    const SizedBox(
                      height: 30,
                    ),
                    singInButton(context, false, () async {
                      setState(() {
                        isLoading = true;
                      });
                      if (await correctPassword()) {
                        FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: _emailTextController.text,
                                password: _passwordTextController.text)
                            .then((UserCredential userCredential) {
                          String uid = userCredential.user!.uid;
                          userRepository.createUser(_loginTextController.text,
                              _emailTextController.text, uid);

                          print("Created New Account");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        }).onError((error, stackTrace) {
                          setState(() {
                            isLoading = false;
                          });
                          String errorMessage =
                              "Wystąpił błąd podczas tworzenia konta.";
                          if (error is FirebaseAuthException) {
                            errorMessage =
                                error.message ?? "Wystąpił błąd autentykacji.";
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Wystąpił błąd: $errorMessage"),
                          ));
                          print("Error ${error.toString()}");
                        });
                      } else {
                        return;
                      }
                    }),
                    singInOption(),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Row singInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Posiadasz konto? ",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignInScreen()));
          },
          child: const Text(
            "Zaloguj się",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Future<bool> correctPassword() async {
    if (_passwordTextController.text != _passwordRepeatTextController.text) {
      createSnackBarError("Hasła nie są takie same.", context);
      return false;
    }
    if (_passwordTextController.text.length < 8) {
      createSnackBarError("Hasło nie może być krótsze niż 8 znaków", context);
      return false;
    }
    if (!_passwordTextController.text.contains(RegExp(r'\d'))) {
      createSnackBarError(
          "Hasło musi zawierać co najmniej jedną\nliczbę.", context);
      return false;
    }
    if (!_passwordTextController.text
        .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      createSnackBarError(
          "Hasło musi zawierać co najmniej jeden\nznak specjalny.", context);
      return false;
    }
    return true;
  }
}
//todo odświeżanie
