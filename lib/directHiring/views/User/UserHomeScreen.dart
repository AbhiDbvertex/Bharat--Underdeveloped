import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Bidding/view/user/bidding_post_task_screen.dart';
import '../../../Emergency/User/screens/emergency_services.dart';
import '../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../models/userModel/WorkCategoryModel.dart';
import '../../models/userModel/Worker.dart';
import '../comm/home_location_screens.dart';
import '../comm/view_images_screen.dart';
import 'SubCategories.dart';
import 'UserNotificationScreen.dart';
import 'WorkerCategories.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  String? userLocation = 'Select Location'; // Default location
  List<Worker> workers = [
    Worker(name: 'Dipak Sharma', role: 'Plumber', rating: 4.5),
    Worker(name: 'Ravi Kumar', role: 'Electrician', rating: 4.2),
    Worker(name: 'Sita Verma', role: 'Cleaner', rating: 4.8),
  ];
  List<WorkCategoryModel> allCategories = [];
  bool isLoading = true;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  List<String> bannerImages = [];
  bool isBannerLoading = true;

  @override
  void initState() {
    super.initState();
    loadSavedLocation(); // Load saved location first
    fetchCategories(); // Fetch categories
    _fetchLocation();
    // setupStaticBanners();
    fetchBanners();
  }

  void setupStaticBanners() {
    setState(() {
      bannerImages = [
        'https://picsum.photos/id/1018/800/400',
        'https://picsum.photos/id/1025/800/400',
        'https://picsum.photos/id/1069/800/400',
      ];
      isBannerLoading = false;
    });
  }

  Future<void> fetchBanners() async {
    setState(() {
      isBannerLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        bwDebug("❌ No token found for fetching banners");
        setState(() => isBannerLoading = false);
        return;
      }
      final url =
          Uri.parse('https://api.thebharatworks.com/api/banner/getAllBannerImages');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['images'] is List) {
          setState(() {
            bannerImages = (data['images'] as List)
                .map((item) => item.toString())
                .toList();
            isBannerLoading = false;
          });
        } else {
          debugPrint("❌ API response for banners not in expected format.");
          setState(() => isBannerLoading = false);
        }
      } else {
        debugPrint(
            "❌ Failed to load banners. Status code: ${response.statusCode}");
        setState(() => isBannerLoading = false);
      }
    } catch (e) {
      debugPrint("❗ Exception while fetching banners: $e");
      setState(() => isBannerLoading = false);
    }
  }

  Future<void> loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString('selected_location') ?? prefs.getString('address');
    setState(() {
      userLocation = savedLocation ?? 'Select Location';
      isLoading = false;
    });
    debugPrint("📍 Loaded saved location: $userLocation");
  }

  Future<void> _fetchLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString('selected_location') ?? prefs.getString('address');
    String? savedAddressId = prefs.getString('selected_address_id');

    if (savedLocation != null &&
        savedLocation != 'Select Location' &&
        savedAddressId != null) {
      setState(() {
        userLocation = savedLocation;
        isLoading = false;
      });
      debugPrint(
        "📍 Prioritized saved location: $userLocation (ID: $savedAddressId)",
      );
      return;
    }

    // If no saved location, fetch from API
    setState(() {
      isLoading = true;
    });

    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      debugPrint("❌ No token found!");
      setState(() {
        userLocation = savedLocation ?? 'Select Location';
        isLoading = false;
      });
      debugPrint("📍 Using saved or default location: $userLocation");
      if (mounted) {
         CustomSnackBar.show(
            message:'Authentication failed, please log in again!' ,
            type: SnackBarType.error
        );

      }
      return;
    }

    try {
      final url = Uri.parse(
        'https://api.thebharatworks.com/api/user/getUserProfileData',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        "📡 API response received: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          final data = responseData['data'];
          String apiLocation = 'Select Location';
          double latitude = 0.0;
          double longitude = 0.0;
          String? addressId;

          // Check for matching address based on savedAddressId
          if (savedAddressId != null && data['full_address'] != null) {
            final matchingAddress = data['full_address'].firstWhere(
              (address) => address['_id'] == savedAddressId,
              orElse: () => null,
            );
            if (matchingAddress != null) {
              apiLocation = matchingAddress['address'] ?? 'Select Location';
              latitude = matchingAddress['latitude']?.toDouble() ?? 0.0;
              longitude = matchingAddress['longitude']?.toDouble() ?? 0.0;
              addressId = matchingAddress['_id'];
            }
          }

          // If no matching address or savedAddressId, use latest "Current Location" address
          if (apiLocation == 'Select Location' &&
              data['full_address'] != null &&
              data['full_address'].isNotEmpty) {
            final currentLocations = data['full_address']
                .where((address) => address['title'] == 'Current Location')
                .toList();
            if (currentLocations.isNotEmpty) {
              // Use the latest "Current Location" address
              final latestCurrentLocation = currentLocations.last;
              apiLocation =
                  latestCurrentLocation['address'] ?? 'Select Location';
              latitude = latestCurrentLocation['latitude']?.toDouble() ?? 0.0;
              longitude = latestCurrentLocation['longitude']?.toDouble() ?? 0.0;
              addressId = latestCurrentLocation['_id'];
            } else {
              // Fallback to the last address
              final latestAddress = data['full_address'].last;
              apiLocation = latestAddress['address'] ?? 'Select Location';
              latitude = latestAddress['latitude']?.toDouble() ?? 0.0;
              longitude = latestAddress['longitude']?.toDouble() ?? 0.0;
              addressId = latestAddress['_id'];
            }
          } else if (data['location']?['address']?.isNotEmpty == true) {
            // Fallback to location.address
            apiLocation = data['location']['address'];
            latitude = data['location']['latitude']?.toDouble() ?? 0.0;
            longitude = data['location']['longitude']?.toDouble() ?? 0.0;
          }

          debugPrint(
            "📍 Location fetched from API: $apiLocation (ID: $addressId)",
          );

          // Save API location to SharedPreferences
          await prefs.setString('selected_location', apiLocation);
          await prefs.setString('address', apiLocation);
          await prefs.setDouble('user_latitude', latitude);
          await prefs.setDouble('user_longitude', longitude);
          if (addressId != null) {
            await prefs.setString('selected_address_id', addressId);
          }

          setState(() {
            userLocation = apiLocation;
            isLoading = false;
          });
          debugPrint(
            "📍 Saved API location and displayed in UI: $userLocation (ID: $addressId)",
          );
        } else {
          setState(() {
            userLocation = savedLocation ?? 'Select Location';
            isLoading = false;
          });
          debugPrint("❌ API error: ${responseData['message']}");
          if (mounted) {

             CustomSnackBar.show(
                message: responseData['message'] ?? 'Failed to fetch profile',
                type: SnackBarType.error
            );

          }
        }
      } else {
        setState(() {
          userLocation = savedLocation ?? 'Select Location';
          isLoading = false;
        });
        debugPrint("❌ API call failed: ${response.statusCode}");
        if (mounted) {

            CustomSnackBar.show(
              message:'Failed to fetch profile data!' ,
              type: SnackBarType.error
          );

        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching location: $e");
      setState(() {
        userLocation = savedLocation ?? 'Select Location';
        isLoading = false;
      });
      if (mounted) {

         CustomSnackBar.show(
            message:'Error fetching location ',
            type: SnackBarType.error
        );

      }
    }
  }

  Future<void> updateLocationOnServer(
    String newAddress,
    double latitude,
    double longitude,
  ) async {
    if (newAddress.isEmpty || latitude == 0.0 || longitude == 0.0) {
      debugPrint("❌ Invalid location data: $newAddress, $latitude, $longitude");
      if (mounted) {

         CustomSnackBar.show(
            message:"Invalid location data" ,
            type: SnackBarType.error
        );


      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/user/updateUserProfile',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_address': [
            {
              'address': newAddress,
              'latitude': latitude,
              'longitude': longitude,
              'title': 'Current Location', // Ensure title is set
              'landmark': '',
            },
          ],
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'address': newAddress,
          },
        }),
      );

      debugPrint(
        "📡 Location update response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          String? newAddressId = data['data']?['full_address']?.last?['_id'];
          await prefs.setString('selected_location', newAddress);
          await prefs.setString('address', newAddress);
          await prefs.setDouble('user_latitude', latitude);
          await prefs.setDouble('user_longitude', longitude);
          if (newAddressId != null) {
            await prefs.setString('selected_address_id', newAddressId);
          }
          setState(() {
            userLocation = newAddress;
            isLoading = false;
          });
          debugPrint(
            "📍 Saved new location and updated UI: $newAddress (ID: $newAddressId)",
          );
          if (mounted) {

             CustomSnackBar.show(
                message:"Location updated successfully : $newAddress" ,
                type: SnackBarType.success
            );
          }
        } else {
          if (mounted) {

             CustomSnackBar.show(
                message: "Location update failed: ${data['message']}",
                type: SnackBarType.error
            );

          }
        }
      } else {
        if (mounted) {

            CustomSnackBar.show(
              message: "Server error, location update failed!",
              type: SnackBarType.error
          );

        }
      }
    } catch (e) {
      debugPrint("❌ Error updating location: $e");
      if (mounted) {

         CustomSnackBar.show(
            message:"Error updating location" ,
            type: SnackBarType.error
        );

      }
    }
  }

  void _navigateToLocationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          onLocationSelected: (Map<String, dynamic> locationData) {
            setState(() {
              userLocation = locationData['address'] ?? 'Select Location';
              debugPrint(
                "📍 New location selected: ${locationData['address']} (ID: ${locationData['addressId']})",
              );
            });
          },
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      String newAddress = result['address'] ?? 'Select Location';
      double latitude = result['latitude'] ?? 0.0;
      double longitude = result['longitude'] ?? 0.0;
      String? addressId = result['addressId'];
      if (newAddress != 'Select Location' &&
          latitude != 0.0 &&
          longitude != 0.0) {
        await updateLocationOnServer(newAddress, latitude, longitude);
        // Save addressId to SharedPreferences
        if (addressId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_address_id', addressId);
        }
        // Refresh location
        await _fetchLocation();
      } else {
        debugPrint("❌ Invalid location data received: $result");
        if (mounted) {

            CustomSnackBar.show(
              message: "Invalid location data, please try again!",
              type: SnackBarType.error
          );

        }
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("❌ No token found");
        setState(() => isLoading = false);
        return;
      }

      final uri = Uri.parse('https://api.thebharatworks.com/api/work-category');
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true && jsonData["data"] is List) {
          setState(() {
            allCategories = (jsonData["data"] as List)
                .map((item) => WorkCategoryModel.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❗ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("📍 Current userLocation: $userLocation");
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar:/* AppBar(
          backgroundColor: Colors.green.shade800,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 10,
          automaticallyImplyLeading: false,
        ),*/

        AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: _navigateToLocationScreen,
                child: SvgPicture.asset('assets/svg_images/LocationIcon.svg'),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: GestureDetector(
                  onTap: _navigateToLocationScreen,
                  child: Text(
                    userLocation ?? 'Select Location',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              SvgPicture.asset('assets/svg_images/homepageLogo.svg'),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserNotificationScreen(),
                    ),
                  );
                },
                child: SvgPicture.asset('assets/svg_images/notificationIcon.svg'),
              ),
            ],
          ),
          actions: [],
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: AppColors.primaryGreen,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //   child: Row(
                //     children: [
                //       Container(
                //         // color: Colors.red,
                //         child: GestureDetector(
                //           onTap: _navigateToLocationScreen,
                //           child: SvgPicture.asset(
                //               'assets/svg_images/LocationIcon.svg'),
                //         ),
                //       ),
                //       const SizedBox(width: 5),
                //       Container(
                //         // color: Colors.blue,
                //         width: width * 0.17,
                //         child: GestureDetector(
                //           onTap: _navigateToLocationScreen,
                //           child: Text(
                //             userLocation ?? 'Select Location',
                //             style: GoogleFonts.roboto(
                //               fontSize: 12,
                //               color: Colors.black,
                //               fontWeight: FontWeight.bold,
                //             ),
                //             overflow: TextOverflow.ellipsis,
                //           ),
                //         ),
                //       ),
                //       // const Spacer(),
                //       SizedBox(width: width * 0.04),
                //       Center(
                //           child: SvgPicture.asset(
                //               'assets/svg_images/homepageLogo.svg')),
                //       const Spacer(),
                //       InkWell(
                //         onTap: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) =>
                //                   const UserNotificationScreen(),
                //             ),
                //           );
                //         },
                //         child: SvgPicture.asset(
                //             'assets/svg_images/notificationIcon.svg'),
                //       ),
                //     ],
                //   ),
                // ),
                // Image.asset(
                //   'assets/images/banner.png',
                //   height: 151,
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                // ),
                // --- Dynamic Image Slider Widget ---
                isBannerLoading
                    ? Container(
                        height: 151,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      )
                    : bannerImages.isEmpty
                        ? Container(
                            height: 151,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No Banners Available",
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              CarouselSlider.builder(
                                carouselController: _carouselController,
                                itemCount: bannerImages.length,
                                itemBuilder: (context, index, realIndex) {
                                  final image = bannerImages[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ViewImage(
                                            imageUrl: image,
                                            title: "Banner Image",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(

                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.fill,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "Image Failed to Load",
                                                      style: GoogleFonts.roboto(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height: 170,
                                  viewportFraction: 0.9,
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: bannerImages.map((image) {
                                  int index = bannerImages.indexOf(image);
                                  return Container(
                                    width: _currentIndex == index ? 16.0 : 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: _currentIndex == index
                                          ? Colors.green.shade800
                                          : Colors.grey,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text(
                    "WORK CATEGORIES",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: allCategories.take(6).map((category) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width / 6 - 10,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubCategories(
                                        categoryId: category.id,
                                        categoryName: '',
                                      ),
                                    ),
                                  );
                                },
                                child: CategoryItemWidget(
                                  id: category.id,
                                  name: category.name,
                                  imagePath: category.image,
                                  subtitle: category.subtitle ?? '',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Center(
                    child: Text(
                      'By selecting category, you can find workers',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFFA7A7A7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkerCategories(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 330,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green.shade700,
                      ),
                      child: const Center(
                        child: Text(
                          'See All',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    print("gadge: emergency task tap ::: ");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmergencyScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(12)),
                      width: double.infinity,
                      //  color: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Emergency Task",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Book emergency services for quick fixes",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          SvgPicture.asset(
                              'assets/svg_images/emergencytaskIcon.svg'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FEATURED WORKER",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 70),
                      Text(
                        "See All",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: WorkerCard(worker: workers[index]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostTaskScreen()),
              );
            },
            backgroundColor: Colors.green.shade800,
            elevation: 6,
            shape: const CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 26,
                  width: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, color: Colors.green, size: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Post the task',
                  style: GoogleFonts.roboto(
                    fontSize: 7,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class CategoryItemWidget extends StatelessWidget {
  final String id;
  final String name;
  final String imagePath;
  final String subtitle;
  final bool isSelected;

  const CategoryItemWidget({
    super.key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.subtitle,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Column(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.green.shade100,
              shape: BoxShape.circle,
              border:
                  isSelected ? Border.all(color: Colors.black, width: 1) : null,
            ),
            /*child: ClipOval(
              child: imagePath.isNotEmpty
                  ? imagePath.startsWith('http')
                  ? Image.network(
                imagePath,
                height: 42,
                width: 42,
                // fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 22);
                },
              )
                  : Image.asset(
                'assets/images/$imagePath',
                height: 42,
                width: 42,
                // fit: BoxFit.cover,
              )
                  : const Icon(Icons.person, size: 22),
            ),*/
            child: ClipOval(
              child: imagePath.isNotEmpty
                  ? imagePath.startsWith('http')
                      ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.network(
                            imagePath,
                            height: 42,
                            width: 42,
                            // fit: BoxFit.cover, // 👈 yeh important
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 22);
                            },
                          ),
                        )
                      : Image.asset(
                          'assets/images/$imagePath',
                          height: 42,
                          width: 42,
                          fit: BoxFit
                              .cover, // 👈 local image bhi crop ke bina dikhegi
                        )
                  : const Icon(Icons.person, size: 22),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 129,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/images/plumber1.png',
              height: 109,
              width: 108.75,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            worker.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  worker.role,
                  style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.star_outline, size: 14, color: Colors.green.shade700),
              const SizedBox(width: 2),
              Text(
                worker.rating.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
