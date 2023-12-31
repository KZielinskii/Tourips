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
        ListTile(
          title: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Wyszukaj znajomych...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.lightBlueAccent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              //todo szukanie znajomych
            },
          ),
        ),
        for (UserModel friend in friendsList)
          ListTile(
            title: Text(friend.login),
            onTap: () {
              //todo profil użytkownika
              Navigator.pop(context);
            },
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
      ],
    ),
  );
}
