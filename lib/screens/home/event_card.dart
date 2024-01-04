import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/EventModel.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          event.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          event.description,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}