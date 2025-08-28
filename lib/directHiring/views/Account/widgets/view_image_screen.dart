

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewCarosuleImage extends StatelessWidget {
  final String imagePath;

  const ViewCarosuleImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imagePath),
          minScale: PhotoViewComputedScale.contained,   
          maxScale: PhotoViewComputedScale.covered * 3,
          enableRotation: false,
          heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
          loadingBuilder: (context, event) => SizedBox(height: 50,width: 50,child: CircularProgressIndicator(color: Colors.green,)),
        ),
      ),
    );
  }
}
