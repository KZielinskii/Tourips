import 'package:flutter/material.dart';
import 'add_event_friends_view.dart';

class AddEventFriendsListScreen extends StatefulWidget {
  late final List<String> requestList;

  AddEventFriendsListScreen({super.key, required this.requestList});

  @override
  AddEventFriendsListScreenState createState() => AddEventFriendsListScreenState();
}

