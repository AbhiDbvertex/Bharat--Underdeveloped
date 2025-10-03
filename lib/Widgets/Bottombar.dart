import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../chat/chat_user_list_screen.dart';
import '../directHiring/views/Account/AccountScreen.dart';
import '../directHiring/views/ServiceProvider/ServiceProviderHomeScreen.dart';
import '../directHiring/views/ServiceProvider/WorkerMyHireScreen.dart';
import '../directHiring/views/User/MyHireScreen.dart';
import '../directHiring/views/User/UserHomeScreen.dart';
import '../directHiring/views/auth/RoleSelectionScreen.dart';
import '../testingfile.dart';
import 'AppColors.dart';

class Bottombar extends StatefulWidget {
  final int? initialIndex;
  const Bottombar({super.key, this.initialIndex = 0});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  int _currentIndex = 0;
  late List<Widget> _userScreens;
  late List<Widget> _serviceProviderScreens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;

    _userScreens = [
      const UserHomeScreen(),
      const MyHireScreen(),
      WorkerMyHireScreen(
        categreyId: 'default_category_id',
        subcategreyId: 'default_sub_category_id',
      ),
      // const PlaceholderScreen(label: 'My Work'),
      // const PlaceholderScreen(label: 'Message'),
      ChatScreen(initialReceiverId: '',),
      const AccountScreen(),
    ];

    _serviceProviderScreens = [
       ServiceProviderHomeScreen(),
      const MyHireScreen(),
      // const PlaceholderScreen(label: 'My Hire'),
      WorkerMyHireScreen(
        categreyId: 'default_category_id',
        subcategreyId: 'default_sub_category_id',
      ),
      // const PlaceholderScreen(label: 'Message'),
      ChatScreen(initialReceiverId: '',),
      const AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final GetXRoleController roleController = Get.find<GetXRoleController>();

    return Obx(() {
      if (roleController.isRoleLoading.value || roleController.role.value.isEmpty) {
        print("Abhi:- Waiting for role to load, isRoleLoading: ${roleController.isRoleLoading.value}, role: ${roleController.role.value}");
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final String myrole = roleController.role.value;
      final String categoryId = roleController.categoryId.value;
      final String subCategoryId = roleController.subCategoryId.value;

      print("Abhi:- get role in bottom bar screen: $myrole");

      _serviceProviderScreens[2] = WorkerMyHireScreen(
        categreyId: categoryId,
        subcategreyId: subCategoryId,
      );

      List<Widget> selectedScreens = myrole == "service_provider" ? _serviceProviderScreens : _userScreens;

      return Scaffold(
        body: selectedScreens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            print("Tab Clicked: $index");
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svg_images/bottombar/home.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 0 ? Colors.green : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svg_images/bottombar/task-square.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 1 ? Colors.green : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              label: 'My Hire',
            ),
            BottomNavigationBarItem(
              icon: /*ImageIcon(AssetImage('assets/images/Job.png'), size: 24),*/ SvgPicture.asset(
                'assets/svg_images/bottombar/corporate-alt.svg', // Suggested placeholder, replace with actual path
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 2 ? Colors.green : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              label: 'My Work',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svg_images/bottombar/messages.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 3 ? Colors.green : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svg_images/bottombar/profile-circle.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 4 ? Colors.green : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Account',
            ),
          ],
        ),
      );
    });
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String label;

  const PlaceholderScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text(label,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: SizedBox(),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Center(child: Text('$label Screen')),
    );
  }
}