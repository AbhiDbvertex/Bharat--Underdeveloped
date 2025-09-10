// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../Widgets/AppColors.dart';
// import 'AccountScreen.dart';
//
// class AboutScreen extends StatefulWidget {
//   const AboutScreen({super.key});
//
//   @override
//   State<AboutScreen> createState() => _AboutScreenState();
// }
//
// class _AboutScreenState extends State<AboutScreen> {
//   String aboutText = 'Loading...';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAboutUs();
//   }
//
//   Future<void> fetchAboutUs() async {
//     final url = Uri.parse(
//       'https://api.thebharatworks.com/api/CompanyDetails/getAboutUs',
//     );
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("👉 API Response Data: $data");
//
//         setState(() {
//           aboutText = data['content'] ?? '';
//         });
//       } else {
//         setState(() {
//           aboutText = 'Failed to load content.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         aboutText = 'Error: $e';
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(
//                       context,
//                       MaterialPageRoute(builder: (context) => AccountScreen()),
//                     );
//                   },
//                   child: const Icon(Icons.arrow_back_outlined, size: 22),
//                 ),
//                 const SizedBox(width: 100),
//                 Text(
//                   "About Us",
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             Center(
//               child: Image.asset(
//                 'assets/images/terms.png',
//                 height: 140,
//                 width: 200,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: Text(
//                   aboutText,
//                   style: GoogleFonts.roboto(fontSize: 14, height: 1.5),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart'; // ✅ HTML content ke liye import karo

import '../../../Widgets/AppColors.dart';
import 'AccountScreen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String aboutText = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchAboutUs();
  }

  Future<void> fetchAboutUs() async {
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/CompanyDetails/getAboutUs',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("👉 API Response Data: $data");

        setState(() {
          aboutText = data['content'] ?? '';
        });
      } else {
        setState(() {
          aboutText = 'Failed to load content.';
        });
      }
    } catch (e) {
      setState(() {
        aboutText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => AccountScreen()),
                    );
                  },
                  child: const Icon(Icons.arrow_back_outlined, size: 22),
                ),
                const SizedBox(width: 100),
                Text(
                  "About Us",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/terms.png',
                height: 140,
                width: 200,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Html(
                  data: aboutText,
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
            Center(
              child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
                color: Colors.green.shade700,
              ),
              alignment: Alignment.topRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
