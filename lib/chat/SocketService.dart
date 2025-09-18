// // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // // import 'dart:async';
// // //
// // // import '../directHiring/Consent/app_constants.dart';
// // //
// // //
// // // class SocketService {
// // //   static IO.Socket? socket;
// // //   static String baseUrl = 'https://api.thebharatworks.com';
// // //   // static String baseUrl = 'https://api.thebharatworks.com:300';
// // //
// // //
// // //   static Future<void> connect(String userId) async {
// // //     final token = await getCustomHeaders();
// // //     socket = IO.io(baseUrl, IO.OptionBuilder()
// // //         .setTransports(['websocket'])  // WebSocket prefer kar
// // //         .setExtraHeaders({'Authorization': 'Bearer $token'})
// // //         .build());
// // //
// // //     socket?.connect();
// // //
// // //     // Connection success pe
// // //     socket?.onConnect((_) {
// // //       print('Socket connected!');
// // //       socket?.emit('addUser', userId);  // Jaise tere React mein hai
// // //     });
// // //
// // //     // Error handle
// // //     socket?.onConnectError((err) => print('Connection error: $err'));
// // //     socket?.onDisconnect((_) => print('Socket disconnected'));
// // //   }
// // //
// // //   static void disconnect() {
// // //     socket?.disconnect();
// // //     socket = null;
// // //   }
// // //
// // //   // // Online users listen kar
// // //   // static void listenOnlineUsers(Function(List<dynamic>) callback) {
// // //   //   socket?.on('getUsers', callback);
// // //   // }
// // //   // Online users listen kar
// // //   static void listenOnlineUsers(void Function(List<dynamic>) callback) {
// // //     socket?.on('getUsers', (data) {
// // //       print('Received online users: $data');
// // //       callback(data as List<dynamic>); // Data ko List<dynamic> mein cast karo
// // //     });
// // //   }
// // //
// // //   // New message listen kar
// // //   static void listenNewMessage(Function(dynamic) callback) {
// // //     socket?.on('getMessage', callback);
// // //   }
// // //
// // //   // Message send kar
// // //   static void sendMessage(dynamic messageData) {
// // //     socket?.emit('sendMessage', messageData);
// // //   }
// // // }
// //
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'dart:async';
// //
// // import '../directHiring/Consent/app_constants.dart';
// //
// // class SocketService {
// //   static IO.Socket? socket;
// //   static String baseUrl = 'https://api.thebharatworks.com'; // Agar custom port hai (jaise 5000), to yahan add kar: 'https://api.thebharatworks.com:5000'
// //
// //   static Future<void> connect(String userId) async {
// //     final token = await getCustomHeaders();
// //     print('Token for Socket: $token');
// //     print('Connecting to: $baseUrl');
// //
// //     socket = IO.io(baseUrl, IO.OptionBuilder()
// //         .setTransports(['polling', 'websocket']) // Pehle polling, phir WebSocket
// //         .setExtraHeaders({'Authorization': 'Bearer $token'})
// //         .enableForceNew() // New connection
// //         .enableReconnection() // Auto-reconnect
// //         .setTimeout(10000) // Connection timeout
// //         .setReconnectionDelay(1000)
// //         .setQuery({'EIO': '4'}) // Explicitly v4 protocol
// //         .build());
// //
// //     socket?.connect();
// //
// //     socket?.onConnect((_) {
// //       print('Socket connected! UserId: $userId');
// //       socket?.emit('addUser', userId);
// //     });
// //
// //     socket?.onConnectError((err) {
// //       print('Connect Error: $err');
// //     });
// //
// //     socket?.onError((err) {
// //       print('Socket Error: $err');
// //     });
// //
// //     socket?.onDisconnect((reason) {
// //       print('Disconnected: $reason');
// //     });
// //
// //     socket?.onAny((event, data) {
// //       print('Event: $event, Data: $data');
// //     });
// //   }
// //
// //   static void disconnect() {
// //     socket?.disconnect();
// //     socket = null;
// //   }
// //
// //   static void listenOnlineUsers(void Function(List<dynamic>) callback) {
// //     socket?.on('getUsers', (data) {
// //       print('Online Users: $data');
// //       callback(data as List<dynamic>);
// //     });
// //   }
// //
// //   static void listenNewMessage(void Function(dynamic) callback) {
// //     socket?.on('getMessage', (data) {
// //       print('New Message: $data');
// //       callback(data);
// //     });
// //   }
// //
// //   static void sendMessage(dynamic messageData) {
// //     socket?.emit('sendMessage', messageData);
// //   }
// // }
// // await getCustomHeaders();
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'dart:async';
//
// import '../directHiring/Consent/app_constants.dart';
//
// class SocketService {
//   static IO.Socket? socket;
//   static String baseUrl = 'https://api.thebharatworks.com/';
//
//   static Future<void> connect(String userId) async {
//     final token =await getCustomHeaders();
//     print('Token for Socket: $token');
//     print('Connecting to: $baseUrl');
//
//     socket = IO.io(
//       "https://api.thebharatworks.com",
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
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

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;

  static void connect(String userId) {
    socket = IO.io(
      "https://api.thebharatworks.com/",  // end me slash zaroori
      IO.OptionBuilder()
          .setPath('/socket.io')           // force path
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()            // auto connect off
          .enableReconnection()
          .build(),
    );

    socket?.connect();


    socket!.onConnect((_) {
      print("✅ Connected to socket");
      socket!.emit("addUser", userId);
    });

    socket!.onConnectError((err) {
      print("❌ Connect error: $err");
    });

    socket!.onDisconnect((_) {
      print("⚡ Disconnected");
    });
  }
}
