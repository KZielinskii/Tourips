import 'package:flutter/cupertino.dart';

import 'EventDetailsView.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  EventDetailsView createState() => EventDetailsView();
}