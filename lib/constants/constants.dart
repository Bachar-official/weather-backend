abstract class Constants {
  static String weatherUrl({required String city, required String locale}) => 'https://wttr.in/$city?format=j1&lang=$locale';
  static String holidaysUrl(String locale) => 'https://$locale.wikipedia.org/api/rest_v1/feed/onthisday/holidays/${_getCurrentDateFormatted()}';
  static String cloudflareAiUrl(String accountId) => 'https://api.cloudflare.com/client/v4/accounts/$accountId/ai/run/@cf/black-forest-labs/flux-1-schnell';
}

String _getCurrentDateFormatted() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$month/$day';
}