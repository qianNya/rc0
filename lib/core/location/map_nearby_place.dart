import 'package:latlong2/latlong.dart';

/// A named place or building near a map coordinate.
class MapNearbyPlace {
  const MapNearbyPlace({
    required this.name,
    required this.point,
    this.subtitle = '',
    this.distanceMeters,
    this.isCoordinateFallback = false,
  });

  final String name;
  final String subtitle;
  final LatLng point;
  final double? distanceMeters;
  final bool isCoordinateFallback;

  String get distanceLabel {
    final meters = distanceMeters;
    if (meters == null) return '';
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }
}

class MapPlaceLookupResult {
  const MapPlaceLookupResult({
    required this.places,
    this.error,
  });

  final List<MapNearbyPlace> places;
  final String? error;

  bool get isSuccess => error == null;
}
