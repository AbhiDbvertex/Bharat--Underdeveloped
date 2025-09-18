import 'package:http/http.dart' as http;
import 'dart:convert';

import '../directHiring/Consent/app_constants.dart';


class ApiService {
  static String baseUrl = 'https://api.thebharatworks.com/api/chat';
  static Future<Map<String, String>> getToken() => getCustomHeaders();

  // Conversations fetch kar
  static Future<List<dynamic>> fetchConversations(String userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['conversations'] ?? [];
    }
    throw Exception('Failed to load conversations');
  }

  // Messages fetch kar
  static Future<List<dynamic>> fetchMessages(String conversationId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['messages'] ?? [];
    }
    throw Exception('Failed to load messages');
  }

  // New conversation start kar
  static Future<dynamic> startConversation(String senderId, String receiverId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({'senderId': senderId, 'receiverId': receiverId}),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body)['conversation'];
    }
    throw Exception('Failed to start conversation');
  }

  // Text message send kar
  static Future<dynamic> sendTextMessage(Map<String, dynamic> messageData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(messageData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body)['newMessage'];
    }
    throw Exception('Failed to send message');
  }

  // Image message send kar (http MultipartRequest ke saath)
  static Future<dynamic> sendImageMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required List<String> imagePaths, // File paths from image_picker
    String? message, // Optional text with images
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/messages'));

    // Headers set kar
    request.headers['Authorization'] = 'Bearer $token';

    // Form fields add kar
    request.fields['senderId'] = senderId;
    request.fields['receiverId'] = receiverId;
    request.fields['conversationId'] = conversationId;
    request.fields['messageType'] = 'image';
    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }

    // Images add kar
    for (var path in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', path)); // Backend ke field name ke hisaab se 'images'
    }

    // Request bhej
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 201) {
      return json.decode(responseBody.body)['newMessage'];
    }
    throw Exception('Failed to send image message: ${responseBody.body}');
  }
}