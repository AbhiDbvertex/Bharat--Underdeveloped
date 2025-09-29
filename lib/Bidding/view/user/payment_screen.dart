// import 'dart:convert';
// import 'package:developer/directHiring/views/User/user_feedback.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../../../directHiring/Consent/ApiEndpoint.dart';
// import '../../../directHiring/Consent/app_constants.dart';
// import '../../../directHiring/views/ServiceProvider/ServiceDisputeScreen.dart';
// class BiddingPaymentScreen extends StatefulWidget {
//   final String orderId;
//   final orderProviderId;
//   final List<dynamic>? paymentHistory;
//
//   const BiddingPaymentScreen({
//     super.key,
//     required this.orderId,
//     this.paymentHistory, this.orderProviderId,
//   });
//
//   @override
//   State<BiddingPaymentScreen> createState() => _BiddingPaymentScreenState();
// }
//
// class _BiddingPaymentScreenState extends State<BiddingPaymentScreen> {
//   bool _showForm = false;
//   String _description = '';
//   String _amount = '';
//   String _selectedPayment = 'cod';
//
//   final List<Map<String, String>> _payments = [];
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController(text: '');
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     // Razorpay initialize karo
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     loadPaymentsFromStorage();
//     // Payment history se data load karo, including _id aur method
//     if (widget.paymentHistory != null) {
//       setState(() {
//         _payments.addAll(widget.paymentHistory!.map((payment) => {
//           'description': payment['description']?.toString() ?? 'No description',
//           'amount': payment['amount']?.toString() ?? '0',
//           'status': payment['status']?.toString() ?? 'UNKNOWN',
//           'method': payment['method']?.toString() ?? 'cod',
//           '_id': payment['_id']?.toString() ?? '',
//         }));
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     _amountController.dispose();
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment failed: ${response.message}")),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("External wallet selected: ${response.walletName}")),
//     );
//   }
//
//   Future<String?> _getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_id'); // Assuming user_id is stored during login
//   }
//
//   Future<void> savePaymentsToStorage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = await _getUserId();
//     if (userId == null || userId.isEmpty) {
//       print("Abhi:- No user ID found, cannot save payments");
//       return;
//     }
//     String storageKey = 'user_${userId}_saved_payments';
//     List<String> paymentsJson = _payments.map((e) => jsonEncode(e)).toList();
//     await prefs.setStringList(storageKey, paymentsJson);
//     print("Abhi:- Payments saved for user $userId");
//   }
//
//   Future<void> loadPaymentsFromStorage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = await _getUserId();
//     if (userId == null || userId.isEmpty) {
//       print("Abhi:- No user ID found, cannot load payments");
//       return;
//     }
//     String storageKey = 'user_${userId}_saved_payments';
//     List<String>? paymentsJson = prefs.getStringList(storageKey);
//     if (paymentsJson != null) {
//       setState(() {
//         _payments.clear();
//         _payments.addAll(
//           paymentsJson.map((e) => Map<String, String>.from(jsonDecode(e))),
//         );
//         print("Abhi:- Loaded payments for user $userId: $_payments");
//       });
//     }
//   }
//
//   Future<void> marCompletebiddingHire() async {
//     print("Abhi:- darect cancelOder order id ${widget.orderId}");
//     final String url = '${AppConstants.baseUrl}${ApiEndpoint.biddingMarkComplete}';
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     print("Abhi:- Mark as Complete token: $token");
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "order_id": widget.orderId,
//         }),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- darecthire Mark as Complete success :- ${response.body}");
//         print("Abhi:- providerId get :- ${widget.orderProviderId}");
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>UserFeedback(providerId: widget.orderProviderId,oderId: widget.orderId,)));
//         // Navigator.pop(context);
//       } else {
//         print("Abhi:- else darect-hire Mark as Complete error :- ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- Exception Mark as Complete darect-hire : - $e");
//     }
//   }
//
//
//   String? _currentPaymentMethod;
//
//   Future<void> postPaymentRequest (payId) async{
//     // final String url = 'https://api.thebharatworks.com/api/direct-order/user/request-release/${widget.orderId}/${payId}';
//     print("Abhi:- postPaymentRequest oderId: ${widget.orderId} payId: ${payId}");
//     final String url = 'https://api.thebharatworks.com/api/bidding-order/user/request-release/${widget.orderId}/${payId}';
//
//
//     print('Abhi:- postPaymentRequest oderId ${widget.orderId}');
//     print("Abhi:- postPaymentRequest url : $url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     print("Abhi:- Mark as Complete token: $token");
//
//     try{
//       var response = await http.post(Uri.parse(url), headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       );
//
//       var responseData = jsonDecode(response.body);
//       if(response.statusCode == 200 || response.statusCode == 201){
//         print("Abhi:- postPaymentRequest response : ${response.body}");
//         print("Abhi:- postPaymentRequest statuscode : ${response.statusCode}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("${responseData['message']}")),
//         );
//       }else{
//         print("Abhi:- else postPaymentRequest response : ${response.body}");
//         print("Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
//       }
//     }catch(e){
//       print("Abhi:- postPaymentRequest Exception $e");
//     }
//   }
//
//   String toTitleCase(String? text) {
//     if (text == null || text.isEmpty) return '';
//     return text[0].toUpperCase() + text.substring(1);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("Abhi:- getOderId postPaymentRequest ${widget.orderId}");
//     print("Abhi:-  ${widget.orderId}");
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Payment",
//                 style: GoogleFonts.roboto(
//                   fontSize: 18,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (!_showForm)
//                 Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _showForm = true;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       "Create",
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           Card(
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (_showForm)
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: _descriptionController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Enter description',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                                   ),
//                                   onChanged: (value) => _description = value,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               SizedBox(
//                                 width: 100,
//                                 child: TextField(
//                                   controller: _amountController,
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                                   decoration: InputDecoration(
//                                     hintText: 'Enter amount',
//                                     prefixText: '₹',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                                   ),
//                                   onChanged: (value) => _amount = value,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Radio<String>(
//                                 value: 'cod',
//                                 groupValue: _selectedPayment,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedPayment = value!;
//                                   });
//                                 },
//                               ),
//                               const Text('Cod'),
//                               const SizedBox(width: 20),
//                               Radio<String>(
//                                 value: 'online',
//                                 groupValue: _selectedPayment,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedPayment = value!;
//                                   });
//                                 },
//                               ),
//                               const Text('Online'),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   _showPaymentDialog();
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green,
//                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   "Submit",
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               OutlinedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _showForm = false;
//                                     _descriptionController.clear();
//                                     _amountController.text = '';
//                                     _description = '';
//                                     _amount = '';
//                                   });
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Colors.green,
//                                   side: const BorderSide(color: Colors.green),
//                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   "Cancel",
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 14,
//                                     color: Colors.green.shade700,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (_payments.isNotEmpty) ...[
//                     ..._payments.asMap().entries.map((entry) {
//                       int i = entry.key;
//                       var payment = entry.value;
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: RichText(
//                                     text: TextSpan(
//                                       style: GoogleFonts.roboto(
//                                         fontSize: 14,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       children: [
//                                         TextSpan(text: "${i + 1}. ${toTitleCase(payment['description'])} "),
//                                         TextSpan(
//                                           text: " ${toTitleCase(payment['status'] ?? 'UNKNOWN')}",
//                                           style: TextStyle(color: Colors.green),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   "₹${payment['amount']}",
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 16,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 5),
//                                 payment['release_status'] == 'release' ? SizedBox() : GestureDetector(
//                                   onTap: () {
//                                     //  Payment ID aur method pass karo
//                                     //   makePayment(
//                                     //     payment['_id'] ?? '',
//                                     //     payment['amount'] ?? '0',
//                                     //    // payment['method'] ?? 'cod',
//                                     //   );
//                                     postPaymentRequest (payment['_id'] ?? '');
//                                     print("Abhi:- payment releaseId : ${payment['_id']}");
//                                   },
//                                   child: Container(
//                                     height: 26,
//                                     width: 40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.green,
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         "Pay",
//                                         style: GoogleFonts.roboto(
//                                           fontSize: 13,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ) ,
//                               ],
//                             ),
//                             const SizedBox(height: 10),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ] else
//                     const Padding(
//                       padding: EdgeInsets.all(12),
//                       child: Text(
//                         "No payments yet",
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.yellow.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Image.asset('assets/images/warning.png', height: 60),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Warning Message",
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   "Lorem ipsum dolor sit amet consectetur.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 14, color: Colors.black87),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ServiceDisputeScreen(
//                     flowType: 'bidding',
//                     orderId: widget.orderId,
//                   ),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               minimumSize: const Size.fromHeight(48),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               "Cancel Task and create dispute",
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: () {
//               marCompletebiddingHire();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               minimumSize: const Size.fromHeight(48),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               "Mark as complete",
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
//
//   void _showPaymentDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Confirmation"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset(
//                 "assets/images/paymentfonfirm.png",
//                 height: 90,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Confirmation",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Date",style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text("${DateFormat("dd/MM/yyyy").format(DateTime.now())}",style: TextStyle(fontWeight: FontWeight.w600),),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Time",style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text("${DateFormat("kk:mm").format(DateTime.now())}",style: TextStyle(fontWeight: FontWeight.w600)),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Amount",style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text("₹$_amount",style: TextStyle(fontWeight: FontWeight.w600)),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("GST (18%)",style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text("₹${(int.parse(_amount) * 0.18).toStringAsFixed(2)}",style: TextStyle(fontWeight: FontWeight.w600)),
//                 ],
//               ),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Total Amount",style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text("₹${(int.parse(_amount) * 1.18).toStringAsFixed(2)}",style: TextStyle(fontWeight: FontWeight.w600)),
//                 ],
//               ),
//               Divider(),
//               //Center(child: const Text("Do you want to proceed\n      with the payment?")),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 100,
//                     height: 35,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.green,
//                     ),
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         if (_description.isNotEmpty && _amount.isNotEmpty) {
//                           if (_selectedPayment == 'online') {
//                             // Razorpay ke liye logic
//                             int razorpayAmount = (int.parse(_amount) * 1.18 * 100).toInt(); // 18% GST add karke paise me convert
//                             var options = {
//                               'key': 'rzp_test_R7z5O0bqmRXuiH',
//                               'amount': razorpayAmount,
//                               'name': 'The Bharat Work',
//                               'description': 'Payment for order ${widget.orderId}',
//                               'prefill': {
//                                 'contact': '9876543210',
//                                 'email': 'test@gmail.com',
//                               },
//                               'external': {
//                                 'wallets': ['paytm']
//                               }
//                             };
//                             try {
//                               _razorpay.open(options);
//                             } catch (e) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text("Razorpay error: $e")),
//                               );
//                             }
//                           } else {
//                             // COD ke liye direct submitPayment call
//                             submitPayment();
//                           }
//                         }
//                       },
//                       child: const Text(
//                         "Pay",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 100,
//                     height: 35,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green),
//                     ),
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text(
//                         "Close",
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> submitPayment() async {
//     final url = Uri.parse(
//       // 'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
//       'https://api.thebharatworks.com/api/bidding-order/addPaymentStage/${widget.orderId}',
//     );
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Token not found")),
//       );
//       return;
//     }
//
//     int baseAmount = int.tryParse(_amount) ?? 0;
//     double gst = baseAmount * 0.18;
//     int totalAmount = (baseAmount * 1.18).toInt();
//
//     final payload = {
//       "tax": gst.toInt(),
//       "description": _description,
//       "amount": totalAmount,
//       "method": _selectedPayment,
//       "status": _selectedPayment == 'cod' ? "success" : "pending",
//       "collected_by": "Admin",
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(payload),
//       );
//       print("anjali Response Code: ${response.statusCode}");
//       print("anjali Response Body: ${response.body}");
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         // Null check aur service_payment key use karo
//         if (responseData['service_payment'] != null &&
//             responseData['service_payment']['payment_history'] != null) {
//           final paymentHistory = responseData['service_payment']['payment_history'];
//           final paymentId = paymentHistory.isNotEmpty
//               ? paymentHistory.last['_id']?.toString() ?? ''
//               : '';
//           setState(() {
//             _payments.add({
//               'description': _description,
//               'amount': totalAmount.toString(),
//               'status': _selectedPayment == 'cod' ? "success" : "pending",
//               'method': _selectedPayment,
//               '_id': paymentId,
//             });
//             _showForm = false;
//             _descriptionController.clear();
//             _amountController.text = '';
//             _description = '';
//             _amount = '';
//             _selectedPayment = 'cod';
//           });
//
//           await savePaymentsToStorage();
//           await loadPaymentsFromStorage();
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Payment stage added successfully")),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Invalid response structure")),
//           );
//         }
//       } else {
//         final responseData = jsonDecode(response.body);
//         String errorMessage = responseData['message'] ?? 'Payment failed';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("⚠️ Error occurred: $e"),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     final url = Uri.parse(
//       // 'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
//       'https://api.thebharatworks.com/api/bidding-order/addPaymentStage/${widget.orderId}',
//     );
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Token not found")),
//       );
//       return;
//     }
//
//     int baseAmount = int.tryParse(_amount) ?? 0;
//     double gst = baseAmount * 0.18;
//     int totalAmount = (baseAmount * 1.18).toInt();
//
//     final payload = {
//       "tax": gst.toInt(),
//       "description": _description,
//       "amount": baseAmount,
//       "method": _selectedPayment,
//       "status": "success",
//       "payment_id": response.paymentId,
//       "collected_by": "Admin",
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(payload),
//       );
//       print("anjali Response Code: ${response.statusCode}");
//       print("anjali Response Body: ${response.body}");
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         // Null check aur service_payment key use karo
//         if (responseData['service_payment'] != null &&
//             responseData['service_payment']['payment_history'] != null) {
//           final paymentHistory = responseData['service_payment']['payment_history'];
//           final paymentId = paymentHistory.isNotEmpty
//               ? paymentHistory.last['_id']?.toString() ?? ''
//               : '';
//           setState(() {
//             _payments.add({
//               'description': _description,
//               'amount': totalAmount.toString(),
//               'status': 'success',
//               'method': _selectedPayment,
//               '_id': paymentId,
//             });
//             _showForm = false;
//             _descriptionController.clear();
//             _amountController.text = '';
//             _description = '';
//             _amount = '';
//             _selectedPayment = 'cod';
//           });
//
//           await savePaymentsToStorage();
//           await loadPaymentsFromStorage();
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Payment completed successfully")),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Invalid response structure")),
//           );
//         }
//       } else {
//         final responseData = jsonDecode(response.body);
//         String errorMessage = responseData['message'] ?? 'Payment update failed';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//         print("Abhi:- payment screen get Exception ${responseData['message']}");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//       print("Abhi:- payment screen get Exception $e");
//     }
//   }
// }

import 'dart:convert';

import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/directHiring/views/User/user_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../directHiring/Consent/ApiEndpoint.dart';
import '../../../directHiring/Consent/app_constants.dart';
import '../../../directHiring/views/ServiceProvider/ServiceDisputeScreen.dart';
import '../../../utility/custom_snack_bar.dart';

class BiddingPaymentScreen extends StatefulWidget {
  final String orderId;
  final orderProviderId;
  final List<dynamic>? paymentHistory;

  const BiddingPaymentScreen({
    super.key,
    required this.orderId,
    this.paymentHistory,
    this.orderProviderId,
  });

  @override
  State<BiddingPaymentScreen> createState() => _BiddingPaymentScreenState();
}

class _BiddingPaymentScreenState extends State<BiddingPaymentScreen> {
  bool _showForm = false;
  String _description = '';
  String _amount = '';
  String _selectedPayment = 'cod';

  final List<Map<String, String>> _payments = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '');
  late Razorpay _razorpay;
  var isLoading = false;

  @override
  void initState() {
    bwDebug("[initsState] Order ID : ${widget.orderId}", tag: "Payment Screen");
    super.initState();
    // Razorpay initialize karo
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadPaymentsFromStorage();
    // Payment history se data load karo, including _id aur method
    if (widget.paymentHistory != null) {
      setState(() {
        _payments.addAll(widget.paymentHistory!.map((payment) => {
              'description':
                  payment['description']?.toString() ?? 'No description',
              'amount': payment['amount']?.toString() ?? '0',
              'status': payment['status']?.toString() ?? 'UNKNOWN',
              'method': payment['method']?.toString() ?? 'cod',
              '_id': payment['_id']?.toString() ?? '',
              'release_status': payment['release_status']?.toString() ?? ""
            }));
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomSnackBar.show(
        message: "Payment failed: ${response.message}",
        type: SnackBarType.error);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackBar.show(
        message: "External wallet selected: ${response.walletName}",
        type: SnackBarType.info);
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Assuming user_id is stored during login
  }

  Future<void> savePaymentsToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await _getUserId();
    if (userId == null || userId.isEmpty) {
      print("Abhi:- No user ID found, cannot save payments");
      return;
    }
    String storageKey = 'user_${userId}_saved_payments';
    List<String> paymentsJson = _payments.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(storageKey, paymentsJson);
    print("Abhi:- Payments saved for user $userId");
  }

  Future<void> loadPaymentsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await _getUserId();
    if (userId == null || userId.isEmpty) {
      print("Abhi:- No user ID found, cannot load payments");
      return;
    }
    String storageKey = 'user_${userId}_saved_payments';
    List<String>? paymentsJson = prefs.getStringList(storageKey);
    if (paymentsJson != null) {
      setState(() {
        _payments.clear();
        _payments.addAll(
          paymentsJson.map((e) => Map<String, String>.from(jsonDecode(e))),
        );
        print("Abhi:- Loaded payments for user $userId: $_payments");
      });
    }
  }

  Future<void> marCompletebiddingHire() async {
    print("Abhi:- darect cancelOder order id ${widget.orderId}");
    final String url =
        '${AppConstants.baseUrl}${ApiEndpoint.biddingMarkComplete}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- Mark as Complete token: $token");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": widget.orderId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- darecthire Mark as Complete success :- ${response.body}");
        print("Abhi:- providerId get :- ${widget.orderProviderId}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserFeedback(
                      providerId: widget.orderProviderId,
                      oderId: widget.orderId,
                      oderType: 'bidding',
                    )));
        // Navigator.pop(context);
        print(
            "Abhi:- getOderId tab mark as complete oderId : ${widget.orderId} , providerId : ${widget.orderProviderId}");
      } else {
        print(
            "Abhi:- else darect-hire Mark as Complete error :- ${response.body}");
      }
    } catch (e) {
      print("Abhi:- Exception Mark as Complete darect-hire : - $e");
    }
  }

  String? _currentPaymentMethod;

  Future<void> postPaymentRequest(payId) async {
    setState(() {
      isLoading = true;
    });
    print(
        "Abhi:- postPaymentRequest oderId: ${widget.orderId} payId: ${payId}");
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/user/request-release/${widget.orderId}/${payId}';

    print('Abhi:- postPaymentRequest oderId ${widget.orderId}');
    print("Abhi:- postPaymentRequest url : $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- Mark as Complete token: $token");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- postPaymentRequest response : ${response.body}");
        print("Abhi:- postPaymentRequest statuscode : ${response.statusCode}");

        CustomSnackBar.show(
            message: "${responseData['message']}", type: SnackBarType.success);
        Navigator.pop(context);
      } else {
        print("Abhi:- else postPaymentRequest response : ${response.body}");
        print(
            "Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
      }
    } catch (e) {
      print("Abhi:- postPaymentRequest Exception $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Abhi:- getOderId postPaymentRequest oderId : ${widget.orderId} , providerId : ${widget.orderProviderId}");
    // Validation for enabling/disabling the Submit button
    bool isFormValid = _description.isNotEmpty &&
        _amount.isNotEmpty &&
        int.tryParse(_amount) != null &&
        int.parse(_amount) > 0;

    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Payment",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_showForm)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showForm = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Create",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Card(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.green, blurRadius: 2)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showForm)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _description = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // FilteringTextInputFormatter.digitsOnly
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}$')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount',
                                    prefixText: '₹',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _amount = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'cod',
                                groupValue: _selectedPayment,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPayment = value!;
                                  });
                                },
                              ),
                              const Text('Cod'),
                              const SizedBox(width: 20),
                              Radio<String>(
                                value: 'online',
                                groupValue: _selectedPayment,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPayment = value!;
                                  });
                                },
                              ),
                              const Text('Online'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: isFormValid
                                    ? () {
                                        _showPaymentDialog();
                                      }
                                    : null, // Disable button if form is invalid
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isFormValid ? Colors.green : Colors.grey,
                                  // Change color based on validity
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Submit",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showForm = false;
                                    _descriptionController.clear();
                                    _amountController.text = '';
                                    _description = '';
                                    _amount = '';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (_payments.isNotEmpty) ...[
                    ..._payments.asMap().entries.map((entry) {
                      int i = entry.key;
                      var payment = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        child: Column(
                          children: [
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: RichText(
                            //         text: TextSpan(
                            //           style: GoogleFonts.roboto(
                            //             fontSize: 14,
                            //             color: Colors.black,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //           children: [
                            //             TextSpan(text: "${i + 1}. ${toTitleCase(payment['description'])} "),
                            //             TextSpan(
                            //               text: " ${toTitleCase(payment['status'] ?? 'UNKNOWN')}",
                            //               style: TextStyle(color: Colors.green),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //     Text(
                            //       "₹${payment['amount']}",
                            //       style: GoogleFonts.roboto(
                            //         fontSize: 16,
                            //         color: Colors.black,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //     const SizedBox(width: 5),
                            //
                            //     payment['release_status'] == 'release_requested'
                            //         ? SizedBox()
                            //         : GestureDetector(
                            //       onTap: isLoading==true?null:()async {
                            //        await postPaymentRequest(payment['_id'] ?? '');
                            //         print("Abhi:- payment releaseId : ${payment['_id']}");
                            //       },
                            //       child: Container(
                            //         height: 26,
                            //         width: 40,
                            //         decoration: BoxDecoration(
                            //           color: Colors.green,
                            //           borderRadius: BorderRadius.circular(5),
                            //         ),
                            //         child: Center(
                            //           child:Text(
                            //             "Pay",
                            //             style: GoogleFonts.roboto(
                            //               fontSize: 13,
                            //               color: Colors.white,
                            //               fontWeight: FontWeight.w500,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // text top se align hoga
                              children: [
                                // Description column
                                Text(
                                  "${i + 1}.",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  flex: 2, // jyada space description ko
                                  child: Text(
                                    "${toTitleCase(payment['description'])}",
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Status column
                                Expanded(
                                  flex: (2),
                                  child: Text(
                                    toTitleCase(payment['release_status'] ==
                                            "release_requested"
                                        ? "Requested"
                                        : payment['release_status'] ==
                                        "pending"
                                        ? "Pending":payment['release_status'] ??
                                            'Pending'
                                    ),
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      // color: getColor(payment['release_status']),
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                // Amount column
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "₹${payment['amount']}/-",
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Button column
                                Expanded(
                                  flex: 0,
                                  child: payment['release_status'] ==
                                              'release_requested' ||
                                          payment['release_status'] ==
                                              'released'
                                      ? const SizedBox(
                                          width: 36) // empty placeholder
                                      : GestureDetector(
                                          onTap: isLoading == true
                                              ? null
                                              : () async {
                                                  await postPaymentRequest(
                                                      payment['_id'] ?? '');
                                                  print(
                                                      "Abhi:- payment releaseId : ${payment['_id']}");
                                                },
                                          child: Container(
                                            height: 26,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Pay",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    }).toList(),
                  ] else
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "No payments yet",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Image.asset('assets/images/warning.png', height: 60),
                const SizedBox(height: 8),
                const Text(
                  "Warning Message",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Make payments only through the app,\nit’s safer and more secure.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDisputeScreen(
                    flowType: 'bidding',
                    orderId: widget.orderId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Cancel Task and Create Dispute",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              marCompletebiddingHire();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Mark as Complete",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/paymentfonfirm.png",
                height: 90,
              ),
              const SizedBox(height: 8),
              const Text(
                "Confirmation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("${DateFormat("dd/MM/yyyy").format(DateTime.now())}",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Time", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("${DateFormat("kk:mm").format(DateTime.now())}",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("₹$_amount",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("GST (18%)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("₹${(int.parse(_amount) * 0.18).toStringAsFixed(2)}",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Amount",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("₹${(int.parse(_amount) * 1.18).toStringAsFixed(2)}",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (_description.isNotEmpty && _amount.isNotEmpty) {
                          if (_selectedPayment == 'online') {
                            int razorpayAmount =
                                (int.parse(_amount) * 1.18 * 100).toInt();
                            var options = {
                              'key': 'rzp_test_R7z5O0bqmRXuiH',
                              'amount': razorpayAmount,
                              'name': 'The Bharat Work',
                              'description':
                                  'Payment for order ${widget.orderId}',
                              'prefill': {
                                'contact': '9876543210',
                                'email': 'test@gmail.com',
                              },
                              'external': {
                                'wallets': ['paytm']
                              }
                            };
                            try {
                              _razorpay.open(options);
                            } catch (e) {
                              CustomSnackBar.show(
                                  message: "Razorpay error: $e",
                                  type: SnackBarType.error);
                            }
                          } else {
                            // COD ke liye direct submitPayment call
                            submitPayment();
                          }
                        }
                      },
                      child: const Text(
                        "Pay",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitPayment() async {
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/bidding-order/addPaymentStage/${widget.orderId}',
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      CustomSnackBar.show(
          message: "Token not found", type: SnackBarType.warning);

      return;
    }

    int baseAmount = int.tryParse(_amount) ?? 0;
    double gst = baseAmount * 0.18;
    int totalAmount = (baseAmount * 1.18).toInt();

    final payload = {
      "tax": gst.toInt(),
      "description": _description,
      "amount": totalAmount,
      "method": _selectedPayment,
      "status": _selectedPayment == 'cod' ? "success" : "pending",
      "collected_by": "Admin",
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      print("anjali Response Code: 1 ${response.statusCode}");
      print("anjali Response Body: 2 ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['service_payment'] != null &&
            responseData['service_payment']['payment_history'] != null) {
          final paymentHistory =
              responseData['service_payment']['payment_history'];
          final paymentId = paymentHistory.isNotEmpty
              ? paymentHistory.last['_id']?.toString() ?? ''
              : '';
          setState(() {
            _payments.add({
              'description': _description,
              'amount': totalAmount.toString(),
              'status': _selectedPayment == 'cod' ? "success" : "pending",
              'method': _selectedPayment,
              '_id': paymentId,
            });
            _showForm = false;
            _descriptionController.clear();
            _amountController.text = '';
            _description = '';
            _amount = '';
            _selectedPayment = 'cod';
          });

          await savePaymentsToStorage();
          await loadPaymentsFromStorage();

          CustomSnackBar.show(
              message: "Payment stage added successfully",
              type: SnackBarType.success);
        } else {
          CustomSnackBar.show(
              message: "Invalid response structure", type: SnackBarType.error);
        }
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? 'Payment failed';

        CustomSnackBar.show(message: errorMessage, type: SnackBarType.error);
      }
    } catch (e) {
      CustomSnackBar.show(
          message: "Error occurred: $e", type: SnackBarType.error);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    bwDebug("order Id : ${widget.orderId}");
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/bidding-order/addPaymentStage/${widget.orderId}',
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      CustomSnackBar.show(
          message: "Token not found", type: SnackBarType.warning);

      return;
    }

    int baseAmount = int.tryParse(_amount) ?? 0;
    double gst = baseAmount * 0.18;
    int totalAmount = (baseAmount * 1.18).toInt();

    final payload = {
      "tax": gst.toInt(),
      "description": _description,
      "amount": baseAmount,
      "method": _selectedPayment,
      "status": "success",
      "payment_id": response.paymentId,
      "collected_by": "Admin",
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      print("anjali Response Code: 3 ${response.statusCode}");
      print("anjali Response Body: 4 ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['service_payment'] != null &&
            responseData['service_payment']['payment_history'] != null) {
          final paymentHistory =
              responseData['service_payment']['payment_history'];
          final paymentId = paymentHistory.isNotEmpty
              ? paymentHistory.last['_id']?.toString() ?? ''
              : '';
          setState(() {
            _payments.add({
              'description': _description,
              'amount': totalAmount.toString(),
              'status': 'success',
              'method': _selectedPayment,
              '_id': paymentId,
            });
            _showForm = false;
            _descriptionController.clear();
            _amountController.text = '';
            _description = '';
            _amount = '';
            _selectedPayment = 'cod';
          });

          await savePaymentsToStorage();
          await loadPaymentsFromStorage();

          CustomSnackBar.show(
              message: "Payment completed successfully",
              type: SnackBarType.success);
        } else {
          CustomSnackBar.show(
              message: "Invalid response structure", type: SnackBarType.error);
        }
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Payment update failed';

        CustomSnackBar.show(message: errorMessage, type: SnackBarType.error);

        print("Abhi:- payment screen get Exception ${responseData['message']}");
      }
    } catch (e) {
      CustomSnackBar.show(message: "Error: $e", type: SnackBarType.error);

      print("Abhi:- payment screen get Exception $e");
    }
  }

//   getColor(String? payment) {
// switch (payment){
//   case 'pending':
//     return Colors.red;
//   case 'released':
//     return Colors.green;
//   case 'release_requested':
//     return Colors.yellow.shade700;
//   case 'refunded':
//     return Colors.blue;
//   default:
// }
//
//   }
}
