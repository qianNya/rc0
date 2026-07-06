import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'map_nearby_place.dart';
import 'map_tile_config.dart';

const _nominatimBase = 'https://nominatim.openstreetmap.org';
const _overpassUrl = 'https://overpass-api.de/api/interpreter';
const _nearbyCacheTtl = Duration(seconds: 60);

final _nearbyCache = <String, _CachedNearbyPlaces>{};

class _CachedNearbyPlaces {
  const _CachedNearbyPlaces(this.result, this.expiresAt);

  final MapPlaceLookupResult result;
  final DateTime expiresAt;
}

/// Looks up buildings and named places near a coordinate via OSM APIs.
abstract final class MapPlaceService {
  static Future<MapPlaceLookupResult> nearbyPlaces(
    LatLng center, {
    int radiusMeters = 200,
    int limit = 12,
  }) async {
    final cacheKey = _cacheKey(center);
    final cached = _nearbyCache[cacheKey];
    if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
      return cached.result;
    }

    try {
      final reverse = await _reverseGeocode(center);
      final overpass = await _overpassNamedFeatures(
        center,
        radiusMeters: radiusMeters,
        limit: limit,
      );

      final merged = <MapNearbyPlace>[];
      void addUnique(MapNearbyPlace place) {
        final key = '${place.name}|${place.point.latitude}|${place.point.longitude}';
        if (merged.any(
          (p) =>
              '${p.name}|${p.point.latitude}|${p.point.longitude}' == key,
        )) {
          return;
        }
        merged.add(place);
      }

      if (reverse != null) addUnique(reverse);
      for (final place in overpass) {
        addUnique(place);
      }

      merged.sort((a, b) {
        final da = a.distanceMeters ?? double.infinity;
        final db = b.distanceMeters ?? double.infinity;
        return da.compareTo(db);
      });

      final places = merged.isEmpty
          ? <MapNearbyPlace>[_coordinateFallback(center)]
          : merged.take(limit).toList(growable: false);
      final result = MapPlaceLookupResult(places: places);
      _rememberNearby(cacheKey, result);
      return result;
    } catch (_) {
      final result = MapPlaceLookupResult(
        places: [_coordinateFallback(center)],
        error: '附近建筑查询失败，已使用地图坐标',
      );
      _rememberNearby(cacheKey, result);
      return result;
    }
  }

  static String _cacheKey(LatLng center) {
    return '${center.latitude.toStringAsFixed(5)},'
        '${center.longitude.toStringAsFixed(5)}';
  }

  static void _rememberNearby(String key, MapPlaceLookupResult result) {
    _nearbyCache[key] = _CachedNearbyPlaces(
      result,
      DateTime.now().add(_nearbyCacheTtl),
    );
  }

  static MapNearbyPlace _coordinateFallback(LatLng center) {
    return MapNearbyPlace(
      name: '地图选点',
      subtitle:
          '${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}',
      point: center,
      distanceMeters: 0,
      isCoordinateFallback: true,
    );
  }

  static Future<MapNearbyPlace?> _reverseGeocode(LatLng center) async {
    final uri = Uri.parse('$_nominatimBase/reverse').replace(
      queryParameters: {
        'format': 'jsonv2',
        'lat': '${center.latitude}',
        'lon': '${center.longitude}',
        'addressdetails': '1',
        'accept-language': 'zh-CN',
        'zoom': '18',
      },
    );

    final response = await http
        .get(uri, headers: {'User-Agent': MapTileConfig.userAgent})
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final json = _decodeUtf8Json(response);
    if (json is! Map<String, dynamic>) return null;
    return parseNominatimReverse(json, center);
  }

  static Future<List<MapNearbyPlace>> _overpassNamedFeatures(
    LatLng center, {
    required int radiusMeters,
    required int limit,
  }) async {
    final lat = center.latitude;
    final lng = center.longitude;
    final query = '''
[out:json][timeout:15];
(
  way["building"]["name"](around:$radiusMeters,$lat,$lng);
  node["building"]["name"](around:$radiusMeters,$lat,$lng);
  way["name"]["building"](around:$radiusMeters,$lat,$lng);
  node["name"]["amenity"](around:${radiusMeters - 50},$lat,$lng);
  way["name"]["amenity"](around:${radiusMeters - 50},$lat,$lng);
  node["name"]["tourism"](around:${radiusMeters - 50},$lat,$lng);
  way["name"]["tourism"](around:${radiusMeters - 50},$lat,$lng);
);
out center ${limit + 4};
''';

    final response = await http
        .post(
          Uri.parse(_overpassUrl),
          headers: {
            'User-Agent': MapTileConfig.userAgent,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) return const [];

    final json = _decodeUtf8Json(response);
    if (json is! Map<String, dynamic>) return const [];
    return parseOverpassElements(json, center);
  }
}

@visibleForTesting
dynamic decodeUtf8JsonBody(List<int> bodyBytes) {
  return jsonDecode(utf8.decode(bodyBytes));
}

dynamic _decodeUtf8Json(http.Response response) {
  return decodeUtf8JsonBody(response.bodyBytes);
}

@visibleForTesting
MapNearbyPlace? parseNominatimReverse(
  Map<String, dynamic> json,
  LatLng origin,
) {
  final address = json['address'];
  final name = _firstNonEmpty([
    if (address is Map)
      address['building'] as String?,
    if (address is Map)
      address['public_building'] as String?,
    if (address is Map) address['amenity'] as String?,
    if (address is Map) address['shop'] as String?,
    if (address is Map) address['tourism'] as String?,
    json['name'] as String?,
    if (address is Map) address['road'] as String?,
    json['display_name'] as String?,
  ]);
  if (name == null || name.isEmpty) return null;

  final lat = double.tryParse('${json['lat']}') ?? origin.latitude;
  final lng = double.tryParse('${json['lon']}') ?? origin.longitude;
  final point = LatLng(lat, lng);
  final subtitle = _formatAddress(address);

  return MapNearbyPlace(
    name: name,
    subtitle: subtitle,
    point: point,
    distanceMeters: const Distance().as(LengthUnit.Meter, origin, point),
  );
}

@visibleForTesting
List<MapNearbyPlace> parseOverpassElements(
  Map<String, dynamic> json,
  LatLng origin,
) {
  final elements = json['elements'];
  if (elements is! List) return const [];

  final places = <MapNearbyPlace>[];
  for (final raw in elements) {
    if (raw is! Map<String, dynamic>) continue;
    final tags = raw['tags'];
    if (tags is! Map) continue;

    final name = _localizedTagName(tags);
    if (name.isEmpty) continue;

    final lat = (raw['center']?['lat'] as num?)?.toDouble() ??
        (raw['lat'] as num?)?.toDouble();
    final lng = (raw['center']?['lon'] as num?)?.toDouble() ??
        (raw['lon'] as num?)?.toDouble();
    if (lat == null || lng == null) continue;

    final point = LatLng(lat, lng);
    final building = tags['building']?.toString();
    final subtitle = building != null && building != 'yes'
        ? '建筑 · $building'
        : (tags['amenity'] ?? tags['tourism'] ?? tags['shop'] ?? '')
            .toString();

    places.add(
      MapNearbyPlace(
        name: name,
        subtitle: subtitle.toString(),
        point: point,
        distanceMeters: const Distance().as(
          LengthUnit.Meter,
          origin,
          point,
        ),
      ),
    );
  }
  return places;
}

String _localizedTagName(Map<dynamic, dynamic> tags) {
  for (final key in ['name:zh', 'name:zh-Hans', 'name:zh-CN', 'name']) {
    final value = tags[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

String _formatAddress(Object? address) {
  if (address is! Map) return '';
  final parts = <String>[
    address['road']?.toString() ?? '',
    address['suburb']?.toString() ?? '',
    address['city']?.toString() ?? '',
    address['state']?.toString() ?? '',
  ].where((e) => e.isNotEmpty).toList(growable: false);
  return parts.join(' · ');
}
