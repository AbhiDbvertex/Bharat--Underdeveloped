// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Widgets/AppColors.dart';
// import '../../controllers/AccountController/AccountController.dart';
// import '../../models/AccountModel/AccountModel.dart';
// import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../auth/LoginScreen.dart';
// import 'service_provider_profile/ServiceProviderProfileScreen.dart';
// import 'user_profile/UserProfileScreen.dart';
//
// class AccountScreen extends StatefulWidget {
//   const AccountScreen({super.key});
//
//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }
//
// class _AccountScreenState extends State<AccountScreen> {
//   final AccountController _controller = AccountController();
//   late Future<AccountModel?> _futureUser;
//   ServiceProviderProfileModel? profile;
//   final List<String> options = [
//     'My Profile',
//     'Membership',
//     'Bank Details',
//     'T&C',
//     'Privacy Policy',
//     'About Us',
//     'FAQ',
//     'Referral',
//     'Contact Us',
//     'Disputes',
//     'promotion'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _futureUser = _controller.fetchUserProfileData(context);
//   }
//
//   Future<void> switchRoleRequest() async{
//     final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
//     print("Abhi:- switchRoleRequest url :$url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     try{
//
//       var response = await http.post(Uri.parse(url), headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },);
//       if(response.statusCode ==200 || response.statusCode ==201){
//         print("Abhi:- switchRoleRequest response ${response.body}");
//         print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
//       }else{
//         print("Abhi:- else switchRoleRequest response ${response.body}");
//         print("Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
//       }
//     }
//     catch(e){print("Abhi:- get Exception $e");}
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
//       body: SafeArea(
//         child: FutureBuilder<AccountModel?>(
//           future: _futureUser,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (snapshot.hasError ||
//                 !snapshot.hasData ||
//                 snapshot.data == null) {
//               return const Center(child: Text("❌ Failed to load user info"));
//             }
//
//             final user = snapshot.data!;
//
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   Text(
//                     "Account",
//                     style: GoogleFonts.roboto(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   // CircleAvatar(
//                   //   radius: 50,
//                   //   backgroundColor: Colors.grey[300],
//                   //   backgroundImage:
//                   //       user.imageUrl.isNotEmpty
//                   //           ? NetworkImage(user.imageUrl)
//                   //           : null,
//                   // ),
//                   Container(
//                     padding: EdgeInsets.all(3), // border thickness adjust here
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.green.shade700,
//                         width: 3.0,
//                       ),
//                     ),
//                     child: CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage: user.imageUrl.isNotEmpty
//                           ? NetworkImage(user.imageUrl)
//                           : null,
//                       child: user.imageUrl.isEmpty
//                           ? const Icon(
//                         Icons.person,
//                         size: 50,
//                         color: Colors.white,
//                       )
//                           : null,
//                     ),
//                   ),
//                   /*Text(
//                     user.name.toUpperCase(),
//                     style: GoogleFonts.roboto(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),*/
//                   // Text(
//                   //   '${user.name[0].toUpperCase()}${user.name.substring(1).toLowerCase()}',
//                   //   style: GoogleFonts.roboto(
//                   //     fontSize: 22,
//                   //     fontWeight: FontWeight.w700,
//                   //   ),
//                   // ),
//
//                   Text(
//                     (user.name != null && user.name.isNotEmpty)
//                         ? '${user.name[0].toUpperCase()}${user.name.substring(1).toLowerCase()}'
//                         : "No Name",
//                     style: GoogleFonts.roboto(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//
//
//                   const SizedBox(height: 30),
//                   ListView.separated(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: options.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 20),
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Container(
//                           height: 55,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.green, width: 1),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: ListTile(
//                             title: Text(
//                               options[index],
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.roboto(fontSize: 14),
//                             ),
//                             trailing: const Icon(
//                               Icons.arrow_forward_ios,
//                               size: 16,
//                               color: Color(0xFF2D728F),
//                             ),
//                             // onTap: () async {
//                             //   if (options[index] == "My Profile") {
//                             //     final prefs =
//                             //         await SharedPreferences.getInstance();
//                             //     final role =
//                             //         (prefs.getString('role') ?? '')
//                             //             .toLowerCase()
//                             //             .trim();
//                             //
//                             //     print(
//                             //       "🔍 Role from prefs: $role",
//                             //     ); // <-- add this
//                             //
//                             //     Widget screen;
//                             //     if (role == "customer") {
//                             //       screen =
//                             //           const ProfileScreen(); // User profile
//                             //     } else if (role == "service_provider") {
//                             //       screen =
//                             //           const SellerScreen(); // Seller profile
//                             //     } else if(role == "service_provider" && profile?.verified == false){
//                             //       await switchRoleRequest();
//                             //       screen = const ProfileScreen();
//                             //     }
//                             //     else {
//                             //       screen =
//                             //           const ProfileScreen(); // Default fallback
//                             //     }
//                             //
//                             //     await Navigator.push(
//                             //       context,
//                             //       MaterialPageRoute(builder: (_) => screen),
//                             //     );
//                             //
//                             //     setState(() {
//                             //       _futureUser = _controller
//                             //           .fetchUserProfileData(context);
//                             //     });
//                             //   } else {
//                             //     _controller.handleOptionTap(
//                             //       options[index],
//                             //       context,
//                             //     );
//                             //   }
//                             // },
//                               onTap: () async {
//                                 if (options[index] == "My Profile") {
//                                   final prefs = await SharedPreferences.getInstance();
//                                   final role = (prefs.getString('role') ?? '').toLowerCase().trim();
//
//                                   print("🔍 Role from prefs: $role");
//
//                                   Widget screen;
//
//                                   if (role == "service_provider" && profile?.verified == false) {
//                                     await switchRoleRequest();
//                                     screen = const ProfileScreen();
//                                   } else if (role == "customer") {
//                                     screen = const ProfileScreen();
//                                   } else if (role == "service_provider") {
//                                     screen = const SellerScreen();
//                                   } else {
//                                     screen = const ProfileScreen();
//                                   }
//                                   await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(builder: (_) => screen),
//                                   );
//
//                                   setState(() {
//                                     _futureUser = _controller.fetchUserProfileData(context);
//                                   });
//                                 } else {
//                                   _controller.handleOptionTap(
//                                     options[index],
//                                     context,
//                                   );
//                                 }
//                               }
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: 280,
//                     height: 60,
//                     child: ElevatedButton.icon(
//                       onPressed: () async {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder:
//                               (context) => Dialog(
//                                 backgroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(20.0),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Image.asset(
//                                         'assets/images/delete2.png',
//                                         height: 140,
//                                       ),
//                                       const SizedBox(height: 20),
//                                       const Text(
//                                         'Are you sure you want\n to logout?',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 20),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: ElevatedButton(
//                                               onPressed:
//                                                   () => Navigator.pop(
//                                                     context,
//                                                     true,
//                                                   ),
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: Colors.green,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                               ),
//                                               child: const Text(
//                                                 'Logout',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Expanded(
//                                             child: OutlinedButton(
//                                               onPressed:
//                                                   () => Navigator.pop(
//                                                     context,
//                                                     false,
//                                                   ),
//                                               style: OutlinedButton.styleFrom(
//                                                 side: const BorderSide(
//                                                   color: Colors.green,
//                                                 ),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                               ),
//                                               child: const Text(
//                                                 'Cancel',
//                                                 style: TextStyle(
//                                                   color: Colors.green,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                         );
//
//                         if (confirm == true) {
//                           final prefs = await SharedPreferences.getInstance();
//                           await prefs.clear();
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const LoginScreen(),
//                             ),
//                             (route) => false,
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.logout, color: Colors.white),
//                       label: const Text(
//                         "Log out",
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green.shade700,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:developer/directHiring/views/Account/service_provider_profile/first_time_serviceprovider_profile.dart';
import 'package:developer/directHiring/views/Account/user_profile/both_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../controllers/AccountController/AccountController.dart';
import '../../models/AccountModel/AccountModel.dart';
import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../auth/LoginScreen.dart';
import 'service_provider_profile/ServiceProviderProfileScreen.dart';
import 'user_profile/UserProfileScreen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountController _controller = AccountController();
  late Future<AccountModel?> _futureUser;
  ServiceProviderProfileModel? profile;
  bool isLoading = true;
  bool _showReviews = true;
  String? address = "";
  final List<String> options = [
    'My Profile',
    'Membership',
    'Bank Details',
    'T&C',
    'Privacy Policy',
    'About Us',
    'FAQ',
    'Referral',
    'Contact Us',
    'Disputes',
    'Promotions'
  ];

  @override
  void initState() {
    super.initState();
    _futureUser = _controller.fetchUserProfileData(context);
    _fetchProfileData(); // Profile data fetch karne ke liye
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/getUserProfileData",
      );
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      print("Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Data: $data");

        if (data['status'] == true) {
          final fetchedAddress =
          data['data'] != null && data['data']['location'] != null
              ? (data['data']['location']['address'] ?? 'Select Location')
              : 'Select Location';

          await prefs.setString("address", fetchedAddress);

          setState(() {
            profile = ServiceProviderProfileModel.fromJson(data['data']);
            isLoading = false;
            address = fetchedAddress;
          });

          print("Saved address: $fetchedAddress");
        } else {

            CustomSnackBar.show(
              message: data["message"] ?? "Profile fetch failed",
              type: SnackBarType.error
          );
        }
      } else {

         CustomSnackBar.show(
            message: "Server error, profile fetch failed!",
            type: SnackBarType.error
        );
      }
    } catch (e) {
      print("Error: $e");

       CustomSnackBar.show(
          message: "Something went wrong, try again!",
          type: SnackBarType.error
      );
    }
  }

  // Profile data fetch karne ka function
  Future<void> _fetchProfileData() async {
    try {
      print("🔍 Fetching profile data...");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("🔍 Error: Token is null or empty");
        return;
      }

      // Apna actual API endpoint daalo
      final String profileUrl = "https://api.thebharatworks.com/api/user/getUserProfileData";
      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("🔍 Profile API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          profile = ServiceProviderProfileModel.fromJson(jsonData); // Apna parsing logic daalo
        });
        // toJson ke bajaye direct fields print karo
        print("🔍 Profile fetched: verified=${profile?.verificationStatus == 'pending'}, other fields=${jsonData}");
      } else {
        print("🔍 Failed to fetch profile: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔍 Error fetching profile: $e");
    }
  }

  Future<void> switchRoleRequest() async {
    final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
    print("🔍 switchRoleRequest URL: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("🔍 Error: Token is null or empty");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"role": "service_provider"}),
      );

      print("🔍 switchRoleRequest Response: ${response.body}");
      print("🔍 switchRoleRequest Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("🔍 Role switch request successful");
        await _fetchProfileData(); // Profile refresh karo
      } else {
        print("🔍 Role switch request failed: ${response.body}");
      }
    } catch (e) {
      print("🔍 Exception in switchRoleRequest: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Account",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: SizedBox(),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<AccountModel?>(
          future: _futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Failed to load user info"));
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade700,
                        width: 3.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: user.imageUrl.isNotEmpty
                          ? NetworkImage(user.imageUrl)
                          : null,
                      child: user.imageUrl.isEmpty
                          ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (user.name != null && user.name.isNotEmpty)
                        ? '${user.name[0].toUpperCase()}${user.name.substring(1).toLowerCase()}'
                        : "No Name",
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 55,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              options[index],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(fontSize: 14),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF2D728F),
                            ),
                            onTap: () async {
                              if (options[index] == "My Profile") {
                                final prefs = await SharedPreferences.getInstance();
                                final role = (prefs.getString('role') ?? '').toLowerCase().trim();

                                print("🔍 Role from prefs: '$role'");
                                print("🔍 Profile sadfas: ${profile?.verificationStatus}");
                                // print("🔍 Profile sadfas: ${_futureUser?['']}");
                                print("🔍 Profile verified: ${profile?.verificationStatus == 'pending'}");

                                Widget screen;

                                // Condition for service_provider with unverified profile

                                if (role == "service_provider" && profile != null && profile!.verificationStatus == 'pending') {
                                  print("🔍 Calling switchRoleRequest for unverified service provider");
                                  // await switchRoleRequest();
                                  screen = const FirstTimeServiceProviderProfileScreen();
                                } else if (profile!.verificationStatus == 'rejected'){
                                  screen = const FirstTimeServiceProviderProfileScreen();
                                } else if (role == "customer") {

                                  print("🔍 Navigating to ProfileScreen for customer");
                                  screen = const ProfileScreen();
                                } else if (role == "service_provider") {
                                  print("🔍 Navigating to SellerScreen for verified service provider");
                                  screen = const SellerScreen();
                                } else {
                                  print("🔍 Fallback to ProfileScreen for unknown role");
                                  screen = const ProfileScreen();
                                }

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => screen),
                                );

                                setState(() {
                                  _futureUser = _controller.fetchUserProfileData(context);
                                  _fetchProfileData(); // Profile bhi refresh karo
                                });
                              } else {
                                _controller.handleOptionTap(options[index], context);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 280,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/delete2.png',
                                    height: 140,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Are you sure you want\n to logout?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Logout',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.green),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        if (confirm == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Log out",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}