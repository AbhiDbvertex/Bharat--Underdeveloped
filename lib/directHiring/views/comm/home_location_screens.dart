//
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:developer/views/auth/AddressDetailScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LocationSelectionScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>) onLocationSelected;
//
//   const LocationSelectionScreen({Key? key, required this.onLocationSelected})
//       : super(key: key);
//
//   @override
//   State<LocationSelectionScreen> createState() =>
//       _LocationSelectionScreenState();
// }
//
// class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
//   bool isLoading = false;
//   List<dynamic> locationSuggestions = [];
//   List<dynamic> savedAddresses = [];
//   TextEditingController locationController = TextEditingController();
//   final String baseUrl = "https://api.thebharatworks.com";
//   Timer? _debounce;
//   String selectedLocation = "Select Location";
//   String? selectedAddressId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedLocation();
//   }
//
//   @override
//   void dispose() {
//     locationController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _loadSavedLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedLocation = prefs.getString("selected_location");
//
//     if (savedLocation != null && savedLocation.isNotEmpty) {
//       if (mounted) {
//         setState(() {
//           selectedLocation = savedLocation;
//           widget.onLocationSelected({
//             'address': savedLocation,
//             'latitude': prefs.getDouble('user_latitude') ?? 0.0,
//             'longitude': prefs.getDouble('user_longitude') ?? 0.0,
//           });
//         });
//       }
//     }
//
//     String? token = await _getToken();
//     if (token != null && mounted) {
//       try {
//         final response = await http.get(
//           Uri.parse('$baseUrl/api/user/getUserProfileData'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//
//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           if (data['status'] == true && data['data'] != null) {
//             String? location =
//             data['data']['current_location']?.isNotEmpty == true
//                 ? data['data']['current_location']
//                 : data['data']['location']?['address']?.isNotEmpty == true
//                 ? data['data']['location']['address']
//                 : "Select Location";
//             double latitude = data['data']['location']?['latitude'] ?? 0.0;
//             double longitude = data['data']['location']?['longitude'] ?? 0.0;
//             List<dynamic> fullAddress = data['data']['full_address'] ?? [];
//
//             await prefs.setString("selected_location", location!);
//             await prefs.setString("address", location!);
//             await prefs.setDouble("user_latitude", latitude);
//             await prefs.setDouble("user_longitude", longitude);
//
//             if (mounted) {
//               setState(() {
//                 selectedLocation = location;
//                 savedAddresses = fullAddress;
//                 selectedAddressId =
//                 fullAddress.isNotEmpty ? fullAddress[0]['id'] : null;
//                 widget.onLocationSelected({
//                   'address': location,
//                   'latitude': latitude,
//                   'longitude': longitude,
//                 });
//               });
//             }
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Location fetch mein error: $e")),
//           );
//         }
//       }
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Pehle login kar le, bhai!")),
//         );
//       }
//     }
//   }
//
//   Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString("token");
//   }
//
//   Future<void> _saveLocation(
//       String location, {
//         double? latitude,
//         double? longitude,
//       }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("selected_location", location);
//     await prefs.setString("address", location);
//     if (latitude != null) await prefs.setDouble("user_latitude", latitude);
//     if (longitude != null) await prefs.setDouble("user_longitude", longitude);
//   }
//
//   Future<void> fetchLocationSuggestions(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         locationSuggestions = [];
//       });
//       return;
//     }
//
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Pehle login kar le, bhai!")),
//         );
//       }
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final url = Uri.parse('$baseUrl/api/user/suggest-locations?input=$input');
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           setState(() {
//             locationSuggestions = data['suggestions'] ?? [];
//           });
//         }
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<Map<String, dynamic>?> fetchLocationDetails(String placeId) async {
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Login kar le bhai, jaldi!")),
//         );
//       }
//       return null;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final url = Uri.parse(
//       '$baseUrl/api/user/get-location-from-place?place_id=$placeId',
//     );
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           return {
//             'address': data['address'] ?? "Unknown location",
//             'latitude': data['latitude'] ?? 0.0,
//             'longitude': data['longitude'] ?? 0.0,
//           };
//         }
//       }
//       return null;
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> updateLocation(
//       String address,
//       double latitude,
//       double longitude,
//       String addressId,
//       ) async {
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("First Login then update location!")),
//         );
//       }
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final url = Uri.parse('$baseUrl/api/user/updateLocation');
//     try {
//       final response = await http.put(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         /*body: jsonEncode({
//           'latitude': latitude,
//           'longitude': longitude,
//           'address': address,
//           'current_location': address,
//           'full_address': address,
//         }),*/body: jsonEncode({
//         {
//           "latitude": latitude,
//           "longitude": longitude,
//           "address": address
//         }
//
//       }),
//       );
//
//       if (response.statusCode == 200) {
//         print("Abhi:- get update location in home page response : ${response.body}");
//         print("Abhi:- get update location in home page statusCode : ${response.statusCode}");
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           String newLocation = data['location']['address'] ?? address;
//           await _saveLocation(
//             newLocation,
//             latitude: latitude,
//             longitude: longitude,
//           );
//
//           setState(() {
//             selectedLocation = newLocation;
//             selectedAddressId = addressId;
//             locationController.text = '';
//           });
//
//           widget.onLocationSelected({
//             'address': newLocation,
//             'latitude': latitude,
//             'longitude': longitude,
//           });
//
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(data['message'] ?? "Location update ho gaya!"),
//               ),
//             );
//           }
//         }
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> deleteAddress(String addressId) async {
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Bhai, login toh kar pehle!")),
//         );
//       }
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final url = Uri.parse('$baseUrl/api/user/deleteAddress/$addressId');
//     try {
//       final response = await http.delete(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           if (mounted) {
//             setState(() {
//               savedAddresses.removeWhere(
//                     (address) => address['id'] == addressId,
//               );
//               if (selectedAddressId == addressId) {
//                 selectedAddressId =
//                 savedAddresses.isNotEmpty ? savedAddresses[0]['id'] : null;
//                 selectedLocation =
//                 savedAddresses.isNotEmpty
//                     ? savedAddresses[0]['address']
//                     : "Select Location";
//               }
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(data['message'] ?? "Address delete ho gaya!"),
//               ),
//             );
//           }
//         }
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final textScaleFactor = MediaQuery.of(context).textScaleFactor;
//
//     // print("Abhi:- print user location id : ${address['address'],}");
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade800,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: screenHeight * 0.03,
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.04),
//           child: Column(
//             children: [
//               SizedBox(height: screenHeight * 0.02),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Padding(
//                       padding: EdgeInsets.only(left: screenWidth * 0.03),
//                       child: Icon(
//                         Icons.arrow_back_outlined,
//                         size: screenWidth * 0.06,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.2),
//                   Text(
//                     'Select Location',
//                     style: GoogleFonts.roboto(
//                       fontSize: 18 * textScaleFactor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: screenHeight * 0.02),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: locationController,
//                       decoration: InputDecoration(
//                         hintText: "Search Location",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             screenWidth * 0.02,
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: Colors.grey.shade700,
//                           size: screenWidth * 0.06,
//                         ),
//                       ),
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (_debounce?.isActive ?? false) _debounce!.cancel();
//                         _debounce = Timer(
//                           const Duration(milliseconds: 300),
//                               () {
//                             fetchLocationSuggestions(value);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   ElevatedButton(
//                     onPressed: () {
//                       locationController.clear();
//                       fetchLocationSuggestions('');
//                       setState(() {});
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green.shade700,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: screenWidth * 0.04,
//                         vertical: screenHeight * 0.015,
//                       ),
//                     ),
//                     child: Text(
//                       "Cancel",
//                       style: GoogleFonts.roboto(
//                         color: Colors.white,
//                         fontSize: 14 * textScaleFactor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: screenHeight * 0.02),
//               Expanded(
//                 child:
//                 isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child:
//                       selectedLocation != "Select Location"
//                           ? Text(
//                         selectedLocation,
//                         style: GoogleFonts.roboto(
//                           fontSize: 16 * textScaleFactor,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       )
//                           : Text(
//                         "",
//                         style: GoogleFonts.roboto(
//                           fontSize: 14 * textScaleFactor,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//
//                     Center(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) => AddressDetailScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           height: screenHeight * 0.04,
//                           width: screenWidth * 0.15,
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade700,
//                             borderRadius: BorderRadius.circular(
//                               screenWidth * 0.02,
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Add",
//                               style: GoogleFonts.roboto(
//                                 fontSize: 10 * textScaleFactor,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.02),
//                     if (savedAddresses.isNotEmpty) ...[
//                       SizedBox(height: screenHeight * 0.01),
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: savedAddresses.length,
//                           itemBuilder: (context, index) {
//                             final address = savedAddresses[index];
//                             // print("Abhi:- get selected location id ${address['address']?['_id']}");
//                             print("Abhi:- get selected location id ${address['_id']}");
//                             return Container(
//                               margin: EdgeInsets.symmetric(
//                                 vertical: screenHeight * 0.005,
//                               ),
//                               padding: EdgeInsets.all(
//                                 screenWidth * 0.03,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.grey.shade300,
//                                 ),
//                                 borderRadius: BorderRadius.circular(
//                                   screenWidth * 0.02,
//                                 ),
//                                 color: Colors.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.1),
//                                     spreadRadius: 1,
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Radio<String>(
//                                         value: address['_id'],
//                                         groupValue: selectedAddressId,
//                                         onChanged: (value) async {
//                                           setState(() {
//                                             selectedAddressId = value;
//                                             selectedLocation =
//                                             address['address'];
//                                           });
//                                           final latitude =
//                                               address['latitude']
//                                                   ?.toDouble() ??
//                                                   0.0;
//                                           final longitude =
//                                               address['longitude']
//                                                   ?.toDouble() ??
//                                                   0.0;
//                                           await updateLocation(
//                                             address['address'],
//                                             latitude,
//                                             longitude,
//                                             address['_id'],
//                                           );
//                                         },
//                                       ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               address['address'] ??
//                                                   "Unknown",
//                                               style: GoogleFonts.roboto(
//                                                 fontSize:
//                                                 14 *
//                                                     textScaleFactor,
//                                                 fontWeight:
//                                                 FontWeight.bold,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               height:
//                                               screenHeight * 0.005,
//                                             ),
//                                             Text(
//                                               "Title: ${address['title'] ?? 'N/A'}",
//                                               style: GoogleFonts.roboto(
//                                                 fontSize:
//                                                 12 *
//                                                     textScaleFactor,
//                                               ),
//                                             ),
//                                             Text(
//                                               "Landmark: ${address['landmark'] ?? 'N/A'}",
//                                               style: GoogleFonts.roboto(
//                                                 fontSize:
//                                                 12 *
//                                                     textScaleFactor,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: screenHeight * 0.01),
//                                   Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.end,
//                                     children: [
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder:
//                                                   (context) =>
//                                                   AddressDetailScreen(),
//                                             ),
//                                           );
//                                         },
//                                         child: Text(
//                                           "Edit",
//                                           style: GoogleFonts.roboto(
//                                             color:
//                                             Colors.green.shade700,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize:
//                                             12 * textScaleFactor,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: screenWidth * 0.02,
//                                       ),
//                                       TextButton(
//                                         onPressed: () async {
//                                           await deleteAddress(
//                                             address['id'],
//                                           );
//                                         },
//                                         child: Text(
//                                           "Delete",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.red.shade700,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize:
//                                             12 * textScaleFactor,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                     if (locationSuggestions.isNotEmpty) ...[
//                       SizedBox(height: screenHeight * 0.02),
//                       Text(
//                         "Search Suggestions",
//                         style: GoogleFonts.roboto(
//                           fontSize: 16 * textScaleFactor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.01),
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: locationSuggestions.length,
//                           itemBuilder: (context, index) {
//                             final suggestion =
//                             locationSuggestions[index];
//                             return ListTile(
//                               title: Text(
//                                 suggestion['description'] ?? "Unknown",
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 14 * textScaleFactor,
//                                 ),
//                               ),
//                               onTap: () async {
//                                 final locationData =
//                                 await fetchLocationDetails(
//                                   suggestion['place_id'],
//                                 );
//                                 if (locationData != null) {
//                                   await updateLocation(
//                                     locationData['address'],
//                                     locationData['latitude'],
//                                     locationData['longitude'],
//                                     suggestion['place_id'],
//                                   );
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.02),
//               GestureDetector(
//                 onTap: () async {
//                   if (selectedAddressId != null) {
//                     final selectedAddress = savedAddresses.firstWhere(
//                           (address) => address['id'] == selectedAddressId,
//                       orElse: () => null,
//                     );
//                     if (selectedAddress != null) {
//                       final latitude =
//                           selectedAddress['latitude']?.toDouble() ?? 0.0;
//                       final longitude =
//                           selectedAddress['longitude']?.toDouble() ?? 0.0;
//                       await _saveLocation(
//                         selectedAddress['address'],
//                         latitude: latitude,
//                         longitude: longitude,
//                       );
//                       widget.onLocationSelected({
//                         'address': selectedAddress['address'],
//                         'latitude': latitude,
//                         'longitude': longitude,
//                       });
//                       Navigator.pop(context, {
//                         'address': selectedAddress['address'],
//                         'latitude': latitude,
//                         'longitude': longitude,
//                       });
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             "Bhai, pehle koi address toh select kar!",
//                           ),
//                         ),
//                       );
//                     }
//                   } else {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddressDetailScreen(),
//                       ),
//                     );
//                   }
//                 },
//                 child: Container(
//                   height: screenHeight * 0.06,
//                   width: screenWidth * 0.3,
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade700,
//                     borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   ),
//                   child: Center(
//                     child: Text(
//                       "Okk",
//                       style: GoogleFonts.roboto(
//                         fontSize: 14 * textScaleFactor,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.02),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


/*
import 'dart:async';
import 'dart:convert';

import 'package:developer/views/auth/AddressDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationSelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationSelectionScreen({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  bool isLoading = false;
  List<dynamic> locationSuggestions = [];
  List<dynamic> savedAddresses = [];
  TextEditingController locationController = TextEditingController();
  final String baseUrl = "https://api.thebharatworks.com";
  Timer? _debounce;
  String selectedLocation = "Select Location";
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void dispose() {
    locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocation = prefs.getString("selected_location");

    if (savedLocation != null && savedLocation.isNotEmpty) {
      if (mounted) {
        setState(() {
          selectedLocation = savedLocation;
          widget.onLocationSelected({
            'address': savedLocation,
            'latitude': prefs.getDouble('user_latitude') ?? 0.0,
            'longitude': prefs.getDouble('user_longitude') ?? 0.0,
          });
        });
      }
    }

    String? token = await _getToken();
    if (token != null && mounted) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/user/getUserProfileData'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true && data['data'] != null) {
            String? location = data['data']['full_address']?.isNotEmpty == true
                ? data['data']['full_address'][0]['address']
                : data['data']['current_location']?.isNotEmpty == true
                ? data['data']['current_location']
                : data['data']['location']?['address']?.isNotEmpty == true
                ? data['data']['location']['address']
                : "Select Location";
            double latitude = data['data']['full_address']?.isNotEmpty == true
                ? data['data']['full_address'][0]['latitude'] ?? 0.0
                : data['data']['location']?['latitude'] ?? 0.0;
            double longitude = data['data']['full_address']?.isNotEmpty == true
                ? data['data']['full_address'][0]['longitude'] ?? 0.0
                : data['data']['location']?['longitude'] ?? 0.0;
            List<dynamic> fullAddress = data['data']['full_address'] ?? [];

            await prefs.setString("selected_location", location ?? "");
            await prefs.setString("address", location ?? "" );
            await prefs.setDouble("user_latitude", latitude);
            await prefs.setDouble("user_longitude", longitude);

            if (mounted) {
              setState(() {
                selectedLocation = location ?? "";
                savedAddresses = fullAddress;
                selectedAddressId =
                fullAddress.isNotEmpty ? fullAddress[0]['_id'] : null;
                widget.onLocationSelected({
                  'address': location,
                  'latitude': latitude,
                  'longitude': longitude,
                });
              });
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location fetch mein error: $e")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pehle login kar le, bhai!")),
        );
      }
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _saveLocation(
      String location, {
        double? latitude,
        double? longitude,
      }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_location", location);
    await prefs.setString("address", location);
    if (latitude != null) await prefs.setDouble("user_latitude", latitude);
    if (longitude != null) await prefs.setDouble("user_longitude", longitude);
  }

  Future<void> fetchLocationSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        locationSuggestions = [];
      });
      return;
    }

    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pehle login kar le, bhai!")),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/suggest-locations?input=$input');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            locationSuggestions = data['suggestions'] ?? [];
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> fetchLocationDetails(String placeId) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login kar le bhai, jaldi!")),
        );
      }
      return null;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      '$baseUrl/api/user/get-location-from-place?place_id=$placeId',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'address': data['address'] ?? "Unknown location",
            'latitude': data['latitude'] ?? 0.0,
            'longitude': data['longitude'] ?? 0.0,
          };
        }
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateLocation(
      String address,
      double latitude,
      double longitude,
      String addressId,
      ) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("First Login then update location!")),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/updateLocation');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        }),
      );

      print("Abhi:- get update location in home page response: ${response.body}");
      print("Abhi:- get update location in home page statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          String newLocation = data['location']['address'] ?? address;
          await _saveLocation(
            newLocation,
            latitude: latitude,
            longitude: longitude,
          );

          setState(() {
            selectedLocation = newLocation;
            selectedAddressId = addressId;
            locationController.text = '';
          });

          widget.onLocationSelected({
            'address': newLocation,
            'latitude': latitude,
            'longitude': longitude,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Location update ho gaya!"),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("API error: ${data['message'] ?? 'Unknown error'}"),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: ${response.statusCode}"),
            ),
          );
        }
      }
    } catch (e) {
      print("Error in updateLocation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating location: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteAddress(String addressId) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bhai, login toh kar pehle!")),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/deleteAddress/$addressId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (mounted) {
            setState(() {
              savedAddresses.removeWhere(
                    (address) => address['_id'] == addressId,
              );
              if (selectedAddressId == addressId) {
                selectedAddressId =
                savedAddresses.isNotEmpty ? savedAddresses[0]['_id'] : null;
                selectedLocation = savedAddresses.isNotEmpty
                    ? savedAddresses[0]['address']
                    : "Select Location";
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Address delete ho gaya!"),
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: screenHeight * 0.03,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Icon(
                        Icons.arrow_back_outlined,
                        size: screenWidth * 0.06,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.2),
                  Text(
                    'Select Location',
                    style: GoogleFonts.roboto(
                      fontSize: 18 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: "Search Location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade700,
                          size: screenWidth * 0.06,
                        ),
                      ),
                      autofocus: true,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 300),
                              () {
                            fetchLocationSuggestions(value);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      locationController.clear();
                      fetchLocationSuggestions('');
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 14 * textScaleFactor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: selectedLocation != "Select Location"
                          ? Text(
                        selectedLocation,
                        style: GoogleFonts.roboto(
                          fontSize: 16 * textScaleFactor,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                          : Text(
                        "",
                        style: GoogleFonts.roboto(
                          fontSize: 14 * textScaleFactor,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressDetailScreen(),
                            ),
                          ).then((_) => _loadSavedLocation());
                        },
                        child: Container(
                          height: screenHeight * 0.04,
                          width: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.02,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Add",
                              style: GoogleFonts.roboto(
                                fontSize: 10 * textScaleFactor,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    if (savedAddresses.isNotEmpty) ...[
                      SizedBox(height: screenHeight * 0.01),
                      Expanded(
                        child: ListView.builder(
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = savedAddresses[index];
                            print(
                                "Abhi:- get selected location id ${address['_id']}");
                            return GestureDetector(
                              onTap: () {
                                // Container pe tap karne par radio button trigger
                                final latitude =
                                    address['latitude']?.toDouble() ?? 0.0;
                                final longitude =
                                    address['longitude']?.toDouble() ?? 0.0;
                                setState(() {
                                  selectedAddressId = address['_id'];
                                  selectedLocation = address['address'];
                                });
                                updateLocation(
                                  address['address'],
                                  latitude,
                                  longitude,
                                  address['_id'],
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.005,
                                ),
                                padding: EdgeInsets.all(
                                  screenWidth * 0.03,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.02,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: address['_id'],
                                          groupValue: selectedAddressId,
                                          onChanged: (value) async {
                                            setState(() {
                                              selectedAddressId = value;
                                              selectedLocation =
                                              address['address'];
                                            });
                                            final latitude = address['latitude']
                                                ?.toDouble() ??
                                                0.0;
                                            final longitude = address['longitude']
                                                ?.toDouble() ??
                                                0.0;
                                            await updateLocation(
                                              address['address'],
                                              latitude,
                                              longitude,
                                              address['_id'],
                                            );
                                          },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                address['address'] ??
                                                    "Unknown",
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                  14 * textScaleFactor,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                screenHeight * 0.005,
                                              ),
                                              Text(
                                                "Title: ${address['title'] ?? 'N/A'}",
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                  12 * textScaleFactor,
                                                ),
                                              ),
                                              Text(
                                                "Landmark: ${address['landmark'] ?? 'N/A'}",
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                  12 * textScaleFactor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddressDetailScreen(),
                                              ),
                                            ).then((_) => _loadSavedLocation());
                                          },
                                          child: Text(
                                            "Edit",
                                            style: GoogleFonts.roboto(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                              12 * textScaleFactor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.02,
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteAddress(
                                              address['_id'],
                                            );
                                          },
                                          child: Text(
                                            "Delete",
                                            style: GoogleFonts.roboto(
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                              12 * textScaleFactor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (locationSuggestions.isNotEmpty) ...[
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Search Suggestions",
                        style: GoogleFonts.roboto(
                          fontSize: 16 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Expanded(
                        child: ListView.builder(
                          itemCount: locationSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = locationSuggestions[index];
                            return ListTile(
                              title: Text(
                                suggestion['description'] ?? "Unknown",
                                style: GoogleFonts.roboto(
                                  fontSize: 14 * textScaleFactor,
                                ),
                              ),
                              onTap: () async {
                                final locationData =
                                await fetchLocationDetails(
                                  suggestion['place_id'],
                                );
                                if (locationData != null) {
                                  await updateLocation(
                                    locationData['address'],
                                    locationData['latitude'],
                                    locationData['longitude'],
                                    suggestion['place_id'],
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: () async {
                  */
/*if (selectedAddressId != null) {
                    final selectedAddress = savedAddresses.firstWhere(
                          (address) => address['_id'] == selectedAddressId,
                      orElse: () => null,
                    );
                    if (selectedAddress != null) {
                      final latitude =
                          selectedAddress['latitude']?.toDouble() ?? 0.0;
                      final longitude =
                          selectedAddress['longitude']?.toDouble() ?? 0.0;
                      await _saveLocation(
                        selectedAddress['address'],
                        latitude: latitude,
                        longitude: longitude,
                      );
                      widget.onLocationSelected({
                        'address': selectedAddress['address'],
                        'latitude': latitude,
                        'longitude': longitude,
                      });
                      Navigator.pop(context, {
                        'address': selectedAddress['address'],
                        'latitude': latitude,
                        'longitude': longitude,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Bhai, pehle koi address toh select kar!"),
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressDetailScreen(),
                      ),
                    ).then((_) => _loadSavedLocation());
                  }*//*

                  Navigator.pop(context);
                },
                child: Container(
                  height: screenHeight * 0.06,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Center(
                    child: Text(
                      "Okk",
                      style: GoogleFonts.roboto(
                        fontSize: 14 * textScaleFactor,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/AddressDetailScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationSelectionScreen({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  bool isLoading = false;
  List<dynamic> locationSuggestions = [];
  List<dynamic> savedAddresses = [];
  TextEditingController locationController = TextEditingController();
  final String baseUrl = "https://api.thebharatworks.com";
  Timer? _debounce;
  String selectedLocation = "Select Location";
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void dispose() {
    locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocation = prefs.getString("selected_location");
    String? savedAddressId = prefs.getString("selected_address_id");

    if (savedLocation != null && savedLocation.isNotEmpty) {
      if (mounted) {
        setState(() {
          selectedLocation = savedLocation;
          selectedAddressId = savedAddressId;
          widget.onLocationSelected({
            'address': savedLocation,
            'latitude': prefs.getDouble('user_latitude') ?? 0.0,
            'longitude': prefs.getDouble('user_longitude') ?? 0.0,
          });
        });
      }
    }

    String? token = await _getToken();
    if (token != null && mounted) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/user/getUserProfileData'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true && data['data'] != null) {
            String? location = data['data']['full_address']?.isNotEmpty == true
                ? data['data']['full_address'][0]['address']
                : data['data']['current_location']?.isNotEmpty == true
                ? data['data']['current_location']
                : data['data']['location']?['address']?.isNotEmpty == true
                ? data['data']['location']['address']
                : "Select Location";
            double latitude = data['data']['full_address']?.isNotEmpty == true
                ? data['data']['full_address'][0]['latitude'] ?? 0.0
                : data['data']['location']?['latitude'] ?? 0.0;
            double longitude = data['data']['full_address']?.isNotEmpty == true
                ? data['data']['full_address'][0]['longitude'] ?? 0.0
                : data['data']['location']?['longitude'] ?? 0.0;
            List<dynamic> fullAddress = data['data']['full_address'] ?? [];

            await prefs.setString("selected_location", location ?? "");
            await prefs.setString("address", location ?? "");
            await prefs.setDouble("user_latitude", latitude);
            await prefs.setDouble("user_longitude", longitude);

            if (mounted) {
              setState(() {
                savedAddresses = fullAddress;
                // Do not overwrite selectedLocation and selectedAddressId here
                // Keep the saved ones
                if (selectedAddressId == null || !savedAddresses.any((addr) => addr['_id'] == selectedAddressId)) {
                  selectedAddressId = fullAddress.isNotEmpty ? fullAddress[0]['_id'] : null;
                  selectedLocation = fullAddress.isNotEmpty ? fullAddress[0]['address'] : "Select Location";
                }
                widget.onLocationSelected({
                  'address': selectedLocation,
                  'latitude': prefs.getDouble('user_latitude') ?? 0.0,
                  'longitude': prefs.getDouble('user_longitude') ?? 0.0,
                });
              });
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location fetch mein error: $e")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pehle login kar le, bhai!")),
        );
      }
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _saveLocation(
      String location, {
        double? latitude,
        double? longitude,
        String? addressId,
      }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_location", location);
    await prefs.setString("address", location);
    if (latitude != null) await prefs.setDouble("user_latitude", latitude);
    if (longitude != null) await prefs.setDouble("user_longitude", longitude);
    if (addressId != null) await prefs.setString("selected_address_id", addressId);
  }

  Future<void> fetchLocationSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        locationSuggestions = [];
      });
      return;
    }

    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pehle login kar le, bhai!")),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/suggest-locations?input=$input');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            locationSuggestions = data['suggestions'] ?? [];
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> fetchLocationDetails(String placeId) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login!")),
        );
      }
      return null;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      '$baseUrl/api/user/get-location-from-place?place_id=$placeId',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return {
            'address': data['address'] ?? "Unknown location",
            'latitude': data['latitude'] ?? 0.0,
            'longitude': data['longitude'] ?? 0.0,
          };
        }
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateLocation(
      String address,
      double latitude,
      double longitude,
      String addressId,
      ) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("First Login then update location!")),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/updateLocation');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        }),
      );

      print("Abhi:- get update location in home page response: ${response.body}");
      print("Abhi:- get update location in home page statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          String newLocation = data['location']['address'] ?? address;
          await _saveLocation(
            newLocation,
            latitude: latitude,
            longitude: longitude,
            addressId: addressId,
          );

          setState(() {
            selectedLocation = newLocation;
            selectedAddressId = addressId;
            locationController.text = '';
          });

          widget.onLocationSelected({
            'address': newLocation,
            'latitude': latitude,
            'longitude': longitude,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Location update ho gaya!"),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("API error: ${data['message'] ?? 'Unknown error'}"),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: ${response.statusCode}"),
            ),
          );
        }
      }
    } catch (e) {
      print("Error in updateLocation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating location: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteAddress(String addressId) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login!")),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/deleteAddress/$addressId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (mounted) {
            setState(() {
              savedAddresses.removeWhere(
                    (address) => address['id'] == addressId,
              );
              if (selectedAddressId == addressId) {
                selectedAddressId =
                savedAddresses.isNotEmpty ? savedAddresses[0]['id'] : null;
                selectedLocation =
                savedAddresses.isNotEmpty
                    ? savedAddresses[0]['address']
                    : "Select Location";
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Address delete ho gaya!"),
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: screenHeight * 0.03,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Icon(
                        Icons.arrow_back_outlined,
                        size: screenWidth * 0.06,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.2),
                  Text(
                    'Select Location',
                    style: GoogleFonts.roboto(
                      fontSize: 18 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: "Search Location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade700,
                          size: screenWidth * 0.06,
                        ),
                      ),
                      autofocus: true,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 300),
                              () {
                            fetchLocationSuggestions(value);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      locationController.clear();
                      fetchLocationSuggestions('');
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 14 * textScaleFactor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: selectedLocation != "Select Location"
                          ? Text(
                        selectedLocation,
                        style: GoogleFonts.roboto(
                          fontSize: 16 * textScaleFactor,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                          : Text(
                        "",
                        style: GoogleFonts.roboto(
                          fontSize: 14 * textScaleFactor,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressDetailScreen(),
                            ),
                          ).then((_) => _loadSavedLocation());
                        },
                        child: Container(
                          height: screenHeight * 0.04,
                          width: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.02,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Add",
                              style: GoogleFonts.roboto(
                                fontSize: 10 * textScaleFactor,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    if (savedAddresses.isNotEmpty) ...[
                      SizedBox(height: screenHeight * 0.01),
                      Expanded(
                        child: ListView.builder(
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = savedAddresses[index];
                            print(
                                "Abhi:- get selected location id ${address['_id']}");
                            return GestureDetector(
                              onTap: () {
                                // Container pe tap karne par radio button trigger
                                final latitude =
                                    address['latitude']?.toDouble() ?? 0.0;
                                final longitude =
                                    address['longitude']?.toDouble() ?? 0.0;
                                setState(() {
                                  selectedAddressId = address['_id'];
                                  selectedLocation = address['address'];
                                });
                                updateLocation(
                                  address['address'],
                                  latitude,
                                  longitude,
                                  address['_id'],
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.005,
                                ),
                                padding: EdgeInsets.all(
                                  screenWidth * 0.03,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.02,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: address['_id'],
                                          groupValue: selectedAddressId,
                                          onChanged: (value) async {
                                            setState(() {
                                              selectedAddressId = value;
                                              selectedLocation =
                                              address['address'];
                                            });
                                            final latitude = address['latitude']
                                                ?.toDouble() ??
                                                0.0;
                                            final longitude = address['longitude']
                                                ?.toDouble() ??
                                                0.0;
                                            await updateLocation(
                                              address['address'],
                                              latitude,
                                              longitude,
                                              address['_id'],
                                            );
                                          },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                address['address'] ??
                                                    "Unknown",
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                  14 * textScaleFactor,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                screenHeight * 0.005,
                                              ),
                                              Text(
                                                "Title: ${address['title'] ?? 'N/A'}",
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                  12 * textScaleFactor,
                                                ),
                                              ),
                                              Text(
                                                "Landmark: ${address['landmark'] ?? 'N/A'}",
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                  12 * textScaleFactor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddressDetailScreen(),
                                              ),
                                            ).then((_) => _loadSavedLocation());
                                          },
                                          child: Text(
                                            "Edit",
                                            style: GoogleFonts.roboto(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                              12 * textScaleFactor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.02,
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteAddress(
                                              address['_id'],
                                            );
                                          },
                                          child: Text(
                                            "Delete",
                                            style: GoogleFonts.roboto(
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                              12 * textScaleFactor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (locationSuggestions.isNotEmpty) ...[
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Search Suggestions",
                        style: GoogleFonts.roboto(
                          fontSize: 16 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Expanded(
                        child: ListView.builder(
                          itemCount: locationSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = locationSuggestions[index];
                            return ListTile(
                              title: Text(
                                suggestion['description'] ?? "Unknown",
                                style: GoogleFonts.roboto(
                                  fontSize: 14 * textScaleFactor,
                                ),
                              ),
                              onTap: () async {
                                final locationData =
                                await fetchLocationDetails(
                                  suggestion['place_id'],
                                );
                                if (locationData != null) {
                                  await updateLocation(
                                    locationData['address'],
                                    locationData['latitude'],
                                    locationData['longitude'],
                                    suggestion['place_id'],
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: () async {
                 /* if (selectedAddressId != null) {
                    final selectedAddress = savedAddresses.firstWhere(
                          (address) => address['_id'] == selectedAddressId,
                      orElse: () => null,
                    );
                    if (selectedAddress != null) {
                      final latitude =
                          selectedAddress['latitude']?.toDouble() ?? 0.0;
                      final longitude =
                          selectedAddress['longitude']?.toDouble() ?? 0.0;
                      await _saveLocation(
                        selectedAddress['address'],
                        latitude: latitude,
                        longitude: longitude,
                        addressId: selectedAddress['_id'],
                      );
                      widget.onLocationSelected({
                        'address': selectedAddress['address'],
                        'latitude': latitude,
                        'longitude': longitude,
                      });
                      Navigator.pop(context, {
                        'address': selectedAddress['address'],
                        'latitude': latitude,
                        'longitude': longitude,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Bhai, pehle koi address toh select kar!"),
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressDetailScreen(),
                      ),
                    ).then((_) => _loadSavedLocation());
                  }*/
                  Navigator.pop(context);
                },
                child: Container(
                  height: screenHeight * 0.06,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Center(
                    child: Text(
                      "Okk",
                      style: GoogleFonts.roboto(
                        fontSize: 14 * textScaleFactor,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}