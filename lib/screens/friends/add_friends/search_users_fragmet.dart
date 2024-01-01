import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/screens/friends/add_friends/users/user_list_item.dart';

import '../../../models/UserModel.dart';

class SearchUsersFragment extends StatefulWidget {
  final List<UserModel> usersList;

  const SearchUsersFragment({super.key, required this.usersList});

  @override
  _SearchUsersFragmentState createState() => _SearchUsersFragmentState();
}

class _SearchUsersFragmentState extends State<SearchUsersFragment> {
  late List<UserModel>? filteredUsersList;
  late Timer timer;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filteredUsersList = widget.usersList;
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

  void filterUsersList(String query) {
    setState(() {
      isLoading = true;
      filteredUsersList = widget.usersList
          .where(
              (user) => user.login.toLowerCase().contains(query.toLowerCase()))
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    onChanged: filterUsersList,
                    decoration: const InputDecoration(
                      hintText: "Szukaj...",
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: filteredUsersList?.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: UserListItem(user: filteredUsersList![index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
