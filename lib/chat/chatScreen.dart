
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'APIServices.dart';
import 'SocketService.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
// 68ac07f700315e754a037e56
// final receiverId = "68abeca08908c84c7c3769ea"; // TODO: Dynamically set
class _ChatScreenState extends State<ChatScreen> {
  final String userId = "68ac07f700315e754a037e56"; // TODO: Auth se le
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
    return Scaffold(
      body: Row(
        children: [
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
                          controller: _receiverIdController,
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
                    key: ValueKey(conversations.length),
                    itemCount: conversations.length,
                    itemBuilder: (ctx, idx) {
                      final conv = conversations[idx];
                      final members = (conv['members'] as List);
                      final otherUser = members.firstWhere(
                            (m) => m['_id'] != userId,
                        orElse: () => {'name': 'Unknown', '_id': ''},
                      );

                      return ListTile(
                        title: Text(otherUser['name'] ?? 'Unknown'),
                        subtitle: Text(conv['lastMessage'] ?? ''),
                        onTap: () {
                          setState(() => currentChat = conv);
                          _fetchMessages();
                        },
                        selected: currentChat?['_id'] == conv['_id'],
                        trailing: onlineUsers.contains(otherUser['_id'])
                            ? Icon(Icons.circle, color: Colors.green, size: 12)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                if (currentChat != null)
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: _fetchMessages,
                        tooltip: 'Refresh Messages',
                      ),
                    ),
                  ),
                Expanded(
                  child: currentChat == null
                      ? Center(child: Text('Select a conversation'))
                      : ListView.builder(
                    key: ValueKey(messages.length),
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
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (msg['messageType'] == 'image' && msg['image'] != null)
                                ...msg['image'].map<Widget>((imgUrl) => Image.network(
                                  'https://api.thebharatworks.com/$imgUrl',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text('Image load failed'),
                                )),
                              if (msg['messageType'] == 'document' && msg['document'] != null)
                                ...msg['document'].map<Widget>((docUrl) => ListTile(
                                  title: Text('Document'),
                                  subtitle: Text(docUrl.split('/').last),
                                  onTap: () {
                                    print('Open document: $docUrl');
                                    // TODO: Add url_launcher
                                  },
                                )),
                              if (msg['message'] != null && msg['message'].isNotEmpty)
                                Text(msg['message']),
                              Text(
                                DateTime.parse(msg['createdAt']).toLocal().toString().substring(0, 16),
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
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
                            controller: _messageController,
                            decoration: InputDecoration(hintText: 'Message type karo...'),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: _pickImages,
                          icon: Icon(Icons.image),
                        ),
                        IconButton(
                          onPressed: _pickDocuments,
                          icon: Icon(Icons.attach_file),
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
                // Text("")
                if (images.isNotEmpty || documents.isNotEmpty)
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length + documents.length,
                      itemBuilder: (context, index) {
                        if (index < images.length) {
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: Image.file(
                              File(images[index]),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          final docIndex = index - images.length;
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(documents[docIndex].split('/').last),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'APIServices.dart';
// import 'SocketService.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
// // 68ac07f700315e754a037e56
// // final receiverId = "68abeca08908c84c7c3769ea"; // TODO: Dynamically set
// class _ChatScreenState extends State<ChatScreen> {
//   final String userId = "68ac07f700315e754a037e56"; // TODO: Auth se le
//   List<dynamic> conversations = [];
//   dynamic currentChat;
//   List<dynamic> messages = [];
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _receiverIdController = TextEditingController();
//   List<String> images = [];
//   List<String> documents = [];
//   List<dynamic> onlineUsers = [];
//   String receiverId = '';
//   final ScrollController _scrollController = ScrollController();
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _initSocket();
//     _fetchConversations();
//   }
//
//   void _initSocket() {
//     print('Initializing socket for userId: $userId');
//     SocketService.connect(userId);
//     SocketService.setMessageCallback((parsedMessage) {
//       print('New message via socket: $parsedMessage');
//       if (parsedMessage != null && parsedMessage['conversationId'] != null) {
//         if (currentChat != null && parsedMessage['conversationId'] == currentChat['_id']) {
//           setState(() {
//             if (!messages.any((msg) => msg['_id'] == parsedMessage['_id'])) {
//               messages.add(parsedMessage);
//             }
//           });
//           _scrollToBottom();
//           print('✅ Received message added to UI: ${parsedMessage['message']}');
//         } else {
//           _fetchConversations();
//           print('ℹ️ Message from other chat: ${parsedMessage['conversationId']}');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('New message in another chat!')),
//           );
//         }
//       } else {
//         print('❌ Invalid message data: $parsedMessage');
//       }
//     });
//     SocketService.listenOnlineUsers((users) {
//       print('Online users: $users');
//       setState(() => onlineUsers = users);
//     });
//   }
//
//   Future<void> _fetchConversations() async {
//     try {
//       final convs = await ApiService.fetchConversations(userId);
//       setState(() => conversations = convs);
//     } catch (e) {
//       print('Error fetching conversations: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversations fetch nahi hui: $e')));
//     }
//   }
//
//   Future<void> _fetchMessages() async {
//     if (currentChat == null) return;
//     try {
//       final msgs = await ApiService.fetchMessages(currentChat['_id']);
//       setState(() {
//         messages = msgs.where((msg) => !messages.any((m) => m['_id'] == msg['_id'])).toList() + messages;
//       });
//       _scrollToBottom();
//     } catch (e) {
//       print('Error fetching messages: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Messages fetch nahi hui: $e')));
//     }
//   }
//
//   Future<void> _startConversation() async {
//     if (receiverId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receiver ID daalo!')));
//       return;
//     }
//     try {
//       final newConv = await ApiService.startConversation(userId, receiverId);
//       setState(() {
//         conversations.add(newConv);
//         currentChat = newConv;
//         receiverId = '';
//         _receiverIdController.clear();
//       });
//       _fetchMessages();
//     } catch (e) {
//       print('Error starting conversation: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
//     }
//   }
//
//   Future<void> _pickImages() async {
//     final List<XFile>? pickedFiles = await _picker.pickMultiImage();
//     if (pickedFiles != null) {
//       if (pickedFiles.length > 5) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Maximum 5 images allowed!')),
//         );
//         return;
//       }
//       setState(() {
//         images = pickedFiles.map((file) => file.path).toList();
//       });
//     }
//   }
//
//   Future<void> _pickDocuments() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx'],
//     );
//     if (result != null && result.files.length <= 5) {
//       setState(() {
//         documents = result.files.map((file) => file.path!).toList();
//       });
//     } else if (result != null && result.files.length > 5) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Maximum 5 documents allowed!')),
//       );
//     }
//   }
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.isEmpty && images.isEmpty && documents.isEmpty) {
//       print('Abhi:- No message, images, or documents to send.');
//       return;
//     }
//     final receiverId = currentChat['members']
//         ?.firstWhere((m) => m['_id'] != userId, orElse: () => null)?['_id'];
//     if (receiverId == null || currentChat == null) {
//       print('Abhi:- Current chat or receiverId is null, cannot send message.');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle chat select karo!')));
//       return;
//     }
//
//     try {
//       print('Abhi:- Attempting to send message. Message: ${_messageController.text}, Images: $images, Documents: $documents');
//       dynamic newMsg;
//       if (images.isNotEmpty) {
//         newMsg = await ApiService.sendImageMessage(
//           senderId: userId,
//           receiverId: receiverId,
//           conversationId: currentChat['_id'],
//           imagePaths: images,
//           message: _messageController.text.isNotEmpty ? _messageController.text : null,
//         );
//         print('Abhi:- Image message sent successfully: $newMsg');
//       } else if (documents.isNotEmpty) {
//         newMsg = await ApiService.sendDocumentMessage(
//           senderId: userId,
//           receiverId: receiverId,
//           conversationId: currentChat['_id'],
//           documentPaths: documents,
//           message: _messageController.text.isNotEmpty ? _messageController.text : null,
//         );
//         print('Abhi:- Document message sent successfully: $newMsg');
//       } else {
//         final msgData = {
//           'senderId': userId,
//           'receiverId': receiverId,
//           'conversationId': currentChat['_id'],
//           'message': _messageController.text,
//           'messageType': 'text',
//         };
//         newMsg = await ApiService.sendTextMessage(msgData);
//         print('Abhi:- Text message sent successfully: $newMsg');
//       }
//
//       print('Abhi:- Emitting message via socket: $newMsg');
//       SocketService.sendMessage(newMsg);
//       setState(() {
//         if (!messages.any((msg) => msg['_id'] == newMsg['_id'])) {
//           messages.add(newMsg);
//         }
//         _messageController.clear();
//         images.clear();
//         documents.clear();
//         print('Abhi:- Message added to UI and fields cleared.');
//       });
//       _scrollToBottom();
//     } catch (e) {
//       print('Abhi:- Error sending message: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
//     }
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     SocketService.removeMessageCallback();
//     SocketService.disconnect();
//     _scrollController.dispose();
//     _messageController.dispose();
//     _receiverIdController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: TextField(
//                           controller: _receiverIdController,
//                           onChanged: (val) => receiverId = val,
//                           decoration: InputDecoration(hintText: 'Receiver ID daalo'),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         flex: 1,
//                         child: ElevatedButton(
//                           onPressed: _startConversation,
//                           child: Text('Start Chat'),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(0, 48),
//                             padding: EdgeInsets.symmetric(horizontal: 10),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     key: ValueKey(conversations.length),
//                     itemCount: conversations.length,
//                     itemBuilder: (ctx, idx) {
//                       final conv = conversations[idx];
//                       final members = (conv['members'] as List);
//                       final otherUser = members.firstWhere(
//                             (m) => m['_id'] != userId,
//                         orElse: () => {'name': 'Unknown', '_id': ''},
//                       );
//
//                       return ListTile(
//                         title: Text(otherUser['name'] ?? 'Unknown'),
//                         subtitle: Text(conv['lastMessage'] ?? ''),
//                         onTap: () {
//                           setState(() => currentChat = conv);
//                           _fetchMessages();
//                         },
//                         selected: currentChat?['_id'] == conv['_id'],
//                         trailing: onlineUsers.contains(otherUser['_id'])
//                             ? Icon(Icons.circle, color: Colors.green, size: 12)
//                             : null,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: Column(
//               children: [
//                 if (currentChat != null)
//                   Padding(
//                     padding: EdgeInsets.all(10),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: IconButton(
//                         icon: Icon(Icons.refresh),
//                         onPressed: _fetchMessages,
//                         tooltip: 'Refresh Messages',
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   child: currentChat == null
//                       ? Center(child: Text('Select a conversation'))
//                       : ListView.builder(
//                     key: ValueKey(messages.length),
//                     controller: _scrollController,
//                     itemCount: messages.length,
//                     itemBuilder: (ctx, idx) {
//                       final msg = messages[idx];
//                       final isMe = msg['senderId'] == userId;
//                       return Align(
//                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.green[100] : Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                             children: [
//                               if (msg['messageType'] == 'image' && msg['image'] != null)
//                                 ...msg['image'].map<Widget>((imgUrl) => Image.network(
//                                   'https://api.thebharatworks.com/$imgUrl',
//                                   width: 200,
//                                   height: 200,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) => Text('Image load failed'),
//                                 )),
//                               if (msg['messageType'] == 'document' && msg['document'] != null)
//                                 ...msg['document'].map<Widget>((docUrl) => ListTile(
//                                   title: Text('Document'),
//                                   subtitle: Text(docUrl.split('/').last),
//                                   onTap: () {
//                                     print('Open document: $docUrl');
//                                     // TODO: Add url_launcher
//                                   },
//                                 )),
//                               if (msg['message'] != null && msg['message'].isNotEmpty)
//                                 Text(msg['message']),
//                               Text(
//                                 DateTime.parse(msg['createdAt']).toLocal().toString().substring(0, 16),
//                                 style: TextStyle(fontSize: 10, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (currentChat != null)
//                   Padding(
//                     padding: EdgeInsets.all(10),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: TextField(
//                             controller: _messageController,
//                             decoration: InputDecoration(hintText: 'Message type karo...'),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         IconButton(
//                           onPressed: _pickImages,
//                           icon: Icon(Icons.image),
//                         ),
//                         IconButton(
//                           onPressed: _pickDocuments,
//                           icon: Icon(Icons.attach_file),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           flex: 1,
//                           child: ElevatedButton(
//                             onPressed: _sendMessage,
//                             child: Text('Send'),
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: Size(0, 48),
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 // Text("")
//                 if (images.isNotEmpty || documents.isNotEmpty)
//                   Container(
//                     height: 100,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: images.length + documents.length,
//                       itemBuilder: (context, index) {
//                         if (index < images.length) {
//                           return Padding(
//                             padding: EdgeInsets.all(8),
//                             child: Image.file(
//                               File(images[index]),
//                               width: 80,
//                               height: 80,
//                               fit: BoxFit.cover,
//                             ),
//                           );
//                         } else {
//                           final docIndex = index - images.length;
//                           return Padding(
//                             padding: EdgeInsets.all(8),
//                             child: Text(documents[docIndex].split('/').last),
//                           );
//                         }
//                       },
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

/*
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'APIServices.dart';
import 'SocketService.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String userId = "68ac07f700315e754a037e56";
  // final String userId = "68abeca08908c84c7c3769ea";
  // final String userId = "68ac1a6900315e754a038c80";
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

  // Navigation state
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
      // Today: show time only
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      // Other days: show date
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
      return _buildChatDetailScreen();
    }
    return _buildChatListScreen();
  }

  Widget _buildChatListScreen() {
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
          // Search Bar
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[100],
          //     borderRadius: BorderRadius.circular(25),
          //   ),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: 'Search for services',
          //       hintStyle: TextStyle(color: Colors.grey[600]),
          //       prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          //       border: InputBorder.none,
          //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          //     ),
          //   ),
          // ),

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

          // Chat List
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
                    onTap: () {
                      setState(() {
                        currentChat = conv;
                        showChatDetail = true;
                      });
                      _fetchMessages();
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

  Widget _buildChatDetailScreen() {
    final members = (currentChat['members'] as List);
    final otherUser = members.firstWhere(
          (m) => m['_id'] != userId,
      orElse: () => {'name': 'Unknown', '_id': ''},
    );
    final isOnline = onlineUsers.contains(otherUser['_id']);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              showChatDetail = false;
              currentChat = null;
              messages.clear();
            });
          },
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
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (ctx, idx) {
                final msg = messages[idx];
                final isMe = msg['senderId'] == userId;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                            if (msg['messageType'] == 'document' && msg['document'] != null)
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
                                  _formatTime(msg['createdAt']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMe ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                                // if (isMe) ...[
                                //   SizedBox(width: 4),
                                //   Icon(
                                //     Icons.done_all,
                                //     size: 14,
                                //     color: Colors.white70,
                                //   ),
                                // ],
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

          // Selected Images/Documents Preview
          if (images.isNotEmpty || documents.isNotEmpty)
            Container(
              height: 80,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: images.length + documents.length,
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
                            documents[docIndex].split('/').last.substring(0,
                                documents[docIndex].split('/').last.length > 8 ? 8 : documents[docIndex].split('/').last.length),
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

          // Message Input
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
                      onPressed: _pickDocuments,
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
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Write a message',
                                  hintStyle: TextStyle(color: Colors.grey[600]),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                maxLines: null,
                              ),
                            ),
                            IconButton(
                              onPressed: _pickImages,
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
                        onPressed: _sendMessage,
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
    );
  }

}*/




///      top code is working code


 ///          new code  today commented code
/*import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        onBack(); // Call the onBack callback to navigate back to ChatListScreen
        return false; // Prevent default back button behavior (exiting the app)
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = messages[idx];
                  final isMe = msg['senderId'] == userId;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                              if (msg['messageType'] == 'document' && msg['document'] != null)
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
                  itemCount: images.length + documents.length,
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
                              documents[docIndex].split('/').last.substring(0,
                                  documents[docIndex].split('/').last.length > 8 ? 8 : documents[docIndex].split('/').last.length),
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
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}*/

///      top code is working code

