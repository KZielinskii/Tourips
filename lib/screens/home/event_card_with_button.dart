import 'package:flutter/material.dart';

import '../../models/EventModel.dart';

class EventCardWithButton extends StatelessWidget {
  final EventModel event;
  final Function() handleJoinRequest;
  final bool isButtonEnabled;

  const EventCardWithButton(
      {super.key,
      required this.event,
      required this.handleJoinRequest,
      required this.isButtonEnabled});

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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? handleJoinRequest : null,
                child: const Text("Poproś o dołączenie"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
