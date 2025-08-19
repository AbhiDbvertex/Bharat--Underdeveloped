import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewImage extends StatelessWidget {
  final dynamic imageUrl; // Changed to dynamic to accept String or List<String>

  const ViewImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile Image",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.black,
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
