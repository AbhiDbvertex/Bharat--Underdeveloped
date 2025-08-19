// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../controllers/userController/workerListViewProfileController.dart';
//
// class WorkerListViewProfileScreen extends StatefulWidget {
//   final String workerId;
//
//   const WorkerListViewProfileScreen({super.key, required this.workerId});
//
//   @override
//   _WorkerListViewProfileScreenState createState() =>
//       _WorkerListViewProfileScreenState();
// }
//
// class _WorkerListViewProfileScreenState
//     extends State<WorkerListViewProfileScreen> {
//   final WorkerListViewProfileController controller =
//   WorkerListViewProfileController();
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWorkerDetails();
//   }
//
//   Future<void> fetchWorkerDetails() async {
//     setState(() => isLoading = true);
//     try {
//       await controller.fetchWorkerProfile(widget.workerId);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching worker details: $e')),
//       );
//     }
//     setState(() => isLoading = false);
//   }
//
//   OutlineInputBorder _customBorder() {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: Colors.grey, width: 1),
//     );
//   }
//
//   Widget _buildReadOnlyTextField(
//       String hint,
//       TextEditingController controller, {
//         TextInputType keyboardType = TextInputType.text,
//       }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           readOnly: true,
//           decoration: InputDecoration(
//             hintText: controller.text.isEmpty ? hint : null,
//             hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//             border: _customBorder(),
//             enabledBorder: _customBorder(),
//             focusedBorder: _customBorder(),
//           ),
//           style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body:
//       isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(
//                     Icons.arrow_back_outlined,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 80),
//                 Text(
//                   "Worker Details",
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             /// Profile Image
//             ClipOval(
//               child:
//               controller.imageUrl != null &&
//                   controller.imageUrl!.isNotEmpty
//                   ? Image.network(
//                 controller.imageUrl!,
//                 width: 120,
//                 height: 120,
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (context, error, stackTrace) => Image.asset(
//                   'assets/images/No_image_available.png',
//                   width: 120,
//                   height: 120,
//                   fit: BoxFit.cover,
//                 ),
//               )
//                   : Image.asset(
//                 'assets/images/No_image_available.png',
//                 width: 120,
//                 height: 120,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             /// Name
//             _buildReadOnlyTextField('Name', controller.nameController),
//             const SizedBox(height: 10),
//
//             /// Phone
//             IntlPhoneField(
//               initialValue: controller.phoneNumber ?? '',
//               decoration: InputDecoration(
//                 hintText:
//                 controller.phoneNumber?.isEmpty ?? true
//                     ? 'Phone Number'
//                     : null,
//                 border: _customBorder(),
//                 enabledBorder: _customBorder(),
//                 focusedBorder: _customBorder(),
//               ),
//               initialCountryCode: 'IN',
//               disableLengthCheck: true,
//               readOnly: true,
//             ),
//             const SizedBox(height: 10),
//
//             /// Aadhaar
//             _buildReadOnlyTextField(
//               'Aadhaar Number',
//               controller.aadhaarController,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//
//             /// DOB
//             _buildReadOnlyTextField(
//               'Date of Birth (YYYY-MM-DD)',
//               controller.dobController,
//             ),
//             const SizedBox(height: 10),
//
//             /// Address
//             _buildReadOnlyTextField(
//               'Address',
//               controller.addressController,
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../Widgets/AppColors.dart';
import '../../controllers/userController/workerListViewProfileController.dart';

class WorkerListViewProfileScreen extends StatefulWidget {
  final String workerId;

  const WorkerListViewProfileScreen({super.key, required this.workerId});

  @override
  _WorkerListViewProfileScreenState createState() =>
      _WorkerListViewProfileScreenState();
}

class _WorkerListViewProfileScreenState
    extends State<WorkerListViewProfileScreen> {
  final WorkerListViewProfileController controller =
  WorkerListViewProfileController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkerDetails();
  }

  Future<void> fetchWorkerDetails() async {
    setState(() => isLoading = true);
    try {
      await controller.fetchWorkerProfile(widget.workerId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching worker details: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  OutlineInputBorder _customBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    );
  }

  Widget _buildReadOnlyTextField(
      String hint,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: true,
          decoration: InputDecoration(
            hintText: controller.text.isEmpty ? hint : null,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: _customBorder(),
            enabledBorder: _customBorder(),
            focusedBorder: _customBorder(),
          ),
          style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_outlined,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 80),
                Text(
                  "Worker Details",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Profile Image
            ClipOval(
              child:
              controller.imageUrl != null &&
                  controller.imageUrl!.isNotEmpty
                  ? Image.network(
                controller.imageUrl!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Image.asset(
                  'assets/images/No_image_available.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(
                'assets/images/No_image_available.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            /// Name
            _buildReadOnlyTextField('Name', controller.nameController),
            const SizedBox(height: 10),

            /// Phone
            IntlPhoneField(
              initialValue: controller.phoneNumber ?? '',
              decoration: InputDecoration(
                hintText:
                controller.phoneNumber?.isEmpty ?? true
                    ? 'Phone Number'
                    : null,
                border: _customBorder(),
                enabledBorder: _customBorder(),
                focusedBorder: _customBorder(),
              ),
              initialCountryCode: 'IN',
              disableLengthCheck: true,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            /// Aadhaar
            _buildReadOnlyTextField(
              'Aadhaar Number',
              controller.aadhaarController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            /// DOB
            _buildReadOnlyTextField(
              'Date of Birth (YYYY-MM-DD)',
              controller.dobController,
            ),
            const SizedBox(height: 10),

            /// Address
            _buildReadOnlyTextField(
              'Address',
              controller.addressController,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
