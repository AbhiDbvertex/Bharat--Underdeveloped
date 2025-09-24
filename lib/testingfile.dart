import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat/APIServices.dart';
import 'chat/SocketService.dart';

class ChatDetailScreen extends StatelessWidget {
  final dynamic currentChat;
  final String userId;
  final List<dynamic> messages;
  final List<dynamic> onlineUsers;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final List<String> images;
  final List<String> documents;
  final VoidCallback onBack;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImages;
  final VoidCallback onPickDocuments;
  final String Function(String) formatTime;

  const ChatDetailScreen({
    Key? key,
    required this.currentChat,
    required this.userId,
    required this.messages,
    required this.onlineUsers,
    required this.scrollController,
    required this.messageController,
    required this.images,
    required this.documents,
    required this.onBack,
    required this.onSendMessage,
    required this.onPickImages,
    required this.onPickDocuments,
    required this.formatTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final members = (currentChat['members'] as List);
    final otherUser = members.firstWhere(
          (m) => m['_id'] != userId,
      orElse: () => {'name': 'Unknown', '_id': ''},
    );
    final isOnline = onlineUsers.contains(otherUser['_id']);


    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBack,
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: otherUser['avatar'] != null
                        ? NetworkImage(otherUser['avatar'])
                        : null,
                    child: otherUser['avatar'] == null
                        ? Icon(Icons.person, color: Colors.grey[600], size: 20)
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  otherUser['name'] ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.phone, color: Colors.black),
              onPressed: () {
                // Handle voice call
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                // Handle more options
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                reverse: true, // Latest messages neeche
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = messages[idx]; // Reverse order mein already sorted
                  final isMe = msg['senderId'] == userId;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[600] : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 5),
                              bottomRight: Radius.circular(isMe ? 5 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg['messageType'] == 'image' && msg['image'] != null)
                                ...msg['image'].map<Widget>((imgUrl) => Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      'https://api.thebharatworks.com/$imgUrl',
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.error),
                                          ),
                                    ),
                                  ),
                                )),
                              if (msg['messageType'] == 'document' &&
                                  msg['document'] != null)
                                ...msg['document'].map<Widget>((docUrl) => Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.insert_drive_file, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        docUrl.split('/').last,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )),
                              if (msg['message'] != null && msg['message'].isNotEmpty)
                                Text(
                                  msg['message'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTime(msg['createdAt']),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isMe ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (images.isNotEmpty || documents.isNotEmpty)
              Container(
                height: 80,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length + documents.length,
                  itemBuilder: (context, index) {
                    if (index < images.length) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      final docIndex = index - images.length;
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file, size: 24),
                            Text(
                              documents[docIndex].split('/').last.substring(
                                  0,
                                  documents[docIndex].split('/').last.length > 8
                                      ? 8
                                      : documents[docIndex].split('/').last.length),
                              style: TextStyle(fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onPickDocuments,
                        icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Write a message',
                                    hintStyle: TextStyle(color: Colors.grey[600]),
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              IconButton(
                                onPressed: onPickImages,
                                icon: Icon(Icons.image, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: onSendMessage,
                          icon: Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
}
//
// //
// // /*
// //
// // import 'package:flutter/material.dart';
// //
// // class PropertyDetailPage extends StatefulWidget {
// //   final Map<String, dynamic> property;
// //
// //   const PropertyDetailPage({
// //     Key? key,
// //     required this.property,
// //   }) : super(key: key);
// //
// //   @override
// //   _PropertyDetailPageState createState() => _PropertyDetailPageState();
// // }
// //
// // class _PropertyDetailPageState extends State<PropertyDetailPage> {
// //   int currentImageIndex = 0;
// //   PageController _pageController = PageController();
// //
// //   // Sample property data - replace with actual data from widget.property
// //   final Map<String, dynamic> sampleProperty = {
// //     'images': [
// //       'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
// //       'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2080&q=80',
// //       'https://images.unsplash.com/photo-1484154218962-a197022b5858?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2074&q=80',
// //     ],
// //     'title': 'Luxury 2BHK Apartment',
// //     'address': '123, Green Valley Society, Sector 21, Indore, Madhya Pradesh 452010',
// //     'owner': {
// //       'name': 'Rajesh Kumar',
// //       'image': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
// //       'phone': '+91 98765 43210',
// //     },
// //     'propertySize': '1200 sq ft',
// //     'rent': 15000,
// //     'deposit': 45000,
// //     'electricityBill': 'Excluded (₹2-3k/month)',
// //     'parking': 'Available',
// //     'kitchen': 'Modular Kitchen',
// //     'bathrooms': 2,
// //     'roomType': '2 BHK',
// //     'rules': [
// //       'No smoking inside the apartment',
// //       'No pets allowed',
// //       'No loud music after 10 PM',
// //       'Vegetarian tenants preferred',
// //       'Regular house cleaning required',
// //       'No unauthorized guests overnight'
// //     ],
// //     'amenities': [
// //       'WiFi',
// //       'Air Conditioning',
// //       '24/7 Security',
// //       'Lift',
// //       'Power Backup',
// //       'Water Supply',
// //       'Gym',
// //       'Garden'
// //     ],
// //     'rating': 4.5,
// //   };
// //
// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final property = widget.property.isNotEmpty ? widget.property : sampleProperty;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: CustomScrollView(
// //         slivers: [
// //           // Image Slider with App Bar
// //           SliverAppBar(
// //             expandedHeight: 300,
// //             floating: false,
// //             pinned: true,
// //             backgroundColor: Colors.white,
// //             elevation: 0,
// //             leading: Container(
// //               margin: EdgeInsets.all(8),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.9),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: IconButton(
// //                 icon: Icon(Icons.arrow_back, color: Colors.black),
// //                 onPressed: () => Navigator.pop(context),
// //               ),
// //             ),
// //             actions: [
// //               Container(
// //                 margin: EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.9),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: IconButton(
// //                   icon: Icon(Icons.favorite_border, color: Colors.black),
// //                   onPressed: () {
// //                     // Handle favorite
// //                   },
// //                 ),
// //               ),
// //               Container(
// //                 margin: EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.9),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: IconButton(
// //                   icon: Icon(Icons.share, color: Colors.black),
// //                   onPressed: () {
// //                     // Handle share
// //                   },
// //                 ),
// //               ),
// //             ],
// //             flexibleSpace: FlexibleSpaceBar(
// //               background: Stack(
// //                 children: [
// //                   PageView.builder(
// //                     controller: _pageController,
// //                     onPageChanged: (index) {
// //                       setState(() {
// //                         currentImageIndex = index;
// //                       });
// //                     },
// //                     itemCount: property['images']?.length ?? 0,
// //                     itemBuilder: (context, index) {
// //                       return Image.network(
// //                         property['images'][index],
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) => Container(
// //                           color: Colors.grey[300],
// //                           child: Icon(Icons.image_not_supported, size: 50),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   // Image indicators
// //                   Positioned(
// //                     bottom: 20,
// //                     left: 0,
// //                     right: 0,
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: List.generate(
// //                         property['images']?.length ?? 0,
// //                             (index) => Container(
// //                           margin: EdgeInsets.symmetric(horizontal: 3),
// //                           width: 8,
// //                           height: 8,
// //                           decoration: BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             color: currentImageIndex == index
// //                                 ? Colors.white
// //                                 : Colors.white.withOpacity(0.5),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   // Image counter
// //                   Positioned(
// //                     top: 50,
// //                     right: 20,
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                       decoration: BoxDecoration(
// //                         color: Colors.black.withOpacity(0.6),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Text(
// //                         '${currentImageIndex + 1}/${property['images']?.length ?? 0}',
// //                         style: TextStyle(color: Colors.white, fontSize: 12),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //
// //           // Property Content
// //           SliverToBoxAdapter(
// //             child: Padding(
// //               padding: EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Property Title and Rating
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               property['title'] ?? 'Property Title',
// //                               style: TextStyle(
// //                                 fontSize: 24,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black87,
// //                               ),
// //                             ),
// //                             SizedBox(height: 4),
// //                             Text(
// //                               property['roomType'] ?? '2 BHK',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 color: Colors.blue[600],
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Container(
// //                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                         decoration: BoxDecoration(
// //                           color: Colors.orange[100],
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(Icons.star, color: Colors.orange, size: 16),
// //                             SizedBox(width: 4),
// //                             Text(
// //                               property['rating']?.toString() ?? '4.5',
// //                               style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.orange[700],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   SizedBox(height: 20),
// //
// //                   // Address
// //                   _buildInfoSection(
// //                     'Address',
// //                     Icons.location_on,
// //                     property['address'] ?? 'Address not available',
// //                     Colors.red,
// //                   ),
// //
// //                   SizedBox(height: 24),
// //
// //                   // Owner Information
// //                   _buildOwnerSection(property['owner']),
// //
// //                   SizedBox(height: 24),
// //
// //                   // Rent and Deposit
// //                   _buildPricingSection(property),
// //
// //                   SizedBox(height: 24),
// //
// //                   // Property Details
// //                   _buildPropertyDetailsSection(property),
// //
// //                   SizedBox(height: 24),
// //
// //                   // Amenities
// //                   _buildAmenitiesSection(property['amenities']),
// //
// //                   SizedBox(height: 24),
// //
// //                   // Room Rules
// //                   _buildRoomRulesSection(property['rules']),
// //
// //                   SizedBox(height: 100), // Extra space for floating button
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: Container(
// //         width: double.infinity,
// //         margin: EdgeInsets.symmetric(horizontal: 20),
// //         child: Row(
// //           children: [
// //             Expanded(
// //               child: ElevatedButton.icon(
// //                 onPressed: () {
// //                   // Handle call owner
// //                 },
// //                 icon: Icon(Icons.phone, color: Colors.white),
// //                 label: Text(
// //                   'Call Owner',
// //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                 ),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.green[600],
// //                   foregroundColor: Colors.white,
// //                   padding: EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(width: 12),
// //             Expanded(
// //               child: ElevatedButton.icon(
// //                 onPressed: () {
// //                   // Handle schedule visit
// //                 },
// //                 icon: Icon(Icons.calendar_today, color: Colors.white),
// //                 label: Text(
// //                   'Schedule Visit',
// //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                 ),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue[600],
// //                   foregroundColor: Colors.white,
// //                   padding: EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
// //     );
// //   }
// //
// //   Widget _buildInfoSection(String title, IconData icon, String content, Color iconColor) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Icon(icon, color: iconColor, size: 20),
// //             SizedBox(width: 8),
// //             Text(
// //               title,
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.black87,
// //               ),
// //             ),
// //           ],
// //         ),
// //         SizedBox(height: 8),
// //         Text(
// //           content,
// //           style: TextStyle(
// //             fontSize: 16,
// //             color: Colors.grey[700],
// //             height: 1.4,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildOwnerSection(Map<String, dynamic>? owner) {
// //     if (owner == null) return SizedBox.shrink();
// //
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Property Owner',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           SizedBox(height: 12),
// //           Row(
// //             children: [
// //               CircleAvatar(
// //                 radius: 30,
// //                 backgroundColor: Colors.grey[300],
// //                 backgroundImage: owner['image'] != null
// //                     ? NetworkImage(owner['image'])
// //                     : null,
// //                 child: owner['image'] == null
// //                     ? Icon(Icons.person, size: 30, color: Colors.grey[600])
// //                     : null,
// //               ),
// //               SizedBox(width: 16),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       owner['name'] ?? 'Owner Name',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.black87,
// //                       ),
// //                     ),
// //                     SizedBox(height: 4),
// //                     Text(
// //                       owner['phone'] ?? 'Phone not available',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.grey[600],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Container(
// //                 padding: EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.green[100],
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Icon(Icons.verified_user, color: Colors.green[700], size: 20),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPricingSection(Map<String, dynamic> property) {
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [Colors.blue[50]!, Colors.blue[100]!],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Pricing Details',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: _buildPriceItem(
// //                   'Monthly Rent',
// //                   '₹${property['rent']?.toString() ?? '0'}',
// //                   Colors.green[700]!,
// //                 ),
// //               ),
// //               Container(width: 1, height: 40, color: Colors.grey[300]),
// //               Expanded(
// //                 child: _buildPriceItem(
// //                   'Security Deposit',
// //                   '₹${property['deposit']?.toString() ?? '0'}',
// //                   Colors.orange[700]!,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 12),
// //           Text(
// //             'Electricity: ${property['electricityBill'] ?? 'Not specified'}',
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: Colors.grey[700],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPriceItem(String label, String value, Color color) {
// //     return Column(
// //       children: [
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //             color: color,
// //           ),
// //         ),
// //         SizedBox(height: 4),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 12,
// //             color: Colors.grey[600],
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildPropertyDetailsSection(Map<String, dynamic> property) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Property Details',
// //           style: TextStyle(
// //             fontSize: 18,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Container(
// //           padding: EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.grey[200]!),
// //           ),
// //           child: Column(
// //             children: [
// //               _buildDetailRow('Property Size', property['propertySize'] ?? 'Not specified', Icons.square_foot),
// //               _buildDetailRow('Kitchen', property['kitchen'] ?? 'Not specified', Icons.kitchen),
// //               _buildDetailRow('Bathrooms', property['bathrooms']?.toString() ?? '0', Icons.bathroom),
// //               _buildDetailRow('Parking', property['parking'] ?? 'Not available', Icons.local_parking),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildDetailRow(String label, String value, IconData icon) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(vertical: 8),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: Colors.blue[600], size: 20),
// //           SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w500,
// //               color: Colors.black87,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAmenitiesSection(List<dynamic>? amenities) {
// //     if (amenities == null || amenities.isEmpty) return SizedBox.shrink();
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Amenities',
// //           style: TextStyle(
// //             fontSize: 18,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Wrap(
// //           spacing: 8,
// //           runSpacing: 8,
// //           children: amenities.map((amenity) => Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: Colors.green[50],
// //               borderRadius: BorderRadius.circular(20),
// //               border: Border.all(color: Colors.green[200]!),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(Icons.check_circle, color: Colors.green[600], size: 16),
// //                 SizedBox(width: 6),
// //                 Text(
// //                   amenity.toString(),
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     color: Colors.green[700],
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )).toList(),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildRoomRulesSection(List<dynamic>? rules) {
// //     if (rules == null || rules.isEmpty) return SizedBox.shrink();
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Room Rules',
// //           style: TextStyle(
// //             fontSize: 18,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Container(
// //           padding: EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.red[50],
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.red[200]!),
// //           ),
// //           child: Column(
// //             children: rules.map((rule) => Padding(
// //               padding: EdgeInsets.symmetric(vertical: 4),
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Icon(Icons.info_outline, color: Colors.red[600], size: 16),
// //                   SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       rule.toString(),
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.red[700],
// //                         height: 1.3,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             )).toList(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }*/
//
// //
// // import 'package:flutter/material.dart';
// //
// // class PropertyDashboard extends StatefulWidget {
// //   @override
// //   _PropertyDashboardState createState() => _PropertyDashboardState();
// // }
// //
// // class _PropertyDashboardState extends State<PropertyDashboard> {
// //   final TextEditingController _searchController = TextEditingController();
// //   String selectedLocation = 'Indore';
// //   String selectedPropertyType = 'All';
// //   String selectedBudget = 'Any Budget';
// //   int _selectedIndex = 0;
// //
// //   // Sample data - replace with your API data
// //   final List<Map<String, dynamic>> featuredProperties = [
// //     {
// //       'id': '1',
// //       'title': 'Luxury 2BHK Apartment',
// //       'location': 'Vijay Nagar, Indore',
// //       'rent': 15000,
// //       'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
// //       'type': '2 BHK',
// //       'area': '1200 sq ft',
// //       'rating': 4.5,
// //       'isFavorite': false,
// //     },
// //     {
// //       'id': '2',
// //       'title': 'Modern Studio Apartment',
// //       'location': 'Palasia, Indore',
// //       'rent': 8000,
// //       'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=2080&q=80',
// //       'type': 'Studio',
// //       'area': '600 sq ft',
// //       'rating': 4.2,
// //       'isFavorite': true,
// //     },
// //     {
// //       'id': '3',
// //       'title': 'Spacious 3BHK Villa',
// //       'location': 'Scheme 54, Indore',
// //       'rent': 25000,
// //       'image': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?ixlib=rb-4.0.3&auto=format&fit=crop&w=2074&q=80',
// //       'type': '3 BHK',
// //       'area': '1800 sq ft',
// //       'rating': 4.8,
// //       'isFavorite': false,
// //     },
// //   ];
// //
// //   final List<Map<String, dynamic>> recentProperties = [
// //     {
// //       'id': '4',
// //       'title': 'Cozy 1BHK Near IT Park',
// //       'location': 'Scheme 78, Indore',
// //       'rent': 12000,
// //       'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
// //       'type': '1 BHK',
// //       'area': '800 sq ft',
// //       'rating': 4.3,
// //       'isNew': true,
// //     },
// //     {
// //       'id': '5',
// //       'title': 'Furnished Studio',
// //       'location': 'AB Road, Indore',
// //       'rent': 9500,
// //       'image': 'https://images.unsplash.com/photo-1493663284031-b7e3aaa4c4bc?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
// //       'type': 'Studio',
// //       'area': '500 sq ft',
// //       'rating': 4.0,
// //       'isNew': true,
// //     },
// //   ];
// //
// //   final List<String> locations = ['Indore', 'Bhopal', 'Ujjain', 'Gwalior'];
// //   final List<String> propertyTypes = ['All', '1 BHK', '2 BHK', '3 BHK', 'Studio'];
// //   final List<String> budgets = ['Any Budget', '< ₹10K', '₹10K - ₹20K', '> ₹20K'];
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Header Section
// //               _buildHeader(),
// //
// //               // Search and Filters
// //               _buildSearchSection(),
// //
// //               // Quick Stats
// //               _buildQuickStats(),
// //
// //               // Featured Properties
// //               _buildFeaturedSection(),
// //
// //               // Categories
// //               _buildCategoriesSection(),
// //
// //               // Recent Properties
// //               _buildRecentSection(),
// //
// //               SizedBox(height: 20),
// //             ],
// //           ),
// //         ),
// //       ),
// //       bottomNavigationBar: _buildBottomNavigationBar(),
// //     );
// //   }
// //
// //   Widget _buildHeader() {
// //     return Container(
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [Colors.blue[600]!, Colors.blue[800]!],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.only(
// //           bottomLeft: Radius.circular(30),
// //           bottomRight: Radius.circular(30),
// //         ),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'Good Morning! 👋',
// //                       style: TextStyle(
// //                         color: Colors.white70,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                     SizedBox(height: 4),
// //                     Text(
// //                       'Find Your Dream Home',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Stack(
// //                 children: [
// //                   CircleAvatar(
// //                     radius: 25,
// //                     backgroundColor: Colors.white,
// //                     child: Icon(Icons.person, color: Colors.blue[600], size: 30),
// //                   ),
// //                   Positioned(
// //                     right: 0,
// //                     top: 0,
// //                     child: Container(
// //                       width: 12,
// //                       height: 12,
// //                       decoration: BoxDecoration(
// //                         color: Colors.green,
// //                         shape: BoxShape.circle,
// //                         border: Border.all(color: Colors.white, width: 2),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 20),
// //           Row(
// //             children: [
// //               Icon(Icons.location_on, color: Colors.white70, size: 16),
// //               SizedBox(width: 4),
// //               Text(
// //                 'Current Location: Indore, MP',
// //                 style: TextStyle(color: Colors.white70, fontSize: 14),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSearchSection() {
// //     return Padding(
// //       padding: EdgeInsets.all(20),
// //       child: Column(
// //         children: [
// //           // Search Bar
// //           Container(
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(15),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.1),
// //                   blurRadius: 10,
// //                   offset: Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: TextField(
// //               controller: _searchController,
// //               decoration: InputDecoration(
// //                 hintText: 'Search properties, locations...',
// //                 hintStyle: TextStyle(color: Colors.grey[500]),
// //                 prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
// //                 suffixIcon: IconButton(
// //                   icon: Icon(Icons.tune, color: Colors.blue[600]),
// //                   onPressed: () {
// //                     _showFilterBottomSheet();
// //                   },
// //                 ),
// //                 border: InputBorder.none,
// //                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //               ),
// //             ),
// //           ),
// //
// //           SizedBox(height: 16),
// //
// //           // Quick Filter Chips
// //           SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: Row(
// //               children: [
// //                 _buildFilterChip('Location', selectedLocation, Icons.location_on),
// //                 SizedBox(width: 8),
// //                 _buildFilterChip('Type', selectedPropertyType, Icons.home),
// //                 SizedBox(width: 8),
// //                 _buildFilterChip('Budget', selectedBudget, Icons.attach_money),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFilterChip(String label, String value, IconData icon) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.blue[50],
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.blue[200]!),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 16, color: Colors.blue[600]),
// //           SizedBox(width: 4),
// //           Text(
// //             '$label: $value',
// //             style: TextStyle(
// //               fontSize: 12,
// //               color: Colors.blue[700],
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildQuickStats() {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: 20),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: _buildStatCard(
// //               'Available Properties',
// //               '1,250+',
// //               Icons.home_work,
// //               Colors.green,
// //             ),
// //           ),
// //           SizedBox(width: 12),
// //           Expanded(
// //             child: _buildStatCard(
// //               'New Listings',
// //               '35',
// //               Icons.new_releases,
// //               Colors.orange,
// //             ),
// //           ),
// //           SizedBox(width: 12),
// //           Expanded(
// //             child: _buildStatCard(
// //               'Avg. Rent',
// //               '₹15K',
// //               Icons.trending_up,
// //               Colors.purple,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               color: color.withOpacity(0.1),
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(icon, color: color, size: 20),
// //           ),
// //           SizedBox(height: 8),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           SizedBox(height: 2),
// //           Text(
// //             title,
// //             style: TextStyle(
// //               fontSize: 10,
// //               color: Colors.grey[600],
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFeaturedSection() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: EdgeInsets.all(20),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Featured Properties',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   // Navigate to all properties
// //                 },
// //                 child: Text(
// //                   'View All',
// //                   style: TextStyle(color: Colors.blue[600]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         SizedBox(
// //           height: 300,
// //           child: ListView.builder(
// //             scrollDirection: Axis.horizontal,
// //             padding: EdgeInsets.symmetric(horizontal: 20),
// //             itemCount: featuredProperties.length,
// //             itemBuilder: (context, index) {
// //               return _buildPropertyCard(featuredProperties[index], isLarge: true);
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildCategoriesSection() {
// //     final List<Map<String, dynamic>> categories = [
// //       {'name': '1 BHK', 'icon': Icons.hotel, 'count': '450+'},
// //       {'name': '2 BHK', 'icon': Icons.home, 'count': '380+'},
// //       {'name': '3 BHK', 'icon': Icons.villa, 'count': '290+'},
// //       {'name': 'Studio', 'icon': Icons.apartment, 'count': '130+'},
// //     ];
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: EdgeInsets.all(20),
// //           child: Text(
// //             'Browse by Category',
// //             style: TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.black87,
// //             ),
// //           ),
// //         ),
// //         SizedBox(
// //           height: 120,
// //           child: ListView.builder(
// //             scrollDirection: Axis.horizontal,
// //             padding: EdgeInsets.symmetric(horizontal: 20),
// //             itemCount: categories.length,
// //             itemBuilder: (context, index) {
// //               final category = categories[index];
// //               return Container(
// //                 width: 100,
// //                 margin: EdgeInsets.only(right: 12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(15),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withOpacity(0.05),
// //                       blurRadius: 10,
// //                       offset: Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: InkWell(
// //                   onTap: () {
// //                     // Handle category selection
// //                   },
// //                   borderRadius: BorderRadius.circular(15),
// //                   child: Padding(
// //                     padding: EdgeInsets.all(16),
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Container(
// //                           padding: EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             color: Colors.blue[50],
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: Icon(
// //                             category['icon'],
// //                             color: Colors.blue[600],
// //                             size: 24,
// //                           ),
// //                         ),
// //                         SizedBox(height: 8),
// //                         Text(
// //                           category['name'],
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.w600,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                         Text(
// //                           category['count'],
// //                           style: TextStyle(
// //                             color: Colors.grey[600],
// //                             fontSize: 10,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildRecentSection() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: EdgeInsets.all(20),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Recently Added',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   // Navigate to recent properties
// //                 },
// //                 child: Text(
// //                   'View All',
// //                   style: TextStyle(color: Colors.blue[600]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         ListView.builder(
// //           shrinkWrap: true,
// //           physics: NeverScrollableScrollPhysics(),
// //           padding: EdgeInsets.symmetric(horizontal: 20),
// //           itemCount: recentProperties.length,
// //           itemBuilder: (context, index) {
// //             return _buildCompactPropertyCard(recentProperties[index]);
// //           },
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildPropertyCard(Map<String, dynamic> property, {bool isLarge = false}) {
// //     return Container(
// //       width: isLarge ? 280 : 200,
// //       margin: EdgeInsets.only(right: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: InkWell(
// //         onTap: () {
// //           // Navigate to property detail
// //         },
// //         borderRadius: BorderRadius.circular(15),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Stack(
// //               children: [
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
// //                   child: Image.network(
// //                     property['image'],
// //                     height: isLarge ? 180 : 120,
// //                     width: double.infinity,
// //                     fit: BoxFit.cover,
// //                     errorBuilder: (context, error, stackTrace) => Container(
// //                       height: isLarge ? 180 : 120,
// //                       color: Colors.grey[300],
// //                       child: Icon(Icons.image_not_supported),
// //                     ),
// //                   ),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: Container(
// //                     padding: EdgeInsets.all(4),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: Icon(
// //                       property['isFavorite'] ? Icons.favorite : Icons.favorite_border,
// //                       color: property['isFavorite'] ? Colors.red : Colors.grey,
// //                       size: 16,
// //                     ),
// //                   ),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   left: 8,
// //                   child: Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue[600],
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Text(
// //                       property['type'],
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 10,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             Expanded(
// //               child: Padding(
// //                 padding: EdgeInsets.all(12),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       property['title'],
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w600,
// //                         fontSize: 14,
// //                       ),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     SizedBox(height: 4),
// //                     Row(
// //                       children: [
// //                         Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
// //                         SizedBox(width: 2),
// //                         Expanded(
// //                           child: Text(
// //                             property['location'],
// //                             style: TextStyle(
// //                               color: Colors.grey[600],
// //                               fontSize: 11,
// //                             ),
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     SizedBox(height: 8),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text(
// //                           '₹${property['rent']}/month',
// //                           style: TextStyle(
// //                             color: Colors.green[600],
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                           ),
// //                         ),
// //                         Row(
// //                           children: [
// //                             Icon(Icons.star, color: Colors.orange, size: 12),
// //                             SizedBox(width: 2),
// //                             Text(
// //                               property['rating'].toString(),
// //                               style: TextStyle(fontSize: 11),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCompactPropertyCard(Map<String, dynamic> property) {
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: InkWell(
// //         onTap: () {
// //           // Navigate to property detail
// //         },
// //         borderRadius: BorderRadius.circular(12),
// //         child: Padding(
// //           padding: EdgeInsets.all(12),
// //           child: Row(
// //             children: [
// //               Stack(
// //                 children: [
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(8),
// //                     child: Image.network(
// //                       property['image'],
// //                       width: 80,
// //                       height: 80,
// //                       fit: BoxFit.cover,
// //                       errorBuilder: (context, error, stackTrace) => Container(
// //                         width: 80,
// //                         height: 80,
// //                         color: Colors.grey[300],
// //                         child: Icon(Icons.image_not_supported),
// //                       ),
// //                     ),
// //                   ),
// //                   if (property['isNew'] == true)
// //                     Positioned(
// //                       top: 4,
// //                       left: 4,
// //                       child: Container(
// //                         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                         decoration: BoxDecoration(
// //                           color: Colors.red[600],
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: Text(
// //                           'NEW',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 8,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //               SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       property['title'],
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w600,
// //                         fontSize: 16,
// //                       ),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     SizedBox(height: 4),
// //                     Row(
// //                       children: [
// //                         Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
// //                         SizedBox(width: 4),
// //                         Expanded(
// //                           child: Text(
// //                             property['location'],
// //                             style: TextStyle(
// //                               color: Colors.grey[600],
// //                               fontSize: 12,
// //                             ),
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     SizedBox(height: 8),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text(
// //                           '₹${property['rent']}/month',
// //                           style: TextStyle(
// //                             color: Colors.green[600],
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                           ),
// //                         ),
// //                         Container(
// //                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                           decoration: BoxDecoration(
// //                             color: Colors.blue[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Text(
// //                             property['type'],
// //                             style: TextStyle(
// //                               color: Colors.blue[700],
// //                               fontSize: 10,
// //                               fontWeight: FontWeight.w500,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBottomNavigationBar() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: Offset(0, -2),
// //           ),
// //         ],
// //       ),
// //       child: BottomNavigationBar(
// //         currentIndex: _selectedIndex,
// //         onTap: (index) {
// //           setState(() {
// //             _selectedIndex = index;
// //           });
// //         },
// //         type: BottomNavigationBarType.fixed,
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         selectedItemColor: Colors.blue[600],
// //         unselectedItemColor: Colors.grey[600],
// //         selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
// //         items: [
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.home),
// //             label: 'Home',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.search),
// //             label: 'Search',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.favorite),
// //             label: 'Favorites',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.message),
// //             label: 'Messages',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.person),
// //             label: 'Profile',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _showFilterBottomSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setModalState) {
// //             return Container(
// //               padding: EdgeInsets.all(20),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'Filters',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       IconButton(
// //                         onPressed: () => Navigator.pop(context),
// //                         icon: Icon(Icons.close),
// //                       ),
// //                     ],
// //                   ),
// //                   SizedBox(height: 20),
// //
// //                   // Location Filter
// //                   Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
// //                   SizedBox(height: 8),
// //                   Wrap(
// //                     spacing: 8,
// //                     children: locations.map((location) {
// //                       return ChoiceChip(
// //                         label: Text(location),
// //                         selected: selectedLocation == location,
// //                         onSelected: (selected) {
// //                           if (selected) {
// //                             setModalState(() {
// //                               selectedLocation = location;
// //                             });
// //                           }
// //                         },
// //                       );
// //                     }).toList(),
// //                   ),
// //
// //                   SizedBox(height: 20),
// //
// //                   // Property Type Filter
// //                   Text('Property Type', style: TextStyle(fontWeight: FontWeight.w600)),
// //                   SizedBox(height: 8),
// //                   Wrap(
// //                     spacing: 8,
// //                     children: propertyTypes.map((type) {
// //                       return ChoiceChip(
// //                         label: Text(type),
// //                         selected: selectedPropertyType == type,
// //                         onSelected: (selected) {
// //                           if (selected) {
// //                             setModalState(() {
// //                               selectedPropertyType = type;
// //                             });
// //                           }
// //                         },
// //                       );
// //                     }).toList(),
// //                   ),
// //
// //                   SizedBox(height: 20),
// //
// //                   // Budget Filter
// //                   Text('Budget', style: TextStyle(fontWeight: FontWeight.w600)),
// //                   SizedBox(height: 8),
// //                   Wrap(
// //                     spacing: 8,
// //                     children: budgets.map((budget) {
// //                       return ChoiceChip(
// //                         label: Text(budget),
// //                         selected: selectedBudget == budget,
// //                         onSelected: (selected) {
// //                           if (selected) {
// //                             setModalState(() {
// //                               selectedBudget = budget;
// //                             });
// //                           }
// //                         },
// //                       );
// //                     }).toList(),
// //                   ),
// //
// //                   SizedBox(height: 30),
// //
// //                   // Apply Button
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           // Apply filters
// //                         });
// //                         Navigator.pop(context);
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.blue[600],
// //                         padding: EdgeInsets.symmetric(vertical: 16),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         'Apply Filters',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }