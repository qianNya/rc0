class HealthResp {
  final String service;
  final String version;

  HealthResp({required this.service, required this.version});

  factory HealthResp.fromJson(Map<String, dynamic> m) {
    return HealthResp(
      service: m['service'] ?? '',
      version: m['version'] ?? '',
    );
  }
}
