// NegotiationCard widget for Negotiate and Accept buttons
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NegotiationCardUser extends StatefulWidget {
  final String? workerId;
  // this is filed requirement for user negotiate
  final oderId;
  final biddingOfferId;
  final UserId;
  // final String offerPrice;


  const NegotiationCardUser({
    Key? key,  this.workerId, this.oderId, this.biddingOfferId, this.UserId,

  }) : super(key: key);

  @override
  _NegotiationCardUserState createState() => _NegotiationCardUserState();
}

class _NegotiationCardUserState extends State<NegotiationCardUser> {
  bool isNegotiating = false;
  bool isAccepting = false; // Naya state for Accept & Amount
  final TextEditingController amountController = TextEditingController();
  final TextEditingController acceptAmountController =
  TextEditingController(); // Naya controller for accept

  // Future<void> postNegotiate () async {
  //   final String url = "https://api.thebharatworks.com/api/negotiations/start";
  //   print("Abhi:- postnegotiate url : $url");
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token') ?? '';
  //   print("Abhi:- print ammount : ${amountController.text.trim()}");
  //
  //   try {
  //     var response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },body: jsonEncode({
  //       "order_id": widget.oderId,
  //       "bidding_offer_id": widget.biddingOfferId,
  //       "service_provider": widget.workerId,
  //       "user": widget.workerId,
  //       "initiator": "user", // or "service_provider"
  //       "offer_amount": amountController.text.trim(),
  //       "message": "Can you do it for 5300?"
  //     }),
  //       /*{
  //       "order_id": widget.oderId,
  //       "bidding_offer_id": widget.biddingOfferId,
  //       "service_provider": widget.workerId,
  //       "user": widget.workerId,
  //       "initiator": "user", // or "service_provider"
  //       "offer_amount": amountController.text.trim(),
  //       "message": "Can you do it for 5300?"
  //     }*/);
  //
  //     if(response.statusCode == 200 || response.statusCode ==201){
  //       print("Abhi:- postNegotiate statusCode : ${response.statusCode}");
  //       print("Abhi:- postNegotiate response : ${response.body}");
  //     }else{
  //       print("Abhi:- else postNegotiate statusCode : ${response.statusCode}");
  //       print("Abhi:- else postNegotiate response : ${response.body}");
  //     }
  //
  //   }catch(e){
  //     print("Abhi:- postNegotiate Exception : $e");
  //   }
  // }
  Future<void> postNegotiate(String amount) async {
    final String url = "https://api.thebharatworks.com/api/negotiations/start";
    print("Abhi:- postnegotiate url : $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- sending amount : $amount");

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
          "user": widget.UserId, // yaha userId pass kar
          "initiator": "user",
          "offer_amount": amount,
          "message": "Can you do it for $amount?"
        }),
      );

       var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- postNegotiate statusCode : ${response.statusCode}");
        print("Abhi:- postNegotiate response : ${response.body}");
        Get.snackbar("Succes", "${responseData['message']}");
      } else {
        print("Abhi:- else postNegotiate statusCode : ${response.statusCode}");
        print("Abhi:- else postNegotiate response : ${response.body}");
      }
    } catch (e) {
      print("Abhi:- postNegotiate Exception : $e");
    }
  }


  @override
  void dispose() {
    amountController.dispose();
    acceptAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:- get Ids negotiation Screen : workerId : ${widget.workerId} userId :${widget.UserId} biddingOfferId : ${widget.biddingOfferId} oderId : ${widget.oderId}");
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
                      padding:
                      EdgeInsets.symmetric(vertical: height * 0.015),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(width * 0.02),
                        border: Border.all(color: Colors.green),
                        color: Colors.white,
                      ),
                      child: Text(
                        "Offer Price",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: width * 0.04,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.015),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isNegotiating = true;
                          isAccepting =
                          false; // Negotiate click hone pe accept band
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: height * 0.015),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(width * 0.02),
                          border: Border.all(color: Colors.green.shade700),
                          color: isNegotiating
                              ? Colors.green.shade700
                              : Colors.white,
                        ),
                        child: Text(
                          "Negotiate",
                          style: GoogleFonts.roboto(
                            color: isNegotiating
                                ? Colors.white
                                : Colors.green.shade700,
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
                // onTap: () {
                //   String amount = amountController.text.trim();
                //   // widget.onNegotiate(amount);
                //   setState(() {
                //     isNegotiating = false;
                //     amountController.clear();
                //   });
                //   postNegotiate ();
                // },
                onTap: () {
                  String amount = amountController.text.trim();

                  if(amount.isEmpty){
                    print("Abhi:- amount empty hai");
                    return;
                  }

                  postNegotiate(amount);  // pehle call karo with value

                  setState(() {
                    isNegotiating = false;
                    amountController.clear();
                  });
                },

                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Send Request",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: width * 0.04,
                    ),
                  ),
                ),
              ),
            ] else if (isAccepting) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  border: Border.all(color: Colors.green),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: acceptAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter your Accept Amount",
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
                  String amount = acceptAmountController.text.trim();
                  // widget.onAccept(amount);
                  setState(() {
                    isAccepting = false;
                    acceptAmountController.clear();
                  });
                },
                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Confirm Accept",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: width * 0.04,
                    ),
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    isAccepting = true;
                    isNegotiating =
                    false; // Accept click hone pe negotiate band
                  });
                },
                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: height * 0.018),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
