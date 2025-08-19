import 'package:get/get.dart';

import '../models/request_accepted_model.dart';

class RequestController extends GetxController {
  var isLoading = false.obs;
  var requests = <RequestAcceptedModel>[].obs;

  // Replace with your API URL
  final String apiUrl = "https://yourapi.com/get-requests";

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // thoda loading dikhane ke liye
      requests.value = [
        RequestAcceptedModel(
          id: "1",
          name: "Rahul Sharma",
          amount: 2500,
          location: "Delhi, India",
          imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
          status: "Active",
        ),
        RequestAcceptedModel(
          id: "2",
          name: "Priya Verma",
          amount: 1800,
          location: "Mumbai, India",
          imageUrl: "https://randomuser.me/api/portraits/women/44.jpg",
          status: "Active",
        ),
        RequestAcceptedModel(
          id: "3",
          name: "Aman Gupta",
          amount: 3200,
          location: "Bangalore, India",
          imageUrl: "https://randomuser.me/api/portraits/men/12.jpg",
          status: "Pending",
        ),
      ];
      //var response = await Dio().get(apiUrl);

      // if (response.statusCode == 200) {
      //   var data = response.data as List; // assuming API returns a list
      //   requests.value =
      //       data.map((e) => RequestAcceptedModel.fromJson(e)).toList();
      // } else {
      //   print("Error: ${response.statusMessage}");
      // }
    } catch (e) {
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
