import 'package:developer/Emergency/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
 static final tag="MapLauncher";
  static Future<bool> openMap({
    var latitude,
    var longitude,
    String? address,
  }) async {
    bwDebug("[OpenMap] Address: $address, Latitude: $latitude, Longitude: $longitude",tag: tag);
    String googleMapsUrl;

    if (latitude != null && longitude != null && latitude != 0.0 && longitude != 0.0) {
      googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
      bwDebug("Opening map with lat/lng: $latitude, $longitude");
    }
    else if (address != null && address.trim().isNotEmpty && address != 'Select Location') {
      final encodedAddress = Uri.encodeComponent(address.trim());
      googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
      bwDebug("Opening map with address: $address");
    }
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