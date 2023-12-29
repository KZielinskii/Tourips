import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/models/EventModel.dart';

import 'event_card.dart';

class HomeEventsPage extends StatelessWidget {
  const HomeEventsPage({super.key});

  void goToEventDetails(BuildContext context) {
    //todo
    return;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorState =
    GlobalKey<RefreshIndicatorState>();

    return RefreshIndicator(
      key: refreshIndicatorState,
      onRefresh: () async {
        // todo
      },
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Wystąpił błąd: ${snapshot.error}');
          } else {
            try {
              List<EventModel> events = snapshot.data!.docs.map((
                  DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<
                    String,
                    dynamic>;
                List<GeoPoint> route = data['route'] != null &&
                    data['route'] is List
                    ? (data['route'] as List).cast<GeoPoint>()
                    : [];

                return EventModel(
                  title: data['title'],
                  description: data['description'],
                  owner: data['owner'],
                  startDate: (data['startDate'] as Timestamp).toDate(),
                  endDate: (data['endDate'] as Timestamp).toDate(),
                  capacity: data['capacity'],
                  participants: data['participants'],
                  route: route,
                );
              }).toList();

              return Column(
                children: [
                  if (events.isEmpty)
                    const Center(child: Text('Nie znaleziono wydarzeń'))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) =>
                            GestureDetector(
                              onTap: () => goToEventDetails(context),
                              child: EventCard(event: events.elementAt(index)),
                            ),
                      ),
                    ),
                ],
              );
            } catch (error) {
              return Text('Wystąpił błąd podczas przetwarzania danych: $error');
            }
          }
        },
      ),
    );
  }
}
