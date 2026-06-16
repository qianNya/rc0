abstract final class AppUpdateConfig {
  /// MinIO bucket / object for the release APK (anonymous direct URL returns 403).
  static const apkBucket = 'rc0';
  static const apkObjectKey = 'app-release.apk';
  static const apkFileName = 'app-release.apk';

  /// Fallback direct URL (usually blocked by MinIO policy).
  static const apkUrl = 'http://112.74.176.124:9090/rc0/app-release.apk';

  static const presignExpireSec = 3600;
}
