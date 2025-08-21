// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:fluttertoast/fluttertoast.dart';
// // // import 'package:geocoding/geocoding.dart';
// // // import 'package:geolocator/geolocator.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:mime/mime.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import '../../../../Widgets/AppColors.dart';
// // // import '../../../directHiring/models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// // // import '../../../directHiring/views/auth/MapPickerScreen.dart';
// // // import '../../../directHiring/views/comm/home_location_screens.dart';
// // //
// // // class PostTaskScreen extends StatefulWidget {
// // //   const PostTaskScreen({super.key});
// // //
// // //   @override
// // //   State<PostTaskScreen> createState() => _PostTaskScreenState();
// // // }
// // //
// // // class _PostTaskScreenState extends State<PostTaskScreen> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final TextEditingController _dateController = TextEditingController();
// // //
// // //   List<File> _selectedImages = [];
// // //   DateTime? _selectedDate;
// // //
// // //   final titleController = TextEditingController();
// // //   final addressController = TextEditingController();
// // //   final googleAddressController = TextEditingController();
// // //   final descriptionController = TextEditingController();
// // //   final costController = TextEditingController();
// // //
// // //   String? selectedCategoryId;
// // //   List<Map<String, String>> categories = [];
// // //   List<Map<String, String>> allSubCategories = [];
// // //   List<String> selectedSubCategoryIds = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     fetchCategories();
// // //     _initializeLocation();
// // //   }
// // //   bool _isSwitched = false;
// // //   String userLocation = "Select Location"; // Changed to single source of truth
// // //   ServiceProviderProfileModel? profile;
// // //   bool isLoading = true;
// // //   bool _showReviews = true;
// // //   String? address = "";
// // //
// // //
// // //
// // //   // Combined method to load saved location and fetch from API if needed
// // //   Future<void> _initializeLocation() async {
// // //     setState(() {
// // //       isLoading = true; // Show loading until location is resolved
// // //     });
// // //
// // //     final prefs = await SharedPreferences.getInstance();
// // //     String? savedLocation =
// // //         prefs.getString("selected_location") ?? prefs.getString("address");
// // //
// // //     if (savedLocation != null && savedLocation != "Select Location") {
// // //       // If saved location exists, use it
// // //       setState(() {
// // //         userLocation = savedLocation;
// // //         isLoading = false;
// // //       });
// // //       print("📍 Loaded saved location: $savedLocation");
// // //       return;
// // //     }
// // //
// // //     // If no saved location, fetch from API
// // //     await fetchProfile();
// // //
// // //
// // //   }
// // //
// // //   Future<void> fetchProfile() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final token = prefs.getString('token') ?? '';
// // //       if (token.isEmpty) {
// // //         if (mounted) {
// // //           Fluttertoast.showToast(msg: "No token found, please log in again!");
// // //         }
// // //         setState(() {
// // //           isLoading = false;
// // //         });
// // //         return;
// // //       }
// // //
// // //       final url = Uri.parse(
// // //         "https://api.thebharatworks.com/api/user/getUserProfileData",
// // //       );
// // //       final response = await http.get(
// // //         url,
// // //         headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
// // //       );
// // //       print("📡 Full API Response: ${response.body}");
// // //
// // //       if (response.statusCode == 200) {
// // //         final data = json.decode(response.body);
// // //         print("📋 Data: $data");
// // //
// // //         if (data['status'] == true) {
// // //           String apiLocation = 'Select Location';
// // //           String? addressId;
// // //
// // //           // Check full_address for the latest "Current Location"
// // //           if (data['data']?['full_address'] != null &&
// // //               data['data']['full_address'].isNotEmpty) {
// // //             final addresses = data['data']['full_address'] as List;
// // //             final currentLocations =
// // //             addresses
// // //                 .where((addr) => addr['title'] == 'Current Location')
// // //                 .toList();
// // //             if (currentLocations.isNotEmpty) {
// // //               final latestLocation = currentLocations.last;
// // //               apiLocation = latestLocation['address'] ?? 'Select Location';
// // //               addressId = latestLocation['_id'];
// // //             } else {
// // //               final latestAddress = addresses.last;
// // //               apiLocation = latestAddress['address'] ?? 'Select Location';
// // //               addressId = latestAddress['_id'];
// // //             }
// // //           }
// // //
// // //           // Save to SharedPreferences
// // //           await prefs.setString("address", apiLocation);
// // //           if (addressId != null) {
// // //             await prefs.setString("selected_address_id", addressId);
// // //           }
// // //
// // //           setState(() {
// // //             profile = ServiceProviderProfileModel.fromJson(data['data']);
// // //             userLocation = apiLocation;
// // //             isLoading = false;
// // //           });
// // //           print(
// // //             "📍 Saved and displayed location: $apiLocation (ID: $addressId)",
// // //           );
// // //         } else {
// // //           if (mounted) {
// // //             Fluttertoast.showToast(
// // //               msg: data["message"] ?? "Profile fetch failed",
// // //             );
// // //           }
// // //           setState(() {
// // //             isLoading = false;
// // //           });
// // //         }
// // //       } else {
// // //         if (mounted) {
// // //           Fluttertoast.showToast(msg: "Server error, profile fetch failed!");
// // //         }
// // //         setState(() {
// // //           isLoading = false;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       print("❌ Error fetching profile: $e");
// // //       if (mounted) {
// // //         Fluttertoast.showToast(msg: "Something went wrong, try again!");
// // //       }
// // //       setState(() {
// // //         isLoading = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   // Update location on server
// // //   Future<void> updateLocationOnServer(
// // //       String newAddress,
// // //       double latitude,
// // //       double longitude,
// // //       ) async {
// // //     if (newAddress.isEmpty || latitude == 0.0 || longitude == 0.0) {
// // //       if (mounted) {
// // //         Fluttertoast.showToast(msg: "Invalid location data!");
// // //       }
// // //       return;
// // //     }
// // //
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final token = prefs.getString('token') ?? '';
// // //       final url = Uri.parse(
// // //         "https://api.thebharatworks.com/api/user/updateUserProfile",
// // //       );
// // //       final response = await http.post(
// // //         url,
// // //         headers: {
// // //           HttpHeaders.authorizationHeader: 'Bearer $token',
// // //           'Content-Type': 'application/json',
// // //         },
// // //         body: json.encode({
// // //           'full_address': [
// // //             {
// // //               'address': newAddress,
// // //               'latitude': latitude,
// // //               'longitude': longitude,
// // //               'title': 'Current Location',
// // //               'landmark': '',
// // //             },
// // //           ],
// // //           'location': {
// // //             'latitude': latitude,
// // //             'longitude': longitude,
// // //             'address': newAddress,
// // //           },
// // //         }),
// // //       );
// // //
// // //       print(
// // //         "📡 Location update response: ${response.statusCode} - ${response.body}",
// // //       );
// // //
// // //       if (response.statusCode == 200) {
// // //         final data = json.decode(response.body);
// // //         if (data['status'] == true) {
// // //           String? newAddressId = data['data']?['full_address']?.last?['_id'];
// // //           await prefs.setString("selected_location", newAddress);
// // //           await prefs.setString("address", newAddress);
// // //           await prefs.setDouble("user_latitude", latitude);
// // //           await prefs.setDouble("user_longitude", longitude);
// // //           if (newAddressId != null) {
// // //             await prefs.setString("selected_address_id", newAddressId);
// // //           }
// // //           setState(() {
// // //             userLocation = newAddress;
// // //             isLoading = false;
// // //           });
// // //           print("📍 Location updated: $newAddress (ID: $newAddressId)");
// // //           if (mounted) {
// // //             // Fluttertoast.showToast(msg: "Location updated: $newAddress");
// // //           }
// // //         } else {
// // //           if (mounted) {
// // //             // Fluttertoast.showToast(
// // //             //   msg: data["message"] ?? "Failed to update location",
// // //             // );
// // //           }
// // //         }
// // //       } else {
// // //         if (mounted) {
// // //           Fluttertoast.showToast(
// // //             msg: "Server error, failed to update location!",
// // //           );
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print("❌ Error updating location: $e");
// // //       if (mounted) {
// // //         Fluttertoast.showToast(msg: "Error updating location!");
// // //       }
// // //     }
// // //   }
// // //
// // //
// // //   void _navigateToLocationScreen() async {
// // //     final result = await Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder:
// // //             (context) => LocationSelectionScreen(
// // //
// // //           onLocationSelected: (Map<String, dynamic> locationData) {
// // //             setState(() {
// // //               userLocation = locationData['address'] ?? 'Select Location';
// // //               debugPrint(
// // //                 "📍 New location selected: ${locationData['address']} (ID: ${locationData['addressId']})",
// // //               );
// // //             });
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //     if (result != null && result is Map<String, dynamic>) {
// // //       String newAddress = result['address'] ?? 'Select Location';
// // //       double latitude = result['latitude'] ?? 0.0;
// // //       double longitude = result['longitude'] ?? 0.0;
// // //       String? addressId = result['addressId'];
// // //       if (newAddress != 'Select Location' &&
// // //           latitude != 0.0 &&
// // //           longitude != 0.0) {
// // //         await updateLocationOnServer(newAddress, latitude, longitude);
// // //         // Save addressId to SharedPreferences
// // //         if (addressId != null) {
// // //           final prefs = await SharedPreferences.getInstance();
// // //           await prefs.setString('selected_address_id', addressId);
// // //         }
// // //         // Refresh location
// // //         await _fetchLocation();
// // //       } else {
// // //         debugPrint("❌ Invalid location data received: $result");
// // //         if (mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(
// // //               content: Text("Invalid location data, please try again!"),
// // //               duration: Duration(seconds: 2),
// // //             ),
// // //           );
// // //         }
// // //       }
// // //     }
// // //   }
// // //
// // //   Future<void> _fetchLocation() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     String? savedLocation =
// // //         prefs.getString('selected_location') ?? prefs.getString('address');
// // //     String? savedAddressId = prefs.getString('selected_address_id');
// // //
// // //     if (savedLocation != null &&
// // //         savedLocation != 'Select Location' &&
// // //         savedAddressId != null) {
// // //       setState(() {
// // //         userLocation = savedLocation;
// // //         isLoading = false;
// // //       });
// // //       debugPrint(
// // //         "📍 Prioritized saved location: $userLocation (ID: $savedAddressId)",
// // //       );
// // //       return;
// // //     }
// // //
// // //     // If no saved location, fetch from API
// // //     setState(() {
// // //       isLoading = true;
// // //     });
// // //
// // //     final token = prefs.getString('token');
// // //     if (token == null || token.isEmpty) {
// // //       debugPrint("❌ No token found!");
// // //       setState(() {
// // //         userLocation = savedLocation ?? 'Select Location';
// // //         isLoading = false;
// // //       });
// // //       debugPrint("📍 Using saved or default location: $userLocation");
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Authentication failed, please log in again!'),
// // //             duration: Duration(seconds: 2),
// // //           ),
// // //         );
// // //       }
// // //       return;
// // //     }
// // //
// // //     try {
// // //       final url = Uri.parse(
// // //         'https://api.thebharatworks.com/api/user/getUserProfileData',
// // //       );
// // //       final response = await http.get(
// // //         url,
// // //         headers: {
// // //           'Authorization': 'Bearer $token',
// // //           'Content-Type': 'application/json',
// // //         },
// // //       );
// // //
// // //       debugPrint(
// // //         "📡 API response received: ${response.statusCode} - ${response.body}",
// // //       );
// // //
// // //       if (response.statusCode == 200) {
// // //         final responseData = jsonDecode(response.body);
// // //         if (responseData['status'] == true) {
// // //           final data = responseData['data'];
// // //           String apiLocation = 'Select Location';
// // //           double latitude = 0.0;
// // //           double longitude = 0.0;
// // //           String? addressId;
// // //
// // //           // Check for matching address based on savedAddressId
// // //           if (savedAddressId != null && data['full_address'] != null) {
// // //             final matchingAddress = data['full_address'].firstWhere(
// // //                   (address) => address['_id'] == savedAddressId,
// // //               orElse: () => null,
// // //             );
// // //             if (matchingAddress != null) {
// // //               apiLocation = matchingAddress['address'] ?? 'Select Location';
// // //               latitude = matchingAddress['latitude']?.toDouble() ?? 0.0;
// // //               longitude = matchingAddress['longitude']?.toDouble() ?? 0.0;
// // //               addressId = matchingAddress['_id'];
// // //             }
// // //           }
// // //
// // //           // If no matching address or savedAddressId, use latest "Current Location" address
// // //           if (apiLocation == 'Select Location' &&
// // //               data['full_address'] != null &&
// // //               data['full_address'].isNotEmpty) {
// // //             final currentLocations =
// // //             data['full_address']
// // //                 .where((address) => address['title'] == 'Current Location')
// // //                 .toList();
// // //             if (currentLocations.isNotEmpty) {
// // //               // Use the latest "Current Location" address
// // //               final latestCurrentLocation = currentLocations.last;
// // //               apiLocation =
// // //                   latestCurrentLocation['address'] ?? 'Select Location';
// // //               latitude = latestCurrentLocation['latitude']?.toDouble() ?? 0.0;
// // //               longitude = latestCurrentLocation['longitude']?.toDouble() ?? 0.0;
// // //               addressId = latestCurrentLocation['_id'];
// // //             } else {
// // //               // Fallback to the last address
// // //               final latestAddress = data['full_address'].last;
// // //               apiLocation = latestAddress['address'] ?? 'Select Location';
// // //               latitude = latestAddress['latitude']?.toDouble() ?? 0.0;
// // //               longitude = latestAddress['longitude']?.toDouble() ?? 0.0;
// // //               addressId = latestAddress['_id'];
// // //             }
// // //           } else if (data['location']?['address']?.isNotEmpty == true) {
// // //             // Fallback to location.address
// // //             apiLocation = data['location']['address'];
// // //             latitude = data['location']['latitude']?.toDouble() ?? 0.0;
// // //             longitude = data['location']['longitude']?.toDouble() ?? 0.0;
// // //           }
// // //
// // //           debugPrint(
// // //             "📍 Location fetched from API: $apiLocation (ID: $addressId)",
// // //           );
// // //
// // //           // Save API location to SharedPreferences
// // //           await prefs.setString('selected_location', apiLocation);
// // //           await prefs.setString('address', apiLocation);
// // //           await prefs.setDouble('user_latitude', latitude);
// // //           await prefs.setDouble('user_longitude', longitude);
// // //           if (addressId != null) {
// // //             await prefs.setString('selected_address_id', addressId);
// // //           }
// // //
// // //           setState(() {
// // //             userLocation = apiLocation;
// // //             isLoading = false;
// // //           });
// // //           debugPrint(
// // //             "📍 Saved API location and displayed in UI: $userLocation (ID: $addressId)",
// // //           );
// // //         } else {
// // //           setState(() {
// // //             userLocation = savedLocation ?? 'Select Location';
// // //             isLoading = false;
// // //           });
// // //           debugPrint("❌ API error: ${responseData['message']}");
// // //           if (mounted) {
// // //             ScaffoldMessenger.of(context).showSnackBar(
// // //               SnackBar(
// // //                 content: Text(
// // //                   responseData['message'] ?? 'Failed to fetch profile',
// // //                 ),
// // //                 duration: const Duration(seconds: 2),
// // //               ),
// // //             );
// // //           }
// // //         }
// // //       } else {
// // //         setState(() {
// // //           userLocation = savedLocation ?? 'Select Location';
// // //           isLoading = false;
// // //         });
// // //         debugPrint("❌ API call failed: ${response.statusCode}");
// // //         if (mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(
// // //               content: Text('Failed to fetch profile data!'),
// // //               duration: Duration(seconds: 2),
// // //             ),
// // //           );
// // //         }
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error fetching location: $e");
// // //       setState(() {
// // //         userLocation = savedLocation ?? 'Select Location';
// // //         isLoading = false;
// // //       });
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('Error fetching location: $e'),
// // //             duration: const Duration(seconds: 2),
// // //           ),
// // //         );
// // //       }
// // //     }
// // //   }
// // //
// // //
// // //   Future<void> fetchCategories() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //
// // //     final res = await http.get(
// // //       Uri.parse('https://api.thebharatworks.com/api/work-category'),
// // //       headers: {'Authorization': 'Bearer $token'},
// // //     );
// // //
// // //     if (res.statusCode == 200) {
// // //       final data = jsonDecode(res.body);
// // //       setState(() {
// // //         categories = List<Map<String, String>>.from(
// // //           data['data'].map(
// // //                 (cat) => {
// // //               'id': cat['_id'].toString(),
// // //               'name': cat['name'].toString(),
// // //             },
// // //           ),
// // //         );
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> fetchSubCategories(String categoryId) async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //
// // //     final res = await http.get(
// // //       Uri.parse('https://api.thebharatworks.com/api/subcategories/$categoryId'),
// // //       headers: {'Authorization': 'Bearer $token'},
// // //     );
// // //
// // //     if (res.statusCode == 200) {
// // //       final data = jsonDecode(res.body);
// // //       setState(() {
// // //         allSubCategories = List<Map<String, String>>.from(
// // //           data['data'].map(
// // //                 (sub) => {
// // //               'id': sub['_id'].toString(),
// // //               'name': sub['name'].toString(),
// // //             },
// // //           ),
// // //         );
// // //       });
// // //     }
// // //   }
// // //
// // //   void _showSubcategoryDialog() {
// // //     List<String> tempSelected = List.from(selectedSubCategoryIds);
// // //
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) {
// // //         return StatefulBuilder(
// // //           builder: (context, setDialogState) {
// // //             return AlertDialog(
// // //               title: const Text("Select Subcategories"),
// // //               content: SizedBox(
// // //                 width: double.maxFinite,
// // //                 child: ListView.builder(
// // //                   shrinkWrap: true,
// // //                   itemCount: allSubCategories.length,
// // //                   itemBuilder: (context, index) {
// // //                     final sub = allSubCategories[index];
// // //                     final subId = sub['id']!;
// // //                     return CheckboxListTile(
// // //                       title: Text(sub['name'] ?? ''),
// // //                       value: tempSelected.contains(subId),
// // //                       onChanged: (bool? value) {
// // //                         setDialogState(() {
// // //                           if (value == true) {
// // //                             tempSelected.add(subId);
// // //                           } else {
// // //                             tempSelected.remove(subId);
// // //                           }
// // //                         });
// // //                       },
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //               actions: [
// // //                 TextButton(
// // //                   onPressed: () => Navigator.pop(context),
// // //                   child: const Text("Cancel"),
// // //                 ),
// // //                 TextButton(
// // //                   onPressed: () {
// // //                     setState(() {
// // //                       selectedSubCategoryIds = tempSelected;
// // //                     });
// // //                     Navigator.pop(context);
// // //                   },
// // //                   child: const Text("Done"),
// // //                 ),
// // //               ],
// // //             );
// // //           },
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   Future<void> _selectDate(BuildContext context) async {
// // //     final picked = await showDatePicker(
// // //       context: context,
// // //       initialDate: DateTime.now().add(const Duration(days: 1)),
// // //       firstDate: DateTime.now(),
// // //       lastDate: DateTime(2100),
// // //     );
// // //     if (picked != null) {
// // //       setState(() {
// // //         _selectedDate = picked;
// // //         _dateController.text =
// // //         "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> _pickImage() async {
// // //     if (_selectedImages.length >= 5) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Maximum 5 images allowed.")),
// // //       );
// // //       return;
// // //     }
// // //
// // //     final picker = ImagePicker();
// // //     final int remaining = 5 - _selectedImages.length;
// // //
// // //     if (remaining == 1) {
// // //       // Use pickImage for single image selection
// // //       final XFile? pickedImage = await picker.pickImage(
// // //         source: ImageSource.gallery,
// // //         imageQuality: 70,
// // //       );
// // //       if (pickedImage != null) {
// // //         setState(() {
// // //           _selectedImages.add(File(pickedImage.path));
// // //         });
// // //       }
// // //     } else {
// // //       // Use pickMultiImage for multiple images
// // //       final List<XFile>? pickedImages = await picker.pickMultiImage(
// // //         imageQuality: 70,
// // //       );
// // //       if (pickedImages != null && pickedImages.isNotEmpty) {
// // //         // Ensure total images do not exceed 5
// // //         final newImages = pickedImages.map((x) => File(x.path)).toList();
// // //         final totalImages = _selectedImages.length + newImages.length;
// // //         if (totalImages > 5) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Cannot select more than 5 images.")),
// // //           );
// // //           // Take only the allowed number of images
// // //           setState(() {
// // //             _selectedImages.addAll(newImages.take(5 - _selectedImages.length));
// // //           });
// // //         } else {
// // //           setState(() {
// // //             _selectedImages.addAll(newImages);
// // //           });
// // //         }
// // //       }
// // //     }
// // //   }
// // //
// // //   Future<void> _getCurrentLocation() async {
// // //     try {
// // //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// // //       if (!serviceEnabled) {
// // //         // Location services are not enabled, prompt to enable
// // //         bool opened = await Geolocator.openLocationSettings();
// // //         if (!opened) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Please enable location services from settings.")),
// // //           );
// // //           return;
// // //         }
// // //         // Check again after opening settings
// // //         serviceEnabled = await Geolocator.isLocationServiceEnabled();
// // //         if (!serviceEnabled) {
// // //           return;
// // //         }
// // //       }
// // //
// // //       LocationPermission permission = await Geolocator.checkPermission();
// // //       if (permission == LocationPermission.denied) {
// // //         permission = await Geolocator.requestPermission();
// // //         if (permission == LocationPermission.denied) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Location permission denied.")),
// // //           );
// // //           return;
// // //         }
// // //       }
// // //
// // //       if (permission == LocationPermission.deniedForever) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text("Location permission denied forever. Please enable from app settings.")),
// // //         );
// // //         await Geolocator.openAppSettings();
// // //         return;
// // //       }
// // //
// // //       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
// // //       List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
// // //       if (placemarks.isNotEmpty) {
// // //         Placemark place = placemarks[0];
// // //         String formattedAddress = [
// // //           place.street,
// // //           place.subLocality,
// // //           place.locality,
// // //           place.postalCode,
// // //           place.administrativeArea,
// // //           place.country,
// // //         ].where((e) => e != null && e.isNotEmpty).join(', ');
// // //
// // //         setState(() {
// // //           addressController.text = formattedAddress;
// // //         });
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text("Unable to fetch address from location.")),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text("Error fetching location: $e")),
// // //       );
// // //     }
// // //   }
// // //
// // //   Future<void> _submitTask() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final token = prefs.getString('token') ?? '';
// // //
// // //       String formattedDeadline =
// // //       _selectedDate != null
// // //           ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
// // //           : "2025-08-01";
// // //
// // //       List<String> base64Images = [];
// // //       for (var image in _selectedImages) {
// // //         final bytes = await image.readAsBytes();
// // //         final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
// // //         base64Images.add("data:$mimeType;base64,${base64Encode(bytes)}");
// // //       }
// // //
// // //       final body = {
// // //         "title": titleController.text.trim(),
// // //         "category_id": selectedCategoryId,
// // //         "sub_category_ids": selectedSubCategoryIds.join(','),
// // //         "address": addressController.text.trim(),
// // //         "google_address": googleAddressController.text.trim(),
// // //         "description": descriptionController.text.trim(),
// // //         "cost": costController.text.trim(),
// // //         "deadline": formattedDeadline,
// // //         if (base64Images.isNotEmpty) "images": base64Images,
// // //       };
// // //
// // //       final response = await http.post(
// // //         Uri.parse("https://api.thebharatworks.com/api/bidding-order/create"),
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer $token',
// // //         },
// // //         body: jsonEncode(body),
// // //       );
// // //
// // //       if (!mounted) return;
// // //
// // //       print("Abhi:- Post Task response ${response.body}");
// // //       print("Abhi:- Post Task response ${response.statusCode}");
// // //
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text("Task Posted Successfully")),
// // //         );
// // //         Navigator.pop(context);
// // //       } else if (response.statusCode == 401) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text(" Session expired. Please login again."),
// // //           ),
// // //         );
// // //         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
// // //       } else {
// // //         ScaffoldMessenger.of(
// // //           context,
// // //         ).showSnackBar(SnackBar(content: Text("❌ Failed: ${response.body}")));
// // //       }
// // //     } catch (e) {
// // //       if (!mounted) return;
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(SnackBar(content: Text("Error: Something went wrong ")));
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final height = MediaQuery.of(context).size.height;
// // //     final width = MediaQuery.of(context).size.width;
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         backgroundColor: AppColors.primaryGreen,
// // //         centerTitle: true,
// // //         elevation: 0,
// // //         toolbarHeight: 20,
// // //         automaticallyImplyLeading: false,
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Form(
// // //           key: _formKey,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _pageHeader(),
// // //               _buildLabel("Title"),
// // //               _buildTextField(titleController, "Enter Title of work"),
// // //
// // //               _buildLabel("Category"),
// // //               DropdownButtonFormField<String>(
// // //                 decoration: _inputDecoration("Choose category"),
// // //                 value: selectedCategoryId,
// // //                 items:
// // //                 categories
// // //                     .map(
// // //                       (cat) => DropdownMenuItem(
// // //                     value: cat['id'],
// // //                     child: Text(cat['name']!),
// // //                   ),
// // //                 )
// // //                     .toList(),
// // //                 onChanged: (val) {
// // //                   setState(() {
// // //                     selectedCategoryId = val;
// // //                     selectedSubCategoryIds.clear();
// // //                     allSubCategories = [];
// // //                   });
// // //                   if (val != null) fetchSubCategories(val);
// // //                 },
// // //                 validator: (val) => val == null ? "Please select a category" : null,
// // //               ),
// // //
// // //               _buildLabel("Sub Category (Multiple selection)"),
// // //               _subcategorySelector(),
// // //
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   _buildLabel("Location"),
// // //                   InkWell(
// // //                     onTap: _navigateToLocationScreen,
// // //                     child: Container(
// // //                       width: width*0.35,
// // //                       decoration: BoxDecoration(
// // //                           color: AppColors.primaryGreen,
// // //                           borderRadius: BorderRadius.circular(5)
// // //                       ),
// // //                       child: Center(child: Text("Change location",style: TextStyle(color: Colors.white),)),
// // //                     ),
// // //                   )
// // //                 ],
// // //               ),
// // //               TextFormField(
// // //                 // onTap: none,
// // //                 controller: userLocation ?? 'Select Location',              // ye value ko controller me add karo
// // //                 decoration: _inputDecoration("${userLocation ?? 'Select Location'}").copyWith(
// // //                   suffixIcon: IconButton(
// // //                     icon: const Icon(Icons.my_location),
// // //                     onPressed: _getCurrentLocation,
// // //                   ),
// // //                 ),
// // //                 validator: (val) => val == null || val.isEmpty ? "Please enter a valid address" : null,
// // //               ),
// // //
// // //               _buildLabel("Google Address"),
// // //               _googleLocationField(),
// // //
// // //               _buildLabel("Description"),
// // //               _buildTextField(
// // //                 descriptionController,
// // //                 "Describe your task",
// // //                 maxLines: 4,
// // //               ),
// // //
// // //               _buildLabel("Cost"),
// // //               _buildTextField(
// // //                 costController,
// // //                 "Enter cost in INR",
// // //                 keyboardType: TextInputType.number,
// // //                 validator: (val) {
// // //                   if (val == null || val.isEmpty) {
// // //                     return "Please enter the cost";
// // //                   }
// // //                   if (double.tryParse(val) == null) {
// // //                     return "Please enter a valid number";
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //
// // //               _buildLabel("Select Deadline"),
// // //               GestureDetector(
// // //                 onTap: () => _selectDate(context),
// // //                 child: AbsorbPointer(
// // //                   child: TextFormField(
// // //                     controller: _dateController,
// // //                     decoration: _inputDecoration(
// // //                       "Select Deadline Date",
// // //                       icon: Icons.calendar_today,
// // //                     ),
// // //                     validator:
// // //                         (val) =>
// // //                     val == null || val.isEmpty
// // //                         ? "Please pick a deadline"
// // //                         : null,
// // //                   ),
// // //                 ),
// // //               ),
// // //
// // //               _buildLabel("Upload Task Image"),
// // //               _buildImagePicker(),
// // //
// // //               const SizedBox(height: 24),
// // //               ElevatedButton(
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.green,
// // //                   minimumSize: const Size.fromHeight(50),
// // //                 ),
// // //                 onPressed: () {
// // //                   if (_formKey.currentState!.validate()) {
// // //                     if (selectedCategoryId == null) {
// // //                       ScaffoldMessenger.of(context).showSnackBar(
// // //                         const SnackBar(
// // //                           content: Text(
// // //                             "Please select a category",
// // //                           ),
// // //                         ),
// // //                       );
// // //                       return;
// // //                     }
// // //                     if (selectedSubCategoryIds.isEmpty) {
// // //                       ScaffoldMessenger.of(context).showSnackBar(
// // //                         const SnackBar(
// // //                           content: Text(
// // //                             "Please select at least one sub category",
// // //                           ),
// // //                         ),
// // //                       );
// // //                       return;
// // //                     }
// // //                     _submitTask();
// // //                   }
// // //                 },
// // //                 child: const Text("Post Task", style: TextStyle(fontSize: 16)),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _pageHeader() {
// // //     return Row(
// // //       children: [
// // //         GestureDetector(
// // //           onTap: () => Navigator.pop(context),
// // //           child: const Icon(Icons.arrow_back_outlined, color: Colors.black),
// // //         ),
// // //         const SizedBox(width: 86),
// // //         Text(
// // //           "Post New Task",
// // //           style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _googleLocationField() {
// // //     return GestureDetector(
// // //       onTap: () async {
// // //         final result = await Navigator.push(
// // //           context,
// // //           MaterialPageRoute(builder: (_) => MapPickerScreen()),
// // //         );
// // //         if (result != null && result is String) {
// // //           setState(() => googleAddressController.text = result);
// // //         }
// // //       },
// // //       child: AbsorbPointer(
// // //         child: TextFormField(
// // //           controller: googleAddressController,
// // //           decoration: _inputDecoration("Location", icon: Icons.my_location),
// // //           validator:
// // //               (val) => val == null || val.isEmpty ? "Please select a Google address" : null,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildLabel(String text) => Padding(
// // //     padding: const EdgeInsets.symmetric(vertical: 8),
// // //     child: Text(
// // //       text,
// // //       style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
// // //     ),
// // //   );
// // //
// // //   InputDecoration _inputDecoration(String hint, {IconData? icon}) =>
// // //       InputDecoration(
// // //         hintText: hint,
// // //         prefixIcon: icon != null ? Icon(icon) : null,
// // //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// // //         contentPadding: const EdgeInsets.symmetric(
// // //           vertical: 14,
// // //           horizontal: 12,
// // //         ),
// // //       );
// // //
// // //   Widget _buildTextField(
// // //       TextEditingController controller,
// // //       String hint, {
// // //         int maxLines = 1,
// // //         TextInputType? keyboardType,
// // //         String? Function(String?)? validator,
// // //       }) => TextFormField(
// // //     controller: controller,
// // //     keyboardType: keyboardType,
// // //     maxLines: maxLines,
// // //     decoration: _inputDecoration(hint),
// // //     validator: validator ?? (val) => val == null || val.isEmpty ? "This field is required" : null,
// // //   );
// // //
// // //   Widget _subcategorySelector() {
// // //     return GestureDetector(
// // //       onTap: () {
// // //         if (selectedCategoryId != null) {
// // //           _showSubcategoryDialog();
// // //         } else {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("️ Please select category first")),
// // //           );
// // //         }
// // //       },
// // //       child: _buildDropdownTile(selectedSubCategoryIds),
// // //     );
// // //   }
// // //
// // //   Widget _buildDropdownTile(List<String> selectedIds) => Container(
// // //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// // //     decoration: BoxDecoration(
// // //       border: Border.all(color: Colors.grey.shade400),
// // //       borderRadius: BorderRadius.circular(10),
// // //     ),
// // //     child: Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         Expanded(
// // //           child: Text(
// // //             selectedIds.isEmpty
// // //                 ? "Choose sub categories"
// // //                 : allSubCategories
// // //                 .where((sub) => selectedIds.contains(sub['id']))
// // //                 .map((sub) => sub['name'])
// // //                 .join(', '),
// // //             style: TextStyle(
// // //               fontSize: 14,
// // //               color: selectedIds.isEmpty ? Colors.grey : Colors.black,
// // //             ),
// // //           ),
// // //         ),
// // //         const Icon(Icons.arrow_drop_down),
// // //       ],
// // //     ),
// // //   );
// // //
// // //   Widget _buildImagePicker() {
// // //     return Column(
// // //       children: [
// // //         if (_selectedImages.isEmpty)
// // //           Center(
// // //             child: Column(
// // //               children: [
// // //                 GestureDetector(
// // //                   onTap: _pickImage,
// // //                   child: Container(
// // //                     height: 120,
// // //                     width: 270,
// // //                     padding: const EdgeInsets.all(12),
// // //                     decoration: BoxDecoration(
// // //                       border: Border.all(color: Colors.grey.shade300),
// // //                       borderRadius: BorderRadius.circular(10),
// // //                     ),
// // //                     child: Column(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         const Icon(Icons.upload, size: 20, color: Colors.green),
// // //                         Text(
// // //                           "Upload Work Photo",
// // //                           style: GoogleFonts.roboto(
// // //                             fontSize: 14,
// // //                             fontWeight: FontWeight.w600,
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 3),
// // //                         Container(
// // //                           padding: const EdgeInsets.symmetric(
// // //                             horizontal: 30,
// // //                             vertical: 10,
// // //                           ),
// // //                           decoration: BoxDecoration(
// // //                             border: Border.all(color: Colors.green),
// // //                             borderRadius: BorderRadius.circular(8),
// // //                           ),
// // //                           child: const Text(
// // //                             "Upload",
// // //                             style: TextStyle(
// // //                               color: Colors.green,
// // //                               fontSize: 16,
// // //                               fontWeight: FontWeight.w600,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 Text(
// // //                   "Upload (.png, .jpg, .jpeg) File (300px * 300px)",
// // //                   textAlign: TextAlign.center,
// // //                   style: GoogleFonts.roboto(
// // //                     fontSize: 13,
// // //                     fontWeight: FontWeight.w500,
// // //                     color: Colors.green,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           )
// // //         else
// // //           Wrap(
// // //             spacing: 8.0,
// // //             runSpacing: 8.0,
// // //             children: [
// // //               ..._selectedImages.map((img) => Stack(
// // //                 children: [
// // //                   ClipRRect(
// // //                     borderRadius: BorderRadius.circular(8),
// // //                     child: Image.file(
// // //                       img,
// // //                       height: 100,
// // //                       width: 100,
// // //                       fit: BoxFit.cover,
// // //                     ),
// // //                   ),
// // //                   Positioned(
// // //                     right: 0,
// // //                     top: 0,
// // //                     child: IconButton(
// // //                       icon: const Icon(Icons.close, color: Colors.red),
// // //                       onPressed: () {
// // //                         setState(() {
// // //                           _selectedImages.remove(img);
// // //                         });
// // //                       },
// // //                     ),
// // //                   ),
// // //                 ],
// // //               )),
// // //               if (_selectedImages.length < 5)
// // //                 GestureDetector(
// // //                   onTap: _pickImage,
// // //                   child: Container(
// // //                     height: 100,
// // //                     width: 100,
// // //                     decoration: BoxDecoration(
// // //                       border: Border.all(color: Colors.grey),
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: const Center(
// // //                       child: Icon(Icons.add, size: 50, color: Colors.green),
// // //                     ),
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //         const SizedBox(height: 10),
// // //       ],
// // //     );
// // //   }
// // // }
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:get/get_core/src/get_main.dart';
// // import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // import '../../../Widgets/AppColors.dart';
// // import '../../../directHiring/views/auth/MapPickerScreen.dart';
// // import '../../controller/buding_postTask_controller.dart';
// //
// // class PostTaskScreen extends StatelessWidget {
// //   const PostTaskScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final controller = Get.put(PostTaskController());
// //     final height = MediaQuery.of(context).size.height;
// //     final width = MediaQuery.of(context).size.width;
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         toolbarHeight: 20,
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: Obx(
// //             () => SingleChildScrollView(
// //           padding: const EdgeInsets.all(16),
// //           child: Form(
// //             key: controller.formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 _pageHeader(context),
// //                 _buildLabel("Title"),
// //                 _buildTextField(controller.titleController, "Enter Title of work"),
// //                 _buildLabel("Category"),
// //                 DropdownButtonFormField<String>(
// //                   decoration: _inputDecoration("Choose category"),
// //                   value: controller.selectedCategoryId.value,
// //                   items: controller.categories
// //                       .map(
// //                         (cat) => DropdownMenuItem(
// //                       value: cat['id'],
// //                       child: Text(cat['name']!),
// //                     ),
// //                   )
// //                       .toList(),
// //                   onChanged: (val) {
// //                     controller.selectedCategoryId.value = val;
// //                     controller.selectedSubCategoryIds.clear();
// //                     controller.allSubCategories.clear();
// //                     if (val != null) controller.fetchSubCategories(val);
// //                   },
// //                   validator: (val) => val == null ? "Please select a category" : null,
// //                 ),
// //                 _buildLabel("Sub Category (Multiple selection)"),
// //                 _subcategorySelector(controller),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     _buildLabel("Location"),
// //                     InkWell(
// //                       onTap: controller.navigateToLocationScreen,
// //                       child: Container(
// //                         width: width * 0.35,
// //                         decoration: BoxDecoration(
// //                           color: AppColors.primaryGreen,
// //                           borderRadius: BorderRadius.circular(5),
// //                         ),
// //                         child: const Center(
// //                           child: Text(
// //                             "Change location",
// //                             style: TextStyle(color: Colors.white),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 TextFormField( enabled: false,
// //                   controller: TextEditingController(text: controller.userLocation.value),
// //                   decoration: _inputDecoration(controller.userLocation.value).copyWith(
// //                     suffixIcon: IconButton(
// //                       icon: const Icon(Icons.my_location),
// //                       onPressed: controller.getCurrentLocation,
// //                     ),
// //                   ),
// //                   validator: (val) => val == null || val.isEmpty ? "Please enter a valid address" : null,
// //                 ),
// //                 _buildLabel("Google Address"),
// //                 _googleLocationField(controller),
// //                 _buildLabel("Description"),
// //                 _buildTextField(
// //                   controller.descriptionController,
// //                   "Describe your task",
// //                   maxLines: 4,
// //                 ),
// //                 _buildLabel("Cost"),
// //                 _buildTextField(
// //                   controller.costController,
// //                   "Enter cost in INR",
// //                   keyboardType: TextInputType.number,
// //                   validator: (val) {
// //                     if (val == null || val.isEmpty) {
// //                       return "Please enter the cost";
// //                     }
// //                     if (double.tryParse(val) == null) {
// //                       return "Please enter a valid number";
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 _buildLabel("Select Deadline"),
// //                 GestureDetector(
// //                   onTap: () => controller.selectDate(context),
// //                   child: AbsorbPointer(
// //                     child: TextFormField(
// //                       controller: controller.dateController,
// //                       decoration: _inputDecoration("Select Deadline Date", icon: Icons.calendar_today),
// //                       validator: (val) => val == null || val.isEmpty ? "Please pick a deadline" : null,
// //                     ),
// //                   ),
// //                 ),
// //                 _buildLabel("Upload Task Image"),
// //                 _buildImagePicker(controller),
// //                 const SizedBox(height: 24),
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     minimumSize: const Size.fromHeight(50),
// //                   ),
// //                   onPressed: () {
// //                     if (controller.formKey.currentState!.validate()) {
// //                       if (controller.selectedCategoryId.value == null) {
// //                         Get.snackbar("Error", "Please select a category");
// //                         return;
// //                       }
// //                       if (controller.selectedSubCategoryIds.isEmpty) {
// //                         Get.snackbar("Error", "Please select at least one sub category");
// //                         return;
// //                       }
// //                       controller.submitTask();
// //                     }
// //                   },
// //                   child: const Text("Post Task", style: TextStyle(fontSize: 16)),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _pageHeader(BuildContext context) {
// //     return Row(
// //       children: [
// //         GestureDetector(
// //           onTap: () => Get.back(),
// //           child: const Icon(Icons.arrow_back_outlined, color: Colors.black),
// //         ),
// //         const SizedBox(width: 86),
// //         Text(
// //           "Post New Task",
// //           style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _googleLocationField(PostTaskController controller) {
// //     return GestureDetector(
// //       onTap: () async {
// //         final result = await Get.to(() => MapPickerScreen());
// //         if (result != null && result is String) {
// //           controller.googleAddressController.text = result;
// //         }
// //       },
// //       child: AbsorbPointer(
// //         child: TextFormField(
// //           controller: controller.googleAddressController,
// //           decoration: _inputDecoration("Location", icon: Icons.my_location,),
// //           validator: (val) => val == null || val.isEmpty ? "Please select a Google address" : null,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLabel(String text) => Padding(
// //     padding: const EdgeInsets.symmetric(vertical: 8),
// //     child: Text(
// //       text,
// //       style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
// //     ),
// //   );
// //
// //   InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
// //     hintText: hint,
// //     prefixIcon: icon != null ? Icon(icon) : null,
// //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //     contentPadding: const EdgeInsets.symmetric(
// //       vertical: 14,
// //       horizontal: 12,
// //     ),
// //   );
// //
// //   Widget _buildTextField(
// //       TextEditingController controller,
// //       String hint, {
// //         int maxLines = 1,
// //         TextInputType? keyboardType,
// //         String? Function(String?)? validator,
// //       }) =>
// //       TextFormField(
// //         controller: controller,
// //         keyboardType: keyboardType,
// //         maxLines: maxLines,
// //         decoration: _inputDecoration(hint),
// //         validator: validator ?? (val) => val == null || val.isEmpty ? "This field is required" : null,
// //       );
// //
// //   Widget _subcategorySelector(PostTaskController controller) {
// //     return GestureDetector(
// //       onTap: () {
// //         if (controller.selectedCategoryId.value != null) {
// //           controller.showSubcategoryDialog();
// //         } else {
// //           Get.snackbar("Error", "Please select category first");
// //         }
// //       },
// //       child: _buildDropdownTile(controller),
// //     );
// //   }
// //
// //   Widget _buildDropdownTile(PostTaskController controller) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// //     decoration: BoxDecoration(
// //       border: Border.all(color: Colors.grey.shade400),
// //       borderRadius: BorderRadius.circular(10),
// //     ),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Expanded(
// //           child: Text(
// //             controller.selectedSubCategoryIds.isEmpty
// //                 ? "Choose sub categories"
// //                 : controller.allSubCategories
// //                 .where((sub) => controller.selectedSubCategoryIds.contains(sub['id']))
// //                 .map((sub) => sub['name'])
// //                 .join(', '),
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: controller.selectedSubCategoryIds.isEmpty ? Colors.grey : Colors.black,
// //             ),
// //           ),
// //         ),
// //         const Icon(Icons.arrow_drop_down),
// //       ],
// //     ),
// //   );
// //
// //   Widget _buildImagePicker(PostTaskController controller) {
// //     return Column(
// //       children: [
// //         if (controller.selectedImages.isEmpty)
// //           Center(
// //             child: Column(
// //               children: [
// //                 GestureDetector(
// //                   onTap: controller.pickImage,
// //                   child: Container(
// //                     height: 120,
// //                     width: 270,
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Colors.grey.shade300),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(Icons.upload, size: 20, color: Colors.green),
// //                         Text(
// //                           "Upload Work Photo",
// //                           style: GoogleFonts.roboto(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 3),
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 30,
// //                             vertical: 10,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             border: Border.all(color: Colors.green),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: const Text(
// //                             "Upload",
// //                             style: TextStyle(
// //                               color: Colors.green,
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   "Upload (.png, .jpg, .jpeg) File (300px * 300px)",
// //                   textAlign: TextAlign.center,
// //                   style: GoogleFonts.roboto(
// //                     fontSize: 13,
// //                     fontWeight: FontWeight.w500,
// //                     color: Colors.green,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         else
// //           Wrap(
// //             spacing: 8.0,
// //             runSpacing: 8.0,
// //             children: [
// //               ...controller.selectedImages.map((img) => Stack(
// //                 children: [
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(8),
// //                     child: Image.file(
// //                       img,
// //                       height: 100,
// //                       width: 100,
// //                       fit: BoxFit.cover,
// //                     ),
// //                   ),
// //                   Positioned(
// //                     right: 0,
// //                     top: 0,
// //                     child: IconButton(
// //                       icon: const Icon(Icons.close, color: Colors.red),
// //                       onPressed: () {
// //                         controller.selectedImages.remove(img);
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               )),
// //               if (controller.selectedImages.length < 5)
// //                 GestureDetector(
// //                   onTap: controller.pickImage,
// //                   child: Container(
// //                     height: 100,
// //                     width: 100,
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Colors.grey),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: const Center(
// //                       child: Icon(Icons.add, size: 50, color: Colors.green),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         const SizedBox(height: 10),
// //       ],
// //     );
// //   }
// // }
//
// /*
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../../directHiring/models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../../../directHiring/views/auth/MapPickerScreen.dart';
// import '../../../directHiring/views/comm/home_location_screens.dart';
// import '../../controller/buding_postTask_controller.dart';
// class PostTaskScreen extends StatelessWidget {
//   const PostTaskScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(PostTaskController());
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: Obx(
//             () => SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: controller.formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _pageHeader(context),
//                 _buildLabel("Title"),
//                 _buildTextField(controller.titleController, "Enter Title of work"),
//                 _buildLabel("Category"),
//                 DropdownButtonFormField<String>(
//                   decoration: _inputDecoration("Choose category"),
//                   value: controller.selectedCategoryId.value,
//                   items: controller.categories
//                       .map(
//                         (cat) => DropdownMenuItem(
//                       value: cat['id'],
//                       child: Text(cat['name']!),
//                     ),
//                   )
//                       .toList(),
//                   onChanged: (val) {
//                     controller.selectedCategoryId.value = val;
//                     controller.selectedSubCategoryIds.clear();
//                     controller.allSubCategories.clear();
//                     if (val != null) controller.fetchSubCategories(val);
//                   },
//                   validator: (val) => val == null ? "Please select a category" : null,
//                 ),
//                 _buildLabel("Sub Category (Multiple selection)"),
//                 _subcategorySelector(controller),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildLabel("Location"),
//                     InkWell(
//                       onTap: controller.navigateToLocationScreen,
//                       child: Container(
//                         width: width * 0.35,
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryGreen,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             "Change location",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextFormField(
//                   enabled: false,
//                   controller: controller.addressController, // Use addressController directly
//                   decoration: _inputDecoration(controller.userLocation.value).copyWith(
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.my_location),
//                       onPressed: controller.getCurrentLocation,
//                     ),
//                   ),
//                   validator: (val) => val == null || val.isEmpty || val == 'Select Location'
//                       ? "Please enter a valid address"
//                       : null,
//                 ),
//                 _buildLabel("Google Address"),
//                 _googleLocationField(controller),
//                 _buildLabel("Description"),
//                 _buildTextField(
//                   controller.descriptionController,
//                   "Describe your task",
//                   maxLines: 4,
//                 ),
//                 _buildLabel("Cost"),
//                 _buildTextField(
//                   controller.costController,
//                   "Enter cost in INR",
//                   keyboardType: TextInputType.number,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return "Please enter the cost";
//                     }
//                     if (double.tryParse(val) == null) {
//                       return "Please enter a valid number";
//                     }
//                     return null;
//                   },
//                 ),
//                 _buildLabel("Select Deadline"),
//                 GestureDetector(
//                   onTap: () => controller.selectDate(context),
//                   child: AbsorbPointer(
//                     child: TextFormField(
//                       controller: controller.dateController,
//                       decoration: _inputDecoration("Select Deadline Date", icon: Icons.calendar_today),
//                       validator: (val) => val == null || val.isEmpty ? "Please pick a deadline" : null,
//                     ),
//                   ),
//                 ),
//                 _buildLabel("Upload Task Image"),
//                 _buildImagePicker(controller),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                   onPressed: () {
//                     if (controller.formKey.currentState!.validate()) {
//                       if (controller.selectedCategoryId.value == null) {
//                         Get.snackbar("Error", "Please select a category",);
//                         return;
//                       }
//                       if (controller.selectedSubCategoryIds.isEmpty) {
//                         Get.snackbar("Error", "Please select at least one sub category");
//                         return;
//                       }
//                       controller.submitTask();
//                     }
//                   },
//                   child: const Text("Post Task", style: TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _pageHeader(BuildContext context) {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () => Get.back(),
//           child: const Icon(Icons.arrow_back_outlined, color: Colors.black),
//         ),
//         const SizedBox(width: 86),
//         Text(
//           "Post New Task",
//           style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
//
//   Widget _googleLocationField(PostTaskController controller) {
//     return GestureDetector(
//       onTap: () async {
//         final result = await Get.to(() => MapPickerScreen());
//         if (result != null && result is String) {
//           controller.googleAddressController.text = result;
//         }
//       },
//       child: AbsorbPointer(
//         child: TextFormField(
//           controller: controller.googleAddressController,
//           decoration: _inputDecoration("Location", icon: Icons.my_location),
//           validator: (val) => val == null || val.isEmpty ? "Please select a Google address" : null,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLabel(String text) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Text(
//       text,
//       style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
//     ),
//   );
//
//   InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
//     hintText: hint,
//     prefixIcon: icon != null ? Icon(icon) : null,
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//     contentPadding: const EdgeInsets.symmetric(
//       vertical: 14,
//       horizontal: 12,
//     ),
//   );
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String hint, {
//         int maxLines = 1,
//         TextInputType? keyboardType,
//         String? Function(String?)? validator,
//       }) =>
//       TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         decoration: _inputDecoration(hint),
//         validator: validator ?? (val) => val == null || val.isEmpty ? "This field is required" : null,
//       );
//
//   Widget _subcategorySelector(PostTaskController controller) {
//     return GestureDetector(
//       onTap: () {
//         if (controller.selectedCategoryId.value != null) {
//           controller.showSubcategoryDialog();
//         } else {
//           Get.snackbar("Error", "Please select category first");
//         }
//       },
//       child: _buildDropdownTile(controller),
//     );
//   }
//
//   Widget _buildDropdownTile(PostTaskController controller) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey.shade400),
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             controller.selectedSubCategoryIds.isEmpty
//                 ? "Choose sub categories"
//                 : controller.allSubCategories
//                 .where((sub) => controller.selectedSubCategoryIds.contains(sub['id']))
//                 .map((sub) => sub['name'])
//                 .join(', '),
//             style: TextStyle(
//               fontSize: 14,
//               color: controller.selectedSubCategoryIds.isEmpty ? Colors.grey : Colors.black,
//             ),
//           ),
//         ),
//         const Icon(Icons.arrow_drop_down),
//       ],
//     ),
//   );
//
//   Widget _buildImagePicker(PostTaskController controller) {
//     return Column(
//       children: [
//         if (controller.selectedImages.isEmpty)
//           Center(
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: controller.pickImage,
//                   child: Container(
//                     height: 120,
//                     width: 270,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.upload, size: 20, color: Colors.green),
//                         Text(
//                           "Upload Work Photo",
//                           style: GoogleFonts.roboto(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 30,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.green),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Text(
//                             "Upload",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Upload (.png, .jpg, .jpeg) File (300px * 300px)",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.roboto(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 8.0,
//             children: [
//               ...controller.selectedImages.map((img) => Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       img,
//                       height: 100,
//                       width: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: IconButton(
//                       icon: const Icon(Icons.close, color: Colors.red),
//                       onPressed: () {
//                         controller.selectedImages.remove(img);
//                       },
//                     ),
//                   ),
//                 ],
//               )),
//               if (controller.selectedImages.length < 5)
//                 GestureDetector(
//                   onTap: controller.pickImage,
//                   child: Container(
//                     height: 100,
//                     width: 100,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Center(
//                       child: Icon(Icons.add, size: 50, color: Colors.green),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
// }*/
//                   ///         upar vala code puri tara se shai hai
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart' as mime;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../../directHiring/models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../../../directHiring/views/auth/MapPickerScreen.dart';
// import '../../../directHiring/views/comm/home_location_screens.dart';
// import '../../controller/buding_postTask_controller.dart';
//
// class PostTaskScreen extends StatelessWidget {
//   const PostTaskScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(PostTaskController(), permanent: false); // Mark controller as non-permanent
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     return WillPopScope(
//       onWillPop: () async {
//         controller.resetForm(); // Reset form before navigating back
//         Get.delete<PostTaskController>(); // Delete controller to ensure fresh instance on re-entry
//         return true; // Allow back navigation
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppColors.primaryGreen,
//           centerTitle: true,
//           elevation: 0,
//           toolbarHeight: 20,
//           automaticallyImplyLeading: false,
//         ),
//         body: Obx(
//               () => SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: controller.formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _pageHeader(context, controller),
//                   _buildLabel("Title"),
//                   _buildTextField(controller.titleController, "Enter Title of work"),
//                   _buildLabel("Category"),
//                   DropdownButtonFormField<String>(
//                     decoration: _inputDecoration("Choose category"),
//                     value: controller.selectedCategoryId.value,
//                     items: controller.categories
//                         .map(
//                           (cat) => DropdownMenuItem(
//                         value: cat['id'],
//                         child: Text(cat['name']!),
//                       ),
//                     )
//                         .toList(),
//                     onChanged: (val) {
//                       controller.selectedCategoryId.value = val;
//                       controller.selectedSubCategoryIds.clear();
//                       controller.allSubCategories.clear();
//                       if (val != null) controller.fetchSubCategories(val);
//                     },
//                     validator: (val) => val == null ? "Please select a category" : null,
//                   ),
//                   _buildLabel("Sub Category (Multiple selection)"),
//                   _subcategorySelector(controller),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildLabel("Location"),
//                       InkWell(
//                         onTap: controller.navigateToLocationScreen,
//                         child: Container(
//                           width: width * 0.35,
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryGreen,
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               "Change location",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   TextFormField(
//                     enabled: false,
//                     controller: controller.addressController,
//                     decoration: _inputDecoration(controller.userLocation.value).copyWith(
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.my_location),
//                         onPressed: controller.getCurrentLocation,
//                       ),
//                     ),
//                     validator: (val) => val == null || val.isEmpty || val == 'Select Location'
//                         ? "Please enter a valid address"
//                         : null,
//                   ),
//                   _buildLabel("Google Address"),
//                   _googleLocationField(controller),
//                   _buildLabel("Description"),
//                   _buildTextField(
//                     controller.descriptionController,
//                     "Describe your task",
//                     maxLines: 4,
//                   ),
//                   _buildLabel("Cost"),
//                   _buildTextField(
//                     controller.costController,
//                     "Enter cost in INR",
//                     keyboardType: TextInputType.number,
//                     validator: (val) {
//                       if (val == null || val.isEmpty) {
//                         return "Please enter the cost";
//                       }
//                       if (double.tryParse(val) == null) {
//                         return "Please enter a valid number";
//                       }
//                       return null;
//                     },
//                   ),
//                   _buildLabel("Select Deadline"),
//                   GestureDetector(
//                     onTap: () => controller.selectDate(context),
//                     child: AbsorbPointer(
//                       child: TextFormField(
//                         controller: controller.dateController,
//                         decoration: _inputDecoration("Select Deadline Date", icon: Icons.calendar_today),
//                         validator: (val) => val == null || val.isEmpty ? "Please pick a deadline" : null,
//                       ),
//                     ),
//                   ),
//                   _buildLabel("Upload Task Image"),
//                   _buildImagePicker(controller),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       minimumSize: const Size.fromHeight(50),
//                     ),
//                     onPressed: () {
//                       if (controller.formKey.currentState!.validate()) {
//                         if (controller.selectedCategoryId.value == null) {
//                           controller.showSnackbar("Error", "Please select a category");
//                           return;
//                         }
//                         if (controller.selectedSubCategoryIds.isEmpty) {
//                           controller.showSnackbar("Error", "Please select at least one sub category");
//                           return;
//                         }
//                         controller.submitTask();
//                       }
//                     },
//                     child: const Text("Post Task", style: TextStyle(fontSize: 16)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _pageHeader(BuildContext context, PostTaskController controller) {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () {
//             controller.resetForm(); // Reset form before navigating back
//             Get.delete<PostTaskController>(); // Delete controller to ensure fresh instance
//             Get.back();
//           },
//           child: const Icon(Icons.arrow_back_outlined, color: Colors.black),
//         ),
//         const SizedBox(width: 86),
//         Text(
//           "Post New Task",
//           style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
//
//   Widget _googleLocationField(PostTaskController controller) {
//     return GestureDetector(
//       onTap: () async {
//         final result = await Get.to(() => MapPickerScreen());
//         if (result != null && result is String) {
//           controller.googleAddressController.text = result;
//         }
//       },
//       child: AbsorbPointer(
//         child: TextFormField(
//           controller: controller.googleAddressController,
//           decoration: _inputDecoration("Location", icon: Icons.my_location),
//           validator: (val) => val == null || val.isEmpty ? "Please select a Google address" : null,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLabel(String text) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Text(
//       text,
//       style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
//     ),
//   );
//
//   InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
//     hintText: hint,
//     prefixIcon: icon != null ? Icon(icon) : null,
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//     contentPadding: const EdgeInsets.symmetric(
//       vertical: 14,
//       horizontal: 12,
//     ),
//   );
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String hint, {
//         int maxLines = 1,
//         TextInputType? keyboardType,
//         String? Function(String?)? validator,
//       }) =>
//       TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         decoration: _inputDecoration(hint),
//         validator: validator ?? (val) => val == null || val.isEmpty ? "This field is required" : null,
//       );
//
//   Widget _subcategorySelector(PostTaskController controller) {
//     return GestureDetector(
//       onTap: () {
//         if (controller.selectedCategoryId.value != null) {
//           controller.showSubcategoryDialog();
//         } else {
//           controller.showSnackbar("Error", "Please select category first");
//         }
//       },
//       child: _buildDropdownTile(controller),
//     );
//   }
//
//   Widget _buildDropdownTile(PostTaskController controller) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey.shade400),
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             controller.selectedSubCategoryIds.isEmpty
//                 ? "Choose sub categories"
//                 : controller.allSubCategories
//                 .where((sub) => controller.selectedSubCategoryIds.contains(sub['id']))
//                 .map((sub) => sub['name'])
//                 .join(', '),
//             style: TextStyle(
//               fontSize: 14,
//               color: controller.selectedSubCategoryIds.isEmpty ? Colors.grey : Colors.black,
//             ),
//           ),
//         ),
//         const Icon(Icons.arrow_drop_down),
//       ],
//     ),
//   );
//
//   Widget _buildImagePicker(PostTaskController controller) {
//     return Column(
//       children: [
//         if (controller.selectedImages.isEmpty)
//           Center(
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: controller.pickImage,
//                   child: Container(
//                     height: 120,
//                     width: 270,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.upload, size: 20, color: Colors.green),
//                         Text(
//                           "Upload Work Photo",
//                           style: GoogleFonts.roboto(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 30,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.green),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Text(
//                             "Upload",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Upload (.png, .jpg, .jpeg) File (300px * 300px)",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.roboto(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 8.0,
//             children: [
//               ...controller.selectedImages.map((img) => Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       img,
//                       height: 100,
//                       width: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: IconButton(
//                       icon: const Icon(Icons.close, color: Colors.red),
//                       onPressed: () {
//                         controller.selectedImages.remove(img);
//                       },
//                     ),
//                   ),
//                 ],
//               )),
//               if (controller.selectedImages.length < 5)
//                 GestureDetector(
//                   onTap: controller.pickImage,
//                   child: Container(
//                     height: 100,
//                     width: 100,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Center(
//                       child: Icon(Icons.add, size: 50, color: Colors.green),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart' as mime;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../directHiring/models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../../../directHiring/views/auth/MapPickerScreen.dart';
import '../../../directHiring/views/comm/home_location_screens.dart';
import '../../controller/buding_postTask_controller.dart';

class PostTaskScreen extends StatelessWidget {
  const PostTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostTaskController(), permanent: false); // Mark controller as non-permanent
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        controller.resetForm(); // Reset form before navigating back
        Get.delete<PostTaskController>(); // Delete controller to ensure fresh instance on re-entry
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 20,
          automaticallyImplyLeading: false,
        ),
        body: Obx(
              () => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(context, controller),
                  _buildLabel("Title"),
                  _buildTextField(controller.titleController, "Enter Title of work"),
                  _buildLabel("Category"),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Choose category"),
                    value: controller.selectedCategoryId.value,
                    items: controller.categories
                        .map(
                          (cat) => DropdownMenuItem(
                        value: cat['id'],
                        child: Text(cat['name']!),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      controller.selectedCategoryId.value = val;
                      controller.selectedSubCategoryIds.clear();
                      controller.allSubCategories.clear();
                      if (val != null) controller.fetchSubCategories(val);
                    },
                    validator: (val) => val == null ? "Please select a category" : null,
                  ),
                  _buildLabel("Sub Category (Multiple selection)"),
                  _subcategorySelector(controller),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel("Location"),
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
                  _buildLabel("Google Address"),
                  _googleLocationField(controller),
                  _buildLabel("Description"),
                  _buildTextField(
                    controller.descriptionController,
                    "Describe your task",
                    maxLines: 4,
                  ),
                  _buildLabel("Cost"),
                  _buildTextField(
                    controller.costController,
                    "Enter cost in INR",
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please enter the cost";
                      }
                      if (double.tryParse(val) == null) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                  ),
                  _buildLabel("Select Deadline"),
                  GestureDetector(
                    onTap: () => controller.selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: controller.dateController,
                        decoration: _inputDecoration("Select Deadline Date", icon: Icons.calendar_today),
                        validator: (val) => val == null || val.isEmpty ? "Please pick a deadline" : null,
                      ),
                    ),
                  ),
                  _buildLabel("Upload Task Image"),
                  _buildImagePicker(controller),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      if (controller.formKey.currentState!.validate()) {
                        if (controller.selectedCategoryId.value == null) {
                          controller.showSnackbar("Error", "Please select a category", context: context);
                          return;
                        }
                        if (controller.selectedSubCategoryIds.isEmpty) {
                          controller.showSnackbar("Error", "Please select at least one sub category", context: context);
                          return;
                        }
                        controller.submitTask(context); // Pass context to submitTask
                        Get.back();
                      }
                    },
                    child: const Text("Post Task", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeader(BuildContext context, PostTaskController controller) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            controller.resetForm(); // Reset form before navigating back
            Get.delete<PostTaskController>(); // Delete controller to ensure fresh instance
            Get.back();
          },
          child: const Icon(Icons.arrow_back_outlined, color: Colors.black),
        ),
        const SizedBox(width: 86),
        Text(
          "Post New Task",
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _googleLocationField(PostTaskController controller) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => MapPickerScreen());
        if (result != null && result is String) {
          controller.googleAddressController.text = result;
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller.googleAddressController,
          decoration: _inputDecoration("Location", icon: Icons.my_location),
          validator: (val) => val == null || val.isEmpty ? "Please select a Google address" : null,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 12,
    ),
  );

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(hint),
        validator: validator ?? (val) => val == null || val.isEmpty ? "This field is required" : null,
      );

  Widget _subcategorySelector(PostTaskController controller) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedCategoryId.value != null) {
          controller.showSubcategoryDialog();
        } else {
          controller.showSnackbar("Error", "Please select category first", context: Get.context!);
        }
      },
      child: _buildDropdownTile(controller),
    );
  }

  Widget _buildDropdownTile(PostTaskController controller) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            controller.selectedSubCategoryIds.isEmpty
                ? "Choose sub categories"
                : controller.allSubCategories
                .where((sub) => controller.selectedSubCategoryIds.contains(sub['id']))
                .map((sub) => sub['name'])
                .join(', '),
            style: TextStyle(
              fontSize: 14,
              color: controller.selectedSubCategoryIds.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
        ),
        const Icon(Icons.arrow_drop_down),
      ],
    ),
  );

  Widget _buildImagePicker(PostTaskController controller) {
    return Column(
      children: [
        if (controller.selectedImages.isEmpty)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 120,
                    width: 270,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload, size: 20, color: Colors.green),
                        Text(
                          "Upload Work Photo",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Upload",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Upload (.png, .jpg, .jpeg) File (300px * 300px)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...controller.selectedImages.map((img) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      img,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        controller.selectedImages.remove(img);
                      },
                    ),
                  ),
                ],
              )),
              if (controller.selectedImages.length < 5)
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 50, color: Colors.green),
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}