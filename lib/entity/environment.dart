class Environment {
  final String city;
  final String locale;
  final String? cloudflareAccountId;
  final String? cloudflareToken;
  final String pressureUnit;
  final String units;
  final int port;

  const Environment({
    required this.city,
    required this.locale,
    required this.pressureUnit,
    required this.units,
    this.cloudflareAccountId,
    this.cloudflareToken,
    required this.port,
  });
}