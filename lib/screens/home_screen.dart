import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Wyloguj się"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
          },
        ),
      )
    );
  }
}
