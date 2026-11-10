import '../entity/entity.dart';

String buildWeatherPrompt({
  required DateTime date,
  required double temperature,
  required int conditionCode,
  required String city,
  required String region,
  required String sunrise,
  required String sunset,
  List<Holiday> holidays = const [],
  String? countryName,
}) {
  final season = _seasonFragment(date.month);
  final timeOfDay = _timeOfDayFragment(date.hour, date.minute, sunrise, sunset);
  final temp = _temperatureFragment(temperature);

  final holidayDecor = _holidayFragment(holidays, countryName);

  final isNight =
      timeOfDay.contains('deep night') || timeOfDay.contains('twilight');

  final weatherCondition = WeatherCondition.fromCode(conditionCode);
  final conditionEn = weatherCondition.getCondition(isNight);

  final isBadWeather =
      conditionEn.toLowerCase().contains('rain') ||
      conditionEn.toLowerCase().contains('drizzle') ||
      conditionEn.toLowerCase().contains('snow') ||
      conditionEn.toLowerCase().contains('overcast') ||
      conditionEn.toLowerCase().contains('cloudy') ||
      conditionEn.toLowerCase().contains('fog') ||
      conditionEn.toLowerCase().contains('mist') ||
      conditionEn.toLowerCase().contains('storm');

  final skyDesc = isNight
      ? 'dark night sky, visible stars'
      : (isBadWeather
            ? '$conditionEn, overcast gray sky, diffused soft lighting, wet surfaces'
            : '$conditionEn, natural lighting');

  final nightBoost = isNight
      ? 'Night atmosphere: warm glow from windows and street lamps. '
      : '';

  final lightDesc = isNight
      ? 'artificial lighting'
      : (isBadWeather ? 'soft diffused daylight' : 'natural daylight');

  final camera = isNight
      ? 'Shot on Fujifilm X-T5, 23mm f/2, long exposure, cinematic night photography.'
      : (isBadWeather
            ? 'Shot on Fujifilm X-T5, 23mm f/2, soft overcast daylight, moody atmosphere, sharp focus.'
            : 'Shot on Fujifilm X-T5, 23mm f/2, bright daylight, sharp focus.');

  return 'Photorealistic wide shot of a city street in $city, $region. '
      'The sky occupies the upper half of the frame: $skyDesc. '
      '$timeOfDay, $season, $temp. '
      '$nightBoost'
      '$holidayDecor'
      'Urban architecture, streets, $lightDesc, depth of field, '
      'clean negative space in the center for UI widget overlay. '
      '$camera';
}

// ---------- Holidays ----------
String _holidayFragment(List<Holiday> holidays, String? countryName) {
  if (holidays.isEmpty) return '';

  // Пытаемся найти праздник, специфичный для указанной страны
  Holiday targetHoliday = holidays.first;
  if (countryName != null && countryName.isNotEmpty) {
    final matched = holidays.firstWhere(
      (h) => h.text.toLowerCase().contains(countryName.toLowerCase()),
      orElse: () => const Holiday(''),
    );
    if (matched.text.isNotEmpty) {
      targetHoliday = matched;
    }
  }

  final cleanName = targetHoliday.text.split(RegExp(r'[—:]')).last.trim();

  if (cleanName.isEmpty) return '';

  return 'The street atmosphere and subtle visual elements reflect the local holiday: "$cleanName". ';
}

// ---------- Season ----------
String _seasonFragment(int month) {
  switch (month) {
    case 12:
      return 'early winter, snow on roofs';
    case 1:
      return 'deep winter, heavy snow';
    case 2:
      return 'late winter, snowy landscape';
    case 3:
      return 'early spring, melting snow, first green patches';
    case 4:
      return 'mid spring, fresh green foliage';
    case 5:
      return 'late spring, lush green trees';
    case 6:
      return 'early summer, vibrant green foliage';
    case 7:
      return 'mid summer, dense green canopy';
    case 8:
      return 'late summer, green trees';
    case 9:
      return 'early autumn, yellowing leaves';
    case 10:
      return 'mid autumn, yellow and red foliage, wet asphalt';
    case 11:
      return 'late autumn, fallen leaves, bare branches';
    default:
      return 'neutral seasonal tones';
  }
}

// ---------- Time ----------
String _timeOfDayFragment(
  int hour,
  int minute,
  String sunriseStr,
  String sunsetStr,
) {
  final currentMinutes = hour * 60 + minute;
  final sunriseMinutes = _parseTime(sunriseStr, 6, 0);
  final sunsetMinutes = _parseTime(sunsetStr, 18, 0);

  if (currentMinutes < sunriseMinutes - 120) {
    return 'deep night, dark sky, city lights';
  }
  if (currentMinutes < sunriseMinutes) return 'pre-dawn twilight';
  if (currentMinutes < sunriseMinutes + 120) return 'sunrise, morning glow';
  if (currentMinutes < sunsetMinutes - 120) return 'daytime';
  if (currentMinutes < sunsetMinutes) return 'sunset, golden hour';
  if (currentMinutes < sunsetMinutes + 120) return 'dusk, evening twilight';
  return 'deep night, dark sky, city lights';
}

int _parseTime(String timeStr, int defaultH, int defaultM) {
  final parts = timeStr.split(':');
  if (parts.length != 2) return defaultH * 60 + defaultM;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
    return defaultH * 60 + defaultM;
  }
  return h * 60 + m;
}

// ---------- Temperature ----------
String _temperatureFragment(double t) {
  if (t <= -5) return 'freezing cold';
  if (t <= 5) return 'cold';
  if (t <= 14) return 'cool';
  if (t <= 22) return 'warm';
  return 'hot';
}
