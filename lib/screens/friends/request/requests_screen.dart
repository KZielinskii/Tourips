import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tourpis/models/EventModel.dart';
import 'package:tourpis/repository/event_request_repository.dart';

import '../../../utils/color_utils.dart';
import 'event_request_list_item.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  RequestsView createState() => RequestsView();
}

class RequestsView extends State<RequestsScreen> {
  final EventRequestRepository _eventRequestRepository = EventRequestRepository();
  late List<EventModel> allRequest;
  late StreamController<List<EventModel>> _controller;

  @override
  void initState() {
    super.initState();
    allRequest = [];
    _controller = StreamController<List<EventModel>>.broadcast();
    _loadRequestsList();
  }

  Future<void> _loadRequestsList() async {
    allRequest = await _eventRequestRepository.getRequestsForUser();
    _controller.add(allRequest);
  }

  Future<void> _updateList(int index) async {
    allRequest.removeAt(index);
    _controller.add(allRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zaproszenia do wydarzeń"),
        backgroundColor: hexStringToColor("0B3963"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("2F73B1"),
              hexStringToColor("2F73B1"),
              hexStringToColor("0B3963"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<List<EventModel>>(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<EventModel> data = snapshot.data!;
                    return data.isNotEmpty
                        ? ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: EventRequestListItem(
                            event: data[index],
                            onUpdate: () => _updateList(index),
                            context: context,
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Text("Nie masz jeszcze żadnych zaproszeń."),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
