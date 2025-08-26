// // // import 'dart:convert';
// // // import 'package:developer/directHiring/views/User/user_feedback.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:intl/intl.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // //
// // // import '../../Consent/ApiEndpoint.dart';
// // // import '../../Consent/app_constants.dart';
// // // import '../ServiceProvider/ServiceDisputeScreen.dart';
// // //
// // // class PaymentScreen extends StatefulWidget {
// // //   final String orderId;
// // //   final orderProviderId;
// // //   final List<dynamic>? paymentHistory;
// // //
// // //   const PaymentScreen({
// // //     super.key,
// // //     required this.orderId,
// // //     this.paymentHistory, this.orderProviderId,
// // //   });
// // //
// // //   @override
// // //   State<PaymentScreen> createState() => _PaymentScreenState();
// // // }
// // //
// // // class _PaymentScreenState extends State<PaymentScreen> {
// // //   bool _showForm = false;
// // //   String _description = '';
// // //   String _amount = '';
// // //   String _selectedPayment = 'cod';
// // //
// // //   final List<Map<String, String>> _payments = [];
// // //   final TextEditingController _descriptionController = TextEditingController();
// // //   final TextEditingController _amountController = TextEditingController(text: '');
// // //   late Razorpay _razorpay;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     // Razorpay initialize karo
// // //     _razorpay = Razorpay();
// // //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// // //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// // //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// // //     loadPaymentsFromStorage();
// // //     // Payment history se data load karo, including _id aur method
// // //     if (widget.paymentHistory != null) {
// // //       setState(() {
// // //         _payments.addAll(widget.paymentHistory!.map((payment) => {
// // //           'description': payment['description']?.toString() ?? 'No description',
// // //           'amount': payment['amount']?.toString() ?? '0',
// // //           'status': payment['status']?.toString() ?? 'UNKNOWN',
// // //           'method': payment['method']?.toString() ?? 'cod',
// // //           '_id': payment['_id']?.toString() ?? '',
// // //         }));
// // //       });
// // //     }
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _descriptionController.dispose();
// // //     _amountController.dispose();
// // //     _razorpay.clear();
// // //     super.dispose();
// // //   }
// // //
// // //   // Razorpay ke callbacks
// // //   // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// // //   //   // Payment success hone par API call karo
// // //   //  // await _completePayment(response.paymentId, _currentPaymentId!, _currentPaymentMethod!);
// // //   // }
// // //
// // //   void _handlePaymentError(PaymentFailureResponse response) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text("Payment failed: ${response.message}")),
// // //     );
// // //   }
// // //
// // //   void _handleExternalWallet(ExternalWalletResponse response) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text("External wallet selected: ${response.walletName}")),
// // //     );
// // //   }
// // //
// // //   Future<String?> _getUserId() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     return prefs.getString('user_id'); // Assuming user_id is stored during login
// // //   }
// // //
// // //   Future<void> savePaymentsToStorage() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     String? userId = await _getUserId();
// // //     if (userId == null || userId.isEmpty) {
// // //       print("Abhi:- No user ID found, cannot save payments");
// // //       return;
// // //     }
// // //     String storageKey = 'user_${userId}_saved_payments';
// // //     List<String> paymentsJson = _payments.map((e) => jsonEncode(e)).toList();
// // //     await prefs.setStringList(storageKey, paymentsJson);
// // //     print("Abhi:- Payments saved for user $userId");
// // //   }
// // //
// // //   Future<void> loadPaymentsFromStorage() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     String? userId = await _getUserId();
// // //     if (userId == null || userId.isEmpty) {
// // //       print("Abhi:- No user ID found, cannot load payments");
// // //       return;
// // //     }
// // //     String storageKey = 'user_${userId}_saved_payments';
// // //     List<String>? paymentsJson = prefs.getStringList(storageKey);
// // //     if (paymentsJson != null) {
// // //       setState(() {
// // //         _payments.clear();
// // //         _payments.addAll(
// // //           paymentsJson.map((e) => Map<String, String>.from(jsonDecode(e))),
// // //         );
// // //         print("Abhi:- Loaded payments for user $userId: $_payments");
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> marCompleteDarectHire() async {
// // //     print("Abhi:- darect cancelOder order id ${widget.orderId}");
// // //     final String url = '${AppConstants.baseUrl}${ApiEndpoint.darectMarkComplete}';
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //     print("Abhi:- Mark as Complete token: $token");
// // //
// // //     try {
// // //       var response = await http.post(
// // //         Uri.parse(url),
// // //         headers: {
// // //           'Authorization': 'Bearer $token',
// // //           'Content-Type': 'application/json',
// // //         },
// // //         body: jsonEncode({
// // //           "order_id": widget.orderId,
// // //         }),
// // //       );
// // //
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         print("Abhi:- darecthire Mark as Complete success :- ${response.body}");
// // //         print("Abhi:- providerId get :- ${widget.orderProviderId}");
// // //         Navigator.push(context, MaterialPageRoute(builder: (context)=>UserFeedback(providerId: widget.orderProviderId,oderId: widget.orderId,)));
// // //         // Navigator.pop(context);
// // //       } else {
// // //         print("Abhi:- else darect-hire Mark as Complete error :- ${response.body}");
// // //       }
// // //     } catch (e) {
// // //       print("Abhi:- Exception Mark as Complete darect-hire : - $e");
// // //     }
// // //   }
// // //
// // //
// // //   String? _currentPaymentMethod;
// // //
// // //   Future<void> postPaymentRequest (payId) async{
// // //     final String url = 'https://api.thebharatworks.com/api/direct-order/user/request-release/${widget.orderId}/${payId}';
// // //     // final String url = 'https://api.thebharatworks.com/api/direct-order/user/request-release/6877ae8442c5eb3a0a8ff0eb/689064980de39e91960f54c7';
// // //
// // //     print('Abhi:- postPaymentRequest oderId ${widget.orderId}');
// // //     print("Abhi:- postPaymentRequest url : $url");
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //     print("Abhi:- Mark as Complete token: $token");
// // //
// // //     try{
// // //       var response = await http.post(Uri.parse(url), headers: {
// // //         'Authorization': 'Bearer $token',
// // //         'Content-Type': 'application/json',
// // //       },
// // //       );
// // //
// // //       var responseData = jsonDecode(response.body);
// // //       if(response.statusCode == 200 || response.statusCode == 201){
// // //         print("Abhi:- postPaymentRequest response : ${response.body}");
// // //         print("Abhi:- postPaymentRequest statuscode : ${response.statusCode}");
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text("${responseData['message']}")),
// // //         );
// // //       }else{
// // //         print("Abhi:- else postPaymentRequest response : ${response.body}");
// // //         print("Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
// // //       }
// // //     }catch(e){
// // //       print("Abhi:- postPaymentRequest Exception $e");
// // //     }
// // //
// // //   }
// // //
// // //   String toTitleCase(String? text) {
// // //     if (text == null || text.isEmpty) return '';
// // //     return text[0].toUpperCase() + text.substring(1);
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     print("Abhi:- getOderId postPaymentRequest ${widget.orderId}");
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.stretch,
// // //         children: [
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               Text(
// // //                 "Payment",
// // //                 style: GoogleFonts.roboto(
// // //                   fontSize: 18,
// // //                   color: Colors.black,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //               if (!_showForm)
// // //                 Padding(
// // //                   padding: const EdgeInsets.all(10),
// // //                   child: ElevatedButton(
// // //                     onPressed: () {
// // //                       setState(() {
// // //                         _showForm = true;
// // //                       });
// // //                     },
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: Colors.green,
// // //                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                     child: Text(
// // //                       "Create",
// // //                       style: GoogleFonts.roboto(
// // //                         fontSize: 14,
// // //                         color: Colors.white,
// // //                         fontWeight: FontWeight.w700,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //           Card(
// // //             child: Container(
// // //               width: double.infinity,
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(8),
// // //                 color: Colors.white,
// // //               ),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   if (_showForm)
// // //                     Container(
// // //                       padding: const EdgeInsets.all(10),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.white,
// // //                         borderRadius: BorderRadius.circular(12),
// // //                       ),
// // //                       child: Column(
// // //                         children: [
// // //                           Row(
// // //                             children: [
// // //                               Expanded(
// // //                                 child: TextField(
// // //                                   controller: _descriptionController,
// // //                                   decoration: InputDecoration(
// // //                                     hintText: 'Enter description',
// // //                                     border: OutlineInputBorder(
// // //                                       borderRadius: BorderRadius.circular(8),
// // //                                     ),
// // //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
// // //                                   ),
// // //                                   onChanged: (value) => _description = value,
// // //                                 ),
// // //                               ),
// // //                               const SizedBox(width: 10),
// // //                               SizedBox(
// // //                                 width: 100,
// // //                                 child: TextField(
// // //                                   controller: _amountController,
// // //                                   keyboardType: TextInputType.number,
// // //                                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// // //                                   decoration: InputDecoration(
// // //                                     hintText: 'Enter amount',
// // //                                     prefixText: '₹',
// // //                                     border: OutlineInputBorder(
// // //                                       borderRadius: BorderRadius.circular(8),
// // //                                     ),
// // //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
// // //                                   ),
// // //                                   onChanged: (value) => _amount = value,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           const SizedBox(height: 12),
// // //                           Row(
// // //                             children: [
// // //                               Radio<String>(
// // //                                 value: 'cod',
// // //                                 groupValue: _selectedPayment,
// // //                                 onChanged: (value) {
// // //                                   setState(() {
// // //                                     _selectedPayment = value!;
// // //                                   });
// // //                                 },
// // //                               ),
// // //                               const Text('Cod'),
// // //                               const SizedBox(width: 20),
// // //                               Radio<String>(
// // //                                 value: 'online',
// // //                                 groupValue: _selectedPayment,
// // //                                 onChanged: (value) {
// // //                                   setState(() {
// // //                                     _selectedPayment = value!;
// // //                                   });
// // //                                 },
// // //                               ),
// // //                               const Text('Online'),
// // //                             ],
// // //                           ),
// // //                           const SizedBox(height: 12),
// // //                           Row(
// // //                             mainAxisAlignment: MainAxisAlignment.center,
// // //                             children: [
// // //                               ElevatedButton(
// // //                                 onPressed: () {
// // //                                   _showPaymentDialog();
// // //                                 },
// // //                                 style: ElevatedButton.styleFrom(
// // //                                   backgroundColor: Colors.green,
// // //                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// // //                                   shape: RoundedRectangleBorder(
// // //                                     borderRadius: BorderRadius.circular(8),
// // //                                   ),
// // //                                 ),
// // //                                 child: Text(
// // //                                   "Submit",
// // //                                   style: GoogleFonts.roboto(
// // //                                     fontSize: 14,
// // //                                     color: Colors.white,
// // //                                     fontWeight: FontWeight.w700,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                               const SizedBox(width: 20),
// // //                               OutlinedButton(
// // //                                 onPressed: () {
// // //                                   setState(() {
// // //                                     _showForm = false;
// // //                                     _descriptionController.clear();
// // //                                     _amountController.text = '';
// // //                                     _description = '';
// // //                                     _amount = '';
// // //                                   });
// // //                                 },
// // //                                 style: OutlinedButton.styleFrom(
// // //                                   foregroundColor: Colors.green,
// // //                                   side: const BorderSide(color: Colors.green),
// // //                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// // //                                   shape: RoundedRectangleBorder(
// // //                                     borderRadius: BorderRadius.circular(8),
// // //                                   ),
// // //                                 ),
// // //                                 child: Text(
// // //                                   "Cancel",
// // //                                   style: GoogleFonts.roboto(
// // //                                     fontSize: 14,
// // //                                     color: Colors.green.shade700,
// // //                                     fontWeight: FontWeight.w700,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   if (_payments.isNotEmpty) ...[
// // //                     ..._payments.asMap().entries.map((entry) {
// // //                       int i = entry.key;
// // //                       var payment = entry.value;
// // //                       return Padding(
// // //                         padding: const EdgeInsets.all(8.0),
// // //                         child: Column(
// // //                           children: [
// // //                             Row(
// // //                               children: [
// // //                                 Expanded(
// // //                                   child: RichText(
// // //                                     text: TextSpan(
// // //                                       style: GoogleFonts.roboto(
// // //                                         fontSize: 14,
// // //                                         color: Colors.black,
// // //                                         fontWeight: FontWeight.w500,
// // //                                       ),
// // //                                       children: [
// // //                                         TextSpan(text: "${i + 1}. ${toTitleCase(payment['description'])} "),
// // //                                         TextSpan(
// // //                                           text: " ${toTitleCase(payment['status'] ?? 'UNKNOWN')}",
// // //                                           style: TextStyle(color: Colors.green),
// // //                                         ),
// // //                                       ],
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                                 Text(
// // //                                   "₹${payment['amount']}",
// // //                                   style: GoogleFonts.roboto(
// // //                                     fontSize: 16,
// // //                                     color: Colors.black,
// // //                                     fontWeight: FontWeight.w500,
// // //                                   ),
// // //                                 ),
// // //                                 const SizedBox(width: 5),
// // //                                 payment['release_status'] == 'release' ? SizedBox() : GestureDetector(
// // //                                   onTap: () {
// // //                                   //  Payment ID aur method pass karo
// // //                                   //   makePayment(
// // //                                   //     payment['_id'] ?? '',
// // //                                   //     payment['amount'] ?? '0',
// // //                                   //    // payment['method'] ?? 'cod',
// // //                                   //   );
// // //                                     postPaymentRequest (payment['_id'] ?? '');
// // //                                     print("Abhi:- payment releaseId : ${payment['_id']}");
// // //                                   },
// // //                                   child: Container(
// // //                                     height: 26,
// // //                                     width: 40,
// // //                                     decoration: BoxDecoration(
// // //                                       color: Colors.green,
// // //                                       borderRadius: BorderRadius.circular(5),
// // //                                     ),
// // //                                     child: Center(
// // //                                       child: Text(
// // //                                         "Pay",
// // //                                         style: GoogleFonts.roboto(
// // //                                           fontSize: 13,
// // //                                           color: Colors.white,
// // //                                           fontWeight: FontWeight.w500,
// // //                                         ),
// // //                                       ),
// // //                                     ),
// // //                                   ),
// // //                                 ) ,
// // //                               ],
// // //                             ),
// // //                             const SizedBox(height: 10),
// // //                           ],
// // //                         ),
// // //                       );
// // //                     }).toList(),
// // //                   ] else
// // //                     const Padding(
// // //                       padding: EdgeInsets.all(12),
// // //                       child: Text(
// // //                         "No payments yet",
// // //                         style: TextStyle(fontSize: 14, color: Colors.grey),
// // //                       ),
// // //                     ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 24),
// // //           Container(
// // //             padding: const EdgeInsets.all(12),
// // //             decoration: BoxDecoration(
// // //               color: Colors.yellow.shade100,
// // //               borderRadius: BorderRadius.circular(12),
// // //             ),
// // //             child: Column(
// // //               children: [
// // //                 Image.asset('assets/images/warning.png', height: 60),
// // //                 const SizedBox(height: 8),
// // //                 const Text(
// // //                   "Warning Message",
// // //                   style: TextStyle(
// // //                     color: Colors.red,
// // //                     fontSize: 16,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 4),
// // //                 const Text(
// // //                   "Lorem ipsum dolor sit amet consectetur.",
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(fontSize: 14, color: Colors.black87),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           const SizedBox(height: 24),
// // //           ElevatedButton(
// // //             onPressed: () {
// // //               Navigator.push(
// // //                 context,
// // //                 MaterialPageRoute(
// // //                   builder: (context) => ServiceDisputeScreen(
// // //                     flowType: 'direct',
// // //                     orderId: widget.orderId,
// // //                   ),
// // //                 ),
// // //               );
// // //             },
// // //             style: ElevatedButton.styleFrom(
// // //               backgroundColor: Colors.red,
// // //               minimumSize: const Size.fromHeight(48),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(8),
// // //               ),
// // //             ),
// // //             child: const Text(
// // //               "Cancel Task and create dispute",
// // //               style: TextStyle(color: Colors.white, fontSize: 16),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 12),
// // //           ElevatedButton(
// // //             onPressed: () {
// // //               marCompleteDarectHire();
// // //             },
// // //             style: ElevatedButton.styleFrom(
// // //               backgroundColor: Colors.green,
// // //               minimumSize: const Size.fromHeight(48),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(8),
// // //               ),
// // //             ),
// // //             child: const Text(
// // //               "Mark as complete",
// // //               style: TextStyle(color: Colors.white, fontSize: 16),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 24),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _showPaymentDialog() {
// // //     showDialog(
// // //       context: context,
// // //       builder: (BuildContext context) {
// // //         return AlertDialog(
// // //           title: const Text("Confirmation"),
// // //           content: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             crossAxisAlignment: CrossAxisAlignment.center,
// // //             children: [
// // //               Image.asset(
// // //                 "assets/images/paymentfonfirm.png",
// // //                 height: 90,
// // //               ),
// // //               const SizedBox(height: 8),
// // //               const Text(
// // //                 "Confirmation",
// // //                 style: TextStyle(
// // //                   fontWeight: FontWeight.bold,
// // //                   fontSize: 18,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 2),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text("Date",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                   Text("${DateFormat("dd/MM/yyyy").format(DateTime.now())}",style: TextStyle(fontWeight: FontWeight.w600),),
// // //                 ],
// // //               ),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text("Time",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                   Text("${DateFormat("kk:mm").format(DateTime.now())}",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                 ],
// // //               ),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text("Amount",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                   Text("₹$_amount",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                 ],
// // //               ),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text("GST (18%)",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                   Text("₹${(int.parse(_amount) * 0.18 ??0).toStringAsFixed(2)}",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                 ],
// // //               ),
// // //               Divider(),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text("Total Amount",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                   // Text("₹${(int.parse(_amount) * 1.18).toStringAsFixed(2)}",style: TextStyle(fontWeight: FontWeight.w600)),
// // //                   Text(
// // //                     "₹${((double.tryParse(_amount) ?? 0) * 0.18).toStringAsFixed(2)}",
// // //                     style: TextStyle(fontWeight: FontWeight.w600),
// // //                   ),
// // //                 ],
// // //               ),
// // //               Divider(),
// // //               //Center(child: const Text("Do you want to proceed\n      with the payment?")),
// // //               const SizedBox(height: 8),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Container(
// // //                     width: 100,
// // //                     height: 35,
// // //                     decoration: BoxDecoration(
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       color: Colors.green,
// // //                     ),
// // //                     child: TextButton(
// // //                       onPressed: () {
// // //                         Navigator.of(context).pop();
// // //                         if (_description.isNotEmpty && _amount.isNotEmpty) {
// // //                           if (_selectedPayment == 'online') {
// // //                             // Razorpay ke liye logic
// // //                             int razorpayAmount = (int.parse(_amount) * 1.18 * 100).toInt(); // 18% GST add karke paise me convert
// // //                             var options = {
// // //                               'key': 'rzp_test_R7z5O0bqmRXuiH',
// // //                               'amount': razorpayAmount,
// // //                               'name': 'The Bharat Work',
// // //                               'description': 'Payment for order ${widget.orderId}',
// // //                               'prefill': {
// // //                                 'contact': '9876543210',
// // //                                 'email': 'test@gmail.com',
// // //                               },
// // //                               'external': {
// // //                                 'wallets': ['paytm']
// // //                               }
// // //                             };
// // //                             try {
// // //                               _razorpay.open(options);
// // //                             } catch (e) {
// // //                               ScaffoldMessenger.of(context).showSnackBar(
// // //                                 SnackBar(content: Text("Razorpay error: $e")),
// // //                               );
// // //                             }
// // //                           } else {
// // //                             // COD ke liye direct submitPayment call
// // //                             submitPayment();
// // //                           }
// // //                         }
// // //                       },
// // //                       child: const Text(
// // //                         "Pay",
// // //                         style: TextStyle(color: Colors.white),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   Container(
// // //                     width: 100,
// // //                     height: 35,
// // //                     decoration: BoxDecoration(
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       border: Border.all(color: Colors.green),
// // //                     ),
// // //                     child: TextButton(
// // //                       onPressed: () {
// // //                         Navigator.of(context).pop();
// // //                       },
// // //                       child: const Text(
// // //                         "Close",
// // //                         style: TextStyle(color: Colors.black),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   Future<void> submitPayment() async {
// // //     final url = Uri.parse(
// // //       'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
// // //     );
// // //
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     String? token = prefs.getString('token');
// // //
// // //     if (token == null || token.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Token not found")),
// // //       );
// // //       return;
// // //     }
// // //
// // //     int baseAmount = int.tryParse(_amount) ?? 0;
// // //     double gst = baseAmount * 0.18;
// // //     int totalAmount = (baseAmount * 1.18).toInt();
// // //
// // //     final payload = {
// // //       "tax": gst.toInt(),
// // //       "description": _description,
// // //       "amount": totalAmount,
// // //       "method": _selectedPayment,
// // //       "status": _selectedPayment == 'cod' ? "success" : "pending",
// // //       "collected_by": "Admin",
// // //     };
// // //
// // //     try {
// // //       final response = await http.post(
// // //         url,
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer $token',
// // //         },
// // //         body: jsonEncode(payload),
// // //       );
// // //       print("anjali Response Code: ${response.statusCode}");
// // //       print("anjali Response Body: ${response.body}");
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         final responseData = jsonDecode(response.body);
// // //         // Null check aur service_payment key use karo
// // //         if (responseData['service_payment'] != null &&
// // //             responseData['service_payment']['payment_history'] != null) {
// // //           final paymentHistory = responseData['service_payment']['payment_history'];
// // //           final paymentId = paymentHistory.isNotEmpty
// // //               ? paymentHistory.last['_id']?.toString() ?? ''
// // //               : '';
// // //           setState(() {
// // //             _payments.add({
// // //               'description': _description,
// // //               'amount': totalAmount.toString(),
// // //               'status': _selectedPayment == 'cod' ? "success" : "pending",
// // //               'method': _selectedPayment,
// // //               '_id': paymentId,
// // //             });
// // //             _showForm = false;
// // //             _descriptionController.clear();
// // //             _amountController.text = '';
// // //             _description = '';
// // //             _amount = '';
// // //             _selectedPayment = 'cod';
// // //           });
// // //
// // //           await savePaymentsToStorage();
// // //           await loadPaymentsFromStorage();
// // //
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Payment stage added successfully")),
// // //           );
// // //         } else {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Invalid response structure")),
// // //           );
// // //         }
// // //       } else {
// // //         final responseData = jsonDecode(response.body);
// // //         String errorMessage = responseData['message'] ?? 'Payment failed';
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text(errorMessage),
// // //             duration: const Duration(seconds: 4),
// // //           ),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text("⚠️ Error occurred: $e"),
// // //           duration: const Duration(seconds: 3),
// // //         ),
// // //       );
// // //     }
// // //   }
// // //
// // //   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// // //     final url = Uri.parse(
// // //       'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
// // //     );
// // //
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     String? token = prefs.getString('token');
// // //
// // //     if (token == null || token.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Token not found")),
// // //       );
// // //       return;
// // //     }
// // //
// // //     int baseAmount = int.tryParse(_amount) ?? 0;
// // //     double gst = baseAmount * 0.18;
// // //     int totalAmount = (baseAmount * 1.18).toInt();
// // //
// // //     final payload = {
// // //       "tax": gst.toInt(),
// // //       "description": _description,
// // //       "amount": baseAmount,
// // //       "method": _selectedPayment,
// // //       "status": "success",
// // //       "payment_id": response.paymentId,
// // //       "collected_by": "Admin",
// // //     };
// // //
// // //     try {
// // //       final response = await http.post(
// // //         url,
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer $token',
// // //         },
// // //         body: jsonEncode(payload),
// // //       );
// // //       print("anjali Response Code: ${response.statusCode}");
// // //       print("anjali Response Body: ${response.body}");
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         final responseData = jsonDecode(response.body);
// // //         // Null check aur service_payment key use karo
// // //         if (responseData['service_payment'] != null &&
// // //             responseData['service_payment']['payment_history'] != null) {
// // //           final paymentHistory = responseData['service_payment']['payment_history'];
// // //           final paymentId = paymentHistory.isNotEmpty
// // //               ? paymentHistory.last['_id']?.toString() ?? ''
// // //               : '';
// // //           setState(() {
// // //             _payments.add({
// // //               'description': _description,
// // //               'amount': totalAmount.toString(),
// // //               'status': 'success',
// // //               'method': _selectedPayment,
// // //               '_id': paymentId,
// // //             });
// // //             _showForm = false;
// // //             _descriptionController.clear();
// // //             _amountController.text = '';
// // //             _description = '';
// // //             _amount = '';
// // //             _selectedPayment = 'cod';
// // //           });
// // //
// // //           await savePaymentsToStorage();
// // //           await loadPaymentsFromStorage();
// // //
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Payment completed successfully")),
// // //           );
// // //         } else {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Invalid response structure")),
// // //           );
// // //         }
// // //       } else {
// // //         final responseData = jsonDecode(response.body);
// // //         String errorMessage = responseData['message'] ?? 'Payment update failed';
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text(errorMessage)),
// // //         );
// // //         print("Abhi:- payment screen get Exception ${responseData['message']}");
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text("Error: $e")),
// // //       );
// // //       print("Abhi:- payment screen get Exception $e");
// // //     }
// // //   }
// // // }
// //
// // import 'dart:convert';
// // import 'package:developer/directHiring/views/User/user_feedback.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:intl/intl.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// //
// // import '../../Consent/ApiEndpoint.dart';
// // import '../../Consent/app_constants.dart';
// // import '../ServiceProvider/ServiceDisputeScreen.dart';
// //
// // class PaymentScreen extends StatefulWidget {
// //   final String orderId;
// //   final String? orderProviderId; // Updated to String? for clarity
// //   final List<dynamic>? paymentHistory;
// //
// //   const PaymentScreen({
// //     super.key,
// //     required this.orderId,
// //     this.paymentHistory,
// //     this.orderProviderId,
// //   });
// //
// //   @override
// //   State<PaymentScreen> createState() => _PaymentScreenState();
// // }
// //
// // class _PaymentScreenState extends State<PaymentScreen> {
// //   bool _showForm = false;
// //   String _description = '';
// //   String _amount = '';
// //   String _selectedPayment = 'cod';
// //
// //   final List<Map<String, String>> _payments = [];
// //   final TextEditingController _descriptionController = TextEditingController();
// //   final TextEditingController _amountController = TextEditingController(text: '');
// //   late Razorpay _razorpay;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize Razorpay
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //     loadPaymentsFromStorage();
// //     // Load payment history
// //     if (widget.paymentHistory != null) {
// //       setState(() {
// //         _payments.addAll(widget.paymentHistory!.map((payment) => {
// //           'description': payment['description']?.toString() ?? 'No description',
// //           'amount': payment['amount']?.toString() ?? '0',
// //           'status': payment['status']?.toString() ?? 'UNKNOWN',
// //           'method': payment['method']?.toString() ?? 'cod',
// //           '_id': payment['_id']?.toString() ?? '',
// //         }));
// //       });
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _descriptionController.dispose();
// //     _amountController.dispose();
// //     _razorpay.clear();
// //     super.dispose();
// //   }
// //
// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text("Payment failed: ${response.message}")),
// //     );
// //   }
// //
// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text("External wallet selected: ${response.walletName}")),
// //     );
// //   }
// //
// //   Future<String?> _getUserId() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     return prefs.getString('user_id');
// //   }
// //
// //   Future<void> savePaymentsToStorage() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? userId = await _getUserId();
// //     if (userId == null || userId.isEmpty) {
// //       print("Abhi:- No user ID found, cannot save payments");
// //       return;
// //     }
// //     String storageKey = 'user_${userId}_saved_payments';
// //     List<String> paymentsJson = _payments.map((e) => jsonEncode(e)).toList();
// //     await prefs.setStringList(storageKey, paymentsJson);
// //     print("Abhi:- Payments saved for user $userId");
// //   }
// //
// //   Future<void> loadPaymentsFromStorage() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? userId = await _getUserId();
// //     if (userId == null || userId.isEmpty) {
// //       print("Abhi:- No user ID found, cannot load payments");
// //       return;
// //     }
// //     String storageKey = 'user_${userId}_saved_payments';
// //     List<String>? paymentsJson = prefs.getStringList(storageKey);
// //     if (paymentsJson != null) {
// //       setState(() {
// //         _payments.clear();
// //         _payments.addAll(
// //           paymentsJson.map((e) => Map<String, String>.from(jsonDecode(e))),
// //         );
// //         print("Abhi:- Loaded payments for user $userId: $_payments");
// //       });
// //     }
// //   }
// //
// //   Future<void> marCompleteDarectHire() async {
// //     print("Abhi:- direct cancelOrder order id ${widget.orderId}");
// //     final String url = '${AppConstants.baseUrl}${ApiEndpoint.darectMarkComplete}';
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //     print("Abhi:- Mark as Complete token: $token");
// //
// //     try {
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //         body: jsonEncode({
// //           "order_id": widget.orderId,
// //         }),
// //       );
// //
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- directhire Mark as Complete success :- ${response.body}");
// //         print("Abhi:- providerId get :- ${widget.orderProviderId}");
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => UserFeedback(
// //               providerId: widget.orderProviderId ?? '',
// //               oderId: widget.orderId,
// //             ),
// //           ),
// //         );
// //       } else {
// //         print("Abhi:- else direct-hire Mark as Complete error :- ${response.body}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- Exception Mark as Complete direct-hire : - $e");
// //     }
// //   }
// //
// //   Future<void> postPaymentRequest(String payId) async {
// //     final String url =
// //         'https://api.thebharatworks.com/api/direct-order/user/request-release/${widget.orderId}/$payId';
// //     print('Abhi:- postPaymentRequest orderId ${widget.orderId}');
// //     print("Abhi:- postPaymentRequest url : $url");
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //     print("Abhi:- Mark as Complete token: $token");
// //
// //     try {
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //
// //       var responseData = jsonDecode(response.body);
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- postPaymentRequest response : ${response.body}");
// //         print("Abhi:- postPaymentRequest statuscode : ${response.statusCode}");
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text("${responseData['message']}")),
// //         );
// //       } else {
// //         print("Abhi:- else postPaymentRequest response : ${response.body}");
// //         print("Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- postPaymentRequest Exception $e");
// //     }
// //   }
// //
// //   String toTitleCase(String? text) {
// //     if (text == null || text.isEmpty) return '';
// //     return text[0].toUpperCase() + text.substring(1);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print("Abhi:- getOrderId postPaymentRequest ${widget.orderId}");
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 "Payment",
// //                 style: GoogleFonts.roboto(
// //                   fontSize: 18,
// //                   color: Colors.black,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               if (!_showForm)
// //                 Padding(
// //                   padding: const EdgeInsets.all(10),
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       setState(() {
// //                         _showForm = true;
// //                       });
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green,
// //                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     child: Text(
// //                       "Create",
// //                       style: GoogleFonts.roboto(
// //                         fontSize: 14,
// //                         color: Colors.white,
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           Card(
// //             child: Container(
// //               width: double.infinity,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(8),
// //                 color: Colors.white,
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   if (_showForm)
// //                     Container(
// //                       padding: const EdgeInsets.all(10),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Column(
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Expanded(
// //                                 child: TextField(
// //                                   controller: _descriptionController,
// //                                   decoration: InputDecoration(
// //                                     hintText: 'Enter description',
// //                                     border: OutlineInputBorder(
// //                                       borderRadius: BorderRadius.circular(8),
// //                                     ),
// //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
// //                                   ),
// //                                   onChanged: (value) => _description = value,
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 10),
// //                               SizedBox(
// //                                 width: 100,
// //                                 child: TextField(
// //                                   controller: _amountController,
// //                                   keyboardType: TextInputType.number,
// //                                   inputFormatters: [
// //                                     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
// //                                   ],
// //                                   decoration: InputDecoration(
// //                                     hintText: 'Enter amount',
// //                                     prefixText: '₹',
// //                                     border: OutlineInputBorder(
// //                                       borderRadius: BorderRadius.circular(8),
// //                                     ),
// //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
// //                                   ),
// //                                   onChanged: (value) => _amount = value,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 12),
// //                           Row(
// //                             children: [
// //                               Radio<String>(
// //                                 value: 'cod',
// //                                 groupValue: _selectedPayment,
// //                                 onChanged: (value) {
// //                                   setState(() {
// //                                     _selectedPayment = value!;
// //                                   });
// //                                 },
// //                               ),
// //                               const Text('Cod'),
// //                               const SizedBox(width: 20),
// //                               Radio<String>(
// //                                 value: 'online',
// //                                 groupValue: _selectedPayment,
// //                                 onChanged: (value) {
// //                                   setState(() {
// //                                     _selectedPayment = value!;
// //                                   });
// //                                 },
// //                               ),
// //                               const Text('Online'),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 12),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               ElevatedButton(
// //                                 onPressed: (_description.isNotEmpty &&
// //                                     _amount.isNotEmpty &&
// //                                     double.tryParse(_amount) != null)
// //                                     ? () => _showPaymentDialog()
// //                                     : null,
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor: Colors.green,
// //                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(8),
// //                                   ),
// //                                 ),
// //                                 child: Text(
// //                                   "Submit",
// //                                   style: GoogleFonts.roboto(
// //                                     fontSize: 14,
// //                                     color: Colors.white,
// //                                     fontWeight: FontWeight.w700,
// //                                   ),
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 20),
// //                               OutlinedButton(
// //                                 onPressed: () {
// //                                   setState(() {
// //                                     _showForm = false;
// //                                     _descriptionController.clear();
// //                                     _amountController.text = '';
// //                                     _description = '';
// //                                     _amount = '';
// //                                     _selectedPayment = 'cod';
// //                                   });
// //                                 },
// //                                 style: OutlinedButton.styleFrom(
// //                                   foregroundColor: Colors.green,
// //                                   side: const BorderSide(color: Colors.green),
// //                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(8),
// //                                   ),
// //                                 ),
// //                                 child: Text(
// //                                   "Cancel",
// //                                   style: GoogleFonts.roboto(
// //                                     fontSize: 14,
// //                                     color: Colors.green.shade700,
// //                                     fontWeight: FontWeight.w700,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   if (_payments.isNotEmpty) ...[
// //                     ..._payments.asMap().entries.map((entry) {
// //                       int i = entry.key;
// //                       var payment = entry.value;
// //                       return Padding(
// //                         padding: const EdgeInsets.all(8.0),
// //                         child: Column(
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 Expanded(
// //                                   child: RichText(
// //                                     text: TextSpan(
// //                                       style: GoogleFonts.roboto(
// //                                         fontSize: 14,
// //                                         color: Colors.black,
// //                                         fontWeight: FontWeight.w500,
// //                                       ),
// //                                       children: [
// //                                         TextSpan(text: "${i + 1}. ${toTitleCase(payment['description'])} "),
// //                                         TextSpan(
// //                                           text: " ${toTitleCase(payment['status'] ?? 'UNKNOWN')}",
// //                                           style: TextStyle(color: Colors.green),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   "₹${payment['amount']}",
// //                                   style: GoogleFonts.roboto(
// //                                     fontSize: 16,
// //                                     color: Colors.black,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 5),
// //                                 payment['release_status'] == 'release'
// //                                     ? SizedBox()
// //                                     : GestureDetector(
// //                                   onTap: () {
// //                                     postPaymentRequest(payment['_id'] ?? '');
// //                                     print("Abhi:- payment releaseId : ${payment['_id']}");
// //                                   },
// //                                   child: Container(
// //                                     height: 26,
// //                                     width: 40,
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.green,
// //                                       borderRadius: BorderRadius.circular(5),
// //                                     ),
// //                                     child: Center(
// //                                       child: Text(
// //                                         "Pay",
// //                                         style: GoogleFonts.roboto(
// //                                           fontSize: 13,
// //                                           color: Colors.white,
// //                                           fontWeight: FontWeight.w500,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 10),
// //                           ],
// //                         ),
// //                       );
// //                     }).toList(),
// //                   ] else
// //                     const Padding(
// //                       padding: EdgeInsets.all(12),
// //                       child: Text(
// //                         "No payments yet",
// //                         style: TextStyle(fontSize: 14, color: Colors.grey),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: Colors.yellow.shade100,
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Column(
// //               children: [
// //                 Image.asset('assets/images/warning.png', height: 60),
// //                 const SizedBox(height: 8),
// //                 const Text(
// //                   "Warning Message",
// //                   style: TextStyle(
// //                     color: Colors.red,
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 const Text(
// //                   "Lorem ipsum dolor sit amet consectetur.",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(fontSize: 14, color: Colors.black87),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => ServiceDisputeScreen(
// //                     flowType: 'direct',
// //                     orderId: widget.orderId,
// //                   ),
// //                 ),
// //               );
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.red,
// //               minimumSize: const Size.fromHeight(48),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //             ),
// //             child: const Text(
// //               "Cancel Task and create dispute",
// //               style: TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           ElevatedButton(
// //             onPressed: () {
// //               marCompleteDarectHire();
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.green,
// //               minimumSize: const Size.fromHeight(48),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //             ),
// //             child: const Text(
// //               "Mark as complete",
// //               style: TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _showPaymentDialog() {
// //     double amount = double.tryParse(_amount) ?? 0;
// //     double gst = amount * 0.18;
// //     double totalAmount = amount * 1.18;
// //
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: const Text("Confirmation"),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               Image.asset(
// //                 "assets/images/paymentfonfirm.png",
// //                 height: 90,
// //               ),
// //               const SizedBox(height: 8),
// //               const Text(
// //                 "Confirmation",
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 18,
// //                 ),
// //               ),
// //               const SizedBox(height: 2),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
// //                   Text(
// //                     "${DateFormat("dd/MM/yyyy").format(DateTime.now())}",
// //                     style: TextStyle(fontWeight: FontWeight.w600),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text("Time", style: TextStyle(fontWeight: FontWeight.w600)),
// //                   Text(
// //                     "${DateFormat("kk:mm").format(DateTime.now())}",
// //                     style: TextStyle(fontWeight: FontWeight.w600),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text("Amount", style: TextStyle(fontWeight: FontWeight.w600)),
// //                   Text(
// //                     "₹${amount.toStringAsFixed(2)}",
// //                     style: TextStyle(fontWeight: FontWeight.w600),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text("GST (18%)", style: TextStyle(fontWeight: FontWeight.w600)),
// //                   Text(
// //                     "₹${gst.toStringAsFixed(2)}",
// //                     style: TextStyle(fontWeight: FontWeight.w600),
// //                   ),
// //                 ],
// //               ),
// //               Divider(),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w600)),
// //                   Text(
// //                     "₹${totalAmount.toStringAsFixed(2)}",
// //                     style: TextStyle(fontWeight: FontWeight.w600),
// //                   ),
// //                 ],
// //               ),
// //               Divider(),
// //               const SizedBox(height: 8),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Container(
// //                     width: 100,
// //                     height: 35,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(8),
// //                       color: Colors.green,
// //                     ),
// //                     child: TextButton(
// //                       onPressed: () {
// //                         Navigator.of(context).pop();
// //                         if (_description.isNotEmpty && amount > 0) {
// //                           if (_selectedPayment == 'online') {
// //                             int razorpayAmount = (totalAmount * 100).toInt();
// //                             var options = {
// //                               'key': 'rzp_test_R7z5O0bqmRXuiH',
// //                               'amount': razorpayAmount,
// //                               'name': 'The Bharat Work',
// //                               'description': 'Payment for order ${widget.orderId}',
// //                               'prefill': {
// //                                 'contact': '9876543210',
// //                                 'email': 'test@gmail.com',
// //                               },
// //                               'external': {
// //                                 'wallets': ['paytm']
// //                               }
// //                             };
// //                             try {
// //                               _razorpay.open(options);
// //                             } catch (e) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(content: Text("Razorpay error: $e")),
// //                               );
// //                             }
// //                           } else {
// //                             submitPayment();
// //                           }
// //                         } else {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(content: Text("Please enter a valid description and amount")),
// //                           );
// //                         }
// //                       },
// //                       child: const Text(
// //                         "Pay",
// //                         style: TextStyle(color: Colors.white),
// //                       ),
// //                     ),
// //                   ),
// //                   Container(
// //                     width: 100,
// //                     height: 35,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: Colors.green),
// //                     ),
// //                     child: TextButton(
// //                       onPressed: () {
// //                         Navigator.of(context).pop();
// //                       },
// //                       child: const Text(
// //                         "Close",
// //                         style: TextStyle(color: Colors.black),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Future<void> submitPayment() async {
// //     final url = Uri.parse(
// //       'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
// //     );
// //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? token = prefs.getString('token');
// //
// //     if (token == null || token.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Token not found")),
// //       );
// //       return;
// //     }
// //
// //     double baseAmount = double.tryParse(_amount) ?? 0;
// //     if (baseAmount <= 0) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Please enter a valid amount")),
// //       );
// //       return;
// //     }
// //
// //     double gst = baseAmount * 0.18;
// //     int totalAmount = (baseAmount * 1.18).toInt();
// //
// //     final payload = {
// //       "tax": gst.toInt(),
// //       "description": _description,
// //       "amount": totalAmount,
// //       "method": _selectedPayment,
// //       "status": _selectedPayment == 'cod' ? "success" : "pending",
// //       "collected_by": "Admin",
// //     };
// //
// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //         body: jsonEncode(payload),
// //       );
// //       print("anjali Response Code: ${response.statusCode}");
// //       print("anjali Response Body: ${response.body}");
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         final responseData = jsonDecode(response.body);
// //         if (responseData['service_payment'] != null &&
// //             responseData['service_payment']['payment_history'] != null) {
// //           final paymentHistory = responseData['service_payment']['payment_history'];
// //           final paymentId = paymentHistory.isNotEmpty
// //               ? paymentHistory.last['_id']?.toString() ?? ''
// //               : '';
// //           setState(() {
// //             _payments.add({
// //               'description': _description,
// //               'amount': totalAmount.toString(),
// //               'status': _selectedPayment == 'cod' ? "success" : "pending",
// //               'method': _selectedPayment,
// //               '_id': paymentId,
// //             });
// //             _showForm = false;
// //             _descriptionController.clear();
// //             _amountController.text = '';
// //             _description = '';
// //             _amount = '';
// //             _selectedPayment = 'cod';
// //           });
// //
// //           await savePaymentsToStorage();
// //           await loadPaymentsFromStorage();
// //
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("Payment stage added successfully")),
// //           );
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("Invalid response structure")),
// //           );
// //         }
// //       } else {
// //         final responseData = jsonDecode(response.body);
// //         String errorMessage = responseData['message'] ?? 'Payment failed';
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(errorMessage),
// //             duration: const Duration(seconds: 4),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("⚠️ Error occurred: $e"),
// //           duration: const Duration(seconds: 3),
// //         ),
// //       );
// //     }
// //   }
// //
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// //     final url = Uri.parse(
// //       'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
// //     );
// //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? token = prefs.getString('token');
// //
// //     if (token == null || token.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Token not found")),
// //       );
// //       return;
// //     }
// //
// //     double baseAmount = double.tryParse(_amount) ?? 0;
// //     if (baseAmount <= 0) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Invalid amount")),
// //       );
// //       return;
// //     }
// //
// //     double gst = baseAmount * 0.18;
// //     int totalAmount = (baseAmount * 1.18).toInt();
// //
// //     final payload = {
// //       "tax": gst.toInt(),
// //       "description": _description,
// //       "amount": baseAmount.toInt(),
// //       "method": _selectedPayment,
// //       "status": "success",
// //       "payment_id": response.paymentId,
// //       "collected_by": "Admin",
// //     };
// //
// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //         body: jsonEncode(payload),
// //       );
// //       print("anjali Response Code: ${response.statusCode}");
// //       print("anjali Response Body: ${response.body}");
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         final responseData = jsonDecode(response.body);
// //         if (responseData['service_payment'] != null &&
// //             responseData['service_payment']['payment_history'] != null) {
// //           final paymentHistory = responseData['service_payment']['payment_history'];
// //           final paymentId = paymentHistory.isNotEmpty
// //               ? paymentHistory.last['_id']?.toString() ?? ''
// //               : '';
// //           setState(() {
// //             _payments.add({
// //               'description': _description,
// //               'amount': totalAmount.toString(),
// //               'status': 'success',
// //               'method': _selectedPayment,
// //               '_id': paymentId,
// //             });
// //             _showForm = false;
// //             _descriptionController.clear();
// //             _amountController.text = '';
// //             _description = '';
// //             _amount = '';
// //             _selectedPayment = 'cod';
// //           });
// //
// //           await savePaymentsToStorage();
// //           await loadPaymentsFromStorage();
// //
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("Payment completed successfully")),
// //           );
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("Invalid response structure")),
// //           );
// //         }
// //       } else {
// //         final responseData = jsonDecode(response.body);
// //         String errorMessage = responseData['message'] ?? 'Payment update failed';
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text(errorMessage)),
// //         );
// //         print("Abhi:- payment screen get Exception ${responseData['message']}");
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error: $e")),
// //       );
// //       print("Abhi:- payment screen get Exception $e");
// //     }
// //   }
// // }
//
// import 'dart:convert';
// import 'package:developer/directHiring/views/User/user_feedback.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import '../../Consent/ApiEndpoint.dart';
// import '../../Consent/app_constants.dart';
// import '../ServiceProvider/ServiceDisputeScreen.dart';
//
// class PaymentScreen extends StatefulWidget {
//   final String orderId;
//   final String? orderProviderId;
//   final List<dynamic>? paymentHistory;
//
//   const PaymentScreen({
//     super.key,
//     required this.orderId,
//     this.paymentHistory,
//     this.orderProviderId,
//   });
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
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
//     // Initialize Razorpay
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     loadPaymentsFromStorage();
//     // Load payment history
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
//       // duration: const Duration(seconds: 3),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("External wallet selected: ${response.walletName}")),
//       // duration: const Duration(seconds: 3),
//     );
//   }
//
//   Future<String?> _getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_id');
//   }
//
//   // Future<void> savePaymentsToStorage() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? userId = await _getUserId();
//   //   if (userId == null || userId.isEmpty) {
//   //     print("Abhi:- No user ID found, cannot save payments");
//   //     return;
//   //   }
//   //   String storageKey = 'user_${userId}_saved_payments';
//   //   <List> paymentsJson = _payments.map((e) => jsonEncode(e)).toList();
//   //   await prefs.setStringList(storageKey, paymentsJson);
//   //   print("Abhi:- Payments saved for user $userId");
//   // }
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
//   Future<void> marCompleteDarectHire() async {
//     print("Abhi:- direct cancelOrder order id ${widget.orderId}");
//     final String url = '${AppConstants.baseUrl}${ApiEndpoint.darectMarkComplete}';
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
//         print("Abhi:- directhire Mark as Complete success :- ${response.body}");
//         print("Abhi:- providerId get :- ${widget.orderProviderId}");
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserFeedback(
//               providerId: widget.orderProviderId ?? '',
//               oderId: widget.orderId,
//             ),
//           ),
//         );
//       } else {
//         print("Abhi:- else direct-hire Mark as Complete error :- ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- Exception Mark as Complete direct-hire : - $e");
//     }
//   }
//
//   Future<void> postPaymentRequest(String payId) async {
//     final String url =
//         'https://api.thebharatworks.com/api/direct-order/user/request-release/${widget.orderId}/$payId';
//     print('Abhi:- postPaymentRequest orderId ${widget.orderId}');
//     print("Abhi:- postPaymentRequest url : $url");
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
//       );
//
//       var responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- postPaymentRequest response : ${response.body}");
//         print("Abhi:- postPaymentRequest statuscode : ${response.statusCode}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("${responseData['message']}")),
//          /*d : const Duration(seconds: 3),*/
//         );
//       } else {
//         print("Abhi:- else postPaymentRequest response : ${response.body}");
//         print("Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
//       }
//     } catch (e) {
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
//     print("Abhi:- getOrderId postPaymentRequest ${widget.orderId}");
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
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _description = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               SizedBox(
//                                 width: 100,
//                                 child: TextField(
//                                   controller: _amountController,
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
//                                   ],
//                                   decoration: InputDecoration(
//                                     hintText: 'Enter amount',
//                                     prefixText: '₹',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                                   ),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _amount = value;
//                                     });
//                                   },
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
//                                 onPressed: (_description.isNotEmpty &&
//                                     _amount.isNotEmpty &&
//                                     double.tryParse(_amount) != null &&
//                                     double.tryParse(_amount)! > 0)
//                                     ? () => _showPaymentDialog()
//                                     : null,
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
//                                     _selectedPayment = 'cod';
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
//                                           style: const TextStyle(color: Colors.green),
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
//                                 payment['release_status'] == 'release'
//                                     ? const SizedBox()
//                                     : GestureDetector(
//                                   onTap: () {
//                                     postPaymentRequest(payment['_id'] ?? '');
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
//                                 ),
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
//                     flowType: 'direct',
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
//               marCompleteDarectHire();
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
//     double amount = double.tryParse(_amount) ?? 0;
//     double gst = amount * 0.18;
//     double totalAmount = amount * 1.18;
//
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
//                   const Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text(
//                     DateFormat("dd/MM/yyyy").format(DateTime.now()),
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Time", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text(
//                     DateFormat("kk:mm").format(DateTime.now()),
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Amount", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text(
//                     "₹${amount.toStringAsFixed(2)}",
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("GST (18%)", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text(
//                     "₹${gst.toStringAsFixed(2)}",
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               const Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text(
//                     "₹${totalAmount.toStringAsFixed(2)}",
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               const Divider(),
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
//                         if (_description.isNotEmpty && amount > 0) {
//                           if (_selectedPayment == 'online') {
//                             int razorpayAmount = (totalAmount * 100).toInt();
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
//                                 SnackBar(
//                                   content: Text("Razorpay error: $e"),
//                                   duration: const Duration(seconds: 3),
//                                 ),
//                               );
//                             }
//                           } else {
//                             submitPayment();
//                           }
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Please enter a valid description and amount"),
//                               duration: Duration(seconds: 3),
//                             ),
//                           );
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
//       'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
//     );
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Token not found"),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
//     double baseAmount = double.tryParse(_amount) ?? 0;
//     if (baseAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter a valid amount"),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
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
//             const SnackBar(
//               content: Text("Payment stage added successfully"),
//               duration: Duration(seconds: 3),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Invalid response structure"),
//               duration: Duration(seconds: 3),
//             ),
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
//       'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
//     );
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Token not found"),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
//     double baseAmount = double.tryParse(_amount) ?? 0;
//     if (baseAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Invalid amount"),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
//     double gst = baseAmount * 0.18;
//     int totalAmount = (baseAmount * 1.18).toInt();
//
//     final payload = {
//       "tax": gst.toInt(),
//       "description": _description,
//       "amount": baseAmount.toInt(),
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
//             const SnackBar(
//               content: Text("Payment completed successfully"),
//               duration: Duration(seconds: 3),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Invalid response structure"),
//               duration: Duration(seconds: 3),
//             ),
//           );
//         }
//       } else {
//         final responseData = jsonDecode(response.body);
//         String errorMessage = responseData['message'] ?? 'Payment update failed';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//         print("Abhi:- payment screen get Exception ${responseData['message']}");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e"),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       print("Abhi:- payment screen get Exception $e");
//     }
//   }
// }

import 'dart:convert';
import 'package:developer/directHiring/views/User/user_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../ServiceProvider/ServiceDisputeScreen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String? orderProviderId;
  final List<dynamic>? paymentHistory;

  const PaymentScreen({
    super.key,
    required this.orderId,
    this.paymentHistory,
    this.orderProviderId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _showForm = false;
  String _description = '';
  String _amount = '';
  String _selectedPayment = 'cod';

  final List<Map<String, String>> _payments = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Add listeners to keep controllers and variables in sync
    _descriptionController.addListener(() {
      setState(() {
        _description = _descriptionController.text;
      });
    });
    _amountController.addListener(() {
      setState(() {
        _amount = _amountController.text;
      });
    });

    // Load payments from storage
    loadPaymentsFromStorage();

    // Load payment history from widget
    if (widget.paymentHistory != null) {
      setState(() {
        _payments.addAll(widget.paymentHistory!.map((payment) => {
          'description': payment['description']?.toString() ?? 'No description',
          'amount': payment['amount']?.toString() ?? '0',
          'status': payment['status']?.toString() ?? 'UNKNOWN',
          'method': payment['method']?.toString() ?? 'cod',
          '_id': payment['_id']?.toString() ?? '',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External wallet selected: ${response.walletName}"),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
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

  Future<void> marCompleteDarectHire() async {
    print("Abhi:- direct cancelOrder order id ${widget.orderId}");
    final String url = '${AppConstants.baseUrl}${ApiEndpoint.darectMarkComplete}';
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
        print("Abhi:- directhire Mark as Complete success :- ${response.body}");
        print("Abhi:- providerId get :- ${widget.orderProviderId}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserFeedback(
              providerId: widget.orderProviderId ?? '',
              oderId: widget.orderId,
            ),
          ),
        );
      } else {
        print("Abhi:- else direct-hire Mark as Complete error :- ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to mark as complete: ${response.body}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Abhi:- Exception Mark as Complete direct-hire : - $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error marking as complete: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> postPaymentRequest(String payId) async {
    final String url =
        'https://api.thebharatworks.com/api/direct-order/user/request-release/${widget.orderId}/$payId';
    print('Abhi:- postPaymentRequest orderId ${widget.orderId}');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Payment request successful"),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        print("Abhi:- else postPaymentRequest response : ${response.body}");
        print("Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Payment request failed"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Abhi:- postPaymentRequest Exception $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error in payment request: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:- getOrderId postPaymentRequest ${widget.orderId}");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
          Card(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // Allows decimals up to 2 places. For integers only, use:
                                    // FilteringTextInputFormatter.digitsOnly
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount',
                                    prefixText: '₹',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
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
                                onPressed: (_description.isNotEmpty &&
                                    _amount.isNotEmpty &&
                                    double.tryParse(_amount) != null &&
                                    double.tryParse(_amount)! > 0)
                                    ? () => _showPaymentDialog()
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                                    _amountController.clear();
                                    _description = '';
                                    _amount = '';
                                    _selectedPayment = 'cod';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: "${i + 1}. ${toTitleCase(payment['description'])} "),
                                        TextSpan(
                                          text: " ${toTitleCase(payment['status'] ?? 'UNKNOWN')}",
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  "₹${payment['amount']}",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                payment['release_status'] == 'release'
                                    ? const SizedBox()
                                    : GestureDetector(
                                  onTap: () {
                                    postPaymentRequest(payment['_id'] ?? '');
                                    print("Abhi:- payment releaseId : ${payment['_id']}");
                                  },
                                  child: Container(
                                    height: 26,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5),
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
                  "Lorem ipsum dolor sit amet consectetur.",
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
                    flowType: 'direct',
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
              "Cancel Task and create dispute",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              marCompleteDarectHire();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Mark as complete",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    double amount = double.tryParse(_amount) ?? 0;
    double gst = amount * 0.18;
    double totalAmount = amount * 1.18;

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
                  const Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat("dd/MM/yyyy").format(DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Time", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat("kk:mm").format(DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Amount", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("GST (18%)", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    "₹${gst.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    "₹${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(),
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
                        if (_description.isNotEmpty && amount > 0) {
                          if (_selectedPayment == 'online') {
                            int razorpayAmount = (totalAmount * 100).toInt();
                            var options = {
                              'key': 'rzp_test_R7z5O0bqmRXuiH',
                              'amount': razorpayAmount,
                              'name': 'The Bharat Work',
                              'description': 'Payment for order ${widget.orderId}',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Razorpay error: $e"),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } else {
                            submitPayment();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid description and amount"),
                              duration: Duration(seconds: 3),
                            ),
                          );
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
      'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token not found"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    double baseAmount = double.tryParse(_amount) ?? 0;
    if (baseAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

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
      print("anjali Response Code: ${response.statusCode}");
      print("anjali Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['service_payment'] != null &&
            responseData['service_payment']['payment_history'] != null) {
          final paymentHistory = responseData['service_payment']['payment_history'];
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
            _amountController.clear();
            _description = '';
            _amount = '';
            _selectedPayment = 'cod';
          });

          await savePaymentsToStorage();
          await loadPaymentsFromStorage();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment stage added successfully"),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid response structure"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? 'Payment failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
      print("Abhi:- submitPayment Exception: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/direct-order/order/payment-stage/${widget.orderId}',
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token not found"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    double baseAmount = double.tryParse(_amount) ?? 0;
    if (baseAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid amount"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    double gst = baseAmount * 0.18;
    int totalAmount = (baseAmount * 1.18).toInt();

    final payload = {
      "tax": gst.toInt(),
      "description": _description,
      "amount": baseAmount.toInt(),
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
      print("anjali Response Code: ${response.statusCode}");
      print("anjali Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['service_payment'] != null &&
            responseData['service_payment']['payment_history'] != null) {
          final paymentHistory = responseData['service_payment']['payment_history'];
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
            _amountController.clear();
            _description = '';
            _amount = '';
            _selectedPayment = 'cod';
          });

          await savePaymentsToStorage();
          await loadPaymentsFromStorage();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment completed successfully"),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid response structure"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? 'Payment update failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
        print("Abhi:- payment screen get Exception ${responseData['message']}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
      print("Abhi:- payment screen get Exception $e");
    }
  }
}