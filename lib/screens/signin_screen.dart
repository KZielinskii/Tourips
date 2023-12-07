import 'package:flutter/material.dart';
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
                MediaQuery.of(context).size.height * 0.8
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
