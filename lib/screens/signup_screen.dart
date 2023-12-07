import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/screens/signin_screen.dart';

import '../utils/color_utils.dart';
import '../widgets/widget.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _passwordRepeatTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _loginTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("2F73B1"),
              hexStringToColor("2F73B1"),
              hexStringToColor("DCDCDC")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0,
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.2
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo_text.png"),
                reusableTextField("Wprowadź login", Icons.person_outline, false, _loginTextController),
                SizedBox(
                  height: 30,
                ),
                reusableTextField("Wprowadź email", Icons.person_outline, false, _emailTextController),
                SizedBox(
                  height: 30,
                ),
                reusableTextField("Wprowadź hasło", Icons.lock_outline, true, _passwordTextController),
                SizedBox(
                  height: 30,
                ),
                reusableTextField("Powtórz hasło", Icons.lock_outline, true, _passwordRepeatTextController),
                SizedBox(
                  height: 30,
                ),
                singInButton(context, false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }),
                singInOption()
              ],
            ),
          ),
        ),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
          },
          child: const Text(
            "Zaloguj się",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
