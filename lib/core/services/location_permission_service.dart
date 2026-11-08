import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static const _storageKey = 'vidsell.location_permission_requested';
  static LatLng? _lastKnownLocation;

  static LatLng? get lastKnownLocation => _lastKnownLocation;

  final FlutterSecureStorage _storage;

  LocationPermissionService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Check if location permission has already been prompted once.
  Future<bool> hasRequested() async {
    try {
      final value = await _storage.read(key: _storageKey);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Mark location permission as requested so it is never prompted again on app open.
  Future<void> markRequested() async {
    try {
      await _storage.write(key: _storageKey, value: 'true');
    } catch (_) {}
  }

  /// Request system location permission once.
  Future<PermissionStatus> requestPermission() async {
    await markRequested();
    try {
      return await Permission.locationWhenInUse.request();
    } catch (_) {
      return PermissionStatus.denied;
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _lastKnownLocation = null;
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _lastKnownLocation = null;
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return _lastKnownLocation = LatLng(position.latitude, position.longitude);
  }
}
