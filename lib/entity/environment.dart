class Environment {
  final String city;
  final String locale;
  final String? cloudflareAccountId;
  final String? cloudflareToken;
  final String? area;
  final String units;
  final String cronSchedule;
  final String weatherApiToken;
  final int port;
  final String? country;

  const Environment({
    required this.city,
    required this.locale,
    required this.units,
    this.cloudflareAccountId,
    this.cloudflareToken,
    this.area,
    this.country,
    required this.port,
    required this.cronSchedule,
    required this.weatherApiToken,
  });

  bool get isMetric => units == 'metric';
  bool get isCloudflareFeaturesEnabled =>
      cloudflareAccountId != null &&
      cloudflareAccountId != 'null' &&
      cloudflareToken != null &&
      cloudflareToken != 'null' &&
      area != null &&
      area != 'null';
}
