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
import 'package:geolocator/geolocator.dart'; // ✅ Location ke liye
import 'package:geocoding/geocoding.dart'; // ✅ Address string ke liye
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
  TimeOfDay? selectedTime; // ✅ Time picker ke liye
  List<XFile> selectedImages = [];
  int? platformFee;
  final controller = Get.put(PostTaskController(), permanent: false);
  var isLoading = false;
  var profile = Rxn<ServiceProviderProfileModel>();
  var late;
  var long;
  var addre;
  String? _goToShopSelection;
  String get _dynamicShopAddress => profile.value?.businessAddress?.address?.isNotEmpty == true
      ? profile.value!.businessAddress!.address!
      : "Shop Address: Not Available";
  @override
  void initState() {
    super.initState();
    fetchPlatformFee();
    fetchProfile();
  }

  // Abhishek added this api

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
          // userLocation.value = apiLocation;
          addressController.text = apiLocation; // Sync addressController
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

  // ✅ Platform fee fetch karne ka function
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

  // ✅ Date picker ke liye function
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ✅ Time picker ke liye function
  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  // ✅ Images select karne ka function
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        if (selectedImages.length + pickedList.length <= 5) {
          selectedImages.addAll(pickedList);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maximum 5 images allowed")),
          );
        }
      });
    }
  }


  Future<void> getCurrentLocation() async {
    try {
      // Check aur request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission permanently denied")),
        );
        return;
      }

      // Current location fetch karo
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Coordinates se address string banayo
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Specific format: Plot Number, Area, City, State, Country
        final addressComponents = [
          placemark.street,
          placemark.subLocality,
          placemark.subThoroughfare, // Plot number ya house number
          placemark.thoroughfare, // Area ya street
          placemark.locality, // City
          placemark.administrativeArea, // State
          placemark.country, // Country
        ];
        // Null ya empty values hatao aur join karo
        final address = addressComponents
            .where((e) => e != null && e.isNotEmpty)
            .join(", ");
        setState(() {
          addressController.text = address;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to fetch address")),
        );
      }
    } catch (e) {
      print("❗ Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        // SnackBar(content: Text("Error fetching location: $e")),
        SnackBar(content: Text("Error fetching location: ")),
      );
    }
  }

  // ✅ Confirmation dialog
  // Future<bool> showConfirmationDialog() async {
  //   return await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         contentPadding: const EdgeInsets.all(24),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Image.asset(
  //               'assets/images/success.png',
  //               height: 120,
  //               width: 120,
  //               fit: BoxFit.cover,
  //             ),
  //             const SizedBox(height: 20),
  //             Text(
  //               "Are you Sure want to hire?",
  //               style: GoogleFonts.roboto(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.green.shade700,
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                     onPressed: () async{
  //                       final confirmed=await showDetails(context);
  //                       Navigator.pop(context,confirmed);
  //                     },
  //                     child: const Text(
  //                       "Okay",
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: OutlinedButton(
  //                     style: OutlinedButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       side: BorderSide(color: Colors.green.shade700),
  //                     ),
  //                     onPressed: () => Navigator.pop(context, false),
  //                     child: Text(
  //                       "Cancel",
  //                       style: GoogleFonts.roboto(
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.green.shade700,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   ) ??
  //       false;
  // }
  Future<bool> showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
               // padding: EdgeInsets.only(top: 0.2.toWidthPercent()),
                width: 0.6.toWidthPercent(),
                alignment: Alignment.center,
                child: Image.asset(BharatAssets.paymentConfLogo),
              ),
              SizedBox(height: 0.1.toWidthPercent()),
              Text(

                'Payment Proceed',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 35),
              Container(
                width: 169,
                height: 58,
                color: Color(0xffB1FDCA),
                alignment: Alignment.center,
                child: Text(
                  platformFee != null ? '₹${platformFee}' : '₹0',
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334247),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(BharatAssets.payImage),
              ),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xff228B22),
                      ),

                      // onPressed: () => Navigator.pop(context, true),
                      // child: const Text(
                      //   "Confirm",
                      //   style: TextStyle(color: Colors.white),

                      child: Text(
                        "Hire",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
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
                        border: Border.all(
                          color: Color(0xff228B22),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xff228B22),
                        ),
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

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final address = addressController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        // address.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedImages.isEmpty) {
      CustomSnackBar.show(
          context,
          message: 'Please fill all fields',
          type: SnackBarType.error
      );

      return;
    }

    final confirmed = await showConfirmationDialog();
    if (!mounted || !confirmed) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.hireScreen}'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    print("Abhi:- get date time :- ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}");

    final deadline =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

    print("Abhi:- get address by controller value : ${controller.addressController.text}");

    request.fields['first_provider_id'] = widget.firstProviderId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['address'] = controller.addressController.text;
    request.fields['deadline'] = deadline; // ✅ Deadline mein time bhi add kiya
    request.fields['latitude'] = late.toString();
    request.fields['longitude'] = long.toString();

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
final orderId=decoded["order"]["_id"];
        final paymentSuccess = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RazorpayScreen(
              razorpayOrderId: razorpayOrderId,
              amount: amount,
              providerId: widget.firstProviderId,
              orderId: orderId,
              // categoryId: widget.categoryId,
              // subcategoryId: widget.subcategoryId,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $respStr')),
        );
      }
    } catch (e) {
      print("❗ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    finally{
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("Abhi:-fast provider id :- ${widget.firstProviderId}");
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Direct Hire",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
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
              buildLabel("Title"),
              const SizedBox(height: 6),
              buildTextField("Enter Title of work", titleController),
              const SizedBox(height: 14),
              buildLabel("Platform Fees"),
              const SizedBox(height: 6),
              buildPlatformFeeField(),
              const SizedBox(height: 14),
              buildLabel("Description"),
              const SizedBox(height: 6),
              buildDescriptionField(),
              const SizedBox(height: 14),
              // buildLabel("Address"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  buildLabel("Location"),
                  InkWell(
                    onTap: controller.navigateToLocationScreen,
                    child: Container(
                      width: width * 0.35,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          "Change location",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // buildAddressField(),
              TextFormField(
                enabled: false,
                controller: controller.addressController,
                decoration: _inputDecoration(controller.userLocation.value).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: controller.getCurrentLocation,
                  ),
                ),
                validator: (val) => val == null || val.isEmpty || val == 'Select Location'
                    ? "Please enter a valid address"
                    : null,
              ),
              const SizedBox(height: 14),

              buildLabel("Do you want to go to his shop?"),
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
              // Conditional Uneditable Text Field for Shop Address
              if (_goToShopSelection == "Yes") ...[
                GestureDetector(
                  onTap: () {
                    if(profile.value?.businessAddress !=null){
                      MapLauncher.openMap(
                          latitude: profile.value!.businessAddress!.latitude,
                          longitude: profile.value!.businessAddress!.longitude,
                          address: profile.value!.businessAddress!.address
                      );
                    }
                  },
                  child: TextFormField(
                    enabled: false,
                    initialValue: _dynamicShopAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              buildLabel("Add deadline and time"),
              const SizedBox(height: 6),
              buildDatePicker(),
              const SizedBox(height: 14),
              buildLabel("Add time"),
              const SizedBox(height: 6),
              buildTimePicker(), // ✅ Time picker add kiya
              const SizedBox(height: 14),
              buildLabel("Upload Images"),
              const SizedBox(height: 6),
              buildImageUpload(),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: isLoading?null:submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ?  const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      "Hire",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Label widget
  Widget buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  // ✅ Text field widget
  Widget buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // ✅ Platform fee field
  Widget buildPlatformFeeField() {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        hintText: platformFee != null ? "Rs $platformFee.00" : "Loading...",
        hintStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // ✅ Description field
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

  // ✅ Address field with location icon tap
  Widget buildAddressField() {

    return TextField(
      controller:  addressController,
      decoration: InputDecoration(
        hintText: "Enter Full Address",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: GestureDetector(
          onTap: getCurrentLocation, // ✅ Location icon par tap se current location fetch
          child: const Icon(Icons.location_on, color: Colors.green),
        ),
      ),
    );
  }

  // ✅ Date picker field
  Widget buildDatePicker() {
    return TextField(
      readOnly: true,
      onTap: pickDate,
      decoration: InputDecoration(
        hintText: selectedDate == null
            ? "Select date"
            : "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // ✅ Time picker field
  Widget buildTimePicker() {
    return TextField(
      readOnly: true,
      onTap: pickTime,
      decoration: InputDecoration(
        hintText: selectedTime == null
            ? "Select time"
            : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
        prefixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // ✅ Image upload widget
  Widget buildImageUpload() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: selectedImages.isEmpty
          ? GestureDetector(
        onTap: pickImages,
        child: const Center(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Upload Images ",
                style: TextStyle(color: Colors.green),
              ),Icon(Icons.add,color: Colors.green,)
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
                  child: Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 40,
                  ),
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
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        selectedImages.removeAt(index);
                      });
                    },
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
    prefixIcon: icon != null ? Icon(icon) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 12,
    ),
  );


     Future<bool>showDetails(context) async{

      return await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24,horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Payment Confirmation",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image
                  Image.asset(BharatAssets.payConfLogo2),
                  const SizedBox(height: 24),

                  // Details section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Date",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
                          Text(
                           DateFormat("dd-MM-yy").format(
                              DateTime.now(),
                            ),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                          ),                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Time",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                          Text(
                             DateFormat("hh:mm a").format(
                              DateTime.now(),),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                          ),                    ],
                      ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text("Amount",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                      //     Text("${responseModel.order?.servicePayment?.amount} RS",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
                      //   ],
                      // ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Platform fees",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                          Text(platformFee != null ? "$platformFee INR" : "N/A",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Image.asset(BharatAssets.payLine),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            platformFee != null ? "$platformFee /-" : "N/A",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 4,color: Colors.green,),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () =>Navigator.pop(context, true),
                        child: Container(
                          height: 35,
                          width: 0.28.toWidthPercent(),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xff228B22)
                          ),
                          child: Text("Pay",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),),
                        ),
                      ),
                      InkWell(
                        onTap: ()=>Navigator.pop(context, false),
                        child: Container(
                          height: 35,
                          width: 0.28.toWidthPercent(),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green, // ✅ Green border
                              width: 1.5,          // thickness of border
                            ),

                          ),
                          child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.green),),
                        ),
                      )
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

