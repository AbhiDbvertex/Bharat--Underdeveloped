import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';

class ViewUserProfileScreen extends StatefulWidget {
  final String userId;
  final profileImage;
  const ViewUserProfileScreen({super.key, required this.userId, this.profileImage});

  @override
  State<ViewUserProfileScreen> createState() => _ViewUserProfileScreenState();
}

class _ViewUserProfileScreenState extends State<ViewUserProfileScreen> {
  String? profilePicUrl;
  String? fullName;
  String? aboutUs;
  String? phone;
  late TextEditingController aboutController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    aboutController = TextEditingController();
    _fetchProfileFromAPI();
  }

  Future<void> _fetchProfileFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('Login Again!');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Again!')));
        setState(() => isLoading = false);
        return;
      }

      print("📋 Fetching profile for userId: ${widget.userId}");
      // Fallback endpoint for customer data
      final response = await http.get(
        Uri.parse(
          'https://api.thebharatworks.com/api/user/getUser/${widget.userId}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print("📥 User API Response: ${response.body}");
        if (body['success'] == true) {
          final data = body['user'];
          setState(() {
            fullName = data['full_name'] ?? 'Unknown User';
            phone = data['phone'] ?? 'No Phone';
            profilePicUrl =
            data['profile_pic'] != null
                ? data['profile_pic'].startsWith('http')
                ? data['profile_pic']
                : 'https://api.thebharatworks.com${data['profile_pic']}'
                : null;
            aboutUs = data['aboutUs'] ?? 'No info available';
            aboutController.text = aboutUs!;
            isLoading = false;
          });
          print(
            "✅ Profile data set: Name=$fullName, Phone=$phone, ProfilePic=$profilePicUrl",
          );
        } else {
          print("❌ User API failed: ${body['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User   data not found: ${body['message']}'),
            ),
          );
          setState(() {
            fullName = 'Unknown User';
            phone = 'No Phone';
            aboutUs = 'No info available';
            aboutController.text = aboutUs!;
            isLoading = false;
          });
        }
      } else {
        print(": ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode} - ${response.body}'),
          ),
        );
        setState(() {
          fullName = 'Unknown User';
          phone = 'No Phone';
          aboutUs = 'No info available';
          aboutController.text = aboutUs!;
          isLoading = false;
        });
      }
    } catch (e) {
      print(': $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(': $e')));
      setState(() {
        fullName = 'Unknown User';
        phone = 'No Phone';
        aboutUs = 'No info available';
        aboutController.text = aboutUs!;
        isLoading = false;
      });
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade700, width: 3.0),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
            // profilePicUrl != null && profilePicUrl!.isNotEmpty
            //     ? NetworkImage(profilePicUrl!)
            //     : null,
    widget.profileImage != null && widget.profileImage.isNotEmpty
             ? NetworkImage(widget.profileImage)
             : null,
            child:
            profilePicUrl == null || profilePicUrl!.isEmpty
                ? const Text(
              'No Pic',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
                : null,
          ),
        ),
        // Positioned(
        //   bottom: 14,
        //   right: 4,
        //   child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
        // ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        color: const Color(0xFF9DF89D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 140,
        width: double.infinity,
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
            //             "Profile",
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
           // Center(child: _buildRoleSwitcher(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitcher(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roleButton("User", true, () {}),
        const SizedBox(width: 16),
        _roleButton("Worker", false, () {}),
      ],
    );
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF9DF89D),
        centerTitle: true,
        title: const Text("Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: Color(0xFF9DF89D),
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child:
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(context),
                Positioned(
                  top: 170, // Adjusted to fit better
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 8),
                      Text(
                        fullName ?? 'Unknown User',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone ?? 'No Phone',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black54,
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
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "About Us",
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Text(
                                  aboutUs ?? 'No info available',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
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
