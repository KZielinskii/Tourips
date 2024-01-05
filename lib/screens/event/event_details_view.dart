import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourpis/models/EventModel.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/event_request_repository.dart';
import 'package:tourpis/screens/event/user_participant_list_item.dart';
import 'package:tourpis/screens/event/user_request_list_item.dart';
import '../../models/UserModel.dart';
import '../../repository/event_participants_repository.dart';
import '../../repository/user_repository.dart';
import '../../utils/color_utils.dart';
import '../../widgets/widget.dart';
import '../map/display_map_screen.dart';
import 'event_details_screen.dart';

class EventDetailsView extends State<EventDetailsScreen> {
  late final EventModel event;
  bool isOwner = false;
  bool isLoading = true;
  List<UserModel?> participants = [];
  List<UserModel> requests = [];

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    try {
      event = (await EventRepository().getEventById(widget.eventId))!;
      participants = await EventParticipantsRepository()
          .getParticipantsByEventId(widget.eventId);
    } catch (e) {
      print("Error downloading event.");
    } finally {
      checkUserIsOwner();
      setState(() {
        isLoading = false;
      });
    }
  }

  LatLng geoPointToLatLng(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? "Ładowanie..." : event.title),
        backgroundColor: hexStringToColor("0B3963"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("2F73B1"),
          hexStringToColor("2F73B1"),
          hexStringToColor("0B3963")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      16.0,
                      16.0,
                      16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (event.route.isNotEmpty) {
                              List<LatLng> routeLatLng =
                                  event.route.map(geoPointToLatLng).toList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisplayMapScreen(
                                    routePoints: routeLatLng,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Brak punktów do wyświetlenia na mapie.'),
                                ),
                              );
                            }
                          },
                          child: const Card(
                            color: Colors.blue,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'Pokaż trasę na mapie',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.white,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Informacje:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  event.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Start: ${event.startDate.toString().substring(0, 16)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Koniec: ${event.endDate.toString().substring(0, 16)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Uczestnicy: ${participants.length}/${event.capacity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: participants.length,
                                  itemBuilder: (context, index) {
                                    final user = participants[index];
                                    return Padding(
                                      key: ValueKey(user!.uid),
                                      padding: const EdgeInsets.all(8.0),
                                      child: UserParticipantListItem(
                                          user: user,
                                          eventId: widget.eventId,
                                          isOwner: isOwner),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isOwner)
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final user = requests[index];
                              return Padding(
                                key: ValueKey(user.uid),
                                padding: const EdgeInsets.all(8.0),
                                child: UserRequestListItem(
                                  user: user,
                                  eventId: widget.eventId,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        if (isOwner)
                          ElevatedButton(
                            onPressed: () {
                              //todo ekran edytowania
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Edytuj Wydarzenie",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (isOwner)
                          ElevatedButton(
                            onPressed: () {
                              deleteEvent();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Usuń Wydarzenie",
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> checkUserIsOwner() async {
    String? userId = await UserRepository().getCurrentUserId();
    UserModel? user = await UserRepository().getUserByUid(userId!);
    if (event.owner == user!.login) {
      loadEventRequests();
      setState(() {
        isOwner = true;
      });
    }
  }

  Future<void> loadEventRequests() async {
    List<UserModel?> users =
        await EventRequestRepository().getRequestsForEvent(widget.eventId);
    for (UserModel? user in users) {
      requests.add(user!);
    }
    setState(() {
      requests = requests;
    });
  }

  Future<void> deleteEvent() async {
    try {
      bool confirmed = await showDeleteConfirmationDialog(context);

      if (confirmed) {
        await EventRepository().deleteEvent(widget.eventId);
        setState(() {
          Navigator.pop(context);
          createSnackBar("Usunięto wydarzenie.", context);
        });
      }
    } catch (e) {
      setState(() {
        createSnackBarError("Błąd serwera.", context);
      });
    }
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Potwierdzenie",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Czy na pewno chcesz usunąć wydarzenie?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                completer.complete(false);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: const Text(
                "Anuluj",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                completer.complete(true);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text(
                "Usuń",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          backgroundColor: Colors.black87,
        );
      },
    );
    return completer.future;
  }
}
