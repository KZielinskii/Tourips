import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/color_utils.dart';
import 'EventDetailsScreen.dart';

class EventDetailsView extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  void _loadEventDetails() {
    //todo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Event"),
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
                  MediaQuery.of(context).size.height * 0.4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
