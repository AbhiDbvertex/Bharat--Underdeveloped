// // // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // // // import 'dart:async';
// // // //
// // // // import '../directHiring/Consent/app_constants.dart';
// // // //
// // // //
// // // // class SocketService {
// // // //   static IO.Socket? socket;
// // // //   static String baseUrl = 'https://api.thebharatworks.com';
// // // //   // static String baseUrl = 'https://api.thebharatworks.com:300';
// // // //
// // // //
// // // //   static Future<void> connect(String userId) async {
// // // //     final token = await getCustomHeaders();
// // // //     socket = IO.io(baseUrl, IO.OptionBuilder()
// // // //         .setTransports(['websocket'])  // WebSocket prefer kar
// // // //         .setExtraHeaders({'Authorization': 'Bearer $token'})
// // // //         .build());
// // // //
// // // //     socket?.connect();
// // // //
// // // //     // Connection success pe
// // // //     socket?.onConnect((_) {
// // // //       print('Socket connected!');
// // // //       socket?.emit('addUser', userId);  // Jaise tere React mein hai
// // // //     });
// // // //
// // // //     // Error handle
// // // //     socket?.onConnectError((err) => print('Connection error: $err'));
// // // //     socket?.onDisconnect((_) => print('Socket disconnected'));
// // // //   }
// // // //
// // // //   static void disconnect() {
// // // //     socket?.disconnect();
// // // //     socket = null;
// // // //   }
// // // //
// // // //   // // Online users listen kar
// // // //   // static void listenOnlineUsers(Function(List<dynamic>) callback) {
// // // //   //   socket?.on('getUsers', callback);
// // // //   // }
// // // //   // Online users listen kar
// // // //   static void listenOnlineUsers(void Function(List<dynamic>) callback) {
// // // //     socket?.on('getUsers', (data) {
// // // //       print('Received online users: $data');
// // // //       callback(data as List<dynamic>); // Data ko List<dynamic> mein cast karo
// // // //     });
// // // //   }
// // // //
// // // //   // New message listen kar
// // // //   static void listenNewMessage(Function(dynamic) callback) {
// // // //     socket?.on('getMessage', callback);
// // // //   }
// // // //
// // // //   // Message send kar
// // // //   static void sendMessage(dynamic messageData) {
// // // //     socket?.emit('sendMessage', messageData);
// // // //   }
// // // // }
// // //
// // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // // import 'dart:async';
// // //
// // // import '../directHiring/Consent/app_constants.dart';
// // //
// // // class SocketService {
// // //   static IO.Socket? socket;
// // //   static String baseUrl = 'https://api.thebharatworks.com'; // Agar custom port hai (jaise 5000), to yahan add kar: 'https://api.thebharatworks.com:5000'
// // //
// // //   static Future<void> connect(String userId) async {
// // //     final token = await getCustomHeaders();
// // //     print('Token for Socket: $token');
// // //     print('Connecting to: $baseUrl');
// // //
// // //     socket = IO.io(baseUrl, IO.OptionBuilder()
// // //         .setTransports(['polling', 'websocket']) // Pehle polling, phir WebSocket
// // //         .setExtraHeaders({'Authorization': 'Bearer $token'})
// // //         .enableForceNew() // New connection
// // //         .enableReconnection() // Auto-reconnect
// // //         .setTimeout(10000) // Connection timeout
// // //         .setReconnectionDelay(1000)
// // //         .setQuery({'EIO': '4'}) // Explicitly v4 protocol
// // //         .build());
// // //
// // //     socket?.connect();
// // //
// // //     socket?.onConnect((_) {
// // //       print('Socket connected! UserId: $userId');
// // //       socket?.emit('addUser', userId);
// // //     });
// // //
// // //     socket?.onConnectError((err) {
// // //       print('Connect Error: $err');
// // //     });
// // //
// // //     socket?.onError((err) {
// // //       print('Socket Error: $err');
// // //     });
// // //
// // //     socket?.onDisconnect((reason) {
// // //       print('Disconnected: $reason');
// // //     });
// // //
// // //     socket?.onAny((event, data) {
// // //       print('Event: $event, Data: $data');
// // //     });
// // //   }
// // //
// // //   static void disconnect() {
// // //     socket?.disconnect();
// // //     socket = null;
// // //   }
// // //
// // //   static void listenOnlineUsers(void Function(List<dynamic>) callback) {
// // //     socket?.on('getUsers', (data) {
// // //       print('Online Users: $data');
// // //       callback(data as List<dynamic>);
// // //     });
// // //   }
// // //
// // //   static void listenNewMessage(void Function(dynamic) callback) {
// // //     socket?.on('getMessage', (data) {
// // //       print('New Message: $data');
// // //       callback(data);
// // //     });
// // //   }
// // //
// // //   static void sendMessage(dynamic messageData) {
// // //     socket?.emit('sendMessage', messageData);
// // //   }
// // // }
// // await getCustomHeaders();
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'dart:async';
//
// import '../directHiring/Consent/app_constants.dart';
//
// class SocketService extends GetxController{
//   static IO.Socket? socket;
//   static String baseUrl = 'https://api.thebharatworks.com/';
//
//   static Future<void> connect(String userId) async {
//     final token =await getCustomHeaders();
//     print('Token for Socket: $token');
//     print('Connecting to: $baseUrl');
//
//     socket = IO.io(
//       "http://api.thebharatworks.com:5001",
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .enableAutoConnect()
//           .enableForceNew()
//           .enableReconnection()
//           .build(),
//     );
//
//     socket?.connect();
//
//     socket?.onConnect((_) {
//       print("✅ Connected to socket");
//     });
//
//     socket?.onConnectError((data) {
//       print("❌ Connect error: $data");
//     });
//
//     socket?.onError((err) {
//       print('Socket Error: $err');
//     });
//
//     socket?.onDisconnect((reason) {
//       print('Disconnected: $reason');
//     });
//
//     socket?.onAny((event, data) {
//       print('Event: $event, Data: $data');
//     });
//   }
//
//   static void disconnect() {
//     socket?.disconnect();
//     socket = null;
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
//       print('New Message: $data');
//       callback(data);
//     });
//   }
//
//   static void sendMessage(dynamic messageData) {
//     socket?.emit('sendMessage', messageData);
//   }
// }
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// import 'dart:async';
//
// import '../directHiring/Consent/app_constants.dart';
//
// class SocketService {
//
//   static IO.Socket? socket;
//
//   static String baseUrl = 'http://api.thebharatworks.com:5001';
//
//   static Future<void> connect(String userId) async {
//
//     final token = await getCustomHeaders(); // returns {Content-Type, Accept, Authorization}
//
//     print('Abhi:- Token for Socket: $token');
//
//     print('Abhi:- Connecting to: $baseUrl');
//
//     socket = IO.io(
//
//       baseUrl,
//
//       IO.OptionBuilder()
//
//           .setTransports(['websocket'])
//
//           .setExtraHeaders(token) // ✅ no extra Bearer Bearer
//
//           .enableForceNew()
//
//           .enableReconnection()
//
//           .setTimeout(10000)
//
//           .setReconnectionDelay(1000)
//
//           .setReconnectionAttempts(5)
//
//           .build(),
//
//     );
//
//     socket?.connect();
//
//     socket?.onConnect((_) {
//
//       print('✅ Socket connected! UserId: $userId');
//
//       socket?.emit('addUser', userId);
//
//     });
//
//     socket?.onConnectError((err) {
//
//       print('❌ Connect Error: $err');
//
//     });
//
//     socket?.onError((err) {
//
//       print('❌ Socket Error: $err');
//
//     });
//
//     socket?.onDisconnect((reason) {
//
//       print('⚠️ Disconnected: $reason');
//
//       if (reason != 'io client disconnect') {
//
//         print('🔄 Attempting to reconnect...');
//
//       }
//
//     });
//
//     socket?.on('getMessage', onMessage);
//
//     socket?.onReconnect((_) {
//
//       print('🔄 Socket reconnected! UserId: $userId');
//
//       socket?.emit('addUser', userId);
//
//     });
//
//     socket?.onAny((event, data) {
//
//       print('📩 Event: $event, Data: $data');
//
//     });
//
//   }
//
//   static void onMessage(dynamic res) {
//
//     print("💬 New message received: $res");
//
//   }
//
//   static void disconnect() {
//
//     socket?.disconnect();
//
//     socket = null;
//
//     print("🔌 Socket disconnected manually");
//
//   }
//
//   static void listenOnlineUsers(void Function(List<dynamic>) callback) {
//
//     socket?.on('getUsers', (data) {
//
//       print('👥 Online Users: $data');
//
//       callback(data as List<dynamic>);
//
//     });
//
//   }
//
//   static void listenNewMessage(void Function(dynamic) callback) {
//
//     socket?.on('getMessage', (data) {
//
//       print('New Message listenNewMessage: $data');
//
//       callback(data);
//
//     });
//
//   }
//
//   static void sendMessage(dynamic messageData) {
//
//     print("📤 Sending message: $messageData");
//
//     socket?.emit('sendMessage', messageData);
//
//   }
//
// }
//
////////////
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

import '../directHiring/Consent/app_constants.dart';

class SocketService {
  static IO.Socket? socket;
  static String baseUrl = 'http://api.thebharatworks.com:5001';
  static bool _isConnecting = false;
  static Function(dynamic)? _onMessageCallback;

  static void setMessageCallback(Function(dynamic) callback) {
    _onMessageCallback = callback;
    print('Abhi:- Message callback set');
  }

  static void removeMessageCallback() {
    _onMessageCallback = null;
    print('Abhi:- Message callback removed');
  }

  static Future<void> connect(String userId) async {
    if (socket != null && socket!.connected) {
      print('Abhi:- Socket already connected for userId: $userId');
      socket?.emit('addUser', userId); // Re-emit to ensure registration
      return;
    }

    if (_isConnecting) {
      print('Abhi:- Connection already in progress');
      return;
    }

    _isConnecting = true;
    final token = await getCustomHeaders();
    print('Abhi:- Token for Socket: $token');
    print('Abhi:- Connecting to: $baseUrl');

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(token)
          .enableForceNew()
          .enableReconnection()
          .setTimeout(10000)
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) {
      print('Abhi:- Socket connected! UserId: $userId');
      socket?.emit('addUser', userId);
      _isConnecting = false;
    });

    socket?.onConnectError((err) {
      print('Abhi:- Connect Error: $err');
      _isConnecting = false;
    });

    socket?.onError((err) {
      print('Abhi:- Socket Error: $err');
    });

    socket?.onDisconnect((reason) {
      print('️ Disconnected: $reason');
      if (reason != 'io client disconnect') {
        print('Abhi:- Attempting to reconnect...');
      }
    });

    // socket?.on('getMessage', onMessage);

    socket?.onReconnect((_) {
      print('Abhi:- Socket reconnected! UserId: $userId');
      socket?.emit('addUser', userId);
    });

    socket?.on('getMessage', (data) {
      print('Abhi:- New Message Received: $data');
      if (data != null && data['conversationId'] != null) {
        final parsedMessage = {
          '_id': data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'senderId': data['senderId'] ?? '',
          'receiverId': data['receiverId'] ?? '',
          'conversationId': data['conversationId'] ?? '',
          'message': data['message'],
          'messageType': data['messageType'] ?? 'text',
          'image': data['image'] != null && data['image'].isNotEmpty
              ? List<String>.from(data['image'])
              : null,
          'document': data['document'] != null && data['document'].isNotEmpty
              ? List<String>.from(data['document'])
              : null,
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        };
        _onMessageCallback?.call(parsedMessage);
      } else {
        print('Abhi:- Invalid message data: $data');
      }
    });
    socket?.onAny((event, data) {
      print('Abhi:- Event: $event, Data: $data');
    });
  }

  // static void onMessage(dynamic res) {
  //   print("Abhi:- New message received: $res");
  // }

  static void disconnect() {
    socket?.off('getMessage');
    socket?.disconnect();
    socket = null;
    _onMessageCallback = null;
    print("Abhi:- Socket disconnected manually");

  }

  static void listenOnlineUsers(void Function(List<dynamic>) callback) {
    socket?.off('getUsers'); // Prevent duplicate listeners
    socket?.on('getUsers', (data) {
      print('Abhi:- Online Users: $data');
      callback(data as List<dynamic>);
    });
  }

  // static void listenNewMessage(void Function(dynamic) callback) {
  //   print('Abhi:- Setting up getMessage listener');
  //   socket?.off('getMessage'); // Remove previous listeners to avoid duplicates
  //   socket?.on('getMessage', (data) {
  //     print('Abhi:- New Message Received: $data');
  //     if (data != null && data['conversationId'] != null) {
  //       callback(data);
  //     } else {
  //       print('Abhi:- Invalid message data: $data');
  //     }
  //   });
  //   print('Abhi:- Socket connected: ${socket?.connected}');
  // }

  static void sendMessage(dynamic messageData) {
    print("Abhi:- Sending message: $messageData");
    socket?.emit('sendMessage', messageData);
  }
}
