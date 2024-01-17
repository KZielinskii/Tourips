import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/screens/signup_screen.dart';
import '../utils/color_utils.dart';
import '../widgets/widget.dart';
import 'home/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  MediaQuery.of(context).size.width * 0.1,
                  MediaQuery.of(context).size.height * 0.1,
                  MediaQuery.of(context).size.width * 0.1,
                  MediaQuery.of(context).size.height * 0.1,
                ),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/logo.png"),
                    const SizedBox(height: 30),
                    reusableTextField(
                      "Wprowadź email",
                      Icons.person_outline,
                      false,
                      _emailTextController,
                      true,
                    ),
                    const SizedBox(height: 30),
                    reusableTextField(
                      "Wprowadź hasło",
                      Icons.lock_outline,
                      true,
                      _passwordTextController,
                      true,
                    ),
                    const SizedBox(height: 30),
                    singInButton(context, true, () {
                      setState(() {
                        isLoading = true;
                      });
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text,
                      )
                          .then((value) {
                        print("Sign In");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }).onError((error, stackTrace) {
                        setState(() {
                          isLoading = false;
                        });
                        createSnackBarError(
                          "Nieprawidłowy login lub hasło",
                          context,
                        );
                        print("Error ${error.toString()}");
                      });
                    }),
                    singUpOption(),
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

  Row singUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Nie posiadasz konta? ",
        style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "Zarejestruj się",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}