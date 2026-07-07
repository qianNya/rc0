/// Optional cache lookup for resolved network URLs (injected from app layer).
abstract interface class ImageCachePort {
  /// Returns a cached local file path when already downloaded; null otherwise.
  String? cachedPathSync(String remoteUrl);
}

/// No-op cache used when offline cache is unavailable.
final class NullImageCachePort implements ImageCachePort {
  const NullImageCachePort();

  @override
  String? cachedPathSync(String remoteUrl) => null;
}
