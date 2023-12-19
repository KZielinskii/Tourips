import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/models/EventModel.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text(event.description),
    );
  }
}

class HomeEventsPage extends StatelessWidget {
  const HomeEventsPage({Key? key}) : super(key: key);

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
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Wystąpił błąd: ${snapshot.error}');
          } else {
            List<EventModel> events = snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return EventModel(
                title: data['title'],
                description: data['description'],
                owner: data['owner'],
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
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => goToEventDetails(context),
                        child: EventCard(event: events.elementAt(index)),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
