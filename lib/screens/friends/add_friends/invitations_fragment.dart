import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tourpis/screens/friends/add_friends/list_items/request_list_item.dart';

import '../../../models/UserModel.dart';
import '../../../repository/friend_request_repository.dart';

class InvitationsFragment extends StatefulWidget {

  const InvitationsFragment({super.key});

  @override
  _InvitationsFragmentState createState() => _InvitationsFragmentState();
}

class _InvitationsFragmentState extends State<InvitationsFragment> {
  final FriendRequestRepository _friendRequestRepository = FriendRequestRepository();
  late List<UserModel> allRequest;
  late StreamController<List<UserModel>> _controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    allRequest = [];
    _controller = StreamController<List<UserModel>>.broadcast();
    _loadUsersList();
  }

  Future<void> _loadUsersList() async {
    allRequest = await _friendRequestRepository.getAllRequestToUser();
    _controller.add(allRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<UserModel> data = snapshot.data!;
                return data.isNotEmpty
                    ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RequestListItem(
                        user: data[index],
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
    );
  }

  Future<void> _updateList(int index) async {
    allRequest.removeAt(index);
    _controller.add(allRequest);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
