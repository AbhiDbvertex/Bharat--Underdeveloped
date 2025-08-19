
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../User/UserNotificationScreen.dart';
// import '../comm/home_location_screens.dart';
//
//
// class ServiceProviderHomeScreen extends StatefulWidget {
//   const ServiceProviderHomeScreen({super.key});
//
//   @override
//   State<ServiceProviderHomeScreen> createState() =>
//       _ServiceProviderHomeScreenState();
// }
//
// class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
//   bool _isSwitched = false;
//   String selectedLocation = "Select Location";
//   ServiceProviderProfileModel? profile;
//   bool isLoading = true;
//   bool _showReviews = true;
//   String? address = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedLocation();
//     fetchProfile();
//   }
//
//   Future<void> fetchProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url = Uri.parse(
//         "https://api.thebharatworks.com/api/user/getUserProfileData",
//       );
//       final response = await http.get(
//         url,
//         headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
//       );
//       print("Full API Response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("Data: $data");
//
//         if (data['status'] == true) {
//           final fetchedAddress =
//           data['data'] != null && data['data']['location'] != null
//               ? (data['data']['location']['address'] ?? 'Select Location')
//               : 'Select Location';
//
//           await prefs.setString("address", fetchedAddress);
//
//           setState(() {
//             profile = ServiceProviderProfileModel.fromJson(data['data']);
//             isLoading = false;
//             address = fetchedAddress;
//             selectedLocation = fetchedAddress; // Sync with address
//           });
//
//           print("Saved address: $fetchedAddress");
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data["message"] ?? "Profile fetch failed")),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Server error, profile fetch failed!")),
//         );
//       }
//     } catch (e) {
//       print("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Something went wrong, try again!")),
//       );
//     }
//   }
//
//   Future<String> getsaveLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final savedAddress = prefs.getString("address") ?? "Select Location";
//     print("Abhi: get save location: $savedAddress");
//     return savedAddress;
//   }
//
//   Future<void> _loadSavedLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedLocation = prefs.getString("selected_location");
//     if (savedLocation == null || savedLocation.isEmpty) {
//       savedLocation = await getsaveLocation();
//     }
//     setState(() {
//       selectedLocation = savedLocation ?? "Select Location";
//       print("SharedPreferences se mila: $selectedLocation");
//     });
//   }
//
//   void _navigateToLocationScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => LocationSelectionScreen(
//           onLocationSelected: (location) async {
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             await prefs.setString("selected_location", location);
//             await prefs.setString("address", location); // Sync with address
//             setState(() {
//               selectedLocation = location;
//               print("Nayi screen se location aaya: $location");
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade800,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 10,
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: height * 0.01),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: _navigateToLocationScreen,
//                       child: Image.asset('assets/images/loc.png'),
//                     ),
//                     SizedBox(width: 5),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _navigateToLocationScreen,
//                         child: Text(
//                           selectedLocation,
//                           style: GoogleFonts.roboto(
//                             fontSize: 12,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     Image.asset(
//                       'assets/images/sin.png',
//                       height: 34.9,
//                       width: 100.25,
//                     ),
//                     const SizedBox(width: 5),
//                     Image.asset('assets/images/sin1.png'),
//                     const Spacer(),
//                     InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => UserNotificationScreen(),
//                           ),
//                         );
//                       },
//                       child: Image.asset('assets/images/noti.png'),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Image.asset(
//                 'assets/images/banner.png',
//                 height: 151,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               const SizedBox(height: 10),
//               sectionHeader("WORK CATEGORIES"),
//               const SizedBox(height: 10),
//               const SizedBox(height: 20),
//               Center(
//                 child: Container(
//                   width: 340,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green.shade50,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 12,
//                         horizontal: 20,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           'assets/images/vec.png',
//                           height: 24,
//                           width: 24,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             'Are you ready for Emergency task?',
//                             style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         SizedBox(
//                           width: 40,
//                           height: 20,
//                           child: Transform.scale(
//                             scale: 0.6,
//                             alignment: Alignment.centerLeft,
//                             child: Switch(
//                               value: _isSwitched,
//                               onChanged: (bool value) {
//                                 setState(() {
//                                   _isSwitched = value;
//                                 });
//                               },
//                               activeColor: Colors.red,
//                               inactiveThumbColor: Colors.white,
//                               inactiveTrackColor: Colors.grey.shade300,
//                               materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               sectionHeader("RECENT POSTED WORK"),
//               const SizedBox(height: 20),
//               Container(
//                 height: 180,
//                 width: double.infinity,
//                 color: Colors.green.shade50,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: const [
//                       Recent(
//                         name: "Furniture",
//                         role: "Make Chair...",
//                         imagePath: 'assets/images/Fur.png',
//                       ),
//                       SizedBox(width: 12),
//                       Recent(
//                         name: "Furniture",
//                         role: "Make Chair...",
//                         imagePath: 'assets/images/Fur2.png',
//                       ),
//                       SizedBox(width: 12),
//                       Recent(
//                         name: "Furniture",
//                         role: "Make Chair...",
//                         imagePath: 'assets/images/Fur.png',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               sectionHeader("EMERGENCY WORK"),
//               const SizedBox(height: 10),
//               Container(
//                 height: 180,
//                 width: double.infinity,
//                 color: Colors.green.shade50,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: const [
//                       EmergencyCard(
//                         name: "Furniture",
//                         role: "Make Chair...",
//                         imagePath: 'assets/images/Fur.png',
//                       ),
//                       SizedBox(width: 12),
//                       EmergencyCard(
//                         name: "Furniture",
//                         role: "Make Chair...",
//                         imagePath: 'assets/images/Fur2.png',
//                       ),
//                       SizedBox(width: 12),
//                       EmergencyCard(
//                         name: "Furniture",
//                         role: "Make Chair...",
//                         imagePath: 'assets/images/Fur.png',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               sectionHeader("FEATURE WORKER"),
//               const SizedBox(height: 10),
//               const SizedBox(height: 20),
//               Container(
//                 height: 142,
//                 width: double.infinity,
//                 color: Colors.green.shade700,
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/images/hand.png',
//                       height: 102,
//                       width: 104,
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(right: 18.0),
//                             child: Text(
//                               'Membership',
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 18.0),
//                             child: Text(
//                               'Choose your desire membership to',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 9,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             'more features',
//                             style: GoogleFonts.roboto(
//                               fontSize: 9,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Image.asset(
//                       'assets/images/arrow.png',
//                       height: 30,
//                       width: 30,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget sectionHeader(String title) {
//     bool showPlus =
//         title.toUpperCase() == "RECENT POSTED WORK" ||
//             title.toUpperCase() == "EMERGENCY WORK";
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.roboto(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           if (showPlus)
//             Padding(
//               padding: const EdgeInsets.only(right: 65.0),
//               child: Image.asset('assets/images/plus.png', height: 20),
//             )
//           else
//             const SizedBox(width: 20),
//           Row(
//             children: [
//               Text(
//                 "See All",
//                 style: GoogleFonts.roboto(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black38,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 14,
//                 color: Colors.black38,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Recent extends StatelessWidget {
//   final String name;
//   final String role;
//   final String imagePath;
//
//   const Recent({
//     super.key,
//     required this.name,
//     required this.role,
//     required this.imagePath,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 135,
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Image.asset(imagePath, width: 125, height: 106, fit: BoxFit.contain),
//           const SizedBox(height: 0),
//           Padding(
//             padding: const EdgeInsets.only(right: 58.0),
//             child: Text(
//               name,
//               style: GoogleFonts.roboto(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           const SizedBox(height: 2),
//           Padding(
//             padding: const EdgeInsets.only(right: 45.0),
//             child: Text(
//               role,
//               style: GoogleFonts.roboto(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class EmergencyCard extends StatelessWidget {
//   final String name;
//   final String role;
//   final String imagePath;
//
//   const EmergencyCard({
//     super.key,
//     required this.name,
//     required this.role,
//     required this.imagePath,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 135,
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Image.asset(imagePath, width: 125, height: 100),
//           const SizedBox(height: 0),
//           Padding(
//             padding: const EdgeInsets.only(right: 58.0),
//             child: Text(
//               name,
//               style: GoogleFonts.roboto(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           const SizedBox(height: 2),
//           Padding(
//             padding: const EdgeInsets.only(right: 45.0),
//             child: Text(
//               role,
//               style: GoogleFonts.roboto(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../User/UserNotificationScreen.dart';
import '../comm/home_location_screens.dart';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() =>
      _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {


  bool _isSwitched = false;
  String userLocation = "Select Location"; // Changed to single source of truth
  ServiceProviderProfileModel? profile;
  bool isLoading = true;
bool _showReviews = true;
String? address = "";

  @override
  void initState() {
    super.initState();
    _initializeLocation(); // Single method to handle location loading
  }

  // Combined method to load saved location and fetch from API if needed
  Future<void> _initializeLocation() async {
    setState(() {
      isLoading = true; // Show loading until location is resolved
    });

    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString("selected_location") ?? prefs.getString("address");

    if (savedLocation != null && savedLocation != "Select Location") {
      // If saved location exists, use it
      setState(() {
        userLocation = savedLocation;
        isLoading = false;
      });
      print("📍 Loaded saved location: $savedLocation");
      return;
    }

    // If no saved location, fetch from API
    await fetchProfile();


  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        if (mounted) {
          Fluttertoast.showToast(msg: "No token found, please log in again!");
        }
        setState(() {
          isLoading = false;
        });
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

          // Check full_address for the latest "Current Location"
          if (data['data']?['full_address'] != null &&
              data['data']['full_address'].isNotEmpty) {
            final addresses = data['data']['full_address'] as List;
            final currentLocations =
            addresses
                .where((addr) => addr['title'] == 'Current Location')
                .toList();
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

          // Save to SharedPreferences
          await prefs.setString("address", apiLocation);
          if (addressId != null) {
            await prefs.setString("selected_address_id", addressId);
          }

          setState(() {
            profile = ServiceProviderProfileModel.fromJson(data['data']);
            userLocation = apiLocation;
            isLoading = false;
          });
          print(
            "📍 Saved and displayed location: $apiLocation (ID: $addressId)",
          );
        } else {
          if (mounted) {
            Fluttertoast.showToast(
              msg: data["message"] ?? "Profile fetch failed",
            );
          }
          setState(() {
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          Fluttertoast.showToast(msg: "Server error, profile fetch failed!");
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      if (mounted) {
        Fluttertoast.showToast(msg: "Something went wrong, try again!");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update location on server
  Future<void> updateLocationOnServer(
      String newAddress,
      double latitude,
      double longitude,
      ) async {
    if (newAddress.isEmpty || latitude == 0.0 || longitude == 0.0) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Invalid location data!");
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

      print(
        "📡 Location update response: ${response.statusCode} - ${response.body}",
      );

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
          setState(() {
            userLocation = newAddress;
            isLoading = false;
          });
          print("📍 Location updated: $newAddress (ID: $newAddressId)");
          if (mounted) {
            // Fluttertoast.showToast(msg: "Location updated: $newAddress");
          }
        } else {
          if (mounted) {
            // Fluttertoast.showToast(
            //   msg: data["message"] ?? "Failed to update location",
            // );
          }
        }
      } else {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Server error, failed to update location!",
          );
        }
      }
    } catch (e) {
      print("❌ Error updating location: $e");
      if (mounted) {
        Fluttertoast.showToast(msg: "Error updating location!");
      }
    }
  }


  void _navigateToLocationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationSelectionScreen(

          onLocationSelected: (Map<String, dynamic> locationData) {
            setState(() {
              userLocation = locationData['address'] ?? 'Select Location';
              debugPrint(
                "📍 New location selected: ${locationData['address']} (ID: ${locationData['addressId']})",
              );
            });
          },
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      String newAddress = result['address'] ?? 'Select Location';
      double latitude = result['latitude'] ?? 0.0;
      double longitude = result['longitude'] ?? 0.0;
      String? addressId = result['addressId'];
      if (newAddress != 'Select Location' &&
          latitude != 0.0 &&
          longitude != 0.0) {
        await updateLocationOnServer(newAddress, latitude, longitude);
        // Save addressId to SharedPreferences
        if (addressId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_address_id', addressId);
        }
        // Refresh location
        await _fetchLocation();
      } else {
        debugPrint("❌ Invalid location data received: $result");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid location data, please try again!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _fetchLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString('selected_location') ?? prefs.getString('address');
    String? savedAddressId = prefs.getString('selected_address_id');

    if (savedLocation != null &&
        savedLocation != 'Select Location' &&
        savedAddressId != null) {
      setState(() {
        userLocation = savedLocation;
        isLoading = false;
      });
      debugPrint(
        "📍 Prioritized saved location: $userLocation (ID: $savedAddressId)",
      );
      return;
    }

    // If no saved location, fetch from API
    setState(() {
      isLoading = true;
    });

    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      debugPrint("❌ No token found!");
      setState(() {
        userLocation = savedLocation ?? 'Select Location';
        isLoading = false;
      });
      debugPrint("📍 Using saved or default location: $userLocation");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed, please log in again!'),
            duration: Duration(seconds: 2),
          ),
        );
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

      debugPrint(
        "📡 API response received: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          final data = responseData['data'];
          String apiLocation = 'Select Location';
          double latitude = 0.0;
          double longitude = 0.0;
          String? addressId;

          // Check for matching address based on savedAddressId
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

          // If no matching address or savedAddressId, use latest "Current Location" address
          if (apiLocation == 'Select Location' &&
              data['full_address'] != null &&
              data['full_address'].isNotEmpty) {
            final currentLocations =
            data['full_address']
                .where((address) => address['title'] == 'Current Location')
                .toList();
            if (currentLocations.isNotEmpty) {
              // Use the latest "Current Location" address
              final latestCurrentLocation = currentLocations.last;
              apiLocation =
                  latestCurrentLocation['address'] ?? 'Select Location';
              latitude = latestCurrentLocation['latitude']?.toDouble() ?? 0.0;
              longitude = latestCurrentLocation['longitude']?.toDouble() ?? 0.0;
              addressId = latestCurrentLocation['_id'];
            } else {
              // Fallback to the last address
              final latestAddress = data['full_address'].last;
              apiLocation = latestAddress['address'] ?? 'Select Location';
              latitude = latestAddress['latitude']?.toDouble() ?? 0.0;
              longitude = latestAddress['longitude']?.toDouble() ?? 0.0;
              addressId = latestAddress['_id'];
            }
          } else if (data['location']?['address']?.isNotEmpty == true) {
            // Fallback to location.address
            apiLocation = data['location']['address'];
            latitude = data['location']['latitude']?.toDouble() ?? 0.0;
            longitude = data['location']['longitude']?.toDouble() ?? 0.0;
          }

          debugPrint(
            "📍 Location fetched from API: $apiLocation (ID: $addressId)",
          );

          // Save API location to SharedPreferences
          await prefs.setString('selected_location', apiLocation);
          await prefs.setString('address', apiLocation);
          await prefs.setDouble('user_latitude', latitude);
          await prefs.setDouble('user_longitude', longitude);
          if (addressId != null) {
            await prefs.setString('selected_address_id', addressId);
          }

          setState(() {
            userLocation = apiLocation;
            isLoading = false;
          });
          debugPrint(
            "📍 Saved API location and displayed in UI: $userLocation (ID: $addressId)",
          );
        } else {
          setState(() {
            userLocation = savedLocation ?? 'Select Location';
            isLoading = false;
          });
          debugPrint("❌ API error: ${responseData['message']}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['message'] ?? 'Failed to fetch profile',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        setState(() {
          userLocation = savedLocation ?? 'Select Location';
          isLoading = false;
        });
        debugPrint("❌ API call failed: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch profile data!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching location: $e");
      setState(() {
        userLocation = savedLocation ?? 'Select Location';
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching location: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateToLocationScreen,
                      child: /*Image.asset('assets/images/loc.png'),*/ SvgPicture.asset('assets/svg_images/LocationIcon.svg',),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToLocationScreen,
                        child: Text(

                          userLocation ?? 'Select Location',

                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Image.asset(
                    //   'assets/images/sin.png',
                    //   height: 34.9,
                    //   width: 100.25,
                    // ),
                    // const SizedBox(width: 5),
                    // Image.asset('assets/images/sin1.png'),
                    SvgPicture.asset('assets/svg_images/homepageLogo.svg',),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserNotificationScreen(),
                          ),
                        );
                      },
                      child: /*Image.asset('assets/images/noti.png'),*/SvgPicture.asset('assets/svg_images/notificationIcon.svg',),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Image.asset(
                'assets/images/banner.png',
                height: 151,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              sectionHeader("WORK CATEGORIES"),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 340,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg_images/Vector.svg',
                          height: 24,
                          color: Colors.green.shade700,
                        ),
                       /* Image.asset(
                          'assets/images/vec.png',
                          height: 24,
                          width: 24,
                        ),*/
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Are you ready for Emergency task?',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // SizedBox(
                        //   width: 40,
                        //   height: 20,
                        //   child: Transform.scale(
                        //     scale: 0.6,
                        //     alignment: Alignment.centerLeft,
                        //
                        //     child:
                        //     // Switch(
                        //     //   value: _isSwitched,
                        //     //   onChanged: (bool value) {
                        //     //     setState(() {
                        //     //       _isSwitched = value;
                        //     //     });
                        //     //     if (value) {
                        //     //       myController.enableFeature();   // API call when ON
                        //     //     } else {
                        //     //       myController.disableFeature();  // API call when OFF
                        //     //     }
                        //     //   },
                        //     //   activeColor: Colors.red,
                        //     //   inactiveThumbColor: Colors.white,
                        //     //   inactiveTrackColor: Colors.grey.shade300,
                        //     //   materialTapTargetSize:
                        //     //   MaterialTapTargetSize.shrinkWrap,
                        //     // ),
                        //     Switch(
                        //       value: _isSwitched,
                        //       onChanged: (bool value) {
                        //         _checkEmergencyTask(); // ✅ same method call
                        //
                        //       },
                        //       activeColor: Colors.red,
                        //       inactiveThumbColor: Colors.white,
                        //       inactiveTrackColor: Colors.grey.shade300,
                        //
                        //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        //     )
                        //
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              sectionHeader("RECENT POSTED WORK"),
              const SizedBox(height: 20),
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      Recent(
                        name: "Furniture",
                        role: "Make Chair...",
                        imagePath: 'assets/images/Fur.png',
                      ),
                      SizedBox(width: 12),
                      Recent(
                        name: "Furniture",
                        role: "Make Chair...",
                        imagePath: 'assets/images/Fur2.png',
                      ),
                      SizedBox(width: 12),
                      Recent(
                        name: "Furniture",
                        role: "Make Chair...",
                        imagePath: 'assets/images/Fur.png',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              sectionHeader("EMERGENCY WORK"),
              const SizedBox(height: 10),
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      EmergencyCard(
                        name: "Furniture",
                        role: "Make Chair...",
                        imagePath: 'assets/images/Fur.png',
                      ),
                      SizedBox(width: 12),
                      EmergencyCard(
                        name: "Furniture",
                        role: "Make Chair...",
                        imagePath: 'assets/images/Fur2.png',
                      ),
                      SizedBox(width: 12),
                      EmergencyCard(
                        name: "Furniture",
                        role: "Make Chair...",
                        imagePath: 'assets/images/Fur.png',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              sectionHeader("FEATURE WORKER"),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              Container(
                height: 142,
                width: double.infinity,
                color: Colors.green.shade700,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/hand.png',
                      height: 102,
                      width: 104,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child: Text(
                              'Membership',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child: Text(
                              'Choose your desire membership to',
                              style: GoogleFonts.roboto(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'more features',
                            style: GoogleFonts.roboto(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/images/arrow.png',
                      height: 30,
                      width: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    bool showPlus =
        title.toUpperCase() == "RECENT POSTED WORK" ||
            title.toUpperCase() == "EMERGENCY WORK";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showPlus)
            Padding(
              padding: const EdgeInsets.only(right: 65.0),
              child: /*Image.asset('assets/images/plus.png', height: 20),*/ SvgPicture.asset(
                'assets/svg_images/add-square.svg',
                height: 20,
              ),
            )
          else
            const SizedBox(width: 20),
          Row(
            children: [
              Text(
                "See All",
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black38,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Recent extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;

  const Recent({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 125, height: 106, fit: BoxFit.contain),
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.only(right: 58.0),
            child: Text(
              name,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(right: 45.0),
            child: Text(
              role,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;

  const EmergencyCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 125, height: 100),
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.only(right: 58.0),
            child: Text(
              name,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(right: 45.0),
            child: Text(
              role,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}