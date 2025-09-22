// import 'dart:async';
// import 'dart:convert';
// import 'package:developer/Emergency/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Widgets/AppColors.dart';
// import '../../../utility/custom_snack_bar.dart';
// import '../auth/AddressDetailScreen.dart';
//
// class LocationSelectionScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>) onLocationSelected;
//
//   const LocationSelectionScreen({Key? key, required this.onLocationSelected})
//       : super(key: key);
//
//   @override
//   State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
// }
//
// class _LocationSelectionScreenState extends State<LocationSelectionScreen>
//     with RouteAware {
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
//   static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
//
//   @override
//   void initState() {
//     super.initState();
//     bwDebug("Debug: initState chala, initial load shuru...");
//     _loadSavedLocation();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     print("Debug: didChangeDependencies chala, subscribing to routeObserver...");
//     routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
//   }
//
//   @override
//   void dispose() {
//     bwDebug("Debug: dispose chala, cleaning up...");
//     locationController.dispose();
//     _debounce?.cancel();
//     routeObserver.unsubscribe(this);
//     super.dispose();
//   }
//
//   @override
//   void didPopNext() {
//     print("Debug: Screen wapas aayi, data refresh kar raha hoon...");
//     _loadSavedLocation();
//   }
//
//   Future<void> _loadSavedLocation() async {
//     print("Debug: _loadSavedLocation shuru ho raha hai...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedLocation = prefs.getString("selected_location");
//     String? savedAddressId = prefs.getString("selected_address_id");
//     String? savedTitle = prefs.getString("selected_title");
//     String? savedLandmark = prefs.getString("selected_landmark");
//
//     print(
//       "Debug: SharedPreferences se data - savedLocation: $savedLocation, savedAddressId: $savedAddressId, savedTitle: $savedTitle, savedLandmark: $savedLandmark",
//     );
//
//     String? token = await _getToken();
//     print("Debug: Token: $token");
//     if (token != null && mounted) {
//       try {
//         print("Debug: API call kar raha hoon: $baseUrl/api/user/getUserProfileData");
//         final response = await http.get(
//           Uri.parse('$baseUrl/api/user/getUserProfileData'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//
//         print("Debug: API response status: ${response.statusCode}, body: ${response.body}");
//
//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           print("Debug: API response data: $data");
//           if (data['status'] == true && data['data'] != null) {
//             List<dynamic> fullAddress = data['data']['full_address'] ?? [];
//             print("Debug: Server se full_address: $fullAddress");
//
//             setState(() {
//               savedAddresses = _removeDuplicateAddresses(fullAddress);
//               print("Debug: Deduplicated savedAddresses: $savedAddresses");
//
//               if (savedAddresses.isNotEmpty) {
//                 if (savedAddressId == null ||
//                     !savedAddresses.any((addr) => addr['_id'] == savedAddressId)) {
//                   savedAddressId = savedAddresses[0]['_id'];
//                   savedLocation = savedAddresses[0]['address'] ?? "Select Location";
//                   savedTitle = savedAddresses[0]['title']?.toString() ?? 'N/A';
//                   savedLandmark = savedAddresses[0]['landmark']?.toString() ?? 'N/A';
//                 }
//
//                 selectedAddressId = savedAddressId;
//                 selectedLocation = savedLocation ?? "Select Location";
//                 selectedTitle = savedTitle ?? 'N/A';
//                 selectedLandmark = savedLandmark ?? 'N/A';
//
//                 print("📍 UI mein location set: $selectedLocation, ID: $savedAddressId");
//               } else {
//                 selectedAddressId = null;
//                 selectedLocation = "Select Location";
//                 selectedTitle = 'N/A';
//                 selectedLandmark = 'N/A';
//                 print("Debug: Koi saved addresses nahi mile.");
//               }
//             });
//           } else {
//             print("Debug: API failed: ${data['message']}");
//             if (mounted) {
//               // ScaffoldMessenger.of(context).showSnackBar(
//               //   SnackBar(content: Text("API failed: ${data['message'] ?? 'Unknown error'}")),
//               // );
//               CustomSnackBar.show(
//                   context,
//                   message: "API failed: ${data['message'] ?? 'Unknown error'}",
//                   type: SnackBarType.error
//               );
//             }
//           }
//         } else {
//           print("Debug: API server error: ${response.statusCode}");
//           if (mounted) {
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(content: Text("Server error: ${response.statusCode}")),
//             // );
//             CustomSnackBar.show(
//                 context,
//                 message:"Server error:Try Again... ${response.statusCode}" ,
//                 type: SnackBarType.warning
//             );
//           }
//         }
//       } catch (e) {
//         print("Error in _loadSavedLocation: $e");
//         if (mounted) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text("Error fetching location: $e")),
//           // );
//           CustomSnackBar.show(
//               context,
//               message: "Error fetching location: ",
//               type: SnackBarType.error
//           );
//         }
//       }
//     } else {
//       print("Debug: Token null hai ya widget mounted nahi hai.");
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Please login first!")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message: "Please login first!",
//             type: SnackBarType.warning
//         );
//       }
//     }
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
//           "Debug: Duplicate address hata diya - ID: $id, address: ${address['address']}",
//         );
//       }
//     }
//     return uniqueAddresses;
//   }
//
//   Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString("token");
//     print("Debug: Token fetched from SharedPreferences: $token");
//     return token;
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
//     print("Debug: Saving location: $location, ID: $addressId");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("selected_location", location);
//     await prefs.setString("address", location);
//     if (latitude != null) await prefs.setDouble("user_latitude", latitude);
//     if (longitude != null) await prefs.setDouble("user_longitude", longitude);
//     if (addressId != null) await prefs.setString("selected_address_id", addressId);
//     if (title != null) await prefs.setString("selected_title", title);
//     if (landmark != null) await prefs.setString("selected_landmark", landmark);
//     print("Debug: Location saved to SharedPreferences");
//   }
//
//   Future<void> fetchLocationSuggestions(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         locationSuggestions = [];
//       });
//       print("Debug: Input khali hai, suggestions clear kar diya");
//       return;
//     }
//
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Please login first!")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message:"Please login first!" ,
//             type: SnackBarType.warning
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
//       print("Debug: Location suggestions fetch kar raha hoon: $url");
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       print("Debug: fetchLocationSuggestions response: ${response.body}");
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           setState(() {
//             locationSuggestions = data['suggestions'] ?? [];
//             print("Debug: Suggestions loaded: $locationSuggestions");
//           });
//         } else {
//           print("Debug: Suggestions API failed: ${data['message']}");
//         }
//       } else {
//         print("Debug: Suggestions API server error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error in fetchLocationSuggestions: $e");
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text("Error fetching suggestions: $e")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message:"Error fetching suggestions: $e" ,
//             type: SnackBarType.error
//         );
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
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Please login first!")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message: "Please login first!",
//             type: SnackBarType.warning
//         );
//       }
//       return null;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final url = Uri.parse('$baseUrl/api/user/get-location-from-place?place_id=$placeId');
//     try {
//       print("Debug: Fetching location details for place_id: $placeId");
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
//           if (address == null || address.isEmpty || latitude == null || longitude == null) {
//             if (mounted) {
//               // ScaffoldMessenger.of(context).showSnackBar(
//               //   const SnackBar(content: Text("Invalid location data received!")),
//               // );
//               CustomSnackBar.show(
//                   context,
//                   message: "Invalid location data received!",
//                   type: SnackBarType.warning
//               );
//             }
//             return null;
//           }
//
//           print("Debug: Location details fetched: $address, $latitude, $longitude");
//           return {
//             'address': address,
//             'latitude': latitude,
//             'longitude': longitude,
//             'title': title,
//             'landmark': landmark,
//           };
//         } else {
//           print("Debug: Location details API failed: ${data['message']}");
//           if (mounted) {
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(content: Text("API error: ${data['message'] ?? 'Unknown error'}")),
//             // );
//             CustomSnackBar.show(
//                 context,
//                 message: "API error: ${data['message'] ?? 'Unknown error'}",
//                 type: SnackBarType.error
//             );
//
//           }
//           return null;
//         }
//       } else {
//         print("Debug: Location details server error: ${response.statusCode}");
//         if (mounted) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text("Server error: ${response.statusCode}")),
//           // );
//           CustomSnackBar.show(
//               context,
//               message:"Server error: ${response.statusCode}" ,
//               type: SnackBarType.error
//           );
//
//         }
//         return null;
//       }
//     } catch (e) {
//       print("Error in fetchLocationDetails: $e");
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text("Error fetching location details: $e")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message: "Error fetching location details: $e",
//             type: SnackBarType.error
//         );
//
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
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Invalid address or coordinates!")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message:"Invalid address or coordinates!" ,
//             type: SnackBarType.error
//         );
//
//       }
//       return;
//     }
//
//     String? token = await _getToken();
//     if (token == null) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Please login first!")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message: "Please login first!",
//             type: SnackBarType.warning
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
//       print("Debug: Updating location: $address, ID: $addressId");
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
//
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
//             print("Debug: Updated address ID: $newAddressId, address: $address");
//             print("Debug: Deduplicated savedAddresses after update: $savedAddresses");
//             print("📍 UI mein location set: $address, ID: $newAddressId");
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
//           if (mounted) {
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(content: Text(data['message'] ?? "Location updated successfully!")),
//             // );
//             CustomSnackBar.show(
//                 context,
//                 message:data['message'] ?? "Location updated successfully!" ,
//                 type: SnackBarType.success
//             );
//           }
//         } else {
//           print("Debug: Update location API failed: ${data['message']}");
//           if (mounted) {
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(content: Text("API error: ${data['message'] ?? 'Unknown error'}")),
//             // );
//             CustomSnackBar.show(
//                 context,
//                 message:"API error: ${data['message'] ?? 'Unknown error'}" ,
//                 type: SnackBarType.error
//             );
//           }
//         }
//       } else {
//         print("Debug: Update location server error: ${response.statusCode}");
//         if (mounted) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text("Server error: ${response.statusCode}")),
//           // );
//           CustomSnackBar.show(
//               context,
//               message:"Server error: ${response.statusCode}" ,
//               type: SnackBarType.error
//           );
//         }
//       }
//     } catch (e) {
//       print("Error in updateLocation: $e");
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text("Error updating location: $e")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message:"Error updating location: $e",
//             type: SnackBarType.error
//         );
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
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Please login first!")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message:"Please login first!",
//             type: SnackBarType.warning
//         );
//       }
//       return;
//     }
//
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
//
//     if (confirmDelete != true) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final url = Uri.parse('$baseUrl/api/user/deleteAddress/$addressId');
//     try {
//       print("Debug: Deleting address ID: $addressId");
//       final response = await http.delete(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       print("Debug: deleteAddress response: ${response.body}");
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == true) {
//           if (mounted) {
//             setState(() {
//               savedAddresses.removeWhere((address) => address['_id'] == addressId);
//               if (selectedAddressId == addressId) {
//                 selectedAddressId = savedAddresses.isNotEmpty ? savedAddresses[0]['_id'] : null;
//                 selectedLocation = savedAddresses.isNotEmpty
//                     ? savedAddresses[0]['address']
//                     : "Select Location";
//                 selectedTitle = savedAddresses.isNotEmpty
//                     ? savedAddresses[0]['title']?.toString() ?? 'N/A'
//                     : 'N/A';
//                 selectedLandmark = savedAddresses.isNotEmpty
//                     ? savedAddresses[0]['landmark']?.toString() ?? 'N/A'
//                     : 'N/A';
//                 print("📍 UI mein location set after delete: $selectedLocation");
//               }
//               print("Debug: Address deleted, updated savedAddresses: $savedAddresses");
//             });
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(content: Text(data['message'] ?? "Address deleted successfully!")),
//             // );
//             CustomSnackBar.show(
//                 context,
//                 message:data['message'] ?? "Address deleted successfully!",
//                 type: SnackBarType.success
//             );
//           }
//         } else {
//           print("Debug: Delete address API failed: ${data['message']}");
//           if (mounted) {
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(content: Text("API error: ${data['message'] ?? 'Unknown error'}")),
//             // );
//             CustomSnackBar.show(
//                 context,
//                 message:"API error: ${data['message'] ?? 'Unknown error'}",
//                 type: SnackBarType.error
//             );
//           }
//         }
//       } else {
//         print("Debug: Delete address server error: ${response.statusCode}");
//         if (mounted) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text("Server error: ${response.statusCode}")),
//           // );
//           CustomSnackBar.show(
//               context,
//               message:"Server error: ${response.statusCode}",
//               type: SnackBarType.error
//           );
//         }
//       }
//     } catch (e) {
//       print("Error in deleteAddress: $e");
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text("Error deleting address: $e")),
//         // );
//         CustomSnackBar.show(
//             context,
//             message:"Error deleting address: $e",
//             type: SnackBarType.error
//         );
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
//     print("Debug: Building UI, savedAddresses length: ${savedAddresses.length}");
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         centerTitle: true, // Use false to control alignment
//         leading: const BackButton(color: Colors.black),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 'Select Location',
//                 style: GoogleFonts.roboto(
//                   fontSize: 18 * textScaleFactor,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 print("Debug: Add button pressed, opening AddressDetailScreen");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddressDetailScreen(),
//                   ),
//                 ).then((result) {
//                   print("Debug: Returned from AddressDetailScreen (Add), result: $result");
//                   if (result != null && !result['isEdit']) {
//                     setState(() {
//                       selectedLocation = result['address'] ?? "Select Location";
//                       selectedAddressId = result['addressId'];
//                       selectedTitle = result['title']?.toString() ?? 'N/A';
//                       selectedLandmark = result['landmark']?.toString() ?? 'N/A';
//                       if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId)) {
//                         savedAddresses.add({
//                           '_id': selectedAddressId,
//                           'address': selectedLocation,
//                           'latitude': result['latitude']?.toDouble() ?? 0.0,
//                           'longitude': result['longitude']?.toDouble() ?? 0.0,
//                           'title': selectedTitle,
//                           'landmark': selectedLandmark,
//                         });
//                         print("Debug: Added new address: $selectedLocation, ID: $selectedAddressId");
//                       }
//                       savedAddresses = _removeDuplicateAddresses(savedAddresses);
//                       print("Debug: Deduplicated savedAddresses after add: $savedAddresses");
//                     });
//                     _loadSavedLocation();
//                   }
//                 });
//               },
//               child: Container(
//                 height: screenHeight * 0.04,
//                 width: screenWidth * 0.15,
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade700,
//                   borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Add",
//                     style: GoogleFonts.roboto(
//                       fontSize: 10 * textScaleFactor,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         systemOverlayStyle:  SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryGreen,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(screenWidth * 0.04),
//               child: Column(
//                 children: [
//                   // SizedBox(height: screenHeight * 0.02),
//                   // Row(
//                   //   children: [
//                   //     GestureDetector(
//                   //       onTap: () {
//                   //         print("Debug: Back button pressed");
//                   //         Navigator.pop(context);
//                   //       },
//                   //       child: Padding(
//                   //         padding: EdgeInsets.only(left: screenWidth * 0.03),
//                   //         child: Icon(
//                   //           Icons.arrow_back_outlined,
//                   //           size: screenWidth * 0.06,
//                   //           color: Colors.black,
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     SizedBox(width: screenWidth * 0.2),
//                   //     Expanded(
//                   //       child: Text(
//                   //         'Select Location',
//                   //         style: GoogleFonts.roboto(
//                   //           fontSize: 18 * textScaleFactor,
//                   //           fontWeight: FontWeight.bold,
//                   //         ),
//                   //         overflow: TextOverflow.ellipsis,
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                   // Align(
//                   //   alignment: Alignment.bottomRight,
//                   //   child: GestureDetector(
//                   //     onTap: () {
//                   //       print("Debug: Add button pressed, opening AddressDetailScreen");
//                   //       Navigator.push(
//                   //         context,
//                   //         MaterialPageRoute(
//                   //           builder: (context) => AddressDetailScreen(),
//                   //         ),
//                   //       ).then((result) {
//                   //         print("Debug: Returned from AddressDetailScreen (Add), result: $result");
//                   //         if (result != null && !result['isEdit']) {
//                   //           setState(() {
//                   //             selectedLocation = result['address'] ?? "Select Location";
//                   //             selectedAddressId = result['addressId'];
//                   //             selectedTitle = result['title']?.toString() ?? 'N/A';
//                   //             selectedLandmark = result['landmark']?.toString() ?? 'N/A';
//                   //             if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId)) {
//                   //               savedAddresses.add({
//                   //                 '_id': selectedAddressId,
//                   //                 'address': selectedLocation,
//                   //                 'latitude': result['latitude']?.toDouble() ?? 0.0,
//                   //                 'longitude': result['longitude']?.toDouble() ?? 0.0,
//                   //                 'title': selectedTitle,
//                   //                 'landmark': selectedLandmark,
//                   //               });
//                   //               print("Debug: Added new address: $selectedLocation, ID: $selectedAddressId");
//                   //             }
//                   //             savedAddresses = _removeDuplicateAddresses(savedAddresses);
//                   //             print("Debug: Deduplicated savedAddresses after add: $savedAddresses");
//                   //           });
//                   //           _loadSavedLocation(); // Server se sync karo
//                   //         }
//                   //       });
//                   //     },
//                   //     child: Container(
//                   //       height: screenHeight * 0.04,
//                   //       width: screenWidth * 0.15,
//                   //       decoration: BoxDecoration(
//                   //         color: Colors.green.shade700,
//                   //         borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   //       ),
//                   //       child: Center(
//                   //         child: Text(
//                   //           "Add",
//                   //           style: GoogleFonts.roboto(
//                   //             fontSize: 10 * textScaleFactor,
//                   //             color: Colors.white,
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
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
//                           textAlign: TextAlign.center,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.00),
//                   Expanded(
//                     child: isLoading
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
//                                   "Debug: Rendering address: ID: ${address['_id']}, address: ${address['address']}, title: ${address['title']}, landmark: ${address['landmark']}",
//                                 );
//                                 return GestureDetector(
//                                   onTap: () {
//                                     final latitude = address['latitude']?.toDouble();
//                                     final longitude = address['longitude']?.toDouble();
//                                     final addressText = address['address']?.toString();
//                                     final title = address['title']?.toString() ?? 'N/A';
//                                     final landmark = address['landmark']?.toString() ?? 'N/A';
//
//                                     if (addressText == null || addressText.isEmpty) {
//                                       // ScaffoldMessenger.of(context).showSnackBar(
//                                       //   const SnackBar(content: Text("Invalid address!")),
//                                       // );
//                                       CustomSnackBar.show(
//                                           context,
//                                           message: "Invalid address!",
//                                           type: SnackBarType.error
//                                       );
//                                       return;
//                                     }
//                                     if (latitude == null || longitude == null || latitude == 0.0 || longitude == 0.0) {
//                                       // ScaffoldMessenger.of(context).showSnackBar(
//                                       //   const SnackBar(content: Text("Invalid latitude or longitude for this address!")),
//                                       // );
//                                       CustomSnackBar.show(
//                                           context,
//                                           message: "Invalid latitude or longitude for this address!",
//                                           type: SnackBarType.error
//                                       );
//                                       return;
//                                     }
//
//                                     setState(() {
//                                       selectedAddressId = address['_id'];
//                                       selectedLocation = addressText;
//                                       selectedTitle = title;
//                                       selectedLandmark = landmark;
//                                       print("📍 UI mein location set: $addressText");
//                                     });
//                                   },
//                                   child: Container(
//                                     margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
//                                     padding: EdgeInsets.all(screenWidth * 0.03),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(color: Colors.grey.shade300),
//                                       borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Radio<String>(
//                                               value: address['_id'],
//                                               groupValue: selectedAddressId,
//                                               onChanged: (value) {
//                                                 final latitude = address['latitude']?.toDouble();
//                                                 final longitude = address['longitude']?.toDouble();
//                                                 final addressText = address['address']?.toString();
//                                                 final title = address['title']?.toString() ?? 'N/A';
//                                                 final landmark = address['landmark']?.toString() ?? 'N/A';
//                                                 if (addressText == null || addressText.isEmpty) {
//                                                   // ScaffoldMessenger.of(context).showSnackBar(
//                                                   //   const SnackBar(content: Text("Invalid address!")),
//                                                   // );
//                                                   CustomSnackBar.show(
//                                                       context,
//                                                       message: "Invalid address!",
//                                                       type: SnackBarType.error
//                                                   );
//                                                   return;
//                                                 }
//                                                 if (latitude == null || longitude == null || latitude == 0.0 || longitude == 0.0) {
//                                                   // ScaffoldMessenger.of(context).showSnackBar(
//                                                   //   const SnackBar(content: Text("Invalid latitude or longitude for this address!")),
//                                                   // );
//                                                   CustomSnackBar.show(
//                                                       context,
//                                                       message: "Invalid latitude or longitude for this address!",
//                                                       type: SnackBarType.error
//                                                   );
//                                                   return;
//                                                 }
//
//                                                 setState(() {
//                                                   selectedAddressId = value;
//                                                   selectedLocation = addressText;
//                                                   selectedTitle = title;
//                                                   selectedLandmark = landmark;
//                                                   print("📍 UI mein location set: $addressText");
//                                                 });
//                                               },
//                                             ),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     address['address'] ?? "Unknown",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: 14 * textScaleFactor,
//                                                       fontWeight: FontWeight.bold,
//                                                     ),
//                                                     overflow: TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                   ),
//                                                   SizedBox(height: screenHeight * 0.005),
//                                                   Text(
//                                                     "Title: ${address['title'] ?? 'N/A'}",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: 12 * textScaleFactor,
//                                                     ),
//                                                     overflow: TextOverflow.ellipsis,
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
//                                         SizedBox(height: screenHeight * 0.01),
//                                         Row(
//                                           mainAxisAlignment: MainAxisAlignment.end,
//                                           children: [
//                                             TextButton(
//                                               onPressed: () {
//                                                 print("Debug: Edit button pressed for address ID: ${address['_id']}");
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) => AddressDetailScreen(
//                                                       editlocationId: address['_id'] ?? "no id",
//                                                       initialAddress: address['address']?.toString(),
//                                                       initialLocation: LatLng(
//                                                         address['latitude']?.toDouble() ?? 0.0,
//                                                         address['longitude']?.toDouble() ?? 0.0,
//                                                       ),
//                                                       initialTitle: address['title']?.toString(),
//                                                       initialLandmark: address['landmark']?.toString(),
//                                                     ),
//                                                   ),
//                                                 ).then((result) {
//                                                   print("Debug: Returned from AddressDetailScreen (Edit), result: $result");
//                                                   if (result != null && result['isEdit']) {
//                                                     setState(() {
//                                                       String oldAddressId = address['_id'];
//                                                       selectedLocation = result['address'] ?? "Select Location";
//                                                       selectedAddressId = result['addressId'] ?? oldAddressId;
//                                                       selectedTitle = result['title']?.toString() ?? 'N/A';
//                                                       selectedLandmark = result['landmark']?.toString() ?? 'N/A';
//
//                                                       savedAddresses.removeWhere((addr) => addr['_id'] == oldAddressId);
//
//                                                       int index = savedAddresses.indexWhere((addr) => addr['_id'] == selectedAddressId);
//                                                       if (index == -1) {
//                                                         savedAddresses.add({
//                                                           '_id': selectedAddressId,
//                                                           'address': selectedLocation,
//                                                           'latitude': result['latitude']?.toDouble(),
//                                                           'longitude': result['longitude']?.toDouble(),
//                                                           'title': selectedTitle,
//                                                           'landmark': selectedLandmark,
//                                                         });
//                                                         print("Debug: Added new edited address ID: $selectedAddressId, address: $selectedLocation");
//                                                       } else {
//                                                         savedAddresses[index] = {
//                                                           '_id': selectedAddressId,
//                                                           'address': selectedLocation,
//                                                           'latitude': result['latitude']?.toDouble(),
//                                                           'longitude': result['longitude']?.toDouble(),
//                                                           'title': selectedTitle,
//                                                           'landmark': selectedLandmark,
//                                                         };
//                                                         print("Debug: Updated existing address ID: $selectedAddressId, address: $selectedLocation");
//                                                       }
//
//                                                       savedAddresses = _removeDuplicateAddresses(savedAddresses);
//                                                       print("Debug: Deduplicated savedAddresses after edit: $savedAddresses");
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
//                                                     _loadSavedLocation();
//                                                   }
//                                                 });
//                                               },
//                                               child: Text(
//                                                 "Edit",
//                                                 style: GoogleFonts.roboto(
//                                                   color: Colors.green.shade700,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12 * textScaleFactor,
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: screenWidth * 0.02),
//                                             TextButton(
//                                               onPressed: () async {
//                                                 print("Debug: Delete button pressed for address ID: ${address['_id']}");
//                                                 await deleteAddress(address['_id']);
//                                               },
//                                               child: Text(
//                                                 "Delete",
//                                                 style: GoogleFonts.roboto(
//                                                   color: Colors.red.shade700,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12 * textScaleFactor,
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
//                                 final suggestion = locationSuggestions[index];
//                                 print("Debug: Rendering suggestion: ${suggestion['description']}");
//                                 return ListTile(
//                                   title: Text(
//                                     suggestion['description'] ?? "Unknown",
//                                     style: GoogleFonts.roboto(
//                                       fontSize: 14 * textScaleFactor,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                   onTap: () async {
//                                     final locationData = await fetchLocationDetails(suggestion['place_id']);
//                                     if (locationData != null) {
//                                       setState(() {
//                                         selectedLocation = locationData['address'];
//                                         selectedAddressId = suggestion['place_id'];
//                                         selectedTitle = locationData['title']?.toString() ?? 'N/A';
//                                         selectedLandmark = locationData['landmark']?.toString() ?? 'N/A';
//                                         if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId)) {
//                                           savedAddresses.add({
//                                             '_id': selectedAddressId,
//                                             'address': selectedLocation,
//                                             'latitude': locationData['latitude']?.toDouble() ?? 0.0,
//                                             'longitude': locationData['longitude']?.toDouble() ?? 0.0,
//                                             'title': selectedTitle,
//                                             'landmark': selectedLandmark,
//                                           });
//                                           print("Debug: Added suggestion address: $selectedLocation, ID: $selectedAddressId");
//                                         }
//                                         savedAddresses = _removeDuplicateAddresses(savedAddresses);
//                                         print("Debug: Deduplicated savedAddresses after suggestion add: $savedAddresses");
//                                         print("📍 UI mein location set: $selectedLocation");
//                                       });
//                                     } else {
//                                       if (mounted) {
//                                         // ScaffoldMessenger.of(context).showSnackBar(
//                                         //   const SnackBar(content: Text("Failed to fetch location details!")),
//                                         // );
//                                         CustomSnackBar.show(
//                                             context,
//                                             message:"Failed to fetch location details!" ,
//                                             type: SnackBarType.error
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
//                   GestureDetector(
//                     onTap: () async {
//                       if (isLoading) return;
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
//                             (addr) => addr['_id'] == selectedAddressId,
//                         orElse: () => null,
//                       );
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
//                       final longitude = selectedAddress['longitude']?.toDouble();
//                       final addressText = selectedAddress['address']?.toString();
//                       final title = selectedAddress['title']?.toString() ?? 'N/A';
//                       final landmark = selectedAddress['landmark']?.toString() ?? 'N/A';
//
//                       if (addressText == null || addressText.isEmpty || latitude == null || longitude == null || latitude == 0.0 || longitude == 0.0) {
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
//                       setState(() {
//                         isLoading = true;
//                       });
//
//                       await updateLocation(
//                         addressText,
//                         latitude,
//                         longitude,
//                         selectedAddressId!,
//                         title,
//                         landmark,
//                       );
//
//                       setState(() {
//                         isLoading = false;
//                       });
//
//                       widget.onLocationSelected({
//                         'address': addressText,
//                         'latitude': latitude,
//                         'longitude': longitude,
//                         'title': title,
//                         'landmark': landmark,
//                       });
//
//                       await _saveLocation(
//                         addressText,
//                         latitude: latitude,
//                         longitude: longitude,
//                         addressId: selectedAddressId,
//                         title: title,
//                         landmark: landmark,
//                       );
//
//                  //    Navigator.pop(context);
//
//                       // Fluttertoast.showToast(
//                       //   msg: "Location submitted successfully!",
//                       //   toastLength: Toast.LENGTH_SHORT,
//                       //   gravity: ToastGravity.BOTTOM,
//                       //   backgroundColor: Colors.black,
//                       //   textColor: Colors.white,
//                       //   fontSize: 14.0,
//                       // );
//                     },
//                     child: Container(
//                       height: screenHeight * 0.06,
//                       width: screenWidth * 0.3,
//                       decoration: BoxDecoration(
//                         color: isLoading ? Colors.grey : Colors.green.shade700,
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
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../auth/AddressDetailScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationSelectionScreen({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen>
    with RouteAware {
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

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    print("Debug: initState chala, initial load shuru...");
    _loadSavedLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("Debug: didChangeDependencies chala, subscribing to routeObserver...");
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    print("Debug: dispose chala, cleaning up...");
    locationController.dispose();
    _debounce?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    print("Debug: Screen wapas aayi, data refresh kar raha hoon...");
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    print("Debug: _loadSavedLocation shuru ho raha hai...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocation = prefs.getString("selected_location");
    String? savedAddressId = prefs.getString("selected_address_id");
    String? savedTitle = prefs.getString("selected_title");
    String? savedLandmark = prefs.getString("selected_landmark");

    print(
      "Debug: SharedPreferences se data - savedLocation: $savedLocation, savedAddressId: $savedAddressId, savedTitle: $savedTitle, savedLandmark: $savedLandmark",
    );

    String? token = await _getToken();
    print("Debug: Token: $token");
    if (token != null && mounted) {
      try {
        print("Debug: API call kar raha hoon: $baseUrl/api/user/getUserProfileData");
        final response = await http.get(
          Uri.parse('$baseUrl/api/user/getUserProfileData'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print("Debug: API response status: ${response.statusCode}, body: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("Debug: API response data: $data");
          if (data['status'] == true && data['data'] != null) {
            List<dynamic> fullAddress = data['data']['full_address'] ?? [];
            print("Debug: Server se full_address: $fullAddress");

            setState(() {
              savedAddresses = _removeDuplicateAddresses(fullAddress);
              print("Debug: Deduplicated savedAddresses: $savedAddresses");

              if (savedAddresses.isNotEmpty) {
                if (savedAddressId == null ||
                    !savedAddresses.any((addr) => addr['_id'] == savedAddressId)) {
                  savedAddressId = savedAddresses[0]['_id'];
                  savedLocation = savedAddresses[0]['address'] ?? "Select Location";
                  savedTitle = savedAddresses[0]['title']?.toString() ?? 'N/A';
                  savedLandmark = savedAddresses[0]['landmark']?.toString() ?? 'N/A';
                }

                selectedAddressId = savedAddressId;
                selectedLocation = savedLocation ?? "Select Location";
                selectedTitle = savedTitle ?? 'N/A';
                selectedLandmark = savedLandmark ?? 'N/A';

                print("📍 UI mein location set: $selectedLocation, ID: $savedAddressId");
              } else {
                selectedAddressId = null;
                selectedLocation = "Select Location";
                selectedTitle = 'N/A';
                selectedLandmark = 'N/A';
                print("Debug: Koi saved addresses nahi mile.");
              }
            });
          } else {
            print("Debug: API failed: ${data['message']}");
            if (mounted) {

              CustomSnackBar.show(
                  context,
                  message: "API failed: ${data['message'] ?? 'Unknown error'}",
                  type: SnackBarType.error
              );

            }
          }
        } else {
          print("Debug: API server error: ${response.statusCode}");
          if (mounted) {

            CustomSnackBar.show(
                context,
                message:"Server error: ${response.statusCode}" ,
                type: SnackBarType.error
            );

          }
        }
      } catch (e) {
        print("Error in _loadSavedLocation: $e");
        if (mounted) {

          CustomSnackBar.show(
              context,
              message: "Error fetching location",
              type: SnackBarType.error
          );

        }
      }
    } else {
      print("Debug: Token null hai ya widget mounted nahi hai.");
      if (mounted) {

        CustomSnackBar.show(
            context,
            message:"Please login first!",
            type: SnackBarType.error
        );

      }
    }
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
          "Debug: Duplicate address hata diya - ID: $id, address: ${address['address']}",
        );
      }
    }
    return uniqueAddresses;
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    print("Debug: Token fetched from SharedPreferences: $token");
    return token;
  }

  Future<void> _saveLocation(
      String location, {
        double? latitude,
        double? longitude,
        String? addressId,
        String? title,
        String? landmark,
      }) async {
    print("Debug: Saving location: $location, ID: $addressId");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_location", location);
    await prefs.setString("address", location);
    if (latitude != null) await prefs.setDouble("user_latitude", latitude);
    if (longitude != null) await prefs.setDouble("user_longitude", longitude);
    if (addressId != null) await prefs.setString("selected_address_id", addressId);
    if (title != null) await prefs.setString("selected_title", title);
    if (landmark != null) await prefs.setString("selected_landmark", landmark);
    print("Debug: Location saved to SharedPreferences");
  }

  Future<void> fetchLocationSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        locationSuggestions = [];
      });
      print("Debug: Input khali hai, suggestions clear kar diya");
      return;
    }

    String? token = await _getToken();
    if (token == null) {
      if (mounted) {

        CustomSnackBar.show(
            context,
            message: "Please login first!",
            type: SnackBarType.error
        );

      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/suggest-locations?input=$input');
    try {
      print("Debug: Location suggestions fetch kar raha hoon: $url");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Debug: fetchLocationSuggestions response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            locationSuggestions = data['suggestions'] ?? [];
            print("Debug: Suggestions loaded: $locationSuggestions");
          });
        } else {
          print("Debug: Suggestions API failed: ${data['message']}");
        }
      } else {
        print("Debug: Suggestions API server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in fetchLocationSuggestions: $e");
      if (mounted) {
            CustomSnackBar.show(
            context,
            message:"Error fetching suggestions" ,
            type: SnackBarType.error
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

  Future<Map<String, dynamic>?> fetchLocationDetails(String placeId) async {
    String? token = await _getToken();
    if (token == null) {
      if (mounted) {

        CustomSnackBar.show(
            context,
            message:"Please login first!" ,
            type: SnackBarType.error
        );

      }
      return null;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/get-location-from-place?place_id=$placeId');
    try {
      print("Debug: Fetching location details for place_id: $placeId");
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

          if (address == null || address.isEmpty || latitude == null || longitude == null) {
            if (mounted) {

              CustomSnackBar.show(
                  context,
                  message: "Invalid location data received!",
                  type: SnackBarType.error
              );
            }
            return null;
          }

          print("Debug: Location details fetched: $address, $latitude, $longitude");
          return {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'title': title,
            'landmark': landmark,
          };
        } else {
          print("Debug: Location details API failed: ${data['message']}");
          if (mounted) {

            CustomSnackBar.show(
                context,
                message: "API error: ${data['message'] ?? 'Unknown error'}",
                type: SnackBarType.error
            );
          }
          return null;
        }
      } else {
        print("Debug: Location details server error: ${response.statusCode}");
        if (mounted) {

          CustomSnackBar.show(
              context,
              message:"Server error: ${response.statusCode}" ,
              type: SnackBarType.error
          );
        }
        return null;
      }
    } catch (e) {
      print("Error in fetchLocationDetails: $e");
      if (mounted) {

        CustomSnackBar.show(
            context,
            message: "Error fetching location details: $e",
            type: SnackBarType.error
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

        CustomSnackBar.show(
            context,
            message: "Invalid address or coordinates!",
            type: SnackBarType.error
        );
      }
      return;
    }

    String? token = await _getToken();
    if (token == null) {
      if (mounted) {

        CustomSnackBar.show(
            context,
            message: "Please login first!",
            type: SnackBarType.error
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/user/updateLocation');
    try {
      print("Debug: Updating location: $address, ID: $addressId");
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
            print("Debug: Updated address ID: $newAddressId, address: $address");
            print("Debug: Deduplicated savedAddresses after update: $savedAddresses");
            print("📍 UI mein location set: $address, ID: $newAddressId");
          });

          await _saveLocation(
            address,
            latitude: latitude,
            longitude: longitude,
            addressId: newAddressId,
            title: title,
            landmark: landmark,
          );

          // if (mounted) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text(data['message'] ?? "Location updated successfully!")),
          //   );
          // }

          // if (mounted) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text(data['message'] ?? "Location updated successfully! sdfsdafsda")),
          //   );
          // }
        } else {
          print("Debug: Update location API failed: ${data['message']}");
          if (mounted) {

            CustomSnackBar.show(
                context,
                message:"API error: ${data['message'] ?? 'Unknown error'}" ,
                type: SnackBarType.error
            );
          }
        }
      } else {
        print("Debug: Update location server error: ${response.statusCode}");
        if (mounted) {

          CustomSnackBar.show(
              context,
              message: "Server error: ${response.statusCode}",
              type: SnackBarType.error
          );
        }
      }
    } catch (e) {
      print("Error in updateLocation: $e");
      if (mounted) {

        CustomSnackBar.show(
            context,
            message:"Error updating location: $e" ,
            type: SnackBarType.error
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

        CustomSnackBar.show(
            context,
            message: "Please login first!",
            type: SnackBarType.error
        );
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
      print("Debug: Deleting address ID: $addressId");
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Debug: deleteAddress response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (mounted) {
            setState(() {
              savedAddresses.removeWhere((address) => address['_id'] == addressId);
              if (selectedAddressId == addressId) {
                selectedAddressId = savedAddresses.isNotEmpty ? savedAddresses[0]['_id'] : null;
                selectedLocation = savedAddresses.isNotEmpty
                    ? savedAddresses[0]['address']
                    : "Select Location";
                selectedTitle = savedAddresses.isNotEmpty
                    ? savedAddresses[0]['title']?.toString() ?? 'N/A'
                    : 'N/A';
                selectedLandmark = savedAddresses.isNotEmpty
                    ? savedAddresses[0]['landmark']?.toString() ?? 'N/A'
                    : 'N/A';
                print("📍 UI mein location set after delete: $selectedLocation");
              }
              print("Debug: Address deleted, updated savedAddresses: $savedAddresses");
            });

            CustomSnackBar.show(
                context,
                message:data['message'] ?? "Address deleted successfully!" ,
                type: SnackBarType.success
            );
          }
        } else {
          print("Debug: Delete address API failed: ${data['message']}");
          if (mounted) {

            CustomSnackBar.show(
                context,
                message: "API error: ${data['message'] ?? 'Unknown error'}",
                type: SnackBarType.error
            );

          }
        }
      } else {
        print("Debug: Delete address server error: ${response.statusCode}");
        if (mounted) {

          CustomSnackBar.show(
              context,
              message: "Server error: ${response.statusCode}",
              type: SnackBarType.error
          );

        }
      }
    } catch (e) {
      print("Error in deleteAddress: $e");
      if (mounted) {
            CustomSnackBar.show(
            context,
            message: "Error deleting address",
            type: SnackBarType.error
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    print("Debug: Building UI, savedAddresses length: ${savedAddresses.length}");

    return Scaffold(
      appBar:AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Select Location",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        print("Debug: Add button pressed, opening AddressDetailScreen");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressDetailScreen(),
                          ),
                        ).then((result) {
                          print("Debug: Returned from AddressDetailScreen (Add), result: $result");
                          if (result != null && !result['isEdit']) {
                            setState(() {
                              selectedLocation = result['address'] ?? "Select Location";
                              selectedAddressId = result['addressId'];
                              selectedTitle = result['title']?.toString() ?? 'N/A';
                              selectedLandmark = result['landmark']?.toString() ?? 'N/A';
                              if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId)) {
                                savedAddresses.add({
                                  '_id': selectedAddressId,
                                  'address': selectedLocation,
                                  'latitude': result['latitude']?.toDouble() ?? 0.0,
                                  'longitude': result['longitude']?.toDouble() ?? 0.0,
                                  'title': selectedTitle,
                                  'landmark': selectedLandmark,
                                });
                                print("Debug: Added new address: $selectedLocation, ID: $selectedAddressId");
                              }
                              savedAddresses = _removeDuplicateAddresses(savedAddresses);
                              print("Debug: Deduplicated savedAddresses after add: $savedAddresses");
                            });
                            _loadSavedLocation(); // Server se sync karo
                          }
                        });
                      },
                      child: Container(
                        height: screenHeight * 0.04,
                        width: screenWidth * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
                    child: isLoading
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
                                  "Debug: Rendering address: ID: ${address['_id']}, address: ${address['address']}, title: ${address['title']}, landmark: ${address['landmark']}",
                                );
                                return GestureDetector(
                                  onTap: () {
                                    final latitude = address['latitude']?.toDouble();
                                    final longitude = address['longitude']?.toDouble();
                                    final addressText = address['address']?.toString();
                                    final title = address['title']?.toString() ?? 'N/A';
                                    final landmark = address['landmark']?.toString() ?? 'N/A';

                                    if (addressText == null || addressText.isEmpty) {
                                      CustomSnackBar.show(
                                          context,
                                          message: "Invalid address!",
                                          type: SnackBarType.error
                                      );

                                      return;
                                    }
                                    if (latitude == null || longitude == null || latitude == 0.0 || longitude == 0.0) {

                                      CustomSnackBar.show(
                                          context,
                                          message: "Invalid latitude or longitude for this address!",
                                          type: SnackBarType.error
                                      );

                                      return;
                                    }

                                    setState(() {
                                      selectedAddressId = address['_id'];
                                      selectedLocation = addressText;
                                      selectedTitle = title;
                                      selectedLandmark = landmark;
                                      print("📍 UI mein location set: $addressText");
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: address['_id'],
                                              groupValue: selectedAddressId,
                                              onChanged: (value) {
                                                final latitude = address['latitude']?.toDouble();
                                                final longitude = address['longitude']?.toDouble();
                                                final addressText = address['address']?.toString();
                                                final title = address['title']?.toString() ?? 'N/A';
                                                final landmark = address['landmark']?.toString() ?? 'N/A';
                                                if (addressText == null || addressText.isEmpty) {

                                                  CustomSnackBar.show(
                                                      context,
                                                      message:"Invalid address!" ,
                                                      type: SnackBarType.error
                                                  );

                                                  return;
                                                }
                                                if (latitude == null || longitude == null || latitude == 0.0 || longitude == 0.0) {


                                                  CustomSnackBar.show(
                                                      context,
                                                      message: "Invalid latitude or longitude for this address!",
                                                      type: SnackBarType.error
                                                  );

                                                  return;
                                                }

                                                setState(() {
                                                  selectedAddressId = value;
                                                  selectedLocation = addressText;
                                                  selectedTitle = title;
                                                  selectedLandmark = landmark;
                                                  print("📍 UI mein location set: $addressText");
                                                });
                                              },
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    address['address'] ?? "Unknown",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 14 * textScaleFactor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  SizedBox(height: screenHeight * 0.005),
                                                  Text(
                                                    "Title: ${address['title'] ?? 'N/A'}",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 12 * textScaleFactor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
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
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                print("Debug: Edit button pressed for address ID: ${address['_id']}");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => AddressDetailScreen(
                                                      editlocationId: address['_id'] ?? "no id",
                                                      initialAddress: address['address']?.toString(),
                                                      initialLocation: LatLng(
                                                        address['latitude']?.toDouble() ?? 0.0,
                                                        address['longitude']?.toDouble() ?? 0.0,
                                                      ),
                                                      initialTitle: address['title']?.toString(),
                                                      initialLandmark: address['landmark']?.toString(),
                                                    ),
                                                  ),
                                                ).then((result) {
                                                  print("Debug: Returned from AddressDetailScreen (Edit), result: $result");
                                                  if (result != null && result['isEdit']) {
                                                    setState(() {
                                                      String oldAddressId = address['_id'];
                                                      selectedLocation = result['address'] ?? "Select Location";
                                                      selectedAddressId = result['addressId'] ?? oldAddressId;
                                                      selectedTitle = result['title']?.toString() ?? 'N/A';
                                                      selectedLandmark = result['landmark']?.toString() ?? 'N/A';

                                                      savedAddresses.removeWhere((addr) => addr['_id'] == oldAddressId);

                                                      int index = savedAddresses.indexWhere((addr) => addr['_id'] == selectedAddressId);
                                                      if (index == -1) {
                                                        savedAddresses.add({
                                                          '_id': selectedAddressId,
                                                          'address': selectedLocation,
                                                          'latitude': result['latitude']?.toDouble(),
                                                          'longitude': result['longitude']?.toDouble(),
                                                          'title': selectedTitle,
                                                          'landmark': selectedLandmark,
                                                        });
                                                        print("Debug: Added new edited address ID: $selectedAddressId, address: $selectedLocation");
                                                      } else {
                                                        savedAddresses[index] = {
                                                          '_id': selectedAddressId,
                                                          'address': selectedLocation,
                                                          'latitude': result['latitude']?.toDouble(),
                                                          'longitude': result['longitude']?.toDouble(),
                                                          'title': selectedTitle,
                                                          'landmark': selectedLandmark,
                                                        };
                                                        print("Debug: Updated existing address ID: $selectedAddressId, address: $selectedLocation");
                                                      }

                                                      savedAddresses = _removeDuplicateAddresses(savedAddresses);
                                                      print("Debug: Deduplicated savedAddresses after edit: $savedAddresses");
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
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12 * textScaleFactor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            TextButton(
                                              onPressed: () async {
                                                print("Debug: Delete button pressed for address ID: ${address['_id']}");
                                                await deleteAddress(address['_id']);
                                              },
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.roboto(
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12 * textScaleFactor,
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
                                print("Debug: Rendering suggestion: ${suggestion['description']}");
                                return ListTile(
                                  title: Text(
                                    suggestion['description'] ?? "Unknown",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14 * textScaleFactor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  onTap: () async {
                                    final locationData = await fetchLocationDetails(suggestion['place_id']);
                                    if (locationData != null) {
                                      setState(() {
                                        selectedLocation = locationData['address'];
                                        selectedAddressId = suggestion['place_id'];
                                        selectedTitle = locationData['title']?.toString() ?? 'N/A';
                                        selectedLandmark = locationData['landmark']?.toString() ?? 'N/A';
                                        if (!savedAddresses.any((addr) => addr['_id'] == selectedAddressId)) {
                                          savedAddresses.add({
                                            '_id': selectedAddressId,
                                            'address': selectedLocation,
                                            'latitude': locationData['latitude']?.toDouble() ?? 0.0,
                                            'longitude': locationData['longitude']?.toDouble() ?? 0.0,
                                            'title': selectedTitle,
                                            'landmark': selectedLandmark,
                                          });
                                          print("Debug: Added suggestion address: $selectedLocation, ID: $selectedAddressId");
                                        }
                                        savedAddresses = _removeDuplicateAddresses(savedAddresses);
                                        print("Debug: Deduplicated savedAddresses after suggestion add: $savedAddresses");
                                        print("📍 UI mein location set: $selectedLocation");
                                      });
                                    } else {
                                      if (mounted) {

                                        CustomSnackBar.show(
                                            context,
                                            message:"Failed to fetch location details!" ,
                                            type: SnackBarType.error
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
                  GestureDetector(
                    onTap: () async {
                      if (isLoading) return;
                      print("Debug: Submit button pressed");
                      if (selectedAddressId == null) {

                        CustomSnackBar.show(
                            context,
                            message:"Please select a location!" ,
                            type: SnackBarType.error
                        );
                        return;
                      }

                      final selectedAddress = savedAddresses.firstWhere(
                            (addr) => addr['_id'] == selectedAddressId,
                        orElse: () => null,
                      );

                      if (selectedAddress == null) {

                        CustomSnackBar.show(
                            context,
                            message: "Selected address not found!",
                            type: SnackBarType.error
                        );
                        return;
                      }

                      final latitude = selectedAddress['latitude']?.toDouble();
                      final longitude = selectedAddress['longitude']?.toDouble();
                      final addressText = selectedAddress['address']?.toString();
                      final title = selectedAddress['title']?.toString() ?? 'N/A';
                      final landmark = selectedAddress['landmark']?.toString() ?? 'N/A';

                      if (addressText == null || addressText.isEmpty || latitude == null || longitude == null || latitude == 0.0 || longitude == 0.0) {

                        CustomSnackBar.show(
                            context,
                            message: "Invalid selected address data!",
                            type: SnackBarType.error
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

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

                      widget.onLocationSelected({
                        'address': addressText,
                        'latitude': latitude,
                        'longitude': longitude,
                        'title': title,
                        'landmark': landmark,
                      });

                      await _saveLocation(
                        addressText,
                        latitude: latitude,
                        longitude: longitude,
                        addressId: selectedAddressId,
                        title: title,
                        landmark: landmark,
                      );

                      Navigator.pop(context);
                      CustomSnackBar.show(
                          context,
                          message: "Location submitted successfully!",
                          type: SnackBarType.success
                      );
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