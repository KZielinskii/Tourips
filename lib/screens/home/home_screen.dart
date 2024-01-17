import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/screens/home/home_events_page.dart';
import 'package:tourpis/screens/home/home_recommended_page.dart';
import 'package:tourpis/utils/color_utils.dart';

import '../../models/UserModel.dart';
import '../../repository/event_request_repository.dart';
import '../../repository/friend_request_repository.dart';
import '../../repository/friends_repository.dart';
import '../add_event/add_event_screen.dart';
import '../chat/chat_screen.dart';
import '../friends/add_friends/users_screen.dart';
import '../friends/request/requests_screen.dart';
import '../profile/profile_screen.dart';
import '../archive/archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FriendsRepository _friendsRepository = FriendsRepository();

  late List<UserModel> _friendsList = [];
  late User user;

  int _selectedIndex = 0;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
    _loadFriendsList();
  }

  Future<void> _loadFriendsList() async {
    _friendsList = await _friendsRepository.loadFriendsList();
    setState(() {});
  }

  Future<void> _loadUserProfileImage() async {
    setState(() {
      user = FirebaseAuth.instance.currentUser!;
    });

    Reference storageReference =
        FirebaseStorage.instance.ref().child('images/${user.uid}.png');

    try {
      _image = File((await storageReference.getDownloadURL()).toString());

      setState(() {
        _image = _image;
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wydarzenia"),
        backgroundColor: hexStringToColor("0B3963"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawer: Drawer(
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
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UsersScreen()),
                  );
                  _loadFriendsList();
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
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: Icon(Icons.person_add, color: Colors.white),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Dodaj znajomych",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<int>(
                        future:
                            FriendRequestRepository().getRequestCountToUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Container();
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
                    MaterialPageRoute(
                        builder: (context) => const RequestsScreen()),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: Icon(Icons.add_location_alt_outlined,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Dołącz do wydarzeń",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<int>(
                        future:
                            EventRequestRepository().getCountRequestsForUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Container();
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
                    MaterialPageRoute(
                        builder: (context) => const ArchiveScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: hexStringToColor("0B3963"),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Stack(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: Icon(Icons.unarchive,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Archiwum",
                              style:
                              TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (UserModel friend in _friendsList)
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: hexStringToColor("2F73B1"),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: Text(
                    friend.login,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                                receiverLogin: friend.login,
                                receiverId: friend.uid,
                              )),
                    );
                  },
                ),
              ),
          ],
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Szukaj...",
                          contentPadding: EdgeInsets.all(10),
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25.0,
                      child: _getImageWidget(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedIndex == 0
                  ? const HomeEventsPage()
                  : const HomeRecommendedPage(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Wydarzenia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Rekomendowane',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEventScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _getImageWidget() {
    if (_image != null) {
      return ClipOval(
        child: Image.network(
          _image!.path,
          height: 40,
          width: 40,
        ),
      );
    } else {
      return const Icon(
        Icons.person,
        color: Colors.blueGrey,
        size: 40,
      );
    }
  }
}
