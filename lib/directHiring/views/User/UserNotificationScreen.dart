import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import 'package:intl/intl.dart';
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      title: json['title'],
      message: json['message'],
      createdAt: json['createdAt'],
    );
  }
}

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("❌ Token not found in SharedPreferences.");
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse(
      'https://api.thebharatworks.com/api/user/getAllNotification',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("noti  STATUS CODE: ${response.statusCode}");
      print("📦 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> notifList = data['notifications'];
          setState(() {
            notifications =
                notifList
                    .map((json) => NotificationModel.fromJson(json))
                    .toList();
            isLoading = false;
          });
        } else {
          print("❌ API returned success: false");
          setState(() => isLoading = false);
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Notification",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
        
            const SizedBox(height: 20),
            isLoading
                ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
                : notifications.isEmpty
                ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/notification.png', height: 250),
                      const SizedBox(height: 20),
                      Text(
                        'No Notification Available',
                        style: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final date = DateTime.parse(notif.createdAt).toLocal();
                      final formatted = DateFormat('yyyy-MM-dd hh:mm a').format(date);
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            notif.title,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notif.message),
                              const SizedBox(height: 4),
                              Text(
                                // notif.createdAt.substring(0, 10),
                                // "${dateFormat('yyyy-MM-dd – kk:mm').format()}",
                                "${formatted}",
        
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
