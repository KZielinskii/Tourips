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
  List<EventModel> filteredEvents = [];
  List<EventModel> requestsForUser = [];
  Set<String> disabledJoinButtons = {};

  @override
  void initState() {
    super.initState();
    loadRequestsForUser();
  }

  Future<void> loadRequestsForUser() async {
    try {
      List<EventModel> requests = await EventRequestRepository().getAllRequestsForAndFromUser();
      setState(() {
        requestsForUser = requests;
      });
    } catch (e) {
      print('Błąd podczas pobierania zapytań: $e');
    }
  }

  bool isRequestSent(String eventId) {
    return requestsForUser.any((request) => request.id == eventId);
  }


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
              List<EventModel> refreshedEvents =
              await eventRepository.getOtherEvents();

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
                  List<EventModel> displayedEvents =
                  filteredEvents.isNotEmpty ? filteredEvents : events;

                  return ListView.builder(
                    itemCount: displayedEvents.length,
                    itemBuilder: (context, index) {
                      final event = displayedEvents[index];
                      return GestureDetector(
                        onTap: () => goToEventDetails(context, event.id!),
                        child: EventCardWithButton(
                          event: event,
                          handleJoinRequest: () => handleJoinRequest(event),
                          isButtonEnabled: !disabledJoinButtons.contains(event.id) &&
                              !isRequestSent(event.id!),
                        ),
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
