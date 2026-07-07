import 'package:rc0_media/rc0_media.dart';

import '../services/network_image_cache_service.dart';

/// Bridges app [NetworkImageCacheService] to [ImageResolver.cachePort].
final class NetworkImageCachePort implements ImageCachePort {
  const NetworkImageCachePort();

  @override
  String? cachedPathSync(String remoteUrl) =>
      NetworkImageCacheService.instance.cachedPathSync(remoteUrl);
}
