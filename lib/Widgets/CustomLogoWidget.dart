import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomLogoWidget extends StatelessWidget {
  final String imagePath;
  final String title;

  const CustomLogoWidget({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min, // Avoid extra space vertically
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: height*0.3,
          height: 88,
          fit: BoxFit.contain,
        ),
        Transform.translate(
          offset: const Offset(0, -10), // Moves text 4px up to overlap/remove spacing
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                height: 1.0, // Removes extra line spacing
                letterSpacing: 1.8,
              ),
              textAlign: TextAlign.center,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
