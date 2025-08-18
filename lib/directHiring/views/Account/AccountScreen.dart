import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/AccountController.dart';
import '../../models/AccountModel/AccountModel.dart';
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
  ];

  @override
  void initState() {
    super.initState();
    _futureUser = _controller.fetchUserProfileData(context);
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
      body: SafeArea(
        child: FutureBuilder<AccountModel?>(
          future: _futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Center(child: Text("❌ Failed to load user info"));
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Account",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundColor: Colors.grey[300],
                  //   backgroundImage:
                  //       user.imageUrl.isNotEmpty
                  //           ? NetworkImage(user.imageUrl)
                  //           : null,
                  // ),
                  Container(
                    padding: EdgeInsets.all(3), // border thickness adjust here
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
                  /*Text(
                    user.name.toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),*/
                  Text(
                    '${user.name[0].toUpperCase()}${user.name.substring(1).toLowerCase()}',
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
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final role =
                                    (prefs.getString('role') ?? '')
                                        .toLowerCase()
                                        .trim();

                                print(
                                  "🔍 Role from prefs: $role",
                                ); // <-- add this

                                Widget screen;
                                if (role == "customer") {
                                  screen =
                                      const ProfileScreen(); // User profile
                                } else if (role == "service_provider") {
                                  screen =
                                      const SellerScreen(); // Seller profile
                                } else {
                                  screen =
                                      const ProfileScreen(); // Default fallback
                                }

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => screen),
                                );

                                setState(() {
                                  _futureUser = _controller
                                      .fetchUserProfileData(context);
                                });
                              } else {
                                _controller.handleOptionTap(
                                  options[index],
                                  context,
                                );
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
                          builder:
                              (context) => Dialog(
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
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Colors.green,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
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
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
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
