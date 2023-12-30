
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/friends_repository.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/friends/user_list_item.dart';

import '../../../models/UserModel.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Użytkownicy, których możesz znać"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _usersList.length,
              itemBuilder: (context, index) {
                return UserListItem(user: _usersList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}


