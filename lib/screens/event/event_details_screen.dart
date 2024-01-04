import 'package:flutter/cupertino.dart';

import 'event_details_view.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  EventDetailsView createState() => EventDetailsView();
}