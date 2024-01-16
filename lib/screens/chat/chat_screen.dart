import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourpis/repository/chat_repository.dart';

import '../../utils/color_utils.dart';

class ChatScreen extends StatefulWidget {
  final String receiverLogin;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.receiverLogin,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatView();
}

class _ChatView extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepository = ChatRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.receiverLogin,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("2F73B1"),
            hexStringToColor("2F73B1"),
            hexStringToColor("0B3963")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Column(
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              _buildMessageInput(),
            ],
          ),
        ));
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatRepository.sendMessage(
          widget.receiverId, _messageController.text);
      _messageController.clear();
    }
  }

  Widget _buildMessageInput() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Wpisz wiadomość...',
                  hintStyle: TextStyle(color: Colors.white24),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_circle_up,
              size: 40,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    FirebaseAuth firebase = FirebaseAuth.instance;
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var align = (data['senderId'] == firebase.currentUser!.uid)
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: (data['senderId'] == firebase.currentUser!.uid)
            ? BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(8.0),
              )
            : BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
        child: Text(
          data['message'],
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    FirebaseAuth firebase = FirebaseAuth.instance;
    return StreamBuilder(
        stream: _chatRepository.getMesseges(
            widget.receiverId, firebase.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Błąd ${snapshot.error}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }
}
