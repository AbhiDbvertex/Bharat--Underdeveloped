// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../../controllers/AccountController/CustomerCareController.dart';
// import 'AccountScreen.dart';
//
// class CustomerCare extends StatefulWidget {
//   const CustomerCare({super.key});
//
//   @override
//   State<CustomerCare> createState() => _CustomerCareState();
// }
//
// class _CustomerCareState extends State<CustomerCare> {
//   final CustomerCareController controller = CustomerCareController();
//
//   void _refresh() => setState(() {});
//
//   @override
//   Widget build(BuildContext context) {
//     final borderStyle = OutlineInputBorder(
//       borderRadius: BorderRadius.circular(5),
//       borderSide: const BorderSide(color: Colors.grey),
//     );
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 10,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(
//                         context,
//                         MaterialPageRoute(builder: (_) => AccountScreen()),
//                       );
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.only(left: 8.0),
//                       child: Icon(Icons.arrow_back, size: 25),
//                     ),
//                   ),
//                   const SizedBox(width: 90),
//                   Text(
//                     "User Care",
//                     style: GoogleFonts.roboto(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Please Feel Free To Talk To Us If You Have Any\nQuestions. We Endeavour To Answer Within 24 Hours.',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey),
//               ),
//               const SizedBox(height: 30),
//
//               // Toggle Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildToggle('Contact via Email', true),
//                   _buildToggle('Contact via Call', false),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 controller.model.isEmailSelected
//                     ? 'Send us an email for support or inquiries.'
//                     : "Schedule a call, and we'll get back to you\nwithin 15-20 hours.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.roboto(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Dropdown
//               DropdownButtonFormField<String>(
//                 value: controller.model.selectedSubject,
//                 hint: const Text('Select Subject'),
//                 onChanged: (value) {
//                   controller.updateSubject(value);
//                   _refresh();
//                 },
//                 items:
//                     controller.model.subjects.map((subject) {
//                       return DropdownMenuItem<String>(
//                         value: subject,
//                         child: Text(subject),
//                       );
//                     }).toList(),
//                 decoration: InputDecoration(
//                   border: borderStyle,
//                   enabledBorder: borderStyle,
//                   focusedBorder: borderStyle,
//                 ),
//               ),
//
//               const SizedBox(height: 15),
//
//               // Email/Phone Input
//               TextField(
//                 controller: controller.contactController,
//                 keyboardType:
//                     controller.model.isEmailSelected
//                         ? TextInputType.emailAddress
//                         : TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText:
//                       controller.model.isEmailSelected
//                           ? 'Email Address'
//                           : 'Contact Number',
//                   hintText:
//                       controller.model.isEmailSelected
//                           ? 'Enter your email'
//                           : 'Enter your contact number',
//                   border: borderStyle,
//                   enabledBorder: borderStyle,
//                   focusedBorder: borderStyle,
//                 ),
//               ),
//
//               const SizedBox(height: 15),
//
//               // Description
//               TextField(
//                 controller: controller.descriptionController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText: 'Description',
//                   border: borderStyle,
//                   enabledBorder: borderStyle,
//                   focusedBorder: borderStyle,
//                 ),
//               ),
//
//               const SizedBox(height: 60),
//
//               InkWell(
//                 onTap: () {
//                   if (controller.model.isEmailSelected) {
//                     controller.emailForm(context, _refresh);
//                   } else {
//                     controller.callForm(context, _refresh);
//                   }
//                 },
//                 child: Container(
//                   height: 50,
//                   width: 300,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.green.shade700,
//                   ),
//                   child: Center(
//                     child: Text(
//                       controller.model.isEmailSelected
//                           ? 'Submit'
//                           : 'Schedule a Call',
//                       style: GoogleFonts.roboto(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // Submit Button
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildToggle(String title, bool isEmail) {
//     bool selected = controller.model.isEmailSelected == isEmail;
//     return GestureDetector(
//       onTap: () {
//         controller.toggleContactMethod(isEmail);
//         _refresh();
//       },
//       child: Container(
//         height: 50,
//         width: 155,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: selected ? Colors.green.shade700 : Colors.grey.shade300,
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: GoogleFonts.roboto(
//               color: selected ? Colors.white : Colors.black,
//               fontWeight: FontWeight.w600,
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/CustomerCareController.dart';
import 'AccountScreen.dart';

class CustomerCare extends StatefulWidget {
  const CustomerCare({super.key});

  @override
  State<CustomerCare> createState() => _CustomerCareState();
}

class _CustomerCareState extends State<CustomerCare> {
  final CustomerCareController controller = CustomerCareController();
  final _formKey = GlobalKey<FormState>();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.arrow_back, size: 25),
                      ),
                    ),
                    const SizedBox(width: 90),
                    Text(
                      "User Care",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Please Feel Free To Talk To Us If You Have Any\nQuestions. We Endeavour To Answer Within 24 Hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                // Toggle Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToggle('Contact via Email', true),
                    _buildToggle('Contact via Call', false),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  controller.model.isEmailSelected
                      ? 'Send us an email for support or inquiries.'
                      : "Schedule a call, and we'll get back to you\nwithin 15-20 hours.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown
                DropdownButtonFormField<String>(
                  value: controller.model.selectedSubject,
                  hint: const Text('Select Subject'),
                  onChanged: (value) {
                    controller.updateSubject(value);
                    _refresh();
                  },
                  items:
                  controller.model.subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: borderStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: borderStyle,
                  ),
                  validator:
                      (value) =>
                  value == null ? 'Please select a subject' : null,
                ),
                const SizedBox(height: 15),
                // Email/Phone Input
                TextFormField(
                  controller: controller.contactController,
                  keyboardType:
                  controller.model.isEmailSelected
                      ? TextInputType.emailAddress
                      : TextInputType.number,
                  maxLength:
                  controller.model.isEmailSelected
                      ? null
                      : 10, // Updated to enforce 10 digits
                  decoration: InputDecoration(
                    labelText:
                    controller.model.isEmailSelected
                        ? 'Email Address'
                        : 'Contact Number',
                    hintText:
                    controller.model.isEmailSelected
                        ? 'Enter your email'
                        : 'Enter your contact number',
                    border: borderStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: borderStyle,
                    counterText: controller.model.isEmailSelected ? '' : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (controller.model.isEmailSelected) {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    } else {
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Description
                TextFormField(
                  controller: controller.descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    border: borderStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: borderStyle,
                  ),
                  validator:
                      (value) =>
                  value == null || value.isEmpty
                      ? 'Please enter a description'
                      : null,
                ),
                const SizedBox(height: 60),
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      if (controller.model.isEmailSelected) {
                        controller.emailForm(context, _refresh);
                      } else {
                        controller.callForm(context, _refresh);
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.shade700,
                    ),
                    child: Center(
                      child: Text(
                        controller.model.isEmailSelected
                            ? 'Submit'
                            : 'Schedule a Call',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String title, bool isEmail) {
    bool selected = controller.model.isEmailSelected == isEmail;
    return GestureDetector(
      onTap: () {
        controller.toggleContactMethod(isEmail);
        _refresh();
      },
      child: Container(
        height: 50,
        width: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? Colors.green.shade700 : Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.roboto(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
