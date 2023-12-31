
import 'package:flutter/material.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/friends/add_friends/invitations_fragment.dart';
import 'package:tourpis/screens/friends/add_friends/search_users_fragmet.dart';
import 'package:tourpis/screens/friends/add_friends/users_screen.dart';

import '../../../models/UserModel.dart';
import '../../../utils/color_utils.dart';

class UsersView extends State<UsersScreen> {
  final UserRepository _userRepository = UserRepository();
  final FriendRequestRepository _friendRequestRepository = FriendRequestRepository();

  List<UserModel> _usersList = [];
  List<UserModel> _requestList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsersList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUsersList() async {
    List<UserModel> allUsers = await _userRepository.getAllUsersExceptFriends();
    List<UserModel> allRequest = await _friendRequestRepository.getAllRequestToUser();
    setState(() {
      _usersList = allUsers;
      _requestList = allRequest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Znajdź znajomych"),
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
          children: [
            Expanded(
              child: _selectedIndex == 0
                  ? SearchUsersFragment(usersList: _usersList)
                  : InvitationsFragment(usersList: _requestList),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Użytkownicy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert_rounded),
            label: 'Zaproszenia',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 5,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        showUnselectedLabels: true,
      ),
    );
  }
}
