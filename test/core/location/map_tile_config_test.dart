import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/core/location/map_tile_config.dart';

void main() {
  group('MapTileConfig', () {
    test('uses the app bundle id for tile requests', () {
      expect(MapTileConfig.packageName, 'com.zjhlife.rc0');
      expect(MapTileConfig.userAgent, contains(MapTileConfig.packageName));
    });

    test('uses CARTO basemaps instead of the OSM public tile server', () {
      expect(
        MapTileConfig.tileUrlTemplate,
        contains('basemaps.cartocdn.com'),
      );
      expect(
        MapTileConfig.tileUrlTemplate,
        isNot(contains('tile.openstreetmap.org')),
      );
      expect(MapTileConfig.osmCopyrightUrl, isNotEmpty);
      expect(MapTileConfig.cartoAttributionUrl, isNotEmpty);
    });

    test('layers include tile and attribution widgets', () {
      final layers = MapTileConfig.layers();
      expect(layers, hasLength(2));
    });
  });
}
