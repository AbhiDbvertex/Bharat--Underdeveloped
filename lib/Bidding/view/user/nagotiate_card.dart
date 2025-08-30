// // // // NegotiationCard widget for Negotiate and Accept buttons
// // // import 'dart:convert';
// // //
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:get/get_core/src/get_main.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:intl/intl.dart';
// // // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import '../../../Emergency/User/screens/PaymentConformation.dart';
// // // import '../../../Emergency/utils/assets.dart';
// // //
// // // class NegotiationCardUser extends StatefulWidget {
// // //   final String? workerId;
// // //   // this is filed requirement for user negotiate
// // //   final oderId;
// // //   final biddingOfferId;
// // //   final UserId;
// // //   // final String offerPrice;
// // //
// // //
// // //   const NegotiationCardUser({
// // //     Key? key,  this.workerId, this.oderId, this.biddingOfferId, this.UserId,
// // //
// // //   }) : super(key: key);
// // //
// // //   @override
// // //   _NegotiationCardUserState createState() => _NegotiationCardUserState();
// // // }
// // //
// // // class _NegotiationCardUserState extends State<NegotiationCardUser> {
// // //   bool isNegotiating = false;
// // //   bool isAccepting = false; // Naya state for Accept & Amount
// // //   final TextEditingController amountController = TextEditingController();
// // //   final TextEditingController acceptAmountController =
// // //   TextEditingController(); // Naya controller for accept
// // //   var getCurrentBiddingAmmount;
// // //   var getCurrentBiddingId;
// // //
// // //
// // //
// // //   Future<void> postNegotiate(String amount) async {
// // //     final String url = "https://api.thebharatworks.com/api/negotiations/start";
// // //     print("Abhi:- postnegotiate url : $url");
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //     print("Abhi:- sending amount : $amount");
// // //
// // //     try {
// // //       var response = await http.post(
// // //         Uri.parse(url),
// // //         headers: {
// // //           'Authorization': 'Bearer $token',
// // //           'Content-Type': 'application/json',
// // //         },
// // //         body: jsonEncode({
// // //           "order_id": widget.oderId,
// // //           "bidding_offer_id": widget.biddingOfferId,
// // //           "service_provider": widget.workerId,
// // //           "user": widget.UserId, // yaha userId pass kar
// // //           "initiator": "user",
// // //           "offer_amount": amount,
// // //           "message": "Can you do it for $amount?"
// // //         }),
// // //       );
// // //
// // //        var responseData = jsonDecode(response.body);
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         print("Abhi:- postNegotiate statusCode : ${response.statusCode}");
// // //         print("Abhi:- postNegotiate response : ${response.body}");
// // //         Get.back();
// // //         Get.snackbar("Succes", "${responseData['message']}",snackPosition:SnackPosition.BOTTOM,backgroundColor: Colors.green,colorText: Colors.white);
// // //
// // //       } else {
// // //         print("Abhi:- else postNegotiate statusCode : ${response.statusCode}");
// // //         print("Abhi:- else postNegotiate response : ${response.body}");
// // //       }
// // //     } catch (e) {
// // //       print("Abhi:- postNegotiate Exception : $e");
// // //     }
// // //   }
// // //
// // //   Future<void> getNegotiation () async {
// // //     // final String url = 'https://api.thebharatworks.com/api/negotiations/getLatestNegotiation/68afe536d57712243b253706';
// // //     final String url = 'https://api.thebharatworks.com/api/negotiations/getLatestNegotiation/${widget.oderId}';
// // //     print("Abhi:- getNegotiation url : $url");
// // //
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //
// // //     var response = await http.get(Uri.parse(url),
// // //     headers: {
// // //     'Authorization': 'Bearer $token',
// // //     'Content-Type': 'application/json',
// // //     },
// // //     );
// // //
// // //     try {
// // //       var responseData = jsonDecode(response.body);
// // //       if(response.statusCode == 200 || response.statusCode == 201){
// // //         print("Abhi:- getNegotiation statusCode : ${response.statusCode}");
// // //         print("Abhi:- getNegotiation response : ${response.body}");
// // //         setState(() {
// // //           getCurrentBiddingAmmount = responseData['offer_amount'];
// // //           getCurrentBiddingId = responseData['_id'];
// // //         });
// // //         print('Abhi:- postNegotiate amount : $getCurrentBiddingAmmount id : $getCurrentBiddingId');
// // //       }else {
// // //         print("Abhi:- else getNegotiation statusCode : ${response.statusCode}");
// // //         print("Abhi:- else getNegotiation response : ${response.body}");
// // //       }
// // //     }catch(e){
// // //       print("Abhi:- getNegotiation Exception");
// // //     }
// // //   }
// // //
// // //   //        Accept amount api
// // //   Future<void> AcceptNegotiation () async {
// // //     final String url = "https://api.thebharatworks.com/api/negotiations/accept/$getCurrentBiddingId";
// // //
// // //     print("Abhi:- getNegotiation url : $url");
// // //
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //
// // //     var response = await http.put(Uri.parse(url),
// // //       headers: {
// // //         'Authorization': 'Bearer $token',
// // //         'Content-Type': 'application/json',
// // //       },
// // //       body: jsonEncode({
// // //           "role":"user"
// // //         }),
// // //     );
// // //
// // //     try{
// // //
// // //       var responseData = jsonDecode(response.body);
// // //       if (response.statusCode ==200 || response.statusCode == 201){
// // //         print("Abhi:- AcceptNegotiation statusCode : ${response.statusCode}");
// // //         print("Abhi:- AcceptNegotiation response : ${response.body}");
// // //         Get.back();
// // //         Get.back();
// // //         Get.snackbar("Success", responseData['message'],backgroundColor: Colors.green,colorText: Colors.white,snackPosition: SnackPosition.BOTTOM);
// // //         // Get.to(PaymentConformationScreen(responseModel: null,));
// // //       }
// // //       print("Abhi:- else AcceptNegotiation statusCode : ${response.statusCode}");
// // //       print("Abhi:- else AcceptNegotiation response : ${response.body}");
// // //
// // //     }catch(e){
// // //       print("Abhi:- acceptNegotiation : $e");
// // //     }
// // //
// // //   }
// // //   late Razorpay _razorpay;
// // //   @override
// // //   void initState() {
// // //     // TODO: implement initState
// // //     super.initState();
// // //     getNegotiation ();
// // //     _razorpay = Razorpay();
// // //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// // //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// // //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// // //   }
// // //
// // //
// // //   @override
// // //   void dispose() {
// // //     amountController.dispose();
// // //     acceptAmountController.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     print("Abhi:- get Ids negotiation Screen : workerId : ${widget.workerId} userId :${widget.UserId} biddingOfferId : ${widget.biddingOfferId} oderId : ${widget.oderId}");
// // //     final height = MediaQuery.of(context).size.height;
// // //     final width = MediaQuery.of(context).size.width;
// // //     return Card(
// // //       color: Colors.white,
// // //       child: Container(
// // //         width: width,
// // //         padding: EdgeInsets.all(width * 0.04),
// // //         child: Column(
// // //           children: [
// // //             Container(
// // //               width: width,
// // //               padding: EdgeInsets.all(width * 0.015),
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(width * 0.02),
// // //                 color: Colors.green.shade100,
// // //               ),
// // //               child: Row(
// // //                 children: [
// // //                   Expanded(
// // //                     child: Container(
// // //                       padding:
// // //                       EdgeInsets.symmetric(vertical: height * 0.015),
// // //                       alignment: Alignment.center,
// // //                       decoration: BoxDecoration(
// // //                         borderRadius:
// // //                         BorderRadius.circular(width * 0.02),
// // //                         border: Border.all(color: Colors.green),
// // //                         color: Colors.white,
// // //                       ),
// // //                       child: Text(
// // //                         "Offer Price(${getCurrentBiddingAmmount ?? 0})",
// // //                         style: TextStyle(
// // //                           color: Colors.green,
// // //                           fontSize: width * 0.04,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   SizedBox(width: width * 0.015),
// // //                   Expanded(
// // //                     child: GestureDetector(
// // //                       onTap: () {
// // //                         setState(() {
// // //                           isNegotiating = true;
// // //                           isAccepting =
// // //                           false; // Negotiate click hone pe accept band
// // //                         });
// // //                       },
// // //                       child: Container(
// // //                         padding: EdgeInsets.symmetric(
// // //                             vertical: height * 0.015),
// // //                         alignment: Alignment.center,
// // //                         decoration: BoxDecoration(
// // //                           borderRadius:
// // //                           BorderRadius.circular(width * 0.02),
// // //                           border: Border.all(color: Colors.green.shade700),
// // //                           color: isNegotiating
// // //                               ? Colors.green.shade700
// // //                               : Colors.white,
// // //                         ),
// // //                         child: Text(
// // //                           "Negotiate",
// // //                           style: GoogleFonts.roboto(
// // //                             color: isNegotiating
// // //                                 ? Colors.white
// // //                                 : Colors.green.shade700,
// // //                             fontSize: width * 0.04,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             SizedBox(height: height * 0.02),
// // //             if (isNegotiating) ...[
// // //               Container(
// // //                 padding: EdgeInsets.symmetric(vertical: 2),
// // //                 alignment: Alignment.center,
// // //                 decoration: BoxDecoration(
// // //                   borderRadius: BorderRadius.circular(width * 0.02),
// // //                   border: Border.all(color: Colors.green),
// // //                   color: Colors.white,
// // //                 ),
// // //                 child: TextField(
// // //                   controller: amountController,
// // //                   keyboardType: TextInputType.number,
// // //                   decoration: InputDecoration(
// // //                     hintText: "Enter your offer Amount",
// // //                     hintStyle: GoogleFonts.roboto(
// // //                       color: Colors.green.shade700,
// // //                       fontWeight: FontWeight.bold,
// // //                       fontSize: width * 0.04,
// // //                     ),
// // //                     border: InputBorder.none,
// // //                     contentPadding: EdgeInsets.symmetric(horizontal: 10),
// // //                   ),
// // //                   style: GoogleFonts.roboto(
// // //                     color: Colors.green.shade700,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: width * 0.04,
// // //                   ),
// // //                 ),
// // //               ),
// // //               SizedBox(height: height * 0.02),
// // //               GestureDetector(
// // //                 // onTap: () {
// // //                 //   String amount = amountController.text.trim();
// // //                 //   // widget.onNegotiate(amount);
// // //                 //   setState(() {
// // //                 //     isNegotiating = false;
// // //                 //     amountController.clear();
// // //                 //   });
// // //                 //   postNegotiate ();
// // //                 // },
// // //                 onTap: () {
// // //                   String amount = amountController.text.trim();
// // //
// // //                   if(amount.isEmpty){
// // //                     print("Abhi:- amount empty hai");
// // //                     return;
// // //                   }
// // //
// // //                   postNegotiate(amount);  // pehle call karo with value
// // //
// // //                   setState(() {
// // //                     isNegotiating = false;
// // //                     amountController.clear();
// // //                   });
// // //                 },
// // //
// // //                 child: Container(
// // //                   padding:
// // //                   EdgeInsets.symmetric(vertical: height * 0.018),
// // //                   alignment: Alignment.center,
// // //                   decoration: BoxDecoration(
// // //                     borderRadius: BorderRadius.circular(width * 0.02),
// // //                     color: Colors.green.shade700,
// // //                   ),
// // //                   child: Text(
// // //                     "Send Request",
// // //                     style: GoogleFonts.roboto(
// // //                       color: Colors.white,
// // //                       fontSize: width * 0.04,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ] else if (isAccepting) ...[
// // //               Container(
// // //                 padding: EdgeInsets.symmetric(vertical: 2),
// // //                 alignment: Alignment.center,
// // //                 decoration: BoxDecoration(
// // //                   borderRadius: BorderRadius.circular(width * 0.02),
// // //                   border: Border.all(color: Colors.green),
// // //                   color: Colors.white,
// // //                 ),
// // //                 child: TextField(
// // //                   controller: acceptAmountController,
// // //                   keyboardType: TextInputType.number,
// // //                   decoration: InputDecoration(
// // //                     hintText: "Enter your Accept Amount",
// // //                     hintStyle: GoogleFonts.roboto(
// // //                       color: Colors.green.shade700,
// // //                       fontWeight: FontWeight.bold,
// // //                       fontSize: width * 0.04,
// // //                     ),
// // //                     border: InputBorder.none,
// // //                     contentPadding: EdgeInsets.symmetric(horizontal: 10),
// // //                   ),
// // //                   style: GoogleFonts.roboto(
// // //                     color: Colors.green.shade700,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: width * 0.04,
// // //                   ),
// // //                 ),
// // //               ),
// // //               SizedBox(height: height * 0.02),
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   String amount = acceptAmountController.text.trim();
// // //                   // widget.onAccept(amount);
// // //                   setState(() {
// // //                     isAccepting = false;
// // //                     acceptAmountController.clear();
// // //                     AcceptNegotiation ();
// // //                   });
// // //                 },
// // //                 child: Container(
// // //                   padding:
// // //                   EdgeInsets.symmetric(vertical: height * 0.018),
// // //                   alignment: Alignment.center,
// // //                   decoration: BoxDecoration(
// // //                     borderRadius: BorderRadius.circular(width * 0.02),
// // //                     color: Colors.green.shade700,
// // //                   ),
// // //                   child: Text(
// // //                     "Confirm Accept",
// // //                     style: GoogleFonts.roboto(
// // //                       color: Colors.white,
// // //                       fontSize: width * 0.04,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ] else ...[
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   setState(() {
// // //                     isAccepting = true;
// // //                     isNegotiating =
// // //                     false; // Accept click hone pe negotiate band
// // //                     AcceptNegotiation ();
// // //                   });
// // //                 },
// // //                 child: Container(
// // //                   padding:
// // //                   EdgeInsets.symmetric(vertical: height * 0.018),
// // //                   alignment: Alignment.center,
// // //                   decoration: BoxDecoration(
// // //                     borderRadius: BorderRadius.circular(width * 0.02),
// // //                     color: Colors.green.shade700,
// // //                   ),
// // //                   child: Text(
// // //                     "Accepted & Amount",
// // //                     style: GoogleFonts.roboto(
// // //                       color: Colors.white,
// // //                       fontWeight: FontWeight.w600,
// // //                       fontSize: width * 0.03,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<void> CreatebiddingPlateformfee ()async {
// // //     final String url = 'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/${getCurrentBiddingId}';
// // //     print("Abhi:- createbiddingplateformfee : ${url}");
// // //
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //
// // //     var response = await http.post(Uri.parse(url),
// // //       headers: {
// // //         'Authorization': 'Bearer $token',
// // //         'Content-Type': 'application/json',
// // //       },
// // //     );
// // //
// // //     try{
// // //       var responseData = jsonDecode(response.body);
// // //       if(response.statusCode == 200 || response.statusCode ==201) {
// // //
// // //         print("Abhi:- createbiddingPlateform fee : ${response.statusCode} ");
// // //         print("Abhi:- createbiddingPlateform fee : ${response.body} ");
// // //         var options = {
// // //           'key': 'rzp_test_R7z5O0bqmRXuiH', // apna Razorpay key id dalna
// // //           'amount': responseData['amount'] * 100, // Rs 100 in paise (100*100 = 10000)
// // //           'name': 'The Bharat Work',
// // //           'description': 'Payment for Order',
// // //           'prefill': {
// // //             'contact': '9876543210',
// // //             'email': 'test@razorpay.com',
// // //           },
// // //           'external': {
// // //             'wallets': ['paytm']
// // //           }
// // //         };
// // //
// // //         verifaibiddingPlateformFee(responseData['orderId'], 'razerpay sucees id')  // yaha par razerpay success id pass karna hai
// // //
// // //         try {
// // //           _razorpay.open(options);
// // //         } catch (e) {
// // //           debugPrint('Error: $e');
// // //         }
// // //       }else {
// // //         print("Abhi:- else createbiddingPlateform fee : ${response.statusCode} ");
// // //         print("Abhi:- else createbiddingPlateform fee : ${response.body} ");
// // //       }
// // //     }catch(e){
// // //       print("Abhi:- createbiddingPlateform fee Exception $e");
// // //     }
// // //   }
// // //
// // //   Future<void> verifaibiddingPlateformFee (razerpayId,paymentId)async {
// // //     final String url = 'https://api.thebharatworks.com/api/bidding-order/verifyPlatformFeePayment';
// // //     print("Abhi:- createbiddingplateformfee : ${url}");
// // //
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token') ?? '';
// // //
// // //     var response = await http.put(Uri.parse(url),
// // //       headers: {
// // //         'Authorization': 'Bearer $token',
// // //         'Content-Type': 'application/json',
// // //       },
// // //       body: jsonEncode({
// // //         "razorpay_order_id": paymentId,
// // //         "razorpay_payment_id":razerpayId
// // //         }),
// // //     );
// // //
// // //     try{
// // //       var responseData = jsonDecode(response.body);
// // //       if(response.statusCode == 200 || response.statusCode ==201) {
// // //
// // //       }else {
// // //         print("Abhi:- else createbiddingPlateform fee : ${response.statusCode} ");
// // //         print("Abhi:- else createbiddingPlateform fee : ${response.body} ");
// // //       }
// // //     }catch(e){
// // //       print("Abhi:- createbiddingPlateform fee Exception $e");
// // //     }
// // //   }
// // //
// // //
// // //   void showTotalDialog(context) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) {
// // //         return Dialog(
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(25),
// // //           ),
// // //           child: Padding(
// // //             padding: const EdgeInsets.symmetric(vertical: 24,horizontal: 24),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               crossAxisAlignment: CrossAxisAlignment.center,
// // //               children: [
// // //                 // Title
// // //                 const Text(
// // //                   "Payment Confirmation",
// // //                   style: TextStyle(
// // //                     fontSize: 22,
// // //                     fontWeight: FontWeight.w700,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 16),
// // //
// // //                 // Image
// // //                 Image.asset(BharatAssets.payConfLogo2),
// // //                 const SizedBox(height: 24),
// // //
// // //                 // Details section
// // //                 Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: [
// // //                         Text("Date",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
// // //                         Text(
// // //                           DateFormat("dd-MM-yy").format(
// // //                             DateTime.now()),style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
// // //                           ),
// // //                       ],
// // //                     ),
// // //                   ]
// // //                     ),
// // //                     const SizedBox(height: 8),
// // //                     Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: [
// // //                         Text("Time",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
// // //                         Text(
// // //                           DateFormat("hh:mm a").format(
// // //                               DateTime.now(),
// // //                           ),
// // //                             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
// // //                         ),                    ],
// // //                     ),
// // //                     const SizedBox(height: 8),
// // //                     Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: [
// // //                         Text("Amount",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
// // //                         Text(" RS",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
// // //                       ],
// // //                     ),
// // //                     const SizedBox(height: 8),
// // //                     Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: [
// // //                         Text("Platform fees",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
// // //                         Text(" INR",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
// // //                       ],
// // //                     ),
// // //                     const SizedBox(height: 16),
// // //                     Image.asset(BharatAssets.payLine),
// // //                     const SizedBox(height: 20),
// // //                     Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: [
// // //                         Text(
// // //                           "Total",
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.w600,
// // //                             fontSize: 24,
// // //                           ),
// // //                         ),
// // //                         Text(
// // //                           "/-",
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.w600,
// // //                             fontSize: 24,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //                 Divider(height: 4,color: Colors.green,),
// // //                 const SizedBox(height: 20),
// // //                 // Buttons
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     InkWell(
// // //                       onTap: () async {
// // //                         // final razorPayId=responseModel.razorpayOrder?.id;
// // //                         // final amount=(responseModel.razorpayOrder?.amount)!/100;
// // //                         // final provierId=responseModel.order?.serviceProviderId;
// // //                         final paymentSuccess = await Navigator.push(
// // //                           context,
// // //                           MaterialPageRoute(
// // //                             builder: (context) => RazorpayScreen(
// // //                               razorpayOrderId:razorPayId! ,
// // //                               amount: amount,
// // //                               providerId: provierId,
// // //                               from: "Emergency",
// // //                               // categoryId: widget.categoryId,
// // //                               // subcategoryId: widget.subcategoryId,
// // //                             ),
// // //                           ),
// // //                         );
// // //                         // Navigator.push(context, MaterialPageRoute(builder: (context) => WorkDetail()));
// // //                       },
// // //                       child: Container(
// // //                         height: 35,
// // //                         width: 0.28.toWidthPercent(),
// // //                         alignment: Alignment.center,
// // //                         decoration: BoxDecoration(
// // //                             borderRadius: BorderRadius.circular(8),
// // //                             color: Color(0xff228B22)
// // //                         ),
// // //                         child: Text("Pay",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),),
// // //                       ),
// // //                     ),
// // //                     InkWell(
// // //                       onTap: (){
// // //
// // //                         Get.back();
// // //                       },
// // //                       child: Container(
// // //                         height: 35,
// // //                         width: 0.28.toWidthPercent(),
// // //                         alignment: Alignment.center,
// // //                         decoration: BoxDecoration(
// // //                           borderRadius: BorderRadius.circular(8),
// // //                           border: Border.all(
// // //                             color: Colors.green, // ✅ Green border
// // //                             width: 1.5,          // thickness of border
// // //                           ),
// // //
// // //                         ),
// // //                         child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.green),),
// // //                       ),
// // //                     )
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //
// // //
// // //   }
// // // }
// //
// // import 'dart:convert';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:intl/intl.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../../../Emergency/User/screens/PaymentConformation.dart';
// // import '../../../Emergency/utils/assets.dart';
// //
// // class NegotiationCardUser extends StatefulWidget {
// //   final String? workerId;
// //   final oderId;
// //   final biddingOfferId;
// //   final UserId;
// //
// //   const NegotiationCardUser({
// //     Key? key,
// //     this.workerId,
// //     this.oderId,
// //     this.biddingOfferId,
// //     this.UserId,
// //   }) : super(key: key);
// //
// //   @override
// //   _NegotiationCardUserState createState() => _NegotiationCardUserState();
// // }
// //
// // class _NegotiationCardUserState extends State<NegotiationCardUser> {
// //   bool isNegotiating = false;
// //   bool isAccepting = false;
// //   final TextEditingController amountController = TextEditingController();
// //   var getCurrentBiddingAmmount;
// //   var getCurrentBiddingId;
// //   String? razorpayOrderId; // New variable to store orderId
// //   String? plateformFee; // New variable to store orderId
// //   late Razorpay _razorpay;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     getNegotiation();
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }
// //
// //   @override
// //   void dispose() {
// //     amountController.dispose();
// //     _razorpay.clear();
// //     super.dispose();
// //   }
// //
// //   // Get Latest Negotiation API
// //   Future<void> getNegotiation() async {
// //     final String url =
// //         'https://api.thebharatworks.com/api/negotiations/getLatestNegotiation/${widget.oderId}';
// //     print("Abhi:- getNegotiation url: $url");
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //
// //     try {
// //       var response = await http.get(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //
// //       var responseData = jsonDecode(response.body);
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- getNegotiation statusCode: ${response.statusCode}");
// //         print("Abhi:- getNegotiation response: ${response.body}");
// //         setState(() {
// //           getCurrentBiddingAmmount = responseData['offer_amount'];
// //           getCurrentBiddingId = responseData['_id'];
// //         });
// //         print(
// //             'Abhi:- getNegotiation amount: $getCurrentBiddingAmmount id: $getCurrentBiddingId');
// //       } else {
// //         print("Abhi:- else getNegotiation statusCode: ${response.statusCode}");
// //         print("Abhi:- else getNegotiation response: ${response.body}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- getNegotiation Exception: $e");
// //     }
// //   }
// //
// //   // Post Negotiate API
// //   Future<void> postNegotiate(String amount) async {
// //     final String url = "https://api.thebharatworks.com/api/negotiations/start";
// //     print("Abhi:- postNegotiate url: $url");
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //
// //     try {
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //         body: jsonEncode({
// //           "order_id": widget.oderId,
// //           "bidding_offer_id": widget.biddingOfferId,
// //           "service_provider": widget.workerId,
// //           "user": widget.UserId,
// //           "initiator": "user",
// //           "offer_amount": amount,
// //           "message": "Can you do it for $amount?"
// //         }),
// //       );
// //
// //       var responseData = jsonDecode(response.body);
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- postNegotiate statusCode: ${response.statusCode}");
// //         print("Abhi:- postNegotiate response: ${response.body}");
// //         Get.back();
// //         Get.snackbar(
// //           "Success",
// //           "${responseData['message']}",
// //           snackPosition: SnackPosition.BOTTOM,
// //           backgroundColor: Colors.green,
// //           colorText: Colors.white,
// //         );
// //       } else {
// //         print("Abhi:- else postNegotiate statusCode: ${response.statusCode}");
// //         print("Abhi:- else postNegotiate response: ${response.body}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- postNegotiate Exception: $e");
// //     }
// //   }
// //
// //   // Accept Negotiation API
// //   Future<void> AcceptNegotiation() async {
// //     final String url =
// //         "https://api.thebharatworks.com/api/negotiations/accept/$getCurrentBiddingId";
// //     print("Abhi:- AcceptNegotiation url: $url");
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //
// //     try {
// //       var response = await http.put(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //         body: jsonEncode({"role": "user"}),
// //       );
// //
// //       var responseData = jsonDecode(response.body);
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- AcceptNegotiation statusCode: ${response.statusCode}");
// //         print("Abhi:- AcceptNegotiation response: ${response.body}");
// //         Get.snackbar(
// //           "Success",
// //           responseData['message'],
// //           backgroundColor: Colors.green,
// //           colorText: Colors.white,
// //           snackPosition: SnackPosition.BOTTOM,
// //         );
// //         Get.back(); // Dialog already closed, this is for previous screen
// //       } else {
// //         print("Abhi:- else AcceptNegotiation statusCode: ${response.statusCode}");
// //         print("Abhi:- else AcceptNegotiation response: ${response.body}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- AcceptNegotiation Exception: $e");
// //     }
// //   }
// //
// //   // Create Platform Fee Order API
// //   Future<void> CreatebiddingPlateformfee() async {
// //     final String url =
// //         'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/$getCurrentBiddingId';
// //     print("Abhi:- CreatebiddingPlateformfee url: $url");
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
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
// //         print("Abhi:- CreatebiddingPlateformfee statusCode: ${response.statusCode}");
// //         print("Abhi:- CreatebiddingPlateformfee response: ${response.body}");
// //         setState(() {
// //           razorpayOrderId = responseData['orderId']; // Store orderId
// //           plateformFee = responseData['amount']; // Store orderId
// //         });
// //         print("Abhi:- cratebiddingOder razerpayOderId: ${razorpayOrderId} plateformFee : $plateformFee");
// //         var options = {
// //           'key': 'rzp_test_R7z5O0bqmRXuiH',
// //           'amount': responseData['amount'] * 100, // Rs to paise
// //           'name': 'The Bharat Work',
// //           'description': 'Payment for Order',
// //           'prefill': {
// //             'contact': '9876543210',
// //             'email': 'test@razorpay.com',
// //           },
// //           'external': {
// //             'wallets': ['paytm']
// //           }
// //         };
// //         try {
// //           _razorpay.open(options); // Razorpay open
// //         } catch (e) {
// //           debugPrint('Razorpay Error: $e');
// //         }
// //
// //       } else {
// //         print("Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
// //         print("Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- CreatebiddingPlateformfee Exception: $e");
// //     }
// //   }
// //
// //   // Verify Platform Fee Payment API
// //   Future<void> verifaibiddingPlateformFee(String paymentId, String orderId) async {
// //     final String url =
// //         'https://api.thebharatworks.com/api/bidding-order/verifyPlatformFeePayment';
// //     print("Abhi:- verifaibiddingPlateformFee url: $url");
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //
// //     try {
// //       var response = await http.put(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //         body: jsonEncode({
// //           "razorpay_order_id": orderId,
// //           "razorpay_payment_id": paymentId,
// //         }),
// //       );
// //
// //       var responseData = jsonDecode(response.body);
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- verifaibiddingPlateformFee statusCode: ${response.statusCode}");
// //         print("Abhi:- verifaibiddingPlateformFee response: ${response.body}");
// //         // Verify success hone ke baad AcceptNegotiation call karo
// //         await AcceptNegotiation();
// //       } else {
// //         print("Abhi:- else verifaibiddingPlateformFee statusCode: ${response.statusCode}");
// //         print("Abhi:- else verifaibiddingPlateformFee response: ${response.body}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- verifaibiddingPlateformFee Exception: $e");
// //     }
// //   }
// //
// //   // Razorpay Handlers
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //     print("Abhi:- Payment Success: ${response.paymentId}");
// //     verifaibiddingPlateformFee(response.paymentId!, razorpayOrderId!); // Call verify
// //     Get.snackbar("Payment Success", "Transaction completed!", backgroundColor: Colors.green, colorText: Colors.white);
// //     Get.back(); // Close dialog
// //   }
// //
// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     print("Abhi:- Payment Error: ${response.message}");
// //     Get.snackbar("Payment Failed", "Error: ${response.message}", backgroundColor: Colors.red, colorText: Colors.white);
// //   }
// //
// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     print("Abhi:- External Wallet: ${response.walletName}");
// //   }
// //
// //   // Dialog for Payment Confirmation
// //   void showTotalDialog(BuildContext context,plateformFee) {
// //     int platformFee = plateformFee; // Assume ya API response se lo
// //     int totalAmount = (getCurrentBiddingAmmount ?? 0) + platformFee;
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 const Text("Payment Confirmation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
// //                 const SizedBox(height: 16),
// //                 Image.asset(BharatAssets.payConfLogo2),
// //                 const SizedBox(height: 24),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text("Date", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
// //                         Text(DateFormat("dd-MM-yy").format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text("Time", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
// //                         Text(DateFormat("hh:mm a").format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text("Amount", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
// //                         Text("RS $getCurrentBiddingAmmount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text("Platform fees", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
// //                         Text("INR $platformFee", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 16),
// //                     Image.asset(BharatAssets.payLine),
// //                     const SizedBox(height: 20),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
// //                         Text("RS $totalAmount/-", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Divider(height: 4, color: Colors.green),
// //                 const SizedBox(height: 20),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     InkWell(
// //                       onTap: () async {
// //                         await CreatebiddingPlateformfee(); // Call create payment
// //                       },
// //                       child: Container(
// //                         height: 35,
// //                         width: MediaQuery.of(context).size.width * 0.28,
// //                         alignment: Alignment.center,
// //                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xff228B22)),
// //                         child: Text("Pay", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
// //                       ),
// //                     ),
// //                     InkWell(
// //                       onTap: () {
// //                         Navigator.pop(context); // Close dialog
// //                       },
// //                       child: Container(
// //                         height: 35,
// //                         width: MediaQuery.of(context).size.width * 0.28,
// //                         alignment: Alignment.center,
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(8),
// //                           border: Border.all(color: Colors.green, width: 1.5),
// //                         ),
// //                         child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.green)),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print(
// //         "Abhi:- get Ids negotiation Screen: workerId: ${widget.workerId} userId: ${widget.UserId} biddingOfferId: ${widget.biddingOfferId} oderId: ${widget.oderId}");
// //     final height = MediaQuery.of(context).size.height;
// //     final width = MediaQuery.of(context).size.width;
// //     return Card(
// //       color: Colors.white,
// //       child: Container(
// //         width: width,
// //         padding: EdgeInsets.all(width * 0.04),
// //         child: Column(
// //           children: [
// //             Container(
// //               width: width,
// //               padding: EdgeInsets.all(width * 0.015),
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(width * 0.02),
// //                 color: Colors.green.shade100,
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(vertical: height * 0.015),
// //                       alignment: Alignment.center,
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(width * 0.02),
// //                         border: Border.all(color: Colors.green),
// //                         color: Colors.white,
// //                       ),
// //                       child: Text(
// //                         "Offer Price(${getCurrentBiddingAmmount ?? 0})",
// //                         style: TextStyle(color: Colors.green, fontSize: width * 0.04),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(width: width * 0.015),
// //                   Expanded(
// //                     child: GestureDetector(
// //                       onTap: () {
// //                         setState(() {
// //                           isNegotiating = true;
// //                           isAccepting = false;
// //                         });
// //                       },
// //                       child: Container(
// //                         padding: EdgeInsets.symmetric(vertical: height * 0.015),
// //                         alignment: Alignment.center,
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(width * 0.02),
// //                           border: Border.all(color: Colors.green.shade700),
// //                           color: isNegotiating ? Colors.green.shade700 : Colors.white,
// //                         ),
// //                         child: Text(
// //                           "Negotiate",
// //                           style: GoogleFonts.roboto(
// //                             color: isNegotiating ? Colors.white : Colors.green.shade700,
// //                             fontSize: width * 0.04,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(height: height * 0.02),
// //             if (isNegotiating) ...[
// //               Container(
// //                 padding: EdgeInsets.symmetric(vertical: 2),
// //                 alignment: Alignment.center,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(width * 0.02),
// //                   border: Border.all(color: Colors.green),
// //                   color: Colors.white,
// //                 ),
// //                 child: TextField(
// //                   controller: amountController,
// //                   keyboardType: TextInputType.number,
// //                   decoration: InputDecoration(
// //                     hintText: "Enter your offer Amount",
// //                     hintStyle: GoogleFonts.roboto(
// //                       color: Colors.green.shade700,
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: width * 0.04,
// //                     ),
// //                     border: InputBorder.none,
// //                     contentPadding: EdgeInsets.symmetric(horizontal: 10),
// //                   ),
// //                   style: GoogleFonts.roboto(
// //                     color: Colors.green.shade700,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: width * 0.04,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: height * 0.02),
// //               GestureDetector(
// //                 onTap: () {
// //                   String amount = amountController.text.trim();
// //                   if (amount.isEmpty) {
// //                     print("Abhi:- amount empty hai");
// //                     return;
// //                   }
// //                   postNegotiate(amount);
// //                   setState(() {
// //                     isNegotiating = false;
// //                     amountController.clear();
// //                   });
// //                 },
// //                 child: Container(
// //                   padding: EdgeInsets.symmetric(vertical: height * 0.018),
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(width * 0.02),
// //                     color: Colors.green.shade700,
// //                   ),
// //                   child: Text(
// //                     "Send Request",
// //                     style: GoogleFonts.roboto(color: Colors.white, fontSize: width * 0.04),
// //                   ),
// //                 ),
// //               ),
// //             ] else ...[
// //               GestureDetector(
// //                 onTap: () {
// //                   setState(() {
// //                     isAccepting = true;
// //                     isNegotiating = false;
// //                   });CreatebiddingPlateformfee();
// //                   showTotalDialog(context,plateformFee); // Direct dialog open
// //                 },
// //                 child: Container(
// //                   padding: EdgeInsets.symmetric(vertical: height * 0.018),
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(width * 0.02),
// //                     color: Colors.green.shade700,
// //                   ),
// //                   child: Text(
// //                     "Accepted & Amount",
// //                     style: GoogleFonts.roboto(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.w600,
// //                       fontSize: width * 0.03,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Emergency/User/screens/PaymentConformation.dart';
// import '../../../Emergency/utils/assets.dart';
//
// class NegotiationCardUser extends StatefulWidget {
//   final String? workerId;
//   final oderId;
//   final biddingOfferId;
//   final UserId;
//
//   const NegotiationCardUser({
//     Key? key,
//     this.workerId,
//     this.oderId,
//     this.biddingOfferId,
//     this.UserId,
//   }) : super(key: key);
//
//   @override
//   _NegotiationCardUserState createState() => _NegotiationCardUserState();
// }
//
// class _NegotiationCardUserState extends State<NegotiationCardUser> {
//   bool isNegotiating = false;
//   bool isAccepting = false;
//   final TextEditingController amountController = TextEditingController();
//   var getCurrentBiddingAmmount;
//   var getCurrentBiddingId;
//   String? razorpayOrderId; // New variable to store orderId
//   int? platformFee; // Corrected variable to store platform fee amount (int type)
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     getNegotiation();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   void dispose() {
//     amountController.dispose();
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   // Get Latest Negotiation API
//   Future<void> getNegotiation() async {
//     final String url =
//         'https://api.thebharatworks.com/api/negotiations/getLatestNegotiation/${widget.oderId}';
//     print("Abhi:- getNegotiation url: $url");
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       var responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- getNegotiation statusCode: ${response.statusCode}");
//         print("Abhi:- getNegotiation response: ${response.body}");
//         setState(() {
//           getCurrentBiddingAmmount = responseData['offer_amount'];
//           getCurrentBiddingId = responseData['_id'];
//         });
//         print(
//             'Abhi:- getNegotiation amount: $getCurrentBiddingAmmount id: $getCurrentBiddingId');
//       } else {
//         print("Abhi:- else getNegotiation statusCode: ${response.statusCode}");
//         print("Abhi:- else getNegotiation response: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- getNegotiation Exception: $e");
//     }
//   }
//
//   // Post Negotiate API
//   Future<void> postNegotiate(String amount) async {
//     final String url = "https://api.thebharatworks.com/api/negotiations/start";
//     print("Abhi:- postNegotiate url: $url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "order_id": widget.oderId,
//           "bidding_offer_id": widget.biddingOfferId,
//           "service_provider": widget.workerId,
//           "user": widget.UserId,
//           "initiator": "user",
//           "offer_amount": amount,
//           "message": "Can you do it for $amount?"
//         }),
//       );
//
//       var responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- postNegotiate statusCode: ${response.statusCode}");
//         print("Abhi:- postNegotiate response: ${response.body}");
//         Get.back();
//         Get.snackbar(
//           "Success",
//           "${responseData['message']}",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         print("Abhi:- else postNegotiate statusCode: ${response.statusCode}");
//         print("Abhi:- else postNegotiate response: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- postNegotiate Exception: $e");
//     }
//   }
//
//   // Accept Negotiation API
//   Future<void> AcceptNegotiation() async {
//     final String url =
//         "https://api.thebharatworks.com/api/negotiations/accept/$getCurrentBiddingId";
//     print("Abhi:- AcceptNegotiation url: $url");
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({"role": "user"}),
//       );
//
//       var responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- AcceptNegotiation statusCode: ${response.statusCode}");
//         print("Abhi:- AcceptNegotiation response: ${response.body}");
//         Get.snackbar(
//           "Success",
//           responseData['message'],
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         Get.back(); // Dialog already closed, this is for previous screen
//       } else {
//         print("Abhi:- else AcceptNegotiation statusCode: ${response.statusCode}");
//         print("Abhi:- else AcceptNegotiation response: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- AcceptNegotiation Exception: $e");
//     }
//   }
//
//   // Create Platform Fee Order API (Now without opening Razorpay immediately)
//   Future<void> CreatebiddingPlateformfee() async {
//     final String url =
//         'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/${widget.oderId}';
//     print("Abhi:- CreatebiddingPlateformfee url: $url");
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
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
//         print("Abhi:- CreatebiddingPlateformfee statusCode: ${response.statusCode}");
//         print("Abhi:- CreatebiddingPlateformfee response: ${response.body}");
//         setState(() {
//           razorpayOrderId = responseData['orderId']; // Store orderId
//           platformFee = responseData['amount']; // Store platform fee amount (assuming it's int)
//         });
//         print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee");
//         // Do not open Razorpay here; it will be opened from dialog's Pay button
//       } else {
//         print("Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
//         print("Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- CreatebiddingPlateformfee Exception: $e");
//     }
//   }
//
//   // Verify Platform Fee Payment API
//   Future<void> verifaibiddingPlateformFee(String paymentId, String orderId) async {
//     final String url =
//         'https://api.thebharatworks.com/api/bidding-order/verifyPlatformFeePayment';
//     print("Abhi:- verifaibiddingPlateformFee url: $url");
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "razorpay_order_id": orderId,
//           "razorpay_payment_id": paymentId,
//         }),
//       );
//
//       var responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- verifaibiddingPlateformFee statusCode: ${response.statusCode}");
//         print("Abhi:- verifaibiddingPlateformFee response: ${response.body}");
//         // Verify success hone ke baad AcceptNegotiation call karo
//         await AcceptNegotiation();
//       } else {
//         print("Abhi:- else verifaibiddingPlateformFee statusCode: ${response.statusCode}");
//         print("Abhi:- else verifaibiddingPlateformFee response: ${response.body}");
//       }
//     } catch (e) {
//       print("Abhi:- verifaibiddingPlateformFee Exception: $e");
//     }
//   }
//
//   // Razorpay Handlers
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     print("Abhi:- Payment Success: ${response.paymentId}");
//     verifaibiddingPlateformFee(response.paymentId!, razorpayOrderId!); // Call verify
//     Get.snackbar("Payment Success", "Transaction completed!", backgroundColor: Colors.green, colorText: Colors.white);
//     Get.back(); // Close dialog
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     print("Abhi:- Payment Error: ${response.message}");
//     Get.snackbar("Payment Failed", "Error: ${response.message}", backgroundColor: Colors.red, colorText: Colors.white);
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("Abhi:- External Wallet: ${response.walletName}");
//   }
//
//   // Dialog for Payment Confirmation (Now takes platformFee as parameter)
//   void showTotalDialog(BuildContext context, int? platformFee) {
//     int fee = platformFee ?? 0; // Default to 0 if null
//     int totalAmount = (getCurrentBiddingAmmount ?? 0) + fee;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text("Payment Confirmation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 16),
//                 Image.asset(BharatAssets.payConfLogo2),
//                 const SizedBox(height: 24),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Date", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text(DateFormat("dd-MM-yy").format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Time", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text(DateFormat("hh:mm a").format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Amount", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text("RS $getCurrentBiddingAmmount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Platform fees", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
//                         Text("INR $fee", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Image.asset(BharatAssets.payLine),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
//                         Text("RS $totalAmount/-", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Divider(height: 4, color: Colors.green),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         if (platformFee != null && razorpayOrderId != null) {
//                           var options = {
//                             'key': 'rzp_test_R7z5O0bqmRXuiH',
//                             'amount': platformFee! * 100, // Use stored platformFee
//                             'name': 'The Bharat Work',
//                             'description': 'Payment for Order',
//                             'prefill': {
//                               'contact': '9876543210',
//                               'email': 'test@razorpay.com',
//                             },
//                             'external': {
//                               'wallets': ['paytm']
//                             }
//                           };
//                           try {
//                             _razorpay.open(options); // Open Razorpay now
//                           } catch (e) {
//                             debugPrint('Razorpay Error: $e');
//                           }
//                         } else {
//                           Get.snackbar("Error", "Platform fee or order ID not available", backgroundColor: Colors.red, colorText: Colors.white);
//                         }
//                       },
//                       child: Container(
//                         height: 35,
//                         width: MediaQuery.of(context).size.width * 0.28,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xff228B22)),
//                         child: Text("Pay", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context); // Close dialog
//                       },
//                       child: Container(
//                         height: 35,
//                         width: MediaQuery.of(context).size.width * 0.28,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.green, width: 1.5),
//                         ),
//                         child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.green)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//         "Abhi:- get Ids negotiation Screen: workerId: ${widget.workerId} userId: ${widget.UserId} biddingOfferId: ${widget.biddingOfferId} oderId: ${widget.oderId}");
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     return Card(
//       color: Colors.white,
//       child: Container(
//         width: width,
//         padding: EdgeInsets.all(width * 0.04),
//         child: Column(
//           children: [
//             Container(
//               width: width,
//               padding: EdgeInsets.all(width * 0.015),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(width * 0.02),
//                 color: Colors.green.shade100,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: height * 0.015),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(width * 0.02),
//                         border: Border.all(color: Colors.green),
//                         color: Colors.white,
//                       ),
//                       child: Text(
//                         "Offer Price(${getCurrentBiddingAmmount ?? 0})",
//                         style: TextStyle(color: Colors.green, fontSize: width * 0.04),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: width * 0.015),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isNegotiating = true;
//                           isAccepting = false;
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: height * 0.015),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(width * 0.02),
//                           border: Border.all(color: Colors.green.shade700),
//                           color: isNegotiating ? Colors.green.shade700 : Colors.white,
//                         ),
//                         child: Text(
//                           "Negotiate",
//                           style: GoogleFonts.roboto(
//                             color: isNegotiating ? Colors.white : Colors.green.shade700,
//                             fontSize: width * 0.04,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: height * 0.02),
//             if (isNegotiating) ...[
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 2),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(width * 0.02),
//                   border: Border.all(color: Colors.green),
//                   color: Colors.white,
//                 ),
//                 child: TextField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: "Enter your offer Amount",
//                     hintStyle: GoogleFonts.roboto(
//                       color: Colors.green.shade700,
//                       fontWeight: FontWeight.bold,
//                       fontSize: width * 0.04,
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                   ),
//                   style: GoogleFonts.roboto(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                     fontSize: width * 0.04,
//                   ),
//                 ),
//               ),
//               SizedBox(height: height * 0.02),
//               GestureDetector(
//                 onTap: () {
//                   String amount = amountController.text.trim();
//                   if (amount.isEmpty) {
//                     print("Abhi:- amount empty hai");
//                     return;
//                   }
//                   postNegotiate(amount);
//                   setState(() {
//                     isNegotiating = false;
//                     amountController.clear();
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: height * 0.018),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(width * 0.02),
//                     color: Colors.green.shade700,
//                   ),
//                   child: Text(
//                     "Send Request",
//                     style: GoogleFonts.roboto(color: Colors.white, fontSize: width * 0.04),
//                   ),
//                 ),
//               ),
//             ] else ...[
//               GestureDetector(
//                 onTap: () async {
//                   setState(() {
//                     isAccepting = true;
//                     isNegotiating = false;
//                   });
//                   await CreatebiddingPlateformfee(); // Pehle API call karo to get platformFee and orderId
//                   showTotalDialog(context, platformFee); // Fir dialog open with platformFee
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: height * 0.018),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(width * 0.02),
//                     color: Colors.green.shade700,
//                   ),
//                   child: Text(
//                     "Accepted & Amount",
//                     style: GoogleFonts.roboto(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: width * 0.03,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
 ///      upar vala code sahi hai


import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Emergency/User/screens/PaymentConformation.dart';
import '../../../Emergency/utils/assets.dart';

class NegotiationCardUser extends StatefulWidget {
  final String? workerId;
  final oderId;
  final biddingOfferId;
  final UserId;

  const NegotiationCardUser({
    Key? key,
    this.workerId,
    this.oderId,
    this.biddingOfferId,
    this.UserId,
  }) : super(key: key);

  @override
  _NegotiationCardUserState createState() => _NegotiationCardUserState();
}

class _NegotiationCardUserState extends State<NegotiationCardUser> {
  bool isNegotiating = false;
  bool isAccepting = false;
  final TextEditingController amountController = TextEditingController();
  var getCurrentBiddingAmmount;
  var getCurrentBiddingId;
  String? razorpayOrderId; // New variable to store orderId
  int? platformFee; // Corrected variable to store platform fee amount (int type)
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    getNegotiation();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // Get Latest Negotiation API
  Future<void> getNegotiation() async {
    final String url =
        'https://api.thebharatworks.com/api/negotiations/getLatestNegotiation/${widget.oderId}';
    print("Abhi:- getNegotiation url: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- getNegotiation statusCode: ${response.statusCode}");
        print("Abhi:- getNegotiation response: ${response.body}");
        setState(() {
          getCurrentBiddingAmmount = responseData['offer_amount'];
          getCurrentBiddingId = responseData['_id'];
        });
        print(
            'Abhi:- getNegotiation amount: $getCurrentBiddingAmmount id: $getCurrentBiddingId');
      } else {
        print("Abhi:- else getNegotiation statusCode: ${response.statusCode}");
        print("Abhi:- else getNegotiation response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- getNegotiation Exception: $e");
    }
  }

  // Post Negotiate API
  Future<void> postNegotiate(String amount) async {
    final String url = "https://api.thebharatworks.com/api/negotiations/start";
    print("Abhi:- postNegotiate url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": widget.oderId,
          "bidding_offer_id": widget.biddingOfferId,
          "service_provider": widget.workerId,
          "user": widget.UserId,
          "initiator": "user",
          "offer_amount": amount,
          "message": "Can you do it for $amount?"
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- postNegotiate statusCode: ${response.statusCode}");
        print("Abhi:- postNegotiate response: ${response.body}");
        Get.back();
        Get.snackbar(
          "Success",
          "${responseData['message']}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Abhi:- else postNegotiate statusCode: ${response.statusCode}");
        print("Abhi:- else postNegotiate response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- postNegotiate Exception: $e");
    }
  }

  // Accept Negotiation API
  Future<void> AcceptNegotiation() async {
    final String url =
        "https://api.thebharatworks.com/api/negotiations/accept/$getCurrentBiddingId";
    print("Abhi:- AcceptNegotiation url: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"role": "user"}),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- AcceptNegotiation statusCode: ${response.statusCode}");
        print("Abhi:- AcceptNegotiation response: ${response.body}");
        Get.back();
        Get.back();
        Get.back();
        Get.snackbar(
          "Success",
          responseData['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Removed Get.back() from here to avoid extra navigation
      } else {
        print("Abhi:- else AcceptNegotiation statusCode: ${response.statusCode}");
        print("Abhi:- else AcceptNegotiation response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- AcceptNegotiation Exception: $e");
    }
  }

  // Create Platform Fee Order API (Now without opening Razorpay immediately)
  Future<void> CreatebiddingPlateformfee() async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/${widget.oderId}';
    print("Abhi:- CreatebiddingPlateformfee url: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

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
        print("Abhi:- CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print("Abhi:- CreatebiddingPlateformfee response: ${response.body}");
        setState(() {
          razorpayOrderId = responseData['orderId']; // Store orderId
          platformFee = responseData['amount']; // Store platform fee amount (assuming it's int)
        });
        print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee");
        // Do not open Razorpay here; it will be opened from dialog's Pay button
      } else {
        print("Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print("Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- CreatebiddingPlateformfee Exception: $e");
    }
  }

  // Verify Platform Fee Payment API
  Future<void> verifaibiddingPlateformFee(String paymentId, String orderId) async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/verifyPlatformFeePayment';
    print("Abhi:- verifaibiddingPlateformFee url: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "razorpay_order_id": orderId,
          "razorpay_payment_id": paymentId,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- verifaibiddingPlateformFee statusCode: ${response.statusCode}");
        print("Abhi:- verifaibiddingPlateformFee response: ${response.body}");
        // Verify success hone ke baad AcceptNegotiation call karo
        await AcceptNegotiation();
      } else {
        print("Abhi:- else verifaibiddingPlateformFee statusCode: ${response.statusCode}");
        print("Abhi:- else verifaibiddingPlateformFee response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- verifaibiddingPlateformFee Exception: $e");
    }
  }

  // Razorpay Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Abhi:- Payment Success: ${response.paymentId}");
    verifaibiddingPlateformFee(response.paymentId!, razorpayOrderId!); // Call verify
    Get.snackbar("Payment Success", "Transaction completed!", backgroundColor: Colors.green, colorText: Colors.white);
    Get.back(); // Close dialog
    Get.back(); // Extra back if needed for previous screen
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Abhi:- Payment Error: ${response.message}");
    Get.snackbar("Payment Failed", "Error: ${response.message}", backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Abhi:- External Wallet: ${response.walletName}");
  }

  // Dialog for Payment Confirmation (Now takes platformFee as parameter)
  void showTotalDialog(BuildContext context, int? platformFee) {
    int fee = platformFee ?? 0; // Default to 0 if null
    int totalAmount = (getCurrentBiddingAmmount ?? 0) + fee;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Payment Confirmation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Image.asset(BharatAssets.payConfLogo2),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(DateFormat("dd-MM-yy").format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Time", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(DateFormat("hh:mm a").format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Amount", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text("RS $getCurrentBiddingAmmount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Platform fees", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                        Text("INR $fee", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Image.asset(BharatAssets.payLine),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                        Text("RS $totalAmount/-", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 4, color: Colors.green),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (platformFee != null && razorpayOrderId != null) {
                          var options = {
                            'key': 'rzp_test_R7z5O0bqmRXuiH',
                            'amount': totalAmount * 100, // Changed to totalAmount for payment
                            'name': 'The Bharat Work',
                            'description': 'Payment for Order',
                            'prefill': {
                              'contact': '9876543210',
                              'email': 'test@razorpay.com',
                            },
                            'external': {
                              'wallets': ['paytm']
                            }
                          };
                          try {
                            _razorpay.open(options); // Open Razorpay now
                          } catch (e) {
                            debugPrint('Razorpay Error: $e');
                          }
                        } else {
                          Get.snackbar("Error", "Platform fee or order ID not available", backgroundColor: Colors.red, colorText: Colors.white);
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xff228B22)),
                        child: Text("Pay", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 1.5),
                        ),
                        child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Abhi:- get Ids negotiation Screen: workerId: ${widget.workerId} userId: ${widget.UserId} biddingOfferId: ${widget.biddingOfferId} oderId: ${widget.oderId}");
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
      child: Container(
        width: width,
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          children: [
            Container(
              width: width,
              padding: EdgeInsets.all(width * 0.015),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.02),
                color: Colors.green.shade100,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.02),
                        border: Border.all(color: Colors.green),
                        color: Colors.white,
                      ),
                      child: Text(
                        "Offer Price(${getCurrentBiddingAmmount ?? 0})",
                        style: TextStyle(color: Colors.green, fontSize: width * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.015),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isNegotiating = true;
                          isAccepting = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * 0.02),
                          border: Border.all(color: Colors.green.shade700),
                          color: isNegotiating ? Colors.green.shade700 : Colors.white,
                        ),
                        child: Text(
                          "Negotiate",
                          style: GoogleFonts.roboto(
                            color: isNegotiating ? Colors.white : Colors.green.shade700,
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            if (isNegotiating) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  border: Border.all(color: Colors.green),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter your offer Amount",
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: GoogleFonts.roboto(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.04,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              GestureDetector(
                onTap: () {
                  String amount = amountController.text.trim();
                  if (amount.isEmpty) {
                    print("Abhi:- amount empty hai");
                    return;
                  }
                  postNegotiate(amount);
                  setState(() {
                    isNegotiating = false;
                    amountController.clear();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Send Request",
                    style: GoogleFonts.roboto(color: Colors.white, fontSize: width * 0.04),
                  ),
                ),
              ),
            ] else ...[
              /*GestureDetector(
                onTap: getCurrentBiddingAmmount == null ?  () async {
                  setState(() {
                    isAccepting = true;
                    isNegotiating = false;
                  });
                  await CreatebiddingPlateformfee(); // Pehle API call karo to get platformFee and orderId
                  showTotalDialog(context, platformFee); // Fir dialog open with platformFee
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Accepted & Amount",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ),*/
              GestureDetector(
                onTap: (getCurrentBiddingAmmount == null || getCurrentBiddingAmmount.toString().isEmpty)
                    ? null
                    : () async {
                  setState(() {
                    isAccepting = true;
                    isNegotiating = false;
                  });
                  await CreatebiddingPlateformfee(); // Pehle API call karo to get platformFee and orderId
                  showTotalDialog(context, platformFee); // Fir dialog open with platformFee
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: (getCurrentBiddingAmmount == null || getCurrentBiddingAmmount.toString().isEmpty)
                        ? Colors.grey // disable look
                        : Colors.green.shade700,
                  ),
                  child: Text(
                    "Accepted & Amount",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}