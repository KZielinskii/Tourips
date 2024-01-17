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
      color: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Text(
                  "\nMiejsca: ${event.participants}/${event.capacity}",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Początek wydarzenia:\n${event.startDate.day}/${event.startDate.month}/${event.startDate.year} ${event.startDate.hour}:${event.startDate.minute}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled ? handleJoinRequest : null,
                      child: const Text(
                        "Poproś o dołączenie",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
