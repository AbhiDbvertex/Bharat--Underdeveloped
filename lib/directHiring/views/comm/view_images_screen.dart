import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../Widgets/AppColors.dart';

class ViewImage extends StatelessWidget {
  final dynamic imageUrl; // Changed to dynamic to accept String or List<String>
  final String? title ;

  const ViewImage({super.key, required this.imageUrl,this.title});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text(title??"Profile Image",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Center(child: _buildImageView()),
    );
  }

  Widget _buildImageView() {
    // Check if imageUrl is a single String
    if (imageUrl is String) {
      return InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Image not available',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          },
        ),
      );
    }
    // Check if imageUrl is a List<String>
    else if (imageUrl is List<String>) {
      return PageView.builder(
        itemCount: imageUrl.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl[index],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Image not available',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    // Fallback for invalid input
    return const Center(
      child: Text(
        'Invalid image data',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
