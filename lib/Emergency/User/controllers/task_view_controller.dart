// import 'dart:async';
// import 'dart:convert';
// import 'package:developer/Emergency/utils/size_ratio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../utils/ApiUrl.dart';
// import '../../utils/assets.dart';
// import '../../utils/logger.dart';
// import '../models/task_view_model.dart';
//
// class TaskController extends GetxController {
//   final tag = "TaskController";
//   final isLoading = false.obs;
//   static const double _taxPercentage = 0.18;
//   var task = TaskModel(
//     workerDetails: WorkerDetails(
//       name: 'Dipak Sharma',
//       imageUrl: 'https://via.placeholder.com/150',
//       emergencyFees: '300',
//     ),
//     assignedPerson: AssignedPerson(
//       name: 'Ayush Ikasera',
//       imageUrl: 'https://via.placeholder.com/150',
//       subCategory: 'Plumber',
//     ),
//     payments: [
//       Payment(name: 'Starting Payment', amount: '20,000', isPaid: false),
//       Payment(name: 'Mid Payment', amount: '20,000', isPaid: true),
//     ],
//     warningMessage: WarningMessage(
//       message: 'Lorem ipsum dolor sit amet consectetur.',
//     ),
//   ).obs;
//
//   var selectedPaymentIndex = (-1).obs;
//   var showWarning = true.obs;
//   var isCreatingNewPayment = false.obs;
//
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//
//   void selectPaymentToPay(int index) {
//     isCreatingNewPayment.value = false;
//     selectedPaymentIndex.value = index;
//     descriptionController.text = task.value.payments[index].name;
//     amountController.text = task.value.payments[index].amount;
//   }
//
//   void createNewPayment() {
//     isCreatingNewPayment.value = true;
//     selectedPaymentIndex.value = -1;
//     descriptionController.clear();
//     amountController.clear();
//   }
// //////////////////23/8/25////////////////////
//   // void submitPayment() {
//   //   if (isCreatingNewPayment.value) {
//   //     if (descriptionController.text.isNotEmpty && amountController.text.isNotEmpty) {
//   //       final newPayment = Payment(
//   //         name: descriptionController.text,
//   //         amount: amountController.text,
//   //         isPaid: false,
//   //       );
//   //       task.update((val) {
//   //         val!.payments.add(newPayment);
//   //       });
//   //       Get.snackbar('Success', 'New payment created successfully!');
//   //     } else {
//   //       Get.snackbar('Error', 'Please enter both description and amount.');
//   //     }
//   //   } else {
//   //     if (selectedPaymentIndex.value != -1) {
//   //       task.update((val) {
//   //         val!.payments[selectedPaymentIndex.value].isPaid = true;
//   //         val.payments[selectedPaymentIndex.value].name = descriptionController.text;
//   //         val.payments[selectedPaymentIndex.value].amount = amountController.text;
//   //       });
//   //       Get.snackbar('Success', 'Payment submitted successfully!');
//   //     }
//   //   }
//   //   isCreatingNewPayment.value = false;
//   //   selectedPaymentIndex.value = -1;
//   // }
//
//
//   //////////////////23/8/25////////////////////
//   void submitPayment(BuildContext context, String orderId) {
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
//
//     final payment = Payment(
//       name: descriptionController.text,
//       amount: amountController.text,
//       isPaid: false,
//     );
//
//     _showPaymentDialog(context, payment, orderId);
//   }
//   void _showPaymentDialog(BuildContext context, Payment payment, String orderId) {
//     final enteredAmount = double.tryParse(payment.amount.replaceAll(',', '')) ?? 0.0;
//     final taxAmount = enteredAmount * _taxPercentage;
//     final totalAmount = enteredAmount + taxAmount;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Payment Confirmation",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Image.asset(BharatAssets.payConfLogo2),
//                 const SizedBox(height: 24),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Date", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text(
//                           DateFormat("dd-MM-yy").format(DateTime.now()),
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Time", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text(
//                           DateFormat("hh:mm a").format(DateTime.now()),
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Amount", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text("₹${enteredAmount.toStringAsFixed(2)}/-", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Tax (${(_taxPercentage * 100).toInt()}%)", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text("₹${taxAmount.toStringAsFixed(2)}/-", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Image.asset(BharatAssets.payLine),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Total",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 24,
//                           ),
//                         ),
//                         Text(
//                           "₹${totalAmount.toStringAsFixed(2)}/-",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 24,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Divider(height: 4, color: Colors.green),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     InkWell(
//                       onTap: () async {
//                         Get.back(); // Dialog band karo
//                         await addPaymentStage(
//                           orderId: orderId,
//                           amount: enteredAmount.toInt(),
//                           tax: taxAmount.toInt(),
//                           description: payment.name,
//                         );
//                       },
//                       child: Container(
//                         height: 35,
//                         width: 0.28.toWidthPercent(),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Color(0xff228B22),
//                         ),
//                         child: Text("Pay", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
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
//                         child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.green)),
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
//   Future<void> addPaymentStage({
//     required String orderId,
//     required int amount,
//     required int tax,
//     required String description,
//   }) async {
//     isLoading.value = true;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url = "${ApiUrl.addPaymentStage}/$orderId";
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
//         // UI ko update karne ka logic yahan add karein, jaise ki payments list mein naya payment jodna
//         final newPayment = Payment(name: description, amount: amount.toString(), isPaid: true);
//         task.update((val) {
//           val!.payments.add(newPayment);
//         });
//         isCreatingNewPayment.value = false;
//         selectedPaymentIndex.value = -1;
//         descriptionController.clear();
//         amountController.clear();
//
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
//
//   //////////////////23/8/25////////////////////
//   void cancelPaymentInput() {
//     isCreatingNewPayment.value = false;
//     selectedPaymentIndex.value = -1;
//     descriptionController.clear();
//     amountController.clear();
//   }
//
//   // void cancelTaskAndCreateDispute() {
//   //   Get.defaultDialog(
//   //     title: 'Cancel Task',
//   //     middleText: 'Are you sure you want to cancel this task?',
//   //     onConfirm: () {
//   //       Get.back();
//   //       Get.snackbar('Task Canceled', 'Dispute created.');
//   //     },
//   //     onCancel: () {
//   //       Get.back();
//   //     },
//   //   );
//   // }
//
//   // Future<bool> markAsComplete({required String orderId}) async {
//   //   bool result = false;
//   //   Get.defaultDialog(
//   //     title: 'Mark as Complete',
//   //     middleText: 'Are you sure the task is complete?',
//   //     onConfirm: () async {
//   //       bwDebug("[markAsComplete] call orderId:$orderId", tag: tag);
//   //       try {
//   //         isLoading.value = true;
//   //         var url = "${ApiUrl.completeOrderUser}";
//   //         final prefs = await SharedPreferences.getInstance();
//   //         final token = prefs.getString('token') ?? '';
//   //         bwDebug("[markAsComplete] final url :$url, token: $token", tag: tag);
//   //         final body = jsonEncode({"order_id": orderId});
//   //         var response = await http.post(
//   //           Uri.parse(url),
//   //           headers: {
//   //             "Authorization": "Bearer $token",
//   //             "Content-Type": "application/json",
//   //           },
//   //           body: body,
//   //         );
//   //         bwDebug(
//   //             "[markAsComplete] response status: ${response.statusCode}\n response Body ${response.body}",
//   //             tag: tag);
//   //         if (response.statusCode == 200) {
//   //           Get.back();
//   //           Get.snackbar('Task Complete', 'Task marked as complete.');
//   //           result = true;
//   //         } else {
//   //           bwDebug("Error: ${response.body}");
//   //           Get.snackbar('Task failed', 'Task marked as incomplete.');
//   //           Get.back();
//   //            result = false;
//   //         }
//   //       } catch (e) {
//   //         bwDebug("[markAsComplete] error : $e", tag: tag);
//   //         result = false;
//   //       } finally {
//   //         bwDebug("[markAsComplete] final : ", tag: tag);
//   //         isLoading.value = false;
//   //         Get.back();
//   //       }
//   //     },
//   //     onCancel: () {
//   //       result = false;
//   //       Get.back();
//   //     },
//   //   );
//   //   return result;
//   // }
//   Future<bool> markAsComplete({required String orderId}) async {
//     // Use a Completer to manage the result of the async dialog
//     final completer = Completer<bool>();
//
//     Get.defaultDialog(
//       title: 'Mark as Complete',
//       middleText: 'Are you sure the task is complete?',
//       onConfirm: () async {
//         Get.back(); // Dismiss the dialog immediately
//         bwDebug("[markAsComplete] call orderId:$orderId", tag: tag);
//         try {
//           isLoading.value = true;
//           var url = "${ApiUrl.completeOrderUser}";
//           final prefs = await SharedPreferences.getInstance();
//           final token = prefs.getString('token') ?? '';
//           bwDebug("[markAsComplete] final url :$url, token: $token", tag: tag);
//           final body = jsonEncode({"order_id": orderId});
//           var response = await http.post(
//             Uri.parse(url),
//             headers: {
//               "Authorization": "Bearer $token",
//               "Content-Type": "application/json",
//             },
//             body: body,
//           );
//           bwDebug(
//               "[markAsComplete] response status: ${response.statusCode}\n response Body ${response.body}",
//               tag: tag);
//           if (response.statusCode == 200) {
//             Get.snackbar('Task Complete', 'Task marked as complete.');
//             completer.complete(true); // Complete the Future with true
//           } else {
//             bwDebug("Error: ${response.body}");
//             Get.snackbar('Task failed', 'Task marked as incomplete.');
//             completer.complete(false); // Complete with false on API error
//           }
//         } catch (e) {
//           bwDebug("[markAsComplete] error : $e", tag: tag);
//           completer.complete(false); // Complete with false on exception
//         } finally {
//           bwDebug("[markAsComplete] final : ", tag: tag);
//           isLoading.value = false;
//         }
//       },
//       onCancel: () {
//         Get.back();
//         completer.complete(false); // Complete with false if the user cancels
//       },
//     );
//
//     return completer.future; // Return the Future
//   }
//
//   @override
//   void onClose() {
//     descriptionController.dispose();
//     amountController.dispose();
//     super.onClose();
//   }
// }