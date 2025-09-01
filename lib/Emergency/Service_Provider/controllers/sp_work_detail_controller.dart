import 'dart:async';
import 'dart:convert';
import 'package:developer/Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
import 'package:developer/Emergency/Service_Provider/models/sp_work_detail_model.dart';
import 'package:developer/directHiring/views/Account/RazorpayScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/ApiUrl.dart';
import '../../utils/logger.dart';
import '../../utils/assets.dart';
import '../../utils/size_ratio.dart';
import '../../../directHiring/Consent/app_constants.dart';

class SpWorkDetailController extends GetxController {
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var tag = "SPWorkDetailController";
  static const double _taxPercentage = 0.18;

  // Data from API (Your original code)
  var imageUrls = <String>[].obs;
  var projectId = "".obs;
  var userId="".obs;
  var categoryName = "".obs;
  var subCategories = "".obs;
  var googleAddress = "".obs;
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
  final emergencyServiceController = Get.put(SpEmergencyServiceController());

  SpWorkDetailController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }

  Future<bool> getEmergencyOrder(String id) async {
    print("yyyyyyyyyyyyyyyyyyyy");
    var result = false;
    isLoading.value = true;
    bwDebug("[getEmergencyOrder] call orderId:$id", tag: tag);
    var url = "${ApiUrl.getSpEmergencyOrderById}/$id";
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
        print('dsss :- $json');
        final dataModel = SpWorkDetailModel.fromJson(json);
        final serviceProvider = dataModel.data?.serviceProvider;

        imageUrls.value = dataModel.data?.imageUrls ?? [];
        projectId.value = dataModel.data?.projectId ?? "";
        userId.value = dataModel.data?.userId?.id ?? "";
        categoryName.value = dataModel.data?.categoryId?.name ?? "";
        subCategories.value =
            dataModel.data?.subCategoryIds?.map((e) => e.name).join(", ") ?? "";
        googleAddress.value = dataModel.data?.googleAddress ?? "";
        detailedAddress.value = dataModel.data?.detailedAddress ?? "";
        contact.value = dataModel.data?.contact ?? "";

        providerId.value = serviceProvider?.id ?? "";
        providerName.value = serviceProvider?.fullName ?? "";
        providerPhone.value = serviceProvider?.phone ?? "";
        providerImage.value = serviceProvider?.profilePic ?? "";

        if (dataModel.assignedWorker != null) {
          print('dss:- assigned worker is not null');
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
    isLoading.value = false;
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
      Get.snackbar('Error', 'Please enter both description and amount.');
      return;
    }

    final enteredAmount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
    if (enteredAmount <= 0) {
      Get.snackbar('Error', 'Amount must be greater than zero.');
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
                            amount: totalAmount,
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
        Get.snackbar('Success', 'Payment added successfully!');
        await getEmergencyOrder(orderId);
        cancelPaymentInput();
      } else {
        bwDebug("API call failed: ${response.statusCode} - ${response.body}");
        Get.snackbar('Error', 'Failed to add payment.');
      }
    } catch (e) {
      bwDebug("API call error: $e");
      Get.snackbar('Error', 'An error occurred. Please try again.');
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
      return "Exception: $e";
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
      return "Exception: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // Mark As Complete API call
  Future<bool> markAsComplete({required String orderId}) async {
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
            Get.snackbar('Task Complete', 'Task marked as complete.');
            await getEmergencyOrder(orderId);
            completer.complete(true);
          } else {
            Get.snackbar('Task failed', 'Task marked as incomplete.');
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
        Get.snackbar('Success', json['message'] ?? 'Payment request sent successfully!');

        await getEmergencyOrder(orderId);
      } else {
        bwDebug("API call failed: ${response.statusCode} - ${response.body}", tag: tag);
        final json = jsonDecode(response.body);
        Get.snackbar('Error', json['message'] ?? 'Failed to send payment request.');
      }
    } catch (e) {
      bwDebug("API call error: $e", tag: tag);
      Get.snackbar('Error', 'An error occurred. Please try again.');
    } finally {
      isActionLoading.value = false;
    }
  }
}
