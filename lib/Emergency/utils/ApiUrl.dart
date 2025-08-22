import 'package:developer/directHiring/Consent/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiUrl {

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }
  static const String base = AppConstants.baseUrl;

  static String path(String endpoint) => "$base/$endpoint";

  static String emergencyOrderById = path("emergency-order/getEmergencyOrder"); //GET
  static String requestAcceptById = path("emergency-order/getAcceptedServiceProviders"); //GET
  static String assignEmergencyOrder = path("emergency-order/assignEmergencyOrder"); //POST

  static String completeOrderUser = path("emergency-order/completeOrderUser"); //POST





//////////////////////Service Provider///////////////////////////
  static String acceptUserOrder = path("emergency-order/accept-order"); //POST
  static String rejectUserOrder = path("emergency-order/reject-order"); //POST

}