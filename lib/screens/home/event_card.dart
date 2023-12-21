import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/EventModel.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          event.title,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          event.description,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}