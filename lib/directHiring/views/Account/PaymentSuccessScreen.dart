//
// import 'dart:async';
// import 'dart:convert';
// import 'package:developer/Emergency/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../Widgets/Bottombar.dart';
// import '../User/DirecrViewScreen.dart';
// import '../User/MyHireScreen.dart';
// import '../User/user_feedback.dart';
//
// class PaymentSuccessScreen extends StatefulWidget {
//   final String? categreyId;
//   final String? subcategreyId;
//   final String? providerId;
//   final String? orderId;
//   final String? from;
//   final passIndex;
//
//   const PaymentSuccessScreen({super.key, this.categreyId, this.subcategreyId, this.providerId,this.orderId,this.from, this.passIndex});
//
//   @override
//   State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
// }
//
// class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
//   Timer? _navigationTimer;
//   String? directOrderId;
//
//   @override
//   void initState() {
//     getAllDarectorders ();
//     bwDebug(
//       "gadge: [initState]  categoryId: ${widget.categreyId} \n"
//           " subCategoryId : ${widget.subcategreyId}\n"
//           "providerId: ${widget.providerId}\n"
//           "orderId: ${widget.orderId}",tag: "PaymentSuccessScreen");
//
//     super.initState();
//
//     // ⏳ Set up a timer for 3 seconds to navigate to Bottombar
//     // _navigationTimer = Timer(const Duration(seconds: 3), () {
//     //   int count = 0;
//     //   if (mounted) {
//     //
//     //     // Navigator.pushAndRemoveUntil(
//     //     //   context,
//     //     //   MaterialPageRoute(
//     //     //     builder: (_) => MyHireScreen(passIndex: 1,) /*Bottombar(initialIndex: 1),*/
//     //     //   ),
//     //     //       (Route<dynamic> route) => false, // Remove all previous routes
//     //     // );
//     //     Navigator.of(context).popUntil((route) {
//     //       return count++ == 5;
//     //     });
//     //
//     //     Navigator.push(
//     //       context,
//     //       MaterialPageRoute(builder: (_) => DirectViewScreen(id: DarectOrderid,) /*MyHireScreen(passIndex: widget.passIndex,)*/),
//     //     );
//     //   }
//     // });
//
//   }
//
//   Future<void> getAllDarectorders() async {
//     const url = 'https://api.thebharatworks.com/api/direct-order/getOrdersByUser';
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       var responseData = jsonDecode(response.body);
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         List<dynamic> orders = responseData['data'] ?? [];
//
//         if (orders.isEmpty) {
//           print("Abhi:- No orders found");
//           return;
//         }
//
//         // ✅ sort by createdAt (latest first)
//         orders.sort((a, b) =>
//             DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
//
//         var latestOrderId = orders.first['_id'];
//
//         print("Latest Order ID: $latestOrderId");
//
//         setState(() {
//           directOrderId = latestOrderId;
//         });
//
//         // ✅ delay 3 sec, then navigate
//         // _navigationTimer = Timer(const Duration(seconds: 3), () {
//         //   if (!mounted) return;
//         //
//         //   Navigator.pushReplacement(
//         //     context,
//         //     MaterialPageRoute(
//         //       builder: (_) => DirectViewScreen(id: directOrderId ?? "",passIndex: widget.passIndex,), // send id here
//         //     ),
//         //   );
//         // });
//
//           int count = 0;
//           if (mounted) {
//             Navigator.of(context).popUntil((route) {
//               return count++ == 5;
//             });
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => DirectViewScreen(id: directOrderId ?? "",passIndex: widget.passIndex,),
//             ));
//           }
//       } else {
//         print("Abhi:- Error ${response.statusCode}: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- getAllDarectOrder Exception: $e");
//     }
//   }
//
//   /*Future<void> getAllDarectorders() async {
//     const url = 'https://api.thebharatworks.com/api/direct-order/getOrdersByUser';
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print("Abhi:- API URL: $url");
//       print("Abhi:- API Response: ${response.body}");
//
//       var responseData = jsonDecode(response.body);
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         List<dynamic> orders = responseData['data'] ?? [];
//
//         if (orders.isEmpty) {
//           print("Abhi:- No orders found");
//           return;
//         }
//
//         // sort orders by createdAt (latest first)
//         orders.sort((a, b) =>
//             DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
//
//         var latestOrder = orders.first; // sabse new order
//         var latestOrderId = latestOrder['_id'];
//
//         setState(() {
//           DarectOrderid = latestOrderId;
//         });
//
//         print("Latest Order ID: $latestOrderId");
//         print("Created At: ${latestOrder['createdAt']}");
//       } else {
//         print("Abhi:- Error ${response.statusCode}: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- getAllDarectOrder Exception: $e");
//     }
//   }*/
//
//   //   @override
//   // void dispose() {
//   //   // Cancel the timer when the widget is disposed
//   //   _navigationTimer?.cancel();
//   //   super.dispose();
//   // }
//
//   @override
//   void dispose() {
//     _navigationTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//       "Abhi:- paymentScreen screen get passIndex : ${widget.passIndex} categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.green,
//                 size: 100,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Payment Successful!",
//                 style: GoogleFonts.roboto(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Thank you for your payment! A confirmation has\nbeen sent to your registered email.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.roboto(
//                   fontSize: 14,
//                   color: Colors.grey.shade500,
//                 ),
//               ),
//               const SizedBox(height: 30),
//              Center(child: Text('Please wait 5 second',style: TextStyle(color: Colors.grey),),)
//               // ElevatedButton(
//               //   onPressed: () {
//               //     // // Cancel the timer when user navigates to feedback screen
//               //     // _navigationTimer?.cancel();
//               //     // Navigator.push(
//               //     //   context,
//               //     //   MaterialPageRoute(
//               //     //     builder: (context) => UserFeedback(providerId: widget.providerId , oderId:widget.orderId , oderType: 'direct',),
//               //     //   ),
//               //     // );
//               //   },
//               //   style: ElevatedButton.styleFrom(
//               //     backgroundColor: Colors.green.shade700,
//               //     padding: const EdgeInsets.symmetric(
//               //       horizontal: 102,
//               //       vertical: 12,
//               //     ),
//               //     shape: RoundedRectangleBorder(
//               //       borderRadius: BorderRadius.circular(10),
//               //     ),
//               //   ),
//               //   child: Text(
//               //     "Share Feedback",
//               //     style: GoogleFonts.roboto(
//               //       color: Colors.white,
//               //       fontWeight: FontWeight.w500,
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:developer/Emergency/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../Emergency/User/models/emergency_list_model.dart';
// import '../../../Emergency/User/screens/work_detail.dart';
// import '../../../Widgets/Bottombar.dart';
// import '../User/DirecrViewScreen.dart';
// import '../User/MyHireScreen.dart';
// import '../User/user_feedback.dart';
//
// class PaymentSuccessScreen extends StatefulWidget {
//   final String? categreyId;
//   final String? subcategreyId;
//   final String? providerId;
//   final String? orderId;
//   final String? from;
//   final passIndex;
//
//   const PaymentSuccessScreen({super.key, this.categreyId, this.subcategreyId, this.providerId,this.orderId,this.from, this.passIndex});
//
//   @override
//   State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
// }
//
// class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
//   Timer? _navigationTimer;
//   String? directOrderId;
//   String? emergencyOrderId;
//   EmergencyListModel? emergencyOrders;
//   String searchQuery = '';
//
//   // @override
//   // void initState() {
//   //   getAllDarectorders ();
//   //   bwDebug(
//   //       "gadge: [initState]  categoryId: ${widget.categreyId} \n"
//   //           " subCategoryId : ${widget.subcategreyId}\n"
//   //           "providerId: ${widget.providerId}\n"
//   //           "orderId: ${widget.orderId}",tag: "PaymentSuccessScreen");
//   //
//   //   super.initState();
//   //
//   //   // ⏳ Set up a timer for 3 seconds to navigate to Bottombar
//   //   // _navigationTimer = Timer(const Duration(seconds: 3), () {
//   //   //   int count = 0;
//   //   //   if (mounted) {
//   //   //
//   //   //     // Navigator.pushAndRemoveUntil(
//   //   //     //   context,
//   //   //     //   MaterialPageRoute(
//   //   //     //     builder: (_) => MyHireScreen(passIndex: 1,) /*Bottombar(initialIndex: 1),*/
//   //   //     //   ),
//   //   //     //       (Route<dynamic> route) => false, // Remove all previous routes
//   //   //     // );
//   //   //     Navigator.of(context).popUntil((route) {
//   //   //       return count++ == 5;
//   //   //     });
//   //   //
//   //   //     Navigator.push(
//   //   //       context,
//   //   //       MaterialPageRoute(builder: (_) => DirectViewScreen(id: DarectOrderid,) /*MyHireScreen(passIndex: widget.passIndex,)*/),
//   //   //     );
//   //   //   }
//   //   // });
//   //
//   // }
//
//   @override
//   void initState()  {
//     super.initState();
//
//     bwDebug(
//       "gadge: [initState]  categoryId: ${widget.categreyId} \n"
//           " subCategoryId : ${widget.subcategreyId}\n"
//           "providerId: ${widget.providerId}\n"
//           "orderId: ${widget.orderId}"
//       "from: ${widget.from}",
//       tag: "PaymentSuccessScreen",
//     );
//
//     // ✅ Navigation logic based on passIndex
//     if (widget.passIndex == 1) {
//       // 👉 Direct order
//       getAllDarectorders();
//     } else if (widget.passIndex == 2) {   //(3=> to 2) replace this index to navigate for the detail screen
//       // 👉 Emergency order
//       getAllEmergency();
//     } else {
//       // 👇 Default fallback (optional)
//       _navigationTimer = Timer(const Duration(seconds: 3), () {
//         if (mounted) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const Bottombar(initialIndex: 0)),
//                 (route) => false,
//           );
//         }
//       });
//     }
//   }
//
//
//   Future<void> getAllDarectorders() async {
//     const url = 'https://api.thebharatworks.com/api/direct-order/getOrdersByUser';
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       var responseData = jsonDecode(response.body);
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- get darecthiring response in payment : ${response.statusCode}");
//         print("Abhi:- get darecthiring response in payment : ${response.body}");
//         List<dynamic> orders = responseData['data'] ?? [];
//
//         if (orders.isEmpty) {
//           print("Abhi:- No orders found");
//           return;
//         }
//
//         // ✅ sort by createdAt (latest first)
//         orders.sort((a, b) =>
//             DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
//
//         var latestOrderId = orders.first['_id'];
//
//         print("Latest Order ID: $latestOrderId");
//
//         setState(() {
//           directOrderId = latestOrderId;
//         });
//
//         int count = 0;
//         if (mounted) {
//           Navigator.of(context).popUntil((route) {
//             return count++ == 5;
//           });
//           Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => DirectViewScreen(id: directOrderId ?? "",passIndex: widget.passIndex,),
//               ));
//         }
//       } else {
//         print("Abhi:- Error ${response.statusCode}: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- getAllDarectOrder Exception: $e");
//     }
//   }
//
//   Future<void> getAllEmergency() async {
//     // const url = 'https://api.thebharatworks.com/api/emergency-order/getAllEmergencyOrdersByRole';
//     //
//     // try {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final token = prefs.getString('token') ?? '';
//     //
//     //   final response = await http.get(
//     //     Uri.parse(url),
//     //     headers: {
//     //       'Authorization': 'Bearer $token',
//     //       'Content-Type': 'application/json',
//     //     },
//     //   );
//     //
//     //   var responseData = jsonDecode(response.body);
//     //
//     //   if (response.statusCode == 200 || response.statusCode == 201) {
//     //     print("Abhi:- get emergency response in payment : ${response.statusCode}");
//     //     print("Abhi:- get emergency response in payment : ${response.body}");
//     //     List<dynamic> orders = responseData['data'] ?? [];
//     //
//     //     if (orders.isEmpty) {
//     //       print("Abhi:- No orders found");
//     //       return;
//     //     }
//     //
//     //     // ✅ sort by createdAt (latest first)
//     //     orders.sort((a, b) =>
//     //         DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
//     //
//     //     var latestemergencyOrderId = orders.first['_id'];
//     //
//     //     print("Latest Order ID emergency: $latestemergencyOrderId");
//     //
//     //     setState(() {
//     //       emergencyOrderId = latestemergencyOrderId;
//     //     });
//     //     // List<dynamic> displayEmergency = emergencyOrders?.data ?? [];
//     //
//     //
//     //     int count = 0;
//     //     if (mounted) {
//     //       Navigator.of(context).popUntil((route) {
//     //         return count++ == 5;
//     //       });
//     bwDebug("get call emergency");
//           Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => WorkDetailPage(
//                 emergencyOrderId,
//               //  passIndex: widget.passIndex,
//                 isUser: true,
//               ),
//               ));
//     //     }
//     //   } else {
//     //     print("Abhi:- Error ${response.statusCode}: ${response.body}");
//     //   }
//     // } catch (e) {
//     //   print("Abhi:- getAllDarectOrder Exception: $e");
//     // }
//   }
//
//   @override
//   void dispose() {
//     _navigationTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//       "Abhi:- paymentScreen screen get passIndex : ${widget.passIndex} categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.green,
//                 size: 100,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Payment Successful!",
//                 style: GoogleFonts.roboto(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Thank you for your payment! A confirmation has\nbeen sent to your registered email.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.roboto(
//                   fontSize: 14,
//                   color: Colors.grey.shade500,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Center(child: Text('Please wait 5 second',style: TextStyle(color: Colors.grey),),)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Emergency/User/models/emergency_list_model.dart';
import '../../../Emergency/User/screens/work_detail.dart';
import '../../../Widgets/Bottombar.dart';
import '../User/DirecrViewScreen.dart';
import '../User/MyHireScreen.dart';
import '../User/user_feedback.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? categreyId;
  final String? subcategreyId;
  final String? providerId;
  final String? orderId;
  final String? from;
  final passIndex;

  const PaymentSuccessScreen({super.key, this.categreyId, this.subcategreyId, this.providerId,this.orderId,this.from, this.passIndex});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  Timer? _navigationTimer;
  String? directOrderId;
  String? emergencyOrderId;
  EmergencyListModel? emergencyOrders;
  String searchQuery = '';

  @override
  void initState()  {
    super.initState();

    bwDebug(
      "gadge: [initState]  categoryId: ${widget.categreyId} \n"
          " subCategoryId : ${widget.subcategreyId}\n"
          "providerId: ${widget.providerId}\n"
          "orderId: ${widget.orderId}"
          "from: ${widget.from}",
      tag: "PaymentSuccessScreen",
    );

    // ✅ Navigation logic based on passIndex – emergency ke liye direct orderId use
    if (widget.passIndex == 1) {
      // 👉 Direct order (same as before, working fine)
      getAllDarectorders();
    } else if (widget.passIndex == 2) {   // Emergency order – updated here
      // 👉 Emergency: Use passed orderId (no fetch needed)
      if (widget.orderId != null) {
        emergencyOrderId = widget.orderId;  // Direct set from passed data
        bwDebug("✅ Set emergencyOrderId: $emergencyOrderId", tag: "PaymentSuccessScreen");
      } else {
        bwDebug("❌ No orderId passed for emergency", tag: "PaymentSuccessScreen");
      }

      // ✅ Delay navigation to after build (fixes any potential errors)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToEmergencyDetail();  // Call delayed method
      });
    } else {
      // 👇 Default fallback (optional)
      _navigationTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Bottombar(initialIndex: 0)),
                (route) => false,
          );
        }
      });
    }
  }

  // ✅ New method for emergency navigation (delayed & safe)
  void _navigateToEmergencyDetail() {
    if (emergencyOrderId == null) {
      bwDebug("❌ No emergencyOrderId – fallback to bottombar", tag: "PaymentSuccessScreen");
      _fallbackToBottombar();
      return;
    }

    // Timer for 3 sec wait (as per UI text)
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Pop 3 routes: Success + Conf + old WorkDetail → back to list
        int count = 0;
        Navigator.of(context).popUntil((route) {
          return count++ == 3;  // Adjusted to 3 for emergency stack
        });
        // Push fresh WorkDetail with updated orderId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkDetailPage(
              emergencyOrderId,  // Non-null now
              passIndex: widget.passIndex,
              isUser: true,
            ),
          ),
        );
        bwDebug("✅ Navigated to Emergency WorkDetail: $emergencyOrderId", tag: "PaymentSuccessScreen");
      }
    });
  }

  // ✅ Fallback method
  void _fallbackToBottombar() {
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottombar(initialIndex: 0)),
              (route) => false,
        );
      }
    });
  }

  Future<void> getAllDarectorders() async {
    const url = 'https://api.thebharatworks.com/api/direct-order/getOrdersByUser';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- get darecthiring response in payment : ${response.statusCode}");
        print("Abhi:- get darecthiring response in payment : ${response.body}");
        List<dynamic> orders = responseData['data'] ?? [];

        if (orders.isEmpty) {
          print("Abhi:- No orders found");
          return;
        }

        // ✅ sort by createdAt (latest first)
        orders.sort((a, b) =>
            DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

        var latestOrderId = orders.first['_id'];

        print("Latest Order ID: $latestOrderId");

        if (mounted) {  // ✅ Safe setState after async
          setState(() {
            directOrderId = latestOrderId;
          });

          int count = 0;
          Navigator.of(context).popUntil((route) {
            return count++ == 5;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DirectViewScreen(id: directOrderId ?? "",passIndex: widget.passIndex,)),
          );
        }
      } else {
        print("Abhi:- Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- getAllDarectOrder Exception: $e");
    }
  }

  // ✅ Removed getAllEmergency() – no longer needed for emergency (use passed orderId)

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      "Abhi:- paymentScreen screen get passIndex : ${widget.passIndex} categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                "Payment Successful!",
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Thank you for your payment! A confirmation has\nbeen sent to your registered email.",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 30),
              const Center(child: Text('Please wait 3 seconds',style: TextStyle(color: Colors.grey),),)  // Updated to 3 sec
            ],
          ),
        ),
      ),
    );
  }
}