//
//
// import 'dart:convert';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../Widgets/AppColors.dart';
// import 'WorkerListViewProfileScreen.dart'; // Worker profile wala screen
//
// // Worker ka Model
// class ServiceWorkerListModel {
//   final String id;
//   final String name;
//   final String location;
//   final String image;
//   final String date;
//
//   ServiceWorkerListModel({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.image,
//     required this.date,
//   });
//
//   factory ServiceWorkerListModel.fromJson(Map<String, dynamic> json) {
//     final rawImage = json['image'] ?? '';
//     final fullImageUrl =
//     rawImage.startsWith('http')
//         ? rawImage.replaceFirst('http://', 'https://')
//         : 'https://via.placeholder.com/150'; // Default image agar nahi mila
//     print('Bhai, ${json['name']} ka image URL: $fullImageUrl');
//
//     return ServiceWorkerListModel(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       location: json['address'] ?? 'Unknown',
//       image: fullImageUrl,
//       date: json['dob']?.split("T")[0] ?? '',
//     );
//   }
// }
//
// // Screen
// class ServiceWorkerListScreen extends StatefulWidget {
//   final String orderId; // Dynamic order ID yaha se aayega
//
//   const ServiceWorkerListScreen({Key? key, required this.orderId})
//       : super(key: key);
//
//   @override
//   _ServiceWorkerListScreenState createState() =>
//       _ServiceWorkerListScreenState();
// }
//
// class _ServiceWorkerListScreenState extends State<ServiceWorkerListScreen> {
//   List<ServiceWorkerListModel> workers = [];
//   bool isLoading = true;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     PaintingBinding.instance.imageCache.clear(); // Image cache saaf karo
//     fetchWorkers();
//   }
//
//   Future<void> fetchWorkers() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     print("🟢 Token mil gaya: $token");
//
//     final url = Uri.parse("https://api.thebharatworks.com/api/worker/all");
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );
//
//       print("📥 Status: ${response.statusCode}");
//       print("📥 Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List workerList = data['workers'];
//         setState(() {
//           workers =
//               workerList
//                   .map((e) => ServiceWorkerListModel.fromJson(e))
//                   .toList();
//           isLoading = false;
//         });
//       } else if (response.statusCode == 401) {
//         final responseData = json.decode(response.body);
//         if (responseData['expired'] == true) {
//           await prefs.remove("auth_token");
//           setState(() {
//
//             errorMessage = "session expire. Login first!";
//
//             isLoading = false;
//           });
//           Future.delayed(Duration(seconds: 2), () {
//             Navigator.pushReplacementNamed(context, '/login');
//           });
//           return;
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//           errorMessage =
//               json.decode(response.body)['message'] ??
//                   'Workers fetch nahi huye!';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Error aa gaya: ${e.toString()}';
//       });
//     }
//   }
//
//   Future<void> assignOrderToWorker(String workerId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     final url = Uri.parse(
//       "https://api.thebharatworks.com/api/worker/assign-order",
//     );
//
//     final body = {
//       "worker_id": workerId,
//       "order_id": widget.orderId,
//       "type": "direct",
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(body),
//       );
//
//       print("📤 Assign Status: ${response.statusCode}");
//       print("📤 Assign Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("✅ Worker assign ")));
//       } else {
//         final data = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("❌ ${data['message'] ?? 'Assignment fail ho gaya!'}"),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("❌ Error: ${e.toString()}")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 InkWell(
//                   onTap: () => Navigator.pop(context),
//                   child: Icon(Icons.arrow_back, color: Colors.black),
//                 ),
//                 SizedBox(width: 100),
//                 Text(
//                   'Worker List',
//                   style: GoogleFonts.roboto(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Worker List
//           Expanded(
//             child:
//             isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : errorMessage != null
//                 ? Center(child: Text(errorMessage!))
//                 : ListView.builder(
//               padding: EdgeInsets.all(8.0),
//               itemCount: workers.length,
//               itemBuilder: (context, index) {
//                 final worker = workers[index];
//                 return Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   margin: EdgeInsets.symmetric(vertical: 8.0),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Image
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: Colors.orange[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: CachedNetworkImage(
//                               imageUrl: worker.image,
//                               fit: BoxFit.cover,
//                               placeholder:
//                                   (context, url) =>
//                                   CircularProgressIndicator(),
//                               errorWidget: (context, url, error) {
//                                 print(
//                                   'Image load error for ${worker.image}: $error',
//                                 );
//                                 return Icon(
//                                   Icons.person,
//                                   size: 40,
//                                   color: Colors.grey,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         // Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 worker.name,
//                                 style: GoogleFonts.roboto(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               SizedBox(height: 6),
//                               Text(
//                                 worker.location,
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               SizedBox(height: 6),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   borderRadius: BorderRadius.circular(
//                                     11,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   worker.date,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Buttons
//                         Column(
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (context) =>
//                                         WorkerListViewProfileScreen(
//                                           workerId: worker.id,
//                                         ),
//                                   ),
//                                 );
//                               },
//                               child: Text(
//                                 'View',
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             InkWell(
//                               onTap: () {
//                                 if (widget.orderId.isEmpty) {
//                                   ScaffoldMessenger.of(
//                                     context,
//                                   ).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         "❌ Order ID nahi hai, bhai!",
//                                       ),
//                                     ),
//                                   );
//                                   return;
//                                 }
//                                 assignOrderToWorker(worker.id);
//                               },
//                               child: Container(
//                                 height: 27,
//                                 width: 70,
//                                 decoration: BoxDecoration(
//                                   color: Colors.green.shade700,
//                                   borderRadius: BorderRadius.circular(
//                                     8,
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     'Assign',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // GetX import kiya
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../Emergency/Service_Provider/controllers/sp_work_detail_controller.dart';
import 'AddWorkerScreen.dart';
import 'WorkerListViewProfileScreen.dart'; // Worker profile wala screen

// Worker ka Model
class ServiceWorkerListModel {
  final String id;
  final String name;
  final String location;
  final String image;
  final String date;

  ServiceWorkerListModel({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.date,
  });

  factory ServiceWorkerListModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? '';
    final fullImageUrl = rawImage.startsWith('http')
        ? rawImage.replaceFirst('http://', 'https://')
        : 'https://via.placeholder.com/150'; // Default image agar nahi mila
    print('Bhai, ${json['name']} ka image URL: $fullImageUrl');

    return ServiceWorkerListModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['address'] ?? 'Unknown',
      image: fullImageUrl,
      date: json['dob']?.split("T")[0] ?? '',
    );
  }
}

// Screen
class ServiceWorkerListScreen extends StatefulWidget {
  final String orderId;
final String? callType;
  const ServiceWorkerListScreen({Key? key, required this.orderId, this.callType})
      : super(key: key);

  @override
  _ServiceWorkerListScreenState createState() =>
      _ServiceWorkerListScreenState();
}

class _ServiceWorkerListScreenState extends State<ServiceWorkerListScreen> {
  List<ServiceWorkerListModel> workers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
bwDebug("orderId: ${widget.orderId}, call type: ${widget.callType}");
    super.initState();
    PaintingBinding.instance.imageCache.clear();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("🟢 Token mil gaya: $token");

    final url = Uri.parse("https://api.thebharatworks.com/api/worker/all");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List workerList = data['workers'];
        setState(() {
          workers = workerList
              .map((e) => ServiceWorkerListModel.fromJson(e))
              .toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        if (responseData['expired'] == true) {
          await prefs.remove("auth_token");
          setState(() {
            errorMessage = "Session expired. Please login again!";
            isLoading = false;
          });
          Get.snackbar(
            "Session Expired",
            errorMessage!,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            borderRadius: 8,
            duration: Duration(seconds: 2),
          );
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return;
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = json.decode(response.body)['message'] ??
              'Workers fetch nahi huye!';
        });
        Get.snackbar(
          "Error",
          errorMessage!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error aa gaya: ${e.toString()}';
      });
      Get.snackbar(
        "Error",
        errorMessage!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
      );
    }
  }

  Future<void> assignOrderToWorker(String workerId) async {
    bwDebug("[assignOrderToWorker],  WorkerId: $workerId, orderId: ${widget.orderId}, type: ${widget.callType}");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(
      "https://api.thebharatworks.com/api/worker/assign-order",
    );

    final body = {
      "worker_id": workerId,
      "order_id": widget.orderId,
      "type": widget.callType??"direct",
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("📤 Assign Status: ${response.statusCode}");
      print("📤 Assign Body: ${response.body}");

      if (response.statusCode == 200) {
      var  controller = Get.find<SpWorkDetailController>();
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Worker assigned successfully';
        Get.snackbar(
          "Success",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
          duration: Duration(seconds: 2),
        );

        if (message == "Worker assigned successfully") {
          Future.delayed(Duration(seconds: 2), () {
            Get.back(); // Back navigate karo
          });
        }
await controller.getEmergencyOrder(widget.orderId);
        Navigator.pop(context);
      } else {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Assignment fail ho gaya!';
        Get.snackbar(
          "Error",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: /*AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),*/
      AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Worker List",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        leading: const BackButton(color: Colors.black),
        actions: [
          Padding(
            padding:  EdgeInsets.only(right: 0.04.toWidthPercent()),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWorkerScreen()),
                );
                if (result == true) {
                  fetchWorkers();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Worker added successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 0.05.toWidthPercent(),horizontal: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.015.toWidthPercent())),

                  color: AppColors.primaryGreen,
                  child: Center(
                    child: Icon(Icons.add,color: Colors.white,size: 0.05.toWidthPercent(),),
                  ),
                  ),
                  Text(
                    "Add Worker",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 0.035.toWidthPercent()),
                  ),
                ],
              ),
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
         /* Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
                SizedBox(width: 100),
                Text(
                  'Worker List',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),*/

          // Worker List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: workers.length,
                        itemBuilder: (context, index) {
                          final worker = workers[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: worker.image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) {
                                          print(
                                            'Image load error for ${worker.image}: $error',
                                          );
                                          return Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker.name,
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          worker.location,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(11),
                                          ),
                                          child: Text(
                                            worker.date,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Buttons
                                  Column(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WorkerListViewProfileScreen(
                                                workerId: worker.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'View',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      InkWell(
                                        onTap: () {
                                          if (widget.orderId.isEmpty) {
                                            Get.snackbar(
                                              "Error",
                                              "Order ID nahi hai, bhai!",
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                              margin: EdgeInsets.all(10),
                                              borderRadius: 8,
                                            );
                                            return;
                                          }
                                          assignOrderToWorker(worker.id);
                                        },
                                        child: Container(
                                          height: 27,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade700,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Assign',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
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
      ),
    );
  }
}
