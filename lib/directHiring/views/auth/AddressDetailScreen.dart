import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'RoleSelectionScreen.dart';

class AddressDetailScreen extends StatefulWidget {
  final String? initialAddress;
  final LatLng? initialLocation;
  final String? initialTitle;
  final String? initialLandmark;
  final String? editlocationId;

  const AddressDetailScreen({
    super.key,
    this.initialAddress,
    this.initialLocation,
    this.initialTitle,
    this.initialLandmark,
    this.editlocationId,
  });

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  late GoogleMapController mapController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LatLng _initialPosition = const LatLng(22.7196, 75.8577);
  bool _isLoadingAddress = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle ?? '';
    addressController.text = widget.initialAddress ?? '';
    landmarkController.text = widget.initialLandmark ?? '';
    _initialPosition = widget.initialLocation ?? const LatLng(22.7196, 75.8577);
    if (widget.initialAddress == null) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    titleController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Please enable location services.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permission denied.');
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
        });
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 15.0),
        );
        await _getAddressFromLatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      _showMessage('Unable to get location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      if (_isLoadingAddress) return;
      setState(() {
        _isLoadingAddress = true;
        addressController.text = "Fetching address...";
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            addressController.text =
                "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
                    .replaceAll(', ,', ',')
                    .trim();
          } else {
            addressController.text = 'No address found.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
          addressController.text = 'Coordinates: $lat, $lng (No address found)';
        });
        _showMessage('Error fetching address: $e');
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
      fillColor: AppColors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide:  BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      errorStyle: const TextStyle(
        height: 0,
        fontSize: 0,
      ), // Hide error text to prevent height change
    );
  }

  Widget buildCustomField({
    required TextEditingController controllerField,
    required String hint,
    List<TextInputFormatter>? formatters,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50, // Fixed height for the TextFormField
          child: TextFormField(
            controller: controllerField,
            textAlign: TextAlign.center,
            inputFormatters: formatters,
            decoration: getInputDecoration(hint),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.text,
            validator: validator,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null || token.isEmpty) {
          if (mounted) {
            _showMessage('Token not found. Please log in.');
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            }
          }
          return;
        }

        const String apiUrl =
            'https://api.thebharatworks.com/api/user/updateLocation';
        final Map<String, dynamic> payload = {
          '_id': widget.editlocationId,
          'title': titleController.text,
          'address': addressController.text,
          'landmark': landmarkController.text,
          'latitude': _initialPosition.latitude,
          'longitude': _initialPosition.longitude,
        };

        print("Debug: Sending updateLocation with payload: $payload");

        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        print("Debug: updateLocation response: ${response.body}");
        print("Debug: updateLocation statusCode: ${response.statusCode}");

        if (!mounted) return;

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          await prefs.setString('selected_location', addressController.text);
          await prefs.setString('address', addressController.text);
          await prefs.setDouble('user_latitude', _initialPosition.latitude);
          await prefs.setDouble('user_longitude', _initialPosition.longitude);
          await prefs.setString(
            'selected_address_id',
            widget.editlocationId ?? '',
          );

          if (mounted) {
            _showMessage('Address updated successfully.');
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pop(context, {
                'address': addressController.text,
                'latitude': _initialPosition.latitude,
                'longitude': _initialPosition.longitude,
                'addressId': widget.editlocationId,
              });
            }
          }
        } else {
          if (mounted) {
            _showMessage(
              'API error: ${responseData['message'] ?? 'Unknown error'}',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Error updating address: $e');
          print("Error in _updateAddress: $e");
        }
      }
    } else {
      _showMessage('Please fill all fields correctly.');
    }
  }

  Future<void> _addAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final role = prefs.getString('role');
        if (token == null || token.isEmpty) {
          if (mounted) {
            _showMessage('Token not found. Please log in.');
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            }
          }
          return;
        }

        const String apiUrl =
            'https://api.thebharatworks.com/api/user/addAddress';
        final Map<String, dynamic> payload = {
          'title': titleController.text,
          'address': addressController.text,
          'landmark': landmarkController.text,
          'latitude': _initialPosition.latitude,
          'longitude': _initialPosition.longitude,
        };

        print("Debug: Sending addAddress with payload: $payload");

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        print("Debug: addAddress response: ${response.body}");
        print("Debug: addAddress statusCode: ${response.statusCode}");

        if (!mounted) return;

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          await prefs.setBool('isProfileComplete', true);
          await prefs.setString('selected_location', addressController.text);
          await prefs.setString('address', addressController.text);
          await prefs.setDouble('user_latitude', _initialPosition.latitude);
          await prefs.setDouble('user_longitude', _initialPosition.longitude);
          await prefs.setString(
            'selected_address_id',
            responseData['addressId'] ?? '',
          );

          if (mounted) {
            _showMessage('Address added successfully.');
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                  (role == 'user' || role == 'service_provider')
                      ? const Bottombar()
                      : const RoleSelectionScreen(),
                ),
                    (route) => false,
              );
            }
          }
        } else {
          if (mounted) {
            _showMessage(
              'API error: ${responseData['message'] ?? 'Unknown error'}',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Error adding address: $e');
          print("Error in _addAddress: $e");
        }
      }
    } else {
      _showMessage('Please fill all fields correctly.');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      "Debug: AddressDetailScreen build, editlocationId: ${widget.editlocationId}",
    );
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        toolbarHeight: 10,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Icon(Icons.arrow_back_outlined, size: 22),
                      ),
                    ),
                    const SizedBox(width: 90),
                    Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    widget.editlocationId != null
                        ? 'Edit Location'
                        : 'Select your location',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.greyBorder,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GoogleMap(
                        gestureRecognizers:
                        <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                          ),
                        },
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 15.0,
                        ),
                        myLocationEnabled: true,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        onCameraMove: (position) {
                          setState(() {
                            _initialPosition = position.target;
                          });
                        },
                        onCameraIdle: () {
                          _debounceTimer?.cancel();
                          _debounceTimer = Timer(
                            const Duration(seconds: 1),
                                () {
                              _getAddressFromLatLng(
                                _initialPosition.latitude,
                                _initialPosition.longitude,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Icon(Icons.location_pin, size: 40, color: Colors.red),
                    if (_isLoadingAddress)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      buildCustomField(
                        controllerField: addressController,
                        hint: 'Enter Address',
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z0-9\s,/-]+"),
                          ),
                          LengthLimitingTextInputFormatter(100),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address cannot be empty.';
                          }
                          if (value.length < 10) {
                            return 'Address must be at least 10 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Address Title',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildCustomField(
                        controllerField: titleController,
                        hint: 'Enter Title ',
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z\s]+"),
                          ),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title cannot be empty.';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters long.';
                          }
                          return null;
                        },
                      ),
                      Center(
                        child: Text(
                          'Landmark',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildCustomField(
                        controllerField: landmarkController,
                        hint: 'Enter Landmark',
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z0-9\s,/-]+"),
                          ),
                          LengthLimitingTextInputFormatter(50),
                        ],
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 3) {
                            return 'Landmark must be at least 3 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        label: 'Submit',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final prefs =
                              await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              final role = prefs.getString('role');
                              print(
                                "🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}",
                              );

                              if (token == null || token.isEmpty) {
                                if (mounted) {
                                  _showMessage(
                                    'Token not found. Please log in.',
                                  );
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  ); // Wait for message to show
                                  if (mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                          (route) => false,
                                    );
                                  }
                                }
                                return;
                              }

                              const String apiUrl =
                                  'https://api.thebharatworks.com/api/user/updateUserProfile';

                              final Map<String, dynamic> payload = {
                                'full_address': [
                                  {
                                    'title': titleController.text,
                                    'address': addressController.text,
                                    'landmark': landmarkController.text,
                                    'latitude': _initialPosition.latitude,
                                    'longitude': _initialPosition.longitude,
                                    "_id": widget.editlocationId,
                                  },
                                ],
                              };

                              final response = await http.post(
                                Uri.parse(apiUrl),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode(payload),
                              );

                              print("🔍 API Response: ${response.body}");

                              if (!mounted) return;

                              final responseData = jsonDecode(response.body);

                              if (response.statusCode == 200 &&
                                  responseData['status'] == true) {
                                await prefs.setBool('isProfileComplete', true);
                                if (mounted) {
                                  _showMessage('Address saved successfully.');
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  ); // Wait for message to show
                                  if (mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                        (role == 'user' ||
                                            role ==
                                                'service_provider')
                                            ? const Bottombar()
                                            : const RoleSelectionScreen(),
                                      ),
                                          (route) => false,
                                    );
                                  }
                                }
                              } else {
                                if (mounted) {
                                  _showMessage(
                                    'API error: ${responseData['message'] ?? 'Unknown error'}',
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                _showMessage('Error calling API: $e');
                                print("❌ Error: $e");
                              }
                            }
                          } else {
                            _showMessage('Please fill all fields correctly.');
                          }
                        },
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
}
