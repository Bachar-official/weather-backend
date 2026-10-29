import 'condition.dart';
import 'forecast.dart';
import 'environment.dart';

class Weather {
  /// Температура в единицах, заданных [Environment.units]
  final double temperature;
  final double apparentTemperature;

  final double humidity;
  final double surfacePressure; // гПа
  final double uvIndex;

  /// Скорость ветра в единицах, заданных [Environment.units] (км/ч или мили/ч)
  final double windSpeed;

  /// Направление ветра в градусах (0–360)
  final int windDegree;

  final Condition condition;
  final bool isDay;

  final DateTime sunrise;
  final DateTime sunset;

  final List<Forecast> forecast;

  const Weather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.surfacePressure,
    required this.uvIndex,
    required this.windSpeed,
    required this.windDegree,
    required this.condition,
    required this.isDay,
    required this.sunrise,
    required this.sunset,
    required this.forecast,
  });

  factory Weather.fromMap(
    Map<String, dynamic> map, {
    required Environment env,
  }) {
    final current = map['current'] as Map<String, dynamic>;
    final forecastData = map['forecast'] as Map<String, dynamic>;
    final forecastDays = forecastData['forecastday'] as List;
    final astro =
        (forecastDays.first as Map<String, dynamic>)['astro']
            as Map<String, dynamic>;

    final metric = env.isMetric;

    // Температура
    final temp = metric
        ? (current['temp_c'] as num).toDouble()
        : (current['temp_f'] as num).toDouble();
    final feelsLike = metric
        ? (current['feelslike_c'] as num).toDouble()
        : (current['feelslike_f'] as num).toDouble();

    // Ветер
    final wind = metric
        ? (current['wind_kph'] as num).toDouble()
        : (current['wind_mph'] as num).toDouble();

    // Давление: API отдаёт mb (гПа) и inHg
    final pressure = metric
        ? (current['pressure_mb'] as num).toDouble()
        : (current['pressure_in'] as num).toDouble();

    // Собираем все часовые прогнозы
    final allHours = <Map<String, dynamic>>[];
    for (final day in forecastDays) {
      final hours = (day as Map<String, dynamic>)['hour'] as List;
      allHours.addAll(hours.cast<Map<String, dynamic>>());
    }

    // Текущее локальное время локации
    final now = DateTime.parse(
      (map['location'] as Map<String, dynamic>)['localtime'] as String,
    );

    final next12Forecasts = allHours
        .map((h) => Forecast.fromMap(h, metric: metric))
        .where((f) => !f.time.isBefore(now))
        .take(12)
        .toList();

    return Weather(
      temperature: temp,
      apparentTemperature: feelsLike,
      humidity: (current['humidity'] as num).toDouble(),
      surfacePressure: pressure,
      uvIndex: (current['uv'] as num).toDouble(),
      windSpeed: wind,
      windDegree: (current['wind_degree'] as num).toInt() % 360,
      condition: Condition.fromMap(
        current['condition'] as Map<String, dynamic>,
      ),
      isDay: current['is_day'] == 1,
      sunrise: _parseAstroTime(astro['sunrise'], now),
      sunset: _parseAstroTime(astro['sunset'], now),
      forecast: next12Forecasts,
    );
  }

  Map<String, dynamic> toMap() => {
    'temperature': temperature,
    'apparentTemperature': apparentTemperature,
    'humidity': humidity,
    'surfacePressure': surfacePressure,
    'uvIndex': uvIndex,
    'windSpeed': windSpeed,
    'windDegree': windDegree,
    'code': condition.code,
    'condition': condition.text,
    'isDay': isDay,
    'sunrise': sunrise.toIso8601String(),
    'sunset': sunset.toIso8601String(),
    'forecast': forecast.map((f) => f.toMap()).toList(),
  };

  @override
  String toString() =>
      'Weather:\n'
      'temperature: $temperature\n'
      'apparentTemperature: $apparentTemperature\n'
      'humidity: $humidity\n'
      'surfacePressure: $surfacePressure\n'
      'uvIndex: $uvIndex\n'
      'windSpeed: $windSpeed\n'
      'windDegree: $windDegree\n'
      'code: ${condition.code}\n'
      'condition: ${condition.text}\n'
      'isDay: $isDay\n'
      'sunrise: $sunrise\n'
      'sunset: $sunset\n'
      'forecast has ${forecast.length} records';
}

DateTime _parseAstroTime(dynamic raw, DateTime reference) {
  final s = raw as String; // "06:15 AM"
  final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)').firstMatch(s);
  if (match == null) {
    throw FormatException('Unexpected astro time: $s');
  }
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3)!;
  if (period == 'AM' && hour == 12) hour = 0;
  if (period == 'PM' && hour != 12) hour += 12;
  return DateTime(reference.year, reference.month, reference.day, hour, minute);
}
