// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Consent/ApiEndpoint.dart';
// import '../../Consent/app_constants.dart';
// import '../../models/AccountModel/CustomerCareModel.dart';
//
// class CustomerCareController {
//   final model = CustomerCareModel();
//
//   final contactController = TextEditingController();
//   final descriptionController = TextEditingController();
//
//   void toggleContactMethod(bool isEmail) {
//     model.isEmailSelected = isEmail;
//   }
//
//   void updateSubject(String? subject) {
//     model.selectedSubject = subject;
//   }
//
//   bool validateForm(BuildContext context) {
//     if (model.selectedSubject == null || contactController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all required fields')),
//       );
//       return false;
//     }
//     return true;
//   }
//
//   /// Contact via Email
//   void emailForm(BuildContext context, VoidCallback refreshView) async {
//     if (!validateForm(context)) return;
//
//     model.contactDetail = contactController.text;
//     model.description = descriptionController.text;
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Token missing. Please login again.')),
//       );
//       return;
//     }
//
//     final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.customerCare}');
//
//     final body = {
//       "subject": model.selectedSubject,
//       "email": model.contactDetail,
//       "message": model.description,
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(body),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Email submitted successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Server Error: ${response.statusCode}\n${response.body}',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Request Error: $e')));
//     }
//
//     contactController.clear();
//     descriptionController.clear();
//     model.reset();
//     refreshView();
//   }
//
//   /// Contact via Call
//   void callForm(BuildContext context, VoidCallback refreshView) async {
//     if (!validateForm(context)) return;
//
//     model.contactDetail = contactController.text;
//     model.description = descriptionController.text;
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Token missing. Please login again.')),
//       );
//       return;
//     }
//
//     final url = Uri.parse(
//       'https://api.thebharatworks.com/api/CompanyDetails/contact/mobile',
//     );
//
//     final body = {
//       "subject": model.selectedSubject,
//       "mobile_number": model.contactDetail,
//       "message": model.description,
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(body),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Call request submitted successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Server Error: ${response.statusCode}\n${response.body}',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Request Error: $e')));
//     }
//
//     contactController.clear();
//     descriptionController.clear();
//     model.reset();
//     refreshView();
//   }
// }

import 'dart:convert';

import 'package:developer/utility/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/AccountModel/CustomerCareModel.dart';

class CustomerCareController {
  final model = CustomerCareModel();
  final contactController = TextEditingController();
  final descriptionController = TextEditingController();

  void toggleContactMethod(bool isEmail) {
    model.isEmailSelected = isEmail;
    contactController.clear(); // Clear contact field when toggling
    descriptionController.clear(); // Clear description when toggling
    model.selectedSubject = null; // Reset subject when toggling
  }

  void updateSubject(String? subject) {
    model.selectedSubject = subject;
  }

  bool validateForm(BuildContext context) {
    // Check if subject is selected
    if (model.selectedSubject == null) {
       CustomSnackBar.show(
          message:'Please select a subject' ,
          type: SnackBarType.error
      );

      return false;
    }

    // Check if contact field is empty
    if (contactController.text.isEmpty) {

       CustomSnackBar.show(
          message:  'Please enter ${model.isEmailSelected ? 'email address' : 'contact number'}' ,
          type: SnackBarType.error
      );

      return false;
    }

    // Email validation
    if (model.isEmailSelected) {
      if (!RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(contactController.text)) {

         CustomSnackBar.show(
            message: 'Please enter a valid email address',
            type: SnackBarType.error
        );

        return false;
      }
    }
    // Phone number validation
    else {
      if (!RegExp(r'^[0-9]+$').hasMatch(contactController.text)) {
         CustomSnackBar.show(
            message: 'Phone number must contain only digits',
            type: SnackBarType.error
        );

        return false;
      }
      if (contactController.text.length != 10) {

         CustomSnackBar.show(
            message: 'Phone number must be 10 digits',
            type: SnackBarType.error
        );

        return false;
      }
    }

    // Check if description is empty
    if (descriptionController.text.isEmpty) {

       CustomSnackBar.show(
          message:'Please enter a description' ,
          type: SnackBarType.error
      );

      return false;
    }

    return true;
  }

  /// Contact via Email
  Future<void> emailForm(BuildContext context, VoidCallback refreshView) async {
    if (!validateForm(context)) return;

    model.contactDetail = contactController.text;
    model.description = descriptionController.text;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {

       CustomSnackBar.show(
          message: 'Token missing. Please login again.',
          type: SnackBarType.error
      );

      return;
    }

    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.customerCare}');

    final body = {
      "subject": model.selectedSubject,
      "email": model.contactDetail,
      "message": model.description,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
         CustomSnackBar.show(
            message: 'Email submitted successfully!',
            type: SnackBarType.success
        );
        contactController.clear();
        descriptionController.clear();
        model.reset();
        refreshView();
      } else {

         CustomSnackBar.show(
            message: 'Server Error: ${response.statusCode}\n${response.body}',
            type: SnackBarType.error
        );
      }
    } catch (e) {
      CustomSnackBar.show( message: 'Request Error: $e',type: SnackBarType.error);
    }
  }

  /// Contact via Call
  Future<void> callForm(BuildContext context, VoidCallback refreshView) async {
    if (!validateForm(context)) return;

    model.contactDetail = contactController.text;
    model.description = descriptionController.text;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {

       CustomSnackBar.show(
          message:'Token missing. Please login again.' ,
          type: SnackBarType.error
      );
      return;
    }

    final url = Uri.parse(
      'https://api.thebharatworks.com/api/CompanyDetails/contact/mobile',
    );

    final body = {
      "subject": model.selectedSubject,
      "mobile_number": model.contactDetail,
      "message": model.description,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

         CustomSnackBar.show(
            message: 'Call request submitted successfully!',
            type: SnackBarType.success
        );

        contactController.clear();
        descriptionController.clear();
        model.reset();
        refreshView();
      } else {

         CustomSnackBar.show(
            message: 'Server Error: ${response.statusCode}\n${response.body}',
            type: SnackBarType.error
        );

      }
    } catch (e) {
       CustomSnackBar.show(
          message: 'Request Error: $e',
          type: SnackBarType.error
      );

    }
  }
}
