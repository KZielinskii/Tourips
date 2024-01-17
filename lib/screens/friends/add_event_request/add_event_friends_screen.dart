import 'package:flutter/material.dart';

import '../../../models/FriendsModel.dart';
import '../../../models/UserModel.dart';
import '../../../repository/friends_repository.dart';
import '../../../repository/user_repository.dart';
import '../../../utils/color_utils.dart';
import 'friend_list_item.dart';

class AddEventFriendsListScreen extends StatefulWidget {
  final List<String> requestList;
  final Function(List<String>) onRequestListChanged;

  const AddEventFriendsListScreen({
    super.key,
    required this.requestList,
    required this.onRequestListChanged,
  });

  @override
  AddEventFriendsListScreenState createState() => AddEventFriendsListScreenState();
}

class AddEventFriendsListScreenState extends State<AddEventFriendsListScreen> {
  final FriendsRepository _friendsRepository = FriendsRepository();
  late List<UserModel> _friendsList = [];
  List<String> _requestList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendsList();
  }

  Future<void> _loadFriendsList() async {
    FriendsModel? friendsModel = await _friendsRepository.getFriendsList();

    if (friendsModel != null) {
      List<UserModel> friendsList = [];

      for (String? friendId in friendsModel.friends) {
        if (friendId != null) {
          UserModel? friend = await UserRepository().getUserByUid(friendId);
          if (friend != null) {
            friendsList.add(friend);
          }
        }
      }

      setState(() {
        _friendsList = friendsList;
        isLoading = false;
      });
    }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _friendsList.length,
                itemBuilder: (context, index) {
                  final user = _friendsList[index];
                  return Padding(
                    key: ValueKey(user.uid),
                    padding: const EdgeInsets.all(8.0),
                    child: FriendListItem(
                      user: user,
                      requestList: _requestList,
                      onRequestListChanged: (List<String> updatedList) {
                        setState(() {
                          _requestList = updatedList;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onRequestListChanged(_requestList);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
