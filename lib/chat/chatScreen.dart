import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'APIServices.dart';
import 'SocketService.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String userId = "68abec670fa4a01b9b742ddf"; // TODO: Auth se le
  List<dynamic> conversations = [];
  dynamic currentChat;
  List<dynamic> messages = [];
  String message = '';
  List<String> images = []; // Image file paths store kar
  List<dynamic> onlineUsers = [];
  String receiverId = '';
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchConversations();
  }

  void _initSocket() {
    print('Initializing socket for userId: $userId');
    SocketService.connect(userId);
    SocketService.listenOnlineUsers((users) {
      print('Online users: $users');
      setState(() => onlineUsers = users);
    });
    SocketService.listenNewMessage((data) {
      print('New message: $data');
      if (currentChat != null && data['conversationId'] == currentChat['_id']) {
        setState(() => messages.add(data));
        _scrollToBottom();
      }
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final convs = await ApiService.fetchConversations(userId);
      setState(() => conversations = convs);
    } catch (e) {
      print('Error fetching conversations: $e');
    }
  }

  Future<void> _fetchMessages() async {
    if (currentChat == null) return;
    try {
      final msgs = await ApiService.fetchMessages(currentChat['_id']);
      setState(() => messages = msgs);
      _scrollToBottom();
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> _startConversation() async {
    if (receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receiver ID daalo!')));
      return;
    }
    try {
      final newConv = await ApiService.startConversation(userId, receiverId);
      setState(() {
        conversations.add(newConv);
        currentChat = newConv;
      });
      receiverId = '';
      _fetchMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      if (pickedFiles.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum 5 images allowed!')),
        );
        return;
      }
      setState(() {
        images = pickedFiles.map((file) => file.path).toList();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (message.isEmpty && images.isEmpty) return;
    final receiverId = "68ac1a6900315e754a038c80"; // Hardcoded jaise React mein
    if (currentChat == null) return;

    try {
      dynamic newMsg;
      if (images.isNotEmpty) {
        newMsg = await ApiService.sendImageMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'],
          imagePaths: images,
          message: message.isNotEmpty ? message : null,
        );
      } else {
        final msgData = {
          'senderId': userId,
          'receiverId': receiverId,
          'conversationId': currentChat['_id'],
          'message': message,
          'messageType': 'text',
        };
        newMsg = await ApiService.sendTextMessage(msgData);
      }

      SocketService.sendMessage(newMsg);
      setState(() {
        messages.add(newMsg);
        message = '';
        images.clear();
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (val) => receiverId = val,
                          decoration: InputDecoration(hintText: 'Receiver ID daalo'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _startConversation,
                          child: Text('Start Chat'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, 48),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (ctx, idx) {
                      final conv = conversations[idx];
                      final otherUser = conv['members'].firstWhere((m) => m['_id'] != userId);
                      return ListTile(
                        title: Text(otherUser['name'] ?? 'User'),
                        subtitle: Text(conv['lastMessage'] ?? ''),
                        onTap: () {
                          setState(() => currentChat = conv);
                          _fetchMessages();
                        },
                        selected: currentChat?['_id'] == conv['_id'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Chat Area
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (ctx, idx) {
                      final msg = messages[idx];
                      final isMe = msg['senderId'] == userId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: msg['messageType'] == 'image' && msg['image'] != null
                              ? Column(
                            children: [
                              ...?msg['image'].map<Widget>((imgUrl) => Image.network(
                                'https://api.thebharatworks.com/$imgUrl',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )),
                              if (msg['message'] != null) Text(msg['message']),
                            ],
                          )
                              : Text(msg['message'] ?? ''),
                        ),
                      );
                    },
                  ),
                ),
                if (currentChat != null)
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            onChanged: (val) => message = val,
                            decoration: InputDecoration(hintText: 'Message type karo...'),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: _pickImages,
                          icon: Icon(Icons.image),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: _sendMessage,
                            child: Text('Send'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(0, 48),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SocketService.disconnect();
    _scrollController.dispose();
    super.dispose();
  }
}