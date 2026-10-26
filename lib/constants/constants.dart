abstract class Constants {
  static String weatherUrl({required String city, required String locale, required String apiKey}) => 'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=2&aqi=no&alerts=no&lang=$locale';
  static String holidaysUrl(String locale) => 'https://$locale.wikipedia.org/api/rest_v1/feed/onthisday/holidays/${_getCurrentDateFormatted()}';
  static String cloudflareAiUrl(String accountId) => 'https://api.cloudflare.com/client/v4/accounts/$accountId/ai/run/@cf/black-forest-labs/flux-1-schnell';
  static const noaaSwpcKIndex = 'https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json';
}

String _getCurrentDateFormatted() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$month/$day';
}