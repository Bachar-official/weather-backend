import 'package:weather_backend/utils/utils.dart';

import 'environment.dart';
import 'forecast.dart';

class Weather {
  final double temperatureC;
  final double apparentTemperatureC;
  final double humidity;
  final double windSpeedKmh;
  final int windDirectionDegrees;
  final double pressureHpa;
  final double uvIndex;
  final bool isDay;

  final int weatherCode;
  final String condition;

  final String sunrise; // "HH:mm"
  final String sunset;  // "HH:mm"
  final List<Forecast> forecast;

  final Environment _env;

  Weather({
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidity,
    required this.windSpeedKmh,
    required this.windDirectionDegrees,
    required this.pressureHpa,
    required this.uvIndex,
    required this.isDay,
    required this.weatherCode,
    required this.condition,
    required this.sunrise,
    required this.sunset,
    required this.forecast,
    required Environment env,
  }) : _env = env;

  factory Weather.fromWttrMap(
    Map<String, dynamic> map,
    Environment env,
  ) {
    final current =
        (map['current_condition'] as List).first as Map<String, dynamic>;
    final days = (map['weather'] as List).cast<Map<String, dynamic>>();
    final firstDay = days.first;
    final astro =
        (firstDay['astronomy'] as List).first as Map<String, dynamic>;

    final sunrise = _convertAmPmTo24Hour(astro['sunrise'] as String);
    final sunset = _convertAmPmTo24Hour(astro['sunset'] as String);

    // "Сейчас" — реальное локальное время сервера, а не observation_time
    // (observation_time в wttr.in — время последнего наблюдения и может
    // отставать на часы из-за кэша).
    final now = DateTime.now();

    // Восход/закат по датам — для корректного isDay в прогнозе через полночь.
    final sunByDate = <String, ({String sunrise, String sunset})>{};
    for (final day in days) {
      final d = day['date'] as String;
      final a = (day['astronomy'] as List).first as Map<String, dynamic>;
      sunByDate[d] = (
        sunrise: _convertAmPmTo24Hour(a['sunrise'] as String),
        sunset: _convertAmPmTo24Hour(a['sunset'] as String),
      );
    }

    // Собираем все будущие 3-часовые точки.
    final points = <Forecast>[];
    for (final day in days) {
      final dayDate = DateTime.parse(day['date'] as String);
      final dayAstro = (day['astronomy'] as List).first as Map<String, dynamic>;
      final daySunrise = _convertAmPmTo24Hour(dayAstro['sunrise'] as String);
      final daySunset = _convertAmPmTo24Hour(dayAstro['sunset'] as String);

      for (final h in (day['hourly'] as List).cast<Map<String, dynamic>>()) {
        final f = Forecast.fromWttrMap(
          h,
          date: dayDate,
          sunrise: daySunrise,
          sunset: daySunset,
          locale: env.locale,
        );
        if (!f.time.isBefore(now)) points.add(f);
      }
    }

    // 12 почасовых записей вперёд (интерполяция между 3-часовыми точками).
    final next12 = _buildHourlyForecast(
      points: points,
      from: now,
      hours: 12,
      sunByDate: sunByDate,
    );

    final windDeg = int.parse(current['winddirDegree'] as String);

    return Weather(
      temperatureC: double.parse(current['temp_C'] as String),
      apparentTemperatureC: double.parse(current['FeelsLikeC'] as String),
      humidity: double.parse(current['humidity'] as String),
      windSpeedKmh: double.parse(current['windspeedKmph'] as String),
      windDirectionDegrees: windDeg,
      pressureHpa: double.parse(current['pressure'] as String),
      uvIndex: double.parse(current['uvIndex'] as String),
      isDay: Utils.isDay(now, sunrise, sunset),
      weatherCode: int.parse(current['weatherCode'] as String),
      condition: Utils.pickLocalizedCondition(current, env.locale),
      sunrise: sunrise,
      sunset: sunset,
      forecast: next12,
      env: env,
    );
  }

  // ----- Геттеры для отображения в единицах пользователя -----

  double get temperature =>
      _env.isMetric ? temperatureC : temperatureC * 9 / 5 + 32;

  double get apparentTemperature => _env.isMetric
      ? apparentTemperatureC
      : apparentTemperatureC * 9 / 5 + 32;

  double get windSpeed =>
      _env.isMetric ? windSpeedKmh : windSpeedKmh / 1.609344;

  double get pressure => _env.isMetric
      ? pressureHpa * 0.750061683 // гПа → мм рт. ст.
      : pressureHpa * 0.02953;    // гПа → inHg

  String get temperatureUnit => _env.isMetric ? '°C' : '°F';
  String get windSpeedUnit => _env.isMetric ? 'км/ч' : 'миль/ч';
  String get pressureUnit => _env.isMetric ? 'мм рт. ст.' : 'inHg';

  // ----- Serialization -----

  /// Отдаёт значения уже в единицах пользователя (по `_env.isMetric`).
  /// Рядом с каждым числом — строка единицы измерения.
  Map<String, dynamic> toMap() => {
        'temperature': temperature,
        'temperatureUnit': temperatureUnit,
        'apparentTemperature': apparentTemperature,
        'apparentTemperatureUnit': temperatureUnit,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windSpeedUnit': windSpeedUnit,
        'windDirectionDegrees': windDirectionDegrees,
        'pressure': pressure,
        'pressureUnit': pressureUnit,
        'uvIndex': uvIndex,
        'isDay': isDay,
        'weatherCode': weatherCode,
        'condition': condition,
        'sunrise': sunrise,
        'sunset': sunset,
        'forecast':
            forecast.map((f) => f.toMap(isMetric: _env.isMetric)).toList(),
      };

  @override
  String toString() => 'Weather(temp=$temperature$temperatureUnit, '
      'feels=$apparentTemperature$temperatureUnit, '
      'wind=$windSpeed$windSpeedUnit, '
      'pressure=$pressure$pressureUnit, '
      'uv=$uvIndex, isDay=$isDay, '
      'weatherCode=$weatherCode, condition="$condition", '
      'forecast=${forecast.length})';
}

// ----- helpers -----

/// Строит почасовой прогноз на [hours] часов вперёд от [from].
/// Температура интерполируется линейно между 3-часовыми точками,
/// условия/код берутся от ближайшей точки, isDay — по восходу/закату
/// соответствующей даты.
List<Forecast> _buildHourlyForecast({
  required List<Forecast> points,
  required DateTime from,
  required int hours,
  required Map<String, ({String sunrise, String sunset})> sunByDate,
}) {
  if (points.isEmpty) return const [];

  // Начинаем с ближайшего целого часа после `from`.
  var cursor = DateTime(from.year, from.month, from.day, from.hour)
      .add(const Duration(hours: 1));

  final result = <Forecast>[];
  for (var i = 0; i < hours; i++) {
    Forecast? p0;
    Forecast? p1;
    for (final p in points) {
      if (!p.time.isAfter(cursor)) {
        p0 = p;
      } else {
        p1 = p;
        break;
      }
    }
    if (p0 == null && p1 == null) break;

    final double tempC;
    if (p0 == null) {
      tempC = p1!.temperatureC;
    } else if (p1 == null) {
      tempC = p0.temperatureC;
    } else {
      final total = p1.time.difference(p0.time).inMinutes;
      final passed = cursor.difference(p0.time).inMinutes;
      final t = total == 0 ? 0.0 : passed / total;
      tempC = p0.temperatureC + (p1.temperatureC - p0.temperatureC) * t;
    }

    final nearest = _nearest(points, cursor);
    final dateKey = _dateKey(cursor);
    final sun = sunByDate[dateKey] ??
        (sunByDate.values.isNotEmpty ? sunByDate.values.first : null);

    result.add(Forecast(
      time: cursor,
      temperatureC: tempC,
      weatherCode: nearest.weatherCode,
      condition: nearest.condition,
      isDay: sun != null ? Utils.isDay(cursor, sun.sunrise, sun.sunset) : false,
    ));

    cursor = cursor.add(const Duration(hours: 1));
  }
  return result;
}

Forecast _nearest(List<Forecast> points, DateTime t) {
  var best = points.first;
  var bestDiff = best.time.difference(t).inMinutes.abs();
  for (final p in points) {
    final d = p.time.difference(t).inMinutes.abs();
    if (d < bestDiff) {
      best = p;
      bestDiff = d;
    }
  }
  return best;
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _convertAmPmTo24Hour(String amPm) {
  final parts = amPm.trim().split(' ');
  final hm = parts[0].split(':');
  int hour = int.parse(hm[0]);
  final minute = hm[1];
  final isPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
  if (isPm && hour != 12) hour += 12;
  if (!isPm && hour == 12) hour = 0;
  return '${hour.toString().padLeft(2, '0')}:$minute';
}