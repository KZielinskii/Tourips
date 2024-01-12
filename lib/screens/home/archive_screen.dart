import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/color_utils.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => ArchiveScreenState();
}

class ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archiwum"),
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
              hexStringToColor("0B3963"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}