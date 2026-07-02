import 'package:latlong2/latlong.dart';

/// A preset city center for the scene map.
class MapCityPreset {
  const MapCityPreset({
    required this.name,
    required this.center,
    this.zoom = 11,
  });

  final String name;
  final LatLng center;
  final double zoom;
}

/// Shared map defaults and searchable city presets.
abstract final class MapCityCatalog {
  static const defaultCityName = '深圳';

  static final defaultCenter = LatLng(22.5431, 114.0579);

  static const defaultZoom = 11.0;

  static const minZoom = 3.0;

  static const maxZoom = 18.0;

  static final cities = <MapCityPreset>[
    MapCityPreset(name: '深圳', center: LatLng(22.5431, 114.0579), zoom: 11),
    MapCityPreset(name: '北京', center: LatLng(39.9042, 116.4074), zoom: 10),
    MapCityPreset(name: '上海', center: LatLng(31.2304, 121.4737), zoom: 10),
    MapCityPreset(name: '广州', center: LatLng(23.1291, 113.2644), zoom: 11),
    MapCityPreset(name: '杭州', center: LatLng(30.2741, 120.1551), zoom: 11),
    MapCityPreset(name: '成都', center: LatLng(30.5728, 104.0668), zoom: 10),
    MapCityPreset(name: '重庆', center: LatLng(29.5630, 106.5516), zoom: 10),
    MapCityPreset(name: '武汉', center: LatLng(30.5928, 114.3055), zoom: 11),
    MapCityPreset(name: '西安', center: LatLng(34.3416, 108.9398), zoom: 11),
    MapCityPreset(name: '南京', center: LatLng(32.0603, 118.7969), zoom: 11),
    MapCityPreset(name: '苏州', center: LatLng(31.2989, 120.5853), zoom: 11),
    MapCityPreset(name: '厦门', center: LatLng(24.4798, 118.0894), zoom: 12),
    MapCityPreset(name: '青岛', center: LatLng(36.0671, 120.3826), zoom: 11),
    MapCityPreset(name: '天津', center: LatLng(39.3434, 117.3616), zoom: 11),
    MapCityPreset(name: '长沙', center: LatLng(28.2282, 112.9388), zoom: 11),
    MapCityPreset(name: '郑州', center: LatLng(34.7466, 113.6254), zoom: 11),
    MapCityPreset(name: '东莞', center: LatLng(23.0207, 113.7518), zoom: 11),
    MapCityPreset(name: '佛山', center: LatLng(23.0218, 113.1219), zoom: 11),
    MapCityPreset(name: '惠州', center: LatLng(23.1115, 114.4162), zoom: 11),
    MapCityPreset(name: '珠海', center: LatLng(22.2707, 113.5767), zoom: 12),
  ];

  static MapCityPreset get defaultCity => cities.first;

  static MapCityPreset? findByName(String name) {
    for (final city in cities) {
      if (city.name == name) return city;
    }
    return null;
  }

  static List<MapCityPreset> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return cities;
    return cities.where((c) => c.name.contains(q)).toList(growable: false);
  }
}
