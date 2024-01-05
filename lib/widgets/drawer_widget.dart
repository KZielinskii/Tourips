
import 'package:flutter/material.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/repository/event_request_repository.dart';
import 'package:tourpis/repository/friend_request_repository.dart';
import 'package:tourpis/screens/chat/chat_screen.dart';
import 'package:tourpis/screens/friends/add_friends/users_screen.dart';
import 'package:tourpis/utils/color_utils.dart';

import '../screens/friends/request/requests_screen.dart';

Widget buildDrawer(BuildContext context, List<UserModel> friendsList) {
  return Drawer(
    backgroundColor: Colors.white,
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: hexStringToColor("2F73B1"),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 8),
                Text(
                  'Lista znajomych',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: hexStringToColor("0B3963"),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Icon(Icons.person_add, color: Colors.white),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          "Dodaj znajomych",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<int>(
                    future: FriendRequestRepository().getRequestCountToUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return (snapshot.data ?? 0) > 0
                            ? Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              snapshot.data.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ) : Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestsScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: hexStringToColor("0B3963"),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Icon(Icons.add_location_alt_outlined, color: Colors.white),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          "Dołącz do wydarzeń",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<int>(
                    future: EventRequestRepository().getCountRequestsForUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return (snapshot.data ?? 0) > 0
                            ?  Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              snapshot.data.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ): Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        for (UserModel friend in friendsList)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: hexStringToColor("2F73B1"),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: Text(friend.login, style: const TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(receiverLogin: friend.login, receiverId: friend.uid,)),
                );
              },
            ),
          ),
      ],
    ),
  );
}