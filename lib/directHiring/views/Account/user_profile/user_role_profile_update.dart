/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../Bidding/controller/bidding_post_task_controller.dart';
import '../../../../Emergency/User/controllers/emergency_service_controller.dart';
import '../../../../Widgets/AppColors.dart';
import '../../comm/view_images_screen.dart';

// RoleEditProfileScreen
class RoleEditProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? skill;
  final String? categoryId;
  final List<String>? subCategoryIds;
  final List<String>? emergencySubCategoryIds;
  final String? documentUrl;
  final updateBothrequest;
  final role;
  final comeEditScreen;

  const RoleEditProfileScreen({
    super.key,
    this.fullName,
    this.skill,
    this.categoryId,
    this.subCategoryIds,
    this.emergencySubCategoryIds,
    this.documentUrl,
    this.updateBothrequest,
    this.role,
    this.comeEditScreen,
  });

  @override
  State<RoleEditProfileScreen> createState() => _RoleEditProfileScreenState();
}

class _RoleEditProfileScreenState extends State<RoleEditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController customDocNameController = TextEditingController();
  List<File> selectedFiles = [];
  File? businessImage;
  bool isLoading = false;
  String? selectedDocumentType;
  String? selectedCategory;
  List<String> selectedSubCategories = [];
  List<String> selectedEmergencySubCategories = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, String>> emergencySubCategories = [];
  String? uploadedDocUrl;
  String? _selectedGender;
  String? _shopVisitChoice="no";
  final Map<String, String> _errorTexts = {};
  LatLng? _selectedLocation;
  final emergencyServiceController = Get.put(EmergencyServiceController());
  final postTaskController = Get.put(PostTaskController(), permanent: false);
  final List<Map<String, String>> documentTypes = [
    {'id': 'drivinglicense', 'name': 'Driving License'},
    {'id': 'passport', 'name': 'Passport'},
    {'id': 'driving', 'name': 'Driving License'},
    {'id': 'aadhaar', 'name': 'Aadhaar Card'},
    {'id': 'govtId', 'name': 'or any Govt.ID'},
  ];

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.fullName ?? '';
    skillController.text = widget.skill ?? '';
    selectedCategory = widget.categoryId;
    selectedSubCategories = widget.subCategoryIds ?? [];
    selectedEmergencySubCategories = widget.emergencySubCategoryIds ?? [];
    uploadedDocUrl = widget.documentUrl;

    fetchCategories().then((_) {
      bool isValidCategory =
      categories.any((cat) => cat['id'] == widget.categoryId);
      setState(() {
        selectedCategory = isValidCategory ? widget.categoryId : null;
      });
      if (selectedCategory != null) {
        fetchSubCategories(selectedCategory!);
        fetchEmergencySubCategories(selectedCategory!);
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      String? savedLocation = prefs.getString('selected_location') ?? prefs.getString('address');
      double? savedLatitude = prefs.getDouble('user_latitude');
      double? savedLongitude = prefs.getDouble('user_longitude');

      if (savedLocation != null && savedLocation != 'Select Location') {
        setState(() {
          emergencyServiceController.googleAddressController.text = savedLocation;
          emergencyServiceController.latitude.value = savedLatitude;
          emergencyServiceController.longitude.value = savedLongitude;
          _selectedLocation = LatLng(savedLatitude ?? 0.0, savedLongitude ?? 0.0);
          bwDebug("📍 Pre-populated googleAddressController with: $savedLocation");
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
      setState(() {
        categories = List<Map<String, String>>.from(
          data['data'].map(
                (cat) => {
              'id': cat['_id'].toString(),
              'name': cat['name'].toString(),
            },
          ),
        );
      });
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
                (sub) => {
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
  Future<void> fetchEmergencySubCategories(String categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/emergency/subcategories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        emergencySubCategories = List<Map<String, String>>.from(
          data['data'].map(
                (sub) => {
              'id': sub['_id'].toString(),
              'name': sub['name'].toString(),
            },
          ),
        );
        selectedEmergencySubCategories = selectedEmergencySubCategories
            .where((id) => emergencySubCategories.any((sub) => sub['id'] == id))
            .toList();
      });
    }
  }
  Future<void> pickBusinessImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      setState(() {
        businessImage = File(result.files.first.path!);
      });
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

    int currentCount = selectedFiles.length + (uploadedDocUrl != null ? 1 : 0);
    if (currentCount >= 2) {
      Get.snackbar(
        'Warning',
        'You can select only 2 documents total',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final newFiles = result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
      if (currentCount + newFiles.length > 2) {
        Get.snackbar(
          'Warning',
          'You can select only 2 documents total',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
        return;
      }
      setState(() {
        selectedFiles.addAll(newFiles);
        uploadedDocUrl = null;
      });
    }
  }

  void deleteDocument(File file) {
    setState(() {
      selectedFiles.remove(file);
    });
  }

  void deleteUploadedDoc() {
    setState(() {
      uploadedDocUrl = null;
      selectedDocumentType = null;
      customDocNameController.clear();
    });
  }

  void deleteBusinessImage() {
    setState(() {
      businessImage = null;
    });
  }

  Future<void> switchRoleRequest() async {
    final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- switchRoleRequest response ${response.body}");
        print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
      } else {
        print("Abhi:- else switchRoleRequest response ${response.body}");
        print("Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
      }
    } catch (e) {
      print("Abhi:- get Exception $e");
    }
  }

  Future<void> onSavePressed() async {
    if (selectedCategory == null ||
        selectedSubCategories.isEmpty ||
        selectedEmergencySubCategories.isEmpty||
        skillController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        ageController.text.isEmpty ||
        _selectedGender == null ||
        selectedDocumentType == null ||
        (selectedFiles.isEmpty && uploadedDocUrl == null) ||
        (_shopVisitChoice == 'yes' && (emergencyServiceController.googleAddressController.text.isEmpty || _selectedLocation == null)) ||
        (selectedDocumentType == 'govtId' && customDocNameController.text.isEmpty)) {
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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (selectedFiles.length < 1 || selectedFiles.length > 2) {
      Get.snackbar(
        'Warning',
        'Please upload at least 1 and at most 2 documents',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
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

      for (var file in selectedFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('documents', file.path),
        );
      }

      if (businessImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('businessImage', businessImage!.path),
        );
      }

      request.fields['category_id'] = selectedCategory!;
      request.fields['subcategory_ids'] = jsonEncode(selectedSubCategories);
      request.fields['emergencySubcategory_ids'] = jsonEncode(selectedEmergencySubCategories);
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
          "latitude": emergencyServiceController.latitude.value?.toString() ?? '',
          "longitude": emergencyServiceController.longitude.value?.toString() ?? '',
        });
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("Request timed out"),
      );

      final res = await http.Response.fromStream(streamedResponse);

      print("Abhi:- post upload detail screen data:- ${res.body}");
      print("Abhi:- post upload detail screen code:- ${res.statusCode}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (widget.comeEditScreen == "editScreen") {
          Navigator.pop(context, true);
        }
        Navigator.pop(context, true);
        switchRoleRequest();
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed: ${res.body}',
          snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
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
  void showEmergencySubcategoryDialog() {
    List<String> tempSelected = List.from(selectedEmergencySubCategories);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Emergency SubCategory"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: emergencySubCategories.length,
                  itemBuilder: (context, index) {
                    final sub = emergencySubCategories[index];
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
                      selectedEmergencySubCategories = tempSelected;
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
              (item) => DropdownMenuItem(
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
                        builder: (_) => ViewImage(
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
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
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
    bool canAddMore = (selectedFiles.length + (uploadedDocUrl != null ? 1 : 0)) < 2;

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
                     */
/* Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () => postTaskController.navigateToLocationScreen(),
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
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 7,),
                          TextFormField(
                            controller: emergencyServiceController.googleAddressController,
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
                      ),*//*

                      Column(
                        children: [
                          Obx(
                                () => GestureDetector(
                              onTap: postTaskController.navigateToLocationScreen,
                              child: AbsorbPointer( // Disable direct typing
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: null,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Shop Address",
                                    hintText: 'Select location from map',
                                    suffixIcon: const Icon(Icons.map, color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                  ),
                                  controller: TextEditingController(
                                    text: postTaskController.fullAddress.value.isNotEmpty
                                        ? postTaskController.fullAddress.value
                                        : "No address found",
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                        ],
                      ),
                    const SizedBox(height: 15),
                    buildSimpleDropdown(
                      hint: 'Select Category',
                      value: selectedCategory,
                      onChanged: (val)  {
                        setState(() {
                          selectedCategory = val;
                          selectedSubCategories.clear();
                          selectedEmergencySubCategories.clear();
                          subcategories = [];
                          emergencySubCategories = [];
                        });
                        if (val != null){
                          fetchSubCategories(val);
                        fetchEmergencySubCategories(val);
                        }
                      },
                      items: categories,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null) {
                          showSubcategoryDialog();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please select category first',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            icon: const Icon(Icons.warning, color: Colors.white),
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
                                (sub) => selectedSubCategories.contains(
                              sub['id'],
                            ),
                          )
                              .map((sub) => sub['name'])
                              .join(', '),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                 ///////////////////////
                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null) {
                          showEmergencySubcategoryDialog();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please select category first',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            icon: const Icon(Icons.warning, color: Colors.white),
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
                          selectedEmergencySubCategories.isEmpty
                              ? 'Select Emergency Subcategories'
                              : emergencySubCategories
                              .where(
                                (sub) => selectedEmergencySubCategories.contains(
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
                        FilteringTextInputFormatter.allow(RegExp(r'[a-z,0-9\./ ]')),
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
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
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
                                backgroundColor: canAddMore ? Colors.green[700] : Colors.grey,
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
                                            builder: (_) => ViewImage(
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
                                        onTap: deleteUploadedDoc,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ...selectedFiles.map((file) {
                                return Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ViewImage(
                                              imageUrl: file.path,
                                              title: "Document",
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: file.path.toLowerCase().endsWith('.pdf')
                                            ? Container(
                                          height: 100,
                                          width: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Text(
                                              'PDF',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                            : Image.file(
                                          file,
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
                                        onTap: () => deleteDocument(file),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.close, color: Colors.white, size: 18),
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
}*/
/////////////////////
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../Bidding/controller/bidding_post_task_controller.dart';
import '../../../../Emergency/User/controllers/emergency_service_controller.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../../utility/custom_snack_bar.dart';
import '../../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../../comm/view_images_screen.dart';

class RoleEditProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? skill;
  final String? categoryId;
  final List<String>? subCategoryIds;
  final List<String>? emergencySubCategoryIds;
  final List<Document>? documents;
  final String? gender;
  final String? age;
  final List<String>? businessImage;
  final bool? isShop;
  final updateBothrequest;
  final role;
  final comeEditScreen;

  const RoleEditProfileScreen({
    super.key,
    this.fullName,
    this.skill,
    this.categoryId,
    this.subCategoryIds,
    this.emergencySubCategoryIds,
    this.documents,
    this.gender,
    this.age,
    this.businessImage,
    this.isShop,
    this.updateBothrequest,
    this.role,
    this.comeEditScreen,
  });

  @override
  State<RoleEditProfileScreen> createState() => _RoleEditProfileScreenState();
}

class _RoleEditProfileScreenState extends State<RoleEditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController customDocNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];
  List<String> existingDocUrls = [];
  List<String> businessImages = [];
  bool isLoading = false;
  bool _showAllDocuments = false;
  String? selectedDocumentType;
  String? selectedCategory;
  List<String> selectedSubCategories = [];
  List<String> selectedEmergencySubCategories = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, String>> emergencySubCategories = [];
  final Map<String, String> _errorTexts = {};
  String? _selectedGender;
  String? _shopVisitChoice = "no";
  LatLng? _selectedLocation;
  final emergencyServiceController = Get.put(EmergencyServiceController());
  final postTaskController = Get.put(PostTaskController(), permanent: false);
  final List<Map<String, String>> documentTypes = [
    {'id': 'passport', 'name': 'Passport'},
    {'id': 'driving', 'name': 'Driving License'},
    {'id': 'aadhaar', 'name': 'Aadhaar Card'},
    {'id': 'pancard', 'name': 'Pan Card'},
    {'id': 'govtId', 'name': 'or any Govt.ID'},
  ];

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.fullName ?? '';
    ageController.text = widget.age ?? '';
    _selectedGender = widget.gender?.toLowerCase(); // Fix: Case-insensitive gender initialization
    _shopVisitChoice = widget.isShop == true ? "yes" : "no"; // Fix: Proper shop choice initialization
    skillController.text = widget.skill ?? '';
    selectedCategory = widget.categoryId;
    selectedSubCategories = widget.subCategoryIds ?? [];
    selectedEmergencySubCategories = widget.emergencySubCategoryIds ?? [];
    businessImages = widget.businessImage ?? [];
    existingDocUrls = widget.documents
        ?.expand((doc) => (doc.images ?? []).map((image) => image.toString()))
        .toList() ?? [];

    fetchCategories().then((_) {
      bool isValidCategory = categories.any((cat) => cat['id'] == widget.categoryId);
      setState(() {
        selectedCategory = isValidCategory ? widget.categoryId : null;
      });
      if (selectedCategory != null) {
        fetchSubCategories(selectedCategory!);
        fetchEmergencySubCategories(selectedCategory!);
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      String? savedLocation = prefs.getString('selected_location') ?? prefs.getString('address');
      double? savedLatitude = prefs.getDouble('user_latitude');
      double? savedLongitude = prefs.getDouble('user_longitude');

      if (savedLocation != null && savedLocation != 'Select Location') {
        setState(() {
          emergencyServiceController.googleAddressController.text = savedLocation;
          emergencyServiceController.latitude.value = savedLatitude;
          emergencyServiceController.longitude.value = savedLongitude;
          _selectedLocation = LatLng(savedLatitude ?? 0.0, savedLongitude ?? 0.0);
          bwDebug("📍 Pre-populated googleAddressController with: $savedLocation");
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
      setState(() {
        categories = List<Map<String, String>>.from(
          data['data'].map(
                (cat) => {
              'id': cat['_id'].toString(),
              'name': cat['name'].toString(),
            },
          ),
        );
      });
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
                (sub) => {
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

  Future<void> fetchEmergencySubCategories(String categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/emergency/subcategories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        emergencySubCategories = List<Map<String, String>>.from(
          data['data'].map(
                (sub) => {
              'id': sub['_id'].toString(),
              'name': sub['name'].toString(),
            },
          ),
        );
        selectedEmergencySubCategories = selectedEmergencySubCategories
            .where((id) => emergencySubCategories.any((sub) => sub['id'] == id))
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
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          businessImages = [image.path]; // Replace existing business image
        });
      }
    } catch (e) {
      CustomSnackBar.show(
        message: 'Error selecting image: $e',
        type: SnackBarType.error,
      );
    }
  }

  void deleteBusinessImage(String imagePath) {
    setState(() {
      businessImages.remove(imagePath);
    });
  }

  // Future<void> pickDocument() async {
  //   if (selectedDocumentType == null) {
  //     CustomSnackBar.show(
  //       message: 'Please select document type first',
  //       type: SnackBarType.error,
  //     );
  //     return;
  //   }
  //
  //   try {
  //     int totalDocs = selectedImages.length + existingDocUrls.length;
  //     if (totalDocs >= 2) {
  //       CustomSnackBar.show(
  //         message: 'You can select max 2 documents total',
  //         type: SnackBarType.error,
  //       );
  //       return;
  //     }
  //
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  //       allowMultiple: true,
  //     );
  //     if (result != null && result.files.isNotEmpty) {
  //       final newFiles = result.files
  //           .where((file) => file.path != null)
  //           .map((file) => File(file.path!))
  //           .toList();
  //       if (totalDocs + newFiles.length > 2) {
  //         CustomSnackBar.show(
  //           message: 'You can select only 2 documents total',
  //           type: SnackBarType.error,
  //         );
  //         return;
  //       }
  //       setState(() {
  //         selectedImages.addAll(newFiles);
  //       });
  //     }
  //   } catch (e) {
  //     CustomSnackBar.show(
  //       message: 'Error selecting documents: $e',
  //       type: SnackBarType.error,
  //     );
  //   }
  // }
  Future<void> pickDocument() async {
    if (selectedDocumentType == null) {
      CustomSnackBar.show(
        message: 'Please select document type first',
        type: SnackBarType.error,
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
      if (selectedImages.length >= 1) {
        Get.snackbar(
          'Warning',
          'You can select max 1 new documents',
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
        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
        if (image != null && selectedImages.length < 1) {
          setState(() {
            selectedImages.add(File(image.path));
          });
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          final toAdd = images.take(1 - selectedImages.length).toList();
          setState(() {
            selectedImages.addAll(toAdd.map((img) => File(img.path)));
          });
          if (toAdd.length < images.length) {
            // Get.snackbar('Info', 'Added ${toAdd.length} images (max 1 new)');
            CustomSnackBar.show(message: "Added ${toAdd.length} images (max 1 new)",type: SnackBarType.info);
          }
        }
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

  void deleteDocument(File file) {
    setState(() {
      selectedImages.remove(file);
    });
  }

  void deleteExistingDocument(String url) {
    setState(() {
      existingDocUrls.remove(url);
      widget.documents?.removeWhere((doc) => doc.images?.contains(url) ?? false);

    });
  }

  Future<void> switchRoleRequest() async {
    final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- switchRoleRequest response ${response.body}");
        print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
      } else {
        print("Abhi:- else switchRoleRequest response ${response.body}");
        print("Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
      }
    } catch (e) {
      print("Abhi:- get Exception $e");
    }
  }

  Future<void> onSavePressed() async {
    String? errorMessage;

    // Common validations
    if (selectedCategory == null) {
      errorMessage = 'Please select category';
    } else if (selectedSubCategories.isEmpty) {
      errorMessage = 'Please select at least one sub category';
    } else if (selectedEmergencySubCategories.isEmpty) {
      errorMessage = 'Please select at least one emergency sub category';
    } else if (skillController.text.trim().isEmpty) {
      errorMessage = 'Please enter skills';
    } else if (fullNameController.text.trim().isEmpty) {
      errorMessage = 'Please enter full name';
    }  else if (fullNameController.text.length<3) {
      errorMessage = 'Please enter valid full name(at least 3 character';
    }else if (ageController.text.trim().isEmpty || int.tryParse(ageController.text.trim()) == null || int.parse(ageController.text.trim()) < 18) {
      errorMessage = 'Please enter valid age (at least 18)';
    } else if (_selectedGender == null) {
      errorMessage = 'Please select gender';
    } else if (_shopVisitChoice == 'yes' && (emergencyServiceController.googleAddressController.text.isEmpty || _selectedLocation == null)) {
      errorMessage = 'Please select shop address';
    } else if ((widget.documents?.isEmpty ?? true) && selectedImages.isEmpty) {
      errorMessage = 'Please upload at least one document';
    } else if ((widget.documents?.isEmpty ?? true) && selectedDocumentType == null) {
      errorMessage = 'Please select document type';
    } else if ((widget.documents?.isEmpty ?? true) && selectedDocumentType == 'govtId' && customDocNameController.text.trim().isEmpty) {
      errorMessage = 'Please enter custom document name';
    }

    if (errorMessage != null) {
      if (!mounted) return;
      CustomSnackBar.show(
        message: errorMessage,
        type: SnackBarType.error,
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

      if (existingDocUrls.isNotEmpty) {
        request.fields['existingDocuments'] = jsonEncode(widget.documents?.map((doc) => {
          'documentName': doc.documentName,
          'images': doc.images,
        }).toList() ?? []);
      }

      for (var image in businessImages.where((img) => !img.startsWith('http'))) {
        request.files.add(
          await http.MultipartFile.fromPath('businessImage', image),
        );
      }

      if (businessImages.any((img) => img.startsWith('http'))) {
        request.fields['existingBusinessImages'] = jsonEncode(
          businessImages.where((img) => img.startsWith('http')).toList(),
        );
      }

      request.fields['category_id'] = selectedCategory!;
      request.fields['subcategory_ids'] = jsonEncode(selectedSubCategories);
      request.fields['emergencySubcategory_ids'] = jsonEncode(selectedEmergencySubCategories);
      request.fields['skill'] = skillController.text.trim();
      request.fields['full_name'] = fullNameController.text.trim();
      request.fields['age'] = ageController.text.trim();
      request.fields['gender'] = _selectedGender!;
      request.fields['documentName'] = selectedDocumentType == 'govtId'
          ? customDocNameController.text.trim()
          : selectedDocumentType ?? '';
      request.fields['isShop'] = _shopVisitChoice == 'yes' ? 'true' : 'false';

      if (_shopVisitChoice == 'yes' && _selectedLocation != null) {
        request.fields['businessAddress'] = jsonEncode({
          "address": emergencyServiceController.googleAddressController.text,
          "latitude": emergencyServiceController.latitude.value?.toString() ?? '',
          "longitude": emergencyServiceController.longitude.value?.toString() ?? '',
        });
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("Request timed out"),
      );

      final res = await http.Response.fromStream(streamedResponse);

      print("Abhi:- post upload detail screen data:- ${res.body}");
      print("Abhi:- post upload detail screen code:- ${res.statusCode}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (widget.comeEditScreen == "editScreen") {
          Navigator.pop(context, true);
        }
        Navigator.pop(context, true);
        switchRoleRequest();
        CustomSnackBar.show(
          message: 'Profile updated successfully',
          type: SnackBarType.success,
        );
      } else {
        CustomSnackBar.show(
          message: 'Failed: ${res.body}',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print("Abhi:- update serviceprovider profile $e");
      CustomSnackBar.show(
        message: 'Error: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
              onPressed: businessImages.length < 1 ? pickBusinessImage : null,
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: const Text('Upload Business Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: businessImages.length < 1 ? Colors.green[700] : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (businessImages.isNotEmpty)
            Wrap(
              spacing: 8,
              children: businessImages.map((image) {
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewImage(
                              imageUrl: image,
                              title: "Business Image",
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: image.startsWith('http')
                            ? CachedNetworkImage(
                          imageUrl: image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: Image.asset(
                              'assets/images/d_png/No_Image_Available.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                            : Image.file(
                          File(image),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey[300],
                              child: Image.asset(
                                'assets/images/d_png/No_Image_Available.jpg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => deleteBusinessImage(image),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          if (_errorTexts['businessImage'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorTexts['businessImage']!,
                style: const TextStyle(color: AppColors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  // Widget buildDocumentUpload() {
  //   final documents = widget.documents ?? [];
  //   final visibleDocuments = _showAllDocuments ? documents : documents.take(2).toList();
  //   final hasMoreDocuments = documents.length > 2;
  //   bool canAddMore = (selectedImages.length + existingDocUrls.length) < 2;
  //
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: Colors.grey.shade400),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Center(
  //           child: ElevatedButton.icon(
  //             onPressed: canAddMore ? pickDocument : null,
  //             icon: const Icon(Icons.add, color: Colors.white),
  //             label: const Text('Upload Document'),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: canAddMore ? Colors.green[700] : Colors.grey,
  //               foregroundColor: Colors.white,
  //               minimumSize: const Size(double.infinity, 48),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         if (selectedImages.isNotEmpty) ...[
  //           Text(
  //             "New Document: ${selectedDocumentType == 'govtId' ? customDocNameController.text.trim() : documentTypes.firstWhere((d) => d['id'] == selectedDocumentType, orElse: () => {'name': 'Unknown'})['name']}",
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w600,
  //               fontSize: 14,
  //             ),
  //           ),
  //           const SizedBox(height: 5),
  //           SizedBox(
  //             height: 100,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: selectedImages.length,
  //               itemBuilder: (context, index) {
  //                 final file = selectedImages[index];
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 8.0),
  //                   child: Stack(
  //                     children: [
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (_) => ViewImage(
  //                                 imageUrl: file.path,
  //                                 title: "Document",
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(6),
  //                           child: file.path.toLowerCase().endsWith('.pdf')
  //                               ? Container(
  //                             height: 90,
  //                             width: 105,
  //                             color: Colors.grey[300],
  //                             child: const Center(
  //                               child: Text(
  //                                 'PDF',
  //                                 style: TextStyle(fontWeight: FontWeight.bold),
  //                               ),
  //                             ),
  //                           )
  //                               : Image.file(
  //                             file,
  //                             height: 90,
  //                             width: 105,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Container(
  //                                 height: 90,
  //                                 width: 105,
  //                                 color: Colors.grey[300],
  //                                 child: Image.asset(
  //                                   'assets/images/d_png/No_Image_Available.jpg',
  //                                   width: 50,
  //                                   height: 50,
  //                                   fit: BoxFit.cover,
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                       ),
  //                       Positioned(
  //                         top: 4,
  //                         right: 4,
  //                         child: GestureDetector(
  //                           onTap: () => deleteDocument(file),
  //                           child: Container(
  //                             decoration: const BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: Colors.black54,
  //                             ),
  //                             padding: const EdgeInsets.all(4),
  //                             child: const Icon(Icons.close, color: Colors.white, size: 18),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //         ],
  //         if (existingDocUrls.isNotEmpty) ...[
  //           const Text(
  //             "Existing Documents",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 8),
  //           ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: visibleDocuments.length,
  //             itemBuilder: (context, index) {
  //               final document = visibleDocuments[index];
  //               if (document.images == null || document.images!.isEmpty) return const SizedBox.shrink();
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     '${(document.documentName ?? "Unnamed Document")[0].toUpperCase()}${(document.documentName ?? "Unnamed Document").substring(1)}',
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 5),
  //                   SizedBox(
  //                     height: 100,
  //                     child: ListView.builder(
  //                       scrollDirection: Axis.horizontal,
  //                       itemCount: document.images!.length,
  //                       itemBuilder: (context, imgIndex) {
  //                         final imageUrl = document.images![imgIndex];
  //                         return Padding(
  //                           padding: const EdgeInsets.only(right: 8.0),
  //                           child: Stack(
  //                             children: [
  //                               InkWell(
  //                                 onTap: () {
  //                                   Navigator.push(
  //                                     context,
  //                                     MaterialPageRoute(
  //                                       builder: (_) => ViewImage(
  //                                         imageUrl: imageUrl,
  //                                         title: "Document",
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                                 child: ClipRRect(
  //                                   borderRadius: BorderRadius.circular(6),
  //                                   child: CachedNetworkImage(
  //                                     imageUrl: imageUrl,
  //                                     height: 90,
  //                                     width: 105,
  //                                     fit: BoxFit.cover,
  //                                     placeholder: (context, url) => const Center(
  //                                       child: CircularProgressIndicator(
  //                                         strokeWidth: 2,
  //                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
  //                                       ),
  //                                     ),
  //                                     errorWidget: (context, url, error) => Container(
  //                                       height: 90,
  //                                       width: 105,
  //                                       color: Colors.grey[300],
  //                                       child: Image.asset(
  //                                         'assets/images/d_png/No_Image_Available.jpg',
  //                                         width: 50,
  //                                         height: 50,
  //                                         fit: BoxFit.cover,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 top: 4,
  //                                 right: 4,
  //                                 child: GestureDetector(
  //                                   onTap: () => deleteExistingDocument(imageUrl),
  //                                   child: Container(
  //                                     decoration: const BoxDecoration(
  //                                       shape: BoxShape.circle,
  //                                       color: Colors.black54,
  //                                     ),
  //                                     padding: const EdgeInsets.all(4),
  //                                     child: const Icon(Icons.close, color: Colors.white, size: 18),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),
  //                 ],
  //               );
  //             },
  //           ),
  //           if (hasMoreDocuments)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 10),
  //               child: Center(
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       _showAllDocuments = !_showAllDocuments;
  //                     });
  //                   },
  //                   child: Text(
  //                     _showAllDocuments ? "See Less" : "See More",
  //                     style: const TextStyle(
  //                       color: AppColors.primaryGreen,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //         if (_errorTexts['documents'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorTexts['documents']!,
  //               style: const TextStyle(color: AppColors.red, fontSize: 11),
  //             ),
  //           ),
  //         if (_errorTexts['documentType'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorTexts['documentType']!,
  //               style: const TextStyle(color: AppColors.red, fontSize: 11),
  //             ),
  //           ),
  //         if (_errorTexts['customDocName'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorTexts['customDocName']!,
  //               style: const TextStyle(color: AppColors.red, fontSize: 11),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
  // Widget buildDocumentUpload() {
  //   final documents = widget.documents ?? [];
  //   final visibleDocuments = _showAllDocuments ? documents : documents.take(2).toList();
  //   final hasMoreDocuments = documents.length > 2;
  //   // bool canAddMore = (selectedImages.length + existingDocUrls.length) < 2;
  //   bool canAddMore = selectedImages.length < 2;
  //
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: Colors.grey.shade400),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Center(
  //           child: ElevatedButton.icon(
  //             onPressed: canAddMore ? () => pickDocument() : null,
  //             icon: const Icon(Icons.add, color: Colors.white),
  //             label: const Text('Upload Document'),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: canAddMore ? Colors.green[700] : Colors.grey,
  //               foregroundColor: Colors.white,
  //               minimumSize: const Size(double.infinity, 48),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //
  //         // New Documents Section
  //         if (selectedImages.isNotEmpty) ...[
  //           Text(
  //             "New Document: ${selectedDocumentType == 'govtId'
  //                 ? customDocNameController.text.trim()
  //                 : documentTypes.firstWhere((d) => d['id'] == selectedDocumentType)['name']}",
  //
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w600,
  //               fontSize: 14,
  //             ),
  //           ),
  //           const SizedBox(height: 5),
  //           SizedBox(
  //             height: 100,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: selectedImages.length,
  //               itemBuilder: (context, index) {
  //                 final file = selectedImages[index];
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 8.0),
  //                   child: Stack(
  //                     children: [
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (_) => ViewImage(
  //                                 imageUrl: file.path,
  //                                 title: "Document",
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(6),
  //                           child: file.path.toLowerCase().endsWith('.pdf')
  //                               ? Container(
  //                             height: 90,
  //                             width: 105,
  //                             color: Colors.grey[300],
  //                             child: const Center(
  //                               child: Text(
  //                                 'PDF',
  //                                 style: TextStyle(fontWeight: FontWeight.bold),
  //                               ),
  //                             ),
  //                           )
  //                               : Image.file(
  //                             file,
  //                             height: 90,
  //                             width: 105,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Container(
  //                                 height: 90,
  //                                 width: 105,
  //                                 color: Colors.grey[300],
  //                                 child: Image.asset(
  //                                   'assets/images/d_png/No_Image_Available.jpg',
  //                                   width: 50,
  //                                   height: 50,
  //                                   fit: BoxFit.cover,
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                       ),
  //                       Positioned(
  //                         top: 4,
  //                         right: 4,
  //                         child: GestureDetector(
  //                           onTap: () => deleteDocument(file),
  //                           child: Container(
  //                             decoration: const BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: Colors.black54,
  //                             ),
  //                             padding: const EdgeInsets.all(4),
  //                             child: const Icon(Icons.close, color: Colors.white, size: 18),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //         ],
  //
  //         // Existing Documents Section
  //         if (existingDocUrls.isNotEmpty || documents.isNotEmpty) ...[
  //           const Text(
  //             "Existing Documents",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 8),
  //           ListView.separated(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: visibleDocuments.length,
  //             separatorBuilder: (context, index) => const SizedBox(height: 10),
  //             itemBuilder: (context, index) {
  //               final document = visibleDocuments[index];
  //               final images = (document.images ?? []).map((image) => image.toString()).toList();
  //               if (images.isEmpty) {
  //                 return const SizedBox.shrink();
  //               }
  //
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     '${(document.documentName ?? "Unnamed Document")[0].toUpperCase()}${(document.documentName ?? "Unnamed Document").substring(1)}',
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 5),
  //                   SizedBox(
  //                     height: 100,
  //                     child: ListView.builder(
  //                       scrollDirection: Axis.horizontal,
  //                       itemCount: images.length,
  //                       itemBuilder: (context, imgIndex) {
  //                         final imageUrl = images[imgIndex];
  //                         return Padding(
  //                           padding: const EdgeInsets.only(right: 8.0),
  //                           child: Stack(
  //                             children: [
  //                               InkWell(
  //                                 onTap: () {
  //                                   Navigator.push(
  //                                     context,
  //                                     MaterialPageRoute(
  //                                       builder: (_) => ViewImage(
  //                                         imageUrl: imageUrl,
  //                                         title: "Document",
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                                 child: ClipRRect(
  //                                   borderRadius: BorderRadius.circular(6),
  //                                   child: CachedNetworkImage(
  //                                     imageUrl: imageUrl,
  //                                     height: 90,
  //                                     width: 105,
  //                                     fit: BoxFit.cover,
  //                                     placeholder: (context, url) => Container(
  //                                       height: 90,
  //                                       width: 105,
  //                                       color: Colors.grey[300],
  //                                       child: const Center(
  //                                         child: CircularProgressIndicator(
  //                                           strokeWidth: 2,
  //                                           valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     errorWidget: (context, url, error) => Container(
  //                                       height: 90,
  //                                       width: 105,
  //                                       color: Colors.grey[300],
  //                                       child: Image.asset(
  //                                         'assets/images/d_png/No_Image_Available.jpg',
  //                                         width: 50,
  //                                         height: 50,
  //                                         fit: BoxFit.cover,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 top: 4,
  //                                 right: 4,
  //                                 child: GestureDetector(
  //                                   onTap: () => deleteExistingDocument(imageUrl),
  //                                   child: Container(
  //                                     decoration: const BoxDecoration(
  //                                       shape: BoxShape.circle,
  //                                       color: Colors.black54,
  //                                     ),
  //                                     padding: const EdgeInsets.all(4),
  //                                     child: const Icon(Icons.close, color: Colors.white, size: 18),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //           if (hasMoreDocuments)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 10),
  //               child: Center(
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       _showAllDocuments = !_showAllDocuments;
  //                     });
  //                   },
  //                   child: Text(
  //                     _showAllDocuments ? "See Less" : "See More",
  //                     style: const TextStyle(
  //                       color: AppColors.primaryGreen,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //
  //         // Error Messages
  //         if (_errorTexts['documents'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorTexts['documents']!,
  //               style: const TextStyle(color: AppColors.red, fontSize: 11),
  //             ),
  //           ),
  //         if (_errorTexts['documentType'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorTexts['documentType']!,
  //               style: const TextStyle(color: AppColors.red, fontSize: 11),
  //             ),
  //           ),
  //         if (_errorTexts['customDocName'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorTexts['customDocName']!,
  //               style: const TextStyle(color: AppColors.red, fontSize: 11),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
  Widget buildDocumentUpload() {
    final documents = widget.documents ?? [];
    final visibleDocuments = _showAllDocuments ? documents : documents.take(2).toList();
    final hasMoreDocuments = documents.length > 1;
    // bool canAddMore = (selectedImages.length +
    //     (widget.documents?.fold<int>(0, (sum, doc) => sum + doc.images!.length) ?? 0)) <
    //     2;
    bool canAddMore = selectedImages.length < 2;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ElevatedButton.icon(
              onPressed: canAddMore ? pickDocument : null,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Upload Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canAddMore ? Colors.green[700] : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "New Document: ${selectedDocumentType == 'govtId'
                  ? customDocNameController.text.trim()
                  : documentTypes.firstWhere((d) => d['id'] == selectedDocumentType)['name']}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  final file = selectedImages[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewImage(
                                  imageUrl: file.path,
                                  title: "Image",
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              file,
                              height: 90,
                              width: 105,
                              fit: BoxFit.cover,

                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 90,
                                  width: 105,
                                  color: Colors.grey[300],
                                  child:   Image.asset(
                                    'assets/images/d_png/No_Image_Available.jpg',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
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
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (documents.isNotEmpty) ...[
            // const Text(
            //   "Existing Documents",
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleDocuments.length,
              itemBuilder: (context, index) {
                final document = visibleDocuments[index];
                if (document.images == null || document.images!.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(document.documentName ?? "Unnamed Document")[0].toUpperCase()}${(document.documentName ?? "Unnamed Document").substring(1)}',                      style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: document.images!.length,
                        itemBuilder: (context, imgIndex) {
                          final imageUrl = document.images![imgIndex];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewImage(
                                      imageUrl: imageUrl,
                                      title: "Document",
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  imageUrl,
                                  height: 90,
                                  width: 105,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 90,
                                      width: 105,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 90,
                                      width: 105,
                                      color: Colors.grey[300],
                                      child:  Image.asset(
                                        'assets/images/d_png/No_Image_Available.jpg',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
            if (hasMoreDocuments)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAllDocuments = !_showAllDocuments;
                      });
                    },
                    child: Text(
                      _showAllDocuments ? "See Less" : "See More",
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],

        ],
      ),
    );
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

  void showEmergencySubcategoryDialog() {
    List<String> tempSelected = List.from(selectedEmergencySubCategories);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Emergency SubCategory"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: emergencySubCategories.length,
                  itemBuilder: (context, index) {
                    final sub = emergencySubCategories[index];
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
                      selectedEmergencySubCategories = tempSelected;
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
    String? validValue = items.any((item) => item['id'] == value) ? value : null;

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
              (item) => DropdownMenuItem(
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
          mainAxisAlignment: MainAxisAlignment.start,
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
        const Text("Do you have any shop?"),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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

  @override
  Widget build(BuildContext context) {
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                errorText: _errorTexts['fullName'],
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
                errorText: _errorTexts['age'],
              ),
            ),
            const SizedBox(height: 15),
            buildGenderRadio(),
            const SizedBox(height: 15),
            buildShopVisitRadio(),
            const SizedBox(height: 15),
            if (_shopVisitChoice == 'yes')
              Column(
                children: [
                  Obx(
                        () => GestureDetector(
                      onTap: postTaskController.navigateToLocationScreen,
                      child: AbsorbPointer(
                        child: TextFormField(
                          minLines: 1,
                          maxLines: null,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Shop Address",
                            hintText: 'Select location from map',
                            suffixIcon: const Icon(Icons.map, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            errorText: _errorTexts['location'],
                          ),
                          controller: TextEditingController(
                            text: postTaskController.fullAddress.value.isNotEmpty
                                ? postTaskController.fullAddress.value
                                : "No address found",
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 15),
            buildSimpleDropdown(
              hint: 'Select Category',
              value: selectedCategory,
              onChanged: (val) {
                setState(() {
                  selectedCategory = val;
                  selectedSubCategories.clear();
                  selectedEmergencySubCategories.clear();
                  subcategories = [];
                  emergencySubCategories = [];
                });
                if (val != null) {
                  fetchSubCategories(val);
                  fetchEmergencySubCategories(val);
                }
              },
              items: categories,
            ),
            if (_errorTexts['category'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorTexts['category']!,
                  style: const TextStyle(color: AppColors.red, fontSize: 11),
                ),
              ),
            GestureDetector(
              onTap: () {
                if (selectedCategory != null) {
                  showSubcategoryDialog();
                } else {
                  CustomSnackBar.show(
                    message: 'Please select category first',
                    type: SnackBarType.error,
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
                      .where((sub) => selectedSubCategories.contains(sub['id']))
                      .map((sub) => sub['name'])
                      .join(', '),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            if (_errorTexts['subCategories'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorTexts['subCategories']!,
                  style: const TextStyle(color: AppColors.red, fontSize: 11),
                ),
              ),
            GestureDetector(
              onTap: () {
                if (selectedCategory != null) {
                  showEmergencySubcategoryDialog();
                } else {
                  CustomSnackBar.show(
                    message: 'Please select category first',
                    type: SnackBarType.error,
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
                  selectedEmergencySubCategories.isEmpty
                      ? 'Select Emergency Subcategories'
                      : emergencySubCategories
                      .where((sub) => selectedEmergencySubCategories.contains(sub['id']))
                      .map((sub) => sub['name'])
                      .join(', '),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            if (_errorTexts['emergencySubCategories'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorTexts['emergencySubCategories']!,
                  style: const TextStyle(color: AppColors.red, fontSize: 11),
                ),
              ),
            TextFormField(
              controller: skillController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-z,0-9\./ ]')),
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
                errorText: _errorTexts['skill'],
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
            if (_errorTexts['documentType'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorTexts['documentType']!,
                  style: const TextStyle(color: AppColors.red, fontSize: 11),
                ),
              ),
            if (selectedDocumentType == 'govtId') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: customDocNameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                ],
                decoration: InputDecoration(
                  labelText: "Custom Document Name",
                  hintText: 'Enter document name (e.g., Voter ID)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorText: _errorTexts['customDocName'],
                ),
              ),
            ],
            const SizedBox(height: 12),
            buildDocumentUpload(),
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
    );
  }
}