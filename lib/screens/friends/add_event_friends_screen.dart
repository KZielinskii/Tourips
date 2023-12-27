import 'package:flutter/material.dart';
import '../../models/FriendsModel.dart';
import '../../models/UserModel.dart';
import '../../repository/friends_repository.dart';
import '../../repository/user_repository.dart';

class AddEventFriendsListScreen extends StatefulWidget {
  @override
  _AddEventFriendsListScreenState createState() => _AddEventFriendsListScreenState();
}

class _AddEventFriendsListScreenState extends State<AddEventFriendsListScreen> {
  final FriendsRepository _friendsRepository = FriendsRepository();
  late List<UserModel> _friendsList = [];

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista znajomych'),
      ),
      body: _friendsList.isEmpty
          ? const Center(
        child: Text('Brak znajomych'),
      )
          : ListView.builder(
        itemCount: _friendsList.length,
        itemBuilder: (context, index) {
          UserModel friend = _friendsList[index];
          return ListTile(
            title: Text(friend.login),
            trailing: IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () => _inviteFriend(friend.uid),
            ),
          );
        },
      ),
    );
  }

  void _inviteFriend(String uid) {
  }
}
