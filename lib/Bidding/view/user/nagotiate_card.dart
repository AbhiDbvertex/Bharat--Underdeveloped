import 'dart:convert';

import 'package:developer/Emergency/utils/logger.dart';
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
  var bygetNegotiation;
  var getCurrentBiddingId;
  String? razorpayOrderId; // New variable to store orderId
  String? CreatePlatformfeemessage;
  int? platformFee; // Corrected variable to store platform fee amount (int type)
  late Razorpay _razorpay;
  String? serviceProviderId;

  @override
  void initState() {
    bwDebug("workerId: ${widget.workerId}, orderId: ${widget.oderId}"
        ", biddingOfferId: ${widget.biddingOfferId}, userId: ${widget.UserId}",tag: "Negotiate");
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
    bwDebug("[get Negotiation call ",tag: "negotiate");
    final String url =
        'https://api.thebharatworks.com/api/negotiations/getLatestNegotiation/${widget.oderId}/user';
    print("Abhi:- getNegotiation url: $url");
    print("Abhi:- getNegotiation bidding orderId: ${widget.oderId}");

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
          bygetNegotiation = responseData['initiator'];
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

    bwDebug("[PostNegotiate], called, amount:$amount");
    final String url = "https://api.thebharatworks.com/api/negotiations/start";
    print("Abhi:- postNegotiate url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    bwDebug(" orderId: ${widget.oderId}\n bidding offerId: ${widget.biddingOfferId},\n"
    "service providerId : ${widget.workerId}, "
    "\n userId: ${widget.UserId}.\n"
    "mount: $amount, \n"
    "");
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
      bwDebug("[postNegotiate]  :  response :$responseData ",tag:"Negotiate");

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
        print("Abhi:- AcceptNegotiation serviceProviderId: ${responseData['negotiation']?['service_provider']}");

        setState(() {
          serviceProviderId = responseData['negotiation']?['service_provider'];
        });

        // Get.back(result: true);
        // Get.back(result: true);
        // Get.back(result: true);
        // Get.snackbar(
        //   "Success",
        //   responseData['message'],
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        // showTotalDialog(context, platformFee);
        await CreatebiddingPlateformfee();
        print("Abhi:- accepted Negocation assassin serviceProviderId : ${serviceProviderId}");
        print("Abhi:- accepted Negocation : ${responseData['message']}");
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
    print("Abhi:- CreatebiddingPlateformfee url: ${widget.oderId}");

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
        print("Abhi:- ");
        setState(() {
          razorpayOrderId = responseData['razorpay_order_id']; // Store orderId

          platformFee = responseData['platform_fee']; // Store platform fee amount (assuming it's int)
        });
        print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee createplatformfeemessage : ${CreatePlatformfeemessage}");
        // Do not open Razorpay here; it will be opened from dialog's Pay button
      } else {
        setState(() {
          CreatePlatformfeemessage =  responseData['message'];
        });
        print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee createplatformfeemessage : ${CreatePlatformfeemessage}");
        print("Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print("Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
        if(CreatePlatformfeemessage == 'Platform fee is greater than 10% advance amount!') {
          Get.snackbar(
              "Success",
              responseData['message'],
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
        }
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
    print("Abhi:- verifaibiddingPlateformFee response razerpay paymentId : ${paymentId} razerpay OrderId ${orderId}");

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
          "serviceProviderId": serviceProviderId
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- verifaibiddingPlateformFee statusCode: ${response.statusCode}");
        print("Abhi:- verifaibiddingPlateformFee response: ${response.body}");
        // Verify success hone ke baad AcceptNegotiation call karo
        Get.back(result: true);
        Get.back(result: true);
        Get.back(result: true);
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
            if (isNegotiating ) ...[
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your offer Amount",
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.04,
                  ),
                  border:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                style: GoogleFonts.roboto(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.04,
                ),
              ),
              SizedBox(height: height * 0.02),
              GestureDetector(
                onTap: () async{
                  String amount = amountController.text.trim();
                  if (amount.isEmpty) {
                    print("Abhi:- amount empty hai");
                    return;
                  }
                  await postNegotiate(amount);
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
             /* bygetNegotiation == 'service_provider' ?*/  GestureDetector(
                onTap: (
                    getCurrentBiddingAmmount == null || getCurrentBiddingAmmount.toString().isEmpty)
                    ? null
                    : () async {
                  setState(() {
                    isAccepting = true;
                    isNegotiating = false;
                  });
                  await AcceptNegotiation();
                  // await CreatebiddingPlateformfee(); // Pehle API call karo to get platformFee and orderId
                  // CreatePlatformfeemessage == 'Platform fee is greater than 10% advance amount!' ? showTotalDialog(context, platformFee) :SizedBox() ; // Fir dialog open with platformFee
                  if (CreatePlatformfeemessage != 'Platform fee is greater than 10% advance amount!') {
                    showTotalDialog(context, platformFee);
                  }

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
              ) /*: SizedBox()*/,
            ],
          ],
        ),
      ),
    );
  }
}