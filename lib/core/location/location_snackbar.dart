import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'device_location_service.dart';

void showDeviceLocationSnackBar(
  BuildContext context,
  DeviceLocationResult result,
) {
  final message = result.error;
  if (message == null) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: result.openAppSettings
            ? SnackBarAction(
                label: '去设置',
                onPressed: Geolocator.openAppSettings,
              )
            : result.openLocationSettings
                ? SnackBarAction(
                    label: '去设置',
                    onPressed: Geolocator.openLocationSettings,
                  )
                : null,
      ),
    );
}
