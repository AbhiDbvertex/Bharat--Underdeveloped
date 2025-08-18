//
// import 'dart:async';
//
// import 'package:developer/views/User/user_feedback.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../Widgets/Bottombar.dart';
// import '../User/MyHireScreen.dart';
//
// class PaymentSuccessScreen extends StatefulWidget {
//   final String? categreyId;
//   final String? subcategreyId;
//   final String? providerId;
//   const PaymentSuccessScreen({super.key, this.categreyId, this.subcategreyId, this.providerId});
//
//   @override
//   State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
// }
//
// class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
//   Timer? _navigationTimer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ⏳ Set up a timer for 3 seconds to navigate to Bottombar
//     _navigationTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const Bottombar(initialIndex: 1),
//           ),
//               (Route<dynamic> route) => false, // Remove all previous routes
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     // Cancel the timer when the widget is disposed
//     _navigationTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//       "Abhi:- paymentScreen screen get categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
//     );
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
//               ElevatedButton(
//                 onPressed: () {
//                   // Cancel the timer when user navigates to feedback screen
//                   _navigationTimer?.cancel();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => UserFeedback(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade700,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 102,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   "Share Feedback",
//                   style: GoogleFonts.roboto(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Widgets/Bottombar.dart';
import '../User/MyHireScreen.dart';
import '../User/user_feedback.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? categreyId;
  final String? subcategreyId;
  final String? providerId;
  final String? from;
  const PaymentSuccessScreen({super.key, this.categreyId, this.subcategreyId, this.providerId,this.from});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // ⏳ Set up a timer for 3 seconds to navigate to Bottombar
    _navigationTimer = Timer(const Duration(seconds: 3), () {

      if (mounted) {

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => Bottombar(initialIndex: 1),
          ),
              (Route<dynamic> route) => false, // Remove all previous routes
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      "Abhi:- paymentScreen screen get categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
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
              ElevatedButton(
                onPressed: () {
                  // Cancel the timer when user navigates to feedback screen
                  _navigationTimer?.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserFeedback(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 102,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Share Feedback",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}