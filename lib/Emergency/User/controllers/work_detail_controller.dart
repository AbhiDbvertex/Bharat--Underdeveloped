
import 'dart:convert';

import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../directHiring/Consent/app_constants.dart';
import '../../utils/ApiUrl.dart';
import '../models/emergency_list_model.dart';
import '../models/work_detail_model.dart';
import 'emergency_service_controller.dart';

class WorkDetailController extends GetxController {
  //final  data;
  var isLoading = false.obs ;
  WorkDetailController();


  var imageUrls = <String>[].obs;
  var projectId = "".obs;
  var categoryName = "".obs;
  var subCategories = "".obs;
  var googleAddress = "".obs;
  var detailedAddress = "".obs;
  var contact = "".obs;
  var deadline = "".obs;
  var hireStatus = "".obs;
  var paymentAmount = 0.obs;
  var plateFormFee=0.obs;
  var currentImageIndex = 0.obs;
  var orderId="".obs;
  var acceptedByProviders = <Map<String, dynamic>>[].obs;
  var apiMessage = "".obs;
  var providerId = "".obs;
  var providerName = "".obs;
  var providerPhone = "".obs;
  var providerImage = "".obs;

  var tag="WorkDetailController";   // dots indicator ke liye


  @override
  void onInit() {
    super.onInit();


    // imageUrls.value = data.imageUrls; // ye ab sab images ko hold karega
    // projectId.value = data.projectId;
    // categoryName.value = data.categoryId.name;
    //
    // // take only first 2 subcategories
    // // if (data.subCategoryIds.isNotEmpty) {
    // //   final subNames = data.subCategoryIds.map((e) => e.name).toList();
    // //   subCategories.value = subNames.take(2).join(", ");
    // // } else {
    // //   subCategories.value = "N/A";
    // // }
    // if (data.subCategoryIds.isNotEmpty) {
    //   final subNames = data.subCategoryIds.map((e) => e.name).toList();
    //   subCategories.value = subNames.join(", ")+ "."; // take(2) remove kiya
    // } else {
    //   subCategories.value = "N/A";
    // }
    // googleAddress.value= data.googleAddress;
    // detailedAddress.value = data.detailedAddress;
    // contact.value = data.contact;
    // deadline.value = DateFormat('dd/MM/yyyy').format(data.deadline);
    // hireStatus.value =
    // "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}";
    // paymentAmount.value = data.servicePayment.amount;
    // orderId.value=data.id;
  }

  Future<String> cancelEmergencyOrder(String orderId)async {
    isLoading.value=true;
    bwDebug("[cancelEmergencyOrder]  orderId: $orderId ",tag:tag);
    //////////////
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    const String url = "${AppConstants.baseUrl}/emergency-order/cancel";

    isLoading.value=true;
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "order_id": orderId,
      }),
    );
    isLoading.value=false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      bwDebug("[cancelEmergencyOrder] Cancel Success: $data",tag: tag);
      await getEmergencyOrder(orderId);
      isLoading.value=false;
      return "Order cancelled successfully";
    } else {
      bwDebug("[cancelEmergencyOrder] Cancel Failed: ${response.body}",tag: tag);
isLoading.value=false;
      return "Order cancelled failed";
    }


    ///////////////
  }

  // Future<void> getEmergencyOrder(String orderId) async {
  //   var url = "${ApiUrl.emergencyOrderById}/$orderId";
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token') ?? '';
  //
  //   try {
  //     var response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         "Authorization": "Bearer ${token}", // agar token chaiye
  //         "Content-Type": "application/json",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       bwDebug("✅ Data: ${response.body}");
  //     } else {
  //       bwDebug("❌ Error: ${response.statusCode} ${response.body}");
  //     }
  //   } catch (e) {
  //     bwDebug("⚠️ Exception: $e");
  //   }
  // }
  Future<bool> getEmergencyOrder(String id) async {
    var result=false;
    isLoading.value=true;
    bwDebug("[getEmergencyOrder] call orderId:$id",tag: tag);
    var url = "${ApiUrl.emergencyOrderById}/$id";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      bwDebug("[getEmergencyOrder]: response: ${response.body}",tag: tag );

      if (response.statusCode == 200) {

        final json = jsonDecode(response.body);
        final dataModel = WorkDetailModel.fromJson(json);
        final serviceProvider=dataModel.data?.serviceProvider;

        imageUrls.value = dataModel.data?.imageUrls ?? [];
        projectId.value = dataModel.data?.projectId ?? "";
        categoryName.value = dataModel.data?.categoryId?.name ?? "";
        subCategories.value = dataModel.data?.subCategoryIds
            ?.map((e) => e.name)
            .join(", ") ?? "";
        googleAddress.value = dataModel.data?.googleAddress ?? "";
        detailedAddress.value = dataModel.data?.detailedAddress ?? "";
        contact.value = dataModel.data?.contact ?? "";
        providerId.value = serviceProvider?.id ?? "";
        providerName.value = serviceProvider?.fullName ?? "";
        providerPhone.value = serviceProvider?.phone ?? "";
        providerImage.value = serviceProvider?.profilePic ?? "";

        deadline.value = (dataModel.data?.deadline != null && dataModel.data!.deadline!.isNotEmpty)
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(dataModel.data!.deadline!))
            : "";

        hireStatus.value = (dataModel.data is Data)
            ? dataModel.data?.hireStatus ?? ""
            : "";
        paymentAmount.value = dataModel.data?.servicePayment?.amount ?? 0;
        plateFormFee.value = dataModel.data?.platformFee ?? 0;
        orderId.value = dataModel.data?.id ?? "";
        acceptedByProviders.value =
            dataModel.data?.acceptedByProviders?.map((e) => {
              "provider": e.provider,
              "status": e.status,
              "id": e.id,
            }).toList() ??
                [];
        apiMessage.value = json["message"] ?? "";
        result=true;
      } else {
        bwDebug("❌ Error: ${response.statusCode} ${response.body}", tag: tag);
        result=false;
      }
    } catch (e) {

      result=false;
      bwDebug("⚠️ Exception: $e", tag: tag);
    }finally{
      isLoading.value=false;

    }
    return result;
  }



  ///////////////////////////////Service Provider/////////////////////////
  Future<String> acceptUserOrder(String orderId) async {


    try {
      isLoading.value=true;
      bwDebug("[acceptUserOrder] call orderId:$orderId",tag: tag);
      var url = "${ApiUrl.acceptUserOrder}/$orderId";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? "Success";
//        final dataModel = WorkDetailModel.fromJson(json);
        bwDebug("[acceptUserOrder]response:  ${response.statusCode} ${response.body}", tag: tag);
        return message;
      } else {
        bwDebug("[acceptUserOrder]❌ Error: ${response.statusCode} ${response.body}", tag: tag);
        try {
          final json = jsonDecode(response.body);
          return json['message'] ?? "Something went wrong";
        } catch (_) {
          return "Something went wrong";
        }
      }
    } catch (e) {

      bwDebug("[acceptUserOrder]⚠️ Exception: $e", tag: tag);
      return "Exception: $e";
    }finally{
      isLoading.value=false;

    }
  }
  Future<String> rejectUserOrder(String orderId) async {
    try {
      isLoading.value = true;
      bwDebug("[rejectUserOrder] call orderId:$orderId", tag: tag);

      var url = "${ApiUrl.rejectUserOrder}/$orderId";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // get message from response
        final message = json['message'] ?? "Success";

        bwDebug("[rejectUserOrder] ✅ response: ${response.statusCode} ${response.body}", tag: tag);

        return message; // return message here
      } else {
        bwDebug("[rejectUserOrder] ❌ Error: ${response.statusCode} ${response.body}", tag: tag);

        // try to extract message if present
        try {
          final json = jsonDecode(response.body);
          return json['message'] ?? "Something went wrong";
        } catch (_) {
          return "Something went wrong";
        }
      }
    } catch (e) {
      bwDebug("[rejectUserOrder] ⚠️ Exception: $e", tag: tag);
      return "Exception: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
