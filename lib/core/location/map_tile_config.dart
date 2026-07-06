import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared map tile + attribution settings for scene maps.
///
/// Uses CARTO basemaps (OSM-derived) instead of the OSM public tile server so
/// flutter_map does not emit the debug-only OSM policy warning on every mount.
abstract final class MapTileConfig {
  static const packageName = 'com.zjhlife.rc0';
  static const tileUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const tileSubdomains = ['a', 'b', 'c', 'd'];
  static const userAgent =
      'com.zjhlife.rc0/1.0 (scene-map; +https://github.com/qianNya/rc0)';
  static const osmCopyrightUrl = 'https://openstreetmap.org/copyright';
  static const cartoAttributionUrl = 'https://carto.com/attributions/';

  static List<Widget> layers() => [
        TileLayer(
          urlTemplate: tileUrlTemplate,
          subdomains: tileSubdomains,
          userAgentPackageName: packageName,
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(Uri.parse(osmCopyrightUrl)),
            ),
            TextSourceAttribution(
              'CARTO',
              onTap: () => launchUrl(Uri.parse(cartoAttributionUrl)),
            ),
          ],
        ),
      ];
}
