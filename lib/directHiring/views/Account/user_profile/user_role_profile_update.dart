import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../../Widgets/AppColors.dart';

class RoleEditProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? skill;
  final String? categoryId;
  final List<String>? subCategoryIds;
  final String? documentUrl;
  final updateBothrequest;
  final role;

  const RoleEditProfileScreen({
    super.key,
    this.fullName,
    this.skill,
    this.categoryId,
    this.subCategoryIds,
    this.documentUrl,
    this.updateBothrequest,
    this.role,
  });

  @override
  State<RoleEditProfileScreen> createState() => _RoleEditProfileScreenState();
}

class _RoleEditProfileScreenState extends State<RoleEditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  File? selectedFile;
  bool isLoading = false;

  String? selectedCategory;
  List<String> selectedSubCategories = [];

  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  String? uploadedDocName;

  @override
  void initState() {
    super.initState();

    fullNameController.text = widget.fullName ?? '';
    skillController.text = widget.skill ?? '';
    selectedCategory = widget.categoryId;
    selectedSubCategories = widget.subCategoryIds ?? [];
    uploadedDocName = widget.documentUrl?.split('/').last;

    fetchCategories().then((_) {
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
      });
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        uploadedDocName = null;
      });
    }
  }

  Future<void> switchRoleRequest() async{
    final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
    print("Abhi:- switchRoleRequest url :$url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try{

      var response = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
      if(response.statusCode ==200 || response.statusCode ==201){
        print("Abhi:- switchRoleRequest response ${response.body}");
        print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
      }else{
        print("Abhi:- else switchRoleRequest response ${response.body}");
        print("Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
      }
    }
    catch(e){print("Abhi:- get Exception $e");}
  }

  Future<void> onSavePressed() async {
    if (selectedCategory == null ||
        selectedSubCategories.isEmpty ||
        skillController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        (selectedFile == null && uploadedDocName == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please fill all fields and upload document"),
        ),
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

      if (selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('document', selectedFile!.path),
        );
      } else if (uploadedDocName != null) {
        request.fields['document_url'] = uploadedDocName!;
      }

      request.fields['category_id'] = selectedCategory!;
      request.fields['subcategory_ids'] = jsonEncode(selectedSubCategories);
      request.fields['skill'] = skillController.text.trim();
      request.fields['full_name'] = fullNameController.text.trim();

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("Request timed out"),
      );

      final res = await http.Response.fromStream(streamedResponse);

      // if (mounted) return;

       print("Abhi:- post uploade detail screen data:- ${res.body}");
       print("Abhi:- post uploade detail screen data:- ${res.statusCode}");
      if (res.statusCode == 200 || res.statusCode == 201) {

      await Future.delayed(const Duration(milliseconds: 500));
      // Navigator.pop(context, true);
      Navigator.pop(context, true);

      switchRoleRequest();
       // widget.role == "user" ? switchRoleRequest() : SizedBox();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Upload successful")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${res.body}")));
      }
    } catch (e) {
      print("Abhi:- update serviceprovider profile $e");
      // if (mounted) {
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      // }
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items:
        items
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.arrow_back, size: 25),
                          ),
                        ),
                        const SizedBox(width: 50),
                        Text(
                          "User Update Details",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: fullNameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
                      ],

                      decoration: InputDecoration(
                        hintText: 'Enter Full Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Please select category first"),
                            ),
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
                    TextFormField(
                      controller: skillController,

                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-z,0-9\./ ]')),
                      ],

                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter Skills',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Note: Please upload your valid document (PAN Card, Driving Licence, Aadhaar Card, etc.)",style: TextStyle(color: Colors.red),),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: pickDocument,
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        selectedFile != null
                            ? selectedFile!.path.split('/').last
                            : (uploadedDocName ?? 'Upload Document'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
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
                      child:
                      isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
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
