import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:orbit_notes/core/failure/failure.dart';

class DeviceLocationResult {
  const DeviceLocationResult({
    required this.point,
    this.accuracyMeters,
  });

  final LatLng point;
  final double? accuracyMeters;
}

/// On-demand GPS only — never tracks in the background.
class DeviceLocationService {
  Future<DeviceLocationResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const PermissionFailure(
        'Location is turned off. Enable it in Settings, or drop a pin manually.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const PermissionFailure(
        'Location permission was denied. You can still place a pin on the map.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionFailure(
        'Location is blocked for Orbit. Enable it in Settings, or pin manually.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    return DeviceLocationResult(
      point: LatLng(position.latitude, position.longitude),
      accuracyMeters: position.accuracy,
    );
  }
}
