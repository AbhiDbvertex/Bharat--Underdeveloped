// import 'dart:convert';
//
// // import 'package:developer/views/CustomeRole/WorkerScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
//
// class ViewWorkerScreen extends StatefulWidget {
//   final String workerId;
//   const ViewWorkerScreen({super.key, required this.workerId});
//
//   @override
//   State<ViewWorkerScreen> createState() => _ViewWorkerScreenState();
// }
//
// class _ViewWorkerScreenState extends State<ViewWorkerScreen> {
//   Map<String, dynamic>? worker;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWorkerDetail();
//   }
//
//   Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   Future<void> fetchWorkerDetail() async {
//     final token = await getToken();
//     if (token == null) {
//       print("❌ Token not found in local storage");
//       setState(() => isLoading = false);
//       return;
//     }
//
//     final url = Uri.parse(
//       'https://api.thebharatworks.com/api/worker/get/${widget.workerId}',
//     );
//
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
//         if (data['success'] == true) {
//           setState(() {
//             worker = data['worker'];
//             isLoading = false;
//           });
//         } else {
//           print("❌ API error: ${data['message']}");
//           setState(() => isLoading = false);
//         }
//       } else {
//         print("❌ Server error: ${response.statusCode}");
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print('❌ Error fetching worker detail: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   Widget _info(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "$label: ",
//             style: GoogleFonts.roboto(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           Expanded(child: Text(value, style: GoogleFonts.roboto(fontSize: 16))),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : worker == null
//               ? const Center(child: Text("Worker not found"))
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: const Icon(
//                             Icons.arrow_back_outlined,
//                             size: 22,
//                           ),
//                         ),
//
//                         SizedBox(width: 90),
//
//                         Text(
//                           "View Details",
//                           style: GoogleFonts.roboto(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Center(
//                       child: CircleAvatar(
//                         radius: 60,
//                         backgroundColor: Colors.grey[300],
//                         backgroundImage: NetworkImage(
//                           "https://api.thebharatworks.com${worker!['image']}",
//                         ),
//                         onBackgroundImageError: (_, __) {},
//                         child:
//                             worker!['image'] == null
//                                 ? const Icon(Icons.person, size: 60)
//                                 : null,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 6,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _info("Name", worker!['name']),
//                           _info("Phone", worker!['phone']),
//                           _info(
//                             "DOB",
//                             worker!['dob'].toString().substring(0, 10),
//                           ),
//                           _info("Address", worker!['address']),
//                           _info("Status", worker!['verifyStatus']),
//                           _info(
//                             "Created At",
//                             worker!['createdAt'].toString().substring(0, 10),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

import 'dart:convert';

import 'package:developer/directHiring/views/comm/view_images_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';

class ViewWorkerScreen extends StatefulWidget {
  final String workerId;
  const ViewWorkerScreen({super.key, required this.workerId});

  @override
  State<ViewWorkerScreen> createState() => _ViewWorkerScreenState();
}

class _ViewWorkerScreenState extends State<ViewWorkerScreen> {
  Map<String, dynamic>? worker;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('ViewWorkerScreen initialized with workerId: ${widget.workerId}');
    fetchWorkerDetail();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchWorkerDetail() async {
    final token = await getToken();
    if (token == null) {
      print("❌ Token not found in local storage");
      setState(() => isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final url = Uri.parse(
      'https://api.thebharatworks.com/api/worker/get/${widget.workerId}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch worker detail response: ${response.body}');
      print('Fetch worker detail statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            worker = data['worker'];
            isLoading = false;
          });
        } else {
          print("❌ API error: ${data['message']}");
          setState(() => isLoading = false);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("API error: ${data['message']}")),
          );
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        setState(() => isLoading = false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('❌ Error fetching worker detail: $e');
      setState(() => isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching worker: $e")));
    }
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.roboto(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
    worker != null &&
        worker!['image'] != null &&
        worker!['image'].isNotEmpty
        ? worker!['image'].startsWith('http')
        ? worker!['image'].replaceFirst('http://', 'https://')
        : 'https://api.thebharatworks.com${worker!['image']}'
        : 'https://api.thebharatworks.com/uploads/worker/default.jpg';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("View Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : worker == null
          ? const Center(child: Text("Worker not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // Only navigate if image is not default
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewImage(imageUrl: imageUrl,title: "Profile",),
                      ),
                    );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.shade700, // Green border color
                      width: 3.0, // Border width
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(imageUrl),
                    onBackgroundImageError: (error, stackTrace) {
                      print('Error loading worker image: $error');
                    },
                    child:
                    imageUrl.contains('default.jpg')
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _info("Name", worker!['name'] ?? 'N/A'),
                  _info("Phone", worker!['phone'] ?? 'N/A'),
                  _info(
                    "DOB",
                    worker!['dob'] != null
                        ? worker!['dob'].toString().substring(0, 10)
                        : 'N/A',
                  ),
                  _info("Address", worker!['address'] ?? 'N/A'),
                  _info("Status", worker!['verifyStatus'] ?? 'N/A'),
                  _info(
                    "Created At",
                    worker!['createdAt'] != null
                        ? worker!['createdAt'].toString().substring(
                      0,
                      10,
                    )
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}