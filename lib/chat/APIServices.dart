import 'package:http/http.dart' as http;
import 'dart:convert';

import '../directHiring/Consent/app_constants.dart';

class ApiService {
  static String baseUrl = 'https://api.thebharatworks.com/api/chat';

  static Future<Map<String, String>> getToken() async {
    final token = await getCustomHeaders();
    print('Abhi:- API Token: $token');
    return token;
  }

  static Future<List<dynamic>> fetchConversations(String userId) async {
    final token = await getToken();
    print('Abhi:- Fetching conversations for userId: $userId');
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$userId'),
      headers: {'Authorization': 'Bearer ${token['Authorization']}'},
    );
    print('Abhi:- Conversations API response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Abhi:- Conversations fetched: ${data['conversations']}');
      return data['conversations'] ?? [];
    }
    throw Exception('Failed to load conversations: ${response.body}');
  }

  static Future<List<dynamic>> fetchMessages(String conversationId) async {
    final token = await getToken();
    print('Abhi:- Fetching messages for conversationId: $conversationId');
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: {'Authorization': 'Bearer ${token['Authorization']}'},
    );
    print('Abhi:- Messages API response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Abhi:- Messages fetched: ${data['messages']}');
      return data['messages'] ?? [];
    }
    throw Exception('Failed to load messages: ${response.body}');
  }

  static Future<dynamic> startConversation(String senderId, String receiverId) async {
    final token = await getToken();
    print('Abhi:- Starting conversation: senderId=$senderId, receiverId=$receiverId');
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: {'Authorization': 'Bearer ${token['Authorization']}', 'Content-Type': 'application/json'},
      body: json.encode({'senderId': senderId, 'receiverId': receiverId}),
    );
    print('Abhi:- Start conversation API response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 201) {
      return json.decode(response.body)['conversation'];
    }
    throw Exception('Failed to start conversation: ${response.body}');
  }

  static Future<dynamic> sendTextMessage(Map<String, dynamic> messageData) async {
    final token = await getToken();
    print('Abhi:- Sending text message: $messageData');
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Authorization': 'Bearer ${token['Authorization']}', 'Content-Type': 'application/json'},
      body: json.encode(messageData),
    );
    print('Abhi:- Text message API response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['status'] == true && data['newMessage'] != null) {
        print('Abhi:- Text message sent successfully: ${data['newMessage']}');
        return data['newMessage'];
      }
      throw Exception('Failed to send message: Invalid response format - ${response.body}');
    }
    throw Exception('Failed to send message: ${response.body}');
  }

  static Future<dynamic> sendImageMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required List<String> imagePaths,
    String? message,
  }) async {
    final token = await getToken();
    print('Abhi:- Sending image message: senderId=$senderId, receiverId=$receiverId, conversationId=$conversationId, images=$imagePaths');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/messages'));

    request.headers['Authorization'] = 'Bearer ${token['Authorization']}';
    request.fields['senderId'] = senderId;
    request.fields['receiverId'] = receiverId;
    request.fields['conversationId'] = conversationId;
    request.fields['messageType'] = 'image';
    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }

    for (var path in imagePaths) {
      print('Abhi:- Adding image to request: $path');
      request.files.add(await http.MultipartFile.fromPath('images', path));
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    print('Abhi:- Image message API response: ${response.statusCode}, ${responseBody.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(responseBody.body)['newMessage'];
    }
    throw Exception('Failed to send image message: ${responseBody.body}');
  }

  static Future<dynamic> sendDocumentMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required List<String> documentPaths,
    String? message,
  }) async {
    final token = await getToken();
    print('Abhi:- Sending document message: senderId=$senderId, receiverId=$receiverId, conversationId=$conversationId, documents=$documentPaths');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/messages'));

    request.headers['Authorization'] = 'Bearer ${token['Authorization']}';
    request.fields['senderId'] = senderId;
    request.fields['receiverId'] = receiverId;
    request.fields['conversationId'] = conversationId;
    request.fields['messageType'] = 'document';
    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }

    for (var path in documentPaths) {
      print('Abhi:- Adding document to request: $path');
      request.files.add(await http.MultipartFile.fromPath('documents', path));
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    print('Abhi:- Document message API response: ${response.statusCode}, ${responseBody.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(responseBody.body)['newMessage'];
    }
    throw Exception('Failed to send document message: ${responseBody.body}');
  }
}