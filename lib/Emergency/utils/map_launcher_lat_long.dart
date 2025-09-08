import 'package:developer/Emergency/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  /// Opens Google Maps with either latitude/longitude or an address.
  /// If [latitude] and [longitude] are provided, they are used.
  /// If only [address] is provided, it is used to open the map.
  static Future<bool> openMap({
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    String googleMapsUrl;

    // Check if latitude and longitude are provided and valid
    if (latitude != null && longitude != null && latitude != 0.0 && longitude != 0.0) {
      googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
      bwDebug("Opening map with lat/lng: $latitude, $longitude");
    }
    // If only address is provided
    else if (address != null && address.trim().isNotEmpty && address != 'Select Location') {
      // Encode the address to handle spaces and special characters
      final encodedAddress = Uri.encodeComponent(address.trim());
      googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
      bwDebug("Opening map with address: $address");
    }
    // Invalid input
    else {
      bwDebug("Invalid input: Provide either valid lat/lng or a non-empty address");
      return false;
    }

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
        bwDebug("Successfully launched Google Maps: $googleMapsUrl");
        return true;
      } else {
        bwDebug("Could not launch Google Maps: $googleMapsUrl");
        return false;
      }
    } catch (e) {
      bwDebug("Error opening map: $e");
      return false;
    }
  }
}