// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../../Widgets/AppColors.dart';
// import 'AccountScreen.dart';
//
// class Privacyscreen extends StatefulWidget {
//   const Privacyscreen({super.key});
//
//   @override
//   State<Privacyscreen> createState() => _PrivacyscreenState();
// }
//
// class _PrivacyscreenState extends State<Privacyscreen> {
//   String termsText = '';
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTerms();
//   }
//
//   Future<void> fetchTerms() async {
//     final url = Uri.parse(
//       'https://api.thebharatworks.com/api/CompanyDetails/getPrivacyPolicy',
//     );
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         setState(() {
//           termsText = result['content'] ?? '';
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           termsText = 'Failed to load terms.';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         termsText = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body:
//           isLoading
//               ? Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pop(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AccountScreen(),
//                               ),
//                             );
//                           },
//                           child: const Icon(
//                             Icons.arrow_back_outlined,
//                             size: 22,
//                           ),
//                         ),
//                         const SizedBox(width: 80),
//                         Text(
//                           "Privacy Policy",
//                           style: GoogleFonts.roboto(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                     Center(
//                       child: Image.asset(
//                         'assets/images/terms.png',
//                         height: 140,
//                         width: 200,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 14),
//                         child: Text(
//                           termsText,
//                           style: GoogleFonts.roboto(fontSize: 14, height: 1.5),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';  // ✅ import karo
import '../../../../Widgets/AppColors.dart';
import 'AccountScreen.dart';

class Privacyscreen extends StatefulWidget {
  const Privacyscreen({super.key});

  @override
  State<Privacyscreen> createState() => _PrivacyscreenState();
}

class _PrivacyscreenState extends State<Privacyscreen> {
  String termsText = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/CompanyDetails/getPrivacyPolicy',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          termsText = result['content'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          termsText = 'Failed to load terms.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        termsText = 'Error: $e';
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
        title: const Text("Privacy Policy",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     GestureDetector(
            //       onTap: () {
            //         Navigator.pop(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => AccountScreen(),
            //           ),
            //         );
            //       },
            //       child: const Icon(
            //         Icons.arrow_back_outlined,
            //         size: 22,
            //       ),
            //     ),
            //     const SizedBox(width: 80),
            //     Text(
            //       "Privacy Policy",
            //       style: GoogleFonts.roboto(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/terms.png',
                height: 140,
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Html(
                  data: termsText,  // ✅ HTML content dikhega
                  style: {
                    "body": Style(
                      fontSize: FontSize(14.0),
                      lineHeight: LineHeight.number(1.5),
                      fontFamily: GoogleFonts.roboto().fontFamily,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
