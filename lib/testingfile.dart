import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});

  final TextEditingController amountController = TextEditingController();

  Future<void> launchUPI(String amount) async {
    final upiId = ""; // apna UPI ID yaha daal
    final name = ""; // apna naam ya app ka naam
    final note = "Payment from app"; // payment note

    final uri = Uri.parse(
      "upi://pay?pa=$upiId&pn=$name&tn=$note&am=$amount&cu=INR",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "UPI app not found!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UPI Payment"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String amt = amountController.text.trim();
                if (amt.isNotEmpty) {
                  launchUPI(amt);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter amount")),
                  );
                }
              },
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
