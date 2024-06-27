import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Reusuables/global.dart';

class ChatScreen extends StatefulWidget {
  final String lobbyId;
  final String phnum;

  ChatScreen({required this.lobbyId,required this.phnum});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.50,
          height: 100,
          child: Image.asset('assets/logoclue.png'),
        ),
        centerTitle: true, // Center the title
        flexibleSpace: Stack(
            children: [
              Image.asset(
                'assets/backnews.png', // Replace with your actual background image path
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ]
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/backnews.png'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter),
        ),

        child: Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats_${widget.lobbyId}').orderBy('timestamp').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var message = snapshot.data!.docs[index];
            bool isCurrentUser = message['senderId'] == widget.phnum;

            return Align(
              alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentUser ? redcol : yellowcol,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['message'],
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      isCurrentUser ? 'You' : message['senderId'],
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white70 : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_textController.text);
              _textController.clear();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return; // Don't send empty messages

    FirebaseFirestore.instance.collection('chats_${widget.lobbyId}').add({
      'message': message,
      'senderId': widget.phnum, // Replace with actual sender ID
      'timestamp': DateTime.now(),
    });
  }
}
