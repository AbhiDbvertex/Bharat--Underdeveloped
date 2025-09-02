// import 'dart:convert';
// import 'package:developer/Emergency/Service_Provider/models/sp_emergency_list_model.dart';
// import 'package:developer/Emergency/utils/ApiUrl.dart';
// import 'package:developer/Emergency/utils/logger.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../User/models/create_order_model.dart';
// class SpEmergencyServiceController extends GetxController {
//
//   final String tag="SpEmergencyServiceController";
//   var isLoading = false.obs ;
//
//   var orders = <SpEmergencyOrderData>[].obs;
//   @override
//   void onInit() {
//     super.onInit();
//     getEmergencySpOrderList();
//   }
//
//   // /// ------------------ API CALLS -------------------
//
//   @override
//   void onClose() {
//     super.onClose();
//   }
//
//
// //   Future<SpEmergencyListModel?> getEmergencySpOrder() async {
// //     isLoading.value=true;
// //     bwDebug("[getEmergencySpOrder] call: ",tag:tag);
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token') ?? '';
// //
// //       final res = await http.get(
// //         Uri.parse(ApiUrl.getAllSpOrders),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //
// //
// //       );
// //       if (res.statusCode == 200) {
// //         final decoded = json.decode(res.body);
// //         bwDebug("[getEmergencySpOrder] data : ${res.body}", tag: tag);
// //
// //         isLoading.value=false;
// //         return SpEmergencyListModel.fromJson(decoded);
// //
// //       } else {
// //         isLoading.value=false;
// //         return null;
// //       }
// //     }  catch (e) {
// // bwDebug("[getEmergencySpOrder], error : $e");
// //     }
// // finally{
// //       isLoading.value=false;
// // }
// //     return null;
// //   }
//
//   // Future<SpEmergencyListModel?> getEmergencySpOrderList() async {
//   //   isLoading.value=true;
//   //   bwDebug("[getEmergencySpOrderList] call: ",tag:tag);
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('token') ?? '';
//   //
//   //     final res = await http.get(
//   //       Uri.parse(ApiUrl.getAllSPOrderList),
//   //       headers: {
//   //         'Authorization': 'Bearer $token',
//   //         'Content-Type': 'application/json',
//   //       },
//   //
//   //
//   //     );
//   //     if (res.statusCode == 200) {
//   //       final decoded = json.decode(res.body);
//   //       bwDebug("[getEmergencySpOrderList] data : ${res.body}", tag: tag);
//   //
//   //       isLoading.value=false;
//   //       return SpEmergencyListModel.fromJson(decoded);
//   //
//   //     } else {
//   //       isLoading.value=false;
//   //       return null;
//   //     }
//   //   }  catch (e) {
//   //     bwDebug("[getEmergencySpOrderList], error : $e");
//   //   }
//   //   finally{
//   //     isLoading.value=false;
//   //   }
//   //   return null;
//   // }
//
//
//   Future<SpEmergencyListModel?> getEmergencySpOrderByRole() async {
//     bwDebug("[getEmergencySpOrder] call: ",tag:tag);
//     return await _fetchOrders(ApiUrl.getAllSpOrders);
//   }
//
//   Future<SpEmergencyListModel?> getEmergencySpOrderList() async {
//     bwDebug("[getEmergencySpOrderList] call: ",tag:tag);
//     return await _fetchOrders(ApiUrl.getAllSPOrderList);
//   }
//
//   Future<SpEmergencyListModel?> _fetchOrders(String url) async {
//     isLoading.value = true;
//     bwDebug("[_fetchOrders] API call started: $url", tag: tag);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       bwDebug("[_fetchOrders] token: $token", tag: tag);
//
//       final res = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       bwDebug("[_fetchOrders] statusCode: ${res.statusCode}", tag: tag);
//
//       if (res.statusCode == 200) {
//         bwDebug("[_fetchOrders] response: ${res.body}", tag: tag);
//
//         final decoded = json.decode(res.body);
//         final model = SpEmergencyListModel.fromJson(decoded);
//
//         bwDebug("[_fetchOrders] parsed model: ${model.toJson()}", tag: tag);
//         return model;
//       } else {
//         bwDebug("[_fetchOrders] failed with body: ${res.body}", tag: tag);
//         return null;
//       }
//     } catch (e, stack) {
//       bwDebug("[_fetchOrders] exception: $e", tag: tag);
//       bwDebug("[_fetchOrders] stacktrace: $stack", tag: tag);
//     } finally {
//       isLoading.value = false;
//       bwDebug("[_fetchOrders] API call completed", tag: tag);
//     }
//     return null;
//   }
//
// }
/////////////
import 'dart:convert';
import 'package:developer/Emergency/Service_Provider/models/sp_emergency_list_model.dart';
import 'package:developer/Emergency/utils/ApiUrl.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpEmergencyServiceController extends GetxController {
  final String tag = "SpEmergencyServiceController";
  var isLoading = false.obs;
  var orders = <SpEmergencyOrderData>[].obs;
  // @override
  // void onInit() {
  //   super.onInit();
  //
  //   // if (orders.isEmpty && !isLoading.value) {
  //   //   getEmergencySpOrderList();
  //   // }
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (orders.isEmpty && !isLoading.value) {
  //       getEmergencySpOrderList();
  //     }
  //   });
  // }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getEmergencySpOrderList() async {
    bwDebug("[getEmergencySpOrderList] call:", tag: tag);
    final result = await _fetchOrders(ApiUrl.getAllSPOrderList);
    if (result != null && result.status) {
      orders.assignAll(result.data); // Update reactive list
      bwDebug("[getEmergencySpOrderList] orders fetched: ${orders.length}", tag: tag);
    } else {
      orders.clear(); // Clear list if no data
      bwDebug("[getEmergencySpOrderList] no data or error", tag: tag);
    }
  }

  Future<SpEmergencyOrderListModel?> getEmergencySpOrderByRole() async {
    bwDebug("[getEmergencySpOrder] call:", tag: tag);
    return await _fetchOrders(ApiUrl.getAllSpOrders);
  }

  Future<SpEmergencyOrderListModel?> _fetchOrders(String url) async {
    isLoading.value = true;
    bwDebug("[_fetchOrders] API call started: $url", tag: tag);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        bwDebug("[_fetchOrders] no token found", tag: tag);
        Get.snackbar('Error', 'No authentication token found. Please log in.');
        return null;
      }

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30), onTimeout: () {
        bwDebug("[_fetchOrders] request timed out", tag: tag);
        Get.snackbar('Error', 'Request timed out. Please try again.');
        return http.Response('Timeout', 408);
      });

      bwDebug("[_fetchOrders] statusCode: ${res.statusCode}", tag: tag);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        print('dssss :- $decoded');
        if (decoded is Map<String, dynamic>) {
          final model = SpEmergencyOrderListModel.fromJson(decoded);
          bwDebug("[_fetchOrders] parsed model: ${model.toJson()}", tag: tag);
          return model;
        } else {
          bwDebug("[_fetchOrders] invalid response format: ${res.body}", tag: tag);
          Get.snackbar('Error', 'Invalid response from server');
          return null;
        }
      } else {
        bwDebug("[_fetchOrders] failed with body: ${res.body}", tag: tag);
        // Get.snackbar('Error', 'Failed to fetch orders: ${res.body}');
        return null;
      }
    } catch (e, stack) {
      bwDebug("[_fetchOrders] exception: $e", tag: tag);
      bwDebug("[_fetchOrders] stacktrace: $stack", tag: tag);
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
      bwDebug("[_fetchOrders] API call completed", tag: tag);
    }
    return null;
  }
}