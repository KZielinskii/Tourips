import 'package:flutter/material.dart';
import 'package:tourpis/screens/friends/add_friends/request_list_item.dart';

import '../../../models/UserModel.dart';

class InvitationsFragment extends StatelessWidget {
  final List<UserModel> usersList;

  const InvitationsFragment({super.key, required this.usersList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RequestListItem(user: usersList[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
