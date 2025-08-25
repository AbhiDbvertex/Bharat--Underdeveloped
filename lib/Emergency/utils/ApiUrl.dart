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

  static String getAllOrder = path("emergency-order/getAllEmergencyOrdersByRole"); //POST
  static String createOrder = path("emergency-order/create"); //POST
  static String workCategory = path("work-category"); //GET
  static String emergencyOrderById = path("emergency-order/getEmergencyOrder"); //GET
  static String requestAcceptById = path("emergency-order/getAcceptedServiceProviders"); //GET
  static String assignEmergencyOrder = path("emergency-order/assignEmergencyOrder"); //POST

  static String completeOrderUser = path("emergency-order/completeOrderUser"); //POST
  static String addPaymentStage = path("emergency-order/addPaymentStage"); //POST
  static String requestRelease = path("emergency-order/user/request-release"); //POST





//////////////////////Service Provider///////////////////////////
  static String acceptUserOrder = path("emergency-order/accept-order"); //POST
  static String rejectUserOrder = path("emergency-order/reject-order"); //POST
  static String getAllSPOrderList = path("emergency-order/filtered-emergency-orders"); //GET
  static String getAllSpOrders = path("emergency-order/getAllEmergencyOrdersByRole"); //GET
  static String getSpEmergencyOrderById = path("emergency-order/getEmergencyOrder"); //GET

}