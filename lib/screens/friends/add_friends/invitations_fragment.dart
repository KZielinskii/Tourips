import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tourpis/screens/friends/add_friends/requests/request_list_item.dart';

import '../../../models/UserModel.dart';

class InvitationsFragment extends StatefulWidget {
  final List<UserModel> usersList;

  const InvitationsFragment({super.key, required this.usersList});

  @override
  _InvitationsFragmentState createState() => _InvitationsFragmentState();
}

class _InvitationsFragmentState extends State<InvitationsFragment> {
  late List<UserModel>? filteredUsersList;
  late Timer timer;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filteredUsersList = widget.usersList;
    if(widget.usersList.isEmpty){
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (filteredUsersList != widget.usersList) {
          setState(() {
            filteredUsersList = widget.usersList;
            isLoading = false;
            timer.cancel();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: filteredUsersList!.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredUsersList?.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RequestListItem(
                        user: filteredUsersList![index],
                        onUpdate: () => _updateList(index),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text("Nie masz jeszcze żadnych zaproszeń."),
                ),
        ),
      ],
    );
  }

  Future<void> _updateList(int index) async {
    filteredUsersList?.removeAt(index);
    setState(() {});
  }
}
