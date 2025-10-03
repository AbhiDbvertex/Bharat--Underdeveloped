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

import '../directHiring/views/ServiceProvider/FullImageScreen.dart';
import 'APIServices.dart';
import 'SocketService.dart';

Future<void> openFileExample(String path) async {
  try {
    final result = await OpenFilex.open(path);
    print("Result: ${result.message}");
  } catch (e) {
    print("Error opening file: $e");
  }
}// In the stream builder use of continue async data flow .

class StandaloneChatDetailScreen extends StatefulWidget {
  final dynamic initialCurrentChat;
  final String initialUserId;
  final List<dynamic> initialMessages;
  final List<String> initialOnlineUsers;

  const StandaloneChatDetailScreen({
    Key? key,
    required this.initialCurrentChat,
    required this.initialUserId,
    required this.initialMessages,
    required this.initialOnlineUsers,
  }) : super(key: key);

  @override
  _StandaloneChatDetailScreenState createState() => _StandaloneChatDetailScreenState();
}

class _StandaloneChatDetailScreenState extends State<StandaloneChatDetailScreen> {
  late dynamic currentChat;
  late String userId;
  List<dynamic> messages = [];
  List<String> images = [];
  List<String> documents = [];
  List<String> onlineUsers = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    currentChat = widget.initialCurrentChat;
    userId = widget.initialUserId;
    messages = widget.initialMessages.toList();
    onlineUsers = widget.initialOnlineUsers.toList();

    // Socket message listener
    SocketService.setMessageCallback((parsedMessage) {
      if (parsedMessage != null && parsedMessage['conversationId'].toString() == currentChat['_id'].toString()) {
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
        print('Abhi:- Received message from other chat or invalid: $parsedMessage');
      }
    });
    SocketService.listenOnlineUsers((users) {
      setState(() => onlineUsers = users.map((u) => u.toString()).toList());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  String getIdAsString(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    if (id is Map && id.containsKey('\$oid')) return id['\$oid'].toString();
    print("Abhi:- Warning: Unexpected _id format: $id");
    return id.toString();
  }
  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty && images.isEmpty && documents.isEmpty) {
      print("Abhi:- Error: No message, images, or documents to send");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No message, images, or documents to send')),
        );
      }
      return;
    }

    String? receiverId;
    try {
      final members = currentChat['members'] as List? ?? [];
      if (members.isEmpty) {
        print("Abhi:- Error: Members list is empty");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: No members found in conversation')),
          );
        }
        return;
      }

      print("Abhi:- Members: $members");
      if (members.first is String) {
        // Case 1: Members are string IDs (from POST /api/chat/conversations)
        receiverId = members.firstWhere(
              (m) => m != userId,
          orElse: () => null,
        );
      } else {
        // Case 2: Members are full user objects (after fetchUserById)
        final matchingMember = members.firstWhere(
              (m) => m['_id'].toString() != userId,
          orElse: () => <String, dynamic>{}, // Return empty Map<String, dynamic>
        );
        receiverId = matchingMember.isNotEmpty ? matchingMember['_id'].toString() : null;
      }

      if (receiverId == null || receiverId.isEmpty) {
        print("Abhi:- Error: No matching member found for receiverId");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Invalid receiver ID')),
          );
        }
        return;
      }

      print("Abhi:- ReceiverId found: $receiverId");
    } catch (e, stackTrace) {
      print("Abhi:- Error finding receiverId: $e");
      print("Abhi:- Stack trace: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to find receiver ID: $e')),
        );
      }
      return;
    }

    try {
      dynamic newMsg;
      if (images.isNotEmpty) {
        newMsg = await ApiService.sendImageMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'].toString(),
          imagePaths: images,
          message: messageController.text.isNotEmpty ? messageController.text : null,
        );
        print('Abhi:- Image message sent successfully: $newMsg');
      } else if (documents.isNotEmpty) {
        newMsg = await ApiService.sendDocumentMessage(
          senderId: userId,
          receiverId: receiverId,
          conversationId: currentChat['_id'].toString(),
          documentPaths: documents,
          message: messageController.text.isNotEmpty ? messageController.text : null,
        );
        print('Abhi:- Document message sent successfully: $newMsg');
      } else {
        final msgData = {
          'senderId': userId,
          'receiverId': receiverId,
          'conversationId': currentChat['_id'].toString(),
          'message': messageController.text,
          'messageType': 'text',
        };
        newMsg = await ApiService.sendTextMessage(msgData);
        print('Abhi:- Text message sent successfully: $newMsg');
      }

      SocketService.sendMessage(newMsg);
      if (mounted) {
        setState(() {
          if (!messages.any((msg) => msg['_id'].toString() == newMsg['_id'].toString())) {
            messages.insert(0, newMsg);
            print('Abhi:- Message added to UI: ${newMsg['_id']}');
          } else {
            print('Abhi:- Message already exists in UI: ${newMsg['_id']}');
          }
          messageController.clear();
          images.clear();
          documents.clear();
          print('Abhi:- Message fields cleared after sending');
        });
        _scrollToBottom();
      }
    } catch (e, stackTrace) {
      print('Abhi:- Error sending message: $e');
      print('Abhi:- Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to send message: $e')),
        );
      }
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

  // -----------   Opne document  ---------------      //
  Future<void> openDocumentFromUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'file.pdf';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      // Open local file
      await OpenFilex.open(file.path);
    } catch (e) {
      print("Abhi:- Error opening document URL: $url");
      print("Abhi:- Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open document: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Abhi:- Back pressed in StandaloneChatDetailScreen");
        SocketService.disconnect();
        return true;
      },
      child: ChatDetailScreen(
        currentChat: currentChat,
        userId: userId,
        messages: messages,
        onlineUsers: onlineUsers,
        scrollController: scrollController,
        messageController: messageController,
        images: images,
        documents: documents,
        onBack: () {
          print("Abhi:- onBack called in ChatDetailScreen");
          SocketService.disconnect();
          Navigator.pop(context);
        },
        onSendMessage: _sendMessage,
        onPickImages: _pickImages,
        onPickDocuments: _pickDocuments,
        formatTime: _formatTime,
      ),
    );
  }

  @override
  void dispose() {
    print("Abhi:- Disposing StandaloneChatDetailScreen");
    SocketService.removeMessageCallback();
    SocketService.disconnect();
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}

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
    print("Abhi:- Building ChatDetailScreen, conversationId: ${currentChat['_id']}");
    final members = (currentChat['members'] as List?) ?? [];
    dynamic otherUser;

    // Handle other user selection with robust type checking
    try {
      if (members.isEmpty) {
        print("Abhi:- Warning: Members list is empty for conversation ${currentChat['_id']}");
        otherUser = {'full_name': 'Unknown', '_id': '', 'profile_pic': null};
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Warning: No members found in conversation')),
          );
        });
      } else {
        otherUser = members.firstWhere(
              (m) {
            final memberId = m['_id']?.toString();
            print("Abhi:- Comparing memberId: $memberId with userId: $userId");
            return memberId != null && memberId != userId;
          },
          orElse: () {
            print("Abhi:- No matching member found, using default");
            return {'full_name': 'Unknown', '_id': '', 'profile_pic': null};
          },
        );
        print("Abhi:- Other user found: ${otherUser['_id']}, name: ${otherUser['full_name']}");
      }
    } catch (e, stackTrace) {
      print("Abhi:- Error finding other user in members: $e");
      print("Abhi:- Stack trace: $stackTrace");
      otherUser = {'full_name': 'Unknown', '_id': '', 'profile_pic': null};
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to load chat user: $e')),
        );
      });
    }

    final isOnline = otherUser['_id'] != '' && onlineUsers.contains(otherUser['_id'].toString());

    return WillPopScope(
      onWillPop: () async {
        print("Abhi:- Back pressed in ChatDetailScreen");
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
            onPressed: () {
              print("Abhi:- Back button pressed in ChatDetailScreen");
              onBack();
            },
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: otherUser['profile_pic'] != null
                        ? NetworkImage(otherUser['profile_pic'])
                        : null,
                    child: otherUser['profile_pic'] == null
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
                  otherUser['full_name'] ?? 'Unknown',
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
                print("Abhi:- Phone button pressed in ChatDetailScreen");
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                print("Abhi:- More options button pressed in ChatDetailScreen");
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = messages[idx];
                  final isMe = msg['senderId']?.toString() == userId;

                  print("Abhi:- Rendering message: ${msg['_id']}, isMe: $isMe, type: ${msg['messageType']}");
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
                            child: /*Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg['messageType'] == 'image' && msg['image'] != null)
                                ...(msg['image'] as List).map<Widget>((imgUrl) => Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                   onTap: (){
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>FullImageScreen(imageUrl: 'https://api.thebharatworks.com/$imgUrl',)));
                                   },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        'https://api.thebharatworks.com/$imgUrl',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print("Abhi:- Error loading image: $error");
                                          // SchedulerBinding.instance.addPostFrameCallback((_) {
                                          //   ScaffoldMessenger.of(context).showSnackBar(
                                          //     SnackBar(content: Text('Error loading image: $error')),
                                          //   );
                                          // });
                                          return Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.error),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )),
                              if (msg['messageType'] == 'image' && msg['image'] != null)
                                ...(msg['image'] as List).map<Widget>((docUrl) => Container(
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
                          ),*/
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (msg['messageType'] == 'image' && msg['image'] != null)
                                  ...(msg['image'] as List).map<Widget>((fileUrl) {
                                    final fullUrl = 'https://api.thebharatworks.com/$fileUrl';
                                    final fileName = fileUrl.split('/').last.toLowerCase();

                                    // check extension
                                    final isImage = fileName.endsWith('.jpg') ||
                                        fileName.endsWith('.jpeg') ||
                                        fileName.endsWith('.png') ||
                                        fileName.endsWith('.gif') ||
                                        fileName.endsWith('.webp');

                                    if (isImage) {
                                      // ---------- IMAGE UI ----------
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FullImageScreen(imageUrl: fullUrl),
                                              ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              fullUrl,
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print("Abhi:- Error loading image: $error");
                                                SchedulerBinding.instance.addPostFrameCallback((_) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error loading image: $error')),
                                                  );
                                                });
                                                return Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.error),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // ---------- DOCUMENT UI ----------
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: InkWell(
                                          // onTap: () async {
                                          //   if (await canLaunchUrl(Uri.parse(fullUrl))) {
                                          //     await launchUrl(Uri.parse(fullUrl));
                                          //   }
                                          // },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.insert_drive_file, size: 20),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  fileName,
                                                  style: TextStyle(fontSize: 12),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }),

                                // ---------- TEXT MESSAGE ----------
                                if (msg['message'] != null && msg['message'].isNotEmpty)
                                  Text(
                                    msg['message'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),

                                SizedBox(height: 4),

                                // ---------- TIME ----------
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
                            )

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
                      print("Abhi:- Rendering selected image: ${images[index]}");
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
                            errorBuilder: (context, error, stackTrace) {
                              print("Abhi:- Error loading selected image: $error");
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error loading selected image: $error')),
                                );
                              });
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      final docIndex = index - images.length;
                      print("Abhi:- Rendering selected document: ${documents[docIndex]}");
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
                                    : documents[docIndex].split('/').last.length,
                              ),
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
                      // IconButton(
                      //   onPressed: () {
                      //     print("Abhi:- Document picker button pressed");
                      //     onPickDocuments();
                      //   },
                      //   icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                      // ),
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
                                  onChanged: (value) {
                                    print("Abhi:- Message input changed: $value");
                                  },
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     print("Abhi:- Image picker button pressed");
                              //     onPickImages();
                              //   },
                              //   icon: Icon(Icons.image, color: Colors.grey[600]),
                              // ),
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
                          onPressed: () {
                            print("Abhi:- Send message button pressed");
                            // print('In Flutter/Dart, a mixin is a way to reuse a class’s code in multiple classes without using inheritance.');
                            onSendMessage();
                          },
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