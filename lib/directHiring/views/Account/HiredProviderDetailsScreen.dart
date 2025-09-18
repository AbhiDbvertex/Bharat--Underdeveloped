import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../models/ServiceProviderModel/DirectOrder.dart';

class HiredProviderDetailsScreen extends StatefulWidget {
  final DirectOrder order;
  final String? providerId;
  final String? categreyId;
  final String? subcategreyId;

  const HiredProviderDetailsScreen({
    super.key,
    required this.order,
    this.providerId,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<HiredProviderDetailsScreen> createState() =>
      _HiredProviderDetailsScreenState();
}

class _HiredProviderDetailsScreenState
    extends State<HiredProviderDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? providerDetail;

  @override
  void initState() {
    super.initState();
    if (widget.providerId != null) {
      fetchProviderById(widget.providerId!);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchProviderById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse(
      'https://api.thebharatworks.com/api/user/getServiceProvider/$id',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          providerDetail = jsonData['user'];
          isLoading = false;
        });
      } else {
        print("❌ Provider fetch failed: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Hired Provider Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () => Navigator.pop(context),
                    //       child: const Icon(
                    //         Icons.arrow_back_outlined,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 86),
                    //     Text(
                    //       "Hired Provider Details",
                    //       style: GoogleFonts.roboto(
                    //         fontSize: 20,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //const SizedBox(height: 20),
                    if (widget.order.image != 'local')
                      Image.network(
                        widget.order.image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Image.asset(
                              'assets/images/task.png',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      widget.order.title,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Status: ${widget.order.status}",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: _getStatusColor(widget.order.status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Posted Date: ${widget.order.date}",
                      style: GoogleFonts.roboto(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Description",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.order.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    if (providerDetail != null) ...[
                      Text(
                        "Provider Details",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Name: ${providerDetail!['full_name'] ?? 'Unknown'}",
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                      Text(
                        "Skill: ${providerDetail!['skill'] ?? 'No skill info'}",
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                      Text(
                        "Location: ${providerDetail!['location'] ?? 'No location'}",
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                      Text(
                        "Rating: ${providerDetail!['rating']?.toStringAsFixed(1) ?? 'N/A'}",
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                    ] else if (widget.providerId == null) ...[
                      Text(
                        "No provider assigned yet.",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.brown;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
