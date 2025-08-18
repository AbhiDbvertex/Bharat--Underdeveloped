import 'package:flutter/material.dart';
import '../../models/AccountModel/PremiumModel.dart';

class PremiumController extends ChangeNotifier {
  final List<PremiumModel> plans = [
    PremiumModel(
      duration: '3 months',
      price: '₹999',
      perMonth: '₹333/month',
      features: [
        'Priority customer support',
        'Unlimited task postings',
        'No service fees',
        'Access to premium features and exclusive offers.',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFF47BFB2), Color(0xFF008274)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    PremiumModel(
      duration: '6 months',
      price: '₹2,499',
      perMonth: '₹416/month',
      features: [
        'All 3-month features',
        'Access to premium jobs',
        'Faster verification',
        'Exclusive webinars and workshops',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFFEDDF3F), Color(0xFFBEAF09)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    PremiumModel(
      duration: '1 year',
      price: '₹4,499',
      perMonth: '₹374/month',
      features: [
        'All 6-month features',
        'Dedicated account manager',
        'Year-round discounts & offers',
        'Early access to new features',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFFED7282), Color(0xFFC1041C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  int _selectedPlanIndex = -1;

  int get selectedPlanIndex => _selectedPlanIndex;

  PremiumModel? get selectedPlan =>
      (_selectedPlanIndex != -1) ? plans[_selectedPlanIndex] : null;

  void selectPlan(int index) {
    _selectedPlanIndex = index;
    notifyListeners();
  }
}
