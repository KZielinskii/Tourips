import 'package:flutter/material.dart';
import 'package:tourpis/models/EventModel.dart';
import 'package:tourpis/screens/home/event_card_with_button.dart';

import '../../repository/event_repository.dart';
import '../../repository/event_request_repository.dart';
import '../../repository/user_repository.dart';
import '../../widgets/widget.dart';
import '../event/event_details_screen.dart';

class HomeRecommendedPage extends StatefulWidget {
  const HomeRecommendedPage({super.key});

  @override
  _HomeRecommendedPageState createState() => _HomeRecommendedPageState();
}

class _HomeRecommendedPageState extends State<HomeRecommendedPage> {
  final EventRepository eventRepository = EventRepository();
  List<EventModel> events = [];
  Set<String> disabledJoinButtons = {};

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
                  child: EventCardWithButton(event: event, handleJoinRequest: () => handleJoinRequest(event),
                    isButtonEnabled: !disabledJoinButtons.contains(event.id), ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> handleJoinRequest(EventModel event) async {
    try {
      if (disabledJoinButtons.contains(event.id)) {
        return;
      }

      String? userId = await UserRepository().getCurrentUserId();
      await EventRequestRepository().createRequest(event.id.toString(), userId!, false);
      setState(() {
        disabledJoinButtons.add(event.id!);
      });
      createSnackBar("Wysłano prośbę o dołączenie do wydarzenia.", context);
    } catch (e) {
      createSnackBarError("Błąd prośby o dołączenie.", context);
    }
  }
}
