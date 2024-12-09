import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Chat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _user != null
              ? IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
              })
              : SizedBox()
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.15,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/appbackgroundoptimize.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(child: _buildMessagesList()),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;
        var now = DateFormat('yyyy-MM-dd').format(DateTime.now());
        var yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 1)));

        bool isTodayDisplayed = false;

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var messageTime = (message['timestamp'] as Timestamp).toDate();
            var formattedDate = DateFormat('yyyy-MM-dd').format(messageTime);

            // Only display "Today" once
            bool showTodayLabel = false;
            if (formattedDate == now && !isTodayDisplayed) {
              showTodayLabel = true;
              isTodayDisplayed = true;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTodayLabel) _buildDateHeader('Today'),
                _buildMessageContent(message),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(DocumentSnapshot message) {
    bool isUserMessage = message['sender'] == _user?.email;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Text(
                message['sender'][0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isUserMessage ? Colors.blue : Color(0x33727272),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                        fontSize: 16, color: isUserMessage ? Colors.white : Colors.white),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${message['sender']}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _formatMessageTime(message['timestamp']),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUserMessage)
            SizedBox(width: 8),
          if (isUserMessage)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Text(
                message['sender'][0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  String _formatMessageTime(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(messageTime);
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white), // Text color inside input box
              decoration: InputDecoration(
                hintText: 'Enter a message...',
                hintStyle: TextStyle(color: Colors.white70), // Hint text color when not focused
                filled: true,
                fillColor: Colors.black, // Background color of input box
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide.none, // No border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(color: Colors.blue, width: 1), // Border color when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.5), width: 1), // Border color when not focused
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }


  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    await _firestore.collection('messages').add({
      'text': _controller.text,
      'sender': _user?.email ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }
}
