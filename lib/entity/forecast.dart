import 'package:weather_backend/utils/utils.dart';

class Forecast {
  final DateTime time;
  final double temperatureC; // always °C
  final int weatherCode;     // number code WWO
  final String condition;    // localized string
  final bool isDay;

  const Forecast({
    required this.time,
    required this.temperatureC,
    required this.weatherCode,
    required this.condition,
    required this.isDay,
  });

  factory Forecast.fromWttrMap(
    Map<String, dynamic> map, {
    required DateTime date,
    required String sunrise, // "HH:mm"
    required String sunset,  // "HH:mm"
    required String locale,
  }) {
    final timeInt = int.parse(map['time'] as String); // "0", "300", ...
    final hour = timeInt ~/ 100;
    final minute = timeInt % 100;
    final dt = DateTime(date.year, date.month, date.day, hour, minute);

    return Forecast(
      time: dt,
      temperatureC: double.parse(map['tempC'] as String),
      weatherCode: int.parse(map['weatherCode'] as String),
      condition: Utils.pickLocalizedCondition(map, locale),
      isDay: Utils.isDay(dt, sunrise, sunset),
    );
  }

  /// [isMetric] определяет, в каких единицах отдавать температуру.
  Map<String, dynamic> toMap({required bool isMetric}) => {
        'time': time.toIso8601String(),
        'temperature': isMetric ? temperatureC : temperatureC * 9 / 5 + 32,
        'temperatureUnit': isMetric ? '°C' : '°F',
        'weatherCode': weatherCode,
        'condition': condition,
        'isDay': isDay,
      };
}