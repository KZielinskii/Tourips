import 'package:flutter/material.dart';

import 'add_event_friends_view.dart';

class AddEventFriendsListScreen extends StatefulWidget {
  final List<String> requestList;
  final Function(List<String>) onRequestListChanged;

  const AddEventFriendsListScreen({
    super.key,
    required this.requestList,
    required this.onRequestListChanged,
  });

  @override
  AddEventFriendsListScreenState createState() => AddEventFriendsListScreenState();
}
