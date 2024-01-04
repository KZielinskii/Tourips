import 'package:flutter/material.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/event_request_repository.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/widgets/widget.dart';

import '../../../models/EventModel.dart';
import '../../event/event_details_screen.dart';

class EventRequestListItem extends StatelessWidget {
  final EventModel event;
  final Function onUpdate;
  final BuildContext context;
  final EventRequestRepository _eventRequestRepository =
      EventRequestRepository();

  EventRequestListItem(
      {super.key,
      required this.event,
      required this.onUpdate,
      required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateToEventDetailsScreen(event.id!);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.white60,
              Colors.white70,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Organizator: ${event.owner}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Start: ${event.startDate.toString().substring(0, 16)}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Koniec: ${event.endDate.toString().substring(0, 16)}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => checkAndAcceptRequest(event.id!),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Dołącz"),
                  ),
                  ElevatedButton(
                    onPressed: () => deleteRequest(event.id!),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Usuń"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToEventDetailsScreen(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailsScreen(eventId: eventId)),
    );
  }

  Future<void> checkAndAcceptRequest(String eventId) async {
    try {
      if (await updateAndCheckRequest(eventId)) {
        acceptRequest(eventId);
      } else {
        createSnackBarError(
            "Wydarzenie osiągneło już maksymalną\nliczbę osób.", context);
      }
    } catch (e) {
      print("Error server request.");
    }
  }

  Future<bool> updateAndCheckRequest(String eventId) async {
    EventModel? event = await _eventRequestRepository.getEventById(eventId);

    return event!.capacity > event.participants;
  }

  Future<void> acceptRequest(String eventId) async {
    try {
      String? userId = await UserRepository().getCurrentUserId();
      await _eventRequestRepository.acceptRequest(eventId, userId!);
      onUpdate();
      createSnackBar("Dołączyłeś do wydarzenia.", context);
    } catch (e) {
      print("Error accepting request.");
    }
  }

  Future<void> deleteRequest(String eventId) async {
    try {
      String? userId = await UserRepository().getCurrentUserId();
      await _eventRequestRepository.deleteRequest(eventId, userId!);
      onUpdate();
      createSnackBar("Usunięto zaproszenie.", context);
    } catch (e) {
      print("Error deleting request.");
    }
  }
}
