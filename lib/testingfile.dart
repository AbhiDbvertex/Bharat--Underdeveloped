// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as socket_io;
// import 'package:file_picker/file_picker.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chat App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const ChatScreen(),
//     );
//   }
// }
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final String userId = "68abec670fa4a01b9b742ddf"; // TODO: Auth context se lo
//   final String apiUrl = "https://api.thebharatworks.com";
//   late socket_io.Socket socket;
//   List<dynamic> conversations = [];
//   dynamic currentChat;
//   List<dynamic> messages = [];
//   String message = "";
//   List<File> images = [];
//   List<String> onlineUsers = [];
//   String receiverId = "";
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _receiverIdController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _connectSocket();
//     _fetchConversations();
//   }
//
//   // Socket.IO Connection
//   void _connectSocket() {
//     socket = socket_io.io(apiUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//
//     socket.connect();
//     socket.onConnect((_) {
//       print("Socket connected");
//       socket.emit("addUser", userId);
//     });
//
//     socket.on("getUsers", (users) {
//       setState(() {
//         onlineUsers = List<String>.from(users);
//       });
//     });
//
//     socket.on("getMessage", (data) {
//       if (currentChat != null && data['conversationId'] == currentChat['_id']) {
//         setState(() {
//           messages.add(data);
//         });
//         _scrollToBottom();
//       }
//     });
//
//     socket.onDisconnect((_) => print("Socket disconnected"));
//   }
//
//   // Fetch Conversations
//   Future<void> _fetchConversations() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$apiUrl/api/chat/conversations/$userId'),
//         headers: {"Authorization": "Bearer ${await _getToken()}"},
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           conversations = jsonDecode(response.body)['conversations'] ?? [];
//         });
//       }
//     } catch (err) {
//       print("Failed to fetch conversations: $err");
//     }
//   }
//
//   // Fetch Messages
//   Future<void> _fetchMessages() async {
//     if (currentChat == null) return;
//     try {
//       final response = await http.get(
//         Uri.parse('$apiUrl/api/chat/messages/${currentChat['_id']}'),
//         headers: {"Authorization": "Bearer ${await _getToken()}"},
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           messages = jsonDecode(response.body)['messages'] ?? [];
//         });
//         _scrollToBottom();
//       }
//     } catch (err) {
//       print("Failed to fetch messages: $err");
//     }
//   }
//
//   // Start New Conversation
//   Future<void> _startConversation() async {
//     if (receiverId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a receiver ID")),
//       );
//       return;
//     }
//     try {
//       final response = await http.post(
//         Uri.parse('$apiUrl/api/chat/conversations'),
//         headers: {
//           "Authorization": "Bearer ${await _getToken()}",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({"senderId": userId, "receiverId": receiverId}),
//       );
//       if (response.statusCode == 200) {
//         final newConversation = jsonDecode(response.body)['conversation'];
//         setState(() {
//           conversations.add(newConversation);
//           currentChat = newConversation;
//           receiverId = "";
//           _receiverIdController.clear();
//         });
//         _fetchMessages();
//       }
//     } catch (err) {
//       print("Failed to start conversation: $err");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to start conversation")),
//       );
//     }
//   }
//
//   // Pick Images
//   Future<void> _pickImages() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       allowMultiple: true,
//     );
//     if (result != null && result.files.isNotEmpty) {
//       if (result.files.length > 5) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Maximum 5 images allowed")),
//         );
//         return;
//       }
//       setState(() {
//         images = result.files.map((file) => File(file.path!)).toList();
//       });
//     }
//   }
//
//   // Send Message
//   Future<void> _sendMessage() async {
//     if (message.trim().isEmpty && images.isEmpty) return;
//     String receiverId = "68ac1a6900315e754a038c80"; // TODO: Conversation se lo
//     if (receiverId.isEmpty || currentChat == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Receiver ID or conversation not found")),
//       );
//       return;
//     }
//
//     try {
//       dynamic newMsg;
//       if (images.isNotEmpty) {
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('$apiUrl/api/chat/messages'),
//         );
//         request.headers['Authorization'] = "Bearer ${await _getToken()}";
//         for (var image in images) {
//           request.files.add(await http.MultipartFile.fromPath('images', image.path));
//         }
//         request.fields['senderId'] = userId;
//         request.fields['receiverId'] = receiverId;
//         request.fields['conversationId'] = currentChat['_id'];
//         request.fields['messageType'] = "image";
//         if (message.trim().isNotEmpty) request.fields['message'] = message;
//
//         final response = await request.send();
//         final respStr = await response.stream.bytesToString();
//         if (response.statusCode == 200) {
//           newMsg = jsonDecode(respStr)['newMessage'];
//         }
//       } else {
//         newMsg = {
//           "senderId": userId,
//           "receiverId": receiverId,
//           "conversationId": currentChat['_id'],
//           "message": message,
//           "messageType": "text",
//         };
//         final response = await http.post(
//           Uri.parse('$apiUrl/api/chat/messages'),
//           headers: {
//             "Authorization": "Bearer ${await _getToken()}",
//             "Content-Type": "application/json",
//           },
//           body: jsonEncode(newMsg),
//         );
//         if (response.statusCode == 200) {
//           newMsg = jsonDecode(response.body)['newMessage'];
//         }
//       }
//
//       socket.emit("sendMessage", newMsg);
//       setState(() {
//         messages.add(newMsg);
//         message = "";
//         images = [];
//         _messageController.clear();
//       });
//       _scrollToBottom();
//     } catch (err) {
//       print("Failed to send message: $err");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to send message")),
//       );
//     }
//   }
//
//   // Scroll to Bottom
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   // Get Token (Dummy Implementation)
//   Future<String> _getToken() async {
//     return "your_token_here"; // TODO: Auth se token lo
//   }
//
//   @override
//   void dispose() {
//     socket.disconnect();
//     _scrollController.dispose();
//     _messageController.dispose();
//     _receiverIdController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat App")),
//       body: Row(
//         children: [
//           // Sidebar (Conversations)
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.3,
//             child: Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Text("Chats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _receiverIdController,
//                           decoration: const InputDecoration(hintText: "Enter receiver ID"),
//                           onChanged: (value) => receiverId = value,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: _startConversation,
//                         child: const Text("Start Chat"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) {
//                       final conv = conversations[index];
//                       final otherUser = conv['members'].firstWhere((m) => m['_id'] != userId);
//                       return ListTile(
//                         title: Text(otherUser['name'] ?? "User"),
//                         subtitle: Text(conv['lastMessage'] ?? ""),
//                         selected: currentChat != null && conv['_id'] == currentChat['_id'],
//                         onTap: () {
//                           setState(() {
//                             currentChat = conv;
//                           });
//                           _fetchMessages();
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Chat Box
//           Expanded(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final msg = messages[index];
//                       final isMe = msg['senderId'] == userId;
//                       return Align(
//                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.green[100] : Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (msg['messageType'] == "image" && msg['image'] != null)
//                                 ...msg['image'].map<Widget>((imgUrl) => Image.network(
//                                   '$apiUrl/$imgUrl',
//                                   width: 200,
//                                   height: 200,
//                                   fit: BoxFit.cover,
//                                 ))
//                                     .toList(),
//                               if (msg['message'] != null && msg['message'].isNotEmpty)
//                                 Text(msg['message']),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (currentChat != null)
//                   Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _messageController,
//                             decoration: const InputDecoration(hintText: "Type a message..."),
//                             onChanged: (value) => message = value,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         IconButton(
//                           icon: const Icon(Icons.image),
//                           onPressed: _pickImages,
//                         ),
//                         ElevatedButton(
//                           onPressed: _sendMessage,
//                           child: const Text("Send"),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String userId = "68abec670fa4a01b9b742ddf"; // TODO: Auth context se lo
  final String apiUrl = "https://api.thebharatworks.com"; // Port add karo agar zaruri ho (e.g., :5000)
  late socket_io.Socket socket;
  List<dynamic> conversations = [];
  dynamic currentChat;
  List<dynamic> messages = [];
  String messageText = "";
  List<File> images = [];
  List<String> onlineUsers = [];
  String receiverIdInput = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _receiverIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _fetchConversations();
  }

  // Socket.IO Connection
  void _connectSocket() {
    socket = socket_io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true, // Enable auto-reconnect
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket.connect();
    socket.onConnect((_) {
      print("Socket connected: ${socket.id}");
      socket.emit("addUser", userId);
    });

    socket.on("getUsers", (users) {
      print("Online users: $users");
      setState(() {
        onlineUsers = List<String>.from(users);
      });
    });

    socket.on("getMessage", (data) {
      print("Received message via socket: $data");
      setState(() {
        // Update messages if current chat matches
        if (currentChat != null && data['conversationId'] == currentChat['_id']) {
          messages.add(data);
        }
        // Update conversations list to reflect last message
        final convIndex = conversations.indexWhere((c) => c['_id'] == data['conversationId']);
        if (convIndex != -1) {
          conversations[convIndex]['lastMessage'] = data['message'] ?? "Image sent";
        }
      });
      _scrollToBottom();
      // Refresh conversations to update last message
      _fetchConversations();
    });

    socket.onConnectError((err) {
      print("Socket connect error: $err");
    });

    socket.onError((err) {
      print("Socket error: $err");
    });

    socket.onDisconnect((_) {
      print("Socket disconnected");
    });
  }

  // Fetch Conversations
  Future<void> _fetchConversations() async {
    try {
      final token = await _getToken();
      print("Fetching conversations with token: ${token.substring(0, 10)}...");
      final response = await http.get(
        Uri.parse('$apiUrl/api/chat/conversations/$userId'),
        headers: {"Authorization": "Bearer $token"},
      );
      print("Conversations response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          conversations = jsonDecode(response.body)['conversations'] ?? [];
        });
      } else {
        throw Exception("Failed to fetch conversations: ${response.statusCode}");
      }
    } catch (err) {
      print("Failed to fetch conversations: $err");
    }
  }

  // Get receiver ID from current chat
  String _getReceiverId() {
    if (currentChat == null || currentChat['members'] == null) return "";
    try {
      final members = currentChat['members'] as List<dynamic>;
      final otherUser = members.firstWhere((m) => m['_id'] != userId);
      return otherUser['_id'] as String;
    } catch (e) {
      print("Error getting receiver ID: $e");
      return "";
    }
  }

  // Fetch Messages
  Future<void> _fetchMessages() async {
    if (currentChat == null) {
      print("No current chat to fetch messages");
      return;
    }
    print("Fetching messages for chat: ${currentChat['_id']}");
    setState(() {
      messages = []; // Clear messages immediately
    });
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$apiUrl/api/chat/messages/${currentChat['_id']}'),
        headers: {"Authorization": "Bearer $token"},
      );
      print("Messages response: ${response.statusCode} - ${response.body.substring(0, 200)}...");
      if (response.statusCode == 200) {
        final fetchedMessages = jsonDecode(response.body)['messages'] ?? [];
        setState(() {
          messages = List<dynamic>.from(fetchedMessages);
        });
        _scrollToBottom();
      } else {
        print("Failed to fetch messages: Status ${response.statusCode}");
        setState(() {
          messages = [];
        });
      }
    } catch (err) {
      print("Failed to fetch messages: $err");
      setState(() {
        messages = [];
      });
    }
  }

  // Start New Conversation
  Future<void> _startConversation() async {
    if (receiverIdInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a receiver ID")),
      );
      return;
    }
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$apiUrl/api/chat/conversations'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"senderId": userId, "receiverId": receiverIdInput}),
      );
      print("Start conversation response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newConversation = jsonDecode(response.body)['conversation'];
        setState(() {
          conversations.add(newConversation);
          currentChat = newConversation;
          receiverIdInput = "";
          _receiverIdController.clear();
          messages = [];
        });
        await _fetchMessages();
      } else {
        throw Exception("Unexpected status: ${response.statusCode}");
      }
    } catch (err) {
      print("Failed to start conversation: $err");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to start conversation")),
      );
    }
  }

  // Pick Images
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      if (result.files.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maximum 5 images allowed")),
        );
        return;
      }
      setState(() {
        images = result.files.map((file) => File(file.path!)).toList();
      });
    }
  }

  // Send Message
  Future<void> _sendMessage() async {
    if (messageText.trim().isEmpty && images.isEmpty) return;
    final receiverId = _getReceiverId();
    if (receiverId.isEmpty || currentChat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receiver ID or conversation not found")),
      );
      return;
    }
    print("Sending message to receiver: $receiverId");
    try {
      dynamic newMsg;
      final token = await _getToken();
      if (images.isNotEmpty) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$apiUrl/api/chat/messages'),
        );
        request.headers['Authorization'] = "Bearer $token";
        for (var image in images) {
          request.files.add(await http.MultipartFile.fromPath('images', image.path));
        }
        request.fields['senderId'] = userId;
        request.fields['receiverId'] = receiverId;
        request.fields['conversationId'] = currentChat['_id'];
        request.fields['messageType'] = "image";
        if (messageText.trim().isNotEmpty) request.fields['message'] = messageText;

        final response = await request.send();
        final respStr = await response.stream.bytesToString();
        print("Image send response: ${response.statusCode} - $respStr");
        if (response.statusCode == 200 || response.statusCode == 201) {
          newMsg = jsonDecode(respStr)['newMessage'];
        } else {
          throw Exception("Upload failed: ${response.statusCode}");
        }
      } else {
        newMsg = {
          "senderId": userId,
          "receiverId": receiverId,
          "conversationId": currentChat['_id'],
          "message": messageText,
          "messageType": "text",
        };
        final response = await http.post(
          Uri.parse('$apiUrl/api/chat/messages'),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(newMsg),
        );
        print("Text send response: ${response.statusCode} - ${response.body}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          newMsg = jsonDecode(response.body)['newMessage'];
        } else {
          throw Exception("Send failed: ${response.statusCode}");
        }
      }

      socket.emit("sendMessage", newMsg);
      setState(() {
        messages.add(newMsg);
        messageText = "";
        images = [];
        _messageController.clear();
      });
      _scrollToBottom();
      // Refresh conversations to update last message
      _fetchConversations();
    } catch (err) {
      print("Failed to send message: $err");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    }
  }

  // Scroll to Bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Get Token (Dummy Implementation)
  Future<String> _getToken() async {
    return "your_token_here"; // TODO: Auth se real token lo
  }

  @override
  void dispose() {
    socket.disconnect();
    _scrollController.dispose();
    _messageController.dispose();
    _receiverIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat App")),
      body: Row(
        children: [
          // Sidebar (Conversations)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Chats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _receiverIdController,
                          decoration: const InputDecoration(hintText: "Enter receiver ID"),
                          onChanged: (value) {
                            setState(() {
                              receiverIdInput = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _startConversation,
                        child: const Text("Start Chat"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      dynamic otherUser;
                      try {
                        otherUser = conv['members'].firstWhere((m) => m['_id'] != userId);
                      } catch (e) {
                        otherUser = {'name': 'Unknown User'};
                      }
                      return ListTile(
                        title: Text(otherUser['name'] ?? "User"),
                        subtitle: Text(conv['lastMessage'] ?? ""),
                        selected: currentChat != null && conv['_id'] == currentChat['_id'],
                        onTap: () {
                          print("Switching to chat: ${conv['_id']}");
                          setState(() {
                            currentChat = conv;
                            messages = [];
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fetchMessages();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Chat Box
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['senderId'] == userId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[100] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg['messageType'] == "image" && (msg['image'] != null) && (msg['image'] is List) && (msg['image'] as List).isNotEmpty)
                                ...(msg['image'] as List).map<Widget>((imgUrl) {
                                  if (imgUrl is String) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Image.network(
                                        '$apiUrl/$imgUrl',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Text("Image load failed");
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }).toList(),
                              if (msg['message'] != null && (msg['message'] as String).isNotEmpty)
                                Text(msg['message'] as String),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (currentChat != null)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(hintText: "Type a message..."),
                            onChanged: (value) {
                              setState(() {
                                messageText = value;
                              });
                            },
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: _pickImages,
                        ),
                        ElevatedButton(
                          onPressed: _sendMessage,
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("Select a chat to start messaging")),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}