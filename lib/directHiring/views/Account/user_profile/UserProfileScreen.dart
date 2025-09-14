import 'dart:convert';
import 'dart:io';

import 'package:developer/directHiring/views/Account/user_profile/user_role_profile_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../auth/RoleSelectionScreen.dart';
import '../service_provider_profile/EditProfileScreen.dart';
import '../service_provider_profile/ServiceProviderProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  final swithcrole;
  const ProfileScreen({super.key, this.swithcrole});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String selectedRole = 'user';
  String? profilePicUrl;
  String? fullName = 'Your Name';
  String? age = 'Your age';
  String? gender = 'Your gender';
  String? requestStatus;
  String? role = 'No role';
  String? aboutUs = '';
  String? phone;
  String? selectedGender;
  late TextEditingController aboutController;
  final GetXRoleController roleController = Get.put(GetXRoleController()); // Updated to GetXRoleController
  @override
  void initState() {
    super.initState();
    aboutController = TextEditingController();
    _fetchProfileFromAPI();
    _loadSelectedRole();
  }
  Future<void> _loadSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('role') ?? 'user'; // Default to 'user'
    });
  }
  Future<void> _fetchProfileFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // if (response.statusCode == 200) {
      //   final body = json.decode(response.body);
      //   if (body['status'] == true) {
      //     final data = body['data'];
      //     setState(() {
      //       fullName = data['full_name'] ?? 'Your Name';
      //       age = data['age'];
      //       gender = data['gender'] ?? 'Your gender';
      //       role = data['role'] ?? 'role';
      //       profilePicUrl = data['profilePic'];
      //       aboutUs = data['aboutUs'] ?? '';
      //       phone = data['phone'] ?? '';
      //       requestStatus = data['requestStatus'] ?? '';
      //       aboutController.text = aboutUs!;
      //     });
      //   }
      //   print("Abhi:- show exception fetchProfileFromAPI data $age Gender: $gender ");
      // }
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final data = body['data'];

          final userAge = data['age']?.toString() ?? '0';   // ✅ safe string
          final userGender = data['gender'] ?? '';         // ✅ string

          // setState(() {
          //   fullName = data['full_name'] ?? 'Your Name';
          //   age = userAge;
          //   gender = userGender;
          //   role = data['role'] ?? 'role';
          //   profilePicUrl = data['profilePic'];
          //   aboutUs = data['aboutUs'] ?? '';
          //   phone = data['phone'] ?? '';
          //   requestStatus = data['requestStatus'] ?? '';
          //   aboutController.text = aboutUs!;
          // });

          if (body['status'] == true) {
            final data = body['data'];
            final userAge = data['age']?.toString() ?? '';
            final userGender = (data['gender'] ?? '').toString().toLowerCase();

            setState(() {
              fullName = data['full_name'] ?? 'Your Name';
              age = userAge;
              gender = userGender;          // UI ke liye
              selectedGender = userGender;  // bottomsheet radio ke liye
              role = data['role'] ?? 'role';
              profilePicUrl = data['profilePic'];
              aboutUs = data['aboutUs'] ?? '';
              phone = data['phone'] ?? '';
              requestStatus = data['requestStatus'] ?? '';
              aboutController.text = aboutUs!;
            });
          }


          print("Abhi:- User Age: $userAge, Gender: $userGender");
        }
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromAPI Error: $e');
      print("Abhi:- show exception fetchProfileFromAPI Error: $e");
    }
  }

  // Future<void> _uploadCombinedProfileData(
  //     String name,
  //     String aboutText,
  //     File? imageFile,
  //     ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   if (token == null) return;
  //
  //   if (imageFile != null) {
  //     final uri = Uri.parse(
  //       'https://api.thebharatworks.com/api/user/updateProfilePic',
  //     );
  //     final request =
  //     http.MultipartRequest('PUT', uri)
  //       ..headers['Authorization'] = 'Bearer $token'
  //       ..fields['full_name'] = name
  //       ..fields['aboutUs'] = aboutText;
  //
  //     request.files.add(
  //       await http.MultipartFile.fromPath('profilePic', imageFile.path),
  //     );
  //
  //     final response = await request.send();
  //     final resBody = await http.Response.fromStream(response);
  //     final body = json.decode(resBody.body);
  //
  //     if (body['status'] == true) {
  //       setState(() {
  //         fullName = name;
  //         aboutUs = aboutText;
  //         _image = imageFile;
  //         profilePicUrl = null;
  //       });
  //       await _fetchProfileFromAPI();
  //
  //     }
  //   } else {
  //     final uri = Uri.parse(
  //       'https://api.thebharatworks.com/api/user/updateUserDetails',
  //     );
  //     final request =
  //     http.MultipartRequest('PUT', uri)
  //       ..headers['Authorization'] = 'Bearer $token'
  //       ..fields['full_name'] = name
  //       ..fields['aboutUs'] = aboutText;
  //      // ..fields['category_id'] = '68443fdbf03868e7d6b74874'
  //      //  ..fields['subcategory_ids'] = jsonEncode([
  //      //    "6844412075d28c40d10de2c4",
  //      //  ]);
  //
  //     final response = await request.send();
  //     final resBody = await http.Response.fromStream(response);
  //     final body = json.decode(resBody.body);
  //     switchRoleRequest();
  //     if (body['status'] == true) {
  //       setState(() {
  //         fullName = name;
  //         aboutUs = aboutText;
  //         aboutController.text = aboutText;
  //       });
  //       await _fetchProfileFromAPI();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Profile updated successfully")),
  //       );
  //       // widget.swithcrole == 'serviceroleSwitch' ?  switchRoleRequest() : SizedBox();
  //       Navigator.pop(context);
  //       // Navigator.pop(context);
  //     }
  //   }
  // }

  Future<void> _uploadCombinedProfileData(
      String name,
      String aboutText,
      File? imageFile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    if (imageFile != null) {
      // 👉 Update profile with image
      final uri = Uri.parse(
        'https://api.thebharatworks.com/api/user/updateProfilePic',
      );
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['full_name'] = name
        ..fields['aboutUs'] = aboutText
        ..fields['age'] = age ?? ''   // ✅ Age
        ..fields['gender'] = selectedGender ?? 'other'; // ✅ Gender

      request.files.add(
        await http.MultipartFile.fromPath('profilePic', imageFile.path),
      );

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final body = json.decode(resBody.body);

      if (body['status'] == true) {
        setState(() {
          fullName = name;
          aboutUs = aboutText;
          _image = imageFile;
          profilePicUrl = null;
        });
        await _fetchProfileFromAPI();
      }
    } else {
      // 👉 Update profile without image
      final uri = Uri.parse(
        'https://api.thebharatworks.com/api/user/updateUserDetails',
      );
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['full_name'] = name
        ..fields['aboutUs'] = aboutText
        ..fields['age'] = age ?? ''   // ✅ Age
        ..fields['gender'] = selectedGender ?? 'other'; // ✅ Gender

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final body = json.decode(resBody.body);

      if (body['status'] == true) {
        setState(() {
          fullName = name;
          aboutUs = aboutText;
          aboutController.text = aboutText;
        });
        await _fetchProfileFromAPI();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context);
      }
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

  // void _showEditProfileBottomSheet() {
  //   final nameController = TextEditingController(text: fullName ?? '');
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return SafeArea(
  //         child: Padding(
  //           padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.bottom,
  //             left: 16,
  //             right: 16,
  //             top: 24,
  //           ),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Center(
  //                   child: Text(
  //                     "Edit Name",
  //                     style: GoogleFonts.roboto(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Expanded(
  //                       child: TextField(
  //                         controller: nameController,
  //                         maxLength: 20,
  //                         decoration: const InputDecoration(
  //                           labelText: 'Full Name',
  //                           hintText: 'Enter your full name',
  //                           border: OutlineInputBorder(),
  //                           counterText: '',
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Icon(Icons.edit, size: 24, color: Colors.grey),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 20),
  //                 ElevatedButton.icon(
  //                   icon: const Icon(Icons.save, color: Colors.white),
  //                   label: const Text(
  //                     "Save",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                   onPressed: () async {
  //                     Navigator.pop(context);
  //                     await _uploadCombinedProfileData(
  //                       nameController.text,
  //                       aboutUs ?? '',
  //                       null,
  //                     );
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.primaryGreen,
  //                     minimumSize: const Size(double.infinity, 45),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  // void _showEditProfileBottomSheet() {
  //   final nameController = TextEditingController(text: fullName ?? '');
  //   final ageController = TextEditingController(text: age ?? '');
  //   String selectedGender = gender ?? '';
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return SafeArea(
  //             child: Padding(
  //               padding: EdgeInsets.only(
  //                 bottom: MediaQuery.of(context).viewInsets.bottom,
  //                 left: 16,
  //                 right: 16,
  //                 top: 24,
  //               ),
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Center(
  //                       child: Text(
  //                         "Edit Profile",
  //                         style: GoogleFonts.roboto(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 16),
  //
  //                     // 👤 Name
  //                     TextField(
  //                       controller: nameController,
  //                       maxLength: 20,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Full Name',
  //                         border: OutlineInputBorder(),
  //                         counterText: '',
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //
  //                     // 🎂 Age
  //                     TextField(
  //                       controller: ageController,
  //                       keyboardType: TextInputType.number,
  //                       maxLength: 3,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Age',
  //                         border: OutlineInputBorder(),
  //                         counterText: '',
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //
  //                     // 🚻 Gender
  //                     Text("Gender", style: GoogleFonts.roboto(
  //                         fontWeight: FontWeight.bold, fontSize: 14)),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Radio<String>(
  //                               value: "Male",
  //                               groupValue: selectedGender,
  //                               onChanged: (value) {
  //                                 setState(() => selectedGender = value!);
  //                               },
  //                             ),
  //                             const Text("Male"),
  //                           ],
  //                         ),
  //                         Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Radio<String>(
  //                               value: "Female",
  //                               groupValue: selectedGender,
  //                               onChanged: (value) {
  //                                 setState(() => selectedGender = value!);
  //                               },
  //                             ),
  //                             const Text("Female"),
  //                           ],
  //                         ),
  //                         Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Radio<String>(
  //                               value: "Other",
  //                               groupValue: selectedGender,
  //                               onChanged: (value) {
  //                                 setState(() => selectedGender = value!);
  //                               },
  //                             ),
  //                             const Text("Other"),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //
  //
  //                     const SizedBox(height: 20),
  //                     ElevatedButton.icon(
  //                       icon: const Icon(Icons.save, color: Colors.white),
  //                       label: const Text(
  //                         "Save",
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                       onPressed: () async {
  //                         Navigator.pop(context);
  //                         await _uploadCombinedProfileData(
  //                           nameController.text,
  //                           aboutUs ?? '',
  //                           null,
  //                         );
  //                         setState(() {
  //                           fullName = nameController.text;
  //                           age = ageController.text;
  //                           gender = selectedGender;
  //                         });
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: AppColors.primaryGreen,
  //                         minimumSize: const Size(double.infinity, 45),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 20),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showEditProfileBottomSheet() {
    final nameController = TextEditingController(text: fullName ?? '');
    final ageController  = TextEditingController(text: age ?? '');
    String tempGender = (selectedGender ?? '').toLowerCase(); // 👈 API se jo aaya wahi

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16, right: 16, top: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text("Edit Profile", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),

                      TextField(
                        controller: nameController,
                        maxLength: 20,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text("Gender", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Radio<String>(
                              value: 'male',
                              groupValue: tempGender,
                              onChanged: (v) => setModalState(() => tempGender = v!),
                            ),
                            const Text('Male'),
                          ]),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Radio<String>(
                              value: 'female',
                              groupValue: tempGender,
                              onChanged: (v) => setModalState(() => tempGender = v!),
                            ),
                            const Text('Female'),
                          ]),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Radio<String>(
                              value: 'other',
                              groupValue: tempGender,
                              onChanged: (v) => setModalState(() => tempGender = v!),
                            ),
                            const Text('Other'),
                          ]),
                        ],
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Save", style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          Navigator.pop(context);

                          // UI state update
                          setState(() {
                            fullName = nameController.text;
                            age = ageController.text;
                            gender = tempGender;
                            selectedGender = tempGender; // 👈 persist selection
                          });

                          // backend call (agar gender/age bhi bhejna hai to yahan add kar do)
                          await _uploadCombinedProfileData(
                            nameController.text,
                            aboutUs ?? '',
                            null,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  void _showEditAboutBottomSheet() {
    final aboutEditController = TextEditingController(text: aboutUs ?? '');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit About",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aboutEditController,
                  maxLines: 5,
                  maxLength: 400,
                  decoration: const InputDecoration(
                    hintText: 'Write about yourself...',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _uploadCombinedProfileData(
                      fullName ?? '',
                      aboutEditController.text,
                      null,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      await _uploadCombinedProfileData(fullName ?? '', aboutUs ?? '', file);
    }
  }


  Widget _buildProfileImage() {
    ImageProvider? imageProvider;

    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (profilePicUrl != null && profilePicUrl!.isNotEmpty) {
      imageProvider = NetworkImage(profilePicUrl!);
    }

    return Stack(
      children: [
        InkWell(
          onTap: _selectAndUploadImage,
          child: Container(
            padding: EdgeInsets.all(3), // border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.shade700,
                width: 3.0,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: 14,
          right: 4,
          child: GestureDetector(
            onTap: _selectAndUploadImage,
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String? role, String? requestStatus) {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        color: const Color(0xFF9DF89D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     IconButton(
            //       padding: EdgeInsets.zero,
            //       icon: const Icon(Icons.arrow_back, size: 25),
            //       onPressed: () => Navigator.pop(context),
            //     ),
            //     Expanded(
            //       child: Center(
            //         child: Padding(
            //           padding: const EdgeInsets.only(right: 18.0),
            //           child: Text(
            //             "User Profile",
            //             style: GoogleFonts.roboto(
            //               fontSize: 18,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 5),
            // (role == "both")
            //     ? SizedBox()
            //     : (requestStatus == null || requestStatus.isEmpty)
            //     ? Center(child: _buildRoleSwitcher(context,role,requestStatus))
            //     : Container(child: Text("No role found!"))
            Center(child: _buildRoleSwitcher(context,role,requestStatus))
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitcher(BuildContext context, String? role, String? requestStatus) {
    const roleMap = {'User': 'user', 'Worker': 'service_provider'};
    final GetXRoleController roleController = Get.find<GetXRoleController>();

    return Obx(() {
      final String selectedRole = roleController.role.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: _roleButton("User", selectedRole == "user", () async {
              // Agar selectedRole already "user" hai, toh kuch nahi karna
              if (selectedRole == "user") {
                return;
              }
              // Agar role "both" hai aur requestStatus null ya empty hai
              if (role == "both" && (requestStatus == null || requestStatus!.isEmpty)) {
                await roleController.updateRole('user');
                Get.off(() => ProfileScreen());
              } else {
                // Agar requestStatus null ya empty hai
                if (requestStatus == null || requestStatus!.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: const Text("Confirmation Box")),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           /* Image.asset(
                              "assets/images/rolechangeConfim.png",
                              height: 90,
                            ),*/
                            SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                            const SizedBox(height: 8),
                            const Text(
                              "Confirmation",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text("If you’d like to become a service provider, kindly complete and submit the document form."),
                            const SizedBox(height: 8),
                          ],
                        ),
                        actions: [
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green,
                            ),
                            child: TextButton(
                              child: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (role == "both") {
                                  await roleController.updateRole('user');
                                }
                                Navigator.of(context).pop();
                                Get.off(() => ProfileScreen());
                              },
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: TextButton(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Jab requestStatus null ya empty nahi hai
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*Image.asset(
                              "assets/images/rolechangeConfim.png",
                              height: 90,
                            ),*/
                            SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                            const SizedBox(height: 8),
                            const Text(
                              "Request Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Profile has been submitted\n waiting for admin approval",
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        actions: [
                          Center(
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.green,
                              ),
                              child: TextButton(
                                child: const Text(
                                  "OK",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            }),
          ),
          const SizedBox(width: 16),
          Container(

            decoration: BoxDecoration(
              color: Colors.white, // background color
              borderRadius: BorderRadius.circular(12), // rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4), // shadow position
                ),
              ],
            ),
            child: InkWell(
              child: _roleButton("Worker", selectedRole == "service_provider", () async {
                // Agar selectedRole already "service_provider" hai, toh kuch nahi karna
                if (selectedRole == "service_provider") {
                  return;
                }
                // Agar role "both" hai aur requestStatus null ya empty hai
                if (role == "both" && (requestStatus == null || requestStatus!.isEmpty)) {
                  await roleController.updateRole('service_provider');
                  Get.off(() => SellerScreen());
                } else {
                  // Agar requestStatus null ya empty hai
                  if (requestStatus == null || requestStatus!.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Center(child: const Text("Confirmation Box")),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/confimationImage.png",
                                height: 120,
                              ),
                              // SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                              // SvgPicture.asset(
                              //   'assets/svg_images/ConfirmationIcon.svg', // Suggested placeholder, replace with actual path
                              //   height: 60,
                              //
                              // ),
                              const SizedBox(height: 8),
                              const Text(
                                "Confirmation",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text("If you’d like to become a service provider, kindly complete and submit the document form."),
                              const SizedBox(height: 8),
                            ],
                          ),
                          actions: [                                                       //     this is current page for confarmation
                            Card(
                              child: Container(
                                width: 100,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.green,
                                ),
                                child: TextButton(
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (role == "both") {
                                      await roleController.updateRole('service_provider');
                                    } else {
                                    // await switchRoleRequest();
                                    }
                                    Navigator.of(context).pop();
                                    Get.off(() => RoleEditProfileScreen(updateBothrequest: true,));

                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: TextButton(
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Jab requestStatus null ya empty nahi hai
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Request Submitted"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Image.asset(
                              //   "assets/images/rolechangeConfim.png",
                              //   height: 90,
                              // ),
                              Image.asset(
                                "assets/images/confimationImage.png",
                                height: 120,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Request Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Profile has been submitted\n waiting for admin approval",
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                          actions: [
                            Center(
                              child: Container(
                                width: 100,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.green,
                                ),
                                child: TextButton(
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _roleButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 140,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade700),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF9DF89D),
        centerTitle: true,
        title: const Text("User Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // _buildHeader(context,requestStatus),
                _buildHeader(context, role,requestStatus),


                Positioned(
                  top: 180,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${fullName?[0].toUpperCase()}${fullName?.substring(1).toLowerCase()}',
                            // fullName ?? 'Your Name',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _showEditProfileBottomSheet,
                            child: /*Image.asset('assets/images/edit1.png'),*/ SvgPicture.asset("assets/svg_images/editicon.svg")
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Age: ${age ?? 0}',
                            // fullName ?? 'Your Name',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ), SizedBox(width: 6,),
                          Text(
                            'Gender: ${ (gender != null && gender!.isNotEmpty)
                                ? "${gender?[0].toUpperCase()}${gender?.substring(1).toLowerCase()}"
                                : "No data"}',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (phone != null && phone!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            phone!,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.swithcrole == 'serviceroleSwitch' ?   Text("Note: If you want to change your role, please fill out the About Us form.",style: TextStyle(color: Colors.red,fontSize: 12),) : SizedBox() ,
                              Row(
                                children: [
                                  Text(
                                    "About Us",
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: _showEditAboutBottomSheet,
                                    child: /*Image.asset(
                                      'assets/images/edit1.png',
                                    ),*/SvgPicture.asset("assets/svg_images/editicon.svg")
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 140,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: aboutController,
                                  readOnly: true,
                                  maxLines: null,
                                  style: GoogleFonts.roboto(fontSize: 14),
                                  decoration: const InputDecoration.collapsed(
                                    hintText: 'Write about yourself...',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    aboutController.dispose();
    super.dispose();
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
