import 'dart:convert';
import 'dart:io';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/map_launcher_lat_long.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../Bidding/controller/bidding_post_task_controller.dart';
import '../../../Emergency/utils/assets.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../Account/RazorpayScreen.dart';
import 'package:get/get.dart';

class HireScreen extends StatefulWidget {
  final String firstProviderId;
  final String? categreyId; // Typo fix: categreyId -> categoryId
  final String? subcategreyId; // Typo fix: subcategreyId -> subcategoryId

  const HireScreen({
    super.key,
    required this.firstProviderId,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<HireScreen> createState() => _HireScreenState();
}

class _HireScreenState extends State<HireScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<XFile> selectedImages = [];
  int? platformFee;
  final controller = Get.put(PostTaskController(), permanent: false);
  var isLoading = false;
  var profile = Rxn<ServiceProviderProfileModel>();
  var late;
  var long;
  var addre;
  String? _goToShopSelection = 'No';
  String get _dynamicShopAddress => profile.value?.businessAddress?.address?.isNotEmpty == true
      ? profile.value!.businessAddress!.address!
      : "Shop Address: Not Available";

  @override
  void initState() {
    super.initState();
    fetchPlatformFee();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        if (Get.context != null && Get.context!.mounted) {
          // showSnackbar("Error", "No token found. Please log in again.", context: Get.context!);
        }
        isLoading = false;
        return;
      }

      final url = Uri.parse("https://api.thebharatworks.com/api/user/getUserProfileData");
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

          if (data['data']?['full_address'] != null && data['data']['full_address'].isNotEmpty) {
            final addresses = data['data']['full_address'] as List;
            final currentLocations = addresses.where((addr) => addr['title'] == 'Current Location').toList();
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

          final latitude = data['data']?['location']?['latitude'];
          final longitude = data['data']?['location']?['longitude'];
          final address = data['data']?['location']?['address'];

          late = latitude;
          long = longitude;
          addre = address;

          print('Abhi:- get user lat : $latitude long : $longitude Address : $addre');

          await prefs.setString("address", apiLocation);
          if (addressId != null) {
            await prefs.setString("selected_address_id", addressId);
          }

          profile.value = ServiceProviderProfileModel.fromJson(data['data']);
          addressController.text = apiLocation;
          isLoading = false;
          print("📍 Saved and displayed location: $apiLocation (ID: $addressId)");
        } else {
          if (Get.context != null && Get.context!.mounted) {
            // showSnackbar("Error", data["message"] ?? "Failed to fetch profile.", context: Get.context!);
          }
          isLoading = false;
        }
      } else {
        if (Get.context != null && Get.context!.mounted) {
          // showSnackbar("Error", "Server error. Failed to fetch profile.", context: Get.context!);
        }
        isLoading = false;
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      if (Get.context != null && Get.context!.mounted) {
        // showSnackbar("Error", "Something went wrong. Please try again.", context: Get.context!);
      }
      isLoading = false;
    }
  }

  Future<void> fetchPlatformFee() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("❌ No token found. User not logged in.");
      return;
    }

    final url = Uri.parse('https://api.thebharatworks.com/api/get-fee/direct');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            platformFee = data['data']['fee'];
          });
        }
      } else {
        print("❌ Failed to fetch fee: ${response.statusCode}");
        print("📩 Body: ${response.body}");
      }
    } catch (e) {
      print("❗ Error fetching platform fee: $e");
    }
  }

  // ✅ Modified Date picker function to open Time picker automatically
  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      // Automatically open time picker after date selection
      if (mounted) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
          });
        }
      }
    }
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        if (selectedImages.length + pickedList.length <= 5) {
          selectedImages.addAll(pickedList);
        } else {
          CustomSnackBar.show(message: "Maximum 5 images allowed", type: SnackBarType.error);
        }
      });
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          CustomSnackBar.show(message: "Location permission denied", type: SnackBarType.error);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        CustomSnackBar.show(message: "Location permission permanently denied", type: SnackBarType.error);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final addressComponents = [
          placemark.street,
          placemark.subLocality,
          placemark.subThoroughfare,
          placemark.thoroughfare,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ];
        final address = addressComponents.where((e) => e != null && e.isNotEmpty).join(", ");
        setState(() {
          addressController.text = address;
        });
      } else {
        CustomSnackBar.show(message: "Unable to fetch address", type: SnackBarType.error);
      }
    } catch (e) {
      print("❗ Error fetching location: $e");
      CustomSnackBar.show(message: "Error fetching location", type: SnackBarType.error);
    }
  }

  Future<bool> showInitialConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/success.png', height: 120, width: 120, fit: BoxFit.cover),
              const SizedBox(height: 20),
              Text(
                "Are you sure you want to hire ?",
                style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.green.shade700),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ) ?? false;
  }

  Future<bool> showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 0.6.toWidthPercent(),
                alignment: Alignment.center,
                child: Image.asset(BharatAssets.paymentConfLogo),
              ),
              SizedBox(height: 0.1.toWidthPercent()),
              Text(
                'Payment Proceed',
                style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              SizedBox(height: 35),
              Container(
                width: 169,
                height: 58,
                color: Color(0xffB1FDCA),
                alignment: Alignment.center,
                child: Text(
                  platformFee != null ? '₹${platformFee}' : '₹0',
                  style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.w500, color: Color(0xFF334247)),
                ),
              ),
              SizedBox(height: 40),
              Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(BharatAssets.payImage)),
              SizedBox(height: 65),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () async {
                      final confirmed = await showDetails(context);
                      Navigator.pop(context, confirmed);
                    },
                    child: Container(
                      height: 35,
                      width: 0.3.toWidthPercent(),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xff228B22)),
                      child: Text(
                        "Hire",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 35,
                      width: 0.3.toWidthPercent(),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xff228B22), width: 1.5),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xff228B22)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ) ?? false;
  }

  Future<void> submitForm() async {
    bwDebug("[submitForm]Goto his show? : $_goToShopSelection", tag: "Hire Screen");
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final address = addressController.text.trim();

    if (title.isEmpty || description.isEmpty || selectedDate == null || selectedTime == null /*|| selectedImages.isEmpty*/) {
      CustomSnackBar.show(message: 'Please fill all fields', type: SnackBarType.error);
      return;
    }
    final initialConfirmed = await showInitialConfirmationDialog();
    if (!mounted || !initialConfirmed) return;

    final paymentConfirmed = await showConfirmationDialog();
    if (!mounted || !paymentConfirmed) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      CustomSnackBar.show(message: 'User not logged in', type: SnackBarType.warning);
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.hireScreen}'));
    request.headers['Authorization'] = 'Bearer $token';

    final deadline =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

    request.fields['first_provider_id'] = widget.firstProviderId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['address'] = controller.addressController.text;
    request.fields['deadline'] = deadline;
    request.fields['latitude'] = late.toString();
    request.fields['longitude'] = long.toString();
    request.fields['isShopVisited'] = _goToShopSelection == "Yes" ? 'true' : 'false';

    print("📤 Fields being sent: lat : $late long : $long");
    request.fields.forEach((key, value) {
      print(" - $key: $value");
    });

    for (var image in selectedImages) {
      print("🖼️ Adding image: ${image.path}");
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', 'jpeg'),
          filename: p.basename(image.path),
        ),
      );
    }

    print("🚀 Sending request...");

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print("response hire Status: ${response.statusCode}");
      print("📩 Response: $respStr");

      bwDebug("gadge: response: ${respStr}");

      if (response.statusCode == 201) {
        final decoded = jsonDecode(respStr);
        final razorpayOrderId = decoded['razorpay_order']['id'];
        final amount = decoded['razorpay_order']['amount'];
        final orderId = decoded["order"]["_id"];
        final paymentSuccess = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RazorpayScreen(
              razorpayOrderId: razorpayOrderId,
              amount: amount,
              providerId: widget.firstProviderId,
              orderId: orderId,
              passIndex: 1,
            ),
          ),
        );

        if (paymentSuccess == true) {
          List<String> hiredProviders = prefs.getStringList('hiredProviders') ?? [];
          if (!hiredProviders.contains(widget.firstProviderId)) {
            hiredProviders.add(widget.firstProviderId);
            await prefs.setStringList('hiredProviders', hiredProviders);
          }

          if (mounted) {
            Navigator.pop(context, widget.firstProviderId);
          }
        }
      } else {
        print("❌ Error Response: $respStr");
        CustomSnackBar.show(message: 'Failed: $respStr', type: SnackBarType.error);
      }
    } catch (e) {
      print("❗ Exception: $e");
      CustomSnackBar.show(message: "Something went wrong.", type: SnackBarType.error);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: SizedBox(
        width: height*0.411,
        child: ElevatedButton(
          onPressed: isLoading ? null : submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : Text(
            "Hire",
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Direct Hire", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              buildLabel("Title *"),
              const SizedBox(height: 6),
              buildTextField(
                "Enter Title of work ",
                titleController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z_.,\s]')),
                ],
              ),
              const SizedBox(height: 14),
              buildLabel("Description *"),
              const SizedBox(height: 6),
              buildDescriptionField(),
              const SizedBox(height: 14),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     buildLabel("Location *"),
              //   ],
              // ),
              // const SizedBox(height: 6),
              // GestureDetector(
              //   onTap: controller.navigateToLocationScreen,
              //   child: TextFormField(
              //     enabled: false,
              //     controller: controller.addressController,
              //     style: const TextStyle(fontSize: 16, color: Colors.green),
              //     decoration: _inputDecoration(controller.userLocation.value).copyWith(
              //       suffixIcon: IconButton(
              //         icon: const Icon(Icons.my_location, color: AppColors.primaryGreen),
              //         onPressed: controller.getCurrentLocation,
              //       ),
              //     ),
              //     validator: (val) => val == null || val.isEmpty || val == 'Select Location' ? "Please enter a valid address" : null,
              //   ),
              // ),
              const SizedBox(height: 14),
              buildLabel("Full Address"),
              Obx(
                    () => InkWell(
                  onTap: controller.navigateToLocationScreen, // Make tappable
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color:  Colors.grey[100],
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.fullAddress.value.isNotEmpty
                              ? controller.fullAddress.value
                              : "No address found",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.black45,

                          ),
                        ),
                        // const SizedBox(height: 4),
                        // Text(
                        //   controller.fullAddress.value,
                        //   style: GoogleFonts.roboto(
                        //     fontSize: 14,
                        //     color: Colors.black87,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              buildLabel("Do you want to go to his shop? *"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Yes"),
                      value: "Yes",
                      groupValue: _goToShopSelection,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (value) {
                        setState(() {
                          _goToShopSelection = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("No"),
                      value: "No",
                      groupValue: _goToShopSelection,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (value) {
                        setState(() {
                          _goToShopSelection = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              buildLabel("Estimated Time of Completion *"),
              const SizedBox(height: 6),
              buildDatePicker(),
              const SizedBox(height: 14),
              buildLabel("Upload Images"),
              const SizedBox(height: 6),
              buildImageUpload(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
    );
  }

  Widget buildTextField(
      String hint,
      TextEditingController controller, {
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      inputFormatters: inputFormatters ?? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.,\s]'))],
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget buildDescriptionField() {
    return TextField(
      controller: descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Write description...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget buildDatePicker() {
    return TextField(
      readOnly: true,
      onTap: pickDate,
      decoration: InputDecoration(
        hintText: selectedDate == null || selectedTime == null
            ? "Select date and time"
            : "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget buildImageUpload() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
      ),
      child: selectedImages.isEmpty
          ? GestureDetector(
        onTap: pickImages,
        child: const Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Upload Images ", style: TextStyle(color: Colors.green)),
              Icon(Icons.add, color: Colors.green),
            ],
          ),
        ),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == selectedImages.length) {
            return GestureDetector(
              onTap: pickImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.blue, size: 40),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(selectedImages[index].path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    height: 0.05.toWidthPercent(),
                    width: 0.05.toWidthPercent(),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedImages.removeAt(index);
                        });
                      },
                      child: Icon(Icons.close, size: 0.05.toWidthPercent(), color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16),
    prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.green)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.green)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.green, width: 2)),
    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.green)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    filled: true,
    fillColor: Colors.grey[100],
  );

  Future<bool> showDetails(context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Payment Confirmation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Image.asset(BharatAssets.payConfLogo2),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(
                          DateFormat("dd-MM-yy").format(DateTime.now()),
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Time", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(
                          DateFormat("hh:mm a").format(DateTime.now()),
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Platform fees", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(platformFee != null ? "$platformFee INR" : "N/A", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Image.asset(BharatAssets.payLine),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                        Text(platformFee != null ? "$platformFee /-" : "N/A", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 4, color: Colors.green),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 35,
                        width: 0.28.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xff228B22)),
                        child: Text("Pay", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 35,
                        width: 0.28.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 1.5),
                        ),
                        child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.green)),
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
}