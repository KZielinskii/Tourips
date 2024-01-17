import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/EventModel.dart';
import '../../repository/event_repository.dart';
import '../../utils/color_utils.dart';
import '../event/event_details_screen.dart';
import '../home/event_card.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => ArchiveScreenState();
}

class ArchiveScreenState extends State<ArchiveScreen> {
  final EventRepository eventRepository = EventRepository();
  List<EventModel> events = [];

  void goToEventDetails(BuildContext context, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(eventId: eventId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorState =
        GlobalKey<RefreshIndicatorState>();
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
            child: Center(
              child: RefreshIndicator(
                key: refreshIndicatorState,
                onRefresh: () async {
                  List<EventModel> refreshedEvents =
                      await eventRepository.getUserEventsEnded();
              
                  setState(() {
                    events = refreshedEvents;
                  });
                },
                child: FutureBuilder<List<EventModel>>(
                  key: UniqueKey(),
                  future: eventRepository.getUserEventsEnded(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Wystąpił błąd podczas przetwarzania danych: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nie znaleziono wydarzeń'));
                    } else {
                      events = snapshot.data!;
              
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return GestureDetector(
                            onTap: () => goToEventDetails(context, event.id!),
                            child: EventCard(event: event),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            )));
  }
}
