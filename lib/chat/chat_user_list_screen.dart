// UserListScreen: Shows list of conversations (user list)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'APIServices.dart';
import 'SocketService.dart';
import 'chatScreen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final String userId = "68ac07f700315e754a037e56";
  List<dynamic> conversations = [];
  List<dynamic> onlineUsers = [];
  final TextEditingController _receiverIdController = TextEditingController();
  String receiverId = '';
  final ScrollController _listScrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchConversations();
    _listScrollController.addListener(_scrollListener);
  }

  void _initSocket() {
    print('Initializing socket for userId: $userId');
    SocketService.connect(userId);
    SocketService.setMessageCallback((parsedMessage) {
      print('New message via socket: $parsedMessage');
      if (parsedMessage != null && parsedMessage['conversationId'] != null) {
        // Refresh conversations if new message in another chat
        _fetchConversations(refresh: true);
        print('ℹ️ Message from other chat: ${parsedMessage['conversationId']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New message in another chat!')),
        );
      } else {
        print('❌ Invalid message data: $parsedMessage');
      }
    });
    SocketService.listenOnlineUsers((users) {
      print('Online users: $users');
      setState(() => onlineUsers = users);
    });
  }

  Future<void> _fetchConversations({bool refresh = false}) async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      // Assume ApiService supports pagination: fetchConversations(userId, page, limit)
      final convs = await ApiService.fetchConversations(userId, /*_currentPage, 10*/); // Limit 10 per page
      setState(() {
        if (refresh) conversations.clear();
        conversations.addAll(convs);
        if (convs.length < 10) _hasMore = false;
      });
    } catch (e) {
      print('Error fetching conversations: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversations fetch nahi hui: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollListener() {
    if (_listScrollController.offset >= _listScrollController.position.maxScrollExtent &&
        !_listScrollController.position.outOfRange) {
      _currentPage++;
      _fetchConversations();
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
        receiverId = '';
        _receiverIdController.clear();
      });
      // Navigate to chat detail
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ChatDetailScreen(currentChat: newConv, userId: userId),
      //   ),
      // );
    } catch (e) {
      print('Error starting conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
    }
  }

  @override
  void dispose() {
    SocketService.removeMessageCallback();
    SocketService.disconnect();
    _listScrollController.dispose();
    _receiverIdController.dispose();
    super.dispose();
  }

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
          // Start New Chat Section
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
                      controller: _receiverIdController,
                      onChanged: (val) => receiverId = val,
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
                    onPressed: _startConversation,
                    icon: Icon(Icons.add_comment, color: Colors.white),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),

          // Chat List with pagination
          Expanded(
            child: ListView.builder(
              controller: _listScrollController,
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length + (_isLoading ? 1 : 0),
              itemBuilder: (ctx, idx) {
                if (idx == conversations.length) {
                  return Center(child: CircularProgressIndicator());
                }
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
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ChatDetailScreen(currentChat: conv, userId: userId),
                      //   ),
                      // );
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
}