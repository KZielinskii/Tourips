
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourpis/models/EventModel.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/event_request_repository.dart';
import 'package:tourpis/screens/chat/chat_screen.dart';
import 'package:tourpis/screens/event/list_items/user_participant_list_item.dart';
import 'package:tourpis/screens/event/list_items/user_request_list_item.dart';
import '../../models/UserModel.dart';
import '../../repository/event_participants_repository.dart';
import '../../repository/user_repository.dart';
import '../../utils/color_utils.dart';
import '../../widgets/widget.dart';
import '../edit_event/edit_event_screen.dart';
import '../map/display_map_screen.dart';
import '../payment/payment_home_screen.dart';
import 'package:http/http.dart' as http;


class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  EventDetailsView createState() => EventDetailsView();
}

class EventDetailsView extends State<EventDetailsScreen> {
  late final EventModel event;
  late List<LatLng> routeLatLng;
  List<String> pointsInfo = [];
  bool isOwner = false;
  bool isLoading = true;
  bool isOnEvent = false;
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
      routeLatLng = event.route.map(geoPointToLatLng).toList();
      for(var location in routeLatLng) {
        String attractionInfo = await getNearestAttractionInfo(location);
        pointsInfo.add(attractionInfo);
      }

    } catch (e) {
      print("Error downloading event.");
    } finally {
      checkUserIsOwner();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getNearestAttractionInfo(LatLng location) async {
    const String apiKey = 'AIzaSyAR_51lpB8C9jjvZrrs0P-ASYrWhJaB5vk';

    const String baseUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    final String locationString =
        '${location.latitude},${location.longitude}';
    const String radius = '1000';

    final String url =
        '$baseUrl?location=$locationString&radius=$radius&type=tourist_attraction&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('results') && data['results'].isNotEmpty) {
        return data['results'][0]['name'];
      } else {
        return 'Brak informacji o atrakcjach w pobliżu';
      }
    } else {
      throw Exception('Failed to load nearby attractions');
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          :  Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("2F73B1"),
              hexStringToColor("2F73B1"),
              hexStringToColor("0B3963")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
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
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            receiverLogin:
                                            participants[index]!
                                                .login,
                                            receiverId:
                                            participants[index]!.uid),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    key: ValueKey(user!.uid),
                                    padding: const EdgeInsets.all(8.0),
                                    child: UserParticipantListItem(
                                        user: user,
                                        eventId: widget.eventId,
                                        isOwner: isOwner),
                                  ));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isOnEvent)InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentHomeScreen(eventId: widget.eventId,),
                              ),
                            );
                          });
                        },
                        child: Column(
                          children: [
                            iconButton(Icons.monetization_on_outlined, false),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Rozliczanie',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      InkWell(
                        onTap: () {
                          if (event.route.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayMapScreen(
                                  routePoints: routeLatLng, pointsInfo: pointsInfo,
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
                        child: Column(
                          children: [
                            iconButton(Icons.map_sharp, false),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Mapa',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isOwner)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final user = requests[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    receiverLogin: requests[index].login,
                                    receiverId: requests[index].uid),
                              ),
                            );
                          },
                          child: Padding(
                            key: ValueKey(user.uid),
                            padding: const EdgeInsets.all(8.0),
                            child: UserRequestListItem(
                              user: user,
                              eventId: widget.eventId,
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  if (isOwner)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditEventScreen(
                                    eventId: widget.eventId)))
                            .then((value) {});
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
    if (event.owner == userId) {
      loadEventRequests();
      setState(() {
        isOwner = true;
      });
    }
    for (var user in participants) {
      if(user?.uid == userId) {
        setState(() {
          isOnEvent = true;
        });
      }
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
