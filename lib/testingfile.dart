//
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
// runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
// const MyApp({super.key});
//
// @override
// Widget build(BuildContext context) {
// return MaterialApp(
// home: const PaymentScreen(),
// theme: ThemeData(primarySwatch: Colors.blue),
// );
// }
// }
//
// class PaymentScreen extends StatefulWidget {
// const PaymentScreen({super.key});
//
// @override
// _PaymentScreenState createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
// final TextEditingController _amountController = TextEditingController();
// final String myUpiId = 'yourupi@okhdfcbank'; // Apna UPI ID daal
// bool _isPhonePeAvailable = false;
//
// @override
// void initState() {
// super.initState();
// _checkPhonePeAvailability();
// }
//
// // Check karo ki PhonePe installed hai
// Future<void> _checkPhonePeAvailability() async {
// const phonePeScheme = 'phonepe';
// bool canLaunch = await canLaunchUrl(Uri.parse('$phonePeScheme://'));
// setState(() {
// _isPhonePeAvailable = canLaunch;
// });
// }
//
// // PhonePe payment start karo
// Future<void> _payWithPhonePe() async {
// final amount = _amountController.text.trim();
// if (amount.isEmpty) {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('Amount enter kar pehle')),
// );
// return;
// }
//
// final double? amountValue = double.tryParse(amount);
// if (amountValue == null || amountValue <= 0) {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('Valid amount daal')),
// );
// return;
// }
//
// // UPI URI bana
// final uri = Uri.parse(
// 'upi://pay?pa=$myUpiId&pn=Your%20Name&am=$amountValue&cu=INR&tn=Payment%20for%20My%20App',
// );
//
// try {
// if (await canLaunchUrl(uri)) {
// await launchUrl(uri, mode: LaunchMode.externalApplication);
// } else {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('PhonePe open nahi ho raha, check kar')),
// );
// }
// } catch (e) {
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(content: Text('Error: $e')),
// );
// }
// }
//
// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(title: const Text('PhonePe Payment')),
// body: Padding(
// padding: const EdgeInsets.all(16.0),
// child: Column(
// children: [
// TextField(
// controller: _amountController,
// decoration: const InputDecoration(
// labelText: 'Enter Amount',
// border: OutlineInputBorder(),
// ),
// keyboardType: TextInputType.number,
// ),
// const SizedBox(height: 20),
// if (_isPhonePeAvailable)
// ElevatedButton(
// onPressed: _payWithPhonePe,
// child: const Text('Pay with PhonePe'),
// )
// else
// const Text(
// 'PhonePe install kar pehle',
// style: TextStyle(color: Colors.red),
// ),
// ],
// ),
// ),
// );
// }
// }
