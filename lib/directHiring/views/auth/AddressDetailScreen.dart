// //
// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../../Widgets/AppColors.dart';
// // import '../../Widgets/Bottombar.dart';
// // import '../../Widgets/CustomButton.dart';
// // import 'LoginScreen.dart';
// // import 'RoleSelectionScreen.dart';
// //
// // class AddressDetailScreen extends StatefulWidget {
// //   final String? initialAddress;
// //   final LatLng? initialLocation;
// //
// //   const AddressDetailScreen({
// //     super.key,
// //     this.initialAddress,
// //     this.initialLocation,
// //   });
// //
// //   @override
// //   State<AddressDetailScreen> createState() => _AddressDetailScreenState();
// // }
// //
// // class _AddressDetailScreenState extends State<AddressDetailScreen> {
// //   late GoogleMapController mapController;
// //   final TextEditingController titleController = TextEditingController();
// //   final TextEditingController addressController = TextEditingController();
// //   final TextEditingController landmarkController = TextEditingController();
// //   final _formKey = GlobalKey<FormState>(); // Form key for validation
// //
// //   LatLng _initialPosition = const LatLng(22.7196, 75.8577);
// //   bool _isLoadingAddress = false;
// //
// //   Timer? _debounceTimer; // Debounce timer
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     titleController.text = '';
// //     addressController.text = widget.initialAddress ?? '';
// //     landmarkController.text = '';
// //     _initialPosition = widget.initialLocation ?? const LatLng(22.7196, 75.8577);
// //     _getCurrentLocation();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _debounceTimer?.cancel();
// //     titleController.dispose();
// //     addressController.dispose();
// //     landmarkController.dispose();
// //     mapController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _showMessage(String message, {Duration duration = const Duration(seconds: 2)}) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           duration: duration,
// //         ),
// //       );
// //     }
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       _showMessage('Please enable location services.');
// //       return;
// //     }
// //
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         _showMessage('Location permission denied.');
// //         return;
// //       }
// //     }
// //
// //     try {
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //       if (mounted) {
// //         setState(() {
// //           _initialPosition = LatLng(position.latitude, position.longitude);
// //         });
// //         mapController.animateCamera(
// //           CameraUpdate.newLatLngZoom(_initialPosition, 15.0),
// //         );
// //         await _getAddressFromLatLng(position.latitude, position.longitude);
// //       }
// //     } catch (e) {
// //       _showMessage('Unable to get location: $e');
// //     }
// //   }
// //
// //   Future<void> _getAddressFromLatLng(double lat, double lng) async {
// //     try {
// //       if (_isLoadingAddress) return;
// //
// //       setState(() {
// //         _isLoadingAddress = true;
// //         addressController.text = "Fetching address...";
// //       });
// //
// //       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
// //       if (mounted) {
// //         setState(() {
// //           _isLoadingAddress = false;
// //           if (placemarks.isNotEmpty) {
// //             final place = placemarks.first;
// //             addressController.text =
// //                 "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
// //                     .replaceAll(', ,', ',')
// //                     .trim();
// //           } else {
// //             addressController.text = 'No address found.';
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _isLoadingAddress = false;
// //           addressController.text = 'Coordinates: $lat, $lng (No address found)';
// //         });
// //         _showMessage('Error fetching address: $e');
// //       }
// //     }
// //   }
// //
// //   void _onMapCreated(GoogleMapController controller) {
// //     mapController = controller;
// //   }
// //
// //   InputDecoration getInputDecoration(String hint) {
// //     return InputDecoration(
// //       hintText: hint,
// //       hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
// //       fillColor: AppColors.white,
// //       filled: true,
// //       contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
// //       enabledBorder: OutlineInputBorder(
// //         borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
// //         borderRadius: BorderRadius.circular(15),
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
// //         borderRadius: BorderRadius.circular(15),
// //       ),
// //       errorBorder: OutlineInputBorder(
// //         borderSide: const BorderSide(color: Colors.red, width: 1.5),
// //         borderRadius: BorderRadius.circular(15),
// //       ),
// //       focusedErrorBorder: OutlineInputBorder(
// //         borderSide: const BorderSide(color: Colors.red, width: 1.5),
// //         borderRadius: BorderRadius.circular(15),
// //       ),
// //     );
// //   }
// //   Widget buildCustomField({
// //     required String hint,
// //     required TextEditingController controllerField,
// //     List<TextInputFormatter>? formatters,
// //     TextInputType keyboardType = TextInputType.text,
// //     bool readOnly = false,
// //     VoidCallback? onTap,
// //     required String? Function(String?) validator,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         SizedBox(
// //           height: 65, // increased height for error space
// //           child: TextFormField(
// //             controller: controllerField,
// //             textAlign: TextAlign.center,
// //             inputFormatters: formatters,
// //             readOnly: readOnly,
// //             onTap: onTap,
// //             decoration: getInputDecoration(hint),
// //             style: const TextStyle(fontSize: 13),
// //             keyboardType: keyboardType,
// //             validator: validator,
// //           ),
// //         ),
// //         const SizedBox(height: 10),
// //       ],
// //     );
// //   }
// //
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.white,
// //       appBar: AppBar(
// //         backgroundColor: AppColors.green,
// //         elevation: 0,
// //         toolbarHeight: 10,
// //         centerTitle: true,
// //       ),
// //       body: SafeArea(
// //         child: Form(
// //           key: _formKey,
// //           child: SingleChildScrollView(
// //             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     GestureDetector(
// //                       onTap: () => Navigator.pop(context),
// //                       child: const Icon(Icons.arrow_back_outlined, size: 22),
// //                     ),
// //                     const SizedBox(width: 60),
// //                     Text(
// //                       'Location',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: AppColors.black,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Center(
// //                   child: Text(
// //                     'Select your location',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //                 Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     Container(
// //                       height: 500,
// //                       width: double.infinity,
// //                       decoration: BoxDecoration(
// //                         border: Border.all(
// //                           color: AppColors.greyBorder,
// //                           width: 1.5,
// //                         ),
// //                         borderRadius: BorderRadius.circular(15),
// //                       ),
// //                       child: GoogleMap(
// //                         gestureRecognizers:
// //                         <Factory<OneSequenceGestureRecognizer>>{
// //                           Factory<OneSequenceGestureRecognizer>(
// //                                 () => EagerGestureRecognizer(),
// //                           ),
// //                         },
// //                         onMapCreated: _onMapCreated,
// //                         initialCameraPosition: CameraPosition(
// //                           target: _initialPosition,
// //                           zoom: 15.0,
// //                         ),
// //                         myLocationEnabled: true,
// //                         zoomGesturesEnabled: true,
// //                         scrollGesturesEnabled: true,
// //                         rotateGesturesEnabled: true,
// //                         tiltGesturesEnabled: true,
// //                         onCameraMove: (position) {
// //                           setState(() {
// //                             _initialPosition = position.target;
// //                           });
// //                         },
// //                         onCameraIdle: () {
// //                           _debounceTimer?.cancel();
// //                           _debounceTimer = Timer(const Duration(seconds: 1), () {
// //                             _getAddressFromLatLng(
// //                               _initialPosition.latitude,
// //                               _initialPosition.longitude,
// //                             );
// //                           });
// //                         },
// //                       ),
// //                     ),
// //                     const Icon(Icons.location_pin, size: 40, color: Colors.red),
// //                     if (_isLoadingAddress)
// //                       const Positioned.fill(
// //                         child: Center(child: CircularProgressIndicator()),
// //                       ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 5),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 18.0),
// //                   child: Column(
// //                     children: [
// //                       buildCustomField(
// //                         controllerField: addressController,
// //                         hint: 'Enter Address',
// //                         formatters: [
// //                           FilteringTextInputFormatter.allow(
// //                             RegExp(r"[a-zA-Z0-9\s,/-]+"),
// //                           ),
// //                           LengthLimitingTextInputFormatter(100),
// //                         ],
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Address cannot be empty.';
// //                           }
// //                           if (value.length < 10) {
// //                             return 'Address must be at least 10 characters long.';
// //                           }
// //                           return null;
// //                         },
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Center(
// //                         child: Text(
// //                           'Address Title',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 5),
// //                       buildCustomField(
// //                         controllerField: titleController,
// //                         hint: 'Enter Title (e.g., Home, Office)',
// //                         formatters: [
// //                           FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]+")),
// //                           LengthLimitingTextInputFormatter(20),
// //                         ],
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Title cannot be empty.';
// //                           }
// //                           if (value.length < 3) {
// //                             return 'Title must be at least 3 characters long.';
// //                           }
// //                           return null;
// //                         },
// //                       ),
// //                       Center(
// //                         child: Text(
// //                           'Landmark',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 5),
// //                       buildCustomField(
// //                         controllerField: landmarkController,
// //                         hint: 'Enter Landmark',
// //                         formatters: [
// //                           FilteringTextInputFormatter.allow(
// //                             RegExp(r"[a-zA-Z0-9\s,/-]+"),
// //                           ),
// //                           LengthLimitingTextInputFormatter(50),
// //                         ],
// //                         validator: (value) {
// //                           if (value != null && value.isNotEmpty && value.length < 3) {
// //                             return 'Landmark must be at least 3 characters long.';
// //                           }
// //                           return null;
// //                         },
// //                       ),
// //                       const SizedBox(height: 15),
// //                       CustomButton(
// //                         label: 'Submit',
// //                         onPressed: () async {
// //                           if (_formKey.currentState!.validate()) {
// //                             try {
// //                               final prefs = await SharedPreferences.getInstance();
// //                               final token = prefs.getString('token');
// //                               final role = prefs.getString('role');
// //                               print("🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}");
// //
// //                               if (token == null || token.isEmpty) {
// //                                 if (mounted) {
// //                                   _showMessage('Token not found. Please log in.');
// //                                   await Future.delayed(const Duration(seconds: 2)); // Wait for message to show
// //                                   if (mounted) {
// //                                     Navigator.pushAndRemoveUntil(
// //                                       context,
// //                                       MaterialPageRoute(builder: (context) => const LoginScreen()),
// //                                           (route) => false,
// //                                     );
// //                                   }
// //                                 }
// //                                 return;
// //                               }
// //
// //                               const String apiUrl = 'https://api.thebharatworks.com/api/user/updateUserProfile';
// //
// //                               final Map<String, dynamic> payload = {
// //                                 'full_address': [
// //                                   {
// //                                     'title': titleController.text,
// //                                     'address': addressController.text,
// //                                     'landmark': landmarkController.text,
// //                                     'latitude': _initialPosition.latitude,
// //                                     'longitude': _initialPosition.longitude,
// //                                   },
// //                                 ],
// //                               };
// //
// //                               final response = await http.post(
// //                                 Uri.parse(apiUrl),
// //                                 headers: {
// //                                   'Content-Type': 'application/json',
// //                                   'Authorization': 'Bearer $token',
// //                                 },
// //                                 body: jsonEncode(payload),
// //                               );
// //
// //                               print("🔍 API Response: ${response.body}");
// //
// //                               if (!mounted) return;
// //
// //                               final responseData = jsonDecode(response.body);
// //
// //                               if (response.statusCode == 200 && responseData['status'] == true) {
// //                                 await prefs.setBool('isProfileComplete', true);
// //                                 if (mounted) {
// //                                   _showMessage('Address saved successfully.');
// //                                   await Future.delayed(const Duration(seconds: 2)); // Wait for message to show
// //                                   if (mounted) {
// //                                     Navigator.pushAndRemoveUntil(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) => (role == 'user' || role == 'service_provider')
// //                                             ? const Bottombar()
// //                                             : const RoleSelectionScreen(),
// //                                       ),
// //                                           (route) => false,
// //                                     );
// //                                   }
// //                                 }
// //                               } else {
// //                                 if (mounted) {
// //                                   _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
// //                                 }
// //                               }
// //                             } catch (e) {
// //                               if (mounted) {
// //                                 _showMessage('Error calling API: $e');
// //                                 print("❌ Error: $e");
// //                               }
// //                             }
// //                           } else {
// //                             _showMessage('Please fill all fields correctly.');
// //                           }
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// /*
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../../Widgets/Bottombar.dart';
// import '../../Widgets/CustomButton.dart';
// import 'LoginScreen.dart';
// import 'RoleSelectionScreen.dart';
//
// class AddressDetailScreen extends StatefulWidget {
//   final name;
//   final refralCode;
//   final role;
//   final String? initialAddress;
//   final LatLng? initialLocation;
//
//   const AddressDetailScreen({
//     super.key,
//     this.initialAddress,
//     this.initialLocation, this.name, this.refralCode, this.role,
//   });
//
//   @override
//   State<AddressDetailScreen> createState() => _AddressDetailScreenState();
// }
// class _AddressDetailScreenState extends State<AddressDetailScreen> {
//   late GoogleMapController mapController;
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController landmarkController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   LatLng _initialPosition = const LatLng(22.7196, 75.8577);
//   bool _isLoadingAddress = false;
//   Timer? _debounceTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     titleController.text = '';
//     addressController.text = widget.initialAddress ?? '';
//     landmarkController.text = '';
//     _initialPosition = widget.initialLocation ?? const LatLng(22.7196, 75.8577);
//     _getCurrentLocation();
//   }
//
//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     titleController.dispose();
//     addressController.dispose();
//     landmarkController.dispose();
//     mapController.dispose();
//     super.dispose();
//   }
//
//   void _showMessage(String message, {Duration duration = const Duration(seconds: 2)}) {
//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: duration,
//       ),
//     );
//   }void _showMessageLoginSuccess(String message, {Duration duration = const Duration(seconds: 2)}) {
//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green.shade700,
//         content: Text(message,style: TextStyle(color: Colors.white),),
//         duration: duration,
//       ),
//     );
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       if (mounted) _showMessage('Please enable location services.');
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         if (mounted) _showMessage('Location permission denied.');
//         return;
//       }
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       if (mounted) {
//         setState(() {
//           _initialPosition = LatLng(position.latitude, position.longitude);
//         });
//         mapController.animateCamera(
//           CameraUpdate.newLatLngZoom(_initialPosition, 15.0),
//         );
//         await _getAddressFromLatLng(position.latitude, position.longitude);
//       }
//     } catch (e) {
//       if (mounted) _showMessage('Unable to get location: $e');
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(double lat, double lng) async {
//     try {
//       if (_isLoadingAddress) return;
//
//       setState(() {
//         _isLoadingAddress = true;
//         addressController.text = "Fetching address...";
//       });
//
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (mounted) {
//         setState(() {
//           _isLoadingAddress = false;
//           if (placemarks.isNotEmpty) {
//             final place = placemarks.first;
//             addressController.text =
//                 "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
//                     .replaceAll(', ,', ',')
//                     .trim();
//           } else {
//             addressController.text = 'No address found.';
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingAddress = false;
//           addressController.text = 'Coordinates: $lat, $lng (No address found)';
//         });
//         _showMessage('Error fetching address: $e');
//       }
//     }
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   InputDecoration getInputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
//       fillColor: AppColors.white,
//       filled: true,
//       contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
//       enabledBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.red, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.red, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//     );
//   }
//
//   Widget buildCustomField({
//     required String hint,
//     required TextEditingController controllerField,
//     List<TextInputFormatter>? formatters,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     required String? Function(String?) validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 65,
//           child: TextFormField(
//             controller: controllerField,
//             textAlign: TextAlign.center,
//             inputFormatters: formatters,
//             readOnly: readOnly,
//             onTap: onTap,
//             decoration: getInputDecoration(hint),
//             style: const TextStyle(fontSize: 13),
//             keyboardType: keyboardType,
//             validator: validator,
//           ),
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("Abhi:- print get details : roel:-->${widget.role} name :---> ${widget.name} referal : ${widget.refralCode}");
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.green,
//         elevation: 0,
//         toolbarHeight: 10,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                */
// /* Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 15.0),
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: const Icon(Icons.arrow_back_outlined, size: 22),
//                       ),
//                     ),
//
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: Text(
//                         'Location',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),*//*
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 15.0),
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: const Icon(Icons.arrow_back_outlined, size: 22),
//                       ),
//                     ),
//                     Text(
//                       'Location',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.black,
//                       ),
//                     ),
//                     SizedBox(width: 37.0), // Adjust width to balance the back icon's padding
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Text(
//                     'Select your location by scroll the pin on map',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 5,),
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       height: 500,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: AppColors.greyBorder,
//                           width: 1.5,
//                         ),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: GoogleMap(
//                         gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                           Factory<OneSequenceGestureRecognizer>(
//                                 () => EagerGestureRecognizer(),
//                           ),
//                         },
//                         onMapCreated: _onMapCreated,
//                         initialCameraPosition: CameraPosition(
//                           target: _initialPosition,
//                           zoom: 15.0,
//                         ),
//                         myLocationEnabled: true,
//                         zoomGesturesEnabled: true,
//                         scrollGesturesEnabled: true,
//                         rotateGesturesEnabled: true,
//                         tiltGesturesEnabled: true,
//                         onCameraMove: (position) {
//                           setState(() {
//                             _initialPosition = position.target;
//                           });
//                         },
//                         onCameraIdle: () {
//                           _debounceTimer?.cancel();
//                           _debounceTimer = Timer(const Duration(seconds: 1), () {
//                             if (mounted) {
//                               _getAddressFromLatLng(
//                                 _initialPosition.latitude,
//                                 _initialPosition.longitude,
//                               );
//                             }
//                           });
//                         },
//                       ),
//                     ),
//                     const Icon(Icons.location_pin, size: 40, color: Colors.red),
//                     if (_isLoadingAddress)
//                       const Positioned.fill(
//                         child: Center(child: CircularProgressIndicator()),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 18.0),
//                   child: Column(
//                     children: [
//                       buildCustomField(
//                         controllerField: addressController,
//                         hint: 'Enter Address',
//                         formatters: [
//                           FilteringTextInputFormatter.allow(
//                             RegExp(r"[a-zA-Z0-9\s,/-]+"),
//                           ),
//                           LengthLimitingTextInputFormatter(100),
//                         ],
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Address cannot be empty.';
//                           }
//                           if (value.length < 10) {
//                             return 'Address must be at least 10 characters long.';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       Center(
//                         child: Text(
//                           'Address Title',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       buildCustomField(
//                         controllerField: titleController,
//                         hint: 'Enter Title (e.g., Home, Office)',
//                         formatters: [
//                           FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]+")),
//                           LengthLimitingTextInputFormatter(20),
//                         ],
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Title cannot be empty.';
//                           }
//                           if (value.length < 3) {
//                             return 'Title must be at least 3 characters long.';
//                           }
//                           return null;
//                         },
//                       ),
//                       Center(
//                         child: Text(
//                           'Landmark',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       buildCustomField(
//                         controllerField: landmarkController,
//                         hint: 'Enter Landmark',
//                         formatters: [
//                           FilteringTextInputFormatter.allow(
//                             RegExp(r"[a-zA-Z0-9\s,/-]+"),
//                           ),
//                           LengthLimitingTextInputFormatter(50),
//                         ],
//                         validator: (value) {
//                           if (value != null && value.isNotEmpty && value.length < 3) {
//                             return 'Landmark must be at least 3 characters long.';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 15),
//                      */
// /* CustomButton(
//                         label: 'Submit',
//                         onPressed: () async {
//                           if (_formKey.currentState!.validate()) {
//                             try {
//                               final prefs = await SharedPreferences.getInstance();
//                               final token = prefs.getString('token');
//                               final role = prefs.getString('role');
//                               print("🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}");
//
//                               if (token == null || token.isEmpty) {
//                                 _showMessage('Token not found. Please log in.');
//                               await Future.delayed(const Duration(seconds: 2));
//                               Navigator.pushAndRemoveUntil(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//                                     (route) => false,
//                               );
//                                 return;
//                               }
//
//                               const String apiUrl = 'https://api.thebharatworks.com/api/user/updateUserProfile';
//
//                               final Map<String, dynamic> payload = {
//                                 'full_address': [
//                                   {
//                                     'title': titleController.text,
//                                     'address': addressController.text,
//                                     'landmark': landmarkController.text,
//                                     'latitude': _initialPosition.latitude,
//                                     'longitude': _initialPosition.longitude,
//                                   },
//                                 ],
//                               };
//
//                               final response = await http.post(
//                                 Uri.parse(apiUrl),
//                                 headers: {
//                                   'Content-Type': 'application/json',
//                                   'Authorization': 'Bearer $token',
//                                 },
//                                 body: jsonEncode(payload),
//                               );
//
//                               print("🔍 API Response: ${response.body}");
//
//                               if (!mounted) return;
//
//                               final responseData = jsonDecode(response.body);
//
//                               if (response.statusCode == 200 && responseData['status'] == true) {
//                                 await prefs.setBool('isProfileComplete', true);
//                                 _showMessage('Address saved successfully.');
//                                 await Future.delayed(const Duration(seconds: 2));
//                                 Navigator.pushAndRemoveUntil(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => (role == 'user' || role == 'service_provider')
//                                         ? const Bottombar()
//                                         : const RoleSelectionScreen(),
//                                   ),
//                                       (route) => false,
//                                 );
//                               } else {_showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
//
//                               }
//                             } catch (e) {_showMessage('Error calling API: $e');
//
//                             }
//                           } else {_showMessage('Please fill all fields correctly.');
//
//                           }
//                         },
//                       ),*//*
//
//                       CustomButton(
//                         label: 'Submit',
//                         onPressed: () async {
//                           if (_formKey.currentState!.validate()) {
//                             try {
//                               final BuildContext localContext = context; // Store context locally
//                               final prefs = await SharedPreferences.getInstance();
//                               final token = prefs.getString('token');
//                               final role = prefs.getString('role');
//                               print("🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}");
//
//                               if (token == null || token.isEmpty) {
//                                 _showMessage('Token not found. Please log in.');
//                                 await Future.delayed(const Duration(seconds: 2));
//                                 Navigator.pushAndRemoveUntil(
//                                   localContext,
//                                   MaterialPageRoute(builder: (context) => const LoginScreen()),
//                                       (route) => false,
//                                 );
//                                 return;
//                               }
//
//                               const String apiUrl = 'https://api.thebharatworks.com/api/user/updateUserProfile';
//
//                               final Map<String, dynamic> payload = {
//
//                                 'full_address': [
//                                   {
//                                     'title': titleController.text,
//                                     'address': addressController.text,
//                                     'landmark': landmarkController.text,
//                                     'latitude': _initialPosition.latitude,
//                                     'longitude': _initialPosition.longitude,
//                                   },
//                                 ],
//                               };
//
//                               final response = await http.post(
//                                 Uri.parse(apiUrl),
//                                 headers: {
//                                   'Content-Type': 'application/json',
//                                   'Authorization': 'Bearer $token',
//                                 },
//                                 body: */
// /*jsonEncode(payload),*//*
//  jsonEncode({
//
//                                     "full_name": widget.name,
//                                     "role": widget.role,
//                                     "full_address":[{
//                                       'title': titleController.text,
//                                       'address': addressController.text,
//                                       'landmark': landmarkController.text,
//                                       'latitude': _initialPosition.latitude,
//                                       'longitude': _initialPosition.longitude,
//                                     },],
//                                     "referral_code": widget.refralCode,
//                                     "_id":"sadfsadfsdaf"
//
//
//                                 })
//                               );
//
//                               print("🔍 API Response: ${response.body}");
//
//                               final responseData = jsonDecode(response.body);
//
//                               if (response.statusCode == 200 && responseData['status'] == true) {
//                                 await prefs.setBool('isProfileComplete', true);
//                                 _showMessage('Signup successfull.');
//                                 await Future.delayed(const Duration(seconds: 2));
//                                 Navigator.pushAndRemoveUntil(
//                                   localContext,
//                                   MaterialPageRoute(
//                                     builder: (context) => (role == 'user' || role == 'service_provider')
//                                         ? const Bottombar()
//                                         : const RoleSelectionScreen(),
//                                   ),
//                                       (route) => false,
//                                 );
//                               } else {
//                                 // _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
//                               }
//                             } catch (e) {
//                               // _showMessage('Error calling API: $e');
//                               print("❌ Error: $e");
//                             }
//                           } else {
//                             _showMessage('Please fill all fields correctly.');
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }*/
//                 /// upar vala currect code hai    ///
//
//
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Added fluttertoast import

import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/Bottombar.dart';
import '../../../Widgets/CustomButton.dart';
import 'LoginScreen.dart';
import 'RoleSelectionScreen.dart';

class AddressDetailScreen extends StatefulWidget {
  final String? name;
  final String? refralCode;
  final String? role;
  final String? initialAddress;
  final LatLng? initialLocation;

  const AddressDetailScreen({
    super.key,
    this.initialAddress,
    this.initialLocation,
    this.name,
    this.refralCode,
    this.role,
  });

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  late GoogleMapController mapController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LatLng _initialPosition = const LatLng(22.7196, 75.8577);
  bool _isLoadingAddress = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    titleController.text = '';
    addressController.text = widget.initialAddress ?? '';
    landmarkController.text = '';
    _initialPosition = widget.initialLocation ?? const LatLng(22.7196, 75.8577);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    titleController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Duration duration = const Duration(seconds: 2)}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG, // Maps to ~2 seconds
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  void _showMessageLoginSuccess(String message, {Duration duration = const Duration(seconds: 2)}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG, // Maps to ~2 seconds
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade700,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Please enable location services.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permission denied.');
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition, 15.0),
      );
      await _getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      _showMessage('Unable to get location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      if (_isLoadingAddress) return;

      setState(() {
        _isLoadingAddress = true;
        addressController.text = "Fetching address...";
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      setState(() {
        _isLoadingAddress = false;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          addressController.text =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
                  .replaceAll(', ,', ',')
                  .trim();
        } else {
          addressController.text = 'No address found.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingAddress = false;
        addressController.text = 'Coordinates: $lat, $lng (No address found)';
      });
      _showMessage('Error fetching address: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
      fillColor: AppColors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget buildCustomField({
    required String hint,
    required TextEditingController controllerField,
    List<TextInputFormatter>? formatters,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 65,
          child: TextFormField(
            controller: controllerField,
            textAlign: TextAlign.center,
            inputFormatters: formatters,
            readOnly: readOnly,
            onTap: onTap,
            decoration: getInputDecoration(hint),
            style: const TextStyle(fontSize: 13),
            keyboardType: keyboardType,
            validator: validator,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:- print get details : role:-->${widget.role} name :---> ${widget.name} referral : ${widget.refralCode}");
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        toolbarHeight: 10,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_outlined, size: 22),
                      ),
                    ),
                    Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 37.0), // Adjust width to balance the back icon's padding
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Select your location by scroll the pin on map',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.greyBorder,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GoogleMap(
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                          ),
                        },
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 15.0,
                        ),
                        myLocationEnabled: true,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        onCameraMove: (position) {
                          setState(() {
                            _initialPosition = position.target;
                          });
                        },
                        onCameraIdle: () {
                          _debounceTimer?.cancel();
                          _debounceTimer = Timer(const Duration(seconds: 1), () {
                            _getAddressFromLatLng(
                              _initialPosition.latitude,
                              _initialPosition.longitude,
                            );
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.location_pin, size: 40, color: Colors.red),
                    if (_isLoadingAddress)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      buildCustomField(
                        controllerField: addressController,
                        hint: 'Enter Address',
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z0-9\s,/-]+"),
                          ),
                          LengthLimitingTextInputFormatter(100),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address cannot be empty.';
                          }
                          if (value.length < 10) {
                            return 'Address must be at least 10 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Address Title',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildCustomField(
                        controllerField: titleController,
                        hint: 'Enter Title (e.g., Home, Office)',
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]+")),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title cannot be empty.';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters long.';
                          }
                          return null;
                        },
                      ),
                      Center(
                        child: Text(
                          'Landmark',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildCustomField(
                        controllerField: landmarkController,
                        hint: 'Enter Landmark',
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z0-9\s,/-]+"),
                          ),
                          LengthLimitingTextInputFormatter(50),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 3) {
                            return 'Landmark must be at least 3 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        label: 'Submit',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final BuildContext localContext = context; // Store context locally for navigation
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              final role = prefs.getString('role');
                              print("🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}");

                              if (token == null || token.isEmpty) {
                                _showMessage('Token not found. Please log in.');
                                await Future.delayed(const Duration(seconds: 2));
                                Navigator.pushAndRemoveUntil(
                                  localContext,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      (route) => false,
                                );
                                return;
                              }

                              const String apiUrl = 'https://api.thebharatworks.com/api/user/updateUserProfile';

                              final Map<String, dynamic> payload = {
                                "full_name": widget.name,
                                "role": widget.role,
                                "full_address": [
                                  {
                                    'title': titleController.text,
                                    'address': addressController.text,
                                    'landmark': landmarkController.text,
                                    'latitude': _initialPosition.latitude,
                                    'longitude': _initialPosition.longitude,
                                  },
                                ],
                                "referral_code": widget.refralCode,
                                "_id": "sadfsadfsdaf",
                              };

                              final response = await http.post(
                                Uri.parse(apiUrl),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode(payload),
                              );

                              print("🔍 API Response: ${response.body}");

                              final responseData = jsonDecode(response.body);

                              if (response.statusCode == 200 && responseData['status'] == true) {
                                await prefs.setBool('isProfileComplete', true);
                                _showMessageLoginSuccess('Signup successful.');
                                await Future.delayed(const Duration(seconds: 2));
                                Navigator.pushAndRemoveUntil(
                                  localContext,
                                  MaterialPageRoute(
                                    builder: (context) => (role == 'user' || role == 'service_provider')
                                        ? const Bottombar()
                                        : const RoleSelectionScreen(),
                                  ),
                                      (route) => false,
                                );
                              } else {
                                _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
                              }
                            } catch (e) {
                              _showMessage('Error calling API: $e');
                              print("❌ Error: $e");
                            }
                          } else {
                            _showMessage('Please fill all fields correctly.');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

     ////        upar vala code sahi hai           ////


