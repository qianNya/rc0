import 'package:latlong2/latlong.dart';

/// A map tap/long-press selection used to create a scene at that location.
class SceneMapPick {
  const SceneMapPick({
    required this.point,
    required this.city,
    this.placeName = '',
    this.address = '',
  });

  final LatLng point;
  final String city;
  final String placeName;
  final String address;

  String get locationLabel =>
      placeName.isNotEmpty ? placeName : '地图选点';
}

typedef SceneMapCreateCallback = Future<void> Function(SceneMapPick pick);
