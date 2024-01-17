import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tourpis/screens/friends/add_friends/list_items/user_list_item.dart';

import '../../../models/UserModel.dart';
import '../../../repository/user_repository.dart';

class SearchUsersFragment extends StatefulWidget {
  const SearchUsersFragment({super.key});

  @override
  _SearchUsersFragmentState createState() => _SearchUsersFragmentState();
}

class _SearchUsersFragmentState extends State<SearchUsersFragment> {
  final UserRepository _userRepository = UserRepository();
  late List<UserModel> allUsers;
  late List<UserModel> filteredUsersList;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    allUsers = [];
    filteredUsersList = [];
    _initializeUsersList();
  }

  Future<void> _initializeUsersList() async {
    try {
      allUsers = await _userRepository.getAllUsersExceptFriends();
      _updateFilteredUsersList("");
    } catch (error) {
      print("Error loading users: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateFilteredUsersList(String query) {
    setState(() {
      filteredUsersList = allUsers
          .where(
            (user) => user.login.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
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
                    onChanged: (query) => _updateFilteredUsersList(query),
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
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredUsersList.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsersList[index];
                    return Padding(
                      key: ValueKey(user.uid),
                      padding: const EdgeInsets.all(8.0),
                      child: UserListItem(user: user),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
