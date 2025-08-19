import 'package:flutter/material.dart';

class PremiumModel {
  final String duration;
  final String price;
  final String perMonth;
  final List<String> features;
  final Gradient gradient;

  PremiumModel({
    required this.duration,
    required this.price,
    required this.perMonth,
    required this.features,
    required this.gradient,
  });
}
