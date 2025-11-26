import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.addressLine,
    this.city,
    this.country,
  });

  final double latitude;
  final double longitude;
  final String? addressLine;
  final String? city;
  final String? country;

  Map<String, dynamic> toGeoJson({
    String? overridePlaceName,
    String? overrideAddress,
  }) {
    final placeName = overridePlaceName ?? addressLine ?? city;
    final address = overrideAddress ?? addressLine;

    return {
      'type': 'Point',
      'coordinates': [longitude, latitude],
      if (placeName != null) 'placeName': placeName,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
    };
  }
}

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  Future<bool> _ensureServiceEnabled() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) return true;

    serviceEnabled = await Geolocator.openLocationSettings();
    return serviceEnabled && await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationResult?> detectCurrentLocation() async {
    if (!await _ensureServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    String? addressLine;
    String? city;
    String? country;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final buffer = <String?>[
          place.name,
          place.subLocality,
          place.locality,
        ]
            .where((element) => element != null && element!.isNotEmpty)
            .cast<String>()
            .toList();

        addressLine = buffer.isNotEmpty ? buffer.join(', ') : null;
        city = place.locality ?? place.subAdministrativeArea;
        country = place.country;
      }
    } catch (_) {
      // Ignore reverse geocoding errors and return coordinates only.
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      addressLine: addressLine,
      city: city,
      country: country,
    );
  }
}

