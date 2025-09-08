import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart' as mime;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import '../../../../Widgets/AppColors.dart';
import '../../../directHiring/models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../../../directHiring/views/auth/MapPickerScreen.dart';
import '../../../directHiring/views/comm/home_location_screens.dart';

class PostTaskController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final googleAddressController = TextEditingController();
  final descriptionController = TextEditingController();
  final costController = TextEditingController();

  var selectedImages = <File>[].obs;
  var selectedDate = Rxn<DateTime>();
  var selectedCategoryId = Rxn<String>();
  var categories = <Map<String, String>>[].obs;
  var allSubCategories = <Map<String, String>>[].obs;
  var selectedSubCategoryIds = <String>[].obs;
  var isSwitched = false.obs;
  var userLocation = "Select Location".obs;
  var profile = Rxn<ServiceProviderProfileModel>();
  var isLoading = true.obs;
  var showReviews = true.obs;
  var address = "".obs;
  var late;
  var long;
  var addre;

  @override
  void onInit() {
    super.onInit();
    resetForm(); // Reset form on initialization to ensure fresh state
    fetchCategories();
    initializeLocation();
    // Sync addressController with userLocation
    ever(userLocation, (String? newLocation) {
      addressController.text = newLocation ?? 'Select Location';
    });
    fetchProfile();
  }

  @override
  void onClose() {
    resetForm(); // Reset form when controller is disposed
    super.onClose();
  }

  // Helper method to show snackbar with consistent styling
  void showSnackbar(String title, String message, {required BuildContext context}) {
    if (context.mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }

  // Method to reset all form fields
  void resetForm() {
    titleController.clear();
    dateController.clear();
    addressController.clear();
    googleAddressController.clear();
    descriptionController.clear();
    costController.clear();
    selectedImages.clear();
    selectedDate.value = null;
    selectedCategoryId.value = null;
    selectedSubCategoryIds.clear();
    allSubCategories.clear();
    userLocation.value = "Select Location";
    isSwitched.value = false;
    address.value = "";
    formKey.currentState?.reset(); // Reset form validation state
    debugPrint("📝 Form reset: All fields cleared");
  }

  Future<void> initializeLocation() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString("selected_location") ?? prefs.getString("address");

    if (savedLocation != null && savedLocation != "Select Location") {
      userLocation.value = savedLocation;
      addressController.text = savedLocation; // Sync addressController
      isLoading.value = false;
      print("📍 Loaded saved location: $savedLocation");
      return;
    }

    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        if (Get.context != null && Get.context!.mounted) {
          showSnackbar("Error", "No token found. Please log in again.", context: Get.context!);
        }
        isLoading.value = false;
        return;
      }

      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/getUserProfileData",
      );
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      print("📡 Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📋 Data: $data");

        if (data['status'] == true) {
          String apiLocation = 'Select Location';
          String? addressId;

          if (data['data']?['full_address'] != null &&
              data['data']['full_address'].isNotEmpty) {
            final addresses = data['data']['full_address'] as List;
            final currentLocations =
            addresses.where((addr) => addr['title'] == 'Current Location').toList();
            if (currentLocations.isNotEmpty) {
              final latestLocation = currentLocations.last;
              apiLocation = latestLocation['address'] ?? 'Select Location';
              addressId = latestLocation['_id'];
            } else {
              final latestAddress = addresses.last;
              apiLocation = latestAddress['address'] ?? 'Select Location';
              addressId = latestAddress['_id'];
            }
          }

          final latitude;
          final longitude;
          final address;
         latitude = data['data']?['location']?['latitude'];
         longitude = data['data']?['location']?['longitude'];
          address = data['data']?['location']?['address'];

          late = latitude;
          long = longitude;
          addre = address;

         print('Abhi:- get user lat : $latitude long : $longitude Address : $addre');

          await prefs.setString("address", apiLocation);
          if (addressId != null) {
            await prefs.setString("selected_address_id", addressId);
          }

          profile.value = ServiceProviderProfileModel.fromJson(data['data']);
          userLocation.value = apiLocation;
          addressController.text = apiLocation; // Sync addressController
          isLoading.value = false;
          print("📍 Saved and displayed location: $apiLocation (ID: $addressId)");
        } else {
          if (Get.context != null && Get.context!.mounted) {
            showSnackbar("Error", data["message"] ?? "Failed to fetch profile.", context: Get.context!);
          }
          isLoading.value = false;
        }
      } else {
        if (Get.context != null && Get.context!.mounted) {
          showSnackbar("Error", "Server error. Failed to fetch profile.", context: Get.context!);
        }
        isLoading.value = false;
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", "Something went wrong. Please try again.", context: Get.context!);
      }
      isLoading.value = false;
    }
  }

  Future<void> updateLocationOnServer(
      String newAddress, double latitude, double longitude) async {
    if (newAddress.isEmpty || latitude == 0.0 || longitude == 0.0) {
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", "Invalid location data.", context: Get.context!);
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/updateUserProfile",
      );
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'full_address': [
            {
              'address': newAddress,
              'latitude': latitude,
              'longitude': longitude,
              'title': 'Current Location',
              'landmark': '',
            },
          ],
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'address': newAddress,
          },
        }),
      );

      print("📡 Location update response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          String? newAddressId = data['data']?['full_address']?.last?['_id'];
          await prefs.setString("selected_location", newAddress);
          await prefs.setString("address", newAddress);
          await prefs.setDouble("user_latitude", latitude);
          await prefs.setDouble("user_longitude", longitude);
          if (newAddressId != null) {
            await prefs.setString("selected_address_id", newAddressId);
          }
          userLocation.value = newAddress;
          addressController.text = newAddress; // Sync addressController
          isLoading.value = false;
          print("📍 Location updated: $newAddress (ID: $newAddressId)");
        } else {
          if (Get.context != null && Get.context!.mounted) {
            showSnackbar("Error", data["message"] ?? "Failed to update location.", context: Get.context!);
          }
        }
      } else {
        if (Get.context != null && Get.context!.mounted) {
          showSnackbar("Error", "Server error. Failed to update location.", context: Get.context!);
        }
      }
    } catch (e) {
      print("❌ Error updating location: $e");
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", "Failed to update location. Please try again.", context: Get.context!);
      }
    }
  }

  Future<void> fetchLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString('selected_location') ?? prefs.getString('address');
    String? savedAddressId = prefs.getString('selected_address_id');

    if (savedLocation != null &&
        savedLocation != 'Select Location' &&
        savedAddressId != null) {
      userLocation.value = savedLocation;
      addressController.text = savedLocation; // Sync addressController
      isLoading.value = false;
      debugPrint("📍 Prioritized saved location: $userLocation (ID: $savedAddressId)");
      return;
    }

    isLoading.value = true;
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      debugPrint("❌ No token found!");
      userLocation.value = savedLocation ?? 'Select Location';
      addressController.text = savedLocation ?? 'Select Location'; // Sync addressController
      isLoading.value = false;
      debugPrint("📍 Using saved or default location: $userLocation");
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", "Authentication failed. Please log in again.", context: Get.context!);
      }
      return;
    }

    try {
      final url = Uri.parse(
        'https://api.thebharatworks.com/api/user/getUserProfileData',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📡 API response received: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          final data = responseData['data'];
          String apiLocation = 'Select Location';
          double latitude = 0.0;
          double longitude = 0.0;
          String? addressId;

          if (savedAddressId != null && data['full_address'] != null) {
            final matchingAddress = data['full_address'].firstWhere(
                  (address) => address['_id'] == savedAddressId,
              orElse: () => null,
            );
            if (matchingAddress != null) {
              apiLocation = matchingAddress['address'] ?? 'Select Location';
              latitude = matchingAddress['latitude']?.toDouble() ?? 0.0;
              longitude = matchingAddress['longitude']?.toDouble() ?? 0.0;
              addressId = matchingAddress['_id'];
            }
          }

          if (apiLocation == 'Select Location' &&
              data['full_address'] != null &&
              data['full_address'].isNotEmpty) {
            final currentLocations =
            data['full_address'].where((address) => address['title'] == 'Current Location').toList();
            if (currentLocations.isNotEmpty) {
              final latestCurrentLocation = currentLocations.last;
              apiLocation = latestCurrentLocation['address'] ?? 'Select Location';
              latitude = latestCurrentLocation['latitude']?.toDouble() ?? 0.0;
              longitude = latestCurrentLocation['longitude']?.toDouble() ?? 0.0;
              addressId = latestCurrentLocation['_id'];
            } else {
              final latestAddress = data['full_address'].last;
              apiLocation = latestAddress['address'] ?? 'Select Location';
              latitude = latestAddress['latitude']?.toDouble() ?? 0.0;
              longitude = latestAddress['longitude']?.toDouble() ?? 0.0;
              addressId = latestAddress['_id'];
            }
          } else if (data['location']?['address']?.isNotEmpty == true) {
            apiLocation = data['location']['address'];
            latitude = data['location']['latitude']?.toDouble() ?? 0.0;
            longitude = data['location']['longitude']?.toDouble() ?? 0.0;
          }

          debugPrint("📍 Location fetched from API: $apiLocation (ID: $addressId)");

          await prefs.setString('selected_location', apiLocation);
          await prefs.setString('address', apiLocation);
          await prefs.setDouble('user_latitude', latitude);
          await prefs.setDouble('user_longitude', longitude);
          if (addressId != null) {
            await prefs.setString('selected_address_id', addressId);
          }

          userLocation.value = apiLocation;
          addressController.text = apiLocation; // Sync addressController
          isLoading.value = false;
          debugPrint("📍 Saved API location and displayed in UI: $userLocation (ID: $addressId)");
        } else {
          userLocation.value = savedLocation ?? 'Select Location';
          addressController.text = savedLocation ?? 'Select Location'; // Sync addressController
          isLoading.value = false;
          debugPrint("❌ API error: ${responseData['message']}");
          if (Get.context != null && Get.context!.mounted) {
            showSnackbar("Error", responseData['message'] ?? 'Failed to fetch profile data.', context: Get.context!);
          }
        }
      } else {
        userLocation.value = savedLocation ?? 'Select Location';
        addressController.text = savedLocation ?? 'Select Location'; // Sync addressController
        isLoading.value = false;
        debugPrint("❌ API call failed: ${response.statusCode}");
        if (Get.context != null && Get.context!.mounted) {
          showSnackbar("Error", 'Failed to fetch profile data.', context: Get.context!);
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching location: $e");
      userLocation.value = savedLocation ?? 'Select Location';
      addressController.text = savedLocation ?? 'Select Location'; // Sync addressController
      isLoading.value = false;
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", 'Failed to fetch location. Please try again.', context: Get.context!);
      }
    }
  }

  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/work-category'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      categories.value = List<Map<String, String>>.from(
        data['data'].map(
              (cat) => {
            'id': cat['_id'].toString(),
            'name': cat['name'].toString(),
          },
        ),
      );
    } else {
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", "Failed to fetch categories.", context: Get.context!);
      }
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/subcategories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      allSubCategories.value = List<Map<String, String>>.from(
        data['data'].map(
              (sub) => {
            'id': sub['_id'].toString(),
            'name': sub['name'].toString(),
          },
        ),
      );
    } else {
      if (Get.context != null && Get.context!.mounted) {
        showSnackbar("Error", "Failed to fetch subcategories.", context: Get.context!);
      }
    }
  }

  void showSubcategoryDialog() {
    List<String> tempSelected = List.from(selectedSubCategoryIds);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Select Subcategories"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allSubCategories.length,
                itemBuilder: (context, index) {
                  final sub = allSubCategories[index];
                  final subId = sub['id']!;
                  return CheckboxListTile(
                    title: Text(sub['name'] ?? ''),
                    value: tempSelected.contains(subId),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelected.add(subId);
                        } else {
                          tempSelected.remove(subId);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  selectedSubCategoryIds.value = tempSelected;
                  Get.back();
                },
                child: const Text("Done"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dateController.text =
      "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
    }
  }

  Future<void> pickImage() async {
    if (selectedImages.length >= 5) {
      showSnackbar("Error", "Maximum 5 images allowed.", context: Get.context!);
      return;
    }

    final picker = ImagePicker();
    final int remaining = 5 - selectedImages.length;

    if (remaining == 1) {
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedImage != null) {
        selectedImages.add(File(pickedImage.path));
      }
    } else {
      final List<XFile>? pickedImages = await picker.pickMultiImage(
        imageQuality: 70,
      );
      if (pickedImages != null && pickedImages.isNotEmpty) {
        final newImages = pickedImages.map((x) => File(x.path)).toList();
        final totalImages = selectedImages.length + newImages.length;
        if (totalImages > 5) {
          showSnackbar("Error", "Cannot select more than 5 images.", context: Get.context!);
          selectedImages.addAll(newImages.take(5 - selectedImages.length));
        } else {
          selectedImages.addAll(newImages);
        }
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool opened = await Geolocator.openLocationSettings();
        if (!opened) {
          showSnackbar("Error", "Please enable location services from settings.", context: Get.context!);
          return;
        }
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackbar("Error", "Location permission denied.", context: Get.context!);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackbar("Error", "Location permission permanently denied. Please enable from app settings.", context: Get.context!);
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String formattedAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        addressController.text = formattedAddress;
        userLocation.value = formattedAddress; // Sync userLocation
      } else {
        showSnackbar("Error", "Unable to fetch address from location.", context: Get.context!);
      }
    } catch (e) {
      showSnackbar("Error", "Failed to fetch location. Please try again.", context: Get.context!);
    }
  }

  // Future<void> submitTask(BuildContext context) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? '';
  //
  //     String formattedDeadline = selectedDate.value != null
  //         ? "${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}"
  //         : "2025-08-01";
  //
  //     List<String> base64Images = [];
  //     for (var image in selectedImages) {
  //       final bytes = await image.readAsBytes();
  //       final mimeType = mime.lookupMimeType(image.path) ?? 'image/jpeg';
  //       base64Images.add("data:$mimeType;base64,${base64Encode(bytes)}");
  //     }
  //
  //     String addressToSend = addressController.text.trim().isNotEmpty
  //         ? addressController.text.trim()
  //         : userLocation.value.trim();
  //     if (addressToSend == 'Select Location' || addressToSend.isEmpty) {
  //       showSnackbar("Error", "Please provide a valid address.", context: context);
  //       return;
  //     }
  //
  //     final body = {
  //       "title": titleController.text.trim(),
  //       "category_id": selectedCategoryId.value,
  //       "sub_category_ids": selectedSubCategoryIds.join(','),
  //       "address": addressToSend,
  //       "google_address": googleAddressController.text.trim(),
  //       "description": descriptionController.text.trim(),
  //       "cost": costController.text.trim(),
  //       "deadline": formattedDeadline,
  //       if (base64Images.isNotEmpty) "images": base64Images,
  //     };
  //
  //     print("📩 Sending task with address: $addressToSend");
  //
  //     final response = await http.post(
  //       Uri.parse("https://api.thebharatworks.com/api/bidding-order/create"),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     print("📡 Post Task response: ${response.body}");
  //     print("📡 Post Task status: ${response.statusCode}");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       showSnackbar("Success", "Task posted successfully.", context: context);
  //       resetForm(); // Reset form after successful submission
  //       // Add a slight delay to ensure snackbar is visible
  //       await Future.delayed(const Duration(seconds: 1));
  //       Get.delete<PostTaskController>(); // Delete controller before navigation
  //       Get.back();
  //     } else if (response.statusCode == 401) {
  //       showSnackbar("Error", "Session expired. Please log in again.", context: context);
  //       Get.offAllNamed('/login');
  //     } else {
  //       showSnackbar("Error", "Failed to post task. Please try again.", context: context);
  //     }
  //   } catch (e) {
  //     showSnackbar("Error", "An error occurred while posting the task. Please try again.", context: context);
  //   }
  // }

  Future<void> submitTask(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      String formattedDeadline = selectedDate.value != null
          ? "${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}"
          : "2025-08-01";

      String addressToSend = addressController.text.trim().isNotEmpty
          ? addressController.text.trim()
          : userLocation.value.trim();
      if (addressToSend == 'Select Location' || addressToSend.isEmpty) {
        showSnackbar("Error", "Please provide a valid address.", context: context);
        return;
      }

      var uri = Uri.parse("https://api.thebharatworks.com/api/bidding-order/create");
      var request = http.MultipartRequest('POST', uri);

      print("Abhi:- Tab post api button : late $late long : $long}");

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = titleController.text.trim();
      request.fields['category_id'] = selectedCategoryId.value.toString();
      request.fields['sub_category_ids'] = selectedSubCategoryIds.join(',');
      request.fields['address'] = addressToSend;
      request.fields['google_address'] = googleAddressController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['cost'] = costController.text.trim();
      request.fields['deadline'] = formattedDeadline;
      request.fields['latitude'] = late.toString();
      request.fields['longitude'] = long.toString();

      // images add karna
      for (var image in selectedImages) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // showSnackbar("Success", "Task posted successfully.", context: context);
        Get.back();
        Get.snackbar("Success", "Task posted successfully",backgroundColor: Colors.green,colorText: Colors.white,snackPosition:  SnackPosition.BOTTOM);
        resetForm();

        await Future.delayed(const Duration(seconds: 1));
        Get.delete<PostTaskController>();
        Get.back();
      } else if (response.statusCode == 401) {
        print("Abhi:- post bidding task api statusCode ${response.statusCode}");
        print("Abhi:- post bidding task api statusCode ${response.stream}");
        showSnackbar("Error", "Session expired. Please log in again.", context: context);
        Get.offAllNamed('/login');
      } else {
        showSnackbar("Error", "Failed to post task. Please try again.", context: context);
        print("Abhi:- post bidding task api statusCode ${response.statusCode}");
        print("Abhi:- post bidding task api statusCode ${response.stream}");
      }
    } catch (e) {
      print("Abhi:- post bidding task api statusCode ${e}");
      showSnackbar("Error", "An error occurred while posting the task. Please try again.", context: context);
    }
  }


  void navigateToLocationScreen() async {
    final result = await Get.to(
          () => LocationSelectionScreen(
        onLocationSelected: (Map<String, dynamic> locationData) {
          userLocation.value = locationData['address'] ?? 'Select Location';
          addressController.text = locationData['address'] ?? 'Select Location'; // Sync addressController
          debugPrint(
            "📍 New location selected: ${locationData['address']} (ID: ${locationData['addressId']})",
          );
        },
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      String newAddress = result['address'] ?? 'Select Location';
      double latitude = result['latitude'] ?? 0.0;
      double longitude = result['longitude'] ?? 0.0;
      String? addressId = result['addressId'];
      if (newAddress != 'Select Location' && latitude != 0.0 && longitude != 0.0) {
        await updateLocationOnServer(newAddress, latitude, longitude);
        if (addressId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_address_id', addressId);
        }
        await fetchLocation();
      } else {
        debugPrint("❌ Invalid location data received: $result");
        showSnackbar("Error", "Invalid location data. Please try again.", context: Get.context!);
      }
    }
  }
}