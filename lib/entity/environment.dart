class Environment {
  final String city;
  final String locale;
  final String? cloudflareAccountId;
  final String? cloudflareToken;
  final String units;
  final String cronSchedule;
  final String weatherApiToken;
  final int port;

  const Environment({
    required this.city,
    required this.locale,
    required this.units,
    this.cloudflareAccountId,
    this.cloudflareToken,
    required this.port,
    required this.cronSchedule,
    required this.weatherApiToken,
  });

  bool get isMetric => units == 'metric';
  bool get isCloudflareFeaturesEnabled => cloudflareAccountId != null && cloudflareAccountId != null;
}