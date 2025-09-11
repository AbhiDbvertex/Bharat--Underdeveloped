import 'dart:convert';

import 'package:developer/Emergency/User/controllers/work_detail_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/ApiUrl.dart';
import '../../utils/logger.dart';
import '../models/request_accepted_model.dart';

class RequestController extends GetxController {
  final tag = "RequestController";
  var isFetchingRequests = false.obs;
  var isHiring = false.obs;

  var requestAcceptedModel = Rxn<RequestAcceptedModel>();
  var errorMessage = ''.obs;

  var assignOrderResponse = AssignOrderResponse(status: false, message: "").obs;

  final workDetailController = Get.find<WorkDetailController>();

  Future<void> getRequestAccepted(String id) async {
    bwDebug("[getRequestAccept] call orderId:$id", tag: tag);

    try {
      isFetchingRequests.value = true;
      //workDetailController.isLoading.value=true;
      var url = "${ApiUrl.requestAcceptById}/$id";

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      bwDebug("[getRequestAccept] final url :$url,token: $token", tag: tag);

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      bwDebug(
          "[getRequestAccept] response status: ${response.statusCode}\n response Body ${response.body}",
          tag: tag);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        requestAcceptedModel.value = RequestAcceptedModel.fromJson(data);
      } else {
        bwDebug("Error: ${response.body}");
        errorMessage.value =
            "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      bwDebug("[getRequestAccept] error : $e  ", tag: tag);
      errorMessage.value = "Exception: $e";
    } finally {
      // workDetailController.isLoading.value = false;
      isFetchingRequests.value = false;
    }
  }

  // Future<void> fetchRequests() async {
  //   try {
  //     isLoading.value = true;
  //     await Future.delayed(const Duration(seconds: 1)); // thoda loading dikhane ke liye
  //     requests.value = [
  //       RequestAcceptedModel(
  //         id: "1",
  //         name: "Rahul Sharma",
  //         amount: 2500,
  //         location: "Delhi, India",
  //         imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
  //         status: "Active",
  //       ),
  //       RequestAcceptedModel(
  //         id: "2",
  //         name: "Priya Verma",
  //         amount: 1800,
  //         location: "Mumbai, India",
  //         imageUrl: "https://randomuser.me/api/portraits/women/44.jpg",
  //         status: "Active",
  //       ),
  //       RequestAcceptedModel(
  //         id: "3",
  //         name: "Aman Gupta",
  //         amount: 3200,
  //         location: "Bangalore, India",
  //         imageUrl: "https://randomuser.me/api/portraits/men/12.jpg",
  //         status: "Pending",
  //       ),
  //     ];
  //     //var response = await Dio().get(apiUrl);
  //
  //     // if (response.statusCode == 200) {
  //     //   var data = response.data as List; // assuming API returns a list
  //     //   requests.value =
  //     //       data.map((e) => RequestAcceptedModel.fromJson(e)).toList();
  //     // } else {
  //     //   print("Error: ${response.statusMessage}");
  //     // }
  //   } catch (e) {
  //     print("Exception: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> assignEmergencyOrder(
      {required String orderId, required String serviceProviderId}) async {
    bwDebug(
        "[assignEmergencyOrder] call orderId:$orderId, serviceProvider:$serviceProviderId",
        tag: tag);

    try {
      isHiring.value = true;
      // workDetailController.isLoading.value = true;
      var url = "${ApiUrl.assignEmergencyOrder}/$orderId";

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      bwDebug("[assignEmergencyOrder] final url :$url, token: $token",
          tag: tag);

      final body = jsonEncode({
        "service_provider_id": serviceProviderId,
      });

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      bwDebug(
          "[assignEmergencyOrder] response status: ${response.statusCode}\n response Body ${response.body}",
          tag: tag);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        assignOrderResponse.value = AssignOrderResponse.fromJson(data);

        if (assignOrderResponse.value.status) {
          bwDebug(
              "[assignEmergencyOrder] SUCCESS: ${assignOrderResponse.value.message}",
              tag: tag);

        } else {
          errorMessage.value = assignOrderResponse.value.message;
        }

      }
      else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final String message = data['message'] ?? 'Unknown error';
        if (message.contains("This order is already assigned.")) {
          errorMessage.value = "This order is already assigned to someone.";
        }

      }
      else {
        bwDebug("Error: ${response.body}");
        errorMessage.value =
            "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
     // await workDetailController.getEmergencyOrder(orderId);
    } catch (e) {
      bwDebug("[assignEmergencyOrder] error : $e", tag: tag);
      errorMessage.value = "Exception: $e";
    } finally {
      // workDetailController.isLoading.value = false;
      await workDetailController.getEmergencyOrder(orderId);
    isHiring.value = false;


    }
  }
}
