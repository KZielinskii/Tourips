import 'package:flutter/material.dart';

import '../../models/EventModel.dart';
import '../../repository/event_repository.dart';
import '../event/event_details_screen.dart';
import 'event_card.dart';

class HomeEventsPage extends StatefulWidget {
  const HomeEventsPage({super.key});

  @override
  _HomeEventsPageState createState() => _HomeEventsPageState();
}

class _HomeEventsPageState extends State<HomeEventsPage> {
  final EventRepository eventRepository = EventRepository();
  List<EventModel> events = [];
  List<EventModel> filteredEvents = [];

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

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        filteredEvents = events
                            .where((event) =>
                            event.title.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Szukaj...",
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            key: refreshIndicatorState,
            onRefresh: () async {
              List<EventModel> refreshedEvents = await eventRepository.getUserEvents();

              setState(() {
                events = refreshedEvents;
              });
            },
            child: FutureBuilder<List<EventModel>>(
              key: UniqueKey(),
              future: eventRepository.getUserEvents(),
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
                  List<EventModel> displayedEvents =
                  filteredEvents.isNotEmpty ? filteredEvents : events;

                  return ListView.builder(
                    itemCount: displayedEvents.length,
                    itemBuilder: (context, index) {
                      final event = displayedEvents[index];
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
        ),
      ],
    );
  }
}
