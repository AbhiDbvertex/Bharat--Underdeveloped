import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/ApiUrl.dart';
import '../../utils/logger.dart';
import '../models/task_view_model.dart';

class TaskController extends GetxController {
  final tag = "TaskController";
  final isLoading = false.obs;

  var task = TaskModel(
    workerDetails: WorkerDetails(
      name: 'Dipak Sharma',
      imageUrl: 'https://via.placeholder.com/150',
      emergencyFees: '300',
    ),
    assignedPerson: AssignedPerson(
      name: 'Ayush Ikasera',
      imageUrl: 'https://via.placeholder.com/150',
      subCategory: 'Plumber',
    ),
    payments: [
      Payment(name: 'Starting Payment', amount: '20,000', isPaid: false),
      Payment(name: 'Mid Payment', amount: '20,000', isPaid: true),
    ],
    warningMessage: WarningMessage(
      message: 'Lorem ipsum dolor sit amet consectetur.',
    ),
  ).obs;

  var selectedPaymentIndex = (-1).obs;
  var showWarning = true.obs;
  var isCreatingNewPayment = false.obs;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  void selectPaymentToPay(int index) {
    isCreatingNewPayment.value = false;
    selectedPaymentIndex.value = index;
    descriptionController.text = task.value.payments[index].name;
    amountController.text = task.value.payments[index].amount;
  }

  void createNewPayment() {
    isCreatingNewPayment.value = true;
    selectedPaymentIndex.value = -1;
    descriptionController.clear();
    amountController.clear();
  }

  void submitPayment() {
    if (isCreatingNewPayment.value) {
      if (descriptionController.text.isNotEmpty && amountController.text.isNotEmpty) {
        final newPayment = Payment(
          name: descriptionController.text,
          amount: amountController.text,
          isPaid: false,
        );
        task.update((val) {
          val!.payments.add(newPayment);
        });
        Get.snackbar('Success', 'New payment created successfully!');
      } else {
        Get.snackbar('Error', 'Please enter both description and amount.');
      }
    } else {
      if (selectedPaymentIndex.value != -1) {
        task.update((val) {
          val!.payments[selectedPaymentIndex.value].isPaid = true;
          val.payments[selectedPaymentIndex.value].name = descriptionController.text;
          val.payments[selectedPaymentIndex.value].amount = amountController.text;
        });
        Get.snackbar('Success', 'Payment submitted successfully!');
      }
    }
    isCreatingNewPayment.value = false;
    selectedPaymentIndex.value = -1;
  }

  void cancelPaymentInput() {
    isCreatingNewPayment.value = false;
    selectedPaymentIndex.value = -1;
    descriptionController.clear();
    amountController.clear();
  }

  void cancelTaskAndCreateDispute() {
    Get.defaultDialog(
      title: 'Cancel Task',
      middleText: 'Are you sure you want to cancel this task?',
      onConfirm: () {
        Get.back();
        Get.snackbar('Task Canceled', 'Dispute created.');
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  // Future<bool> markAsComplete({required String orderId}) async {
  //   bool result = false;
  //   Get.defaultDialog(
  //     title: 'Mark as Complete',
  //     middleText: 'Are you sure the task is complete?',
  //     onConfirm: () async {
  //       bwDebug("[markAsComplete] call orderId:$orderId", tag: tag);
  //       try {
  //         isLoading.value = true;
  //         var url = "${ApiUrl.completeOrderUser}";
  //         final prefs = await SharedPreferences.getInstance();
  //         final token = prefs.getString('token') ?? '';
  //         bwDebug("[markAsComplete] final url :$url, token: $token", tag: tag);
  //         final body = jsonEncode({"order_id": orderId});
  //         var response = await http.post(
  //           Uri.parse(url),
  //           headers: {
  //             "Authorization": "Bearer $token",
  //             "Content-Type": "application/json",
  //           },
  //           body: body,
  //         );
  //         bwDebug(
  //             "[markAsComplete] response status: ${response.statusCode}\n response Body ${response.body}",
  //             tag: tag);
  //         if (response.statusCode == 200) {
  //           Get.back();
  //           Get.snackbar('Task Complete', 'Task marked as complete.');
  //           result = true;
  //         } else {
  //           bwDebug("Error: ${response.body}");
  //           Get.snackbar('Task failed', 'Task marked as incomplete.');
  //           Get.back();
  //            result = false;
  //         }
  //       } catch (e) {
  //         bwDebug("[markAsComplete] error : $e", tag: tag);
  //         result = false;
  //       } finally {
  //         bwDebug("[markAsComplete] final : ", tag: tag);
  //         isLoading.value = false;
  //         Get.back();
  //       }
  //     },
  //     onCancel: () {
  //       result = false;
  //       Get.back();
  //     },
  //   );
  //   return result;
  // }
  Future<bool> markAsComplete({required String orderId}) async {
    // Use a Completer to manage the result of the async dialog
    final completer = Completer<bool>();

    Get.defaultDialog(
      title: 'Mark as Complete',
      middleText: 'Are you sure the task is complete?',
      onConfirm: () async {
        Get.back(); // Dismiss the dialog immediately
        bwDebug("[markAsComplete] call orderId:$orderId", tag: tag);
        try {
          isLoading.value = true;
          var url = "${ApiUrl.completeOrderUser}";
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? '';
          bwDebug("[markAsComplete] final url :$url, token: $token", tag: tag);
          final body = jsonEncode({"order_id": orderId});
          var response = await http.post(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: body,
          );
          bwDebug(
              "[markAsComplete] response status: ${response.statusCode}\n response Body ${response.body}",
              tag: tag);
          if (response.statusCode == 200) {
            Get.snackbar('Task Complete', 'Task marked as complete.');
            completer.complete(true); // Complete the Future with true
          } else {
            bwDebug("Error: ${response.body}");
            Get.snackbar('Task failed', 'Task marked as incomplete.');
            completer.complete(false); // Complete with false on API error
          }
        } catch (e) {
          bwDebug("[markAsComplete] error : $e", tag: tag);
          completer.complete(false); // Complete with false on exception
        } finally {
          bwDebug("[markAsComplete] final : ", tag: tag);
          isLoading.value = false;
        }
      },
      onCancel: () {
        Get.back();
        completer.complete(false); // Complete with false if the user cancels
      },
    );

    return completer.future; // Return the Future
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}