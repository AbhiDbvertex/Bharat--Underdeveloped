import 'dart:io';
import 'package:flutter/material.dart';

class GalleryModel {
  final String? assetPath;
  final File? file;

  GalleryModel.asset(this.assetPath) : file = null;
  GalleryModel.file(this.file) : assetPath = null;

  bool get isAsset => assetPath != null;

  ImageProvider get imageProvider {
    if (isAsset) {
      return AssetImage(assetPath!) as ImageProvider;
    } else if (file != null) {
      return FileImage(file!);
    } else {
      return const AssetImage('assets/images/gallery.png');
    }
  }

  @override
  String toString() {
    return isAsset ? 'Asset: \$assetPath' : 'File: \${file?.path}';
  }
}