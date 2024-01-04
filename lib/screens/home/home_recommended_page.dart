import 'package:flutter/material.dart';
import 'package:tourpis/models/EventModel.dart';

import '../../repository/event_repository.dart';
import '../event/event_details_screen.dart';
import 'event_card.dart';

class HomeRecommendedPage extends StatefulWidget {
  const HomeRecommendedPage({super.key});

  @override
  _HomeRecommendedPageState createState() => _HomeRecommendedPageState();
}

class _HomeRecommendedPageState extends State<HomeRecommendedPage> {
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

    return RefreshIndicator(
      key: refreshIndicatorState,
      onRefresh: () async {
        List<EventModel> refreshedEvents = await eventRepository.getOtherEvents();

        setState(() {
          events = refreshedEvents;
        });
      },
      child: FutureBuilder<List<EventModel>>(
        key: UniqueKey(),
        future: eventRepository.getOtherEvents(),
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
    );
  }
}
