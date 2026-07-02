// Stub for non-web platforms (dart:io available)
import 'dart:io' show SocketException;
import 'package:location/location.dart';

/// Returns true if [e] is a SocketException (network error).
bool isSocketException(dynamic e) => e is SocketException;

/// Gets location using the native `location` package.
Future<Map<String, double?>?> getNativeLocation() async {
  try {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Please enable them to send an alert.',
        );
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception(
          'Location permission is required to send an alert.',
        );
      }
    }

    final locData = await location.getLocation();
    return {'lat': locData.latitude, 'lng': locData.longitude};
  } catch (e) {
    // Return null and let the alert proceed without location
    return null;
  }
}

/// Not used on native — returns null.
Future<Map<String, double?>?> getWebLocation() async => null;
