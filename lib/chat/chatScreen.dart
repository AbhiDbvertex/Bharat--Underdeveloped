// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'dart:io';
// // import 'APIServices.dart';
// // import 'SocketService.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   @override
// //   _ChatScreenState createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final TextEditingController _messageController = TextEditingController();
// //
// //   // final String userId = "68abec670fa4a01b9b742ddf"; // TODO: Auth se le
// //   final String userId = "68abeca08908c84c7c3769ea"; // TODO: Auth se le
// //   List<dynamic> conversations = [];
// //   dynamic currentChat;
// //   List<dynamic> messages = [];
// //   String message = '';
// //   List<String> images = []; // Image file paths store kar
// //   List<dynamic> onlineUsers = [];
// //   String receiverId = '';
// //   final ScrollController _scrollController = ScrollController();
// //   final ImagePicker _picker = ImagePicker();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initSocket();
// //     _fetchConversations();
// //   }
// //
// //   void _initSocket() {
// //     print('Initializing socket for userId: $userId');
// //     SocketService.connect(userId);
// //     SocketService.listenOnlineUsers((users) {
// //       print('Online users: $users');
// //       setState(() => onlineUsers = users);
// //     });
// //     SocketService.listenNewMessage((data) {
// //       print('New message: $data');
// //       if (currentChat != null && data['conversationId'] == currentChat['_id']) {
// //         if (mounted) {
// //           setState(() {
// //             messages.add(data);
// //           });
// //           _scrollToBottom();
// //         }
// //       }
// //     });
// //   }
// //
// //   Future<void> _fetchConversations() async {
// //     try {
// //       final convs = await ApiService.fetchConversations(userId);
// //       if (mounted) {
// //         setState(() => conversations = convs);
// //       }
// //     } catch (e) {
// //       print('Error fetching conversations: $e');
// //     }
// //   }
// //
// //   Future<void> _fetchMessages() async {
// //     if (currentChat == null) return;
// //     try {
// //       final msgs = await ApiService.fetchMessages(currentChat['_id']);
// //       if (mounted) {
// //         setState(() => messages = msgs);
// //       }      _scrollToBottom();
// //     } catch (e) {
// //       print('Error fetching messages: $e');
// //     }
// //   }
// //
// //   Future<void> _startConversation() async {
// //     if (receiverId.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receiver ID daalo!')));
// //       return;
// //     }
// //     try {
// //       final newConv = await ApiService.startConversation(userId, receiverId);
// //       setState(() {
// //         conversations.add(newConv);
// //         currentChat = newConv;
// //       });
// //       receiverId = '';
// //       _fetchMessages();
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _pickImages() async {
// //     final List<XFile>? pickedFiles = await _picker.pickMultiImage();
// //     if (pickedFiles != null) {
// //       if (pickedFiles.length > 5) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Maximum 5 images allowed!')),
// //         );
// //         return;
// //       }
// //       setState(() {
// //         images = pickedFiles.map((file) => file.path).toList();
// //       });
// //     }
// //   }
// //
// //   Future<void> _sendMessage() async {
// //     print("[_send message  call ]");
// //     if (message.isEmpty && images.isEmpty) return;
// //     // final receiverId = "68ac1a6900315e754a038c80"; // Hardcoded jaise React mein
// //     final receiverId = "68ac07f700315e754a037e56"; // Hardcoded jaise React mein
// //     if (currentChat == null) return;
// //
// //     try {
// //       dynamic newMsg;
// //       if (images.isNotEmpty) {
// //         print("[_send message  call ] if");
// //         newMsg = await ApiService.sendImageMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           imagePaths: images,
// //           message: message.isNotEmpty ? message : null,
// //         );
// //       } else {
// //         print("[_send message  call ] else ");
// //         final msgData = {
// //           'senderId': userId,
// //           'receiverId': receiverId,
// //           'conversationId': currentChat['_id'],
// //           'message': message,
// //           'messageType': 'text',
// //         };
// //         newMsg = await ApiService.sendTextMessage(msgData);
// //       }
// //
// //       print("[_send message  call ] not both ");
// //       if(newMsg !=null){
// //         SocketService.sendMessage(newMsg);
// //         setState(() {
// //           messages.add(newMsg);
// //           message = '';
// //           images.clear();
// //         });
// //         _messageController.clear();
// //         _scrollToBottom();
// //       }
// //
// //       print("[_send message  call ],last ");
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
// //       print("[_send message  call ],catch : $e ");
// //
// //     }
// //
// //   }
// //
// //   void _scrollToBottom() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _scrollController.animateTo(
// //         _scrollController.position.maxScrollExtent,
// //         duration: Duration(milliseconds: 300),
// //         curve: Curves.easeOut,
// //       );
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Row(
// //         children: [
// //           // Sidebar
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.all(10),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: TextField(
// //                           onChanged: (val) => receiverId = val,
// //                           decoration: InputDecoration(hintText: 'Receiver ID daalo'),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //                       Expanded(
// //                         flex: 1,
// //                         child: ElevatedButton(
// //                           onPressed: _startConversation,
// //                           child: Text('Start Chat'),
// //                           style: ElevatedButton.styleFrom(
// //                             minimumSize: Size(0, 48),
// //                             padding: EdgeInsets.symmetric(horizontal: 10),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     itemCount: conversations.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final conv = conversations[idx];
// //                       final otherUser = conv['members'].firstWhere((m) => m['_id'] != userId);
// //                       return ListTile(
// //                         title: Text(otherUser['name'] ?? 'User'),
// //                         subtitle: Text(conv['lastMessage'] ?? ''),
// //                         onTap: () {
// //                           setState(() => currentChat = conv);
// //                           _fetchMessages();
// //                         },
// //                         selected: currentChat?['_id'] == conv['_id'],
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Chat Area
// //           Expanded(
// //             flex: 7,
// //             child: Column(
// //               children: [
// //                 Expanded(
// //                   child: ListView.builder(
// //                     controller: _scrollController,
// //                     itemCount: messages.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final msg = messages[idx];
// //                       final isMe = msg['senderId'] == userId;
// //                       return Align(
// //                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
// //                         child: Container(
// //                           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                           padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: isMe ? Colors.green[100] : Colors.grey[200],
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: msg['messageType'] == 'image' && msg['image'] != null
// //                               ? Column(
// //                             children: [
// //                               ...?msg['image'].map<Widget>((imgUrl) => Image.network(
// //                                 'https://api.thebharatworks.com/$imgUrl',
// //                                 width: 200,
// //                                 height: 200,
// //                                 fit: BoxFit.cover,
// //                               )),
// //                               if (msg['message'] != null) Text(msg['message']),
// //                             ],
// //                           )
// //                               : Text(msg['message'] ?? ''),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 if (currentChat != null)
// //                   Padding(
// //                     padding: EdgeInsets.all(10),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           flex: 3,
// //                           child: TextField(
// //                             controller: _messageController,
// //                             onChanged: (val) => message = val,
// //                             decoration: InputDecoration(hintText: 'Message type karo...'),
// //                           ),
// //                         ),
// //                         SizedBox(width: 10),
// //                         IconButton(
// //                           onPressed: _pickImages,
// //                           icon: Icon(Icons.image),
// //                         ),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           flex: 1,
// //                           child: ElevatedButton(
// //                             onPressed: _sendMessage,
// //                             child: Text('Send'),
// //                             style: ElevatedButton.styleFrom(
// //                               minimumSize: Size(0, 48),
// //                               padding: EdgeInsets.symmetric(horizontal: 10),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     SocketService.disconnect();
// //     _scrollController.dispose();
// //     _messageController.dispose(); // Add this line
// //
// //     super.dispose();
// //   }
// // }
//
// ////////////////////
// // import 'dart:async';
// //
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'dart:io';
// // import 'APIServices.dart';
// // import 'SocketService.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   @override
// //   _ChatScreenState createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   // final String userId = "68ac07f700315e754a037e56"; // TODO: Auth se le
// //   final String userId = "68abeca08908c84c7c3769ea"; // TODO: Auth se le
// //   List<dynamic> conversations = [];
// //   dynamic currentChat;
// //   List<dynamic> messages = [];
// //   final TextEditingController _messageController = TextEditingController();
// //   final TextEditingController _receiverIdController = TextEditingController();
// //   final SocketService _socketService = SocketService();
// //
// //   List<String> images = [];
// //   List<String> documents = []; // For documents
// //   List<dynamic> onlineUsers = [];
// //   String receiverId = '';
// //   final ScrollController _scrollController = ScrollController();
// //   final ImagePicker _picker = ImagePicker();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initSocket();
// //     _fetchConversations();
// //     // Fallback polling
// //     Timer.periodic(Duration(seconds: 10), (timer) {
// //       if (currentChat != null) {
// //         _fetchMessages();
// //       }
// //     });
// //   }
// //
// //   void _initSocket() {
// //     print('Initializing socket for userId: $userId');
// //     SocketService.connect(userId);
// //     SocketService.listenOnlineUsers((users) {
// //       print('Online users: $users');
// //       setState(() => onlineUsers = users);
// //     });
// //     SocketService.listenNewMessage((data) {
// //       print('New message via socket: $data');
// //       if (data != null &&
// //           data['conversationId'] != null &&
// //           (data['message'] != null || data['image'] != null || data['document'] != null)) {
// //         if (currentChat != null && data['conversationId'] == currentChat['_id']) {
// //           setState(() {
// //             data['_id'] = data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
// //             messages.add(data);
// //           });
// //           _scrollToBottom();
// //           print('✅ Received message added to UI: ${data['message']}');
// //         } else {
// //           _fetchConversations(); // Refresh sidebar
// //           print('ℹ️ Message from other chat: ${data['conversationId']}');
// //         }
// //       } else {
// //         print('❌ Invalid message data: $data');
// //       }
// //     });
// //   }
// //
// //   Future<void> _fetchConversations() async {
// //     try {
// //       final convs = await ApiService.fetchConversations(userId);
// //       setState(() => conversations = convs);
// //     } catch (e) {
// //       print('Error fetching conversations: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversations fetch nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _fetchMessages() async {
// //     if (currentChat == null) return;
// //     try {
// //       final msgs = await ApiService.fetchMessages(currentChat['_id']);
// //       setState(() => messages = msgs);
// //       _scrollToBottom();
// //     } catch (e) {
// //       print('Error fetching messages: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Messages fetch nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _startConversation() async {
// //     if (receiverId.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receiver ID daalo!')));
// //       return;
// //     }
// //     try {
// //       final newConv = await ApiService.startConversation(userId, receiverId);
// //       setState(() {
// //         conversations.add(newConv);
// //         currentChat = newConv;
// //         receiverId = '';
// //       });
// //       _fetchMessages();
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _pickImages() async {
// //     final List<XFile>? pickedFiles = await _picker.pickMultiImage();
// //     if (pickedFiles != null) {
// //       if (pickedFiles.length > 5) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Maximum 5 images allowed!')),
// //         );
// //         return;
// //       }
// //       setState(() {
// //         images = pickedFiles.map((file) => file.path).toList();
// //       });
// //     }
// //   }
// //
// //   Future<void> _pickDocuments() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: true,
// //       type: FileType.custom,
// //       allowedExtensions: ['pdf', 'doc', 'docx'],
// //     );
// //     if (result != null && result.files.length <= 5) {
// //       setState(() {
// //         documents = result.files.map((file) => file.path!).toList();
// //       });
// //     } else if (result != null && result.files.length > 5) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Maximum 5 documents allowed!')),
// //       );
// //     }
// //   }
// //
// //   Future<void> _sendMessage() async {
// //     if (_messageController.text.isEmpty && images.isEmpty && documents.isEmpty) {
// //       print('Abhi:- No message, images, or documents to send.');
// //       return;
// //     }
// //     // final receiverId = "68abeca08908c84c7c3769ea"; // TODO: Dynamically set
// //     final receiverId = "68ac07f700315e754a037e56"; // TODO: Dynamically set
// //     if (currentChat == null) {
// //       print('Abhi:- Current chat is null, cannot send message. receiverId: $receiverId');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle chat select karo!')));
// //       return;
// //     }
// //
// //     try {
// //       print('Abhi:- Attempting to send message. Message: ${_messageController.text}, Images: $images, Documents: $documents');
// //       dynamic newMsg;
// //       if (images.isNotEmpty) {
// //         newMsg = await ApiService.sendImageMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           imagePaths: images,
// //           message: _messageController.text.isNotEmpty ? _messageController.text : null,
// //         );
// //         print('Abhi:- Image message sent successfully: $newMsg');
// //       } else if (documents.isNotEmpty) {
// //         newMsg = await ApiService.sendDocumentMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           documentPaths: documents,
// //           message: _messageController.text.isNotEmpty ? _messageController.text : null,
// //         );
// //         print('Abhi:- Document message sent successfully: $newMsg');
// //       } else {
// //         final msgData = {
// //           'senderId': userId,
// //           'receiverId': receiverId,
// //           'conversationId': currentChat['_id'],
// //           'message': _messageController.text,
// //           'messageType': 'text',
// //         };
// //         newMsg = await ApiService.sendTextMessage(msgData);
// //         print('Abhi:- Text message sent successfully: $newMsg');
// //       }
// //
// //       print('Abhi:- Emitting message via socket: $newMsg');
// //       SocketService.sendMessage(newMsg);
// //       setState(() {
// //         messages.add(newMsg);
// //         _messageController.clear(); // Clear text field
// //         images.clear();
// //         documents.clear();
// //         print('Abhi:- Message added to UI and fields cleared.');
// //       });
// //       _scrollToBottom();
// //     } catch (e) {
// //       print('Abhi:- Error sending message: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
// //     }
// //   }
// //
// //   void _scrollToBottom() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (_scrollController.hasClients) {
// //         _scrollController.animateTo(
// //           _scrollController.position.maxScrollExtent,
// //           duration: Duration(milliseconds: 300),
// //           curve: Curves.easeOut,
// //         );
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Row(
// //         children: [
// //           // Sidebar
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.all(10),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: TextField(
// //                           onChanged: (val) => receiverId = val,
// //                           decoration: InputDecoration(hintText: 'Receiver ID daalo'),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //                       Expanded(
// //                         flex: 1,
// //                         child: ElevatedButton(
// //                           onPressed: _startConversation,
// //                           child: Text('Start Chat'),
// //                           style: ElevatedButton.styleFrom(
// //                             minimumSize: Size(0, 48),
// //                             padding: EdgeInsets.symmetric(horizontal: 10),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     itemCount: conversations.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final conv = conversations[idx];
// //                       final members = (conv['members'] as List);
// //                       final otherUser = members.firstWhere(
// //                             (m) => m['_id'] != userId,
// //                         orElse: () => {'name': 'Unknown', '_id': ''},
// //                       );
// //
// //                       return ListTile(
// //                         title: Text(otherUser['name'] ?? 'Unknown'),
// //                         subtitle: Text(conv['lastMessage'] ?? ''),
// //                         onTap: () {
// //                           setState(() => currentChat = conv);
// //                           _fetchMessages();
// //                         },
// //                         selected: currentChat?['_id'] == conv['_id'],
// //                         trailing: onlineUsers.contains(otherUser['_id'])
// //                             ? Icon(Icons.circle, color: Colors.green, size: 12)
// //                             : null,
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Chat Area
// //           Expanded(
// //             flex: 7,
// //             child: Column(
// //               children: [
// //                 Expanded(
// //                   child: ListView.builder(
// //                     controller: _scrollController,
// //                     itemCount: messages.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final msg = messages[idx];
// //                       final isMe = msg['senderId'] == userId;
// //                       return Align(
// //                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
// //                         child: Container(
// //                           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                           padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: isMe ? Colors.green[100] : Colors.grey[200],
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: Column(
// //                             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// //                             children: [
// //                               if (msg['messageType'] == 'image' && msg['image'] != null)
// //                                 ...msg['image'].map<Widget>((imgUrl) => Image.network(
// //                                   'https://api.thebharatworks.com/$imgUrl',
// //                                   width: 200,
// //                                   height: 200,
// //                                   fit: BoxFit.cover,
// //                                 )),
// //                               if (msg['messageType'] == 'document' && msg['document'] != null)
// //                                 ...msg['document'].map<Widget>((docUrl) => ListTile(
// //                                   title: Text('Document'),
// //                                   subtitle: Text(docUrl.split('/').last),
// //                                   onTap: () {
// //                                     // Add url_launcher to open docUrl
// //                                     print('Open document: $docUrl');
// //                                   },
// //                                 )),
// //                               if (msg['message'] != null && msg['message'].isNotEmpty)
// //                                 Text(msg['message']),
// //                               Text(
// //                                 DateTime.parse(msg['createdAt']).toLocal().toString().substring(0, 16),
// //                                 style: TextStyle(fontSize: 10, color: Colors.grey),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 if (currentChat != null)
// //                   Padding(
// //                     padding: EdgeInsets.all(10),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           flex: 3,
// //                           child: TextField(
// //                             controller: _messageController,
// //                             decoration: InputDecoration(hintText: 'Message type karo...'),
// //                           ),
// //                         ),
// //                         SizedBox(width: 10),
// //                         IconButton(
// //                           onPressed: _pickImages,
// //                           icon: Icon(Icons.image),
// //                         ),
// //                         IconButton(
// //                           onPressed: _pickDocuments,
// //                           icon: Icon(Icons.attach_file),
// //                         ),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           flex: 1,
// //                           child: ElevatedButton(
// //                             onPressed: _sendMessage,
// //                             child: Text('Send'),
// //                             style: ElevatedButton.styleFrom(
// //                               minimumSize: Size(0, 48),
// //                               padding: EdgeInsets.symmetric(horizontal: 10),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     SocketService.disconnect();
// //     _scrollController.dispose();
// //     _messageController.dispose();
// //     super.dispose();
// //   }
// // }
// //
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'dart:io';
// // import 'APIServices.dart';
// // import 'SocketService.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   @override
// //   _ChatScreenState createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final String userId = "68abeca08908c84c7c3769ea"; // TODO: Auth se le
// //   List<dynamic> conversations = [];
// //   dynamic currentChat;
// //   List<dynamic> messages = [];
// //   final TextEditingController _messageController = TextEditingController();
// //   final TextEditingController _receiverIdController = TextEditingController();
// //   final SocketService _socketService = SocketService();
// //   List<String> images = [];
// //   List<String> documents = [];
// //   List<dynamic> onlineUsers = [];
// //   String receiverId = '';
// //   final ScrollController _scrollController = ScrollController();
// //   final ImagePicker _picker = ImagePicker();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initSocket();
// //     _fetchConversations();
// //   }
// //
// //   void _initSocket() {
// //     print('Initializing socket for userId: $userId');
// //     SocketService.connect(userId);
// //     SocketService.listenOnlineUsers((users) {
// //       print('Online users: $users');
// //       setState(() => onlineUsers = users);
// //     });
// //     SocketService.listenNewMessage((data) {
// //       print('New message via socket: $data');
// //       if (data != null && data['conversationId'] != null) {
// //         final parsedMessage = {
// //           '_id': data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
// //           'senderId': data['senderId'] ?? '',
// //           'receiverId': data['receiverId'] ?? '',
// //           'conversationId': data['conversationId'] ?? '',
// //           'message': data['message'],
// //           'messageType': data['messageType'] ?? 'text',
// //           'image': data['image'] != null ? List<String>.from(data['image']) : null,
// //           'document': data['document'] != null ? List<String>.from(data['document']) : null,
// //           'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
// //         };
// //         if (currentChat != null && data['conversationId'] == currentChat['_id']) {
// //           setState(() {
// //             // Avoid duplicate messages
// //             if (!messages.any((msg) => msg['_id'] == parsedMessage['_id'])) {
// //               messages.add(parsedMessage);
// //             }
// //           });
// //           _scrollToBottom();
// //           print('✅ Received message added to UI: ${parsedMessage['message']}');
// //         } else {
// //           _fetchConversations(); // Refresh sidebar
// //           print('ℹ️ Message from other chat: ${data['conversationId']}');
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text('New message in another chat!')),
// //           );
// //         }
// //       } else {
// //         print('❌ Invalid message data: $data');
// //       }
// //     });
// //   }
// //
// //   Future<void> _fetchConversations() async {
// //     try {
// //       final convs = await ApiService.fetchConversations(userId);
// //       setState(() => conversations = convs);
// //     } catch (e) {
// //       print('Error fetching conversations: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversations fetch nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _fetchMessages() async {
// //     if (currentChat == null) return;
// //     try {
// //       final msgs = await ApiService.fetchMessages(currentChat['_id']);
// //       setState(() {
// //         // Avoid duplicates
// //         messages = msgs.where((msg) => !messages.any((m) => m['_id'] == msg['_id'])).toList() + messages;
// //       });
// //       _scrollToBottom();
// //     } catch (e) {
// //       print('Error fetching messages: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Messages fetch nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _startConversation() async {
// //     if (receiverId.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receiver ID daalo!')));
// //       return;
// //     }
// //     try {
// //       final newConv = await ApiService.startConversation(userId, receiverId);
// //       setState(() {
// //         conversations.add(newConv);
// //         currentChat = newConv;
// //         receiverId = '';
// //         _receiverIdController.clear();
// //       });
// //       _fetchMessages();
// //     } catch (e) {
// //       print('Error starting conversation: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _pickImages() async {
// //     final List<XFile>? pickedFiles = await _picker.pickMultiImage();
// //     if (pickedFiles != null) {
// //       if (pickedFiles.length > 5) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Maximum 5 images allowed!')),
// //         );
// //         return;
// //       }
// //       setState(() {
// //         images = pickedFiles.map((file) => file.path).toList();
// //       });
// //     }
// //   }
// //
// //   Future<void> _pickDocuments() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: true,
// //       type: FileType.custom,
// //       allowedExtensions: ['pdf', 'doc', 'docx'],
// //     );
// //     if (result != null && result.files.length <= 5) {
// //       setState(() {
// //         documents = result.files.map((file) => file.path!).toList();
// //       });
// //     } else if (result != null && result.files.length > 5) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Maximum 5 documents allowed!')),
// //       );
// //     }
// //   }
// //
// //   Future<void> _sendMessage() async {
// //     if (_messageController.text.isEmpty && images.isEmpty && documents.isEmpty) {
// //       print('Abhi:- No message, images, or documents to send.');
// //       return;
// //     }
// //     final receiverId = currentChat['members']
// //         ?.firstWhere((m) => m['_id'] != userId, orElse: () => null)?['_id'];
// //     if (receiverId == null || currentChat == null) {
// //       print('Abhi:- Current chat or receiverId is null, cannot send message.');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle chat select karo!')));
// //       return;
// //     }
// //
// //     try {
// //       print('Abhi:- Attempting to send message. Message: ${_messageController.text}, Images: $images, Documents: $documents');
// //       dynamic newMsg;
// //       if (images.isNotEmpty) {
// //         newMsg = await ApiService.sendImageMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           imagePaths: images,
// //           message: _messageController.text.isNotEmpty ? _messageController.text : null,
// //         );
// //         print('Abhi:- Image message sent successfully: $newMsg');
// //       } else if (documents.isNotEmpty) {
// //         newMsg = await ApiService.sendDocumentMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           documentPaths: documents,
// //           message: _messageController.text.isNotEmpty ? _messageController.text : null,
// //         );
// //         print('Abhi:- Document message sent successfully: $newMsg');
// //       } else {
// //         final msgData = {
// //           'senderId': userId,
// //           'receiverId': receiverId,
// //           'conversationId': currentChat['_id'],
// //           'message': _messageController.text,
// //           'messageType': 'text',
// //         };
// //         newMsg = await ApiService.sendTextMessage(msgData);
// //         print('Abhi:- Text message sent successfully: $newMsg');
// //       }
// //
// //       print('Abhi:- Emitting message via socket: $newMsg');
// //       SocketService.sendMessage(newMsg);
// //       setState(() {
// //         if (!messages.any((msg) => msg['_id'] == newMsg['_id'])) {
// //           messages.add(newMsg);
// //         }
// //         _messageController.clear();
// //         images.clear();
// //         documents.clear();
// //         print('Abhi:- Message added to UI and fields cleared.');
// //       });
// //       _scrollToBottom();
// //     } catch (e) {
// //       print('Abhi:- Error sending message: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
// //     }
// //   }
// //
// //   void _scrollToBottom() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (_scrollController.hasClients) {
// //         _scrollController.animateTo(
// //           _scrollController.position.maxScrollExtent,
// //           duration: Duration(milliseconds: 300),
// //           curve: Curves.easeOut,
// //         );
// //       }
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     SocketService.disconnect();
// //     _scrollController.dispose();
// //     _messageController.dispose();
// //     _receiverIdController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Row(
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.all(10),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: TextField(
// //                           controller: _receiverIdController,
// //                           onChanged: (val) => receiverId = val,
// //                           decoration: InputDecoration(hintText: 'Receiver ID daalo'),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //                       Expanded(
// //                         flex: 1,
// //                         child: ElevatedButton(
// //                           onPressed: _startConversation,
// //                           child: Text('Start Chat'),
// //                           style: ElevatedButton.styleFrom(
// //                             minimumSize: Size(0, 48),
// //                             padding: EdgeInsets.symmetric(horizontal: 10),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     key: ValueKey(conversations.length),
// //                     itemCount: conversations.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final conv = conversations[idx];
// //                       final members = (conv['members'] as List);
// //                       final otherUser = members.firstWhere(
// //                             (m) => m['_id'] != userId,
// //                         orElse: () => {'name': 'Unknown', '_id': ''},
// //                       );
// //
// //                       return ListTile(
// //                         title: Text(otherUser['name'] ?? 'Unknown'),
// //                         subtitle: Text(conv['lastMessage'] ?? ''),
// //                         onTap: () {
// //                           setState(() => currentChat = conv);
// //                           _fetchMessages();
// //                         },
// //                         selected: currentChat?['_id'] == conv['_id'],
// //                         trailing: onlineUsers.contains(otherUser['_id'])
// //                             ? Icon(Icons.circle, color: Colors.green, size: 12)
// //                             : null,
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             flex: 7,
// //             child: Column(
// //               children: [
// //                 if (currentChat != null)
// //                   Padding(
// //                     padding: EdgeInsets.all(10),
// //                     child: Align(
// //                       alignment: Alignment.centerRight,
// //                       child: IconButton(
// //                         icon: Icon(Icons.refresh),
// //                         onPressed: _fetchMessages,
// //                         tooltip: 'Refresh Messages',
// //                       ),
// //                     ),
// //                   ),
// //                 Expanded(
// //                   child: currentChat == null
// //                       ? Center(child: Text('Select a conversation'))
// //                       : ListView.builder(
// //                     key: ValueKey(messages.length),
// //                     controller: _scrollController,
// //                     itemCount: messages.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final msg = messages[idx];
// //                       final isMe = msg['senderId'] == userId;
// //                       return Align(
// //                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
// //                         child: Container(
// //                           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                           padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: isMe ? Colors.green[100] : Colors.grey[200],
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: Column(
// //                             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// //                             children: [
// //                               if (msg['messageType'] == 'image' && msg['image'] != null)
// //                                 ...msg['image'].map<Widget>((imgUrl) => Image.network(
// //                                   'https://api.thebharatworks.com/$imgUrl',
// //                                   width: 200,
// //                                   height: 200,
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (context, error, stackTrace) => Text('Image load failed'),
// //                                 )),
// //                               if (msg['messageType'] == 'document' && msg['document'] != null)
// //                                 ...msg['document'].map<Widget>((docUrl) => ListTile(
// //                                   title: Text('Document'),
// //                                   subtitle: Text(docUrl.split('/').last),
// //                                   onTap: () {
// //                                     print('Open document: $docUrl');
// //                                     // TODO: Add url_launcher
// //                                   },
// //                                 )),
// //                               if (msg['message'] != null && msg['message'].isNotEmpty)
// //                                 Text(msg['message']),
// //                               Text(
// //                                 DateTime.parse(msg['createdAt']).toLocal().toString().substring(0, 16),
// //                                 style: TextStyle(fontSize: 10, color: Colors.grey),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 if (currentChat != null)
// //                   Padding(
// //                     padding: EdgeInsets.all(10),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           flex: 3,
// //                           child: TextField(
// //                             controller: _messageController,
// //                             decoration: InputDecoration(hintText: 'Message type karo...'),
// //                           ),
// //                         ),
// //                         SizedBox(width: 10),
// //                         IconButton(
// //                           onPressed: _pickImages,
// //                           icon: Icon(Icons.image),
// //                         ),
// //                         IconButton(
// //                           onPressed: _pickDocuments,
// //                           icon: Icon(Icons.attach_file),
// //                         ),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           flex: 1,
// //                           child: ElevatedButton(
// //                             onPressed: _sendMessage,
// //                             child: Text('Send'),
// //                             style: ElevatedButton.styleFrom(
// //                               minimumSize: Size(0, 48),
// //                               padding: EdgeInsets.symmetric(horizontal: 10),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 if (images.isNotEmpty || documents.isNotEmpty)
// //                   Container(
// //                     height: 100,
// //                     child: ListView.builder(
// //                       scrollDirection: Axis.horizontal,
// //                       itemCount: images.length + documents.length,
// //                       itemBuilder: (context, index) {
// //                         if (index < images.length) {
// //                           return Padding(
// //                             padding: EdgeInsets.all(8),
// //                             child: Image.file(
// //                               File(images[index]),
// //                               width: 80,
// //                               height: 80,
// //                               fit: BoxFit.cover,
// //                             ),
// //                           );
// //                         } else {
// //                           final docIndex = index - images.length;
// //                           return Padding(
// //                             padding: EdgeInsets.all(8),
// //                             child: Text(documents[docIndex].split('/').last),
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
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
//
// class _ChatScreenState extends State<ChatScreen> {
//   final String userId = "68abeca08908c84c7c3769ea"; // TODO: Auth se le
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
// ////////////////////////
// //
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'dart:io';
// // import 'APIServices.dart';
// // import 'SocketService.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   @override
// //   _ChatScreenState createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final String userId = "68abeca08908c84c7c3769ea"; // TODO: Auth se le
// //   List<dynamic> conversations = [];
// //   dynamic currentChat;
// //   List<dynamic> messages = [];
// //   final TextEditingController _messageController = TextEditingController();
// //   final TextEditingController _receiverIdController = TextEditingController();
// //   List<String> images = [];
// //   List<String> documents = [];
// //   List<dynamic> onlineUsers = [];
// //   String receiverId = '';
// //   final ScrollController _scrollController = ScrollController();
// //   final ImagePicker _picker = ImagePicker();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initSocket();
// //     _fetchConversations();
// //   }
// //
// //   void _initSocket() {
// //     print('Initializing socket for userId: $userId');
// //     SocketService.connect(userId);
// //     SocketService.setMessageCallback((parsedMessage) {
// //       print('New message via socket: $parsedMessage');
// //       if (parsedMessage != null && parsedMessage['conversationId'] != null) {
// //         if (currentChat != null && parsedMessage['conversationId'] == currentChat['_id']) {
// //           setState(() {
// //             if (!messages.any((msg) => msg['_id'] == parsedMessage['_id'])) {
// //               messages.add(parsedMessage);
// //             }
// //           });
// //           _scrollToBottom();
// //           print('✅ Received message added to UI: ${parsedMessage['message']}');
// //         } else {
// //           _fetchConversations();
// //           print('ℹ️ Message from other chat: ${parsedMessage['conversationId']}');
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text('New message in another chat!')),
// //           );
// //         }
// //       } else {
// //         print('❌ Invalid message data: $parsedMessage');
// //       }
// //     });
// //     SocketService.listenOnlineUsers((users) {
// //       print('Online users: $users');
// //       setState(() => onlineUsers = users);
// //     });
// //   }
// //
// //   Future<void> _fetchConversations() async {
// //     try {
// //       final convs = await ApiService.fetchConversations(userId);
// //       setState(() => conversations = convs);
// //     } catch (e) {
// //       print('Error fetching conversations: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversations fetch nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _fetchMessages() async {
// //     if (currentChat == null) return;
// //     try {
// //       final msgs = await ApiService.fetchMessages(currentChat['_id']);
// //       setState(() {
// //         messages = msgs.where((msg) => !messages.any((m) => m['_id'] == msg['_id'])).toList() + messages;
// //       });
// //       _scrollToBottom();
// //     } catch (e) {
// //       print('Error fetching messages: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Messages fetch nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _startConversation() async {
// //     if (receiverId.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receiver ID daalo!')));
// //       return;
// //     }
// //     try {
// //       final newConv = await ApiService.startConversation(userId, receiverId);
// //       setState(() {
// //         conversations.add(newConv);
// //         currentChat = newConv;
// //         receiverId = '';
// //         _receiverIdController.clear();
// //       });
// //       _fetchMessages();
// //     } catch (e) {
// //       print('Error starting conversation: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversation start nahi hui: $e')));
// //     }
// //   }
// //
// //   Future<void> _pickImages() async {
// //     final List<XFile>? pickedFiles = await _picker.pickMultiImage();
// //     if (pickedFiles != null) {
// //       if (pickedFiles.length > 5) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Maximum 5 images allowed!')),
// //         );
// //         return;
// //       }
// //       setState(() {
// //         images = pickedFiles.map((file) => file.path).toList();
// //       });
// //     }
// //   }
// //
// //   Future<void> _pickDocuments() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: true,
// //       type: FileType.custom,
// //       allowedExtensions: ['pdf', 'doc', 'docx'],
// //     );
// //     if (result != null && result.files.length <= 5) {
// //       setState(() {
// //         documents = result.files.map((file) => file.path!).toList();
// //       });
// //     } else if (result != null && result.files.length > 5) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Maximum 5 documents allowed!')),
// //       );
// //     }
// //   }
// //
// //   Future<void> _sendMessage() async {
// //     if (_messageController.text.isEmpty && images.isEmpty && documents.isEmpty) {
// //       print('Abhi:- No message, images, or documents to send.');
// //       return;
// //     }
// //     final receiverId = currentChat['members']
// //         ?.firstWhere((m) => m['_id'] != userId, orElse: () => null)?['_id'];
// //     if (receiverId == null || currentChat == null) {
// //       print('Abhi:- Current chat or receiverId is null, cannot send message.');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle chat select karo!')));
// //       return;
// //     }
// //
// //     try {
// //       print('Abhi:- Attempting to send message. Message: ${_messageController.text}, Images: $images, Documents: $documents');
// //       dynamic newMsg;
// //       if (images.isNotEmpty) {
// //         newMsg = await ApiService.sendImageMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           imagePaths: images,
// //           message: _messageController.text.isNotEmpty ? _messageController.text : null,
// //         );
// //         print('Abhi:- Image message sent successfully: $newMsg');
// //       } else if (documents.isNotEmpty) {
// //         newMsg = await ApiService.sendDocumentMessage(
// //           senderId: userId,
// //           receiverId: receiverId,
// //           conversationId: currentChat['_id'],
// //           documentPaths: documents,
// //           message: _messageController.text.isNotEmpty ? _messageController.text : null,
// //         );
// //         print('Abhi:- Document message sent successfully: $newMsg');
// //       } else {
// //         final msgData = {
// //           'senderId': userId,
// //           'receiverId': receiverId,
// //           'conversationId': currentChat['_id'],
// //           'message': _messageController.text,
// //           'messageType': 'text',
// //         };
// //         newMsg = await ApiService.sendTextMessage(msgData);
// //         print('Abhi:- Text message sent successfully: $newMsg');
// //       }
// //
// //       print('Abhi:- Emitting message via socket: $newMsg');
// //       SocketService.sendMessage(newMsg);
// //       setState(() {
// //         if (!messages.any((msg) => msg['_id'] == newMsg['_id'])) {
// //           messages.add(newMsg);
// //         }
// //         _messageController.clear();
// //         images.clear();
// //         documents.clear();
// //         print('Abhi:- Message added to UI and fields cleared.');
// //       });
// //       _scrollToBottom();
// //     } catch (e) {
// //       print('Abhi:- Error sending message: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message send nahi hui: $e')));
// //     }
// //   }
// //
// //   void _scrollToBottom() {
// //     Future.delayed(Duration(milliseconds: 100), () {
// //       if (_scrollController.hasClients) {
// //         print('Abhi:- Scrolling to bottom, maxScrollExtent: ${_scrollController.position.maxScrollExtent}, current: ${_scrollController.position.pixels}');
// //         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
// //       } else {
// //         print('Abhi:- ScrollController not attached');
// //       }
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     SocketService.removeMessageCallback();
// //     SocketService.disconnect();
// //     _scrollController.dispose();
// //     _messageController.dispose();
// //     _receiverIdController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Row(
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.all(10),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: TextField(
// //                           controller: _receiverIdController,
// //                           onChanged: (val) => receiverId = val,
// //                           decoration: InputDecoration(hintText: 'Receiver ID daalo'),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //                       Expanded(
// //                         flex: 1,
// //                         child: ElevatedButton(
// //                           onPressed: _startConversation,
// //                           child: Text('Start Chat'),
// //                           style: ElevatedButton.styleFrom(
// //                             minimumSize: Size(0, 48),
// //                             padding: EdgeInsets.symmetric(horizontal: 10),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     key: ValueKey(conversations.length),
// //                     itemCount: conversations.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final conv = conversations[idx];
// //                       final members = (conv['members'] as List);
// //                       final otherUser = members.firstWhere(
// //                             (m) => m['_id'] != userId,
// //                         orElse: () => {'name': 'Unknown', '_id': ''},
// //                       );
// //
// //                       return ListTile(
// //                         title: Text(otherUser['name'] ?? 'Unknown'),
// //                         subtitle: Text(conv['lastMessage'] ?? ''),
// //                         onTap: () {
// //                           setState(() => currentChat = conv);
// //                           _fetchMessages();
// //                         },
// //                         selected: currentChat?['_id'] == conv['_id'],
// //                         trailing: onlineUsers.contains(otherUser['_id'])
// //                             ? Icon(Icons.circle, color: Colors.green, size: 12)
// //                             : null,
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             flex: 7,
// //             child: Column(
// //               children: [
// //                 if (currentChat != null)
// //                   Padding(
// //                     padding: EdgeInsets.all(10),
// //                     child: Align(
// //                       alignment: Alignment.centerRight,
// //                       child: IconButton(
// //                         icon: Icon(Icons.refresh),
// //                         onPressed: _fetchMessages,
// //                         tooltip: 'Refresh Messages',
// //                       ),
// //                     ),
// //                   ),
// //                 Expanded(
// //                   child: currentChat == null
// //                       ? Center(child: Text('Select a conversation'))
// //                       : ListView.builder(
// //                     key: ValueKey(messages.hashCode),
// //                     controller: _scrollController,
// //                     reverse: true,
// //                     itemCount: messages.length,
// //                     itemBuilder: (ctx, idx) {
// //                       final msg = messages[messages.length - 1 - idx];
// //                       final isMe = msg['senderId'] == userId;
// //                       return Align(
// //                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
// //                         child: Container(
// //                           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                           padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: isMe ? Colors.green[100] : Colors.grey[200],
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: Column(
// //                             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// //                             children: [
// //                               if (msg['messageType'] == 'image' && msg['image'] != null)
// //                                 ...msg['image'].map<Widget>((imgUrl) => Image.network(
// //                                   'https://api.thebharatworks.com/$imgUrl',
// //                                   width: 200,
// //                                   height: 200,
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (context, error, stackTrace) => Text('Image load failed'),
// //                                 )),
// //                               if (msg['messageType'] == 'document' && msg['document'] != null)
// //                                 ...msg['document'].map<Widget>((docUrl) => ListTile(
// //                                   title: Text('Document'),
// //                                   subtitle: Text(docUrl.split('/').last),
// //                                   onTap: () {
// //                                     print('Open document: $docUrl');
// //                                     // TODO: Add url_launcher
// //                                   },
// //                                 )),
// //                               if (msg['message'] != null && msg['message'].isNotEmpty)
// //                                 Text(msg['message']),
// //                               Text(
// //                                 DateTime.parse(msg['createdAt']).toLocal().toString().substring(0, 16),
// //                                 style: TextStyle(fontSize: 10, color: Colors.grey),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 if (currentChat != null)
// //                   Padding(
// //                     padding: EdgeInsets.all(10),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           flex: 3,
// //                           child: TextField(
// //                             controller: _messageController,
// //                             decoration: InputDecoration(hintText: 'Message type karo...'),
// //                           ),
// //                         ),
// //                         SizedBox(width: 10),
// //                         IconButton(
// //                           onPressed: _pickImages,
// //                           icon: Icon(Icons.image),
// //                         ),
// //                         IconButton(
// //                           onPressed: _pickDocuments,
// //                           icon: Icon(Icons.attach_file),
// //                         ),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           flex: 1,
// //                           child: ElevatedButton(
// //                             onPressed: _sendMessage,
// //                             child: Text('Send'),
// //                             style: ElevatedButton.styleFrom(
// //                               minimumSize: Size(0, 48),
// //                               padding: EdgeInsets.symmetric(horizontal: 10),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 if (images.isNotEmpty || documents.isNotEmpty)
// //                   Container(
// //                     height: 100,
// //                     child: ListView.builder(
// //                       scrollDirection: Axis.horizontal,
// //                       itemCount: images.length + documents.length,
// //                       itemBuilder: (context, index) {
// //                         if (index < images.length) {
// //                           return Padding(
// //                             padding: EdgeInsets.all(8),
// //                             child: Image.file(
// //                               File(images[index]),
// //                               width: 80,
// //                               height: 80,
// //                               fit: BoxFit.cover,
// //                             ),
// //                           );
// //                         } else {
// //                           final docIndex = index - images.length;
// //                           return Padding(
// //                             padding: EdgeInsets.all(8),
// //                             child: Text(documents[docIndex].split('/').last),
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



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
  final String userId = "68abeca08908c84c7c3769ea"; // TODO: Auth se le
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
    print("receiverId : $receiverId");
    print('Abhi:- Current chat or receiverId is null, cannot send message.');

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