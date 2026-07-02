import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:rc0/core/location/map_place_service.dart';

void main() {
  final origin = LatLng(22.5431, 114.0579);

  group('decodeUtf8JsonBody', () {
    test('decodes chinese utf8 bytes correctly', () {
      final json = decodeUtf8JsonBody(
        utf8.encode(
          '{"elements":[{"center":{"lat":22.5435,"lon":114.0582},"tags":{"name":"微众银行"}}]}',
        ),
      ) as Map<String, dynamic>;

      final places = parseOverpassElements(json, origin);
      expect(places.first.name, '微众银行');
    });

    test('prefers name:zh over latin name tag', () {
      final json = decodeUtf8JsonBody(
        utf8.encode(
          '{"elements":[{"center":{"lat":22.5435,"lon":114.0582},"tags":{"name":"WeBank","name:zh":"微众银行"}}]}',
        ),
      ) as Map<String, dynamic>;

      final places = parseOverpassElements(json, origin);
      expect(places.first.name, '微众银行');
    });
  });

  group('parseOverpassElements', () {
    test('parses named buildings with center', () {
      final places = parseOverpassElements({
        'elements': [
          {
            'type': 'way',
            'center': {'lat': 22.5435, 'lon': 114.0582},
            'tags': {'name': '深圳湾体育中心', 'building': 'stadium'},
          },
        ],
      }, origin);

      expect(places, hasLength(1));
      expect(places.first.name, '深圳湾体育中心');
      expect(places.first.distanceMeters, isNotNull);
    });

    test('skips unnamed elements', () {
      final places = parseOverpassElements({
        'elements': [
          {
            'type': 'node',
            'lat': 22.5432,
            'lon': 114.058,
            'tags': {'building': 'yes'},
          },
        ],
      }, origin);

      expect(places, isEmpty);
    });
  });

  group('parseNominatimReverse', () {
    test('prefers building name from address', () {
      final place = parseNominatimReverse({
        'lat': '22.5431',
        'lon': '114.0579',
        'address': {
          'building': '平安金融中心',
          'road': '益田路',
          'city': '深圳市',
        },
      }, origin);

      expect(place?.name, '平安金融中心');
      expect(place?.subtitle, contains('益田路'));
    });
  });
}
