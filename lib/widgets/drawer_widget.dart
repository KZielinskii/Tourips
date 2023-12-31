import 'package:flutter/material.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/screens/friends/add_friends/users_screen.dart';
import 'package:tourpis/utils/color_utils.dart';

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
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Dodaj znajomych',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
                //todo profil użytkownika
                Navigator.pop(context);
              },
            ),
          ),
      ],
    ),
  );
}
