// /////////////                                chat screen                               ////////////
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
//   final String userId = "68ac07f700315e754a037e56"; // TODO: Auth se le
//   List<dynamic> conversations = [];
//   dynamic currentChat;
//   List<dynamic> messages = [];
//   final TextEditingController _messageController = TextEditingController();
//   List<String> images = [];
//   List<String> documents = []; // For documents
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
//     SocketService.listenOnlineUsers((users) {
//       print('Online users: $users');
//       setState(() => onlineUsers = users);
//     });
//     SocketService.listenNewMessage((data) {
//       print('New message via socket: $data');
//       if (data != null &&
//           data['conversationId'] != null &&
//           (data['message'] != null || data['image'] != null || data['document'] != null)) {
//         if (currentChat != null && data['conversationId'] == currentChat['_id']) {
//           setState(() {
//             data['_id'] = data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
//             messages.add(data);
//           });
//           _scrollToBottom();
//           print('✅ Received message added to UI: ${data['message']}');
//         } else {
//           _fetchConversations(); // Refresh sidebar
//           print('ℹ️ Message from other chat: ${data['conversationId']}');
//         }
//       } else {
//         print('❌ Invalid message data: $data');
//       }
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
//       setState(() => messages = msgs);
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
//       });
//       _fetchMessages();
//     } catch (e) {
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
//     final receiverId = "68abeca08908c84c7c3769ea"; // TODO: Dynamically set
//     if (currentChat == null) {
//       print('Abhi:- Current chat is null, cannot send message. receiverId: $receiverId');
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
//         messages.add(newMsg);
//         _messageController.clear(); // Clear text field
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
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar
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
//           // Chat Area
//           Expanded(
//             flex: 7,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
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
//                                 )),
//                               if (msg['messageType'] == 'document' && msg['document'] != null)
//                                 ...msg['document'].map<Widget>((docUrl) => ListTile(
//                                   title: Text('Document'),
//                                   subtitle: Text(docUrl.split('/').last),
//                                   onTap: () {
//                                     // Add url_launcher to open docUrl
//                                     print('Open document: $docUrl');
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
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     SocketService.disconnect();
//     _scrollController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }
// }
//
// ////////                        ApiService                   ///////////
//
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import '../directHiring/Consent/app_constants.dart';
//
// class ApiService {
//   static String baseUrl = 'https://api.thebharatworks.com/api/chat';
//
//   static Future<Map<String, String>> getToken() async {
//     final token = await getCustomHeaders();
//     print('Abhi:- API Token: $token');
//     return token;
//   }
//
//   static Future<List<dynamic>> fetchConversations(String userId) async {
//     final token = await getToken();
//     print('Abhi:- Fetching conversations for userId: $userId');
//     final response = await http.get(
//       Uri.parse('$baseUrl/conversations/$userId'),
//       headers: {'Authorization': 'Bearer ${token['Authorization']}'},
//     );
//     print('Abhi:- Conversations API response: ${response.statusCode}, ${response.body}');
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('Abhi:- Conversations fetched: ${data['conversations']}');
//       return data['conversations'] ?? [];
//     }
//     throw Exception('Failed to load conversations: ${response.body}');
//   }
//
//   static Future<List<dynamic>> fetchMessages(String conversationId) async {
//     final token = await getToken();
//     print('Abhi:- Fetching messages for conversationId: $conversationId');
//     final response = await http.get(
//       Uri.parse('$baseUrl/messages/$conversationId'),
//       headers: {'Authorization': 'Bearer ${token['Authorization']}'},
//     );
//     print('Abhi:- Messages API response: ${response.statusCode}, ${response.body}');
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('Abhi:- Messages fetched: ${data['messages']}');
//       return data['messages'] ?? [];
//     }
//     throw Exception('Failed to load messages: ${response.body}');
//   }
//
//   static Future<dynamic> startConversation(String senderId, String receiverId) async {
//     final token = await getToken();
//     print('Abhi:- Starting conversation: senderId=$senderId, receiverId=$receiverId');
//     final response = await http.post(
//       Uri.parse('$baseUrl/conversations'),
//       headers: {'Authorization': 'Bearer ${token['Authorization']}', 'Content-Type': 'application/json'},
//       body: json.encode({'senderId': senderId, 'receiverId': receiverId}),
//     );
//     print('Abhi:- Start conversation API response: ${response.statusCode}, ${response.body}');
//     if (response.statusCode == 201) {
//       return json.decode(response.body)['conversation'];
//     }
//     throw Exception('Failed to start conversation: ${response.body}');
//   }
//
//   static Future<dynamic> sendTextMessage(Map<String, dynamic> messageData) async {
//     final token = await getToken();
//     print('Abhi:- Sending text message: $messageData');
//     final response = await http.post(
//       Uri.parse('$baseUrl/messages'),
//       headers: {'Authorization': 'Bearer ${token['Authorization']}', 'Content-Type': 'application/json'},
//       body: json.encode(messageData),
//     );
//     print('Abhi:- Text message API response: ${response.statusCode}, ${response.body}');
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = json.decode(response.body);
//       if (data['status'] == true && data['newMessage'] != null) {
//         print('Abhi:- Text message sent successfully: ${data['newMessage']}');
//         return data['newMessage'];
//       }
//       throw Exception('Failed to send message: Invalid response format - ${response.body}');
//     }
//     throw Exception('Failed to send message: ${response.body}');
//   }
//
//   static Future<dynamic> sendImageMessage({
//     required String senderId,
//     required String receiverId,
//     required String conversationId,
//     required List<String> imagePaths,
//     String? message,
//   }) async {
//     final token = await getToken();
//     print('Abhi:- Sending image message: senderId=$senderId, receiverId=$receiverId, conversationId=$conversationId, images=$imagePaths');
//     final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/messages'));
//
//     request.headers['Authorization'] = 'Bearer ${token['Authorization']}';
//     request.fields['senderId'] = senderId;
//     request.fields['receiverId'] = receiverId;
//     request.fields['conversationId'] = conversationId;
//     request.fields['messageType'] = 'image';
//     if (message != null && message.isNotEmpty) {
//       request.fields['message'] = message;
//     }
//
//     for (var path in imagePaths) {
//       print('Abhi:- Adding image to request: $path');
//       request.files.add(await http.MultipartFile.fromPath('images', path));
//     }
//
//     final response = await request.send();
//     final responseBody = await http.Response.fromStream(response);
//     print('Abhi:- Image message API response: ${response.statusCode}, ${responseBody.body}');
//     if (response.statusCode == 201) {
//       return json.decode(responseBody.body)['newMessage'];
//     }
//     throw Exception('Failed to send image message: ${responseBody.body}');
//   }
//
//   static Future<dynamic> sendDocumentMessage({
//     required String senderId,
//     required String receiverId,
//     required String conversationId,
//     required List<String> documentPaths,
//     String? message,
//   }) async {
//     final token = await getToken();
//     print('Abhi:- Sending document message: senderId=$senderId, receiverId=$receiverId, conversationId=$conversationId, documents=$documentPaths');
//     final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/messages'));
//
//     request.headers['Authorization'] = 'Bearer ${token['Authorization']}';
//     request.fields['senderId'] = senderId;
//     request.fields['receiverId'] = receiverId;
//     request.fields['conversationId'] = conversationId;
//     request.fields['messageType'] = 'document';
//     if (message != null && message.isNotEmpty) {
//       request.fields['message'] = message;
//     }
//
//     for (var path in documentPaths) {
//       print('Abhi:- Adding document to request: $path');
//       request.files.add(await http.MultipartFile.fromPath('documents', path));
//     }
//
//     final response = await request.send();
//     final responseBody = await http.Response.fromStream(response);
//     print('Abhi:- Document message API response: ${response.statusCode}, ${responseBody.body}');
//     if (response.statusCode == 201) {
//       return json.decode(responseBody.body)['newMessage'];
//     }
//     throw Exception('Failed to send document message: ${responseBody.body}');
//   }
// }
//
// ////////////              SoketService           ///////////
//
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'dart:async';
//
// import '../directHiring/Consent/app_constants.dart';
//
// class SocketService {
//   static IO.Socket? socket;
//   static String baseUrl = 'http://api.thebharatworks.com:5001';
//
//   static Future<void> connect(String userId) async {
//     final token = await getCustomHeaders();
//     print('Abhi:- Token for Socket: $token');
//     print('Abhi:- Connecting to: $baseUrl');
//
//     socket = IO.io(
//       baseUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .setExtraHeaders(token)
//           .enableForceNew()
//           .enableReconnection()
//           .setTimeout(10000)
//           .setReconnectionDelay(1000)
//           .setReconnectionAttempts(5)
//           .build(),
//     );
//
//     socket?.connect();
//
//     socket?.onConnect((_) {
//       print('Abhi:- Socket connected! UserId: $userId');
//       socket?.emit('addUser', userId);
//     });
//
//     socket?.onConnectError((err) {
//       print('Abhi:- Connect Error: $err');
//     });
//
//     socket?.onError((err) {
//       print('Abhi:- Socket Error: $err');
//     });
//
//     socket?.onDisconnect((reason) {
//       print('️ Disconnected: $reason');
//       if (reason != 'io client disconnect') {
//         print('Abhi:- Attempting to reconnect...');
//       }
//     });
//
//     socket?.on('getMessage', onMessage);
//
//     socket?.onReconnect((_) {
//       print('Abhi:- Socket reconnected! UserId: $userId');
//       socket?.emit('addUser', userId);
//     });
//
//     socket?.onAny((event, data) {
//       print('Abhi:- Event: $event, Data: $data');
//     });
//   }
//
//   static void onMessage(dynamic res) {
//     print("Abhi:- New message received: $res");
//   }
//
//   static void disconnect() {
//     socket?.disconnect();
//     socket = null;
//     print("Abhi:- Socket disconnected manually");
//   }
//
//   static void listenOnlineUsers(void Function(List<dynamic>) callback) {
//     socket?.on('getUsers', (data) {
//       print('Online Users: $data');
//       callback(data as List<dynamic>);
//     });
//   }
//
//   static void listenNewMessage(void Function(dynamic) callback) {
//     socket?.on('getMessage', (data) {
//       print('Abhi:-New Message: $data');
//       callback(data);
//     });
//   }
//
//   static void sendMessage(dynamic messageData) {
//     print("Abhi:- Sending message: $messageData");
//     socket?.emit('sendMessage', messageData);
//   }
// }