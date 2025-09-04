// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class PromotionController extends GetxController {
// //   RxList<File> selectedImages = <File>[].obs;
// //   RxBool isPromoting = false.obs;
// //
// //   Future<bool> submitForm(Map<String, dynamic> promotionForm) async {
// //     print("dss :- ${promotionForm['description']}");
// //     print("dss :- ${promotionForm['whyPromote']}");
// //     print("dss :- ${promotionForm['images']}");
// //     final uri = Uri.parse('https://api.thebharatworks.com/api/promotion/create');
// //     try {
// //       final request = http.MultipartRequest('POST', uri);
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token') ?? '';
// //       //Optional headers (e.g., auth). DON'T set Content-Type; http sets it.
// //
// //         request.headers['Authorization'] = 'Bearer $token';
// //
// //
// //       // Text fields
// //       request.fields['description'] = promotionForm['description'];
// //       request.fields['title'] = promotionForm['whyPromote'];
// //       request.fields['phone'] = promotionForm['whyPromote'];
// //       request.fields['paymentId'] = promotionForm['whyPromote'];
// //
// //       // Files
// //       for (final file in promotionForm['images']) {
// //         request.files.add(
// //           await http.MultipartFile.fromPath("images", file.path),
// //         );
// //       }
// //
// //       // Send
// //       final rawResponse = await request.send();
// //       print(rawResponse.toString());
// //       if (rawResponse.statusCode == 201) {
// //         // Convert StreamedResponse → normal Response
// //         var response = await http.Response.fromStream(rawResponse);
// //
// //         // Decode JSON
// //         final decodedData = jsonDecode(response.body);
// //         if(decodedData['success'] == true){
// //           print('dss :- Request Sent successfully ${decodedData['message']}');
// //           return decodedData['success'];
// //         }
// //       } else {
// //         return false;
// //       }
// //       return false;
// //     } catch (e) {
// //       print('Somthing went wrong whle sending promotion from ${e.toString}');
// //       return false;
// //     }
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PromotionController extends GetxController {
//   RxList<File> selectedImages = <File>[].obs;
//   RxBool isPromoting = false.obs;
//
//   Future<bool> submitForm(Map<String, dynamic> promotionForm) async {
//     // Debug prints for checking data
//     print("dss :- Description: ${promotionForm['description']}");
//     print("dss :- Why Promote: ${promotionForm['whyPromote']}");
//     print("dss :- Phone: ${promotionForm['phone']}");
//     print("dss :- Payment ID: ${promotionForm['paymentId']}");
//     print("dss :- Amount: ${promotionForm['amount']}");
//     print("dss :- Images: ${promotionForm['images']}");
//
//     final uri = Uri.parse('https://api.thebharatworks.com/api/promotion/create');
//     try {
//       final request = http.MultipartRequest('POST', uri);
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       request.headers['Authorization'] = 'Bearer $token';
//
//       // Text fields set karo
//       request.fields['description'] = promotionForm['description'];
//       request.fields['title'] = promotionForm['whyPromote'];
//       request.fields['phone'] = promotionForm['phone']; // UI se phone
//       request.fields['paymentId'] = promotionForm['paymentId']; // Razorpay payment ID
//       request.fields['amount'] = promotionForm['amount'].toString(); // Static amount as string
//
//       // Images add karo
//       for (final file in promotionForm['images']) {
//         request.files.add(
//           await http.MultipartFile.fromPath("images", file.path),
//         );
//       }
//
//       // Request bhejo
//       final rawResponse = await request.send();
//       print("dss :- Response Status: ${rawResponse.statusCode}");
//       if (rawResponse.statusCode == 201) {
//         var response = await http.Response.fromStream(rawResponse);
//         final decodedData = jsonDecode(response.body);
//         if (decodedData['success'] == true) {
//           print('dss :- Promotion created: ${decodedData['message']}');
//           selectedImages.clear(); // Clear images
//           Get.back();
//           return true;
//         }
//
//       }
//       return false;
//     } catch (e) {
//       print('Error in promotion API: $e');
//       return false;
//     } finally {
//       isPromoting.value = false; // Always false karo
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PromotionController extends GetxController {
  RxList<File> selectedImages = <File>[].obs;
  RxBool isPromoting = false.obs;

  Future<bool> submitForm(Map<String, dynamic> promotionForm) async {
    // Debug prints for checking data
    print("dss :- Description: ${promotionForm['description']}");
    print("dss :- Why Promote: ${promotionForm['whyPromote']}");
    print("dss :- Phone: ${promotionForm['phone']}");
    print("dss :- Payment ID: ${promotionForm['paymentId']}");
    print("dss :- Amount: ${promotionForm['amount']}");
    print("dss :- Images: ${promotionForm['images']}");

    final uri = Uri.parse('https://api.thebharatworks.com/api/promotion/create');
    try {
      final request = http.MultipartRequest('POST', uri);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      request.headers['Authorization'] = 'Bearer $token';

      // Text fields set karo
      request.fields['description'] = promotionForm['description'];
      request.fields['title'] = promotionForm['whyPromote'];
      request.fields['phone'] = promotionForm['phone']; // UI se phone
      request.fields['paymentId'] = promotionForm['paymentId']; // Razorpay payment ID
      request.fields['amount'] = promotionForm['amount'].toString(); // Static amount as string

      // Images add karo
      for (final file in promotionForm['images']) {
        request.files.add(
          await http.MultipartFile.fromPath("images", file.path),
        );
      }

      // Request bhejo
      final rawResponse = await request.send();
      print("dss :- Response Status: ${rawResponse.statusCode}");
      if (rawResponse.statusCode == 201) {
        var response = await http.Response.fromStream(rawResponse);
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('dss :- Promotion created: ${decodedData['message']}');
          Get.back();
          selectedImages.clear(); // Images clear karo
           // API success par screen back karo
          Get.snackbar("Success", "Promotion submitted successfully!",
              backgroundColor: Colors.green, colorText: Colors.white,snackPosition: SnackPosition.BOTTOM); // Success snackbar
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error in promotion API: $e');
      return false;
    } finally {
      isPromoting.value = false; // Always false karo
    }
  }
}