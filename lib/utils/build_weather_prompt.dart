import '../entity/entity.dart';

String buildWeatherPrompt({
  required DateTime date,
  required double temperature,
  required String conditionRu,
  required String city,
  required String region,
  required String sunrise,
  required String sunset,
  List<Holiday> holidays = const [],
}) {
  final season = _seasonFragment(date.month);
  final timeOfDay = _timeOfDayFragment(date.hour, date.minute, sunrise, sunset);
  final temp = _temperatureFragment(temperature);
  final holidayDecor = _holidayFragment(holidays);

  // Усиление для ночи
  final isNight = timeOfDay.contains('глубокая ночь') || timeOfDay.contains('сумерки');
  
  // Для ночи мы ИГНОРИРУЕМ "ясно" и "естественный свет", чтобы модель не рисовала день
  final skyDesc = isNight 
      ? 'тёмное ночное небо, звёзды' 
      : '$conditionRu, естественный свет';

  final nightBoost = isNight
      ? 'Ночная атмосфера: тёплые огни окон и фонарей. '
      : '';

  final lightDesc = isNight ? 'искусственный свет' : 'естественный свет';

  final camera = isNight
      ? 'Снято на Fujifilm X-T5, 23mm f/2, длинная выдержка.' // убрали "огни города"
      : 'Снято на Fujifilm X-T5, 23mm f/2, дневной свет.';

  return 'Фотореалистичный широкий план городской улицы в городе $city, $region. '
      'Небо занимает верхнюю половину кадра: $skyDesc. '
      '$timeOfDay, $season, $temp. '
      '$nightBoost'
      '$holidayDecor'
      'Архитектура города, улицы, $lightDesc, глубина кадра, '
      'свободное пространство в центре для UI-виджета. '
      '$camera';
}

// ---------- Праздники ----------
// (оставляем без изменений, как в прошлый раз)
String _holidayFragment(List<Holiday> holidays) {
  if (holidays.isEmpty) return '';
  final ruHoliday = holidays.firstWhere(
    (h) => h.text.toLowerCase().contains('россия') || h.text.toLowerCase().contains('рф'),
    orElse: () => const Holiday(''),
  );
  if (ruHoliday.text.isEmpty) return '';

  final name = ruHoliday.text.replaceAll(RegExp(r'Россия\s*—\s*', caseSensitive: false), '').trim();
  final lower = name.toLowerCase();

  String decor;
  if (lower.contains('новый год') || lower.contains('рождеств')) {
    decor = 'новогодние гирлянды, украшенные витрины, снежинки, тёплые огни';
  } else if (lower.contains('победы') || lower.contains('9 мая')) {
    decor = 'георгиевские ленты, красные флаги, праздничные баннеры, весенние цветы';
  } else if (lower.contains('8 марта') || lower.contains('женск')) {
    decor = 'весенние тюльпаны, мимозы, поздравительные баннеры';
  } else if (lower.contains('23 февраля') || lower.contains('защитник')) {
    decor = 'флаги, сдержанные праздничные баннеры';
  } else if (lower.contains('день россии') || lower.contains('12 июня')) {
    decor = 'флаги России, триколоры, праздничные баннеры';
  } else if (lower.contains('маслениц')) {
    decor = 'ярмарочные палатки, блины, народные гуляния';
  } else {
    decor = 'тематические баннеры и флаги на улице';
  }
  return 'Улица оформлена к празднику «$name»: $decor. ';
}

// ---------- Сезон ----------
String _seasonFragment(int month) {
  switch (month) {
    case 12: return 'начало зимы, снег на крышах';
    case 1:  return 'зима в самом разгаре, снег';
    case 2:  return 'поздняя зима, снег';
    case 3:  return 'ранняя весна, тающий снег, проталины';
    case 4:  return 'весна в самом разгаре, зелёная листва';
    case 5:  return 'поздняя весна, зелёные деревья';
    case 6:  return 'раннее лето, зелёная листва';
    case 7:  return 'лето в самом разгаре, густая зелёная листва';
    case 8:  return 'позднее лето, зелёная листва';
    case 9:  return 'ранняя осень, желтеющая листва';
    case 10: return 'осень в самом разгаре, жёлтая и красная листва на деревьях, мокрый асфальт';
    case 11: return 'поздняя осень, опавшая листва, голые ветки';
    default: return 'нейтральные сезонные оттенки';
  }
}

// ---------- Время суток ----------
String _timeOfDayFragment(int hour, int minute, String sunriseStr, String sunsetStr) {
  final currentMinutes = hour * 60 + minute;
  final sunriseMinutes = _parseTime(sunriseStr, 6, 0);
  final sunsetMinutes = _parseTime(sunsetStr, 18, 0);

  if (currentMinutes < sunriseMinutes - 120) return 'глубокая ночь, тёмное небо, городские огни';
  if (currentMinutes < sunriseMinutes) return 'предрассветные сумерки';
  if (currentMinutes < sunriseMinutes + 120) return 'рассвет';
  if (currentMinutes < sunsetMinutes - 120) return 'день';
  if (currentMinutes < sunsetMinutes) return 'закат';
  if (currentMinutes < sunsetMinutes + 120) return 'сумерки';
  return 'глубокая ночь, тёмное небо, городские огни';
}

int _parseTime(String timeStr, int defaultH, int defaultM) {
  final parts = timeStr.split(':');
  if (parts.length != 2) return defaultH * 60 + defaultM;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return defaultH * 60 + defaultM;
  return h * 60 + m;
}

// ---------- Температура ----------
String _temperatureFragment(double t) {
  if (t <= -5) return 'мороз';
  if (t <= 5)  return 'холодно';
  if (t <= 14) return 'прохладно';
  if (t <= 22) return 'тепло';
  return 'жарко';
}