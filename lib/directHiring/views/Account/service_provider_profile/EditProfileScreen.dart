import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/utility/custom_snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../comm/view_images_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? skill;
  final String? categoryId;
  final List<String>? subCategoryIds;
  final String? documentUrl;
  final gender;

  // final age;
  final String? age; // best way

  const EditProfileScreen({
    super.key,
    this.fullName,
    this.skill,
    this.categoryId,
    this.subCategoryIds,
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
  final ImagePicker _picker = ImagePicker();

  List<File> selectedImages = [];
  // final TextEditingController fullNameController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  File? selectedFile;
  bool isLoading = false;
  String? selectedCategory;
  List<String> selectedSubCategories = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  String? uploadedDocName;
  final Map<String, String> _errorTexts = {};
  String? _selectedGender; // Added for gender selection


  @override
  void initState() {
    super.initState();

    fullNameController.text = widget.fullName ?? '';
    ageController.text = widget.age?.toString() ?? "";
    _selectedGender = widget.gender ?? "";
    skillController.text = widget.skill ?? '';
    selectedSubCategories = widget.subCategoryIds ?? [];
    // uploadedDocName = widget.documentUrl?.split('/').last;
    uploadedDocUrl = widget.documentUrl;
bwDebug("updaded doc: $uploadedDocName");
    fetchCategories().then((_) {
      bool isValidCategory =
          categories.any((cat) => cat['id'] == widget.categoryId);
      setState(() {
        selectedCategory = isValidCategory ? widget.categoryId : null;
      });
      if (selectedCategory != null) {
        fetchSubCategories(selectedCategory!);
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
      print(
          "Fetched Categories: ${data['data']}"); // Debug: Full response print
      setState(() {
        categories = List<Map<String, String>>.from(
          data['data'].map(
            (cat) => {
              'id': cat['_id'].toString(),
              'name': cat['name'].toString(),
            },
          ),
        );
        print(
            "Processed Categories IDs: ${categories.map((c) => c['id']).toList()}"); // Debug: IDs list
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
            (sub) => {
              'id': sub['_id'].toString(),
              'name': sub['name'].toString(),
            },
          ),
        );
        // Validate selectedSubCategories
        selectedSubCategories = selectedSubCategories
            .where((id) => subcategories.any((sub) => sub['id'] == id))
            .toList();
      });
    }
  }

  // Future<void> pickDocument() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  //   );
  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       selectedFile = File(result.files.single.path!);
  //       uploadedDocName = null;
  //     });
  //   }
  // }
  Future<void> pickDocument() async {
    int currentCount = selectedImages.length + (uploadedDocUrl != null ? 1 : 0);
    if (currentCount >= 2) {
      CustomSnackBar.show(context,
          message: "You can select only 2 images total",
          type: SnackBarType.warning);
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
      int currentCount = selectedImages.length + (uploadedDocUrl != null ? 1 : 0);
      if (currentCount >= 2) {
        CustomSnackBar.show(context,
            message: "You can select only 2 images total",
            type: SnackBarType.warning);
        return;
      }

      if (fromCamera) {
        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          if (currentCount + 1 > 2) {
            CustomSnackBar.show(context,
                message: "You can select only 2 images total",
                type: SnackBarType.warning);
            return;
          }
          setState(() {
            selectedImages.add(File(image.path));
          });
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isEmpty) return;
        if (currentCount + images.length > 2) {
          CustomSnackBar.show(context,
              message: "You can select only 2 images total",
              type: SnackBarType.warning);
          return;
        }
        setState(() {
          selectedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: "Error selecting images: $e", type: SnackBarType.error);
    }
  }

  Future<void> onSavePressed() async {
    if (selectedCategory == null ||
        selectedSubCategories.isEmpty ||
        skillController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        ageController.text.isEmpty ||

        // (selectedFile == null && uploadedDocName == null)) {
        (selectedImages.isEmpty && uploadedDocUrl == null)) {

      // Get.snackbar(
      //   'Warning',
      //   'Please fill all fields and upload document',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.orange,
      //   colorText: Colors.white,
      //   margin: EdgeInsets.all(10),
      //   duration: Duration(seconds: 3),
      // );
      CustomSnackBar.show(context,
          message: 'Please fill all fields and upload document',
          type: SnackBarType.warning);
      return;
    }
    if (int.tryParse(ageController.text.trim())! < 18) {
      CustomSnackBar.show(context,
          message: 'Invalid age, You must be at least 18 years old',
          type: SnackBarType.error);
      return;
    }
    if (selectedImages.length < 1 || selectedImages.length > 2) {
      CustomSnackBar.show(context,
          message: "Please upload at least 1 and at most 2 images",
          type: SnackBarType.warning);
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

      // if (selectedFile != null) {
      //   request.files.add(
      //     await http.MultipartFile.fromPath('document', selectedFile!.path),
      //   );
      // } else if (uploadedDocName != null) {
      //   request.fields['document_url'] = uploadedDocName!;
      // }
      if (uploadedDocUrl != null) {
        request.fields['document_url'] = uploadedDocUrl!;
      }

      for (var file in selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath('document', file.path),
        );
      }


      request.fields['category_id'] = selectedCategory!;
      request.fields['age'] = ageController.text;
      request.fields['gender'] = _selectedGender!;
      request.fields['subcategory_ids'] = jsonEncode(selectedSubCategories);
      request.fields['skill'] = skillController.text.trim();
      request.fields['full_name'] = fullNameController.text.trim();

      var streamedResponse = await request.send().timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException("Request timed out"),
          );

      final res = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (res.statusCode == 200) {
        // Get.snackbar(
        //   'Success',
        //   'Upload successful',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   margin: EdgeInsets.all(10),
        //   duration: Duration(seconds: 3),
        // );
        CustomSnackBar.show(context,
            message: "Upload successful", type: SnackBarType.success);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context, true);
      } else {
        // Get.snackbar(
        //   'Error',
        //   'Failed: ${res.body}',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   margin: EdgeInsets.all(10),
        //   duration: Duration(seconds: 3),
        // );
        CustomSnackBar.show(context,
            message: 'Failed: ${res.body}', type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- update serviceprovider profile $e");
      // Get.snackbar(
      //   'Error',
      //   'Error: $e',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   margin: EdgeInsets.all(10),
      //   duration: Duration(seconds: 3),
      // );
      CustomSnackBar.show(context, message: 'Error: $e',type: SnackBarType.error);
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

  Widget buildSimpleDropdown({
    required String? value,
    required String hint,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    // Safety: Agar value items mein nahi hai, to null set kar do
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

  @override
  Widget build(BuildContext context) {
    bool canAddMore = (selectedImages.length + (uploadedDocUrl != null ? 1 : 0)) < 2;

    print("Abhi: get age: ${widget.age} gender: ${widget.gender}");
    return Scaffold(
      // backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("User Update Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                    // const SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () => Navigator.pop(context),
                    //       child: const Padding(
                    //         padding: EdgeInsets.only(left: 8.0),
                    //         child: Icon(Icons.arrow_back, size: 25),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 50),
                    //     Text(
                    //       "User Update Details",
                    //       style: GoogleFonts.roboto(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: fullNameController,
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
                    const SizedBox(height: 12),
                    buildSimpleDropdown(
                      hint: 'Select Category',
                      value: selectedCategory,
                      items: categories,
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                          selectedSubCategories.clear();
                          subcategories = [];
                        });
                        if (val != null) fetchSubCategories(val);
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null) {
                          showSubcategoryDialog();
                        } else {
                          // Get.snackbar(
                          //   'Warning',
                          //   'Please select category first',
                          //   snackPosition: SnackPosition.BOTTOM,
                          //   backgroundColor: Colors.orange,
                          //   colorText: Colors.white,
                          //   margin: EdgeInsets.all(10),
                          //   duration: Duration(seconds: 3),
                          // );
                          CustomSnackBar.show(context, message: 'Please select category first',type: SnackBarType.warning );
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
                    TextFormField(
                      controller: skillController,
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
                    Text(
                      "Note: Please upload your valid document (PAN Card, Driving Licence, Aadhaar Card, etc.)",
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    // ElevatedButton.icon(
                    //   onPressed: pickDocument,
                    //   icon: const Icon(Icons.attach_file),
                    //   label: Text(
                    //     selectedFile != null
                    //         ? selectedFile!.path.split('/').last
                    //         : (uploadedDocName ?? 'Upload Document'),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.grey[300],
                    //     foregroundColor: Colors.black,
                    //   ),
                    // ),
                    Column(
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
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => ViewImage(
                                          imageUrl: uploadedDocUrl!,
                                          title: "Document",
                                        ),
                                      ));
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
                                      onTap: () {
                                        setState(() {
                                          uploadedDocUrl = null;
                                        });
                                      },
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

                            ...selectedImages.map((file) {
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => ViewImage(
                                          imageUrl: file.path,
                                          title: "Image",
                                        ),
                                      ));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        file,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImages.remove(file);
                                        });
                                      },
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



                    SizedBox(height: 20),
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
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: const CircularProgressIndicator(
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

  Widget buildGenderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Your Gender"),
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
        SizedBox(
          // height: 0,
          child: _errorTexts['gender'] != null
              ? Text(
                  _errorTexts['gender']!,
                  style: const TextStyle(color: AppColors.red, fontSize: 11),
                )
              : null,
        ),
        // const SizedBox(height: 10),
      ],
    );
  }
}
