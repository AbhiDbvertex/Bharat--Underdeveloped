import 'package:developer/directHiring/Consent/app_constants.dart';

class ApiUrl {
  static const String base = AppConstants.baseUrl;

  static String path(String endpoint) => "$base/$endpoint";

  static String emergencyOrderById = path("emergency-order/getEmergencyOrder");
}