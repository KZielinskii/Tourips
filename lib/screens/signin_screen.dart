import 'package:flutter/material.dart';
import 'package:tourpis/screens/home_screen.dart';
import 'package:tourpis/screens/signup_screen.dart';
import '../utils/color_utils.dart';
import '../widgets/widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

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
                MediaQuery.of(context).size.height * 0.1,
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.4
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo.png"),
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
                singInButton(context, true, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }),
                singUpOption()
              ],
            ),
          ),
        ),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
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
