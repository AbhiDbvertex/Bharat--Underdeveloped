import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/ServiceProviderModel/GalleryModel.dart';

class GalleryController extends ChangeNotifier {
  final List<GalleryModel> _images = List.generate(
    6,
    (index) => GalleryModel.asset('assets/images/gallery.png'),
  );

  List<GalleryModel> get images => _images;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  void deleteImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> uploadImage(File file) async {
    _isUploading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _images.add(GalleryModel.file(file));

    _isUploading = false;
    notifyListeners();
  }
}
