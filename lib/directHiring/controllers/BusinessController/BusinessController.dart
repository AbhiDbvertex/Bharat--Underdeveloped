import 'package:flutter/material.dart';

import '../../models/userModel/Worker.dart';

class BusinessController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  final List<Worker> workers = [
    const Worker(name: "Mohan Sharma", role: "Plumber", rating: 4.2),
    const Worker(name: "Mohan Sharma", role: "Plumber", rating: 4.2),
    Worker(name: "Mohan Sharma", role: "Plumber", rating: 4.2),
  ];

  final List<Map<String, String>> categories = const [
    {"name": "Bandwala", "imagePath": 'assets/images/band.png'},
    {"name": "Plumber", "imagePath": 'assets/images/plumb.png'},
    {"name": "Carpenter", "imagePath": 'assets/images/carp1.png'},
    {"name": "Painter", "imagePath": 'assets/images/pain.png'},
    {"name": "Electrician", "imagePath": 'assets/images/elec.png'},
  ];
}
