import 'dart:async';
import 'dart:convert';

import 'package:developer/Widgets/CustomButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/Bottombar.dart';
import '../../../utility/custom_snack_bar.dart';
import 'LoginScreen.dart';
import 'RoleSelectionScreen.dart';

class SignupAddressDetailScreen extends StatefulWidget {
  final String? initialAddress;
  final LatLng? initialLocation;
  final String? initialTitle;
  final String? initialLandmark;
  final String? editlocationId;
  final String? name;
  final String? refralCode;
  final String? role;
  final String? gender;
  final age;
  final dataHide;

  const SignupAddressDetailScreen({
    super.key,
    this.initialAddress,
    this.initialLocation,
    this.initialTitle,
    this.initialLandmark,
    this.editlocationId,
    this.name,
    this.refralCode,
    this.role,
    this.gender,
    this.age,
    this.dataHide,
  });

  @override
  State<SignupAddressDetailScreen> createState() =>
      _SignupAddressDetailScreenState();
}

class _SignupAddressDetailScreenState extends State<SignupAddressDetailScreen> {
  late GoogleMapController mapController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LatLng _initialPosition = const LatLng(22.7196, 75.8577);
  bool _isLoadingAddress = false;
  Timer? _debounceTimer;

  // Placeholder for selected location from radio button (latitude, longitude, address)
  LatLng? _selectedLocation; // Updated when radio button is selected
  String? _selectedAddress; // Updated when radio button is selected
  bool isLoading = false;

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

  void _showMessageSuccessAddress(String message) {
<<<<<<< HEAD
    CustomSnackBar.show(message: message, type: SnackBarType.success);
=======
     CustomSnackBar.show(
        message: message,
        type: SnackBarType.success
    );

>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // _showMessage('Please enable location services.');
<<<<<<< HEAD
      CustomSnackBar.show(
          message: 'Please enable location services.',
          type: SnackBarType.error);
=======
       CustomSnackBar.show(
          message:'Please enable location services.' ,
          type: SnackBarType.error
      );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // _showMessage('Location permission denied.');
<<<<<<< HEAD
        CustomSnackBar.show(
            message: 'Location permission denied.', type: SnackBarType.warning);
=======
         CustomSnackBar.show(
            message: 'Location permission denied.',
            type: SnackBarType.warning
        );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
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
      // _showMessage('Unable to get location: $e');
<<<<<<< HEAD
      CustomSnackBar.show(
          message: 'Unable to get location: $e', type: SnackBarType.error);
=======
       CustomSnackBar.show(
          message: 'Unable to get location: $e',
          type: SnackBarType.error
      );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
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
        // _showMessage('Error fetching address: $e');
<<<<<<< HEAD
        CustomSnackBar.show(
            message: 'Error fetching address: $e', type: SnackBarType.error);
=======
         CustomSnackBar.show(
            message:'Error fetching address: $e' ,
            type: SnackBarType.error
        );

>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
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
        borderSide: BorderSide(color: AppColors.greyBorder, width: 1.5),
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
      ),
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
          height: 50,
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
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

  // Placeholder function to update selected location from radio button
  void _updateSelectedLocation(LatLng location, String address) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress = address;
      _initialPosition = location; // Update map position
      addressController.text = address; // Update address field
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15.0),
      );
    });
  }

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null || token.isEmpty) {
          if (mounted) {
            // _showMessage('Token not found. Please log in.');
<<<<<<< HEAD
            CustomSnackBar.show(
=======
             CustomSnackBar.show(
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
                message: 'Token not found. Please log in.',
                type: SnackBarType.warning);

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
            'https://api.thebharatworks.com/api/user/updateUserProfile';
        final Map<String, dynamic> payload = {
          'full_name': widget.name ?? '',
          'role': widget.role ?? '',
          'location': {
            'latitude':
                _selectedLocation?.latitude ?? _initialPosition.latitude,
            'longitude':
                _selectedLocation?.longitude ?? _initialPosition.longitude,
            'address': _selectedAddress ?? addressController.text,
          },
          'full_address': [
            {
              '_id': widget.editlocationId ?? '',
              'title': titleController.text,
              'address': _selectedAddress ?? addressController.text,
              'landmark': landmarkController.text,
              'latitude':
                  _selectedLocation?.latitude ?? _initialPosition.latitude,
              'longitude':
                  _selectedLocation?.longitude ?? _initialPosition.longitude,
            }
          ],
          'referral_code': widget.refralCode ?? '',
        };

        print("Debug: Sending updateUserProfile with payload: $payload");

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        print("Debug: updateUserProfile response: ${response.body}");
        print("Debug: updateUserProfile statusCode: ${response.statusCode}");

        if (!mounted) return;

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          await prefs.setString(
              'selected_location', _selectedAddress ?? addressController.text);
          await prefs.setString(
              'address', _selectedAddress ?? addressController.text);
          await prefs.setDouble('user_latitude',
              _selectedLocation?.latitude ?? _initialPosition.latitude);
          await prefs.setDouble('user_longitude',
              _selectedLocation?.longitude ?? _initialPosition.longitude);
          await prefs.setString(
              'selected_address_id', widget.editlocationId ?? '');

          if (mounted) {
            // _showMessage('Address updated successfully.');
<<<<<<< HEAD
            CustomSnackBar.show(
                message: 'Address updated successfully.',
                type: SnackBarType.success);
=======
             CustomSnackBar.show(
                message:'Address updated successfully.' ,
                type: SnackBarType.success
            );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e

            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pop(context, {
                'address': _selectedAddress ?? addressController.text,
                'latitude':
                    _selectedLocation?.latitude ?? _initialPosition.latitude,
                'longitude':
                    _selectedLocation?.longitude ?? _initialPosition.longitude,
                'addressId': widget.editlocationId,
              });
            }
          }
        } else {
          if (mounted) {
            // _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
<<<<<<< HEAD
            CustomSnackBar.show(
                message:
                    'API error: ${responseData['message'] ?? 'Unknown error'}',
                type: SnackBarType.error);
=======
             CustomSnackBar.show(
                message: 'API error: ${responseData['message'] ?? 'Unknown error'}',
                type: SnackBarType.error
            );

>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
          }
        }
      } catch (e) {
        if (mounted) {
          // _showMessage('Error updating address: $e');
<<<<<<< HEAD
          CustomSnackBar.show(
              message: 'Error updating address: $e', type: SnackBarType.error);
=======
            CustomSnackBar.show(
              message:'Error updating address: $e' ,
              type: SnackBarType.error
          );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e

          print("Error in _updateAddress: $e");
        }
      }
    } else {
      // _showMessage('Please fill all fields correctly.');
<<<<<<< HEAD
      CustomSnackBar.show(
=======
       CustomSnackBar.show(
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
          message: 'Please fill all fields correctly.',
          type: SnackBarType.warning);
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
            // _showMessage('Token not found. Please log in.');
<<<<<<< HEAD
            CustomSnackBar.show(
=======
             CustomSnackBar.show(
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
                message: 'Token not found. Please log in.',
                type: SnackBarType.warning);
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
            'https://api.thebharatworks.com/api/user/updateUserProfile';
        final Map<String, dynamic> payload = {
          'full_name': widget.name ?? '',
          'role': widget.role ?? '',
          'location': {
            'latitude':
                _selectedLocation?.latitude ?? _initialPosition.latitude,
            'longitude':
                _selectedLocation?.longitude ?? _initialPosition.longitude,
            'address': _selectedAddress ?? addressController.text,
          },
          'full_address': [
            {
              'title': titleController.text,
              'address': _selectedAddress ?? addressController.text,
              'landmark': landmarkController.text,
              'latitude':
                  _selectedLocation?.latitude ?? _initialPosition.latitude,
              'longitude':
                  _selectedLocation?.longitude ?? _initialPosition.longitude,
            }
          ],
          'referral_code': widget.refralCode ?? '',
        };

        print("Debug: Sending updateUserProfile with payload: $payload");

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        print("Debug: updateUserProfile response: ${response.body}");
        print("Debug: updateUserProfile statusCode: ${response.statusCode}");

        if (!mounted) return;

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          await prefs.setBool('isProfileComplete', true);
          await prefs.setString(
              'selected_location', _selectedAddress ?? addressController.text);
          await prefs.setString(
              'address', _selectedAddress ?? addressController.text);
          await prefs.setDouble('user_latitude',
              _selectedLocation?.latitude ?? _initialPosition.latitude);
          await prefs.setDouble('user_longitude',
              _selectedLocation?.longitude ?? _initialPosition.longitude);
          await prefs.setString(
              'selected_address_id', responseData['addressId'] ?? '');

          if (mounted) {
            // _showMessage('Address added successfully.');
<<<<<<< HEAD
            CustomSnackBar.show(
=======
             CustomSnackBar.show(
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
                message: 'Address added successfully.',
                type: SnackBarType.success);
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
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
            // _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
<<<<<<< HEAD
            CustomSnackBar.show(
                message:
                    'API error: ${responseData['message'] ?? 'Unknown error'}',
                type: SnackBarType.error);
=======
             CustomSnackBar.show(
                message: 'API error: ${responseData['message'] ?? 'Unknown error'}',
                type: SnackBarType.error
            );

>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
          }
        }
      } catch (e) {
        if (mounted) {
          // _showMessage('Error adding address: $e');
<<<<<<< HEAD
          CustomSnackBar.show(
              message: 'Error adding address: $e', type: SnackBarType.error);
=======
            CustomSnackBar.show(
              message: 'Error adding address: $e',
              type: SnackBarType.error
          );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e

          print("Error in _addAddress: $e");
        }
      }
    } else {
      // _showMessage('Please fill all fields correctly.');
<<<<<<< HEAD
      CustomSnackBar.show(
          message: 'Please fill all fields correctly.',
          type: SnackBarType.warning);
=======
       CustomSnackBar.show(
          message:'Please fill all fields correctly.' ,
          type: SnackBarType.warning
      );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
    }
  }

  Future<void> submitFunction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // ✅ loader start
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final role = prefs.getString('role');
        print(
          "🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}",
        );

        if (token == null || token.isEmpty) {
          if (mounted) {
            // _showMessage('Token not found. Please log in.');
<<<<<<< HEAD
            CustomSnackBar.show(
=======
             CustomSnackBar.show(
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
                message: 'Token not found. Please log in.',
                type: SnackBarType.warning);
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
            'https://api.thebharatworks.com/api/user/updateUserProfile';
        final Map<String, dynamic> payload = {
          'full_name': widget.name ?? '',
          'role': widget.role ?? '',
          "gender": widget.gender,
          "age": widget.age,
          'location': {
            'latitude':
                _selectedLocation?.latitude ?? _initialPosition.latitude,
            'longitude':
                _selectedLocation?.longitude ?? _initialPosition.longitude,
            'address': _selectedAddress ?? addressController.text,
          },
          'full_address': [
            {
              '_id': widget.editlocationId ?? '',
              'title': titleController.text,
              'address': _selectedAddress ?? addressController.text,
              'landmark': landmarkController.text,
              'latitude':
                  _selectedLocation?.latitude ?? _initialPosition.latitude,
              'longitude':
                  _selectedLocation?.longitude ?? _initialPosition.longitude,
            }
          ],
          'referral_code': widget.refralCode ?? '',
        };

        print("Debug: Sending updateUserProfile with payload: $payload");

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        print("Debug: updateUserProfile response: ${response.body}");
        print("Debug: updateUserProfile statusCode: ${response.statusCode}");

        if (!mounted) return;

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          await prefs.setBool('isProfileComplete', true);
          await prefs.setString(
              'selected_location', _selectedAddress ?? addressController.text);
          await prefs.setString(
              'address', _selectedAddress ?? addressController.text);
          await prefs.setDouble('user_latitude',
              _selectedLocation?.latitude ?? _initialPosition.latitude);
          await prefs.setDouble('user_longitude',
              _selectedLocation?.longitude ?? _initialPosition.longitude);
          await prefs.setString('selected_address_id',
              responseData['addressId'] ?? widget.editlocationId ?? '');

          if (mounted) {
            // widget.editlocationId != null ? _showMessageSuccessAddress('Sign up successful.',) : _showMessageSuccessAddress('Sign up successful.',);

            // widget.dataHide == "hide" ? _showMessageSuccessAddress('Sign up successful.',) : _showMessageSuccessAddress('Address saved successfully.');
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      (role == 'user' || role == 'service_provider')
                          ? const Bottombar()
                          : const RoleSelectionScreen(),
                ),
                (route) => false,
              );
              widget.dataHide == "hide"
                  ? CustomSnackBar.show(
                      message: "Sign up successful.",
                      type: SnackBarType.success)
                  : CustomSnackBar.show(
                      message: "Address saved successfully.",
                      type: SnackBarType.success);

              // Navigator.pop(context, {
              //   'address': _selectedAddress ?? addressController.text,
              //   'addressId': responseData['addressId'] ?? widget.editlocationId ?? '',
              //   'latitude': _selectedLocation?.latitude ?? _initialPosition.latitude,
              //   'longitude': _selectedLocation?.longitude ?? _initialPosition.longitude,
              //   'title': titleController.text,
              //   'landmark': landmarkController.text,
              //   'isEdit': widget.editlocationId != null, // true if editing, false if adding
              // });
            }
          }
        } else {
          if (mounted) {
            // _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
<<<<<<< HEAD
            CustomSnackBar.show(
                message:
                    'API error: ${responseData['message'] ?? 'Unknown error'}',
                type: SnackBarType.error);
=======
             CustomSnackBar.show(
                message: 'API error: ${responseData['message'] ?? 'Unknown error'}',
                type: SnackBarType.error
            );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
          }
        }
      } catch (e) {
        if (mounted) {
          // _showMessage('Error calling API: $e');
<<<<<<< HEAD
          CustomSnackBar.show(
              message: 'Error calling API: $e', type: SnackBarType.error);
=======
            CustomSnackBar.show(
              message:'Error calling API: $e' ,
              type: SnackBarType.error
          );
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
          print("❌ Error: $e");
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false; // ✅ loader band karo
          });
        }
      }
    } else {
      // _showMessage('Please fill all fields correctly.');
<<<<<<< HEAD
      CustomSnackBar.show(
=======
       CustomSnackBar.show(
>>>>>>> 863e96cded1345cf6d8a44e851fa25909251ec1e
          message: 'Please fill all fields correctly.',
          type: SnackBarType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Debug: AddressDetailScreen build, editlocationId: ${widget.editlocationId}");
    print(
        "Debug: get userdetail : ${widget.name} user role ${widget.role} user refral ${widget.refralCode}");
    return Scaffold(
      // backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Location",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   children: [
                //     GestureDetector(
                //       onTap: () => Navigator.pop(context),
                //       child: const Padding(
                //         padding: EdgeInsets.only(left: 18.0),
                //         child: Icon(Icons.arrow_back_outlined, size: 22),
                //       ),
                //     ),
                //     const SizedBox(width: 90),
                //     Text(
                //       'Location',
                //       style: GoogleFonts.poppins(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //         color: AppColors.black,
                //       ),
                //     ),
                //   ],
                // ),
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
                        gestureRecognizers: <Factory<
                            OneSequenceGestureRecognizer>>{
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
                        hint: 'Enter Title',
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
                      // CustomButton(
                      //   label: isLoading ? "Loading.." : 'Submit',
                      //   onPressed: () async {
                      //     if (_formKey.currentState!.validate()) {
                      //       try {
                      //         final prefs = await SharedPreferences.getInstance();
                      //         final token = prefs.getString('token');
                      //         final role = prefs.getString('role');
                      //         print(
                      //           "🔍 Before API Call - Token: $token, Role: $role, ProfileComplete: ${prefs.getBool('isProfileComplete')}",
                      //         );
                      //
                      //         if (token == null || token.isEmpty) {
                      //           if (mounted) {
                      //             _showMessage('Token not found. Please log in.');
                      //             await Future.delayed(const Duration(seconds: 2));
                      //             if (mounted) {
                      //               Navigator.pushAndRemoveUntil(
                      //                 context,
                      //                 MaterialPageRoute(builder: (context) => const LoginScreen()),
                      //                     (route) => false,
                      //               );
                      //             }
                      //           }
                      //           return;
                      //         }
                      //
                      //         const String apiUrl = 'https://api.thebharatworks.com/api/user/updateUserProfile';
                      //         final Map<String, dynamic> payload = {
                      //           'full_name': widget.name ?? '',
                      //           'role': widget.role ?? '',
                      //           "gender": widget.gender,  //["male", "female", "other"],
                      //           "age":widget.age,
                      //           'location': {
                      //             'latitude': _selectedLocation?.latitude ?? _initialPosition.latitude,
                      //             'longitude': _selectedLocation?.longitude ?? _initialPosition.longitude,
                      //             'address': _selectedAddress ?? addressController.text,
                      //           },
                      //           'full_address': [
                      //             {
                      //               '_id': widget.editlocationId ?? '',
                      //               'title': titleController.text,
                      //               'address': _selectedAddress ?? addressController.text,
                      //               'landmark': landmarkController.text,
                      //               'latitude': _selectedLocation?.latitude ?? _initialPosition.latitude,
                      //               'longitude': _selectedLocation?.longitude ?? _initialPosition.longitude,
                      //             }
                      //           ],
                      //           'referral_code': widget.refralCode ?? '',
                      //         };
                      //
                      //         print("Debug: Sending updateUserProfile with payload: $payload");
                      //
                      //         final response = await http.post(
                      //           Uri.parse(apiUrl),
                      //           headers: {
                      //             'Content-Type': 'application/json',
                      //             'Authorization': 'Bearer $token',
                      //           },
                      //           body: jsonEncode(payload),
                      //         );
                      //
                      //         print("Debug: updateUserProfile response: ${response.body}");
                      //         print("Debug: updateUserProfile statusCode: ${response.statusCode}");
                      //
                      //         if (!mounted) return;
                      //
                      //         final responseData = jsonDecode(response.body);
                      //
                      //         if (response.statusCode == 200 && responseData['status'] == true) {
                      //           await prefs.setBool('isProfileComplete', true);
                      //           await prefs.setString('selected_location', _selectedAddress ?? addressController.text);
                      //           await prefs.setString('address', _selectedAddress ?? addressController.text);
                      //           await prefs.setDouble('user_latitude', _selectedLocation?.latitude ?? _initialPosition.latitude);
                      //           await prefs.setDouble('user_longitude', _selectedLocation?.longitude ?? _initialPosition.longitude);
                      //           await prefs.setString('selected_address_id', responseData['addressId'] ?? widget.editlocationId ?? '');
                      //
                      //           if (mounted) {
                      //             widget.editlocationId != null ? _showMessage('Address saved successfully.') : _showMessageSuccessAddress('Sign up successful.',) ;
                      //             await Future.delayed(const Duration(seconds: 2));
                      //             if (mounted) {
                      //
                      //               // Navigator.pop(context, true);
                      //               // Navigator.pop(context, {
                      //               //   'address': _selectedAddress ?? addressController.text,
                      //               //   'addressId': responseData['addressId'] ?? widget.editlocationId ?? '',
                      //               //   'latitude': _selectedLocation?.latitude ?? _initialPosition.latitude,
                      //               //   'longitude': _selectedLocation?.longitude ?? _initialPosition.longitude,
                      //               //   'title': titleController.text,
                      //               //   'landmark': landmarkController.text,
                      //               //   'isEdit': widget.editlocationId != null, // true if editing, false if adding
                      //               // });
                      //
                      //               Navigator.pushAndRemoveUntil(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) => (role == 'user' || role == 'service_provider')
                      //                       ? const Bottombar()
                      //                       : const RoleSelectionScreen(),
                      //                 ),
                      //                     (route) => false,
                      //               );
                      //             }
                      //           }
                      //         } else {
                      //           if (mounted) {
                      //             _showMessage('API error: ${responseData['message'] ?? 'Unknown error'}');
                      //           }
                      //         }
                      //       } catch (e) {
                      //         if (mounted) {
                      //           _showMessage('Error calling API: $e');
                      //           print("❌ Error: $e");
                      //         }
                      //       }
                      //     } else {
                      //       _showMessage('Please fill all fields correctly.');
                      //     }
                      //   },
                      // ),

                      CustomButton(
                        label: isLoading ? "Loading.." : 'Submit',
                        onPressed: () {
                          if (!isLoading) {
                            submitFunction();
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
