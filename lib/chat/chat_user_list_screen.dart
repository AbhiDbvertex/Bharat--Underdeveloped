import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'APIServices.dart';
import 'SocketService.dart';
import 'chatScreen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String userId = "68ac07f700315e754a037e56"; //      yash userID
  // final String userId = "68abeca08908c84c7c3769ea"; //   Abhishek userID
  List<dynamic> conversations = [];
  dynamic currentChat;
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _receiverIdController = TextEditingController();
  List<String> images = [];
  List<String> documents = [];
  List<dynamic> onlineUsers = [];
  String receiverId = '';
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool showChatDetail = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchConversations();
  }

  void _initSocket() {
    print('Initializing socket for userId: $userId');
    SocketService.connect(userId);
    SocketService.setMessageCallback((parsedMessage) {
      print('New message via socket: $parsedMessage');
      if (parsedMessage != null && parsedMessage['conversationId'] != null) {
        if (currentChat != null && parsedMessage['conversationId'] == currentChat['_id']) {
          setState(() {
            if (!messages.any((msg) => msg['_id'] == parsedMessage['_id'])) {
              messages.add(parsedMessage);
            }
          });
          _scrollToBottom();
          print('✅ Received message added to UI: ${parsedMessage['message']}');
        } else {
          _fetchConversations();
          print('ℹ️ Message from other chat: ${parsedMessage['conversationId']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New message in another chat!')),
          );
        }
      } else {
        print('❌ Invalid message data: $parsedMessage');
      }
    });
    SocketService.listenOnlineUsers((users) {
      print('Online users: $users');
      setState(() => onlineUsers = users);
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final convs = await ApiService.fetchConversations(userId);
      setState(() => conversations = convs);
    } catch (e) {
      print('Error fetching conversations: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversations fetch nahi hui: $e')));
    }
  }

  Future<void> _fetchMessages() async {
    if (currentChat == null) return;
    try {
      final msgs = await ApiService.fetchMessages(currentChat['_id']);
      setState(() {
        messages = msgs.where((msg) => !messages.any((m) => m['_id'] == msg['_id'])).toList() + messages;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error fetching messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Messages fetch nahi hui: $e')));
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
        receiverId = '';
        _receiverIdController.clear();
        showChatDetail = true;
      });
      _fetchMessages();
    } catch (e) {
      print('Error starting conversation: $e');
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

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.length <= 5) {
      setState(() {
        documents = result.files.map((file) => file.path!).toList();
      });
    } else if (result != null && result.files.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum 5 documents allowed!')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && images.isEmpty && documents.isEmpty) {
      print('Abhi:- No message, images, or documents to send.');
      return;
    }
    final receiverId = currentChat['members']
        ?.firstWhere((m) => m['_id'] != userId, orElse: () => null)?['_id'];
    if (receiverId == null || currentChat == null) {
      print('Abhi:- Current chat or receiverId is null, cannot send message.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle chat select karo!')));
      return;
    }

    try {
      print('Abhi:- Attempting to send message. Message: ${_messageController.text}, Images: $images, Documents: $documents');
      dynamic newMsg;
      if (images.isNotEmpty) {
        newMsg = await ApiService.sendImageMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'],
          imagePaths: images,
          message: _messageController.text.isNotEmpty ? _messageController.text : null,
        );
        print('Abhi:- Image message sent successfully: $newMsg');
      } else if (documents.isNotEmpty) {
        newMsg = await ApiService.sendDocumentMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'],
          documentPaths: documents,
          message: _messageController.text.isNotEmpty ? _messageController.text : null,
        );
        print('Abhi:- Document message sent successfully: $newMsg');
      } else {
        final msgData = {
          'senderId': userId,
          'receiverId': receiverId,
          'conversationId': currentChat['_id'],
          'message': _messageController.text,
          'messageType': 'text',
        };
        newMsg = await ApiService.sendTextMessage(msgData);
        print('Abhi:- Text message sent successfully: $newMsg');
      }

      print('Abhi:- Emitting message via socket: $newMsg');
      SocketService.sendMessage(newMsg);
      setState(() {
        if (!messages.any((msg) => msg['_id'] == newMsg['_id'])) {
          messages.add(newMsg);
        }
        _messageController.clear();
        images.clear();
        documents.clear();
        print('Abhi:- Message added to UI and fields cleared.');
      });
      _scrollToBottom();
    } catch (e) {
      print('Abhi:- Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String createdAt) {
    final DateTime dateTime = DateTime.parse(createdAt).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }

  @override
  void dispose() {
    SocketService.removeMessageCallback();
    SocketService.disconnect();
    _scrollController.dispose();
    _messageController.dispose();
    _receiverIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showChatDetail && currentChat != null) {
      return ChatDetailScreen(
        currentChat: currentChat,
        userId: userId,
        messages: messages,
        onlineUsers: onlineUsers,
        scrollController: _scrollController,
        messageController: _messageController,
        images: images,
        documents: documents,
        onBack: () {
          setState(() {
            showChatDetail = false;
            currentChat = null;
            messages.clear();
          });
        },
        onSendMessage: _sendMessage,
        onPickImages: _pickImages,
        onPickDocuments: _pickDocuments,
        formatTime: _formatTime,
      );
    }
    return ChatListScreen(
      conversations: conversations,
      userId: userId,
      onlineUsers: onlineUsers,
      receiverIdController: _receiverIdController,
      onReceiverIdChanged: (val) => receiverId = val,
      onStartConversation: _startConversation,
      onConversationTap: (conv) {
        setState(() {
          currentChat = conv;
          showChatDetail = true;
        });
        _fetchMessages();
      },
    );
  }
}

class ChatListScreen extends StatelessWidget {
  final List<dynamic> conversations;
  final String userId;
  final List<dynamic> onlineUsers;
  final TextEditingController receiverIdController;
  final Function(String) onReceiverIdChanged;
  final VoidCallback onStartConversation;
  final Function(dynamic) onConversationTap;

  const ChatListScreen({
    Key? key,
    required this.conversations,
    required this.userId,
    required this.onlineUsers,
    required this.receiverIdController,
    required this.onReceiverIdChanged,
    required this.onStartConversation,
    required this.onConversationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: receiverIdController,
                      onChanged: onReceiverIdChanged,
                      decoration: InputDecoration(
                        hintText: 'Enter User ID to start chat',
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onStartConversation,
                    icon: Icon(Icons.add_comment, color: Colors.white),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              itemBuilder: (ctx, idx) {
                final conv = conversations[idx];
                final members = (conv['members'] as List);
                final otherUser = members.firstWhere(
                      (m) => m['_id'] != userId,
                  orElse: () => {'name': 'Unknown', '_id': ''},
                );
                final isOnline = onlineUsers.contains(otherUser['_id']);

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: otherUser['avatar'] != null
                              ? NetworkImage(otherUser['avatar'])
                              : null,
                          child: otherUser['avatar'] == null
                              ? Icon(Icons.person, color: Colors.grey[600], size: 30)
                              : null,
                        ),
                        if (isOnline)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      '${otherUser['name'] ?? 'Unknown'} - Carpenter',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      conv['lastMessage'] ?? 'Tap to start conversation',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onConversationTap(conv),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
               //  THIS COMMENTED CODE IS CURRECT
/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'APIServices.dart';
import 'SocketService.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final String userId = "68ac07f700315e754a037e56"; // Yash userID
  late String userId = ""; // Yash userID
  List<dynamic> conversations = [];
  dynamic currentChat;
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _receiverIdController = TextEditingController();
  List<String> images = [];
  List<String> documents = [];
  List<dynamic> onlineUsers = [];
  String receiverId = '';
  final ScrollController _detailScrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool showChatDetail = false;
  late final String? fullName;
  // late final  fullName;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchConversations();
    _fetchProfileFromAPI();
  }



  Future<void> _fetchProfileFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("Abhi:- No token found, skipping fetch");
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final data = body['data'];
          final userAge = data['age']?.toString() ?? '';
          final userGender = (data['gender'] ?? '').toString().toLowerCase();

          setState(() {
            fullName = data['full_name'] ?? 'Your Name';
            userId = data['_id'] ?? 'Your Name';
          });

          print("Abhi:- get user name : $fullName userId : $userId");

          // print("Abhi:- User Profile Fetched - Age: $userAge, Gender: $userGender, VerifiedStatus: $verifiedSataus, Category: $category_name, RejectionReason: $rejectionReason");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Failed to fetch profile')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error, profile fetch failed!')),
        );
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromAPI Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong, try again!')),
      );
    }
  }

  void _initSocket() {
    print('Initializing socket for userId: $userId');
    SocketService.connect(userId);
    SocketService.setMessageCallback((parsedMessage) {
      print('New message via socket: $parsedMessage');
      if (parsedMessage != null && parsedMessage['conversationId'] != null) {
        if (currentChat != null &&
            parsedMessage['conversationId'] == currentChat['_id']) {
          setState(() {
            if (!messages.any((msg) => msg['_id'] == parsedMessage['_id'])) {
              messages.insert(0, parsedMessage); // Add at start for reverse display
            }
          });
          _scrollToBottom();
          print('✅ Received message added to UI: ${parsedMessage['message']}');
        } else {
          _fetchConversations();
          print('ℹ️ Message from other chat: ${parsedMessage['conversationId']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New message in another chat!')),
          );
        }
      } else {
        print('❌ Invalid message data: $parsedMessage');
      }
    });
    SocketService.listenOnlineUsers((users) {
      print('Online users: $users');
      setState(() => onlineUsers = users);
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final convs = await ApiService.fetchConversations(userId);
      setState(() => conversations = convs);
    } catch (e) {
      print('Error fetching conversations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversations fetch nahi hui: $e')));
    }
  }

  Future<void> _fetchMessages() async {
    if (currentChat == null) return;
    try {
      final msgs = await ApiService.fetchMessages(currentChat['_id']);
      setState(() {
        messages = msgs.toList(); // Ensure messages are sorted by createdAt
        messages.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt']))); // Latest first
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error fetching messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Messages fetch nahi hui: $e')));
    }
  }

  Future<void> _startConversation() async {
    if (receiverId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter Receiver ID')));
      return;
    }
    try {
      final newConv = await ApiService.startConversation(userId, receiverId);
      setState(() {
        conversations.add(newConv);
        currentChat = newConv;
        receiverId = '';
        _receiverIdController.clear();
        showChatDetail = true;
      });
      _fetchMessages();
    } catch (e) {
      print('Error starting conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversation not start: $e')));
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

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.length <= 5) {
      setState(() {
        documents = result.files.map((file) => file.path!).toList();
      });
    } else if (result != null && result.files.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum 5 documents allowed!')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && images.isEmpty && documents.isEmpty) {
      print('Abhi:- No message, images, or documents to send.');
      return;
    }
    final receiverId = currentChat['members']
        ?.firstWhere((m) => m['_id'] != userId, orElse: () => null)?['_id'];
    if (receiverId == null || currentChat == null) {
      print('Abhi:- Current chat or receiverId is null, cannot send message.');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Pehle chat select karo!')));
      return;
    }

    try {
      print(
          'Abhi:- Attempting to send message. Message: ${_messageController.text}, Images: $images, Documents: $documents');
      dynamic newMsg;
      if (images.isNotEmpty) {
        newMsg = await ApiService.sendImageMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'],
          imagePaths: images,
          message: _messageController.text.isNotEmpty ? _messageController.text : null,
        );
        print('Abhi:- Image message sent successfully: $newMsg');
      } else if (documents.isNotEmpty) {
        newMsg = await ApiService.sendDocumentMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'],
          documentPaths: documents,
          message: _messageController.text.isNotEmpty ? _messageController.text : null,
        );
        print('Abhi:- Document message sent successfully: $newMsg');
      } else {
        final msgData = {
          'senderId': userId,
          'receiverId': receiverId,
          'conversationId': currentChat['_id'],
          'message': _messageController.text,
          'messageType': 'text',
        };
        newMsg = await ApiService.sendTextMessage(msgData);
        print('Abhi:- Text message sent successfully: $newMsg');
      }

      print('Abhi:- Emitting message via socket: $newMsg');
      SocketService.sendMessage(newMsg);
      setState(() {
        if (!messages.any((msg) => msg['_id'] == newMsg['_id'])) {
          messages.insert(0, newMsg); // Add at start for reverse display
        }
        _messageController.clear();
        images.clear();
        documents.clear();
        print('Abhi:- Message added to UI and fields cleared.');
      });
      _scrollToBottom();
    } catch (e) {
      print('Abhi:- Error sending message: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Message not send: $e')));
    }
  }

  void _scrollToBottom() {
    if (_detailScrollController.hasClients) {
      _detailScrollController.jumpTo(0);
    } else {
      Future.delayed(Duration(milliseconds: 100), () => _scrollToBottom());
    }
  }

  String _formatTime(String createdAt) {
    try {
      final DateTime dateTime = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final difference = now.difference(dateTime).inDays;

      if (difference == 0) {
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else if (difference == 1) {
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      return "Invalid time";
    }
  }

  @override
  void dispose() {
    SocketService.removeMessageCallback();
    SocketService.disconnect();
    _detailScrollController.dispose();
    _messageController.dispose();
    _receiverIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showChatDetail && currentChat != null) {
      return ChatDetailScreen(
        currentChat: currentChat,
        userId: userId,
        messages: messages,
        onlineUsers: onlineUsers,
        scrollController: _detailScrollController,
        messageController: _messageController,
        images: images,
        documents: documents,
        onBack: () {
          setState(() {
            showChatDetail = false;
            currentChat = null;
            messages.clear();
          });
        },
        onSendMessage: _sendMessage,
        onPickImages: _pickImages,
        onPickDocuments: _pickDocuments,
        formatTime: _formatTime,
      );
    }
    return ChatListScreen(
      conversations: conversations,
      userId: userId,
      onlineUsers: onlineUsers,
      receiverIdController: _receiverIdController,
      onReceiverIdChanged: (val) => receiverId = val,
      onStartConversation: _startConversation,
      onConversationTap: (conv) {
        setState(() {
          currentChat = conv;
          showChatDetail = true;
        });
        _fetchMessages();
      },
    );
  }
}

class ChatListScreen extends StatefulWidget {
  final List<dynamic> conversations;
  final String userId;
  final List<dynamic> onlineUsers;
  final TextEditingController receiverIdController;
  final Function(String) onReceiverIdChanged;
  final VoidCallback onStartConversation;
  final Function(dynamic) onConversationTap;

  const ChatListScreen({
    Key? key,
    required this.conversations,
    required this.userId,
    required this.onlineUsers,
    required this.receiverIdController,
    required this.onReceiverIdChanged,
    required this.onStartConversation,
    required this.onConversationTap,
  }) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ScrollController _listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: widget.receiverIdController,
                      onChanged: widget.onReceiverIdChanged,
                      decoration: InputDecoration(
                        hintText: 'Enter User ID to start chat',
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: widget.onStartConversation,
                    icon: Icon(Icons.add_comment, color: Colors.white),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _listScrollController,
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.conversations.length,
              itemBuilder: (ctx, idx) {
                final conv = widget.conversations[idx];
                final members = (conv['members'] as List);
                final otherUser = members.firstWhere(
                      (m) => m['_id'] != widget.userId,
                  orElse: () => {'name': 'Unknown', '_id': ''},
                );
                final isOnline = widget.onlineUsers.contains(otherUser['_id']);

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: otherUser['avatar'] != null
                              ? NetworkImage(otherUser['avatar'])
                              : null,
                          child: otherUser['avatar'] == null
                              ? Icon(Icons.person, color: Colors.grey[600], size: 30)
                              : null,
                        ),
                        if (isOnline)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      '${otherUser['name'] ?? 'Unknown'} - Carpenter',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      conv['lastMessage'] ?? 'Tap to start conversation',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => widget.onConversationTap(conv),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }
}*/
