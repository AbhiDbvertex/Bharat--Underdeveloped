import 'dart:convert';

import 'package:developer/directHiring/views/User/user_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utility/custom_snack_bar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../ServiceProvider/ServiceDisputeScreen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String? orderProviderId;
  final status;
  final List<dynamic>? paymentHistory;

  const PaymentScreen({
    super.key,
    required this.orderId,
    this.paymentHistory,
    this.orderProviderId,
    this.status,
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
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Add listeners to keep controllers and variables in sync
    // _descriptionController.addListener(() {
    //   setState(() {
    //     _description = _descriptionController.text;
    //   });
    // });
    // _amountController.addListener(() {
    //   setState(() {
    //     _amount = _amountController.text;
    //   });
    // });

    // Load payments from storage
    loadPaymentsFromStorage();

    // Load payment history from widget
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
    final String url =
        '${AppConstants.baseUrl}${ApiEndpoint.darectMarkComplete}';
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
              oderType: "direct",
            ),
          ),
        );
      } else {
        print("Abhi:- else direct-hire Mark as Complete error :- ${response.body}");

        CustomSnackBar.show(
            message: "Failed to mark as complete: ${response.body}",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- Exception Mark as Complete direct-hire : - $e");

      CustomSnackBar.show(
          message: "Error marking as complete: $e", type: SnackBarType.error);
    }
  }

  Future<void> postPaymentRequest(String payId) async {
    setState(() {
      isLoading = true;
    });
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

        CustomSnackBar.show(
            message: responseData['message'] != null
                ? "Payment release request has been successfully sent to the admin."
                : "Payment request successful",
            type: SnackBarType.success);
        Navigator.pop(context);
      } else {
        print("Abhi:- else postPaymentRequest response : ${response.body}");
        print(
            "Abhi:- else postPaymentRequest statuscode : ${response.statusCode}");
        CustomSnackBar.show(
            message: responseData['message'] ?? "Payment request failed",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- postPaymentRequest Exception $e");

      CustomSnackBar.show(
          message: "Error in payment request: $e", type: SnackBarType.error);
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
    print("Abhi:- getOrderId postPaymentRequest ${widget.orderId}");
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
                              Icon(Icons.warning,color: Colors.amber,),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(child: Text("Info. Complete 5 successful online orders to enable COD",style: TextStyle(color: Colors.amber),maxLines: 2,))
                            ],
                          ),
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
                                  },//a,y,a,d,s,s,t,m,m,u,a,n
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  maxLength: 6,
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  // inputFormatters: [
                                   // Allows decimals up to 2 places. For integers only, use:
                                   //  FilteringTextInputFormatter.digitsOnly
                                  //   FilteringTextInputFormatter.allow(
                                  //       RegExp(r'^\d*\.?\d{0,2}$')),
                                  // ],
                                inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),],
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount',
                                    counterText: '',
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
                                onPressed: (_description.isNotEmpty &&
                                        _amount.isNotEmpty &&
                                        double.tryParse(_amount) != null &&
                                        double.tryParse(_amount)! > 0)
                                    ? () => _selectedPayment == 'cod' ? submitPayment() : _showPaymentDialog()
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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
                                    _amountController.clear();
                                    _description = '';
                                    _amount = '';
                                    _selectedPayment = 'cod';
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
                            /*  Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  "₹${payment['amount']}/-",
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
                            ),*/
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex:1,
                                  child: Text(
                                    "${i + 1}.",
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5, //
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
                                  flex: 3,
                                  child: Text(
                                    toTitleCase(payment['release_status'] ==
                                            "release_requested"
                                        ? "Requested"
                                        : payment['release_status'] ??
                                            'Pending'),
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
                                  flex: 3,
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
                                  flex: 1,
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
                                                  BorderRadius.circular(7),
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
          widget.status == 'completed'
              ? Center(
            child: Container(
              height: 35,
              width: 300,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.green)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  Text("  This order has been completed.",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600),),
                ],
              ),
            ),
          ) : widget.status == 'cancelledDispute' ? Center(
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.red),
                  Flexible(
                    child: Text("The order has been cancelled due to a dispute", textAlign: TextAlign.center,maxLines: 2,
                      style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                  ),
                ],
              ),
            ),
          ) : widget.status == 'cancelled' ? Center(
            child: Container(
              height: 35,
              width: 250,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.red),
                  Text("This order is cancelled",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                ],
              ),
            ),
          ) :
          Column(
            children: [
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
                  "Cancel Task and Create Dispute",
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
                  "Mark as Complete",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
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
                  const Text("Date",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat("dd/MM/yyyy").format(DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Time",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat("kk:mm").format(DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("GST (18%)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
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
                  const Text("Total Amount",
                      style: TextStyle(fontWeight: FontWeight.w600)),
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
                            submitPayment();
                          }
                        } else {
                          CustomSnackBar.show(
                              message:
                                  "Please enter a valid description and amount",
                              type: SnackBarType.error);
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
      CustomSnackBar.show(
          message: "Token not found", type: SnackBarType.warning);

      return;
    }

    double baseAmount = double.tryParse(_amount) ?? 0;
    if (baseAmount <= 0) {
      CustomSnackBar.show(
          message: "Please enter a valid amount", type: SnackBarType.error);

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
      print("anjali Response Code: 5 ${response.statusCode}");
      print("anjali Response Body: 6 ${response.body}");
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
            _amountController.clear();
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
      CustomSnackBar.show(message: "Error occurred", type: SnackBarType.error);

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
      CustomSnackBar.show(
          message: "Token not found", type: SnackBarType.warning);
      return;
    }

    double baseAmount = double.tryParse(_amount) ?? 0;
    if (baseAmount <= 0) {
      CustomSnackBar.show(message: "Invalid amount", type: SnackBarType.error);

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
      print("anjali Response Code: 7 ${response.statusCode}");
      print("anjali Response Body: 8 ${response.body}");
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
            _amountController.clear();
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
      CustomSnackBar.show(
          message: "Something went wrong", type: SnackBarType.error);

      print("Abhi:- payment screen get Exception $e");
    }
  }
}
