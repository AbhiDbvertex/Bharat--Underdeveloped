
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Emergency/User/screens/emergency_services.dart';
import '../../models/userModel/WorkCategoryModel.dart';
import '../../models/userModel/Worker.dart';
import '../../../Bidding/PostTaskScreen.dart';
import '../comm/home_location_screens.dart';
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

  @override
  void initState() {
    super.initState();
    loadSavedLocation(); // Load saved location first
    fetchCategories(); // Fetch categories
    _fetchLocation(); // Sync with API, but prioritize saved location
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
            final currentLocations =
            data['full_address']
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
        debugPrint("❌ API call failed: ${response.statusCode}");
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
      debugPrint("❌ Error fetching location: $e");
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

  Future<void> updateLocationOnServer(
      String newAddress,
      double latitude,
      double longitude,
      ) async {
    if (newAddress.isEmpty || latitude == 0.0 || longitude == 0.0) {
      debugPrint("❌ Invalid location data: $newAddress, $latitude, $longitude");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid location data"),
            duration: Duration(seconds: 2),
          ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Location updated successfully: $newAddress"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Location update failed: ${data['message']}"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Server error, location update failed!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating location: $e"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToLocationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationSelectionScreen(
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

  @override
  Widget build(BuildContext context) {
    debugPrint("📍 Current userLocation: $userLocation");
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade800,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 10,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      // color: Colors.red,
                      child: GestureDetector(
                        onTap: _navigateToLocationScreen,
                        child: SvgPicture.asset('assets/svg_images/LocationIcon.svg'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      // color: Colors.blue,
                      width: width*0.17,
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
                    // const Spacer(),
                    SizedBox(width: width*0.04),
                    Center(child: SvgPicture.asset('assets/svg_images/homepageLogo.svg')),
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
              ),
              Image.asset(
                'assets/images/banner.png',
                height: 151,
                width: double.infinity,
                fit: BoxFit.cover,
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
                onTap:  () {
                  print("gadge: emergency task tap ::: ");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  EmergencyScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                      SvgPicture.asset('assets/svg_images/emergencytaskIcon.svg'),
                    ],
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
                      "FEATURE WORKER",
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
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
        floatingActionButton: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostTaskScreen()),
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
              border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
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
                fit: BoxFit.cover, // 👈 local image bhi crop ke bina dikhegi
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