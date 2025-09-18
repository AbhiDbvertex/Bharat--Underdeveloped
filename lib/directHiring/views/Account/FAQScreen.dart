import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Widgets/AppColors.dart';
import 'AccountScreen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? _expandedIndex;
  List<Map<String, String>> faqs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    const String apiUrl = "https://api.thebharatworks.com/api/userFaq";

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("❌ Token not found. User may not be logged in.");
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true && data["data"] != null) {
          final List<dynamic> fetchedFaqs = data["data"];
          setState(() {
            faqs =
                fetchedFaqs.map<Map<String, String>>((faq) {
                  return {
                    "question": faq["question"] ?? "No Question",
                    "answer": faq["answer"] ?? "No Answer",
                  };
                }).toList();
          });
        }
      } else {
        debugPrint(
          "⚠️ Server Error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Help & FAQ",
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
                  children: [
                    // const SizedBox(height: 10),
                    // Row(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () {
                    //         Navigator.pop(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => const AccountScreen(),
                    //           ),
                    //         );
                    //       },
                    //       child: const Icon(
                    //         Icons.arrow_back_outlined,
                    //         size: 22,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 100),
                    //     Text(
                    //       "Help & FAQ",
                    //       style: GoogleFonts.roboto(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),
                    Image.asset('assets/images/help.png', fit: BoxFit.contain),
                    const SizedBox(height: 30),
                    ...faqs.asMap().entries.map((entry) {
                      int index = entry.key;
                      var faq = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          key: Key('$index-${_expandedIndex ?? -1}'),
                          initiallyExpanded: _expandedIndex == index,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _expandedIndex = expanded ? index : null;
                            });
                          },
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          title: Text(
                            faq['question']!,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF191A1D),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              child: Text(
                                faq['answer']!,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF191A1D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }
}
