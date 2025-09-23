//
// import 'dart:convert';
//
// import 'package:developer/Emergency/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../directHiring/Consent/app_constants.dart';
// import '../../utils/ApiUrl.dart';
// import '../models/emergency_list_model.dart';
// import '../models/work_detail_model.dart';
// import 'emergency_service_controller.dart';
//
// class WorkDetailController extends GetxController {
//   //final  data;
//   var isLoading = false.obs ;
//   WorkDetailController();
//
//
//   var imageUrls = <String>[].obs;
//   var projectId = "".obs;
//   var categoryName = "".obs;
//   var subCategories = "".obs;
//   var googleAddress = "".obs;
//   var detailedAddress = "".obs;
//   var contact = "".obs;
//   var deadline = "".obs;
//   var hireStatus = "".obs;
//   var paymentAmount = 0.obs;
//   var plateFormFee=0.obs;
//   var currentImageIndex = 0.obs;
//   var orderId="".obs;
//   var acceptedByProviders = <Map<String, dynamic>>[].obs;
//   var apiMessage = "".obs;
//
//   var providerId = "".obs;
//   var providerName = "".obs;
//   var providerPhone = "".obs;
//   var providerImage = "".obs;
//
//
//   var tag="WorkDetailController";   // dots indicator ke liye
//
//
//   @override
//   void onInit() {
//     super.onInit();
//
//
//     // imageUrls.value = data.imageUrls; // ye ab sab images ko hold karega
//     // projectId.value = data.projectId;
//     // categoryName.value = data.categoryId.name;
//     //
//     // // take only first 2 subcategories
//     // // if (data.subCategoryIds.isNotEmpty) {
//     // //   final subNames = data.subCategoryIds.map((e) => e.name).toList();
//     // //   subCategories.value = subNames.take(2).join(", ");
//     // // } else {
//     // //   subCategories.value = "N/A";
//     // // }
//     // if (data.subCategoryIds.isNotEmpty) {
//     //   final subNames = data.subCategoryIds.map((e) => e.name).toList();
//     //   subCategories.value = subNames.join(", ")+ "."; // take(2) remove kiya
//     // } else {
//     //   subCategories.value = "N/A";
//     // }
//     // googleAddress.value= data.googleAddress;
//     // detailedAddress.value = data.detailedAddress;
//     // contact.value = data.contact;
//     // deadline.value = DateFormat('dd/MM/yyyy').format(data.deadline);
//     // hireStatus.value =
//     // "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}";
//     // paymentAmount.value = data.servicePayment.amount;
//     // orderId.value=data.id;
//   }
//
//   Future<String> cancelEmergencyOrder(String orderId)async {
//     isLoading.value=true;
//     bwDebug("[cancelEmergencyOrder]  orderId: $orderId ",tag:tag);
//     //////////////
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     const String url = "${AppConstants.baseUrl}/emergency-order/cancel";
//
//     isLoading.value=true;
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode({
//         "order_id": orderId,
//       }),
//     );
//     isLoading.value=false;
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       bwDebug("[cancelEmergencyOrder] Cancel Success: $data",tag: tag);
//       await getEmergencyOrder(orderId);
//       isLoading.value=false;
//       return "Order cancelled successfully";
//     } else {
//       bwDebug("[cancelEmergencyOrder] Cancel Failed: ${response.body}",tag: tag);
// isLoading.value=false;
//       return "Order cancelled failed";
//     }
//
//
//     ///////////////
//   }
//
//   // Future<void> getEmergencyOrder(String orderId) async {
//   //   var url = "${ApiUrl.emergencyOrderById}/$orderId";
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('token') ?? '';
//   //
//   //   try {
//   //     var response = await http.get(
//   //       Uri.parse(url),
//   //       headers: {
//   //         "Authorization": "Bearer ${token}", // agar token chaiye
//   //         "Content-Type": "application/json",
//   //       },
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       bwDebug("✅ Data: ${response.body}");
//   //     } else {
//   //       bwDebug("❌ Error: ${response.statusCode} ${response.body}");
//   //     }
//   //   } catch (e) {
//   //     bwDebug("⚠️ Exception: $e");
//   //   }
//   // }
//   Future<bool> getEmergencyOrder(String id) async {
//     var result=false;
//     isLoading.value=true;
//     bwDebug("[getEmergencyOrder] call orderId:$id",tag: tag);
//     var url = "${ApiUrl.emergencyOrderById}/$id";
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );
//       bwDebug("[getEmergencyOrder]: response: ${response.body}",tag: tag );
//
//       if (response.statusCode == 200) {
//
//         final json = jsonDecode(response.body);
//         final dataModel = WorkDetailModel.fromJson(json);
//         final serviceProvider=dataModel.data?.serviceProvider;
//
//         imageUrls.value = dataModel.data?.imageUrls ?? [];
//         projectId.value = dataModel.data?.projectId ?? "";
//         categoryName.value = dataModel.data?.categoryId?.name ?? "";
//         subCategories.value = dataModel.data?.subCategoryIds
//             ?.map((e) => e.name)
//             .join(", ") ?? "";
//         googleAddress.value = dataModel.data?.googleAddress ?? "";
//         detailedAddress.value = dataModel.data?.detailedAddress ?? "";
//         contact.value = dataModel.data?.contact ?? "";
//         providerId.value = serviceProvider?.id ?? "";
//         providerName.value = serviceProvider?.fullName ?? "";
//         providerPhone.value = serviceProvider?.phone ?? "";
//         providerImage.value = serviceProvider?.profilePic ?? "";
//
//         deadline.value = (dataModel.data?.deadline != null && dataModel.data!.deadline!.isNotEmpty)
//             ? DateFormat('dd/MM/yyyy').format(DateTime.parse(dataModel.data!.deadline!))
//             : "";
//
//         hireStatus.value = (dataModel.data is Data)
//             ? dataModel.data?.hireStatus ?? ""
//             : "";
//         paymentAmount.value = dataModel.data?.servicePayment?.amount ?? 0;
//
//         plateFormFee.value = dataModel.data?.platformFee ?? 0;
//
//         orderId.value = dataModel.data?.id ?? "";
//         acceptedByProviders.value =
//             dataModel.data?.acceptedByProviders?.map((e) => {
//               "provider": e.provider,
//               "status": e.status,
//               "id": e.id,
//             }).toList() ??
//                 [];
//         apiMessage.value = json["message"] ?? "";
//
//         result=true;
//
//       } else {
//         bwDebug("❌ Error: ${response.statusCode} ${response.body}", tag: tag);
//         result=false;
//       }
//     } catch (e) {
//
//       result=false;
//       bwDebug("⚠️ Exception: $e", tag: tag);
//     }finally{
//       isLoading.value=false;
//
//     }
//
//     return result;
//
//   }
//
//
//
//   ///////////////////////////////Service Provider/////////////////////////
//   Future<String> acceptUserOrder(String orderId) async {
//
//
//     try {
//       isLoading.value=true;
//       bwDebug("[acceptUserOrder] call orderId:$orderId",tag: tag);
//       var url = "${ApiUrl.acceptUserOrder}/$orderId";
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//
//       );
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         final message = json['message'] ?? "Success";
// //        final dataModel = WorkDetailModel.fromJson(json);
//         bwDebug("[acceptUserOrder]response:  ${response.statusCode} ${response.body}", tag: tag);
//         return message;
//       } else {
//         bwDebug("[acceptUserOrder]❌ Error: ${response.statusCode} ${response.body}", tag: tag);
//         try {
//           final json = jsonDecode(response.body);
//           return json['message'] ?? "Something went wrong";
//         } catch (_) {
//           return "Something went wrong";
//         }
//       }
//     } catch (e) {
//
//       bwDebug("[acceptUserOrder]⚠️ Exception: $e", tag: tag);
//       return "Exception: $e";
//     }finally{
//       isLoading.value=false;
//
//     }
//   }
//   Future<String> rejectUserOrder(String orderId) async {
//     try {
//       isLoading.value = true;
//       bwDebug("[rejectUserOrder] call orderId:$orderId", tag: tag);
//
//       var url = "${ApiUrl.rejectUserOrder}/$orderId";
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//
//         // get message from response
//         final message = json['message'] ?? "Success";
//
//         bwDebug("[rejectUserOrder] ✅ response: ${response.statusCode} ${response.body}", tag: tag);
//
//         return message; // return message here
//       } else {
//         bwDebug("[rejectUserOrder] ❌ Error: ${response.statusCode} ${response.body}", tag: tag);
//
//         // try to extract message if present
//         try {
//           final json = jsonDecode(response.body);
//           return json['message'] ?? "Something went wrong";
//         } catch (_) {
//           return "Something went wrong";
//         }
//       }
//     } catch (e) {
//       bwDebug("[rejectUserOrder] ⚠️ Exception: $e", tag: tag);
//       return "Exception: $e";
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

//////////////////////////////

///////////////////

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/work_detail_model.dart';
// import '../models/task_view_model.dart';
// import '../../utils/ApiUrl.dart';
// import '../../utils/logger.dart';
// import '../../utils/assets.dart';
// import '../../utils/size_ratio.dart';
// import '../../../directHiring/Consent/app_constants.dart';
// import 'emergency_service_controller.dart';
//
// class WorkDetailController extends GetxController {
//   var isLoading = false.obs;
//   var tag = "WorkDetailController";
//   static const double _taxPercentage = 0.18;
//
//   // Data from API (already present)
//   var imageUrls = <String>[].obs;
//   var projectId = "".obs;
//   var categoryName = "".obs;
//   var subCategories = "".obs;
//   var googleAddress = "".obs;
//   var detailedAddress = "".obs;
//   var contact = "".obs;
//   var deadline = "".obs;
//   var hireStatus = "".obs;
//   var paymentAmount = 0.obs;
//   var plateFormFee = 0.obs;
//   var orderId = "".obs;
//   var acceptedByProviders = <Map<String, dynamic>>[].obs;
//   var apiMessage = "".obs;
//   var providerId = "".obs;
//   var providerName = "".obs;
//   var providerPhone = "".obs;
//   var providerImage = "".obs;
//   var assignedWorker = AssignedWorker().obs;
//   var warningMessage = "Lorem ipsum dolor sit amet consectetur.".obs;
//
//   var payments = <PaymentHistory>[].obs;
//   var selectedPaymentIndex = (-1).obs;
//   var isCreatingNewPayment = false.obs;
//   final descriptionController = TextEditingController();
//   final amountController = TextEditingController();
//   final emergencyServiceController = Get.find<EmergencyServiceController>();
//
//   WorkDetailController();
//
//   @override
//   void onInit() {
//     super.onInit();
//   }
//
//   @override
//   void onClose() {
//     descriptionController.dispose();
//     amountController.dispose();
//     super.onClose();
//   }
//
//   // API Call to get work details
//   Future<bool> getEmergencyOrder(String id) async {
//     var result = false;
//     isLoading.value = true;
//     bwDebug("[getEmergencyOrder] call orderId:$id", tag: tag);
//     var url = "${ApiUrl.emergencyOrderById}/$id";
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );
//       bwDebug("[getEmergencyOrder]: response: ${response.body}", tag: tag);
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         final dataModel = WorkDetailModel.fromJson(json);
//         final serviceProvider = dataModel.data?.serviceProvider;
//
//         imageUrls.value = dataModel.data?.imageUrls ?? [];
//         projectId.value = dataModel.data?.projectId ?? "";
//         categoryName.value = dataModel.data?.categoryId?.name ?? "";
//         subCategories.value = dataModel.data?.subCategoryIds
//             ?.map((e) => e.name)
//             .join(", ") ?? "";
//         googleAddress.value = dataModel.data?.googleAddress ?? "";
//         detailedAddress.value = dataModel.data?.detailedAddress ?? "";
//         contact.value = dataModel.data?.contact ?? "";
//
//         providerId.value = serviceProvider?.id ?? "";
//         providerName.value = serviceProvider?.fullName ?? "";
//         providerPhone.value = serviceProvider?.phone ?? "";
//         providerImage.value = serviceProvider?.profilePic ?? "";
//
//         if (dataModel.assignedWorker != null) {
//           assignedWorker.value = dataModel.assignedWorker!;
//         }
//
//         deadline.value = (dataModel.data?.deadline != null && dataModel.data!.deadline!.isNotEmpty)
//             ? DateFormat('dd/MM/yyyy').format(DateTime.parse(dataModel.data!.deadline!))
//             : "";
//         hireStatus.value = dataModel.data?.hireStatus ?? "";
//         paymentAmount.value = dataModel.data?.servicePayment?.amount ?? 0;
//         plateFormFee.value = dataModel.data?.platformFee ?? 0;
//         orderId.value = dataModel.data?.id ?? "";
//
//         // Update payments list
//         payments.value = dataModel.data?.servicePayment?.paymentHistory ?? [];
//
//         acceptedByProviders.value =
//             dataModel.data?.acceptedByProviders?.map((e) => {
//               "provider": e.provider,
//               "status": e.status,
//               "id": e.id,
//             }).toList() ?? [];
//         apiMessage.value = json["message"] ?? "";
//
//         result = true;
//       } else {
//         bwDebug("❌ Error: ${response.statusCode} ${response.body}", tag: tag);
//         result = false;
//       }
//     } catch (e) {
//       result = false;
//       bwDebug("⚠️ Exception: $e", tag: tag);
//     } finally {
//       isLoading.value = false;
//     }
//     return result;
//   }
//
//   // Methods for Payment and UI logic (from TaskController)
//   void selectPaymentToPay(int index) {
//     isCreatingNewPayment.value = false;
//     selectedPaymentIndex.value = index;
//     descriptionController.text = payments[index].description ?? '';
//     amountController.text = payments[index].amount.toString();
//   }
//
//   void createNewPayment() {
//     isCreatingNewPayment.value = true;
//     selectedPaymentIndex.value = -1;
//     descriptionController.clear();
//     amountController.clear();
//   }
//
//   void cancelPaymentInput() {
//     isCreatingNewPayment.value = false;
//     selectedPaymentIndex.value = -1;
//     descriptionController.clear();
//     amountController.clear();
//   }
//
//   // Submit Payment API call
//   Future<void> submitPayment(BuildContext context) async {
//     if (descriptionController.text.isEmpty || amountController.text.isEmpty) {
//       Get.snackbar('Error', 'Please enter both description and amount.');
//       return;
//     }
//
//     final enteredAmount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
//     if (enteredAmount <= 0) {
//       Get.snackbar('Error', 'Amount must be greater than zero.');
//       return;
//     }
//     _showPaymentDialog(context, enteredAmount.toInt(), descriptionController.text);
//   }
//
//   void _showPaymentDialog(BuildContext context, int enteredAmount, String description) {
//     final taxAmount = (enteredAmount * _taxPercentage).toInt();
//     final totalAmount = enteredAmount + taxAmount;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text("Payment Confirmation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 16),
//                 Image.asset(BharatAssets.payConfLogo2),
//                 const SizedBox(height: 24),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       const Text("Date", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                       Text(DateFormat("dd-MM-yy").format(DateTime.now()), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                     ]),
//                     const SizedBox(height: 8),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       const Text("Time", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                       Text(DateFormat("hh:mm a").format(DateTime.now()), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                     ]),
//                     const SizedBox(height: 8),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       const Text("Amount", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                       Text("₹$enteredAmount/-", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                     ]),
//                     const SizedBox(height: 8),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       Text("Tax (${(_taxPercentage * 100).toInt()}%)", style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                       Text("₹$taxAmount/-", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                     ]),
//                     const SizedBox(height: 16),
//                     Image.asset(BharatAssets.payLine),
//                     const SizedBox(height: 20),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       const Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
//                       Text("₹$totalAmount/-", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
//                     ]),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Divider(height: 4, color: Colors.green),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     InkWell(
//                       onTap: () async {
//                         Get.back();
//                         await addPaymentStage(
//                           amount: enteredAmount,
//                           tax: taxAmount,
//                           description: description,
//                         );
//                       },
//                       child: Container(
//                         height: 35,
//                         width: 0.28.toWidthPercent(),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: const Color(0xff228B22),
//                         ),
//                         child: const Text("Pay", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: Container(
//                         height: 35,
//                         width: 0.28.toWidthPercent(),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: Colors.green,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.green)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // API call to add payment stage
//   Future<void> addPaymentStage({
//     required int amount,
//     required int tax,
//     required String description,
//   }) async {
//     isLoading.value = true;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url = "${ApiUrl.addPaymentStage}/${orderId.value}";
//
//       final body = jsonEncode({
//         "amount": amount,
//         "tax": tax,
//         "payment_id": "PAYCOD${DateTime.now().microsecondsSinceEpoch}",
//         "description": description,
//         "method": "online",
//         "status": "success",
//       });
//
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         bwDebug("API call successful: ${response.body}");
//         Get.snackbar('Success', 'Payment added successfully!');
//         await getEmergencyOrder(orderId.value);
//         cancelPaymentInput();
//       } else {
//         bwDebug("API call failed: ${response.statusCode} - ${response.body}");
//         Get.snackbar('Error', 'Failed to add payment.');
//       }
//     } catch (e) {
//       bwDebug("API call error: $e");
//       Get.snackbar('Error', 'An error occurred. Please try again.');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Cancel Emergency Order API call
//   Future<String> cancelEmergencyOrder(String orderId) async {
//     isLoading.value = true;
//     bwDebug("[cancelEmergencyOrder]  orderId: $orderId ", tag: tag);
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     const String url = "${AppConstants.baseUrl}/emergency-order/cancel";
//
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode({
//         "order_id": orderId,
//       }),
//     );
//     isLoading.value = false;
//     if (response.statusCode == 200) {
//       bwDebug("[cancelEmergencyOrder] Cancel Success: ${response.body}", tag: tag);
//       await getEmergencyOrder(orderId);
//       return "Order cancelled successfully";
//     } else {
//       bwDebug("[cancelEmergencyOrder] Cancel Failed: ${response.body}", tag: tag);
//       return "Order cancelled failed";
//     }
//   }
//
//   // Mark As Complete API call
//   Future<bool> markAsComplete({required String orderId}) async {
//     final completer = Completer<bool>();
//     Get.defaultDialog(
//       title: 'Mark as Complete',
//       middleText: 'Are you sure the task is complete?',
//       onConfirm: () async {
//         Get.back();
//         bwDebug("[markAsComplete] call orderId:$orderId", tag: tag);
//         try {
//           isLoading.value = true;
//           var url = "${ApiUrl.completeOrderUser}";
//           final prefs = await SharedPreferences.getInstance();
//           final token = prefs.getString('token') ?? '';
//           final body = jsonEncode({"order_id": orderId});
//           var response = await http.post(
//             Uri.parse(url),
//             headers: {
//               "Authorization": "Bearer $token",
//               "Content-Type": "application/json",
//             },
//             body: body,
//           );
//           if (response.statusCode == 200) {
//             Get.snackbar('Task Complete', 'Task marked as complete.');
//             await getEmergencyOrder(orderId); // Refresh data after completion
//             completer.complete(true);
//           } else {
//             Get.snackbar('Task failed', 'Task marked as incomplete.');
//             completer.complete(false);
//           }
//         } catch (e) {
//           bwDebug("[markAsComplete] error : $e", tag: tag);
//           completer.complete(false);
//         } finally {
//           isLoading.value = false;
//         }
//       },
//       onCancel: () {
//         Get.back();
//         completer.complete(false);
//       },
//     );
//     return completer.future;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:developer/directHiring/views/Account/RazorpayScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utility/custom_snack_bar.dart';
import '../models/work_detail_model.dart';
import '../../utils/ApiUrl.dart';
import '../../utils/logger.dart';
import '../../utils/assets.dart';
import '../../utils/size_ratio.dart';
import '../../../directHiring/Consent/app_constants.dart';
import 'emergency_service_controller.dart';

class WorkDetailController extends GetxController {
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var tag = "WorkDetailController";
  static const double _taxPercentage = 0.18;

  // Data from API (Your original code)
  var imageUrls = <String>[].obs;
  var projectId = "".obs;
  var userId="".obs;
  var categoryName = "".obs;
  var subCategories = "".obs;
  var googleAddress = "".obs;
  var latitude=0.0.obs;
  var longitude=0.0.obs;
  var detailedAddress = "".obs;
  var contact = "".obs;
  var deadline = "".obs;
  var hireStatus = "".obs;
  var paymentAmount = 0.obs;
  var plateFormFee = 0.obs;
  var currentImageIndex = 0.obs; // Purana variable, ab wapas aa gaya
  var orderId = "".obs;
  var acceptedByProviders = <Map<String, dynamic>>[].obs;
  var apiMessage = "".obs;
  var providerId = "".obs;
  var providerName = "".obs;
  var providerPhone = "".obs;
  var providerImage = "".obs;
  var assignedWorker = AssignedWorker().obs;
  var warningMessage = "".obs;
  var razorOrderIdPlatform = "".obs;

  // New variables and methods from the payments logic
  var payments = <PaymentHistory>[].obs;
  var selectedPaymentIndex = (-1).obs;
  var isCreatingNewPayment = false.obs;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final emergencyServiceController = Get.put(EmergencyServiceController());

  WorkDetailController();

  @override
  void onInit() {
    super.onInit();
    // payments.value = List.generate(15, (index) {
    //   return PaymentHistory(
    //     id: "test_payment_${index + 1}",
    //     description: "Test Payment ${index + 1}",
    //     amount: 1000 + (index * 100), // Varying amounts: 1000, 1100, 1200, ..., 2400
    //     tax: ((1000 + (index * 100)) * _taxPercentage).toInt(),
    //     paymentId: "test_razorpay_id_${index + 1}",
    //     releaseStatus: "pending",
    //     status: "success",
    //     method: "online",
    //     isCollected: false,
    //     date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
    //   );
    // });
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }

  Future<bool> getEmergencyOrder(String id) async {
    var result = false;
    isLoading.value = true;
    bwDebug("[getEmergencyOrder] call orderId:$id", tag: tag);
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
      bwDebug("[getEmergencyOrder]: response: ${response.body}", tag: tag);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final dataModel = WorkDetailModel.fromJson(json);
        final serviceProvider = dataModel.data?.serviceProvider;

        imageUrls.value = dataModel.data?.imageUrls ?? [];
        projectId.value = dataModel.data?.projectId ?? "";
        userId.value = dataModel.data?.userId?.id ?? "";
        categoryName.value = dataModel.data?.categoryId?.name ?? "";
        subCategories.value =
            dataModel.data?.subCategoryIds?.map((e) => e.name).join(", ") ?? "";
        googleAddress.value = dataModel.data?.googleAddress ?? "";
        latitude.value = dataModel.data?.latitude ?? 0.0;
        longitude.value = dataModel.data?.longitude ?? 0.0;
        detailedAddress.value = dataModel.data?.detailedAddress ?? "";
        contact.value = dataModel.data?.contact ?? "";

        providerId.value = serviceProvider?.id ?? "";
        providerName.value = serviceProvider?.fullName ?? "";
        providerPhone.value = serviceProvider?.phone ?? "";
        providerImage.value = serviceProvider?.profilePic ?? "";

        if (dataModel.assignedWorker != null) {
          assignedWorker.value = dataModel.assignedWorker!;
        }

        deadline.value = (dataModel.data?.deadline != null &&
                dataModel.data!.deadline!.isNotEmpty)
            ? DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(dataModel.data!.deadline!))
            : "";
        hireStatus.value = dataModel.data?.hireStatus ?? "";
        paymentAmount.value = dataModel.data?.servicePayment?.amount ?? 0;
        plateFormFee.value = dataModel.data?.platformFee ?? 0;
        orderId.value = dataModel.data?.id ?? "";
        razorOrderIdPlatform.value = dataModel.data?.razorOrderIdPlatform ?? "";
        // Update payments list
        payments.value = dataModel.data?.servicePayment?.paymentHistory ?? [];

        acceptedByProviders.value = dataModel.data?.acceptedByProviders
                ?.map((e) => {
                      "provider": e.provider,
                      "status": e.status,
                      "id": e.id,
                    })
                .toList() ??
            [];
        apiMessage.value = json["message"] ?? "";

        result = true;
      } else {
        bwDebug("❌ Error: ${response.statusCode} ${response.body}", tag: tag);
        result = false;
      }
    } catch (e) {
      result = false;
      bwDebug("⚠️ Exception: $e", tag: tag);
    } finally {
      isLoading.value = false;
    }
    return result;
  }

  // Methods for Payment and UI logic
  void selectPaymentToPay(int index) {
    isCreatingNewPayment.value = false;
    selectedPaymentIndex.value = index;
    descriptionController.text = payments[index].description ?? '';
    descriptionController.text = payments[index].description ?? '';
    amountController.text = payments[index].amount.toString();
  }

  void createNewPayment() {
    isCreatingNewPayment.value = true;
    selectedPaymentIndex.value = -1;
    descriptionController.clear();
    amountController.clear();
  }

  void cancelPaymentInput() {
    isCreatingNewPayment.value = false;
    selectedPaymentIndex.value = -1;
    descriptionController.clear();
    amountController.clear();
  }

  // Submit Payment API call
  Future<void> submitPayment(BuildContext context) async {
    if (descriptionController.text.isEmpty || amountController.text.isEmpty) {
      CustomSnackBar.show(
          context,
          message: 'Error: Please enter both description and amount.',
          type: SnackBarType.error
      );

      return;
    }

    final enteredAmount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
    if (enteredAmount <= 0) {
      CustomSnackBar.show(
          context,
          message: 'Error Amount must be greater than zero.',
          type: SnackBarType.error
      );

      return;
    }
    _showPaymentDialog(
        context, enteredAmount.toInt(), descriptionController.text);

  }

  void _showPaymentDialog(
      BuildContext context, int enteredAmount, String description) {
    final taxAmount = (enteredAmount * _taxPercentage).toInt();
    final totalAmount = enteredAmount + taxAmount;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Payment Confirmation",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Image.asset(BharatAssets.payConfLogo2),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18)),
                          Text(DateFormat("dd-MM-yy").format(DateTime.now()),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Time",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18)),
                          Text(DateFormat("hh:mm a").format(DateTime.now()),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Amount",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18)),
                          Text("₹$enteredAmount/-",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tax (${(_taxPercentage * 100).toInt()}%)",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18)),
                          Text("₹$taxAmount/-",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        ]),
                    const SizedBox(height: 16),
                    Image.asset(BharatAssets.payLine),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 24)),
                          Text("₹$totalAmount/-",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 24)),
                        ]),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 4, color: Colors.green),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        Get.back();
                        // await payViaRazor(
                        //   amount: enteredAmount,
                        //   tax: taxAmount,
                        //   description: description,
                        //   razorpayOrderId:razorOrderIdPlatform
                        // );
                        // await  RazorpayScreen(razorpayOrderId: razorOrderIdPlatform.value , amount: totalAmount,from: "emergencyWorkDetail", enteredAmount:enteredAmount, taxAmount:taxAmount,description:description,);
                       bwDebug("razororderid: ${razorOrderIdPlatform.value}");
                        await Get.to(() => RazorpayScreen(
                          providerId: userId.value,
                              taxAmount: taxAmount,
                              razorpayOrderId: razorOrderIdPlatform.value,
                              amount: totalAmount*100,
                              enteredAmount: enteredAmount,
                              description: description,
                              from: "emergencyWorkDetail",
                          orderId: orderId.value
                            ));
                      },
                      child: Container(
                        height: 35,
                        width: 0.28.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xff228B22),
                        ),
                        child: const Text("Pay",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 35,
                        width: 0.28.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green,
                            width: 1.5,
                          ),
                        ),
                        child: const Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // API call to add payment stage
  Future<void> addPaymentStage({
    required razorPayPaymentId,
    required razorpaySignatureId,
    required amount,
    required tax,
    required description,
    required String orderId,
    required context
  }) async {
    isLoading.value = true;
    bwDebug("razorPayPaymentId : $razorPayPaymentId,razorpaySignatureId: $razorpaySignatureId, amount : $amount, tax:$tax, desciption: $description, orderId:${orderId} ");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = "${ApiUrl.addPaymentStage}/$orderId";
bwDebug("final url: $url");
      final body = jsonEncode({
        "amount": amount,
        "tax": tax,
        "payment_id": razorPayPaymentId,
        "description": description,
        "method": "online",
        "status": "success",
      });

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        bwDebug("API call successful: ${response.body}");
        CustomSnackBar.show(
            context,
            message:'Payment added successfully!' ,
            type: SnackBarType.success
        );
        await getEmergencyOrder(orderId);
        cancelPaymentInput();
      } else {
        bwDebug("API call failed: ${response.statusCode} - ${response.body}");
        CustomSnackBar.show(
            context,
            message:'Failed to add payment.' ,
            type: SnackBarType.error
        );

      }
    } catch (e) {
      bwDebug("API call error: $e");
      CustomSnackBar.show(
          context,
          message: 'An error occurred. Please try again.' ,
          type: SnackBarType.warning
      );

    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> payViaRazor({
  //   required int amount,
  //   required int tax,
  //   required String description,
  //   required  razorpayOrderId
  // }) async {
  //
  // }

  // Your existing `cancelEmergencyOrder` method
  Future<String> cancelEmergencyOrder(String orderId) async {
    isLoading.value = true;
    bwDebug("[cancelEmergencyOrder]  orderId: $orderId ", tag: tag);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    const String url = "${AppConstants.baseUrl}/emergency-order/cancel";
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
    isLoading.value = false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      bwDebug("[cancelEmergencyOrder] Cancel Success: $data", tag: tag);
      await getEmergencyOrder(orderId);
      isLoading.value = false;
      return "Order cancelled successfully";
    } else {
      bwDebug("[cancelEmergencyOrder] Cancel Failed: ${response.body}",
          tag: tag);
      isLoading.value = false;
      return "Order cancelled failed";
    }
  }

  // Your existing `acceptUserOrder` method
  Future<String> acceptUserOrder(String orderId) async {
    try {
      isLoading.value = true;
      bwDebug("[acceptUserOrder] call orderId:$orderId", tag: tag);
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
        bwDebug(
            "[acceptUserOrder]response:  ${response.statusCode} ${response.body}",
            tag: tag);
        return message;
      } else {
        bwDebug(
            "[acceptUserOrder]❌ Error: ${response.statusCode} ${response.body}",
            tag: tag);
        try {
          final json = jsonDecode(response.body);
          return json['message'] ?? "Something went wrong";
        } catch (_) {
          return "Something went wrong";
        }
      }
    } catch (e) {
      bwDebug("[acceptUserOrder]⚠️ Exception: $e", tag: tag);
      return "Something went wrong";
    } finally {
      isLoading.value = false;
    }
  }

  // Your existing `rejectUserOrder` method
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
        final message = json['message'] ?? "Success";
        bwDebug(
            "[rejectUserOrder] ✅ response: ${response.statusCode} ${response.body}",
            tag: tag);
        return message;
      } else {
        bwDebug(
            "[rejectUserOrder] ❌ Error: ${response.statusCode} ${response.body}",
            tag: tag);
        try {
          final json = jsonDecode(response.body);
          return json['message'] ?? "Something went wrong";
        } catch (_) {
          return "Something went wrong";
        }
      }
    } catch (e) {
      bwDebug("[rejectUserOrder] ⚠️ Exception: $e", tag: tag);
      return "Something went wrong";
    } finally {
      isLoading.value = false;
    }
  }

  // Mark As Complete API call
  Future<bool> markAsComplete({required String orderId, required context}) async {
    final completer = Completer<bool>();
    Get.defaultDialog(
      title: 'Mark as Complete',
      middleText: 'Are you sure the task is complete?',
      onConfirm: () async {
        Get.back();
        bwDebug("[markAsComplete] call orderId:$orderId", tag: tag);
        try {
          isActionLoading.value = true;
          var url = "${ApiUrl.completeOrderUser}";
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? '';
          final body = jsonEncode({"order_id": orderId});
          var response = await http.post(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: body,
          );
          if (response.statusCode == 200) {
            CustomSnackBar.show(
                context,
                message: 'Task marked as complete.' ,
                type: SnackBarType.success
            );
            await getEmergencyOrder(orderId);
            completer.complete(true);
          } else {
            CustomSnackBar.show(
                context,
                message: 'Task marked as incomplete.',
                type: SnackBarType.error
            );

            completer.complete(false);
          }
        } catch (e) {
          bwDebug("[markAsComplete] error : $e", tag: tag);
          completer.complete(false);
        } finally {
          isActionLoading.value = false;
        }
      },
      onCancel: () {
        Get.back();
        completer.complete(false);
      },
    );
    return completer.future;
  }
  Future<void> requestPaymentRelease({
    required String orderId,
    required String paymentId,
    required context
  }) async {
    isActionLoading.value = true;
    bwDebug("requestPaymentRelease called for orderId: $orderId, paymentId: $paymentId", tag: tag);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = "${ApiUrl.requestRelease}/$orderId/$paymentId";
      bwDebug("Final URL: $url", tag: tag);

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        bwDebug("API call successful: ${response.body}", tag: tag);
        final json = jsonDecode(response.body);
        CustomSnackBar.show(
            context,
            message: json['message'] ?? 'Payment request sent successfully!' ,
            type: SnackBarType.success
        );
        await getEmergencyOrder(orderId);
      } else {
        bwDebug("API call failed: ${response.statusCode} - ${response.body}", tag: tag);
        final json = jsonDecode(response.body);
        CustomSnackBar.show(
            context,
            message: 'Error: Failed to send payment request.',
            type: SnackBarType.error
        );

      }
    } catch (e) {
      bwDebug("API call error: $e", tag: tag);
      CustomSnackBar.show(
          context,
          message: 'An error occurred. Please try again.' ,
          type: SnackBarType.error
      );

    } finally {
      isActionLoading.value = false;
    }
  }
}
