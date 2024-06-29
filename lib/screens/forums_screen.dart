import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lexibrowser/controllers/profile_controller.dart';
import 'package:lexibrowser/helpers/constants.dart';

final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final ProfileController profileController = Get.find();
  late String messageText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('⚡️Forums'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore.collection('messages').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.lightBlueAccent,
                      ),
                    );
                  }
                  final querySnapshot = snapshot.requireData;
                  final messages = querySnapshot.docs;
                  List<Widget> messageBubbles = [];
                  for (var message in messages) {
                    final messageData = message.data();
                    final messageText = messageData['message'] ?? '';
                    final messageSender = messageData['sender'] ?? 'Unknown';
                    final profileImage = messageData['profileImage'] ?? '';
                    final messageBubble = MessageBubble(
                      sender: messageSender,
                      text: messageText,
                      profileImage: profileImage,
                      isMe: messageSender == profileController.userName.value,
                    );
                    messageBubbles.add(messageBubble);
                  }
                  return ListView(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageBubbles,
                  );
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                        hintText: 'Enter your message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Colors.lightBlueAccent,
                    onPressed: () {
                      if (messageTextController.text.isNotEmpty) {
                        messageTextController.clear();
                        _firestore.collection('messages').add({
                          'message': messageText,
                          'sender': profileController.userName.value ?? 'Unknown',
                          'profileImage': profileController.profileImagePath.value ?? '',
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String profileImage;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.profileImage,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                CircleAvatar(
                  backgroundImage: profileImage.isNotEmpty
                      ? FileImage(File(profileImage))
                      : AssetImage("assets/images/vpn2.png") as ImageProvider,
                ),
              if (!isMe)
                SizedBox(width: 8.0),
              Text(
                sender,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
              if (isMe)
                SizedBox(width: 8.0),
              if (isMe)
                CircleAvatar(
                  backgroundImage: profileImage.isNotEmpty
                      ? FileImage(File(profileImage))
                      : AssetImage("assets/images/vpn2.png") as ImageProvider,
                ),
            ],
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
