import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/core/location/map_city_catalog.dart';

void main() {
  group('MapCityCatalog', () {
    test('defaults to Shenzhen', () {
      expect(MapCityCatalog.defaultCityName, '深圳');
      expect(MapCityCatalog.defaultCity.name, '深圳');
      expect(MapCityCatalog.defaultCenter.latitude, closeTo(22.5431, 0.001));
    });

    test('search filters cities', () {
      final results = MapCityCatalog.search('深');
      expect(results.map((e) => e.name), contains('深圳'));
      expect(MapCityCatalog.search('不存在'), isEmpty);
    });

    test('findByName returns preset', () {
      expect(MapCityCatalog.findByName('上海')?.center.latitude, closeTo(31.2304, 0.001));
    });
  });
}
