import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Result of a device location lookup.
class DeviceLocationResult {
  const DeviceLocationResult({
    this.position,
    this.error,
    this.openAppSettings = false,
    this.openLocationSettings = false,
  });

  final LatLng? position;
  final String? error;
  final bool openAppSettings;
  final bool openLocationSettings;

  bool get isSuccess => position != null && error == null;
}

/// Maps [LocationPermission] to whether a location request may proceed.
@visibleForTesting
DeviceLocationResult? permissionGate(LocationPermission permission) {
  switch (permission) {
    case LocationPermission.denied:
      return const DeviceLocationResult(error: '需要定位权限才能使用此功能');
    case LocationPermission.deniedForever:
      return const DeviceLocationResult(
        error: '定位权限已被拒绝，请在系统设置中开启',
        openAppSettings: true,
      );
    case LocationPermission.whileInUse:
    case LocationPermission.always:
    case LocationPermission.unableToDetermine:
      return null;
  }
}

/// Resolves the device GPS position with permission handling.
abstract final class DeviceLocationService {
  static Future<DeviceLocationResult> currentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const DeviceLocationResult(
          error: '请开启设备定位服务',
          openLocationSettings: true,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final blocked = permissionGate(permission);
      if (blocked != null) return blocked;

      final position = await _readPosition();
      return DeviceLocationResult(
        position: LatLng(position.latitude, position.longitude),
      );
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return DeviceLocationResult(
          position: LatLng(last.latitude, last.longitude),
        );
      }
      return const DeviceLocationResult(error: '定位超时，请移动到开阔区域后重试');
    } catch (_) {
      return const DeviceLocationResult(error: '无法获取当前位置');
    }
  }

  static Future<Position> _readPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: _locationSettings(),
    );
  }

  static LocationSettings _locationSettings() {
    const timeLimit = Duration(seconds: 12);
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: timeLimit,
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        );
    }
  }
}
