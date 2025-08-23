// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'PaymentSuccessScreen.dart';
//
// class RazorpayScreen extends StatefulWidget {
//   final String razorpayOrderId;
//   final providerId;
//   final int amount; // e.g. ₹250 = 25000
//   final categreyId;
//   final subcategreyId;
//   final form;
//
//   const RazorpayScreen({
//     super.key,
//     required this.razorpayOrderId,
//     required this.amount,
//     this.categreyId,
//     this.subcategreyId, this.providerId,
//   });
//
//   @override
//   State<RazorpayScreen> createState() => _RazorpayScreenState();
// }
//
// class _RazorpayScreenState extends State<RazorpayScreen> {
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     _openCheckout();
//   }
//
//   void _openCheckout() {
//     var options = {
//       'key': 'rzp_test_0MfRVH2Hq6cqgy',
//       'amount': widget.amount,
//       'name': 'The Bharat Works',
//       'description': 'Platform Fee',
//       'order_id': widget.razorpayOrderId,
//       'prefill': {'contact': '9876543210', 'email': 'example@email.com'},
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('🛑 Razorpay open error: $e');
//     }
//   }
//
//   void _handleSuccess(PaymentSuccessResponse response) async {
//     print("✅ Payment Success:");
//     print("Order ID: ${widget.razorpayOrderId}");
//     print("Payment ID: ${response.paymentId}");
//     print("Signature: ${response.signature}");
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("❌ User not logged in")));
//         return;
//       }
//
//       final res = await http.post(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/verify-platform-payment',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           "razorpay_order_id": widget.razorpayOrderId,
//           "razorpay_payment_id": response.paymentId,
//           "razorpay_signature": response.signature,
//         }),
//       );
//
//       final decoded = jsonDecode(res.body);
//       print("📦 Verify API response: $decoded");
//
//       if (res.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => PaymentSuccessScreen(
//                   categreyId: widget.categreyId,
//                   subcategreyId: widget.subcategreyId,
//                   providerId: widget.providerId,
//                 ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("❌ Verification Failed: ${decoded['message']}"),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       print("❌ Verification Error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Error verifying payment")));
//       Navigator.pop(context);
//     }
//   }
//
//   void _handleError(PaymentFailureResponse response) {
//     print("❌ Payment Failed: ${response.message}");
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("❌ Payment Failed")));
//     Navigator.pop(context);
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("📲 External Wallet: ${response.walletName}");
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("Wallet: ${response.walletName}")));
//     Navigator.pop(context);
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("Abhi:-fast provider id razerpay screen:- ${widget.providerId}");
//     print(
//       "Abhi:- razorpay screen get categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
//     );
//     return const Scaffold(
//       body: Center(
//         child: Text("🔁 Opening Razorpay...", style: TextStyle(fontSize: 18)),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:developer/Emergency/User/controllers/emergency_service_controller.dart';
import 'package:developer/Emergency/User/controllers/work_detail_controller.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PaymentSuccessScreen.dart';

class RazorpayScreen extends StatefulWidget {
  final String razorpayOrderId;
  final providerId;
  final  amount; // e.g. ₹250 = 25000
  final categreyId;
  final subcategreyId;
  final String? from;
  final int?enteredAmount;
  final int? taxAmount;
  final String? description;
  final String? orderId;

  const RazorpayScreen({
    super.key,
    required this.razorpayOrderId,
    required this.amount,
    this.categreyId,
    this.subcategreyId,
    this.providerId,
    this.from,
    this.enteredAmount,
    this.taxAmount,
    this.description,
    this.orderId,
  });

  @override
  State<RazorpayScreen> createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    bwDebug("\nrazorpayOrderId: ${widget.razorpayOrderId}.\n providerId: ${widget.providerId}, \namount: ${widget.amount}, \n from: ${widget.from},"
        " \n enteredAmount: ${widget.enteredAmount}, \n taxAmount: ${widget.taxAmount}, \n description: ${widget.description},orderId: ${widget.orderId} ");
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _openCheckout();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_R7z5O0bqmRXuiH',
      'amount': widget.amount,
      'name': 'The Bharat Works',
      'description': 'Platform Fee',
      // 'order_id': widget.razorpayOrderId,
      'prefill': {'contact': '9876543210', 'email': 'example@email.com'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('🛑 Razorpay open error: $e');
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    print("✅ Payment Success:");
    print("Order ID: ${widget.razorpayOrderId}");
    print("Payment ID: ${response.paymentId}");
    print("Signature: ${response.signature}");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final razorpayOrderId=widget.razorpayOrderId;
    final razorPayPaymentId=response.paymentId;
    final razorpaySignatureId=response.signature;
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ User not logged in")));
      return;
    }
    if(widget.from =="Emergency"){

      EmergencyServiceController().paymentProcess(context,token,razorpayOrderId: razorpayOrderId,razorPayPaymentId: razorPayPaymentId,razorpaySignatureId: razorpaySignatureId,);
    }else if(widget.from =="emergencyWorkDetail"){

      final workDetailController = Get.find<WorkDetailController>();
      workDetailController.addPaymentStage(razorPayPaymentId: razorPayPaymentId,razorpaySignatureId: razorpaySignatureId,amount: widget.enteredAmount,tax: widget.taxAmount, description: widget. description, orderId:widget.orderId!);
      Navigator.pop(context);
    }
    else
    {
      try {
        final res = await http.post(
          Uri.parse(
            'https://api.thebharatworks.com/api/direct-order/verify-platform-payment',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "razorpay_order_id": razorpayOrderId,
            "razorpay_payment_id": razorPayPaymentId,
            "razorpay_signature": razorpaySignatureId,
          }),
        );

        final decoded = jsonDecode(res.body);
        print("📦 Verify API response: $decoded");

        if (res.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                categreyId: widget.categreyId,
                subcategreyId: widget.subcategreyId,
                providerId: widget.providerId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Verification Failed: ${decoded['message']}"),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print("❌ Verification Error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            const SnackBar(content: Text("Error verifying payment")));
        Navigator.pop(context);
      }
    }
  }

  void _handleError(PaymentFailureResponse response) {
    print("❌ Payment Failed: ${response.message}");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("❌ Payment Failed")));
    Navigator.pop(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("📲 External Wallet: ${response.walletName}");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Wallet: ${response.walletName}")));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:-fast provider id razerpay screen:- ${widget.providerId}");
    print(
      "Abhi:- razorpay screen get categreyId ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}",
    );
    return const Scaffold(
      body: Center(
        child: Text("🔁 Opening Razorpay...", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

