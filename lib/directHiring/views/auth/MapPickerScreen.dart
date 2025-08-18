import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng? _pickedLocation;
  String? _address;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      _moveCamera(position.latitude, position.longitude);
    });
  }

  Future<void> _moveCamera(double lat, double lng) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 16),
    ));

    if (!mounted) return;

    setState(() {
      _pickedLocation = LatLng(lat, lng);
    });

    _getAddressFromLatLng(lat, lng);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception("Location permissions are denied.");
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        if (!mounted) return;

        setState(() {
          _address = "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5),
            onMapCreated: (controller) => _controller.complete(controller),
            onCameraMove: (position) {
              _pickedLocation = position.target;
            },
            onCameraIdle: () {
              if (_pickedLocation != null) {
                _getAddressFromLatLng(
                  _pickedLocation!.latitude,
                  _pickedLocation!.longitude,
                );
              }
            },
          ),
          const Icon(Icons.location_pin, size: 40, color: Colors.red),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                if (_address != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_address!, textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_address != null) {
                      Navigator.pop(context, _address);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Select This Location"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
