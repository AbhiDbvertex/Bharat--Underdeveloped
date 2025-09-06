import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Widgets/AppColors.dart';
import '../../ServiceProvider/FullImageScreen.dart';
class ReviewImagesScreen extends StatelessWidget {
  final List<String> images;

  const ReviewImagesScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        toolbarHeight: 0, // Hide default AppBar space
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(width: 70),
              Text(
                "User Reviews",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Divider(),

          Expanded(
            child:
                images.isNotEmpty
                    ? GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> FullImageScreen(imageUrl: images[index],),));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        );
                      },
                    )//
                    : const Center(
                      child: Text("No customer review images available."),
                    ),
          ),
        ],
      ),
    );
  }
}
