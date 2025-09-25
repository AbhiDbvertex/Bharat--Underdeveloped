import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Bidding/ServiceProvider/WorkerRecentPostedScreen.dart';
import 'package:developer/Emergency/Service_Provider/Screens/sp_emergency_work_page.dart';
import 'package:developer/Emergency/Service_Provider/Screens/sp_work_detail.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Bidding/view/user/bidding_post_task_screen.dart';
import '../../../Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
import '../../../Emergency/User/screens/emergency_services.dart';
import '../../../Emergency/utils/logger.dart';
import '../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../../models/userModel/WorkCategoryModel.dart';
import '../User/SubCategories.dart';
import '../User/UserHomeScreen.dart';
import '../User/UserNotificationScreen.dart';
import '../User/WorkerCategories.dart';
import '../comm/home_location_screens.dart';
import '../comm/view_images_screen.dart';

// Bidding Order Model
class BiddingOrder {
  final String title;
  final String description;
  final String imageUrl;

  BiddingOrder({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory BiddingOrder.fromJson(Map<String, dynamic> json) {
    return BiddingOrder(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      imageUrl: json['image_url']?.isNotEmpty == true
          // ? 'https://api.thebharatworks.com${json['image_url'][0]}'
          ? '${json['image_url'][0]}'
          : 'https://via.placeholder.com/150',
    );
  }
}

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() =>
      _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
  bool _isSwitched = false;
  bool _isToggling = false;
  String userLocation = "Select Location";
  ServiceProviderProfileModel? profile;
  bool isLoading = true;
  List<BiddingOrder> biddingOrders = [];
  final controller = Get.put(SpEmergencyServiceController());
  bool? verified;
  List<WorkCategoryModel> allCategories = [];
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
  CarouselSliderController();
  List<String> bannerImages = [];
  bool isBannerLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyTask();
    fetchCategories(); // Fetch categories
    _initializeLocation();
    _fetchBiddingOrders();
    fetchProfile();
    controller.getEmergencySpOrderList();
    fetchBanners();
    // setupStaticBanners();
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
    bwDebug("[fetchBanners] called : ",tag:"ServiceProviderHomeScreen");
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
      bwDebug("[fetchBanners]: statusCode: ${response.statusCode},\n body: ${response.body}");
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
            allCategories =
                (jsonData["data"] as List)
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

  Future<void> _loadEmergencyTask() async {
    final prefs = await SharedPreferences.getInstance();
    bool saved = prefs.getBool("emergency_task") ?? false;
    setState(() {
      _isSwitched = saved;
    });
  }

  Future<void> _initializeLocation() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? savedLocation =
        prefs.getString("selected_location") ?? prefs.getString("address");

    if (savedLocation != null && savedLocation != "Select Location") {
      setState(() {
        userLocation = savedLocation;
        isLoading = false;
      });
      print("📍 Loaded saved location: $savedLocation");
      return;
    }

    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        if (mounted) {
          CustomSnackBar.show(
              context,
              message: "No token found, please log in again!",
              type: SnackBarType.warning
          );

        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/getUserProfileData",
      );
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          String apiLocation = 'Select Location';
          String? addressId;
          String userId = data['data']['_id'];
          final verifaiyStatus = data['data']['verified'];
          await prefs.setString("user_id", userId);


          if (data['data']?['full_address'] != null &&
              data['data']['full_address'].isNotEmpty) {
            final addresses = data['data']['full_address'] as List;
            final currentLocations = addresses
                .where((addr) => addr['title'] == 'Current Location')
                .toList();
            if (currentLocations.isNotEmpty) {
              final latestLocation = currentLocations.last;
              apiLocation = latestLocation['address'] ?? 'Select Location';
              addressId = latestLocation['_id'];
            } else {
              final latestAddress = addresses.last;
              apiLocation = latestAddress['address'] ?? 'Select Location';
              addressId = latestAddress['_id'];
            }
          }

          await prefs.setString("address", apiLocation);
          if (addressId != null) {
            await prefs.setString("selected_address_id", addressId);
          }

          setState(() {
            profile = ServiceProviderProfileModel.fromJson(data['data']);
            userLocation = apiLocation;
            verified = verifaiyStatus;
            isLoading = false;
          });
        } else {
          if (mounted) {

            CustomSnackBar.show(
                context,
                message:data["message"] ?? "Profile fetch failed" ,
                type: SnackBarType.error
            );
          }
          setState(() {
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          CustomSnackBar.show(
              context,
              message:  "Server error, profile fetch failed!",
              type: SnackBarType.error
          );


        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      if (mounted) {
        CustomSnackBar.show(
            context,
            message:"Something went wrong, try again!" ,
            type: SnackBarType.error
        );

      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBiddingOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        if (mounted) {
          CustomSnackBar.show(
              context,
              message:"No token found, please log in again!" ,
              type: SnackBarType.warning
          );

        }
        return;
      }

      final url = Uri.parse(
        // "https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders",
        //   Abhishek added this new api
          'https://api.thebharatworks.com/api/bidding-order/getAvailableBiddingOrders'
      );
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final orders = data['data'] as List;
          setState(() {
            biddingOrders =
                orders.map((order) => BiddingOrder.fromJson(order)).toList();
          });
        } else {
          if (mounted) {

            CustomSnackBar.show(
                context,
                message: data["message"] ?? "Failed to fetch bidding orders",
                type: SnackBarType.error
            );


          }
        }
      } else {
        if (mounted) {
          CustomSnackBar.show(
              context,
              message:  "Server error, failed to fetch orders!",
              type: SnackBarType.error
          );


        }
      }
    } catch (e) {
      print("❌ Error fetching bidding orders: $e");
      if (mounted) {
        CustomSnackBar.show(
            context,
            message:"Error fetching orders!" ,
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
      if (mounted) {
        CustomSnackBar.show(
            context,
            message:  "Invalid location data!",
            type: SnackBarType.error
        );


      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/updateUserProfile",
      );
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'full_address': [
            {
              'address': newAddress,
              'latitude': latitude,
              'longitude': longitude,
              'title': 'Current Location',
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          String? newAddressId = data['data']?['full_address']?.last?['_id'];
          await prefs.setString("selected_location", newAddress);
          await prefs.setString("address", newAddress);
          await prefs.setDouble("user_latitude", latitude);
          await prefs.setDouble("user_longitude", longitude);
          if (newAddressId != null) {
            await prefs.setString("selected_address_id", newAddressId);
          }
          setState(() {
            userLocation = newAddress;
            isLoading = false;
          });
        } else {
          if (mounted) {

            CustomSnackBar.show(
                context,
                message:data["message"] ?? "Failed to update location" ,
                type: SnackBarType.error
            );


          }
        }
      } else {
        if (mounted) {

          CustomSnackBar.show(
              context,
              message: "Server error, failed to update location!",
              type: SnackBarType.error
          );


        }
      }
    } catch (e) {
      print("❌ Error updating location: $e");
      if (mounted) {
        CustomSnackBar.show(
            context,
            message:"Error updating location!" ,
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
        if (addressId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_address_id', addressId);
        }
        await _fetchLocation();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid location data, please try again!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _checkEmergencyTask() async {
    setState(() {
      _isToggling = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url =
          Uri.parse("https://api.thebharatworks.com/api/user/emergency");

      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      bwDebug("Emergency API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          setState(() {
            _isSwitched = data["emergency_task"] ?? false;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("emergency_task", _isSwitched);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data["message"] ?? "Updated")),
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data["message"] ?? "Failed to update")),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${response.statusCode}")),
            );
          }
        }

      }
    } catch (e) {
      bwDebug("Error in Emergency API: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } finally {
      controller.getEmergencySpOrderList();
      setState(() {
        _isToggling = false;
      });
    }
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
      return;
    }

    setState(() {
      isLoading = true;
    });

    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      setState(() {
        userLocation = savedLocation ?? 'Select Location';
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed, please log in again!'),
            duration: Duration(seconds: 2),
          ),
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          final data = responseData['data'];
          String apiLocation = 'Select Location';
          String? addressId;

          if (savedAddressId != null && data['full_address'] != null) {
            final matchingAddress = data['full_address'].firstWhere(
              (address) => address['_id'] == savedAddressId,
              orElse: () => null,
            );
            if (matchingAddress != null) {
              apiLocation = matchingAddress['address'] ?? 'Select Location';
              addressId = matchingAddress['_id'];
            }
          }

          if (apiLocation == 'Select Location' &&
              data['full_address'] != null &&
              data['full_address'].isNotEmpty) {
            final currentLocations = data['full_address']
                .where((address) => address['title'] == 'Current Location')
                .toList();
            if (currentLocations.isNotEmpty) {
              final latestCurrentLocation = currentLocations.last;
              apiLocation =
                  latestCurrentLocation['address'] ?? 'Select Location';
              addressId = latestCurrentLocation['_id'];
            } else {
              final latestAddress = data['full_address'].last;
              apiLocation = latestAddress['address'] ?? 'Select Location';
              addressId = latestAddress['_id'];
            }
          }

          await prefs.setString('selected_location', apiLocation);
          await prefs.setString('address', apiLocation);
          if (addressId != null) {
            await prefs.setString('selected_address_id', addressId);
          }

          setState(() {
            userLocation = apiLocation;
            isLoading = false;
          });
        } else {
          setState(() {
            userLocation = savedLocation ?? 'Select Location';
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['message'] ?? 'Failed to fetch profile',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        setState(() {
          userLocation = savedLocation ?? 'Select Location';
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch profile data!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        userLocation = savedLocation ?? 'Select Location';
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching location: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:- get verify status print : ${verified}");
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: /*AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),*/
      AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Ensures content starts from the left
        title: Row(
          children: [
            GestureDetector(
              onTap: _navigateToLocationScreen,
              child: SvgPicture.asset(
                'assets/svg_images/LocationIcon.svg',

              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: GestureDetector(
                onTap: _navigateToLocationScreen,
                child: Text(
                  userLocation??'Select Location',
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
            SvgPicture.asset(
              'assets/svg_images/homepageLogo.svg',
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserNotificationScreen(),
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/svg_images/notificationIcon.svg',

              ),
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
             /* Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateToLocationScreen,
                      child: SvgPicture.asset(
                        'assets/svg_images/LocationIcon.svg',
                        height: height * 0.03,
                        width: width * 0.04,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToLocationScreen,
                        child: Text(
                          userLocation,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/svg_images/homepageLogo.svg',
                      height: height * 0.05,
                      width: width * 0.2,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserNotificationScreen(),
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/svg_images/notificationIcon.svg',
                        height: height * 0.04,
                        width: width * 0.06,
                      ),
                    ),
                  ],
                ),
              ),*/
              SizedBox(height: height * 0.01),
              // Image.asset(
              //   'assets/images/banner.png',
              //   height: height * 0.2,
              //   width: double.infinity,
              //   fit: BoxFit.cover,
              // ),

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

              SizedBox(height: height * 0.015),
              emergencyWork("WORK CATEGORIES",
                  false, () {
                if(profile?.verificationStatus == 'verified') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkerCategories(),
                    ),
                  );
                }else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            Text(
                              "Please complete your profile first. Once your profile is approved by the admin, you will be able to post.",
                              textAlign: TextAlign.center,
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

              } ,profile?.verificationStatus == 'verified'),
              SizedBox(height: height * 0.015),
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
                          if(profile?.verificationStatus == 'verified'){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubCategories(
                                  categoryId: category.id,
                                  categoryName: '',
                                ),
                              ),
                            );
                          }else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Request Submitted"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                      Text(
                                        "Please complete your profile first. Once your profile is approved by the admin, you will be able to post.",
                                        textAlign: TextAlign.center,
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
              SizedBox(height: height * 0.015),
              Center(
                child: Container(
                  width: width * 0.85,
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.015,
                        horizontal: width * 0.05,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg_images/Vector.svg',
                          height: height * 0.03,
                          color: Colors.green.shade700,
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: Text(
                            'Are you ready for Emergency task?',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: 40,
                          height: 20,
                          child: Transform.scale(
                              scale: 0.6,
                              alignment: Alignment.centerLeft,
                              child:
                                  // Switch(
                                  //   value: _isSwitched,
                                  //   onChanged: (bool value) {
                                  //     setState(() {
                                  //       _isSwitched = value;
                                  //     });
                                  //     if (value) {
                                  //       myController.enableFeature();   // API call when ON
                                  //     } else {
                                  //       myController.disableFeature();  // API call when OFF
                                  //     }
                                  //   },
                                  //   activeColor: Colors.red,
                                  //   inactiveThumbColor: Colors.white,
                                  //   inactiveTrackColor: Colors.grey.shade300,
                                  //   materialTapTargetSize:
                                  //   MaterialTapTargetSize.shrinkWrap,
                                  // ),
                                  Stack(
                                alignment: Alignment.center,
                                children: [
                                  Switch(
                                    value: _isSwitched,
                                    onChanged: _isToggling
                                        ? null
                                        : (bool value) {
                                            _checkEmergencyTask();
                                          },
                                    activeColor: Colors.red,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.grey.shade300,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  if (_isToggling)
                                    const CircularProgressIndicator(
                                      // strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.red),
                                    ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.025),
              recentPostWork(
                "RECENT POSTED WORK",
                true,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerRecentPostedScreen(),
                  ),
                ),profile?.verificationStatus == 'verified'
              ),
              SizedBox(height: height * 0.015),
              Container(
                height: height * 0.25,
                width: double.infinity,
                color: Colors.green.shade50,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.015,
                ),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : biddingOrders.isEmpty
                        ? Center(child: Text("No bidding orders found"))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: biddingOrders
                                  .map((order) => Padding(
                                        padding: EdgeInsets.only(
                                            right: width * 0.03),
                                        child: Recent(
                                          name: order.title,
                                          role: order.description,
                                          imagePath: order.imageUrl,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
              ),
              SizedBox(height: height * 0.025),
              emergencyWork(
                "EMERGENCY WORK",
                true,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpEmergencyWorkPage(),
                  ),
                ),profile?.verificationStatus == 'verified'
              ),
              SizedBox(height: height * 0.015),
              Container(
                  height: height * 0.25,
                  width: double.infinity,
                  color: Colors.green.shade50,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.015,
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.orders.isEmpty) {
                      return const Center(child: Text("No data found.\nTurn on emergency task!!",textAlign: TextAlign.center,));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.orders.map((order) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                bwDebug("onTap card ; orderId: ${order.id}",tag:"Service ProviderHomeScreen");

                                Navigator.push(context, MaterialPageRoute(builder:
                                (_) =>SpWorkDetail(order.id, isUser: false),
                                ),
                                ).then((_) async{
                                  await controller.getEmergencySpOrderList();

                                },);
                              },
                              child: EmergencyCard(
                                name: order.categoryId.name, // category ka name
                                role: order.subCategoryIds.isNotEmpty
                                    ? order.subCategoryIds.first.name
                                    : "No SubCategory",
                                imagePath: order.imageUrls.isNotEmpty
                                    ? order.imageUrls.first
                                    : 'assets/images/Fur.png',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  })),
              SizedBox(height: height * 0.025),
              emergencyWork("FEATURED WORKER", false, () {},profile?.verificationStatus == 'verified'),
              SizedBox(height: height * 0.015),
              Container(
                height: height * 0.18,
                width: double.infinity,
                color: Colors.green.shade700,
                padding: EdgeInsets.all(width * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/hand.png',
                      height: height * 0.13,
                      width: width * 0.25,
                    ),
                    SizedBox(width: width * 0.04),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Membership',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Choose your desire membership to',
                            style: GoogleFonts.roboto(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'more features',
                            style: GoogleFonts.roboto(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/arrow.png',
                      height: height * 0.04,
                      width: width * 0.08,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget recentPostWork(String title, bool showPlus, VoidCallback onSeeAll,bool verifaiyStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showPlus)
            InkWell(
              onTap: (){
                if(verifaiyStatus == 'verified'){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> PostTaskScreen()));
                }else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                             Text(
                            "Please complete your profile first. Once your profile is approved by the admin, you will be able to post.",
                              textAlign: TextAlign.center,
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

              },
              child: SvgPicture.asset(
                'assets/svg_images/add-square.svg',
                height: 20,
              ),
            )
          else
            const SizedBox(width: 20),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                InkWell(
                  // onTap: (){
                  //   if(verifaiyStatus == true){
                  //     Navigator.push(context, MaterialPageRoute(builder: (context)=> EmergencyScreen()));
                  //   }else{
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           title: const Text("Request Submitted"),
                  //           content: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               /*Image.asset(
                  //             "assets/images/rolechangeConfim.png",
                  //             height: 90,
                  //           ),*/
                  //               SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                  //               const SizedBox(height: 8),
                  //               const Text(
                  //                 "Request Status",
                  //                 style: TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 18,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 2),
                  //               Center(
                  //                 child: Text(
                  //                   "Please complete your profile first. Once your profile is approved by the admin, you will be able to post.",
                  //                   textAlign: TextAlign.center,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 8),
                  //             ],
                  //           ),
                  //           actions: [
                  //             Center(
                  //               child: Container(
                  //                 width: 100,
                  //                 height: 35,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(8),
                  //                   color: Colors.green,
                  //                 ),
                  //                 child: TextButton(
                  //                   child: const Text(
                  //                     "OK",
                  //                     style: TextStyle(color: Colors.white),
                  //                   ),
                  //                   onPressed: () {
                  //                     Navigator.of(context).pop();
                  //                   },
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     );
                  //   }
                  // },
                  child: Text(
                    "See All",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black38,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black38,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget emergencyWork(String title, bool showPlus, VoidCallback onSeeAll, bool verifaiyStatus) {
    print("Abhi:- print verifaiyStatus : $verifaiyStatus");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showPlus)
            InkWell(
              onTap: (){
                if(verifaiyStatus == true){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> EmergencyScreen()));
                }else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                             Center(
                               child: Text(
                                 "Please complete your profile first. Once your profile is approved by the admin, you will be able to post.",
                                 textAlign: TextAlign.center,
                                                           ),
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
              },
              child: SvgPicture.asset(
                'assets/svg_images/add-square.svg',
                height: 20,
              ),
            )
          else
            const SizedBox(width: 20),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                InkWell(
                  // onTap: (){
                  //   if(verifaiyStatus == true){
                  //     Navigator.push(context, MaterialPageRoute(builder: (context)=> EmergencyScreen()));
                  //   }else{
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           title: const Text("Request Submitted"),
                  //           content: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               /*Image.asset(
                  //             "assets/images/rolechangeConfim.png",
                  //             height: 90,
                  //           ),*/
                  //               SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                  //               const SizedBox(height: 8),
                  //               const Text(
                  //                 "Request Status",
                  //                 style: TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 18,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 2),
                  //               Center(
                  //                 child: Text(
                  //                   "Please complete your profile first. Once your profile is approved by the admin, you will be able to post.",
                  //                   textAlign: TextAlign.center,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 8),
                  //             ],
                  //           ),
                  //           actions: [
                  //             Center(
                  //               child: Container(
                  //                 width: 100,
                  //                 height: 35,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(8),
                  //                   color: Colors.green,
                  //                 ),
                  //                 child: TextButton(
                  //                   child: const Text(
                  //                     "OK",
                  //                     style: TextStyle(color: Colors.white),
                  //                   ),
                  //                   onPressed: () {
                  //                     Navigator.of(context).pop();
                  //                   },
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     );
                  //   }},
                  child: Text(
                    "See All",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black38,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black38,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Recent extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;

  const Recent({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.35, // Fixed to 35% of screen width
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.35,
          maxHeight: screenHeight * 0.2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imagePath,
              width: screenWidth * 0.3,
              height: screenHeight * 0.12,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/Fur.png',
                width: screenWidth * 0.3,
                height: screenHeight * 0.12,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              name,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              role,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;

  const EmergencyCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.35, // Fixed to 35% of screen width
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.35,
          maxHeight: screenHeight * 0.2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imagePath,
              width: screenWidth * 0.3,
              height: screenHeight * 0.12,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if(loadingProgress == null){
                  return child;
                }
                return SizedBox(
                  width: screenWidth *0.3,
                  height: screenHeight*0.12,
                  child: Center(
                    child: SizedBox(
                      width: 0.15.toWidthPercent(),
                      height: 0.15.toWidthPercent(),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => /*Image.asset(
                'assets/images/Fur.png',
                width: screenWidth * 0.3,
                height: screenHeight * 0.12,
                fit: BoxFit.cover,

              ),*/
              SizedBox(
                width: screenWidth * 0.3,
                height: screenHeight * 0.12,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              name,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              role,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
