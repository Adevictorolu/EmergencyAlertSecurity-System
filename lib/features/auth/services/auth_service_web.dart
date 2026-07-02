// Stub for web platform (dart:html available, dart:io is NOT)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Returns false on web — no SocketException exists.
bool isSocketException(dynamic e) => false;

/// Not used on web — returns null.
Future<Map<String, double?>?> getNativeLocation() async => null;

/// Gets location using the browser Geolocation API (dart:html Future-based API).
Future<Map<String, double?>?> getWebLocation() async {
  try {
    final pos = await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 10),
    );
    return {
      'lat': pos.coords?.latitude?.toDouble(),
      'lng': pos.coords?.longitude?.toDouble(),
    };
  } catch (_) {
    // User denied permission or geolocation unavailable — proceed without location
    return null;
  }
}
