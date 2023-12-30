import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/friends/add_friends/user_list_item.dart';
import 'package:tourpis/screens/friends/add_friends/users_screen.dart';

import '../../../models/UserModel.dart';

class UsersScreenState extends State<UsersScreen> {
  final UserRepository _userRepository = UserRepository();

  List<UserModel> _usersList = [];

  @override
  void initState() {
    super.initState();
    _loadUsersList();
  }

  Future<void> _loadUsersList() async {
    List<UserModel> allUsers = await _userRepository.getAllUsersExceptFriends();
    setState(() {
      _usersList = allUsers;
    });
    for(var user in allUsers) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodaj znajomych:", style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _usersList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UserListItem(user: _usersList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
