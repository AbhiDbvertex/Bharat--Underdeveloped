// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../auth/AddressDetailScreen.dart';
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
//   String? selectedTitle;
//   String? selectedLandmark;
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
//     print("Debug: I am loading the saved location...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedLocation = prefs.getString("selected_location");
//     String? savedAddressId = prefs.getString("selected_address_id");
//     String? savedTitle = prefs.getString("selected_title");
//     String? savedLandmark = prefs.getString("selected_landmark");
//
//     print(
//       "Debug: Loaded savedLocation: $savedLocation, savedAddressId: $savedAddressId, savedTitle: $savedTitle, savedLandmark: $savedLandmark",
//     );
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
//         print("Debug: getUserProfileData response: ${response.body}");
//
//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           if (data['status'] == true && data['data'] != null) {
//             List<dynamic> fullAddress = data['data']['full_address'] ?? [];
//             print("Debug: Raw full_address from server: $fullAddress");
//
//             setState(() {
//               savedAddresses = _removeDuplicateAddresses(fullAddress);
//               print(
//                 "Debug: Loaded fullAddress after deduplication: $savedAddresses",
//               );
//
//               if (savedAddresses.isNotEmpty) {
//                 if (savedAddressId == null ||
//                     !savedAddresses.any(
//                           (addr) => addr['_id'] == savedAddressId,
//                     )) {
//                   savedAddressId = savedAddresses[0]['_id'];
//                   savedLocation =
//                       savedAddresses[0]['address'] ?? "Select Location";
//                   savedTitle = savedAddresses[0]['title']?.toString() ?? 'N/A';
//                   savedLandmark =
//                       savedAddresses[0]['landmark']?.toString() ?? 'N/A';
//                 }
//
//                 selectedAddressId = savedAddressId;
//                 selectedLocation = savedLocation ?? "Select Location";
//                 selectedTitle = savedTitle ?? 'N/A';
//                 selectedLandmark = savedLandmark ?? 'N/A';
//
//                 // Removed onLocationSelected call to prevent API trigger on init
//                 print("📍 Location in UI: $selectedLocation");
//               } else {
//                 selectedAddressId = null;
//                 selectedLocation = "Select Location";
//                 selectedTitle = 'N/A';
//                 selectedLandmark = 'N/A';
//               }
//             });
//           } else {
//             print("Debug: getUserProfileData failed: ${data['message']}");
//           }
//         } else {
//           print(
//             "Debug: getUserProfileData server error: ${response.statusCode}",
//           );
//         }
//       } catch (e) {
//         print("Error in _loadSavedLocation: $e");
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error fetching location: $e")),
//           );
//         }
//       }
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please login first!")));
//       }
//     }
//   }
//
//   List<dynamic> _mergeLocalChanges(List<dynamic> serverAddresses) {
//     print("Debug: Merging local changes...");
//     final mergedAddresses = List<dynamic>.from(serverAddresses);
//     for (var localAddr in savedAddresses) {
//       final index = mergedAddresses.indexWhere(
//             (addr) => addr['_id'] == localAddr['_id'],
//       );
//       if (index != -1) {
//         mergedAddresses[index] = {
//           '_id': localAddr['_id'],
//           'address':
//           localAddr['address'] ??
//               mergedAddresses[index]['address'] ??
//               'Unknown',
//           'latitude':
//           localAddr['latitude'] ??
//               mergedAddresses[index]['latitude'] ??
//               0.0,
//           'longitude':
//           localAddr['longitude'] ??
//               mergedAddresses[index]['longitude'] ??
//               0.0,
//           'title':
//           localAddr['title'] ?? mergedAddresses[index]['title'] ?? 'N/A',
//           'landmark':
//           localAddr['landmark'] ??
//               mergedAddresses[index]['landmark'] ??
//               'N/A',
//         };
//         print(
//           "Debug: Merged address ID: ${mergedAddresses[index]['_id']}, address: ${mergedAddresses[index]['address']}",
//         );
//       } else if (!mergedAddresses.any(
//             (addr) => addr['_id'] == localAddr['_id'],
//       )) {
//         mergedAddresses.add(localAddr);
//         print(
//           "Debug: Added new local address ID: ${localAddr['_id']}, address: ${localAddr['address']}",
//         );
//       }
//     }
//     return _removeDuplicateAddresses(mergedAddresses);
//   }
//
//   List<dynamic> _removeDuplicateAddresses(List<dynamic> addresses) {
//     print("Debug: Removing duplicate addresses...");
//     final seenIds = <String>{};
//     final uniqueAddresses = <dynamic>[];
//
//     for (var address in addresses) {
//       final id = address['_id']?.toString() ?? '';
//       if (id.isNotEmpty && !seenIds.contains(id)) {
//         seenIds.add(id);
//         uniqueAddresses.add(address);
//       } else {
//         print(
//           "Debug: Removed duplicate address with ID: $id, address: ${address['address']}",
//         );
//       }
//     }
//     return uniqueAddresses;
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
//         String? addressId,
//         String? title,
//         String? landmark,
//       }) async {
//     print("Debug: Location save : $location, ID: $addressId");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("selected_location", location);
//     await prefs.setString("address", location);
//     if (latitude != null) await prefs.setDouble("user_latitude", latitude);
//     if (longitude != null) await prefs.setDouble("user_longitude", longitude);
//     if (addressId != null)
//       await prefs.setString("selected_address_id", addressId);
//     if (title != null) await prefs.setString("selected_title", title);
//     if (landmark != null) await prefs.setString("selected_landmark", landmark);
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
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please login first!")));
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
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please login first!")));
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
//       print("Debug: fetchLocationDetails response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           final address = data['address']?.toString();
//           final latitude = data['latitude']?.toDouble();
//           final longitude = data['longitude']?.toDouble();
//           final title = data['title']?.toString() ?? 'N/A';
//           final landmark = data['landmark']?.toString() ?? 'N/A';
//
//           if (address == null ||
//               address.isEmpty ||
//               latitude == null ||
//               longitude == null) {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text("Invalid location data received!"),
//                 ),
//               );
//             }
//             return null;
//           }
//
//           return {
//             'address': address,
//             'latitude': latitude,
//             'longitude': longitude,
//             'title': title,
//             'landmark': landmark,
//           };
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   "API error: ${data['message'] ?? 'Unknown error'}",
//                 ),
//               ),
//             );
//           }
//           return null;
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Server error: ${response.statusCode}")),
//           );
//         }
//         return null;
//       }
//     } catch (e) {
//       print("Error in fetchLocationDetails: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error fetching location details: $e")),
//         );
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
//       String title,
//       String landmark,
//       ) async {
//     if (address.isEmpty || latitude == 0.0 || longitude == 0.0) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid address or coordinates!")),
//         );
//       }
//       return;
//     }
//
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please login first!")));
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
//       print("Debug: Updating location with address: $address, ID: $addressId");
//       final response = await http.put(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           '_id': addressId,
//           'latitude': latitude,
//           'longitude': longitude,
//           'address': address,
//           'title': title,
//           'landmark': landmark,
//         }),
//       );
//
//       print("Debug: updateLocation response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           String newAddressId = data['location']['_id'] ?? addressId;
//           setState(() {
//             savedAddresses.removeWhere((addr) => addr['_id'] == addressId);
//             savedAddresses.add({
//               '_id': newAddressId,
//               'address': address,
//               'latitude': latitude,
//               'longitude': longitude,
//               'title': title,
//               'landmark': landmark,
//             });
//             selectedLocation = address;
//             selectedAddressId = newAddressId;
//             selectedTitle = title;
//             selectedLandmark = landmark;
//             savedAddresses = _removeDuplicateAddresses(savedAddresses);
//             print(
//               "Debug: Updated address ID: $newAddressId, address: $address",
//             );
//             print(
//               "Debug: Deduplicated savedAddresses after update: $savedAddresses",
//             );
//             // Removed onLocationSelected call to prevent API trigger here
//             print("📍 Location in UI: $address, ID: $newAddressId");
//           });
//
//           await _saveLocation(
//             address,
//             latitude: latitude,
//             longitude: longitude,
//             addressId: newAddressId,
//             title: title,
//             landmark: landmark,
//           );
//
//           await _loadSavedLocation();
//
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   data['message'] ?? "Location updated successfully!",
//                 ),
//               ),
//             );
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   "API error: ${data['message'] ?? 'Unknown error'}",
//                 ),
//               ),
//             );
//           }
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Server error: ${response.statusCode}")),
//           );
//         }
//       }
//     } catch (e) {
//       print("Error in updateLocation: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Error updating location: $e")));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {isLoading = false;});
//       }
//     }
//   }
//   Future<void> deleteAddress(String addressId) async {
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please login first!")));
//       }
//       return;
//     }
//     bool? confirmDelete = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             "Confirm Delete",
//             style: GoogleFonts.roboto(
//               fontSize: 18 * MediaQuery.of(context).textScaleFactor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             "Are you sure you want to delete this address?",
//             style: GoogleFonts.roboto(
//               fontSize: 14 * MediaQuery.of(context).textScaleFactor,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text(
//                 "Cancel",
//                 style: GoogleFonts.roboto(
//                   color: Colors.grey,
//                   fontSize: 14 * MediaQuery.of(context).textScaleFactor,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text(
//                 "Delete",
//                 style: GoogleFonts.roboto(
//                   color: Colors.red.shade700,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14 * MediaQuery.of(context).textScaleFactor,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//     if (confirmDelete != true) return;
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
//                     (address) => address['_id'] == addressId,
//               );
//               if (selectedAddressId == addressId) {
//                 selectedAddressId = savedAddresses.isNotEmpty ? savedAddresses[0]['_id'] : null;
//                 selectedLocation = savedAddresses.isNotEmpty ? savedAddresses[0]['address'] : "Select Location";
//                 selectedTitle = savedAddresses.isNotEmpty ? savedAddresses[0]['title']?.toString() ?? 'N/A' : 'N/A';
//                 selectedLandmark = savedAddresses.isNotEmpty ? savedAddresses[0]['landmark']?.toString() ?? 'N/A' : 'N/A';
//                 // Removed onLocationSelected call to prevent API trigger here
//                 print("📍 Location in UI: $selectedLocation");
//               }
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   data['message'] ?? "Address deleted successfully!",
//                 ),
//               ),
//             );
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   "API error: ${data['message'] ?? 'Unknown error'}",
//                 ),
//               ),
//             );
//           }
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Server error: ${response.statusCode}")),
//           );
//         }
//       }
//     } catch (e) {
//       print("Error in deleteAddress: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error deleting address: $e")));
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
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade800,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: screenHeight * 0.03,
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(screenWidth * 0.04),
//               child: Column(
//                 children: [
//                   SizedBox(height: screenHeight * 0.02),
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Padding(
//                           padding: EdgeInsets.only(left: screenWidth * 0.03),
//                           child: Icon(
//                             Icons.arrow_back_outlined,
//                             size: screenWidth * 0.06,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.2),
//                       Expanded(
//                         child: Text(
//                           'Select Location',
//                           style: GoogleFonts.roboto(
//                             fontSize: 18 * textScaleFactor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: GestureDetector(
//                       onTap: () {
//                         print(
//                           "Debug: Add button pressed, opening AddressDetailScreen",
//                         );
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => AddressDetailScreen(),
//                           ),
//                         ).then((result) {
//                           print("Debug: Returned from AddressDetailScreen (Add), result: $result",);
//                           if (result != null && !result['isEdit']) {
//                             setState(() {
//                               selectedLocation = result['address'] ?? "Select Location";
//                               selectedAddressId = result['addressId'];
//                               selectedTitle = result['title']?.toString() ?? 'N/A';
//                               selectedLandmark = result['landmark']?.toString() ?? 'N/A';
//                               if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId,
//                               )) {
//                                 savedAddresses.add({
//                                   '_id': selectedAddressId,
//                                   'address': selectedLocation,
//                                   'latitude': result['latitude']?.toDouble() ?? 0.0,
//                                   'longitude': result['longitude']?.toDouble() ?? 0.0,
//                                   'title': selectedTitle,
//                                   'landmark': selectedLandmark,
//                                 });
//                                 print(
//                                   "Debug: New Address Add: $selectedLocation, ID: $selectedAddressId",
//                                 );
//                               } else {
//                                 print(
//                                   "Debug: Address already exists, skipping add: $selectedAddressId",
//                                 );
//                               }
//                               savedAddresses = _removeDuplicateAddresses(
//                                 savedAddresses,
//                               );
//                               print(
//                                 "Debug: Deduplicated savedAddresses after add: $savedAddresses",
//                               );
//                               // Removed onLocationSelected and _saveLocation to prevent API trigger here
//                             });
//                             _loadSavedLocation(); // Keep this for server sync
//                           }
//                         });
//                       },
//                       child: Container(
//                         height: screenHeight * 0.04,
//                         width: screenWidth * 0.15,
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade700,
//                           borderRadius: BorderRadius.circular(
//                             screenWidth * 0.02,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Add",
//                             style: GoogleFonts.roboto(
//                               fontSize: 10 * textScaleFactor,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           "By choosing this address you can find results accordingly",
//                           style: GoogleFonts.roboto(
//                             color: Colors.grey,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.00),
//                   Expanded(
//                     child:
//                     isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (savedAddresses.isNotEmpty) ...[
//                           SizedBox(height: screenHeight * 0.01),
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: savedAddresses.length,
//                               itemBuilder: (context, index) {
//                                 final address = savedAddresses[index];
//                                 print(
//                                   "Debug: Rendering address ID: ${address['_id']}, address: ${address['address']}, title: ${address['title']}, landmark: ${address['landmark']}",
//                                 );
//                                 return GestureDetector(
//                                   onTap: () {
//                                     final latitude =
//                                     address['latitude']?.toDouble();
//                                     final longitude =
//                                     address['longitude']?.toDouble();
//                                     final addressText =
//                                     address['address']?.toString();
//                                     final title = address['title']?.toString() ?? 'N/A';
//                                     final landmark = address['landmark']?.toString() ?? 'N/A';
//
//                                     if (addressText == null ||
//                                         addressText.isEmpty) {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                             "Invalid address!",
//                                           ),
//                                         ),
//                                       );
//                                       return;
//                                     }
//                                     if (latitude == null ||
//                                         longitude == null ||
//                                         latitude == 0.0 ||
//                                         longitude == 0.0) {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                             "Invalid latitude or longitude for this address!",
//                                           ),
//                                         ),
//                                       );
//                                       return;
//                                     }
//
//                                     setState(() {
//                                       selectedAddressId =
//                                       address['_id'];
//                                       selectedLocation = addressText;
//                                       selectedTitle = title;
//                                       selectedLandmark = landmark;
//                                       // Removed onLocationSelected to prevent API trigger here
//                                       print(
//                                         "📍 Location in UI: $addressText",
//                                       );
//                                     });
//                                   },
//                                   child: Container(
//                                     margin: EdgeInsets.symmetric(
//                                       vertical: screenHeight * 0.005,
//                                     ),
//                                     padding: EdgeInsets.all(
//                                       screenWidth * 0.03,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors.grey.shade300,
//                                       ),
//                                       borderRadius:
//                                       BorderRadius.circular(
//                                         screenWidth * 0.02,
//                                       ),
//                                       color: Colors.white,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.grey.withOpacity(0.1),
//                                           spreadRadius: 1,
//                                           blurRadius: 4,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text("Abhi check the text"),
//                                         Row(
//                                           children: [
//                                             Radio<String>(
//                                               value: address['_id'],
//                                               groupValue:
//                                               selectedAddressId,
//                                               onChanged: (value) {
//                                                 final latitude =
//                                                 address['latitude']?.toDouble();
//                                                 final longitude =
//                                                 address['longitude']?.toDouble();
//                                                 final addressText =
//                                                 address['address']?.toString();
//                                                 final title = address['title']?.toString() ?? 'N/A';
//                                                 final landmark = address['landmark']?.toString() ?? 'N/A';
//                                                 if (addressText == null || addressText.isEmpty) {
//                                                   ScaffoldMessenger.of(context,).showSnackBar(
//                                                     const SnackBar(content: Text("Invalid address!",),
//                                                     ),
//                                                   );
//                                                   return;
//                                                 }
//                                                 if (latitude == null ||
//                                                     longitude == null ||
//                                                     latitude == 0.0 ||
//                                                     longitude == 0.0) {
//                                                   ScaffoldMessenger.of(
//                                                     context,
//                                                   ).showSnackBar(
//                                                     const SnackBar(
//                                                       content: Text("Invalid latitude or longitude for this address!",),
//                                                     ),
//                                                   );
//                                                   return;
//                                                 }
//
//                                                 setState(() {
//                                                   selectedAddressId = value;
//                                                   selectedLocation = addressText;
//                                                   selectedTitle = title;
//                                                   selectedLandmark = landmark;
//                                                   // Removed onLocationSelected to prevent API trigger here
//                                                   print("📍 Location in UI: $addressText",);
//                                                 });
//                                               },
//                                             ),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(address['address'] ?? "Unknown",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: 14 * textScaleFactor,
//                                                       fontWeight: FontWeight.bold,),
//                                                     overflow: TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                   ),
//                                                   SizedBox(
//                                                     height: screenHeight * 0.005,
//                                                   ),
//                                                   Text(
//                                                     "Title: ${address['title'] ?? 'N/A'}",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: 12 * textScaleFactor,
//                                                     ),
//                                                     overflow:
//                                                     TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                   ),
//                                                   Text(
//                                                     "Landmark: ${address['landmark'] ?? 'N/A'}",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: 12 * textScaleFactor,
//                                                     ),
//                                                     overflow: TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: screenHeight * 0.01,
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.end,
//                                           children: [
//                                             TextButton(
//                                               onPressed: () {
//                                                 print(
//                                                   "Debug: Edit button pressed for address ID: ${address['_id']}",
//                                                 );
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context,) => AddressDetailScreen(
//                                                       editlocationId:
//                                                       address['_id'] ??
//                                                           "no id",
//                                                       initialAddress:
//                                                       address['address']?.toString() ?? "",
//                                                       initialLocation: LatLng(address['latitude']?.toDouble() ?? 0.0,
//                                                         address['longitude']?.toDouble() ?? 0.0,
//                                                       ),
//                                                       initialTitle:
//                                                       address['title']?.toString() ?? "",
//                                                       initialLandmark: address['landmark']?.toString() ?? "",
//                                                     ),
//                                                   ),
//                                                 ).then((result) {
//                                                   print(
//                                                     "Debug: Returned from AddressDetailScreen (Edit), result: $result",
//                                                   );
//                                                   if (result != null &&
//                                                       result['isEdit']) {
//                                                     setState(() {
//                                                       String
//                                                       oldAddressId =
//                                                       address['_id'];
//                                                       selectedLocation = result['address'] ?? "Select Location";
//                                                       selectedAddressId = result['addressId'] ?? oldAddressId;
//                                                       selectedTitle = result['title']?.toString() ?? 'N/A';selectedLandmark =
//                                                           result['landmark']?.toString() ?? 'N/A';
//
//                                                       savedAddresses.removeWhere(
//                                                             (addr) => addr['_id'] == oldAddressId,
//                                                       );
//
//                                                       int
//                                                       index = savedAddresses.indexWhere((addr) =>
//                                                         addr['_id'] == selectedAddressId,
//                                                       );
//                                                       if (index == -1) {
//                                                         savedAddresses.add({'_id':
//                                                           selectedAddressId, 'address': selectedLocation, 'latitude':
//                                                           result['latitude']?.toDouble() ?? 0.0,
//                                                           'longitude': result['longitude']?.toDouble() ?? 0.0,
//                                                           'title': selectedTitle,
//                                                           'landmark': selectedLandmark,
//                                                         });
//                                                         print(
//                                                           "Debug: New address add  ID: $selectedAddressId, address: $selectedLocation",
//                                                         );
//                                                       } else {
//                                                         savedAddresses[index] = {'_id':
//                                                           selectedAddressId, 'address':
//                                                           selectedLocation, 'latitude':
//                                                           result['latitude']?.toDouble() ?? 0.0,
//                                                           'longitude':
//                                                           result['longitude']?.toDouble() ?? 0.0,
//                                                           'title': selectedTitle, 'landmark': selectedLandmark,
//                                                         };
//                                                         print(
//                                                           "Debug: Existing address update  ID: $selectedAddressId, address: $selectedLocation",
//                                                         );
//                                                       }
//
//                                                       savedAddresses = _removeDuplicateAddresses(
//                                                         savedAddresses,
//                                                           );
//                                                       print(
//                                                         "Debug: Deduplicated savedAddresses after edit: $savedAddresses",
//                                                       );
//
//                                                       // Removed onLocationSelected to prevent API trigger here
//                                                     });
//
//                                                     _saveLocation(
//                                                       selectedLocation,
//                                                       latitude: result['latitude']?.toDouble(),
//                                                       longitude: result['longitude']?.toDouble(),
//                                                       addressId: selectedAddressId,
//                                                       title: selectedTitle,
//                                                       landmark: selectedLandmark,
//                                                     );
//
//                                                     _loadSavedLocation();
//                                                   }
//                                                 });
//                                               },
//                                               child: Text(
//                                                 "Edit",
//                                                 style: GoogleFonts.roboto(
//                                                   color:
//                                                   Colors.green.shade700,
//                                                   fontWeight: FontWeight.bold, fontSize: 12 * textScaleFactor,
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: screenWidth * 0.02,
//                                             ),
//                                             TextButton(
//                                               onPressed: () async {
//                                                 print(
//                                                   "Debug: Delete button  pressed for address ID: ${address['_id']}",
//                                                 );
//                                                 await deleteAddress(address['_id'],);
//                                               },
//                                               child: Text(
//                                                 "Delete",
//                                                 style: GoogleFonts.roboto(color:
//                                                   Colors.red.shade700,
//                                                   fontWeight:
//                                                   FontWeight.bold,
//                                                   fontSize:
//                                                   12 * textScaleFactor,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                         if (locationSuggestions.isNotEmpty) ...[
//                           SizedBox(height: screenHeight * 0.02),
//                           Text(
//                             "Search Suggestions",
//                             style: GoogleFonts.roboto(
//                               fontSize: 16 * textScaleFactor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: screenHeight * 0.01),
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: locationSuggestions.length,
//                               itemBuilder: (context, index) {
//                                 final suggestion =
//                                 locationSuggestions[index];
//                                 return ListTile(
//                                   title: Text(
//                                     suggestion['description'] ??
//                                         "Unknown",
//                                     style: GoogleFonts.roboto(
//                                       fontSize: 14 * textScaleFactor,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                   onTap: () async {
//                                     final locationData =
//                                     await fetchLocationDetails(
//                                       suggestion['place_id'],
//                                     );
//                                     if (locationData != null) {
//                                       setState(() {
//                                         selectedLocation =
//                                         locationData['address'];
//                                         selectedAddressId =
//                                         suggestion['place_id'];
//                                         selectedTitle =
//                                             locationData['title']?.toString() ?? 'N/A';
//                                         selectedLandmark = locationData['landmark']?.toString() ?? 'N/A';
//                                         if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId,
//                                         )) {
//                                           savedAddresses.add({'_id': selectedAddressId,
//                                             'address': selectedLocation,
//                                             'latitude': locationData['latitude']?.toDouble() ?? 0.0,
//                                             'longitude': locationData['longitude']?.toDouble() ?? 0.0,
//                                             'title': selectedTitle,
//                                             'landmark': selectedLandmark,
//                                           });
//                                           print(
//                                             "Debug: Suggestion se naya address add kiya: $selectedLocation, ID: $selectedAddressId",
//                                           );
//                                         }
//                                         savedAddresses = _removeDuplicateAddresses(savedAddresses,
//                                         );
//                                         print("Debug: Deduplicated savedAddresses after suggestion add: $savedAddresses",);
//                                         // Removed onLocationSelected, _saveLocation, _loadSavedLocation to prevent API trigger here
//                                         print(
//                                           "📍 Location in UI: $selectedLocation",
//                                         );
//                                       });
//                                     } else {
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(context,).showSnackBar(
//                                           const SnackBar(
//                                             content: Text("Failed to fetch location details!",),
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//
//                   // GestureDetector(
//                   //   onTap: () async {
//                   //     print("Debug: Submit button pressed");
//                   //     if (selectedAddressId == null) {
//                   //       ScaffoldMessenger.of(context).showSnackBar(
//                   //         const SnackBar(
//                   //           content: Text("Please select a location!"),
//                   //         ),
//                   //       );
//                   //       return;
//                   //     }
//                   //
//                   //     final selectedAddress = savedAddresses.firstWhere(
//                   //       (addr) => addr['_id'] == selectedAddressId,
//                   //       orElse: () => null,
//                   //     );
//                   //
//                   //     if (selectedAddress == null) {
//                   //       ScaffoldMessenger.of(context).showSnackBar(
//                   //         const SnackBar(
//                   //           content: Text("Selected address not found!"),
//                   //         ),
//                   //       );
//                   //       return;
//                   //     }
//                   //
//                   //     final latitude = selectedAddress['latitude']?.toDouble();
//                   //     final longitude =
//                   //         selectedAddress['longitude']?.toDouble();
//                   //     final addressText =
//                   //         selectedAddress['address']?.toString();
//                   //     final title =
//                   //         selectedAddress['title']?.toString() ?? 'N/A';
//                   //     final landmark =
//                   //         selectedAddress['landmark']?.toString() ?? 'N/A';
//                   //
//                   //     if (addressText == null ||
//                   //         addressText.isEmpty ||
//                   //         latitude == null ||
//                   //         longitude == null ||
//                   //         latitude == 0.0 ||
//                   //         longitude == 0.0) {
//                   //       ScaffoldMessenger.of(context).showSnackBar(
//                   //         const SnackBar(
//                   //           content: Text("Invalid selected address data!"),
//                   //         ),
//                   //       );
//                   //       return;
//                   //     }
//                   //
//                   //     print(
//                   //       "Debug: Submitting address: $addressText, ID: $selectedAddressId",
//                   //     );
//                   //
//                   //     // Call onLocationSelected here to trigger API
//                   //     widget.onLocationSelected({
//                   //       'address': addressText,
//                   //       'latitude': latitude,
//                   //       'longitude': longitude,
//                   //       'title': title,
//                   //       'landmark': landmark,
//                   //     });
//                   //
//                   //     // Save location to SharedPreferences
//                   //     await _saveLocation(
//                   //       addressText,
//                   //       latitude: latitude,
//                   //       longitude: longitude,
//                   //       addressId: selectedAddressId,
//                   //       title: title,
//                   //       landmark: landmark,
//                   //     );
//                   //
//                   //     // Removed Navigator.pop to prevent returning data
//                   //     ScaffoldMessenger.of(context).showSnackBar(
//                   //       const SnackBar(
//                   //         content: Text("Location submitted successfully!"),
//                   //       ),
//                   //     );
//                   //   },
//                   //   child: Container(
//                   //     height: screenHeight * 0.06,
//                   //     width: screenWidth * 0.3,
//                   //     decoration: BoxDecoration(
//                   //       color: Colors.green.shade700,
//                   //       borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   //     ),
//                   //     child: Center(
//                   //       child: Text(
//                   //         "Submit",
//                   //         style: GoogleFonts.roboto(
//                   //           fontSize: 14 * textScaleFactor,
//                   //           color: Colors.white,
//                   //           fontWeight: FontWeight.bold,
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                   GestureDetector(
//                     onTap: () async {
//                       print("Debug: Submit button pressed");
//                       if (selectedAddressId == null) {
//                         Fluttertoast.showToast(
//                           msg: "Please select a location!",
//                           toastLength: Toast.LENGTH_SHORT,
//                           gravity: ToastGravity.BOTTOM,
//                           backgroundColor: Colors.red,
//                           textColor: Colors.white,
//                           fontSize: 14.0,
//                         );
//                         return;
//                       }
//
//                       final selectedAddress = savedAddresses.firstWhere(
//                             (addr) => addr['_id'] == selectedAddressId, orElse: () => null,);
//
//                       if (selectedAddress == null) {
//                         Fluttertoast.showToast(
//                           msg: "Selected address not found!",
//                           toastLength: Toast.LENGTH_SHORT,
//                           gravity: ToastGravity.BOTTOM,
//                           backgroundColor: Colors.red,
//                           textColor: Colors.white,
//                           fontSize: 14.0,
//                         );
//                         return;
//                       }
//
//                       final latitude = selectedAddress['latitude']?.toDouble();
//                       final longitude =
//                       selectedAddress['longitude']?.toDouble();
//                       final addressText =
//                       selectedAddress['address']?.toString();
//                       final title =
//                           selectedAddress['title']?.toString() ?? 'N/A';
//                       final landmark =
//                           selectedAddress['landmark']?.toString() ?? 'N/A';
//
//                       if (addressText == null ||
//                           addressText.isEmpty ||
//                           latitude == null ||
//                           longitude == null ||
//                           latitude == 0.0 ||
//                           longitude == 0.0) {
//                         Fluttertoast.showToast(
//                           msg: "Invalid selected address data!",
//                           toastLength: Toast.LENGTH_SHORT,
//                           gravity: ToastGravity.BOTTOM,
//                           backgroundColor: Colors.red,
//                           textColor: Colors.white,
//                           fontSize: 14.0,
//                         );
//                         return;
//                       }
//
//                       print(
//                         "Debug: Submitting address: $addressText, ID: $selectedAddressId",
//                       );
//                       // Call onLocationSelected to trigger API
//                       widget.onLocationSelected({
//                         'address': addressText,
//                         'latitude': latitude,
//                         'longitude': longitude,
//                         'title': title,
//                         'landmark': landmark,
//                       });
//                       // Save location to SharedPreferences
//                       await _saveLocation(
//                         addressText,
//                         latitude: latitude,
//                         longitude: longitude,
//                         addressId: selectedAddressId,
//                         title: title,
//                         landmark: landmark,
//                       );
//                       Navigator.pop(context);
//                       // Show success toast
//                       Fluttertoast.showToast(
//                         msg: "Location submitted successfully!",
//                         toastLength: Toast.LENGTH_SHORT,
//                         gravity: ToastGravity.BOTTOM,
//                         backgroundColor: Colors.black,
//                         textColor: Colors.white,
//                         fontSize: 14.0,
//                       );
//                     },
//                     child: Container(
//                       height: screenHeight * 0.06,
//                       width: screenWidth * 0.3,
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade700,
//                         borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Submit",
//                           style: GoogleFonts.roboto(
//                             fontSize: 14 * textScaleFactor,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  String? selectedTitle;
  String? selectedLandmark;

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
    print("Debug: I am loading the saved location...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocation = prefs.getString("selected_location");
    String? savedAddressId = prefs.getString("selected_address_id");
    String? savedTitle = prefs.getString("selected_title");
    String? savedLandmark = prefs.getString("selected_landmark");

    print(
      "Debug: Loaded savedLocation: $savedLocation, savedAddressId: $savedAddressId, savedTitle: $savedTitle, savedLandmark: $savedLandmark",
    );

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

        print("Debug: getUserProfileData response: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true && data['data'] != null) {
            List<dynamic> fullAddress = data['data']['full_address'] ?? [];
            print("Debug: Raw full_address from server: $fullAddress");

            setState(() {
              savedAddresses = _removeDuplicateAddresses(fullAddress);
              print(
                "Debug: Loaded fullAddress after deduplication: $savedAddresses",
              );

              if (savedAddresses.isNotEmpty) {
                if (savedAddressId == null ||
                    !savedAddresses.any(
                          (addr) => addr['_id'] == savedAddressId,
                    )) {
                  savedAddressId = savedAddresses[0]['_id'];
                  savedLocation =
                      savedAddresses[0]['address'] ?? "Select Location";
                  savedTitle = savedAddresses[0]['title']?.toString() ?? 'N/A';
                  savedLandmark =
                      savedAddresses[0]['landmark']?.toString() ?? 'N/A';
                }

                selectedAddressId = savedAddressId;
                selectedLocation = savedLocation ?? "Select Location";
                selectedTitle = savedTitle ?? 'N/A';
                selectedLandmark = savedLandmark ?? 'N/A';

                // Removed onLocationSelected call to prevent API trigger on init
                print("📍 Location in UI: $selectedLocation");
              } else {
                selectedAddressId = null;
                selectedLocation = "Select Location";
                selectedTitle = 'N/A';
                selectedLandmark = 'N/A';
              }
            });
          } else {
            print("Debug: getUserProfileData failed: ${data['message']}");
          }
        } else {
          print(
            "Debug: getUserProfileData server error: ${response.statusCode}",
          );
        }
      } catch (e) {
        print("Error in _loadSavedLocation: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching location: $e")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login first!")));
      }
    }
  }

  List<dynamic> _mergeLocalChanges(List<dynamic> serverAddresses) {
    print("Debug: Merging local changes...");
    final mergedAddresses = List<dynamic>.from(serverAddresses);
    for (var localAddr in savedAddresses) {
      final index = mergedAddresses.indexWhere(
            (addr) => addr['_id'] == localAddr['_id'],
      );
      if (index != -1) {
        mergedAddresses[index] = {
          '_id': localAddr['_id'],
          'address':
          localAddr['address'] ??
              mergedAddresses[index]['address'] ??
              'Unknown',
          'latitude':
          localAddr['latitude'] ??
              mergedAddresses[index]['latitude'] ??
              0.0,
          'longitude':
          localAddr['longitude'] ??
              mergedAddresses[index]['longitude'] ??
              0.0,
          'title':
          localAddr['title'] ?? mergedAddresses[index]['title'] ?? 'N/A',
          'landmark':
          localAddr['landmark'] ??
              mergedAddresses[index]['landmark'] ??
              'N/A',
        };
        print(
          "Debug: Merged address ID: ${mergedAddresses[index]['_id']}, address: ${mergedAddresses[index]['address']}",
        );
      } else if (!mergedAddresses.any(
            (addr) => addr['_id'] == localAddr['_id'],
      )) {
        mergedAddresses.add(localAddr);
        print(
          "Debug: Added new local address ID: ${localAddr['_id']}, address: ${localAddr['address']}",
        );
      }
    }
    return _removeDuplicateAddresses(mergedAddresses);
  }

  List<dynamic> _removeDuplicateAddresses(List<dynamic> addresses) {
    print("Debug: Removing duplicate addresses...");
    final seenIds = <String>{};
    final uniqueAddresses = <dynamic>[];

    for (var address in addresses) {
      final id = address['_id']?.toString() ?? '';
      if (id.isNotEmpty && !seenIds.contains(id)) {
        seenIds.add(id);
        uniqueAddresses.add(address);
      } else {
        print(
          "Debug: Removed duplicate address with ID: $id, address: ${address['address']}",
        );
      }
    }
    return uniqueAddresses;
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
        String? title,
        String? landmark,
      }) async {
    print("Debug: Location save : $location, ID: $addressId");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_location", location);
    await prefs.setString("address", location);
    if (latitude != null) await prefs.setDouble("user_latitude", latitude);
    if (longitude != null) await prefs.setDouble("user_longitude", longitude);
    if (addressId != null)
      await prefs.setString("selected_address_id", addressId);
    if (title != null) await prefs.setString("selected_title", title);
    if (landmark != null) await prefs.setString("selected_landmark", landmark);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login first!")));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login first!")));
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

      print("Debug: fetchLocationDetails response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final address = data['address']?.toString();
          final latitude = data['latitude']?.toDouble();
          final longitude = data['longitude']?.toDouble();
          final title = data['title']?.toString() ?? 'N/A';
          final landmark = data['landmark']?.toString() ?? 'N/A';

          if (address == null ||
              address.isEmpty ||
              latitude == null ||
              longitude == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invalid location data received!"),
                ),
              );
            }
            return null;
          }

          return {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'title': title,
            'landmark': landmark,
          };
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "API error: ${data['message'] ?? 'Unknown error'}",
                ),
              ),
            );
          }
          return null;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error: ${response.statusCode}")),
          );
        }
        return null;
      }
    } catch (e) {
      print("Error in fetchLocationDetails: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching location details: $e")),
        );
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
      String title,
      String landmark,
      ) async {
    if (address.isEmpty || latitude == 0.0 || longitude == 0.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid address or coordinates!")),
        );
      }
      return;
    }

    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login first!")));
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/updateLocation');
    try {
      print("Debug: Updating location with address: $address, ID: $addressId");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          '_id': addressId,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'title': title,
          'landmark': landmark,
        }),
      );

      print("Debug: updateLocation response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          String newAddressId = data['location']['_id'] ?? addressId;
          setState(() {
            savedAddresses.removeWhere((addr) => addr['_id'] == addressId);
            savedAddresses.add({
              '_id': newAddressId,
              'address': address,
              'latitude': latitude,
              'longitude': longitude,
              'title': title,
              'landmark': landmark,
            });
            selectedLocation = address;
            selectedAddressId = newAddressId;
            selectedTitle = title;
            selectedLandmark = landmark;
            savedAddresses = _removeDuplicateAddresses(savedAddresses);
            print(
              "Debug: Updated address ID: $newAddressId, address: $address",
            );
            print(
              "Debug: Deduplicated savedAddresses after update: $savedAddresses",
            );
            // Removed onLocationSelected call to prevent API trigger here
            print("📍 Location in UI: $address, ID: $newAddressId");
          });

          await _saveLocation(
            address,
            latitude: latitude,
            longitude: longitude,
            addressId: newAddressId,
            title: title,
            landmark: landmark,
          );

          await _loadSavedLocation();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  data['message'] ?? "Location updated successfully!",
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "API error: ${data['message'] ?? 'Unknown error'}",
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      print("Error in updateLocation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Error updating location: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {isLoading = false;});
      }
    }
  }
  Future<void> deleteAddress(String addressId) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login first!")));
      }
      return;
    }
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Delete",
            style: GoogleFonts.roboto(
              fontSize: 18 * MediaQuery.of(context).textScaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this address?",
            style: GoogleFonts.roboto(
              fontSize: 14 * MediaQuery.of(context).textScaleFactor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: GoogleFonts.roboto(
                  color: Colors.grey,
                  fontSize: 14 * MediaQuery.of(context).textScaleFactor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Delete",
                style: GoogleFonts.roboto(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * MediaQuery.of(context).textScaleFactor,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmDelete != true) return;
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
                selectedAddressId = savedAddresses.isNotEmpty ? savedAddresses[0]['_id'] : null;
                selectedLocation = savedAddresses.isNotEmpty ? savedAddresses[0]['address'] : "Select Location";
                selectedTitle = savedAddresses.isNotEmpty ? savedAddresses[0]['title']?.toString() ?? 'N/A' : 'N/A';
                selectedLandmark = savedAddresses.isNotEmpty ? savedAddresses[0]['landmark']?.toString() ?? 'N/A' : 'N/A';
                // Removed onLocationSelected call to prevent API trigger here
                print("📍 Location in UI: $selectedLocation");
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  data['message'] ?? "Address deleted successfully!",
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "API error: ${data['message'] ?? 'Unknown error'}",
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      print("Error in deleteAddress: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting address: $e")));
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
        child: Stack(
          children: [
            Padding(
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
                      Expanded(
                        child: Text(
                          'Select Location',
                          style: GoogleFonts.roboto(
                            fontSize: 18 * textScaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        print(
                          "Debug: Add button pressed, opening AddressDetailScreen",
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressDetailScreen(),
                          ),
                        ).then((result) {
                          print("Debug: Returned from AddressDetailScreen (Add), result: $result",);
                          if (result != null && !result['isEdit']) {
                            setState(() {
                              selectedLocation = result['address'] ?? "Select Location";
                              selectedAddressId = result['addressId'];
                              selectedTitle = result['title']?.toString() ?? 'N/A';
                              selectedLandmark = result['landmark']?.toString() ?? 'N/A';
                              if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId,
                              )) {
                                savedAddresses.add({
                                  '_id': selectedAddressId,
                                  'address': selectedLocation,
                                  'latitude': result['latitude']?.toDouble() ?? 0.0,
                                  'longitude': result['longitude']?.toDouble() ?? 0.0,
                                  'title': selectedTitle,
                                  'landmark': selectedLandmark,
                                });
                                print(
                                  "Debug: New Address Add: $selectedLocation, ID: $selectedAddressId",
                                );
                              } else {
                                print(
                                  "Debug: Address already exists, skipping add: $selectedAddressId",
                                );
                              }
                              savedAddresses = _removeDuplicateAddresses(
                                savedAddresses,
                              );
                              print(
                                "Debug: Deduplicated savedAddresses after add: $savedAddresses",
                              );
                              // Removed onLocationSelected and _saveLocation to prevent API trigger here
                            });
                            _loadSavedLocation(); // Keep this for server sync
                          }
                        });
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
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "By choosing this address you can find results accordingly",
                          style: GoogleFonts.roboto(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.00),
                  Expanded(
                    child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (savedAddresses.isNotEmpty) ...[
                          SizedBox(height: screenHeight * 0.01),
                          Expanded(
                            child: ListView.builder(
                              itemCount: savedAddresses.length,
                              itemBuilder: (context, index) {
                                final address = savedAddresses[index];
                                print(
                                  "Debug: Rendering address ID: ${address['_id']}, address: ${address['address']}, title: ${address['title']}, landmark: ${address['landmark']}",
                                );
                                return GestureDetector(
                                  onTap: () {
                                    final latitude =
                                    address['latitude']?.toDouble();
                                    final longitude =
                                    address['longitude']?.toDouble();
                                    final addressText =
                                    address['address']?.toString();
                                    final title = address['title']?.toString() ?? 'N/A';
                                    final landmark = address['landmark']?.toString() ?? 'N/A';

                                    if (addressText == null ||
                                        addressText.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Invalid address!",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (latitude == null ||
                                        longitude == null ||
                                        latitude == 0.0 ||
                                        longitude == 0.0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Invalid latitude or longitude for this address!",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      selectedAddressId =
                                      address['_id'];
                                      selectedLocation = addressText;
                                      selectedTitle = title;
                                      selectedLandmark = landmark;
                                      // Removed onLocationSelected to prevent API trigger here
                                      print(
                                        "📍 Location in UI: $addressText",
                                      );
                                    });
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
                                      borderRadius:
                                      BorderRadius.circular(
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
                                        Text("Abhi check the text"),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: address['_id'],
                                              groupValue:
                                              selectedAddressId,
                                              onChanged: (value) {
                                                final latitude =
                                                address['latitude']?.toDouble();
                                                final longitude =
                                                address['longitude']?.toDouble();
                                                final addressText =
                                                address['address']?.toString();
                                                final title = address['title']?.toString() ?? 'N/A';
                                                final landmark = address['landmark']?.toString() ?? 'N/A';
                                                if (addressText == null || addressText.isEmpty) {
                                                  ScaffoldMessenger.of(context,).showSnackBar(
                                                    const SnackBar(content: Text("Invalid address!",),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                if (latitude == null ||
                                                    longitude == null ||
                                                    latitude == 0.0 ||
                                                    longitude == 0.0) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Invalid latitude or longitude for this address!",),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                setState(() {
                                                  selectedAddressId = value;
                                                  selectedLocation = addressText;
                                                  selectedTitle = title;
                                                  selectedLandmark = landmark;
                                                  // Removed onLocationSelected to prevent API trigger here
                                                  print("📍 Location in UI: $addressText",);
                                                });
                                              },
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(address['address'] ?? "Unknown",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 14 * textScaleFactor,
                                                      fontWeight: FontWeight.bold,),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  SizedBox(
                                                    height: screenHeight * 0.005,
                                                  ),
                                                  Text(
                                                    "Title: ${address['title'] ?? 'N/A'}",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 12 * textScaleFactor,
                                                    ),
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    "Landmark: ${address['landmark'] ?? 'N/A'}",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 12 * textScaleFactor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.01,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                print(
                                                  "Debug: Edit button pressed for address ID: ${address['_id']}",
                                                );
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context,) => AddressDetailScreen(
                                                      editlocationId:
                                                      address['_id'] ??
                                                          "no id",
                                                      initialAddress:
                                                      address['address']?.toString() ?? "",
                                                      initialLocation: LatLng(address['latitude']?.toDouble() ?? 0.0,
                                                        address['longitude']?.toDouble() ?? 0.0,
                                                      ),
                                                      initialTitle:
                                                      address['title']?.toString() ?? "",
                                                      initialLandmark: address['landmark']?.toString() ?? "",
                                                    ),
                                                  ),
                                                ).then((result) {
                                                  print(
                                                    "Debug: Returned from AddressDetailScreen (Edit), result: $result",
                                                  );
                                                  if (result != null &&
                                                      result['isEdit']) {
                                                    setState(() {
                                                      String
                                                      oldAddressId =
                                                      address['_id'];
                                                      selectedLocation = result['address'] ?? "Select Location";
                                                      selectedAddressId = result['addressId'] ?? oldAddressId;
                                                      selectedTitle = result['title']?.toString() ?? 'N/A';selectedLandmark =
                                                          result['landmark']?.toString() ?? 'N/A';

                                                      savedAddresses.removeWhere(
                                                            (addr) => addr['_id'] == oldAddressId,
                                                      );

                                                      int
                                                      index = savedAddresses.indexWhere((addr) =>
                                                      addr['_id'] == selectedAddressId,
                                                      );
                                                      if (index == -1) {
                                                        savedAddresses.add({'_id':
                                                        selectedAddressId, 'address': selectedLocation, 'latitude':
                                                        result['latitude']?.toDouble() ?? 0.0,
                                                          'longitude': result['longitude']?.toDouble() ?? 0.0,
                                                          'title': selectedTitle,
                                                          'landmark': selectedLandmark,
                                                        });
                                                        print(
                                                          "Debug: New address add  ID: $selectedAddressId, address: $selectedLocation",
                                                        );
                                                      } else {
                                                        savedAddresses[index] = {'_id':
                                                        selectedAddressId, 'address':
                                                        selectedLocation, 'latitude':
                                                        result['latitude']?.toDouble() ?? 0.0,
                                                          'longitude':
                                                          result['longitude']?.toDouble() ?? 0.0,
                                                          'title': selectedTitle, 'landmark': selectedLandmark,
                                                        };
                                                        print(
                                                          "Debug: Existing address update  ID: $selectedAddressId, address: $selectedLocation",
                                                        );
                                                      }

                                                      savedAddresses = _removeDuplicateAddresses(
                                                        savedAddresses,
                                                      );
                                                      print(
                                                        "Debug: Deduplicated savedAddresses after edit: $savedAddresses",
                                                      );

                                                      // Removed onLocationSelected to prevent API trigger here
                                                    });

                                                    _saveLocation(
                                                      selectedLocation,
                                                      latitude: result['latitude']?.toDouble(),
                                                      longitude: result['longitude']?.toDouble(),
                                                      addressId: selectedAddressId,
                                                      title: selectedTitle,
                                                      landmark: selectedLandmark,
                                                    );

                                                    _loadSavedLocation();
                                                  }
                                                });
                                              },
                                              child: Text(
                                                "Edit",
                                                style: GoogleFonts.roboto(
                                                  color:
                                                  Colors.green.shade700,
                                                  fontWeight: FontWeight.bold, fontSize: 12 * textScaleFactor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.02,
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                print(
                                                  "Debug: Delete button  pressed for address ID: ${address['_id']}",
                                                );
                                                await deleteAddress(address['_id'],);
                                              },
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.roboto(color:
                                                Colors.red.shade700,
                                                  fontWeight:
                                                  FontWeight.bold,
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
                                final suggestion =
                                locationSuggestions[index];
                                return ListTile(
                                  title: Text(
                                    suggestion['description'] ??
                                        "Unknown",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14 * textScaleFactor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  onTap: () async {
                                    final locationData =
                                    await fetchLocationDetails(
                                      suggestion['place_id'],
                                    );
                                    if (locationData != null) {
                                      setState(() {
                                        selectedLocation =
                                        locationData['address'];
                                        selectedAddressId =
                                        suggestion['place_id'];
                                        selectedTitle =
                                            locationData['title']?.toString() ?? 'N/A';
                                        selectedLandmark = locationData['landmark']?.toString() ?? 'N/A';
                                        if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId,
                                        )) {
                                          savedAddresses.add({'_id': selectedAddressId,
                                            'address': selectedLocation,
                                            'latitude': locationData['latitude']?.toDouble() ?? 0.0,
                                            'longitude': locationData['longitude']?.toDouble() ?? 0.0,
                                            'title': selectedTitle,
                                            'landmark': selectedLandmark,
                                          });
                                          print(
                                            "Debug: Suggestion se naya address add kiya: $selectedLocation, ID: $selectedAddressId",
                                          );
                                        }
                                        savedAddresses = _removeDuplicateAddresses(savedAddresses,
                                        );
                                        print("Debug: Deduplicated savedAddresses after suggestion add: $savedAddresses",);
                                        // Removed onLocationSelected, _saveLocation, _loadSavedLocation to prevent API trigger here
                                        print(
                                          "📍 Location in UI: $selectedLocation",
                                        );
                                      });
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context,).showSnackBar(
                                          const SnackBar(
                                            content: Text("Failed to fetch location details!",),
                                          ),
                                        );
                                      }
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
                 /* GestureDetector(
                    onTap: () async {
                      print("Debug: Submit button pressed");
                      if (selectedAddressId == null) {
                        Fluttertoast.showToast(
                          msg: "Please select a location!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      final selectedAddress = savedAddresses.firstWhere(
                            (addr) => addr['_id'] == selectedAddressId, orElse: () => null,);

                      if (selectedAddress == null) {
                        Fluttertoast.showToast(
                          msg: "Selected address not found!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      final latitude = selectedAddress['latitude']?.toDouble();
                      final longitude =
                      selectedAddress['longitude']?.toDouble();
                      final addressText =
                      selectedAddress['address']?.toString();
                      final title =
                          selectedAddress['title']?.toString() ?? 'N/A';
                      final landmark =
                          selectedAddress['landmark']?.toString() ?? 'N/A';

                      if (addressText == null ||
                          addressText.isEmpty ||
                          latitude == null ||
                          longitude == null ||
                          latitude == 0.0 ||
                          longitude == 0.0) {
                        Fluttertoast.showToast(
                          msg: "Invalid selected address data!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      print(
                        "Debug: Submitting address: $addressText, ID: $selectedAddressId",
                      );
                      // Call onLocationSelected to trigger API
                      widget.onLocationSelected({
                        'address': addressText,
                        'latitude': latitude,
                        'longitude': longitude,
                        'title': title,
                        'landmark': landmark,
                      });
                      // Save location to SharedPreferences
                      await _saveLocation(
                        addressText,
                        latitude: latitude,
                        longitude: longitude,
                        addressId: selectedAddressId,
                        title: title,
                        landmark: landmark,
                      );
                      Navigator.pop(context);
                      // Show success toast
                      Fluttertoast.showToast(
                        msg: "Location submitted successfully!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
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
                          "Submit",
                          style: GoogleFonts.roboto(
                            fontSize: 14 * textScaleFactor,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  // Text("di,pr,u,a,d,s,m,a,g,n,t,s,p,a,a"),
                  GestureDetector(
                    onTap: () async {
                      if (isLoading) return; // Prevent multiple clicks
                      print("Debug: Submit button pressed");
                      if (selectedAddressId == null) {
                        Fluttertoast.showToast(
                          msg: "Please select a location!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }
                      final selectedAddress = savedAddresses.firstWhere(
                            (addr) => addr['_id'] == selectedAddressId,
                        orElse: () => null,
                      );

                      if (selectedAddress == null) {
                        Fluttertoast.showToast(
                          msg: "Selected address not found!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      final latitude = selectedAddress['latitude']?.toDouble();
                      final longitude = selectedAddress['longitude']?.toDouble();
                      final addressText = selectedAddress['address']?.toString();
                      final title = selectedAddress['title']?.toString() ?? 'N/A';
                      final landmark = selectedAddress['landmark']?.toString() ?? 'N/A';

                      if (addressText == null ||
                          addressText.isEmpty ||
                          latitude == null ||
                          longitude == null ||
                          latitude == 0.0 ||
                          longitude == 0.0) {
                        Fluttertoast.showToast(
                          msg: "Invalid selected address data!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      // Call updateLocation API
                      await updateLocation(
                        addressText,
                        latitude,
                        longitude,
                        selectedAddressId!,
                        title,
                        landmark,
                      );

                      setState(() {
                        isLoading = false;
                      });

                      // Call onLocationSelected to notify parent widget
                      widget.onLocationSelected({
                        'address': addressText,
                        'latitude': latitude,
                        'longitude': longitude,
                        'title': title,
                        'landmark': landmark,
                      });

                      // Save location to SharedPreferences
                      await _saveLocation(
                        addressText,
                        latitude: latitude,
                        longitude: longitude,
                        addressId: selectedAddressId,
                        title: title,
                        landmark: landmark,
                      );

                      // Navigate back
                      Navigator.pop(context);

                      // Show success toast
                      // Fluttertoast.showToast(
                      //   msg: "Location submitted successfully!",
                      //   toastLength: Toast.LENGTH_SHORT,
                      //   gravity: ToastGravity.BOTTOM,
                      //   backgroundColor: Colors.black,
                      //   textColor: Colors.white,
                      //   fontSize: 14.0,
                      // );

                    },
                    child: Container(
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.3,
                      decoration: BoxDecoration(
                        color: isLoading ? Colors.grey : Colors.green.shade700,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Center(
                        child: Text(
                          "Submit",
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
          ],
        ),
      ),
    );
  }
}
//A widget is a basic building block of Flutter UI that represents everything you see on the screen, like text, button, image, or layout.