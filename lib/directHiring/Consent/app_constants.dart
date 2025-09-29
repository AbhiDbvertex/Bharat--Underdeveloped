import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
    static const String baseUrl = 'https://api.thebharatworks.com/api';
  static const String baseImageUrl = 'https://api.thebharatworks.com';
}


Future<Map<String, String>> getCustomHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception("No auth token found");
  }

  return {
    'Content-Type': 'application/json', // optional
    'Accept': 'application/json',       // optional
    'Authorization': 'Bearer $token',
  };
}
