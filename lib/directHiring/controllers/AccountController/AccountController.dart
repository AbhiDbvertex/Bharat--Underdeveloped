import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/AccountModel/AccountModel.dart';
import '../../views/Account/AboutScreen.dart';
import '../../views/Account/BankScreen.dart';
import '../../views/Account/CustomerCare.dart';
import '../../views/Account/FAQScreen.dart';
import '../../views/Account/GetPremiumScreen.dart';
import '../../views/Account/PrivacyScreen.dart';
import '../../views/Account/ReferralScreen.dart';
import '../../views/Account/TermsScreen.dart';
import '../../views/Account/service_provider_profile/ServiceProviderProfileScreen.dart';

class AccountController {
  void handleOptionTap(String option, BuildContext context) {
    switch (option) {
      case 'T&C':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Termsscreen()),
        );
        break;
      case 'FAQ':
        Navigator.push(context, MaterialPageRoute(builder: (_) => FAQScreen()));
        break;
      case 'About US':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AboutScreen()),
        );
        break;
      case 'Referral':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReferralScreen()),
        );
        break;
      case 'Bank Details':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BankScreen()),
        );
        break;
      case 'My Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SellerScreen()),
        );
        break;
      case 'Membership':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
        );
        break;
      case 'contact us':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomerCare()),
        );
        break;
      case 'Privacy Policy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Privacyscreen()),
        );
        break;
      default:
        break;
    }
  }

  Future<AccountModel?> fetchUserProfileData(BuildContext context) async {
    const url = '${AppConstants.baseUrl}${ApiEndpoint.accountScreen}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("❌ Token not found. User may not be logged in.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in. Token missing")),
      );
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📦 Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data'];

        if (data != null && data is Map<String, dynamic>) {
          return AccountModel.fromJson(data);
        } else {
          print("⚠️ Invalid data format received.");
          return null;
        }
      } else {
        print("❌ Server Error ${response.statusCode}: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.statusCode}")),
        );
        return null;
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Exception: $e")));
      return null;
    }
  }
}
