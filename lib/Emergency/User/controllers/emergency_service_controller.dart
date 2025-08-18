import 'dart:convert';
import 'dart:io';
import 'package:developer/Emergency/User/models/create_order_model.dart';
import 'package:developer/Emergency/User/models/emergency_list_model.dart';
import 'package:developer/Emergency/User/screens/PaymentConformation.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../directHiring/views/Account/PaymentSuccessScreen.dart';
import '../screens/emergency_services.dart';

class EmergencyServiceController extends GetxController {
  /// ------------------ CATEGORY + PROBLEM -------------------
  final String tag="EmergencyServiceController";
  var isLoading = false.obs ;
  var categories = <Map<String, String>>[].obs;
  var selectedCategoryId = "".obs;


  var subCategories = <Map<String, String>>[].obs;
  var selectedSubCategoryIds = <String>[].obs;

  /// ------------------ ADDRESS + CONTACT -------------------
  final googleAddressController = TextEditingController();
  final detailedAddressController = TextEditingController();
  final contactController = TextEditingController();

  /// ------------------ DATE & TIME -------------------
  var selectedDateTime = Rxn<DateTime>();

  /// ------------------ IMAGES -------------------
  var images = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  /// ------------------ TASK FEE -------------------
  var taskFee = 0.obs;

  /// ------------------ INIT -------------------
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
   // calculateFee();
  }

  /// ------------------ API CALLS -------------------
  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/work-category'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      categories.assignAll(List<Map<String, String>>.from(
        data['data'].map((cat) => {
          'id': cat['_id'].toString(),
          'name': cat['name'].toString(),
        }),
      ));
    }
  }

  /// ------------------ PROBLEMS API (based on category) -------------------

  Future<void> fetchSubCategories(String categoryId) async {
    selectedSubCategoryIds.clear();
    subCategories.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/subcategories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      subCategories.assignAll(List<Map<String, String>>.from(
        data['data'].map((sub) => {
          'id': sub['_id'].toString(),
          'name': sub['name'].toString(),
        }),
      ));
    }
  }

  /// ------------------ PICK IMAGE -------------------
  Future<void> pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      images.addAll(pickedFiles.map((e) => File(e.path)));
    }
  }


  void removeImage(File file) {
    images.remove(file);
  }

  /// ------------------ CALCULATE TASK FEE -------------------
  // void calculateFee() {
  //   taskFee.value = selectedSubCategoryIds.length * 100; // example formula
  // }
  Future<void> calculateFee() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/get-fee/emergency'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
    taskFee.value=data['data']['fee'];

    }
  }
  /// ------------------ SUBMIT FORM -------------------
  // void submitForm() {
  //   bwDebug("📂 Category ID: ${selectedCategoryId.value}");
  //   bwDebug("🛠 Subcategory IDs: ${selectedSubCategoryIds.join(", ")}");
  //   bwDebug("📍 Google Address: ${googleAddressController.text}");
  //   bwDebug("🏠 Detailed Address: ${detailedAddressController.text}");
  //   bwDebug("📞 Contact: ${contactController.text}");
  //   bwDebug("📅 DateTime: ${selectedDateTime.value}");
  //   bwDebug("🖼 Images: ${images.length}");
  //   bwDebug("💰 Task Fee: ${taskFee.value}");
  //
  // }
  /// ------------------ SUBMIT FORM -------------------
  Future<void> submitForm(context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    bwDebug("token: $token");

    // validation
    if (selectedCategoryId.value.isEmpty ||
        selectedSubCategoryIds.isEmpty ||
        googleAddressController.text.isEmpty ||
        detailedAddressController.text.isEmpty ||
        contactController.text.isEmpty ||
        selectedDateTime.value == null ||
        images.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",colorText: Colors.red);
      return;
    }
    isLoading.value=true;
    var uri = Uri.parse("https://api.thebharatworks.com/api/emergency-order/create");

    var request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = "Bearer $token";

    // normal fields
    request.fields['category_id'] = selectedCategoryId.value;
    request.fields['sub_category_ids']=selectedSubCategoryIds.value.join(',');

    request.fields['google_address'] = googleAddressController.text;
    request.fields['detailed_address'] = detailedAddressController.text;
    request.fields['contact'] = contactController.text;
    request.fields['deadline'] = selectedDateTime.value!.toIso8601String();
    // request.fields['sub_category_ids'] = jsonEncode(selectedSubCategoryIds);

    // for (var id in selectedSubCategoryIds) {
    //   request.fields['sub_category_ids[]'] = id;
    // }
    // images
    for (var img in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images', img.path),
      );
    }

    try {
      var res = await request.send();
      var body = await res.stream.bytesToString();

      if (res.statusCode == 200 || res.statusCode==201) {
        bwDebug("✅ Success: $body");
        final jsonResponse = jsonDecode(body);
        final responseModel = EmergencyCreateOrderModel.fromJson(jsonResponse);
        prefs.setString("emergency_order_response", jsonEncode(responseModel.toJson()));
        await prefs.setString('razorpay_order_id', responseModel.razorpayOrder?.id ?? '');
        await prefs.setInt('razorpay_amount', responseModel.razorpayOrder?.amount ?? 0);

        final razorOrder = jsonResponse['razorpay_order'];
        final orderId = razorOrder['id'];
        final amount = razorOrder['amount'];
        Get.snackbar("Success", "Request submitted successfully!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  PaymentConformationScreen(
            // orderId:orderId,
            // amount:amount,
              responseModel:responseModel
          )),
        );
      } else {
        bwDebug("❌ Failed: $body");
        Get.snackbar("Error", "Something went wrong!");
      }
    } catch (e) {
      bwDebug("⚠️ Exception: $e");
      Get.snackbar("Error", "Failed to submit request!");
    }
    isLoading.value=false;
  }
  Future<void> paymentProcess(BuildContext context,
      token, {String? razorpayOrderId,String? razorPayPaymentId,String? razorpaySignatureId}) async {
    bwDebug("[paymentProcess] : ",tag: tag);
    final res = await http.post(
      Uri.parse(
        'https://api.thebharatworks.com/api/emergency-order/verify-platform-payment',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "razorpay_order_id":razorpayOrderId ,
        "razorpay_payment_id": razorPayPaymentId,
        "razorpay_signature": razorpaySignatureId,
      }),
    );
    final decoded = jsonDecode(res.body);
    print("📦 Verify API response: $decoded");

    if (res.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(from:"emergency"
            // categreyId: widget.categreyId,
            // subcategreyId: widget.subcategreyId,
            // providerId: widget.providerId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Verification Failed: ${decoded['message']}"),
        ),
      );
      Navigator.pop(context);
    }
  }
  @override
  void onClose() {
    selectedCategoryId.value = '';
    subCategories.clear();
    selectedSubCategoryIds.clear();
    googleAddressController.clear();
    detailedAddressController.clear();
    contactController.clear();
    selectedDateTime.value = null;
    images.clear();
   // taskFee.value = 0;
    super.onClose();
  }


  Future<EmergencyListModel?> getEmergencyOrder() async {
    isLoading.value=true;
    bwDebug("[getEmergencyOrder] call: ",tag:tag);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/emergency-order/getAllEmergencyOrdersByRole'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },


    );
    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      bwDebug("[getEmergencyOrder] data : ${res.body}", tag: tag);

      // Model me convert kar ke return kar rahe hai
      isLoading.value=false;
      return EmergencyListModel.fromJson(decoded);

    } else {
      bwDebug("[getEmergencyOrder] Error: ${res.statusCode}", tag: tag);
      isLoading.value=false;
      return null;
    }

  }
  }
