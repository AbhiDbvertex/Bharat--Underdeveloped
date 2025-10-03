import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:open_filex/open_filex.dart';

import 'APIServices.dart';
import 'SocketService.dart';
import 'chatScreen.dart';
class ChatScreen extends StatefulWidget {
  final String initialReceiverId;

  const ChatScreen({Key? key, required this.initialReceiverId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String userId = "";
  String? fullName;
  List<dynamic> conversations = [];
  dynamic currentChat;
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _receiverIdController = TextEditingController();
  List<String> images = [];
  List<String> documents = [];
  List<dynamic?> onlineUsers = [];
  String receiverId = '';
  final ScrollController _detailScrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool showChatDetail = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Abhi:- ChatScreen initState called, initialReceiverId: ${widget.initialReceiverId}");
    _fetchProfileFromAPI().then((_) {
      print("Abhi:- Profile fetched, userId: $userId");
      _initSocket();
      _fetchConversations();

      if (widget.initialReceiverId.isNotEmpty) {
        setState(() {
          receiverId = widget.initialReceiverId;
          print("Abhi:- Setting receiverId: $receiverId");
        });
        _startConversation();
      }
    });
  }

  Future<void> _fetchProfileFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("Abhi:- Error: No token found, skipping profile fetch");
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: No token found, please log in again')),
          );
        });
        return;
      }

      print("Abhi:- Fetching user profile with token: $token");
      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Abhi:- Profile API response: Status=${response.statusCode}, Body=${response.body}");
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final data = body['data'];
          setState(() {
            fullName = data['full_name'] ?? 'Your Name';
            userId = data['_id']?.toString() ?? '';
          });
          print("Abhi:- Profile fetched successfully: fullName=$fullName, userId=$userId");
        } else {
          final error = body['message'] ?? 'Failed to fetch profile';
          print("Abhi:- Error fetching profile: $error");
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Failed to fetch profile: $error')),
            );
          });
        }
      } else {
        print("Abhi:- Error fetching profile: Status=${response.statusCode}, Body=${response.body}");
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Server error, profile fetch failed: Status ${response.statusCode}')),
          );
        });
      }
    } catch (e) {
      print("Abhi:- Exception in fetchProfileFromAPI: $e");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Exception while fetching profile: $e')),
        );
      });
    }
  }

  void _initSocket() {
    print('Abhi:- Initializing socket for userId: $userId');
    SocketService.connect(userId);
    SocketService.setMessageCallback((parsedMessage) {
      print('Abhi:- New message via socket: $parsedMessage');
      if (parsedMessage != null && parsedMessage['conversationId'] != null) {
        if (currentChat != null &&
            parsedMessage['conversationId'].toString() == currentChat['_id'].toString()) {
          setState(() {
            if (!messages.any((msg) => msg['_id'].toString() == parsedMessage['_id'].toString())) {
              messages.insert(0, parsedMessage);
              print('Abhi:- Received message added to UI: ${parsedMessage['message']}');
            } else {
              print('Abhi:- Message already exists in UI: ${parsedMessage['_id']}');
            }
          });
          _scrollToBottom();
        } else {
          print('Abhi:- Message from other chat: ${parsedMessage['conversationId']}');
          _fetchConversations();
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('New message in another chat: ${parsedMessage['conversationId']}')),
            );
          });
        }
      } else {
        print('Abhi:- Error: Invalid message data from socket: $parsedMessage');
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Invalid message data received from socket')),
          );
        });
      }
    });
    SocketService.listenOnlineUsers((users) {
      print('Abhi:- Online Users: $users');
      setState(() => onlineUsers = users.map((u) => u.toString()).toList());
    });
  }

  Future<void> _fetchConversations() async {
    try {
      setState(() => isLoading = true);
      print("Abhi:- Starting fetchConversations for userId: $userId");
      final convs = await ApiService.fetchConversations(userId);
      setState(() {
        conversations = convs;
        isLoading = false;
      });
      print("Abhi:- Conversations fetched successfully: ${convs.length} conversations");
      print("Abhi:- Conversations: $convs");
    } catch (e) {
      print('Abhi:- Error fetching conversations: $e');
      setState(() => isLoading = false);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch conversations: $e')),
        );
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (currentChat == null) {
      print("Abhi:- Error: currentChat is null, cannot fetch messages");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No conversation selected to fetch messages')),
        );
      });
      return;
    }
    try {
      print("Abhi:- Fetching messages for conversation: ${currentChat['_id']}");
      final msgs = await ApiService.fetchMessages(currentChat['_id'].toString());
      setState(() {
        messages = msgs.toList();
        messages.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
        print("Abhi:- Messages fetched successfully: ${messages.length} messages");
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Abhi:- Error fetching messages: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch messages: $e')),
        );
      });
    }
  }

  Future<void> _startConversation() async {
    if (receiverId.isEmpty) {
      print("Abhi:- Error: receiverId is empty");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Please enter a valid Receiver ID')),
        );
      });
      return;
    }
    if (userId.isEmpty) {
      print("Abhi:- Error: userId is empty");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User ID not available, please try again')),
        );
      });
      return;
    }
    if (receiverId == userId) {
      print("Abhi:- Error: Cannot start conversation with self, senderId=$userId, receiverId=$receiverId");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Cannot start a conversation with yourself')),
        );
      });
      return;
    }

    try {
      setState(() => isLoading = true);
      print("Abhi:- Checking for existing conversation with receiverId: $receiverId, userId: $userId");
      print("Abhi:- Current conversations: $conversations");
      final existingConv = conversations.firstWhere(
            (conv) {
          final members = conv['members'] as List?;
          if (members == null) {
            print("Abhi:- Error: Members list is null for conversation ${conv['_id']}");
            return false;
          }
          print("Abhi:- Checking conversation ${conv['_id']} members: $members");
          return members.any((m) => m['_id'].toString() == receiverId) &&
              members.any((m) => m['_id'].toString() == userId);
        },
        orElse: () => null,
      );

      if (existingConv != null) {
        print("Abhi:- Existing conversation found: ${existingConv['_id']}");
        setState(() {
          currentChat = existingConv;
          showChatDetail = true;
          isLoading = false;
          print("Abhi:- Setting showChatDetail to true for existing conversation: ${existingConv['_id']}");
        });
        await _fetchMessages();
      } else {
        print("Abhi:- No existing conversation found, starting new with receiverId: $receiverId");
        final newConv = await ApiService.startConversation(userId, receiverId);
        setState(() {
          conversations.add(newConv);
          currentChat = newConv;
          showChatDetail = true;
          isLoading = false;
          print("Abhi:- Setting showChatDetail to true for new conversation: ${newConv['_id']}");
        });
        await _fetchMessages();
      }
    } catch (e) {
      print('Abhi:- Error starting conversation: $e');
      setState(() => isLoading = false);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to start conversation: $e')),
        );
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      print("Abhi:- Picking images");
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        if (pickedFiles.length > 5) {
          print("Abhi:- Error: More than 5 images selected");
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Maximum 5 images allowed')),
            );
          });
          return;
        }
        setState(() {
          images = pickedFiles.map((file) => file.path).toList();
          print("Abhi:- Images picked successfully: $images");
        });
      } else {
        print("Abhi:- No images selected");
      }
    } catch (e) {
      print("Abhi:- Exception in pickImages: $e");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Exception while picking images: $e')),
        );
      });
    }
  }

  Future<void> _pickDocuments() async {
    try {
      print("Abhi:- Picking documents");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.length <= 5) {
        setState(() {
          documents = result.files.map((file) => file.path!).toList();
          print("Abhi:- Documents picked successfully: $documents");
        });
      } else if (result != null && result.files.length > 5) {
        print("Abhi:- Error: More than 5 documents selected");
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Maximum 5 documents allowed')),
          );
        });
      } else {
        print("Abhi:- No documents selected");
      }
    } catch (e) {
      print("Abhi:- Exception in pickDocuments: $e");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Exception while picking documents: $e')),
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && images.isEmpty && documents.isEmpty) {
      print("Abhi:- Error: No message, images, or documents to send");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No message, images, or documents to send')),
      );
      return;
    }

    dynamic receiverId;
    /*if (currentChat['members'][0] is String) {
      print("Abhi:- Members are IDs, finding receiverId as string");
      receiverId = currentChat['members'].firstWhere(
            (m) => m != userId,
        orElse: () => null,
      );
    } else {
      print("Abhi:- Members are maps, finding receiverId");
      final matchingMember = currentChat['members'].firstWhere(
            (m) => m['_id'].toString() != userId,
        orElse: () => {}, // Fixed: Empty map return
      );
      receiverId = matchingMember['_id'];
    }*/
    // if (currentChat['members'][0] is String) {
    //   print("Abhi:- Members are IDs, finding receiverId as string");
    //   receiverId = currentChat['members'].firstWhere(
    //         (m) => m != "68d388ada1131cc2e4be05ff",
    //     orElse: () => "68d388ada1131cc2e4be05ff", // ✅ return empty string instead of null
    //   );
    //   if (receiverId.isEmpty) receiverId = null; // ✅ handle invalid case
    // } else {
    //   print("Abhi:- Members are maps, finding receiverId");
    //   final matchingMember = currentChat['members'].firstWhere(
    //         (m) => m['_id'].toString() != "68d388ada1131cc2e4be05ff",
    //     orElse: () => {}, // ✅ empty map return
    //   );
    //   receiverId = matchingMember.isNotEmpty ? matchingMember['_id'] : null;
    // }
    if (currentChat['members'][0] is String) {
      print("Abhi:- Members are IDs, finding receiverId as string");
      receiverId = currentChat['members'].firstWhere(
            (m) => m != userId,  // <--- yahan userId daal
        orElse: () => null,   // <--- null kar, hardcoded nahi
      );
    } else {
      print("Abhi:- Members are maps, finding receiverId");
      final matchingMember = currentChat['members'].firstWhere(
            (m) => m['_id'].toString() != userId,  // <--- yahan userId daal
        orElse: () => {},
      );
      receiverId = matchingMember.isNotEmpty ? matchingMember['_id'].toString() : null;
    }
    if (receiverId == null) {
      print("Abhi:- Error: Invalid receiver ID");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Invalid receiver ID')),
      );
      return;
    }

    try {
      dynamic newMsg;
      if (images.isNotEmpty) {
        newMsg = await ApiService.sendImageMessage(
          senderId: userId,
          receiverId: receiverId.toString(),
          conversationId: currentChat['_id'].toString(),
          imagePaths: images,
          message: _messageController.text.isNotEmpty ? _messageController.text : null,
        );
        print('Abhi:- Image message sent successfully: $newMsg');
      } else if (documents.isNotEmpty) {
        newMsg = await ApiService.sendDocumentMessage(
          senderId: userId,
          receiverId: receiverId.toString(),
          conversationId: currentChat['_id'].toString(),
          documentPaths: documents,
          message: _messageController.text.isNotEmpty ? _messageController.text : null,
        );
        print('Abhi:- Document message sent successfully: $newMsg');
      } else {
        final msgData = {
          'senderId': userId,
          'receiverId': receiverId.toString(),
          'conversationId': currentChat['_id'].toString(),
          'message': _messageController.text,
          'messageType': 'text',
        };
        newMsg = await ApiService.sendTextMessage(msgData);
        print('Abhi:- Text message sent successfully: $newMsg');
      }

      SocketService.sendMessage(newMsg);
      setState(() {
        if (!messages.any((msg) => msg['_id'].toString() == newMsg['_id'].toString())) {
          messages.insert(0, newMsg);
          print('Abhi:- Message added to UI: ${newMsg['_id']}');
        } else {
          print('Abhi:- Message already exists in UI: ${newMsg['_id']}');
        }
        _messageController.clear();
        images.clear();
        documents.clear();
        print('Abhi:- Message fields cleared after sending');
      });
      _scrollToBottom();
    } catch (e) {
      print('Abhi:- Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    const maxRetries = 5;
    int retryCount = 0;

    void attemptScroll() {
      if (_detailScrollController.hasClients) {
        _detailScrollController.jumpTo(0);
        print("Abhi:- Scrolled to bottom of messages");
      } else if (retryCount < maxRetries) {
        print("Abhi:- Scroll controller not ready, retrying (${retryCount + 1}/$maxRetries)");
        retryCount++;
        Future.delayed(Duration(milliseconds: 100), attemptScroll);
      } else {
        print("Abhi:- Scroll controller failed to initialize after $maxRetries retries");
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Failed to scroll to bottom of messages')),
          );
        });
      }
    }

    attemptScroll();
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
        return "Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      print("Abhi:- Error formatting time: $e");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Exception while formatting time: $e')),
        );
      });
      return "Invalid time";
    }
  }

  @override
  void dispose() {
    print("Abhi:- Disposing ChatScreen");
    SocketService.removeMessageCallback();
    SocketService.disconnect();
    _detailScrollController.dispose();
    _messageController.dispose();
    _receiverIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:- Building ChatScreen, showChatDetail: $showChatDetail, currentChat: ${currentChat?['_id'] ?? 'null'}");
    if (isLoading) {
      print("Abhi:- Showing loading indicator");
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (showChatDetail && currentChat != null) {
      print("Abhi:- Rendering ChatDetailScreen for conversation: ${currentChat['_id']}");
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
            print("Abhi:- Back from ChatDetailScreen, resetting state");
          });
        },
        onSendMessage: _sendMessage,
        onPickImages: _pickImages,
        onPickDocuments: _pickDocuments,
        formatTime: _formatTime,
      );
    }
    print("Abhi:- Rendering ChatListScreen");
    return ChatListScreen(
      conversations: conversations,
      userId: userId,
      onlineUsers: onlineUsers,
      receiverIdController: _receiverIdController,
      onReceiverIdChanged: (val) {
        receiverId = val;
        print("Abhi:- Receiver ID changed: $val");
      },
      onStartConversation: () {
        print("Abhi:- Start conversation triggered from ChatListScreen");
        _startConversation();
      },
      onConversationTap: (conv) {
        setState(() {
          currentChat = conv;
          showChatDetail = true;
          print("Abhi:- Tapped conversation, setting showChatDetail to true: ${conv['_id']}");
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
    print("Abhi:- Building ChatListScreen, conversations count: ${widget.conversations.length}");
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
                    onPressed: () {
                      print("Abhi:- Start conversation button pressed in ChatListScreen");
                      widget.onStartConversation();
                    },
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
                final members = (conv['members'] as List?) ?? [];
                dynamic otherUser;
                try {
                  otherUser = members.firstWhere(
                        (m) => m['_id'].toString() != widget.userId,
                    orElse: () => {'full_name': 'Unknown', '_id': '', 'profile_pic': null},
                  );
                  print("Abhi:- Rendering conversation: ${conv['_id']}, otherUser: ${otherUser['full_name']}, otherUserId: ${otherUser['_id']}");
                } catch (e) {
                  print("Abhi:- Error finding other user in ChatListScreen for conversation ${conv['_id']}: $e");
                  otherUser = {'full_name': 'Unknown', '_id': '', 'profile_pic': null};
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    print("Abhi:- get exception with post frame callback $e");
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Error: Failed to load chat user in list: $e')),
                    // );
                  });
                }
                final isOnline = widget.onlineUsers.contains(otherUser['_id'].toString());

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: otherUser['profile_pic'] != null
                              ? NetworkImage(otherUser['profile_pic'])
                              : null,
                          child: otherUser['profile_pic'] == null
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
                      '${otherUser['full_name'] ?? 'Unknown'}',
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
                    onTap: () {
                      print("Abhi:- Conversation tapped: ${conv['_id']}");
                      widget.onConversationTap(conv);
                    },
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
    print("Abhi:- Disposing ChatListScreen");
    _listScrollController.dispose();
    super.dispose();
  }
}