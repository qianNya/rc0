import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:rc0/core/location/device_location_service.dart';

void main() {
  group('permissionGate', () {
    test('allows whileInUse and always', () {
      expect(permissionGate(LocationPermission.whileInUse), isNull);
      expect(permissionGate(LocationPermission.always), isNull);
    });

    test('allows unableToDetermine for web fallback', () {
      expect(permissionGate(LocationPermission.unableToDetermine), isNull);
    });

    test('blocks denied', () {
      final result = permissionGate(LocationPermission.denied)!;
      expect(result.error, contains('定位权限'));
      expect(result.openAppSettings, isFalse);
    });

    test('blocks deniedForever with settings action', () {
      final result = permissionGate(LocationPermission.deniedForever)!;
      expect(result.error, contains('系统设置'));
      expect(result.openAppSettings, isTrue);
    });
  });
}
