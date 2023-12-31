import 'package:flutter/cupertino.dart';
import 'package:tourpis/screens/friends/add_friends/users/user_list_item.dart';

import '../../../models/UserModel.dart';

class SearchUsersFragment extends StatelessWidget {
  final List<UserModel> usersList;

  const SearchUsersFragment({super.key, required this.usersList});

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
                child: UserListItem(user: usersList[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}