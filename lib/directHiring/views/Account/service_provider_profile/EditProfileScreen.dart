// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:developer/Emergency/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import '../../../../Bidding/controller/bidding_post_task_controller.dart';
// import '../../../../Emergency/User/controllers/emergency_service_controller.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../comm/view_images_screen.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   final String? fullName;
//   final String? skill;
//   final String? categoryId;
//   final List<String>? subCategoryIds;
//   final String? documentUrl;
//   final String? gender;
//   final String? age;
//
//   const EditProfileScreen({
//     super.key,
//     this.fullName,
//     this.skill,
//     this.categoryId,
//     this.subCategoryIds,
//     this.documentUrl,
//     this.gender,
//     this.age,
//   });
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   String? uploadedDocUrl;
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   List<File> selectedImages = [];
//   File? businessImage;
//   final TextEditingController skillController = TextEditingController();
//   bool isLoading = false;
//   String? selectedCategory;
//   List<String> selectedSubCategories = [];
//   List<Map<String, String>> categories = [];
//   List<Map<String, String>> subcategories = [];
//   String? selectedDocumentType;
//   final Map<String, String> _errorTexts = {};
//   String? _selectedGender;
//   String? _shopVisitChoice;
//   LatLng? _selectedLocation;
//   final emergencyServiceController = Get.put(EmergencyServiceController());
//   final postTaskController = Get.put(PostTaskController(), permanent: false);
//
//   final List<Map<String, String>> documentTypes = [
//     {'id': 'pan', 'name': 'PAN Card'},
//     {'id': 'driving', 'name': 'Driving License'},
//     {'id': 'aadhar', 'name': 'Aadhar Card'},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     fullNameController.text = widget.fullName ?? '';
//     ageController.text = widget.age?.toString() ?? '';
//     _selectedGender = widget.gender ?? '';
//     skillController.text = widget.skill ?? '';
//     selectedSubCategories = widget.subCategoryIds ?? [];
//     uploadedDocUrl = widget.documentUrl;
//     bwDebug("updated doc: $uploadedDocUrl");
//
//     fetchCategories().then((_) {
//       bool isValidCategory =
//       categories.any((cat) => cat['id'] == widget.categoryId);
//       setState(() {
//         selectedCategory = isValidCategory ? widget.categoryId : null;
//       });
//       if (selectedCategory != null) {
//         fetchSubCategories(selectedCategory!);
//       }
//     });
//
//     SharedPreferences.getInstance().then((prefs) {
//       String? savedLocation = prefs.getString('selected_location') ?? prefs.getString('address');
//       double? savedLatitude = prefs.getDouble('user_latitude');
//       double? savedLongitude = prefs.getDouble('user_longitude');
//
//       if (savedLocation != null && savedLocation != 'Select Location') {
//         setState(() {
//           emergencyServiceController.googleAddressController.text = savedLocation;
//           emergencyServiceController.latitude.value = savedLatitude;
//           emergencyServiceController.longitude.value = savedLongitude;
//           _selectedLocation = LatLng(savedLatitude ?? 0.0, savedLongitude ?? 0.0);
//           bwDebug("📍 Pre-populated googleAddressController with: $savedLocation");
//         });
//       } else {
//         bwDebug("📍 No valid saved location found");
//       }
//     });
//   }
//
//   Future<void> fetchCategories() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     final res = await http.get(
//       Uri.parse('https://api.thebharatworks.com/api/work-category'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       print("Fetched Categories: ${data['data']}");
//       setState(() {
//         categories = List<Map<String, String>>.from(
//           data['data'].map(
//                 (cat) => {
//               'id': cat['_id'].toString(),
//               'name': cat['name'].toString(),
//             },
//           ),
//         );
//         print("Processed Categories IDs: ${categories.map((c) => c['id']).toList()}");
//       });
//     } else {
//       print("Failed to fetch categories: ${res.statusCode} - ${res.body}");
//     }
//   }
//
//   Future<void> fetchSubCategories(String categoryId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     final res = await http.get(
//       Uri.parse('https://api.thebharatworks.com/api/subcategories/$categoryId'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       setState(() {
//         subcategories = List<Map<String, String>>.from(
//           data['data'].map(
//                 (sub) => {
//               'id': sub['_id'].toString(),
//               'name': sub['name'].toString(),
//             },
//           ),
//         );
//         selectedSubCategories = selectedSubCategories
//             .where((id) => subcategories.any((sub) => sub['id'] == id))
//             .toList();
//       });
//     }
//   }
//
//   Future<void> pickBusinessImage() async {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickBusinessImage(true);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickBusinessImage(false);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickBusinessImage(bool fromCamera) async {
//     try {
//       final XFile? image = await _picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           businessImage = File(image.path);
//         });
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Error selecting image: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }
//
//   Future<void> pickDocument() async {
//     if (selectedDocumentType == null) {
//       Get.snackbar(
//         'Error',
//         'Please select document type first',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     int currentCount = selectedImages.length + (uploadedDocUrl != null ? 1 : 0);
//     if (currentCount >= 2) {
//       Get.snackbar(
//         'Warning',
//         'You can select only 2 documents total',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   pickImages(fromCamera: true);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   pickImages(fromCamera: false);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> pickImages({required bool fromCamera}) async {
//     try {
//       int currentCount = selectedImages.length + (uploadedDocUrl != null ? 1 : 0);
//       if (currentCount >= 2) {
//         Get.snackbar(
//           'Warning',
//           'You can select only 2 documents total',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: const Icon(Icons.warning, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//         return;
//       }
//
//       if (fromCamera) {
//         final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//         if (image != null) {
//           if (currentCount + 1 > 2) {
//             Get.snackbar(
//               'Warning',
//               'You can select only 2 documents total',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//               icon: const Icon(Icons.warning, color: Colors.white),
//               margin: const EdgeInsets.all(10),
//               duration: const Duration(seconds: 3),
//             );
//             return;
//           }
//           setState(() {
//             selectedImages.add(File(image.path));
//             uploadedDocUrl = null;
//           });
//         }
//       } else {
//         final List<XFile> images = await _picker.pickMultiImage();
//         if (images.isEmpty) return;
//         if (currentCount + images.length > 2) {
//           Get.snackbar(
//             'Warning',
//             'You can select only 2 documents total',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             icon: const Icon(Icons.warning, color: Colors.white),
//             margin: const EdgeInsets.all(10),
//             duration: const Duration(seconds: 3),
//           );
//           return;
//         }
//         setState(() {
//           selectedImages.addAll(images.map((img) => File(img.path)));
//           uploadedDocUrl = null;
//         });
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Error selecting images: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }
//
//   void deleteBusinessImage() {
//     setState(() {
//       businessImage = null;
//     });
//   }
//
//   void deleteDocument(File file) {
//     setState(() {
//       selectedImages.remove(file);
//     });
//   }
//
//   void deleteUploadedDoc() {
//     setState(() {
//       uploadedDocUrl = null;
//       selectedDocumentType = null;
//     });
//   }
//
//   Future<void> onSavePressed() async {
//     if (selectedCategory == null ||
//         selectedSubCategories.isEmpty ||
//         skillController.text.isEmpty ||
//         fullNameController.text.isEmpty ||
//         ageController.text.isEmpty ||
//         _selectedGender == null ||
//         selectedDocumentType == null ||
//         (selectedImages.isEmpty && uploadedDocUrl == null) ||
//         (_shopVisitChoice == 'yes' && (emergencyServiceController.googleAddressController.text.isEmpty || _selectedLocation == null))) {
//       if (!mounted) return;
//       Get.snackbar(
//         'Error',
//         'Please fill all fields, upload at least one document, and select a location if shop visit is enabled',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     if (int.tryParse(ageController.text.trim()) == null ||
//         int.parse(ageController.text.trim()) < 18) {
//       Get.snackbar(
//         'Error',
//         'Invalid age, You must be at least 18 years old',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     if (selectedImages.length < 1 || selectedImages.length > 2) {
//       Get.snackbar(
//         'Warning',
//         'Please upload at least 1 and at most 2 documents',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       var request = http.MultipartRequest(
//         'PUT',
//         Uri.parse('https://api.thebharatworks.com/api/user/updateUserDetails'),
//       );
//
//       request.headers['Authorization'] = 'Bearer $token';
//
//       for (var file in selectedImages) {
//         request.files.add(
//           await http.MultipartFile.fromPath('documents', file.path),
//         );
//       }
//
//       if (businessImage != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath('businessImage', businessImage!.path),
//         );
//       }
//
//       request.fields['category_id'] = selectedCategory!;
//       request.fields['subcategory_ids'] = jsonEncode(selectedSubCategories);
//       request.fields['skill'] = skillController.text.trim();
//       request.fields['full_name'] = fullNameController.text.trim();
//       request.fields['age'] = ageController.text.trim();
//       request.fields['gender'] = _selectedGender!;
//       request.fields['documentName'] = selectedDocumentType!;
//       request.fields['isShop'] = _shopVisitChoice == 'yes' ? 'true' : 'false';
//
//       if (_shopVisitChoice == 'yes' && _selectedLocation != null) {
//         request.fields['businessAddress'] = jsonEncode({
//           "address": emergencyServiceController.googleAddressController.text,
//           "latitude": emergencyServiceController.latitude.value?.toString() ?? '',
//           "longitude": emergencyServiceController.longitude.value?.toString() ?? '',
//         });
//       }
//
//       var streamedResponse = await request.send().timeout(
//         const Duration(seconds: 20),
//         onTimeout: () => throw TimeoutException("Request timed out"),
//       );
//
//       final res = await http.Response.fromStream(streamedResponse);
//
//       if (!mounted) return;
//
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         Get.snackbar(
//           'Success',
//           'Profile updated successfully',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           icon: const Icon(Icons.check_circle, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//         await Future.delayed(const Duration(milliseconds: 500));
//         if (mounted) Navigator.pop(context, true);
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed: ${res.body}',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: const Icon(Icons.error, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       print("Abhi:- update serviceprovider profile $e");
//       Get.snackbar(
//         'Error',
//         'Error: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   void showSubcategoryDialog() {
//     List<String> tempSelected = List.from(selectedSubCategories);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text("Select Subcategories"),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: subcategories.length,
//                   itemBuilder: (context, index) {
//                     final sub = subcategories[index];
//                     final subId = sub['id']!;
//                     return CheckboxListTile(
//                       title: Text(sub['name'] ?? ''),
//                       value: tempSelected.contains(subId),
//                       onChanged: (bool? value) {
//                         setDialogState(() {
//                           if (value == true) {
//                             tempSelected.add(subId);
//                           } else {
//                             tempSelected.remove(subId);
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       selectedSubCategories = tempSelected;
//                     });
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Done"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget buildSimpleDropdown({
//     required String? value,
//     required String hint,
//     required List<Map<String, String>> items,
//     required void Function(String?) onChanged,
//   }) {
//     String? validValue =
//     items.any((item) => item['id'] == value) ? value : null;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade400),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: validValue,
//         isExpanded: true,
//         decoration: const InputDecoration(border: InputBorder.none),
//         hint: Text(hint, style: const TextStyle(color: Colors.grey)),
//         items: items
//             .map(
//               (item) => DropdownMenuItem(
//             value: item['id'],
//             child: Text(item['name'] ?? ''),
//           ),
//         )
//             .toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }
//
//   Widget buildGenderRadio() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Select Your Gender"),
//         const SizedBox(height: 5),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Radio<String>(
//               value: 'male',
//               groupValue: _selectedGender,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedGender = value;
//                   _errorTexts.remove('gender');
//                 });
//               },
//             ),
//             const Text('Male'),
//             Radio<String>(
//               value: 'female',
//               groupValue: _selectedGender,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedGender = value;
//                   _errorTexts.remove('gender');
//                 });
//               },
//             ),
//             const Text('Female'),
//             Radio<String>(
//               value: 'other',
//               groupValue: _selectedGender,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedGender = value;
//                   _errorTexts.remove('gender');
//                 });
//               },
//             ),
//             const Text('Other'),
//           ],
//         ),
//         if (_errorTexts['gender'] != null)
//           Text(
//             _errorTexts['gender']!,
//             style: const TextStyle(color: AppColors.red, fontSize: 11),
//           ),
//       ],
//     );
//   }
//
//   Widget buildShopVisitRadio() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Do you want to go to his shop?"),
//         const SizedBox(height: 5),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Radio<String>(
//               value: 'yes',
//               groupValue: _shopVisitChoice,
//               onChanged: (value) {
//                 setState(() {
//                   _shopVisitChoice = value;
//                 });
//               },
//             ),
//             const Text('Yes'),
//             Radio<String>(
//               value: 'no',
//               groupValue: _shopVisitChoice,
//               onChanged: (value) {
//                 setState(() {
//                   _shopVisitChoice = value;
//                   emergencyServiceController.googleAddressController.clear();
//                   _selectedLocation = null;
//                   emergencyServiceController.latitude.value = null;
//                   emergencyServiceController.longitude.value = null;
//                 });
//               },
//             ),
//             const Text('No'),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget buildBusinessImageUpload() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade400),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: ElevatedButton.icon(
//               onPressed: pickBusinessImage,
//               icon: const Icon(Icons.add_a_photo, color: Colors.white),
//               label: const Text('Upload Business Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green[700],
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           if (businessImage != null)
//             Stack(
//               children: [
//                 InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ViewImage(
//                           imageUrl: businessImage!.path,
//                           title: "Business Image",
//                         ),
//                       ),
//                     );
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       businessImage!,
//                       height: 100,
//                       width: 100,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           height: 100,
//                           width: 100,
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.broken_image),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 4,
//                   right: 4,
//                   child: GestureDetector(
//                     onTap: deleteBusinessImage,
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.black54,
//                       ),
//                       padding: const EdgeInsets.all(4),
//                       child: const Icon(Icons.close, color: Colors.white, size: 18),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool canAddMore = (selectedImages.length + (uploadedDocUrl != null ? 1 : 0)) < 2;
//
//     print("Abhi: get age: ${widget.age} gender: ${widget.gender}");
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: const Text(
//           "User Update Profile",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         leading: const BackButton(color: Colors.black),
//         actions: [],
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryGreen,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: IntrinsicHeight(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20),
//                     buildBusinessImageUpload(),
//                     const SizedBox(height: 15),
//                     TextFormField(
//                       controller: fullNameController,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
//                       ],
//                       decoration: InputDecoration(
//                         labelText: "Full Name",
//                         hintText: 'Enter Full Name',
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     TextFormField(
//                       controller: ageController,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [LengthLimitingTextInputFormatter(2)],
//                       decoration: InputDecoration(
//                         labelText: "Age",
//                         hintText: 'Enter your age',
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     buildGenderRadio(),
//                     const SizedBox(height: 15),
//                     buildShopVisitRadio(),
//                     const SizedBox(height: 15),
//                     if (_shopVisitChoice == 'yes')
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: emergencyServiceController.googleAddressController,
//                               readOnly: true,
//                               onTap: () => postTaskController.navigateToLocationScreen(),
//                               decoration: InputDecoration(
//                                 labelText: "Shop Address",
//                                 hintText: 'Select location from map',
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 suffixIcon: const Icon(Icons.map),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           InkWell(
//                             onTap: () => postTaskController.navigateToLocationScreen(),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryGreen,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Text(
//                                 "Change location",
//                                 style: TextStyle(color: Colors.white, fontSize: 14),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 15),
//                     buildSimpleDropdown(
//                       hint: 'Select Category',
//                       value: selectedCategory,
//                       items: categories,
//                       onChanged: (val) {
//                         setState(() {
//                           selectedCategory = val;
//                           selectedSubCategories.clear();
//                           subcategories = [];
//                         });
//                         if (val != null) fetchSubCategories(val);
//                       },
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (selectedCategory != null) {
//                           showSubcategoryDialog();
//                         } else {
//                           Get.snackbar(
//                             'Warning',
//                             'Please select category first',
//                             snackPosition: SnackPosition.TOP,
//                             backgroundColor: Colors.orange,
//                             colorText: Colors.white,
//                             icon: const Icon(Icons.warning, color: Colors.white),
//                             margin: const EdgeInsets.all(10),
//                             duration: const Duration(seconds: 3),
//                           );
//                         }
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 16,
//                           horizontal: 12,
//                         ),
//                         margin: const EdgeInsets.only(bottom: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.grey.shade400),
//                         ),
//                         child: Text(
//                           selectedSubCategories.isEmpty
//                               ? 'Select Subcategories'
//                               : subcategories
//                               .where(
//                                 (sub) => selectedSubCategories.contains(
//                               sub['id'],
//                             ),
//                           )
//                               .map((sub) => sub['name'])
//                               .join(', '),
//                           style: const TextStyle(color: Colors.black),
//                         ),
//                       ),
//                     ),
//                     TextFormField(
//                       controller: skillController,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[a-z,0-9\./ ]')),
//                       ],
//                       maxLines: 4,
//                       decoration: InputDecoration(
//                         labelText: "Skills",
//                         hintText: 'Enter Skills',
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       "Note: Please upload your valid document (PAN Card, Driving Licence, Aadhaar Card, etc.)",
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     const SizedBox(height: 12),
//                     buildSimpleDropdown(
//                       hint: 'Select Document Type',
//                       value: selectedDocumentType,
//                       items: documentTypes,
//                       onChanged: (val) {
//                         setState(() {
//                           selectedDocumentType = val;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade400),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(
//                             child: ElevatedButton.icon(
//                               onPressed: canAddMore ? pickDocument : null,
//                               icon: const Icon(Icons.add, color: Colors.white),
//                               label: const Text('Upload Document'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: canAddMore ? Colors.green[700] : Colors.grey,
//                                 foregroundColor: Colors.white,
//                                 minimumSize: const Size(double.infinity, 48),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Wrap(
//                             spacing: 8,
//                             children: [
//                               if (uploadedDocUrl != null)
//                                 Stack(
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => ViewImage(
//                                               imageUrl: uploadedDocUrl!,
//                                               title: "Document",
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: Image.network(
//                                           uploadedDocUrl!,
//                                           height: 100,
//                                           width: 100,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) {
//                                             return Container(
//                                               height: 100,
//                                               width: 100,
//                                               color: Colors.grey[300],
//                                               child: const Icon(Icons.broken_image),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 4,
//                                       right: 4,
//                                       child: GestureDetector(
//                                         onTap: deleteUploadedDoc,
//                                         child: Container(
//                                           decoration: const BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.black54,
//                                           ),
//                                           padding: const EdgeInsets.all(4),
//                                           child: const Icon(Icons.close, color: Colors.white, size: 18),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ...selectedImages.map((file) {
//                                 return Stack(
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => ViewImage(
//                                               imageUrl: file.path,
//                                               title: "Image",
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: Image.file(
//                                           file,
//                                           height: 100,
//                                           width: 100,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) {
//                                             return Container(
//                                               height: 100,
//                                               width: 100,
//                                               color: Colors.grey[300],
//                                               child: const Icon(Icons.broken_image),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 4,
//                                       right: 4,
//                                       child: GestureDetector(
//                                         onTap: () => deleteDocument(file),
//                                         child: Container(
//                                           decoration: const BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.black54,
//                                           ),
//                                           padding: const EdgeInsets.all(4),
//                                           child: const Icon(Icons.close, color: Colors.white, size: 18),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               }).toList(),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: isLoading ? null : onSavePressed,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green[800],
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 130,
//                           vertical: 16,
//                         ),
//                       ),
//                       child: isLoading
//                           ? const SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                         ),
//                       )
//                           : const Text(
//                         "UPDATE",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class MapPickerScreen extends StatefulWidget {
//   final LatLng initialPosition;
//   final Function(LatLng, String) onLocationSelected;
//
//   const MapPickerScreen({
//     super.key,
//     required this.initialPosition,
//     required this.onLocationSelected,
//   });
//
//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }
//
// class _MapPickerScreenState extends State<MapPickerScreen> {
//   GoogleMapController? mapController;
//   LatLng _selectedPosition;
//   bool _isLoadingAddress = false;
//   final emergencyServiceController = Get.find<EmergencyServiceController>();
//
//   _MapPickerScreenState() : _selectedPosition = const LatLng(0, 0);
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedPosition = widget.initialPosition;
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar(
//         'Error',
//         'Please enable location services.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar(
//           'Error',
//           'Location permission denied.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: const Icon(Icons.warning, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       Get.snackbar(
//         'Error',
//         'Location permissions are permanently denied.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       if (mounted) {
//         setState(() {
//           _selectedPosition = LatLng(position.latitude, position.longitude);
//           emergencyServiceController.latitude.value = position.latitude;
//           emergencyServiceController.longitude.value = position.longitude;
//         });
//         mapController?.animateCamera(
//           CameraUpdate.newLatLngZoom(_selectedPosition, 15.0),
//         );
//         await _getAddressFromLatLng(position.latitude, position.longitude);
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Unable to get location: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(double lat, double lng) async {
//     try {
//       if (_isLoadingAddress) return;
//       setState(() {
//         _isLoadingAddress = true;
//         emergencyServiceController.googleAddressController.text = "Fetching address...";
//       });
//
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (mounted) {
//         setState(() {
//           _isLoadingAddress = false;
//           if (placemarks.isNotEmpty) {
//             final place = placemarks.first;
//             emergencyServiceController.googleAddressController.text =
//                 "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
//                     .replaceAll(', ,', ',')
//                     .trim();
//           } else {
//             emergencyServiceController.googleAddressController.text = 'No address found.';
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingAddress = false;
//           emergencyServiceController.googleAddressController.text = 'Coordinates: $lat, $lng (No address found)';
//         });
//         Get.snackbar(
//           'Error',
//           'Error fetching address: $e',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: const Icon(Icons.error, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//       }
//     }
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     if (_selectedPosition != const LatLng(0, 0)) {
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_selectedPosition, 15.0),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Location'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               widget.onLocationSelected(
//                 _selectedPosition,
//                 emergencyServiceController.googleAddressController.text,
//               );
//               Navigator.pop(context);
//             },
//             child: const Text('Done', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _selectedPosition,
//               zoom: 15,
//             ),
//             onMapCreated: _onMapCreated,
//             onTap: (LatLng position) {
//               setState(() {
//                 _selectedPosition = position;
//                 emergencyServiceController.latitude.value = position.latitude;
//                 emergencyServiceController.longitude.value = position.longitude;
//               });
//               _getAddressFromLatLng(position.latitude, position.longitude);
//             },
//             markers: {
//               Marker(
//                 markerId: const MarkerId('selected-location'),
//                 position: _selectedPosition,
//               ),
//             },
//           ),
//           const Positioned(
//             top: 10,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Icon(Icons.location_pin, color: Colors.red, size: 40),
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               color: Colors.white.withOpacity(0.8),
//               child: Text(
//                 _isLoadingAddress
//                     ? 'Fetching address...'
//                     : emergencyServiceController.googleAddressController.text,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../Bidding/controller/bidding_post_task_controller.dart';
import '../../../../Emergency/User/controllers/emergency_service_controller.dart';
import '../../../../Widgets/AppColors.dart';
import '../../comm/view_images_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? skill;
  final String? categoryId;
  final List<String>? subCategoryIds;
  final List<String>? subEmergencyCategoryIds;
  final String? documentUrl;
  final String? gender;
  final String? age;

  const EditProfileScreen({
    super.key,
    this.fullName,
    this.skill,
    this.categoryId,
    this.subCategoryIds,
    this.subEmergencyCategoryIds,
    this.documentUrl,
    this.gender,
    this.age,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? uploadedDocUrl;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController customDocNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];
  File? businessImage;
  final TextEditingController skillController = TextEditingController();
  bool isLoading = false;
  String? selectedCategory;
  List<String> selectedSubCategories = [];
  List<String> selectedSubEmergencyCategories = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, String>> subEmergencyCategories = [];
  String? selectedDocumentType;
  final Map<String, String> _errorTexts = {};
  String? _selectedGender;
  String? _shopVisitChoice;
  LatLng? _selectedLocation;
  final emergencyServiceController = Get.put(EmergencyServiceController());
  final postTaskController = Get.put(PostTaskController(), permanent: false);

  final List<Map<String, String>> documentTypes = [
    {'id': 'pan', 'name': 'PAN Card'},
    {'id': 'driving', 'name': 'Driving License'},
    {'id': 'aadhar', 'name': 'Aadhar Card'},
    {'id': 'govtId', 'name': 'or any Govt.ID'},
  ];

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.fullName ?? '';
    ageController.text = widget.age?.toString() ?? '';
    _selectedGender = widget.gender ?? '';
    skillController.text = widget.skill ?? '';
    selectedSubCategories = widget.subCategoryIds ?? [];
    selectedSubCategories = widget.subEmergencyCategoryIds ?? [];
    uploadedDocUrl = widget.documentUrl;
    bwDebug("updated doc: $uploadedDocUrl");

    fetchCategories().then((_) {
      bool isValidCategory =
      categories.any((cat) => cat['id'] == widget.categoryId);
      setState(() {
        selectedCategory = isValidCategory ? widget.categoryId : null;
      });
      if (selectedCategory != null) {
        fetchSubCategories(selectedCategory!);
        fetchSubEmergencyCategories(selectedCategory!);
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      String? savedLocation = prefs.getString('selected_location') ??
          prefs.getString('address');
      double? savedLatitude = prefs.getDouble('user_latitude');
      double? savedLongitude = prefs.getDouble('user_longitude');

      if (savedLocation != null && savedLocation != 'Select Location') {
        setState(() {
          emergencyServiceController.googleAddressController.text =
              savedLocation;
          emergencyServiceController.latitude.value = savedLatitude;
          emergencyServiceController.longitude.value = savedLongitude;
          _selectedLocation =
              LatLng(savedLatitude ?? 0.0, savedLongitude ?? 0.0);
          bwDebug(
              "📍 Pre-populated googleAddressController with: $savedLocation");
        });
      } else {
        bwDebug("📍 No valid saved location found");
      }
    });
  }

  Future<void> fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/work-category'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print("Fetched Categories: ${data['data']}");
      setState(() {
        categories = List<Map<String, String>>.from(
          data['data'].map(
                (cat) =>
            {
              'id': cat['_id'].toString(),
              'name': cat['name'].toString(),
            },
          ),
        );
        print("Processed Categories IDs: ${categories.map((c) => c['id'])
            .toList()}");
      });
    } else {
      print("Failed to fetch categories: ${res.statusCode} - ${res.body}");
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/subcategories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        subcategories = List<Map<String, String>>.from(
          data['data'].map(
                (sub) =>
            {
              'id': sub['_id'].toString(),
              'name': sub['name'].toString(),
            },
          ),
        );
        selectedSubCategories = selectedSubCategories
            .where((id) => subcategories.any((sub) => sub['id'] == id))
            .toList();
      });
    }
  }

  Future<void> fetchSubEmergencyCategories(String categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse(
          'https://api.thebharatworks.com/api/emergency/subcategories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        subEmergencyCategories = List<Map<String, String>>.from(
          data['data'].map(
                (sub) =>
            {
              'id': sub['_id'].toString(),
              'name': sub['name'].toString(),
            },
          ),
        );
        selectedSubEmergencyCategories = selectedSubEmergencyCategories
            .where((id) => subcategories.any((sub) => sub['id'] == id))
            .toList();
      });
    }
  }

  Future<void> pickBusinessImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickBusinessImage(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickBusinessImage(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickBusinessImage(bool fromCamera) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery);
      if (image != null) {
        setState(() {
          businessImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error selecting image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> pickDocument() async {
    if (selectedDocumentType == null) {
      Get.snackbar(
        'Error',
        'Please select document type first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    int currentCount = selectedImages.length + (uploadedDocUrl != null ? 1 : 0);
    if (currentCount >= 2) {
      Get.snackbar(
        'Warning',
        'You can select only 2 documents total',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImages(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImages(fromCamera: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImages({required bool fromCamera}) async {
    try {
      int currentCount = selectedImages.length +
          (uploadedDocUrl != null ? 1 : 0);
      if (currentCount >= 2) {
        Get.snackbar(
          'Warning',
          'You can select only 2 documents total',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (fromCamera) {
        final XFile? image = await _picker.pickImage(
            source: ImageSource.camera);
        if (image != null) {
          if (currentCount + 1 > 2) {
            Get.snackbar(
              'Warning',
              'You can select only 2 documents total',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              icon: const Icon(Icons.warning, color: Colors.white),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            );
            return;
          }
          setState(() {
            selectedImages.add(File(image.path));
            uploadedDocUrl = null;
          });
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isEmpty) return;
        if (currentCount + images.length > 2) {
          Get.snackbar(
            'Warning',
            'You can select only 2 documents total',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(Icons.warning, color: Colors.white),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          );
          return;
        }
        setState(() {
          selectedImages.addAll(images.map((img) => File(img.path)));
          uploadedDocUrl = null;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error selecting images: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void deleteBusinessImage() {
    setState(() {
      businessImage = null;
    });
  }

  void deleteDocument(File file) {
    setState(() {
      selectedImages.remove(file);
    });
  }

  void deleteUploadedDoc() {
    setState(() {
      uploadedDocUrl = null;
      selectedDocumentType = null;
      customDocNameController.clear();
    });
  }

  Future<void> onSavePressed() async {
    if (selectedCategory == null ||
        selectedSubCategories.isEmpty ||
        selectedSubEmergencyCategories.isEmpty ||
        skillController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        ageController.text.isEmpty ||
        _selectedGender == null ||
        selectedDocumentType == null ||
        (selectedImages.isEmpty && uploadedDocUrl == null) ||
        (_shopVisitChoice == 'yes' &&
            (emergencyServiceController.googleAddressController.text.isEmpty ||
                _selectedLocation == null)) ||
        (selectedDocumentType == 'govtId' &&
            customDocNameController.text.isEmpty)) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        selectedDocumentType == 'govtId' && customDocNameController.text.isEmpty
            ? 'Please enter the custom document name'
            : 'Please fill all fields, upload at least one document, and select a location if shop visit is enabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (int.tryParse(ageController.text.trim()) == null ||
        int.parse(ageController.text.trim()) < 18) {
      Get.snackbar(
        'Error',
        'Invalid age, You must be at least 18 years old',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (selectedImages.length < 1 || selectedImages.length > 2) {
      Get.snackbar(
        'Warning',
        'Please upload at least 1 and at most 2 documents',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://api.thebharatworks.com/api/user/updateUserDetails'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      for (var file in selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath('documents', file.path),
        );
      }

      if (businessImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
              'businessImage', businessImage!.path),
        );
      }

      request.fields['category_id'] = selectedCategory!;
      request.fields['subcategory_ids'] = jsonEncode(selectedSubCategories);
      request.fields['emergencySubcategory_ids'] =
          jsonEncode(selectedSubEmergencyCategories);
      request.fields['skill'] = skillController.text.trim();
      request.fields['full_name'] = fullNameController.text.trim();
      request.fields['age'] = ageController.text.trim();
      request.fields['gender'] = _selectedGender!;
      request.fields['documentName'] = selectedDocumentType == 'govtId'
          ? customDocNameController.text.trim()
          : selectedDocumentType!;
      request.fields['isShop'] = _shopVisitChoice == 'yes' ? 'true' : 'false';

      if (_shopVisitChoice == 'yes' && _selectedLocation != null) {
        request.fields['businessAddress'] = jsonEncode({
          "address": emergencyServiceController.googleAddressController.text,
          "latitude": emergencyServiceController.latitude.value?.toString() ??
              '',
          "longitude": emergencyServiceController.longitude.value?.toString() ??
              '',
        });
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("Request timed out"),
      );

      final res = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context, true);
      } else {
        Get.snackbar(
          'Error',
          'Failed: ${res.body}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print("Abhi:- update serviceprovider profile $e");
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showSubcategoryDialog() {
    List<String> tempSelected = List.from(selectedSubCategories);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Subcategories"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final sub = subcategories[index];
                    final subId = sub['id']!;
                    return CheckboxListTile(
                      title: Text(sub['name'] ?? ''),
                      value: tempSelected.contains(subId),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelected.add(subId);
                          } else {
                            tempSelected.remove(subId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSubCategories = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showSubEmergencyCategoryDialog() {
    List<String> tempSelected = List.from(selectedSubEmergencyCategories);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Emergency Subcategories"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subEmergencyCategories.length,
                  itemBuilder: (context, index) {
                    final sub = subEmergencyCategories[index];
                    final subId = sub['id']!;
                    return CheckboxListTile(
                      title: Text(sub['name'] ?? ''),
                      value: tempSelected.contains(subId),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelected.add(subId);
                          } else {
                            tempSelected.remove(subId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSubEmergencyCategories = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildSimpleDropdown({
    required String? value,
    required String hint,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    String? validValue =
    items.any((item) => item['id'] == value) ? value : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<String>(
        value: validValue,
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: items
            .map(
              (item) =>
              DropdownMenuItem(
                value: item['id'],
                child: Text(item['name'] ?? ''),
              ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildGenderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Your Gender"),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: 'male',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _errorTexts.remove('gender');
                });
              },
            ),
            const Text('Male'),
            Radio<String>(
              value: 'female',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _errorTexts.remove('gender');
                });
              },
            ),
            const Text('Female'),
            Radio<String>(
              value: 'other',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _errorTexts.remove('gender');
                });
              },
            ),
            const Text('Other'),
          ],
        ),
        if (_errorTexts['gender'] != null)
          Text(
            _errorTexts['gender']!,
            style: const TextStyle(color: AppColors.red, fontSize: 11),
          ),
      ],
    );
  }

  Widget buildShopVisitRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Do you have any shop ?"),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: 'yes',
              groupValue: _shopVisitChoice,
              onChanged: (value) {
                setState(() {
                  _shopVisitChoice = value;
                });
              },
            ),
            const Text('Yes'),
            Radio<String>(
              value: 'no',
              groupValue: _shopVisitChoice,
              onChanged: (value) {
                setState(() {
                  _shopVisitChoice = value;
                  emergencyServiceController.googleAddressController.clear();
                  _selectedLocation = null;
                  emergencyServiceController.latitude.value = null;
                  emergencyServiceController.longitude.value = null;
                });
              },
            ),
            const Text('No'),
          ],
        ),
      ],
    );
  }

  Widget buildBusinessImageUpload() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton.icon(
              onPressed: pickBusinessImage,
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: const Text('Upload Business Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (businessImage != null)
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ViewImage(
                              imageUrl: businessImage!.path,
                              title: "Business Image",
                            ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      businessImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: deleteBusinessImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                          Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canAddMore = (selectedImages.length +
        (uploadedDocUrl != null ? 1 : 0)) < 2;

    print("Abhi: get age: ${widget.age} gender: ${widget.gender}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "User Update Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    buildBusinessImageUpload(),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: fullNameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        hintText: 'Enter Full Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      decoration: InputDecoration(
                        labelText: "Age",
                        hintText: 'Enter your age',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildGenderRadio(),
                    const SizedBox(height: 15),
                    buildShopVisitRadio(),
                    const SizedBox(height: 15),
                    if (_shopVisitChoice == 'yes')
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(
                    //         controller: emergencyServiceController.googleAddressController,
                    //         readOnly: true,
                    //         onTap: () => postTaskController.navigateToLocationScreen(),
                    //         decoration: InputDecoration(
                    //           labelText: "Shop Address",
                    //           hintText: 'Select location from map',
                    //           filled: true,
                    //           fillColor: Colors.white,
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(15),
                    //           ),
                    //           suffixIcon: const Icon(Icons.map),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     InkWell(
                    //       onTap: () => postTaskController.navigateToLocationScreen(),
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    //         decoration: BoxDecoration(
                    //           color: AppColors.primaryGreen,
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: const Text(
                    //           "Change location",
                    //           style: TextStyle(color: Colors.white, fontSize: 14),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () =>
                                  postTaskController.navigateToLocationScreen(),
                              child: Container(
                                height: 25,
                                width: 120,
                                // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    "Change location",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 7,),
                          TextFormField(
                            controller: emergencyServiceController
                                .googleAddressController,
                            readOnly: true,
                            // onTap: () => postTaskController.navigateToLocationScreen(),
                            decoration: InputDecoration(
                              labelText: "Shop Address",
                              hintText: 'Select location from map',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              suffixIcon: const Icon(Icons.map),
                            ),
                          ),
                          const SizedBox(width: 10),

                        ],
                      ),
                    const SizedBox(height: 15),
                    buildSimpleDropdown(
                      hint: 'Select Category',
                      value: selectedCategory,
                      items: categories,
                      onChanged: (val)  {
                        setState(() {
                          selectedCategory = val;
                          selectedSubCategories.clear();
                          subcategories = [];
                        });
                        if (val != null) {
                          fetchSubCategories(val);
                          fetchSubEmergencyCategories(val);
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null) {
                          showSubcategoryDialog();
                        } else {
                          Get.snackbar(
                            'Warning',
                            'Please select category first',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            icon: const Icon(
                                Icons.warning, color: Colors.white),
                            margin: const EdgeInsets.all(10),
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          selectedSubCategories.isEmpty
                              ? 'Select Subcategories'
                              : subcategories
                              .where(
                                (sub) =>
                                selectedSubCategories.contains(
                                  sub['id'],
                                ),
                          )
                              .map((sub) => sub['name'])
                              .join(', '),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null) {
                          showSubEmergencyCategoryDialog();
                        } else {
                          Get.snackbar(
                            'Warning',
                            'Please select category first',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            icon: const Icon(
                                Icons.warning, color: Colors.white),
                            margin: const EdgeInsets.all(10),
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          selectedSubEmergencyCategories.isEmpty
                              ? 'Select Emergency Subcategories'
                              : subEmergencyCategories
                              .where(
                                (sub) =>
                                selectedSubEmergencyCategories.contains(
                                  sub['id'],
                                ),
                          )
                              .map((sub) => sub['name'])
                              .join(', '),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: skillController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(
                            r'[a-z,0-9\./ ]')),
                      ],
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Skills",
                        hintText: 'Enter Skills',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Note: Please upload your valid document (PAN Card, Driving Licence, Aadhaar Card, etc.)",
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    buildSimpleDropdown(
                      hint: 'Select Document Type',
                      value: selectedDocumentType,
                      items: documentTypes,
                      onChanged: (val) {
                        setState(() {
                          selectedDocumentType = val;
                          customDocNameController.clear();
                        });
                      },
                    ),
                    if (selectedDocumentType == 'govtId') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: customDocNameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9 ]')),
                        ],
                        decoration: InputDecoration(
                          labelText: "Custom Document Name",
                          hintText: 'Enter document name (e.g., Voter ID)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: canAddMore ? pickDocument : null,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Upload Document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAddMore
                                    ? Colors.green[700]
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (uploadedDocUrl != null)
                                Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ViewImage(
                                                  imageUrl: uploadedDocUrl!,
                                                  title: "Document",
                                                ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          uploadedDocUrl!,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                  Icons.broken_image),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: deleteUploadedDoc,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                              Icons.close, color: Colors.white,
                                              size: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ...selectedImages.map((file) {
                                return Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ViewImage(
                                                  imageUrl: file.path,
                                                  title: "Image",
                                                ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          file,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                  Icons.broken_image),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => deleteDocument(file),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                              Icons.close, color: Colors.white,
                                              size: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : onSavePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 130,
                          vertical: 16,
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "UPDATE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// MapPickerScreen (Shared between both screens)
// class MapPickerScreen extends StatefulWidget {
//   final LatLng initialPosition;
//   final Function(LatLng, String) onLocationSelected;
//
//   const MapPickerScreen({
//     super.key,
//     required this.initialPosition,
//     required this.onLocationSelected,
//   });
//
//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }
//
// class _MapPickerScreenState extends State<MapPickerScreen> {
//   GoogleMapController? mapController;
//   LatLng _selectedPosition;
//   bool _isLoadingAddress = false;
//   final emergencyServiceController = Get.find<EmergencyServiceController>();
//
//   _MapPickerScreenState() : _selectedPosition = const LatLng(0, 0);
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedPosition = widget.initialPosition;
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar(
//         'Error',
//         'Please enable location services.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar(
//           'Error',
//           'Location permission denied.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: const Icon(Icons.warning, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       Get.snackbar(
//         'Error',
//         'Location permissions are permanently denied.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.warning, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       if (mounted) {
//         setState(() {
//           _selectedPosition = LatLng(position.latitude, position.longitude);
//           emergencyServiceController.latitude.value = position.latitude;
//           emergencyServiceController.longitude.value = position.longitude;
//         });
//         mapController?.animateCamera(
//           CameraUpdate.newLatLngZoom(_selectedPosition, 15.0),
//         );
//         await _getAddressFromLatLng(position.latitude, position.longitude);
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Unable to get location: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(double lat, double lng) async {
//     try {
//       if (_isLoadingAddress) return;
//       setState(() {
//         _isLoadingAddress = true;
//         emergencyServiceController.googleAddressController.text = "Fetching address...";
//       });
//
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (mounted) {
//         setState(() {
//           _isLoadingAddress = false;
//           if (placemarks.isNotEmpty) {
//             final place = placemarks.first;
//             emergencyServiceController.googleAddressController.text =
//                 "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
//                     .replaceAll(', ,', ',')
//                     .trim();
//           } else {
//             emergencyServiceController.googleAddressController.text = 'No address found.';
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingAddress = false;
//           emergencyServiceController.googleAddressController.text = 'Coordinates: $lat, $lng (No address found)';
//         });
//         Get.snackbar(
//           'Error',
//           'Error fetching address: $e',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           icon: const Icon(Icons.error, color: Colors.white),
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 3),
//         );
//       }
//     }
//   }